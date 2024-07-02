#                                                                              #
# PlantModelFramework                                                          #
#                                                                              #
# PlantModelFramework.jl                                                       #
#                                                                              #
# Package root module.                                                         #
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

    # implementation ----------------------------------------------------------

    #
    # PlantModel
    #
    # Root model of plant system
    # 

    # type

    struct PlantModel <: Models.Base

        # fields

        environment::Environment.Model              # model : environment
        clock::Clock.Model                          # model : clock
        phenology::Union{Nothing, Phenology.Model}  # model : phenology
        # FIXME: IMPLEMENT ADDITIONAL MODELS        # models: extensions 

        # constructor

        function PlantModel(environment::Environment.Model, 
                            clock::Clock.Model,
                            phenology::Union{Nothing, Phenology.Model}=nothing
                            # FIXME: IMPLEMENT ADDITIONAL MODELS: VARARGS
                           )

            # construct

            new(environment, clock, phenology)
        end

    end

    # functions

    function (m::PlantModel)(days::Integer, 
                             initialFrame::Union{Nothing, Simulation.Frame}=nothing)

        @argcheck days > 0 "# days should be more than 1 (< 1 specified)"


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
            
            # phenology model
            
            @debug "— phenology "

            phenologyOutput = Phenology.run(m.phenology, clockOutput, current, history)

            flowered = isnothing(phenologyOutput) ? false : phenologyOutput.flowered

            # additional models

            @debug "— other models " 

            # for model in additionalModels
            #   model(day,
            #           timepoint,
            #           clockOutput,
            #           phenologyOutput,
            #           outputCurrent,
            #           outputHistory,
            #           stateCurrent,
            #           stateHistory)
            # end

            # update history
            
            push!(history, current)

        end

        @info "model run completed ($(length(history)) frames)."

        # output
        # FIXME: TURN OUTPUT & STATE HISTORIES INTO DATAFRAMES? OR NICE OUTPUT

        return history

    end
    
    # helper functions

    function run(plant::PlantModel, 
                 days::Integer, 
                 initialFrame::Union{Nothing,Simulation.Frame}=nothing)

        plant(days, initialFrame)

    end

    # exports

    export PlantModel
    
    export run

end # module: PlantModelFramework
