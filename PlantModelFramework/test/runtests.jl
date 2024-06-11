#                                                                              #
# PlantModelFramework                                                          #
#                                                                              #
# runtests.jl                                                                  #
#                                                                              #
# Unit testing root.                                                           #
#                                                                              #
# Individual model's unit tests are broken into Test<ModuleName>.jl            #
# paralleling package source code structure.                                   #
#                                                                              #
       
# dependencies ----------------------------------------------------------------

# standard library

using Test

# third-party
# - 

# package

using PlantModelFramework

# test ------------------------------------------------------------------------

@testset "Tests: PlantModelFramework" begin

    include("TestEnvironment.jl")
    include("TestSimulation.jl")

end

