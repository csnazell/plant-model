#                                                                              #
# PlantModelFramework                                                          #
#                                                                              #
# TestEnvironment.jl                                                           #
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

module TestEnvironment

# dependencies ----------------------------------------------------------------

# standard library

using Test

# third-party
# -

# package

using PlantModelFramework.Environment
       
# tests -----------------------------------------------------------------------

@testset "Tests: Environment" begin

    #
    # State
    #
    
    @testset "State" begin
    
        @testset "accessors" begin
    
            day  = 1
            time = 1
            temp = 22.0
            sr   = 6        # sunrise
            ss   = 18       # sunset
            dd   = 24       # day duration
    
            s = Environment.State(day, time, temp, sr, ss, dd)
    
            @test photoperiod(s) == (ss - sr)
    
            @test sunrise(s) == sr
    
            @test sunset(s) == ss
    
            @test isapprox(temp, temperature(s); atol=1e-6)

            @test dayDuration(s) == dd
    
        end # end: testset: accessors

        @testset "conditions" begin

            # photoperiod = 0
            
            state_pp00 = Environment.State(1,1,22.0,0,0,24)

            @test isapprox(0, light_condition(state_pp00, 0.0), atol=1e-8)
            @test isapprox(0, light_condition(state_pp00, 8.0), atol=1e-8)
            @test isapprox(0, light_condition(state_pp00, 16.0), atol=1e-8)
            @test isapprox(0, light_condition(state_pp00, 24.0), atol=1e-8)

            # photoperiod = 8
            
            state_pp08 = Environment.State(1,1,22.0,0,8,24)

            @test isapprox(0, light_condition(state_pp08, 0.0), atol=1e-8)
            @test isapprox(1, light_condition(state_pp08, 8.0), atol=1e-8)
            @test isapprox(0, light_condition(state_pp08, 16.0), atol=1e-8)
            @test isapprox(0, light_condition(state_pp08, 24.0), atol=1e-8)

            # photoperiod = 16
            
            state_pp16 = Environment.State(1,1,22.0,0,16,24)

            @test isapprox(0, light_condition(state_pp16, 0.0), atol=1e-8)
            @test isapprox(1, light_condition(state_pp16, 8.0), atol=1e-8)
            @test isapprox(1, light_condition(state_pp16, 16.0), atol=1e-8)
            @test isapprox(0, light_condition(state_pp16, 24.0), atol=1e-8)

            # photoperiod = 0
            
            state_pp24 = Environment.State(1,1,22.0,0,24,24)

            @test isapprox(1, light_condition(state_pp24, 0.0), atol=1e-8)
            @test isapprox(1, light_condition(state_pp24, 8.0), atol=1e-8)
            @test isapprox(1, light_condition(state_pp24, 16.0), atol=1e-8)
            @test isapprox(1, light_condition(state_pp24, 24.0), atol=1e-8)

        end # end: testset: conditions
    
    end # end: testset: state

    #
    # ConstantModel
    #

    @testset "ConstantModel" begin

        @testset "construction " begin

            # invalid sunrise & sunset parameters

            temp = 22.0

            @test_throws ArgumentError Environment.ConstantModel(temperature=temp, sunrise=-1, sunset=0)
            @test_throws ArgumentError Environment.ConstantModel(temperature=temp, sunrise=25, sunset=0)
            @test_throws ArgumentError Environment.ConstantModel(temperature=temp, sunrise=0, sunset=-1)
            @test_throws ArgumentError Environment.ConstantModel(temperature=temp, sunrise=0, sunset=25)

            # sunrise & sunset parameter swapping
            
            em0 = Environment.ConstantModel(temperature=temp, sunrise=0, sunset=0)

            @test em0.sunrise == 0
            @test em0.sunset  == 0
            @test isapprox(temp, em0.temperature; atol=1e-6)

            em1 = Environment.ConstantModel(temperature=temp, sunrise=6, sunset=18)

            @test em1.sunrise == 6
            @test em1.sunset  == 18
            @test isapprox(temp, em1.temperature; atol=1e-6)

            em2 = Environment.ConstantModel(temperature=temp, sunrise=18, sunset=6)
            println(em2)

            @test em2.sunrise == 6
            @test em2.sunset  == 18
            @test isapprox(temp, em2.temperature; atol=1e-6)

        end # end: testset: construction

        @testset "state calculation" begin

            temp = 22.0
            sr   = 6
            ss   = 18

            em = Environment.ConstantModel(temperature=temp, sunrise=sr, sunset=ss)

            day  = 1
            time = 1

            s = em(day, time)

            @test photoperiod(s) == (ss - sr)
    
            @test sunrise(s) == sr
    
            @test sunset(s) == ss
    
            @test isapprox(temp, temperature(s); atol=1e-6)
            @test temp == temperature(s)

        end # end: testset: state calculation

    end # end: testset: constantmodel
    
end # end: testset: environment

end # end: TestEnvironment
