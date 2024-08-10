#                                                                              #
# PlantModelFramework                                                          #
#                                                                              #
# TestSimulation.jl                                                            #
#                                                                              #
# Unit tests for simulation functionality                                      #
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
        @test fDefault.hour == 0
        @test length(fDefault.outputData) == 0

        f = Simulation.Frame(1,0)

        @test f.day == 1
        @test f.hour == 0
        @test length(f.outputData) == 0

    end # end: testset construction

    @testset "output data " begin

        struct TestData <: Simulation.ModelData
            value::Integer
        end

        # empty model data

        f = Simulation.Frame(1,0)

        @test length(f.outputData) == 0

        @test isnothing( getOutput(f, "test") )

        # set data

        td0 = TestData(42)

        setOutput(f, "test", td0)

        @test length(f.outputData) == 1

        fD = getOutput(f, "test")

        @test !(isnothing(fD))
        @test fD === td0

        # replace data
        
        td1 = TestData(1769)

        setOutput(f, "test", td1)

        @test length(f.outputData) == 1

        fD = getOutput(f, "test")

        @test !(isnothing(fD))
        @test fD === td1
        @test fD !== td0

    end #end: testset: output data

    @testset "state data " begin

        struct TestData <: Simulation.ModelData
            value::Integer
        end

        # empty model data

        f = Simulation.Frame(1,0)

        @test length(f.stateData) == 0

        @test isnothing( getState(f, "test") )

        # set data

        td0 = TestData(42)

        setState(f, "test", td0)

        @test length(f.stateData) == 1

        fD = getState(f, "test")

        @test !(isnothing(fD))
        @test fD === td0

        # replace data
        
        td1 = TestData(1769)

        setState(f, "test", td1)

        @test length(f.stateData) == 1

        fD = getState(f, "test")

        @test !(isnothing(fD))
        @test fD === td1
        @test fD !== td0

    end #end: testset: state data
    
    @testset "time" begin

        # default time

        fDefault = Simulation.Frame()

        @test 1 == day(fDefault)
        @test 0 == hour(fDefault)
        @test 0 == timepoint(fDefault)

        # configured time

        dy = 1749
        hr  = 7

        tP   = (dy - 1) * 24 + hr

        f = Simulation.Frame(dy, hr)

        @test dy == day(f)

        @test hr == hour(f)

        @test tP == timepoint(f)

    end

end #end: testset frames

end #end: TestSimulation
