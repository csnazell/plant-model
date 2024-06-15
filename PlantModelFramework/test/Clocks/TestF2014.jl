#                                                                              #
# PlantModelFramework                                                          #
#                                                                              #
# Clocks / TestF2014.jl                                                        #
#                                                                              #
# Unit tests for F2014 clock gene model.                                       #
#                                                                              #

module TestF2014

# dependencies ----------------------------------------------------------------

# standard library

using Test

# third-party
# -

# package

import PlantModelFramework.Simulation
#import PlantModelFramework.Models
#import PlantModelFramework.Environment
#import PlantModelFramework.Clock

using PlantModelFramework.Clocks.F2014
       
# tests -----------------------------------------------------------------------

@testset "Clocks / F2014" begin

    @testset "COP1" begin

        @testset "initialisation" begin
    
            expectedU0 = ones(1,35) .* 0.1
    
            @test isapprox(expectedU0, (F2014.COP1.initialState()).U, atol=1e-8)
    
            # DEBUG
            # println(" param > $(F2014.COP1.parameters()) ")
            # DEBUG
            # FIXME: IMPLEMENT PARAMETER LOADING TESTS

        end # end: testset: initialisation

    end # end: testset: COP1

end # end: testset: clocks / f2014

end
