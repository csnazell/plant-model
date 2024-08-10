#                                                                              #
# PlantModelFramework                                                          #
#                                                                              #
# Clocks / TestF2014.jl                                                        #
#                                                                              #
# Unit tests for F2014 clock gene model.                                       #
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

module TestF2014

# dependencies ----------------------------------------------------------------

# standard library

using Test

# third-party
# -

# package

import PlantModelFramework.Simulation

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
