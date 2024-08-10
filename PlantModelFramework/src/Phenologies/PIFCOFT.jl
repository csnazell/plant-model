#                                                                              #
# PlantModelFramework                                                          #
#                                                                              #
# Phenologies/PIFCOFT.jl                                                       #
#                                                                              #
# Phenology model for PIF_CO_FT model                                          #
#                                                                              #
# Model:                                                                       # 
# - Transcribed from MATLAB Arabidopsis Framework model v2, described in       #
#   Chew et al, 2017 [https://doi.org/10.1101/105437]                          # 
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

module PIFCOFT

    # dependencies ------------------------------------------------------------
    
    # standard library
    # -

    # third-party
    #
    # - Accessors
    # -- struct copying & modification
    # -- (https://github.com/JuliaObjects/Accessors.jl)

    using Accessors

    # - ArgCheck
    # -- argument validation macros
    # -- (https://github.com/jw3126/ArgCheck.jl)

    using ArgCheck
    
    # - CSV.jl
    # -- *SV parsing library
    # -- (https://github.com/JuliaData/CSV.jl)

    using CSV

    # - DataInterpolations.jl
    # -- Interpolation of 1-Dimensional data (part of SciML)
    # -- (https://github.com/SciML/DataInterpolations.jl

    using DataInterpolations

    # package
    
    import ....Simulation
    import ....Models
    import ....Environment
    import ....Clock
    import ....Phenology

    # implementation ----------------------------------------------------------

    #
    # ClockInput
    #

    struct ClockInput
        cP
        COP1n_n
        EC
        GIn
        LHY
        PRR5
        PRR7
        PRR9
        TOC1
        T
    end

    #
    # Parameters
    #

    @kwdef struct DynamicsParameters <: Phenology.DynamicsParameters
        advance::Float64
        n6::Float64
        n7::Float64
        m8::Float64
        m9::Float64
        g7::Float64
        g8::Float64
        g9::Float64
        n8::Float64
        e::Float64
        f::Float64
        n9::Float64
        p12::Float64
        m15::Float64
        p14::Float64
        n11::Float64
        p10::Float64
        m16::Float64
        p11::Float64
        p13::Float64
        m13::Float64
        m14::Float64
        m12::Float64
        n10::Float64
        g10::Float64
        p8::Float64
        p9::Float64
        m10::Float64
        m11::Float64
        n1::Float64
        n2::Float64
        a::Float64
        g1::Float64
        g2::Float64
        b::Float64
        m1::Float64
        q1::Float64
        n3::Float64
        g3::Float64
        c::Float64
        g4::Float64
        m3::Float64
        p4::Float64
        m4::Float64
        p5::Float64
        k1::Float64
        p1::Float64
        p2::Float64
        m2::Float64
        p3::Float64
        Bco::Float64
        n4::Float64
        g5::Float64
        d::Float64
        n5::Float64
        g6::Float64
        m5::Float64
        p6::Float64
        p7::Float64
        m7::Float64
        m6::Float64
        k2::Float64
        n14::Float64
        n15::Float64
        g12::Float64
        g13::Float64
        h::Float64
        m17::Float64
        n12::Float64
        n13::Float64
        g11::Float64
        g14::Float64
        g15::Float64
        g16::Float64
        g17::Float64
        g18::Float64
        g19::Float64
        g20::Float64
        g21::Float64
        n16::Float64
        n17::Float64
        n18::Float64
        n19::Float64
        n20::Float64
        n21::Float64
        m18::Float64
        m19::Float64
        m20::Float64
        n22::Float64
        n23::Float64
        YHB::Float64
    end

    # functions

    function applyTemperatureCorrection(p::DynamicsParameters, temperature::AbstractFloat)

        # guard condition: temperature neither ~= 22.0 or ~= 27.0

        is22 = isapprox(22.0, temperature, atol=1e-8)

        is27 = isapprox(27.0, temperature, atol=1e-8)

        if (!(is22 || is27))
            error("PIFCOFT.DynamicParameters(temperature): temperature must be 22° or 27°")
        end

        # guard condition: temperature ~= 22.0
        
        if is22
            
            return p

        end

        # @ 27°C: 
        # - relieve EC inhibition of PIF4 transcription
            
        updatedP = @set p.g7 = p.g7 * 4.0;

        # FT activation at the higher temperature
            
        f = 3.24;

        updatedP = @set updatedP.n14 = updatedP.n14 * f;
        updatedP = @set updatedP.n15 = updatedP.n15 * f;

        return updatedP

    end
    
    function parameters(genotype::Set{String}=Set{String}())

        # raw parameters loaded from common data set definition &
        # corrected for specified genotype

        fpParameters = normpath(joinpath(@__DIR__), "Data", "PIFCOFT", "Parameters.tsv")

        @info "loading PIFCOFT parameters (set @ $(genotype)) from $(fpParameters)"

        column = 2

        rawParameters = Dict( map(r -> (Symbol(r[1]), Float64( r[column] )), CSV.File(fpParameters, delim="\t")) )

        # overriden parameters
        # - lifted verbatim from MATLAB load_PIF_CO_FT_parameters.m

        # - g2

        rawParameters[:g2] = 
            ("CDF1ox" in genotype) ? 100000.0 : rawParameters[:g2]

        # - g7

        rawParameters[:g7] = 
            ("PIF4ox" in genotype) ? rawParameters[:g7] * 10000.0 : rawParameters[:g7]

        # - g8

        rawParameters[:g8] = 
            ("PIF5ox" in genotype) ? rawParameters[:g8] * 10000.0 : rawParameters[:g8]

        # - m7
        #   no role for cop1 in this pathway

        rawParameters[:m7] = 
            ("cop1" in genotype) ? 0.0 : rawParameters[:m7]

        # - n1

        rawParameters[:n1] = 
            ("cdf1" in genotype) ? 0.0 : rawParameters[:n1]

        rawParameters[:n1] = 
            ("CDF1ox" in genotype) ? 2.0 : rawParameters[:n1]

        # - n2

        rawParameters[:n2] = 
            (("cdf1" in genotype) || ("CDF1ox" in genotype)) ? 0.0 : rawParameters[:n2]

        # - n3

        rawParameters[:n3] = 
            ("fkf1" in genotype) ? 0.0 : rawParameters[:n3]

        # - n4

        rawParameters[:n4] = 
            (("co" in genotype) || ("COox" in genotype)) ? 0.0 : rawParameters[:n4]

        # - n5

        rawParameters[:n5] = 
            any(map(g -> g in genotype, ["co", "COox", "cop1"])) ? 0.0 : rawParameters[:n5]

        # - n6

        rawParameters[:n6] = 
            ("pif4" in genotype) ? 0.0 : rawParameters[:n6]

        rawParameters[:n6] = 
            ("PIF4ox" in genotype) ? rawParameters[:n6] * 2.0 : rawParameters[:n6]
            
        # - n7

        rawParameters[:n7] = 
            ("pif4" in genotype) ? 0.0 : rawParameters[:n7]

        # - n8

        rawParameters[:n8] = 
            ("pif5" in genotype) ? 0.0 : rawParameters[:n8]

        rawParameters[:n8] = 
            ("PIF5ox" in genotype) ? rawParameters[:n8] * 2.0 : rawParameters[:n8]
            
        # - n9

        rawParameters[:n9] = 
            ("pif5" in genotype) ? 0.0 : rawParameters[:n9]

        # - p2
        #   delta1: no CDF1 destabilisation by FKF1

        rawParameters[:p2] = 
            ("delta1" in genotype) ? 0.0 : rawParameters[:p2]

        # - q1

        rawParameters[:q1] = 
            ("fkf1" in genotype) ? 0.0 : rawParameters[:q1]

        # - Bco

        if      ("co" in genotype)
            rawParameters[:Bco] = 0.0
        elseif ("COox" in genotype)
            rawParameters[:Bco] = 2.0
        end

        # - k2
        #   no CO stabilisation by FKF1
        #   make michaelis constant very high to reduce FKF1 effect to negligible level
        
        rawParameters[:k2] = 
            ("delta2" in genotype) ? 100000.0 : rawParameters[:k2]

        # - YHB
        #   constitutively active PhyB, not light-dependent
        #   does not depend on yhb parameter of clock model. Only phyB here, not all red light inputs.

        rawParameters[:YHB] = 
            ("YHB" in genotype) ? 1.0 : rawParameters[:YHB]
        
        # parameters

        DynamicsParameters(; rawParameters...)

    end

    #
    # Dynamics
    #

    # functions

    # - factory for PIF_CO_FT dynamics

    function dynamics(clockAdapter::Phenology.ClockOutputAdapter, parameters::DynamicsParameters)

        dynamics = Phenology.Dynamics(clockAdapter, parameters)

    end

    # - type-specific implementation (PIFCOFT.DynamicsParameters)

    function (d::Phenology.Dynamics{<: DynamicsParameters})(
                du,                             # calculated matrix of next values
                u,                              # vector of values
                parameters::Tuple{Clock.Output, Environment.State},
                                                # parameters for dynamics calculations
                time                            # time 
                )

        (clockOutput, envState) = parameters

        _behaviour(d, du, u, (clockOutput, envState, nothing), time)

    end

    function (d::Phenology.Dynamics{<: DynamicsParameters})(
                du,                             # calculated matrix of next values
                u,                              # vector of values
                parameters::Tuple{Clock.Output, Environment.State, Dict{Any,Any}},    
                                                # parameters for dynamics calculations
                time                            # time 
                )

        _behaviour(d, du, u, parameters, time)

    end

    # internal functions

    function _behaviour(
                d::Phenology.Dynamics{<: DynamicsParameters},
                du,                             # calculated matrix of next values
                u,                              # vector of values
                parameters::Tuple{Clock.Output, Environment.State, Union{Nothing, Dict{Any,Any}}},    
                                                # parameters for dynamics calculations
                time                            # time 
                )

        # parameters

        (clockOutput, envState, traceOrNothing) = parameters

        modelParameters = applyTemperatureCorrection(d.parameters, Environment.temperature(envState))

        clockInput = d.clockAdapter(clockOutput)

        P = d.parameters # phenology model parameters

        # light conditions
        
        L = Environment.light_condition(envState, time)

        # clock inputs

        modTime         = mod(time, Environment.dayDuration(envState))
        modTimeAdvanced = mod((time + modelParameters.advance), Environment.dayDuration(envState))

        cP      = ( LinearInterpolation(clockInput.cP, clockInput.T) )(modTime)

        COP1n_n = ( LinearInterpolation(clockInput.COP1n_n, clockInput.T) )(modTime)

        EC      = ( LinearInterpolation(clockInput.EC, clockInput.T) )(modTime)
        EC_adv  = ( LinearInterpolation(clockInput.EC, clockInput.T) )(modTimeAdvanced)

        GIn     = ( LinearInterpolation(clockInput.GIn, clockInput.T) )(modTime)

        LHY     = ( LinearInterpolation(clockInput.LHY, clockInput.T) )(modTime)

        PRR5    = ( LinearInterpolation(clockInput.PRR5, clockInput.T) )(modTime)
        PRR7    = ( LinearInterpolation(clockInput.PRR7, clockInput.T) )(modTime)
        PRR9    = ( LinearInterpolation(clockInput.PRR9, clockInput.T) )(modTime)

        TOC1    = ( LinearInterpolation(clockInput.TOC1, clockInput.T) )(modTime)

        # map variables to supplied u vector
        
        (PIF4m, PIF5m, PIF, phyB, PR, INT, IAA29m, ATHB2m, CDF1m, FKF1m, FKF1, 
         CDF1, COm, CO, FTm, InducedC1, InducedC2, RepressedC1) = u 

        # PIF Model

        PIFtot = PIF;
        PIFact_1 = PIF ^ 2 / (PIF ^ 2 + (P.g14 * INT) ^ 2)  #IAA29
        PIFact_2 = PIF ^ 2 / (PIF ^ 2 + (P.g15 * INT) ^ 2)  #ATHB2
        PIFact_3 = PIF ^ 2 / (PIF ^ 2 + (P.g16 * INT) ^ 2)  #InducedC1
        PIFact_4 = PIF ^ 2 / (PIF ^ 2 + (P.g17 * INT) ^ 2)  #InducedC2
        PIFact_5 = PIF ^ 2 / (PIF ^ 2 + (P.g18 * INT) ^ 2)  #RepressedC1        

        # - differential equations

        # -- dPIF4mdt
        du[1] = P.n7+P.n6*P.g7^P.e/(P.g7^P.e+EC_adv^P.e)- P.m8*PIF4m

        # -- dPIF5mdt
        du[2] = P.n9+P.n8*P.g8^P.f/(P.g8^P.f+EC_adv^P.f)- P.m9*PIF5m

        # -- dPIFdt
        du[3] = (P.p13*PIF5m+P.p12*PIF4m) - (P.m13 + P.m14*phyB)*PIF

        # -- dphyBdt
        du[4] = P.p8*(L+(P.YHB>0)*(-L+1))*(1-phyB) - P.m10*phyB

        # -- dPRdt
        du[5] = P.p9*L*(1-PR) - P.m11*PR

        # -- dINTdt
        du[6] = P.p10+ P.p11*PR - P.m12*INT

        # -- dIAA29mdt
        du[7] = P.n10+P.n11*PIFact_1^2/(P.g9^2+PIFact_1^2) - P.m15*IAA29m

        # -- dATHB2mdt
        du[8] = P.n12+P.n13*PIFact_2^2/(P.g10^2+PIFact_2^2) - P.m16*ATHB2m

        # CO model
        
        # - differential equations

        # -- dCDF1mdt
        du[9]= (P.n1 + P.n2*(LHY^P.a)/((P.g1^P.a)+(LHY^P.a))) * (P.g2^P.b)/((P.g2^P.b) + (PRR9+PRR7+PRR5+TOC1)^P.b) - P.m1*CDF1m

        # -- dFKF1mdt
        du[10]= P.q1*L*cP + P.n3*((P.g3^P.c)/((P.g3^P.c)+(LHY^P.c)))*(P.g4/(P.g4+EC)) - P.m3*FKF1m

        # -- dFKF1dt
        du[11]= P.p4*FKF1m - P.p5*(P.m4 - L*(GIn /(P.k1 + GIn)))*FKF1

        # -- dCDF1dt
        du[12]= P.p1*CDF1m - P.m2*(P.p2*FKF1*GIn + P.p3*GIn + 1)*CDF1

        # -- dCOmdt
        du[13]= P.Bco + (P.g5^P.d)/((P.g5^P.d) + (CDF1^P.d))*(P.n4 + P.n5*(1-L)*(COP1n_n/(P.g6 + COP1n_n))) - P.m5*COm

        # -- dCOdt
        du[14]= P.p6*COm - P.p7*(P.m6 + P.m7*(1-L)*COP1n_n - L*FKF1/(FKF1 + P.k2))*CO

        # FT model
        
        # - differential equations
        
        # -- dFTmdt
        du[15] = (P.n14 + P.n15*PIFtot/(P.g11 + PIFtot)) * 
                    (P.n16 + P.n17*P.g12/(P.g12 + CDF1)) * (CO^P.h)/((CO^P.h) + (P.g13^P.h)) - 
                        P.m17*FTm

        # Additional PIF targets
        
        # - differential equations
        
        # -- dInducedC1dt 
        du[16] = P.n18 + P.n19*PIFact_3^2/(P.g19^2+PIFact_3^2) - P.m18*InducedC1
        
        # -- dInducedC2dt 
        du[17] = P.n20 + P.n21*PIFact_4^2/(P.g20^2+PIFact_4^2) - P.m19*InducedC2

        # -- dRepressedC1dt 
        du[18] = P.n22 + P.n23*P.g21^2/(P.g21^2+PIFact_5^2) - P.m20*RepressedC1

        # tracing
        
        if (!(isnothing(traceOrNothing)))

            day  = Environment.day(envState)
            pp   = Environment.photoperiod(envState)

            @info "tracing PIFCOFT calculation @ $(day) - $(time)" 

            tracing = [ (pp,day,"1",time,modTime,modTimeAdvanced,du[1],PIF4m,EC_adv,missing,missing,missing,missing),
                        (pp,day,"2",time,modTime,modTimeAdvanced,du[2],PIF5m,EC_adv,missing,missing,missing,missing),
                        (pp,day,"3",time,modTime,modTimeAdvanced,du[3],PIF,PIF5m,PIF4m,phyB,missing,missing),
                        (pp,day,"4",time,modTime,modTimeAdvanced,du[4],phyB,L,PIF,missing,missing,missing),
                        (pp,day,"5",time,modTime,modTimeAdvanced,du[5],PR,L,missing,missing,missing,missing),
                        (pp,day,"6",time,modTime,modTimeAdvanced,du[6],INT,PR,missing,missing,missing,missing),
                        (pp,day,"7",time,modTime,modTimeAdvanced,du[7],IAA29m,PIFact_1,missing,missing,missing,missing),
                        (pp,day,"8",time,modTime,modTimeAdvanced,du[8],ATHB2m,PIFact_2,missing,missing,missing,missing),
                        (pp,day,"9",time,modTime,modTimeAdvanced,du[9],CDF1m,LHY,PRR9,PRR7,PRR5,TOC1),
                        (pp,day,"10",time,modTime,modTimeAdvanced,du[10],FKF1m,L,LHY,EC,missing,missing),
                        (pp,day,"11",time,modTime,modTimeAdvanced,du[11],FKF1,FKF1m,L,GIn,missing,missing),
                        (pp,day,"12",time,modTime,modTimeAdvanced,du[12],CDF1,CDF1m,FKF1,GIn,missing,missing),
                        (pp,day,"13",time,modTime,modTimeAdvanced,du[13],COm,CDF1,L,COP1n_n,missing,missing),
                        (pp,day,"14",time,modTime,modTimeAdvanced,du[14],CO,COm,L,COP1n_n,FKF1,missing),
                        (pp,day,"15",time,modTime,modTimeAdvanced,du[15],FTm,PIFtot,CDF1,CO,missing,missing),
                        (pp,day,"16",time,modTime,modTimeAdvanced,du[16],InducedC1,PIFact_3,missing,missing,missing,missing),
                        (pp,day,"17",time,modTime,modTimeAdvanced,du[17],InducedC2,PIFact_4,missing,missing,missing,missing),
                        (pp,day,"18",time,modTime,modTimeAdvanced,du[18],RepressedC1,PIFact_5,missing,missing,missing,missing) ]

            tracingMx = stack(tracing; dims=1)

            trace = get!(traceOrNothing, "PIFCOFT-Behaviour", [])

            push!(trace, tracingMx)

        end

    end

    #
    # Utilities
    #
    
    function initialState()

        Phenology.State(0.0, ones(1,18));

    end

end #end: module: PIFCOFT
