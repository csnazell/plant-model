#                                                                              #
# PlantModelFramework                                                          #
#                                                                              #
# PlantModelFramework.jl                                                       #
#                                                                              #
# Package root module.                                                         #
#                                                                              #
                                                                              
module PlantModelFramework

    #
    # dependencies: Standard Library
    #
    
    using Printf

    #
    # dependencies: PlantModelFramework
    #

    include("Models.jl")
    include("Environment.jl")

    # - models
    
    using .Models

    # - environment

    using .Environment

    export photoperiod, sunrise, sunset, temperature

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

    function (m::PlantModel)(days::UInt32)

        @info "running model for $(@sprintf("%u", days)) days"

        for day in 1:days

            @info "- day: $(day) "

        end

        @info "model run completed."

    end

    function simulate(plant::PlantModel, days::UInt32)
        plant(days)
    end

    # exports
    
    export PlantModel

    export simulate

end # module: PlantModelFramework
