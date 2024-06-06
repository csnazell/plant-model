#                                                                              #
# PlantModelFramework                                                          #
#                                                                              #
# PlantModelFramework.jl                                                       #
#                                                                              #
# Package root module.                                                         #
#                                                                              #
                                                                              
module PlantModelFramework

    #
    # dependencies
    #

    # environment

    include("Environment.jl")
    using .Environment


    export photoperiod, sunrise, sunset, temperature

    #
    # structs
    #

    # - 

    #
    # functions
    #

    function plantModel(environment::Environment.Model)

        println("Plant Model!")
        println("- environment = $(environment)")

    end

end # module: PlantModelFramework
