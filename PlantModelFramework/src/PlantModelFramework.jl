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

include("Environment.jl")
using .Environment

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

#
# exports
#

end # module: PlantModelFramework
