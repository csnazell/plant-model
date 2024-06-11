#                                                                              #
# PlantModelFramework                                                          #
#                                                                              #
# TestEnvironment.jl                                                           #
#                                                                              #
# Unit tests for simulation functionality                                      #
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
            sr   = 6
            ss   = 18
    
            s = Environment.State(day, time, temp, sr, ss)
    
            @test photoperiod(s) == (ss - sr)
    
            @test sunrise(s) == sr
    
            @test sunset(s) == ss
    
            @test isapprox(temp, temperature(s); atol=1e-6)
    
        end # end: testset: accessors
    
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
