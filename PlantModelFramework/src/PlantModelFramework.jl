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

module Frank

using ..Environment

function debug()

    Environment.debug()

end

function output()

    print("Frank!")

end

end

#
# structs
#

# - 

#
# functions
#

function plantModel()

    print("Plant Model!")

end

#
# exports
#

end # module: PlantModelFramework
