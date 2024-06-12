#                                                                              #
# PlantModelFramework                                                          #
#                                                                              #
# TestSimulation.jl                                                            #
#                                                                              #
# Unit tests for simulation functionality                                      #
#                                                                              #

module TestSimulation

# dependencies ----------------------------------------------------------------

# standard library

using Test

# third-party
# -

# package

using PlantModelFramework.Simulation
       
# tests -----------------------------------------------------------------------

#
# Frame
#

@testset "Tests: Frame" begin

    @testset "construction " begin

        @test_throws ArgumentError Simulation.Frame(-1,0)
        @test_throws ArgumentError Simulation.Frame(0,0)
        @test_throws ArgumentError Simulation.Frame(1,-1)
        @test_throws ArgumentError Simulation.Frame(1,25)

        fDefault = Simulation.Frame()

        @test fDefault.day == 1
        @test fDefault.timepoint == 0
        @test length(fDefault.modelData) == 0

        f = Simulation.Frame(1,0)

        @test f.day == 1
        @test f.timepoint == 0
        @test length(f.modelData) == 0

    end # end: testset construction

    @testset "model data " begin

        struct TestData <: Simulation.ModelData
            value::Integer
        end

        # empty model data

        f = Simulation.Frame(1,0)

        @test length(f.modelData) == 0

        @test isnothing( getData(f, "test") )

        # set data

        td0 = TestData(42)

        setData(f, "test", td0)

        @test length(f.modelData) == 1

        fD = getData(f, "test")

        @test !(isnothing(fD))
        @test fD === td0

        # replace data
        
        td1 = TestData(1769)

        setData(f, "test", td1)

        @test length(f.modelData) == 1

        fD = getData(f, "test")

        @test !(isnothing(fD))
        @test fD === td1
        @test fD !== td0

    end #end: testset model data
    
end #end: testset frames

end
