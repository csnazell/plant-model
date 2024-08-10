#                                                                              #
# PlantModelFramework                                                          #
#                                                                              #
# PlantModelFramework.jl                                                       #
#                                                                              #
# Package root module.                                                         #
#                                                                              #
#    Copyright 2024 Christopher Snazell, Dr Rea L Antoniou-Kourounioti  and    #
#                    The University of Glasgow                                 #
#                                                                              #
#  Licensed under the Apache License, Version 2.0 (the "License");             #
#  you may not use this file except in compliance with the License.            #
#  You may obtain a copy of the License at                                     #
#                                                                              #
#      http://www.apache.org/licenses/LICENSE-2.0                              #
#                                                                              #
#  Unless required by applicable law or agreed to in writing, software         #
#  distributed under the License is distributed on an "AS IS" BASIS,           #
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    #
#  See the License for the specific language governing permissions and         #
#  limitations under the License.                                              #
#                                                                              #
                                                                              
module PlantModelFramework

    # dependencies ------------------------------------------------------------

    # standard library
    
    using Printf

    # third-party
    #
    # - ArgCheck
    # -- argument validation macros
    # -- (https://github.com/jw3126/ArgCheck.jl)

    using ArgCheck

    #
    # package
    #

    include("Simulation.jl")
    include("Models.jl")
    include("Environment.jl")
    include("Clock.jl")
    include("Clocks/Clocks.jl")
    include("Phenology.jl")
    include("Phenologies/Phenologies.jl")
    include("Feature.jl")
    include("Features/Features.jl")

    # - simulation
    
    using .Simulation

    export Simulation

    export getOutput, setOutput, getState, setState

    # - models
    
    using .Models

    # - environment

    using .Environment

    export Environment

    export photoperiod, sunrise, sunset, temperature

    # - clocks
    
    using  .Clock

    import .Clocks

    export Clock, Clocks

    # - phenology
    
    using  .Phenology

    import .Phenologies

    export Phenology, Phenologies

    # - features
    
    using  .Feature

    import .Features

    export Feature, Features

    # implementation ----------------------------------------------------------

    #
    # PlantModel
    #
    # Root model of plant system
    #
    # Construct model & run for a specified number of days
    # 

    # type

    struct PlantModel <: Models.Base

        # fields

        clock::Clock.Model                          # model : clock
        phenology::Union{Nothing, Phenology.Model}  # model : phenology
        features::Vector{Feature.Model}             # models: extensions 

        # constructor

        function PlantModel(clock::Clock.Model,
                            phenology::Union{Nothing, Phenology.Model},
                            features::Vararg{Feature.Model})

            new(clock, phenology, [features...])

        end

    end

    # additional constructors

    function PlantModel(clock::Clock.Model, features::Vararg{Feature.Model})

        PlantModel(clock, nothing, features...)

    end

    #                                                                          #
    # functions                                                                #
    #                                                                          #
    # functor functions                                                        #
    #                                                                          #
    # (days, initialFrame=nothing)                                             #
    # - run plant model for specified number of days or until plant flowers    #
    #   (as determined by a configured phenology model)                        #
    #                                                                          #
    # helper functions                                                         #
    #                                                                          #
    # run(model, days, initialFrame=nothing)                                   #
    # - wrapper to function method                                             #
    # - see functor method () for more information                             #
    #                                                                          #

    function (m::PlantModel)(days::Integer, 
                             initialFrame::Union{Nothing, Simulation.Frame}=nothing)

        @argcheck days > 1 "# days should be more than 1 (< 2 specified)"


        @info "running model for $(@sprintf("%u", days)) days"

        # initialise history
        # - @ D = 1 | T = 0

        history = Vector{Simulation.Frame}()

        push!(history, (isnothing(initialFrame) ? Simulation.Frame() : initialFrame))

        # run simulation

        flowered = false

        for day in 1:days

            # flowered
            
            if flowered 

                @info "- flowered @ day: $(day - 1) "

                break

            end
            
            # current output & state 
            # - @ D = day | T = timepoint

            hour = 1
            
            current = Simulation.Frame(day, hour)

            @info "- day: $(day) + hour: $(hour) = timepoint: $(timepoint(current)) "

            # clock model
            #
            @debug "— clock "

            clockOutput = Clock.run(m.clock, current, history)

            @debug "—— $(clockOutput) "
            
            # phenology model
            
            @debug "— phenology "

            phenologyOutput = Phenology.run(m.phenology, clockOutput, current, history)

            @debug "—— $(phenologyOutput) (isnothing = $(isnothing(phenologyOutput)))"

            flowered = isnothing(phenologyOutput) ? false : phenologyOutput.flowered

            @debug "—— flowered = $(flowered) "

            # additional models

            @debug "— other models " 

            for feature in m.features

                @debug "—— : $(typeof(feature))"

                Feature.run(feature, clockOutput, phenologyOutput, current, history)
            end

            # update history
            
            push!(history, current)

        end

        @info "model run completed ($(length(history)) frames)."

        # output

        return history

    end
    
    # helper functions

    function run(plant::PlantModel, 
                 days::Integer, 
                 initialFrame::Union{Nothing,Simulation.Frame}=nothing)

        plant(days, initialFrame)

    end

    #                                                                          #
    # exports                                                                  #
    #                                                                          #

    export PlantModel
    
    export run

end # module: PlantModelFramework
