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
    # -

    #
    # package
    #

    include("Simulation.jl")
    include("Models.jl")
    include("Environment.jl")
    include("Clock.jl")

    # - simulation
    
    using .Simulation

    export getData, setData

    # - models
    
    using .Models

    # - environment

    using .Environment

    export Environment

    export photoperiod, sunrise, sunset, temperature

    # - clocks
    
    using .Clock

    export Clock

    export run

    # implementation ----------------------------------------------------------

    #
    # PlantModel
    #
    # Root model of plant system
    # 

    # type

    struct PlantModel <: Models.Base

        # fields

        environment::Environment.Model          # model : environment
                                                # model : clock
                                                # model : phenology
                                                # models: extensions 

        # constructor

        function PlantModel(environment::Environment.Model, 
                           )

            # construct

            new(environment)
        end

    end

    # functions

    function (m::PlantModel)(days::UInt32, 
                             outputInitial::Union{Nothing, Simulation.Frame}=nothing, 
                             stateInitial::Union{Nothing, Simulation.Frame}=nothing)

        @info "running model for $(@sprintf("%u", days)) days"

        # initialise history
        # - @ D = 1 | T = 0

        outputHistory = Vector{Simulation.Frame}()

        push!(outputHistory,
              (isnothing(outputInitial) ? Simulation.Frame() : outputInitial))

        stateHistory  = Vector{Simulation.Frame}()

        push!(stateHistory,
              (isnothing(stateInitial) ? Simulation.Frame() : stateInitial))

        # initialise clock model

        # run simulation

        for day in 1:days

            # flowered
            # FIXME: BREAK @ FLOWERED | CUSTOMISABLE?
            
            # current output & state 
            # - @ D = day | T = timepoint

            hour = 1
            
            outputCurrent = Simulation.Frame(day, hour)
            stateCurrent  = Simulation.Frame(day, hour)

            @info "- day: $(day) + hour: $(day) = timepoint: $(timepoint(outputCurrent)) "

            # clock model
            # clockOutput = clockModel(day, timepoint, stateHistory)
            @debug "— clock "
            
            # phenology model
            # phenologyOutput = 
            #   phenologyModel(day, 
            #                   timepoint,
            #                   clockOutput,
            #                   outputCurrent,
            #                   outputHistory,
            #                   stateCurrent,
            #                   stateHistory)
            @debug "— phenology "
                
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
            
            push!(outputHistory, outputCurrent)
            push!(stateHistory, stateCurrent)

        end

        @info "model run completed."

        # output
        # FIXME: TURN OUTPUT & STATE HISTORIES INTO DATAFRAMES

        @debug "output frames: $(length(outputHistory)) "
        @debug "state frames : $(length(stateHistory)) "

    end
    
    # helper functions

    function simulate(plant::PlantModel, days::UInt32)

        plant(days)

    end

    # exports

    export PlantModel
    
    export simulate

end # module: PlantModelFramework
