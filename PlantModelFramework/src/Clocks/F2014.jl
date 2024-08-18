#                                                                              #
# PlantModelFramework                                                          #
#                                                                              #
# Clocks/F2014.jl                                                              #
#                                                                              #
# Clock gene models for F2014                                                  #
#                                                                              #
# Models:                                                                      # 
# - Fogelmark K, Troein C (2014)                                               #
#   Rethinking Transcriptional Activation in the Arabidopsis Circadian Clock.  #
#   PLoS Comput Biol 10(7): e1003705. doi:10.1371/journal.pcbi.1003705         #
#                                                                              #
#    Copyright 2024 Christopher Snazell, Dr Rea L Antoniou-Kourounioti  and    #
#                     The University of Glasgow                                #
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

module F2014

module Common

    # dependencies ------------------------------------------------------------
    
    # standard library
    # - 

    # third-party
    # - CSV.jl
    # -- *SV parsing library
    # -- (https://github.com/JuliaData/CSV.jl)

    using CSV
    
    # package
    
    import ....Environment

    # implementation ----------------------------------------------------------

    # TODO: MEMOISE?
    function loadParameters(genotype::Set{String}, set::Integer)

        fpParameters = normpath(joinpath(@__DIR__), "Data", "F2014", "Parameters.tsv")

        @info "loading F2014 parameters (set @ $(set)) from $(fpParameters)"

        column = set + 1

        parameters = Dict( map(r -> (Symbol(r[1]) , Float64( r[column] )), CSV.File(fpParameters, delim="\t")) )

        # non-varying parameters
        
        parameters[:m19] = 0.2
        parameters[:m20] = 1.8
        parameters[:m21] = 0.1
        parameters[:m27] = 0.1
        parameters[:m31] = 0.3
        parameters[:m33] = 13.0
        parameters[:n5]  = 0.23
        parameters[:n6]  = 20.0
        parameters[:n14] = 0.1
        parameters[:p6]  = 0.6
        parameters[:p7]  = 0.3
        parameters[:p10] = 0.2
        parameters[:p12] = 8.0
        parameters[:p13] = 0.7
        parameters[:p14] = 0.3
        parameters[:p15] = 3.0

        # additional parameters
        
        parameters[:n1] = 1.0
        parameters[:yhb] = 0.0

        # mutant variation 

        # - f5

        parameters[:f5] = 
            "cca1" in genotype ? 0.0 : parameters[:f5]

        # - n1

        if "cca1 lhy" in genotype
            parameters[:n1] = 0.0
        elseif "CCA10X" in genotype
            parameters[:n1] = 5.0
        end

        # - p16
        #   no ELF3 protein production. (mRNA is not directly affected)

        parameters[:p16] = 
            "elf3" in genotype ? 0.0 : parameters[:p16]

        # - q1

        if "cca1 lhy" in genotype
            parameters[:q1] = 0.0
        elseif "CCA10X" in genotype
            parameters[:q1] = 0.0
        end

        # - yhb
        
        parameters[:yhb] = 
            "YHB" in genotype ? 3.0 : parameters[:yhb]

        # corrected parameters
        
        parameters

    end

    function F2014Dynamics(
                du,                             # calculated matrix of next values
                u,                              # vector  of values
                L,                              # light parameters
                D,                              # .
                BlueL,                          # .
                BlueD,                          # .
                RedL,                           # .
                RedD,                           # .
                parameters,                     # dynamics (model) parameters
                time,                           # time
                envState,                       # environment state (required for tracing)
                traceOrNothing                  # tracing cache (or nothing)
                )

        # map variables to supplied u vector

        (LHYm, LHYp, CCA1m, CCA1p, P, PRR9m, PRR9p, PRR7m, PRR7p, PRR5m, PRR5c, 
         PRR5n, TOC1m, TOC1n, TOC1c, ELF4m, ELF4p, ELF4d, ELF3m, ELF3p, ELF34, 
         LUXm, LUXp, COP1c, COP1n, COP1d, ZTL, ZG, GIm, GIc, GIn, NOXm, NOXp, 
         RVE8m, RVE8p) = u

        # equations

        # - common terms

        LC = (LHYp + parameters.f5 * CCA1p)

        LCcommon = (parameters.q1 * L * P + parameters.n1) / 
                    (1 + (parameters.r1 * PRR9p)^2 + (parameters.r2 * PRR7p)^2 + 
                            (parameters.r3 * PRR5n)^2 + (parameters.r4 * TOC1n)^2)

        EC = ((LUXp + parameters.f6 * NOXp) * (ELF34 + parameters.f1 * ELF3p)) / 
                (1 + parameters.f3 * (LUXp + parameters.f2 * NOXp) + parameters.f4 * 
                    (ELF34 + parameters.f1 * ELF3p))

        P5trans = parameters.t5 * PRR5c - parameters.t6 * PRR5n
        
        Ttrans = parameters.t7 * TOC1c - (parameters.t8) / (1 + parameters.m37 * PRR5n) * TOC1n
        
        E34prod = parameters.p25 * ELF3p * ELF4d
        
        E3deg = parameters.m30 * COP1d + parameters.m29 * COP1n + parameters.m9 + parameters.m10 * GIn
        
        ZGprod = parameters.p12 * ZTL * GIc - (parameters.p13 * BlueD + parameters.p10 * BlueL) * ZG
        
        ELF3tot = ELF3p + ELF34
        
        Gtrans = parameters.p28 * GIc - (parameters.p29) / (1 + parameters.t9 * ELF3tot) * GIn

        # - differential equations

        # -- LHYm
        du[1] = (LCcommon) / (1 + (parameters.r11 * LC)^2) - parameters.m1 * LHYm
        
        # -- LHYp
        du[2] = (L + parameters.m4 * D) * LHYm - parameters.m3 * LHYp
        
        # -- CCA1m
        du[3] = LCcommon - parameters.m1 * CCA1m
        
        # -- CCA1p
        du[4] = (L + parameters.m4 * D) * CCA1m - parameters.m3 * CCA1p
        
        # -- P
        #    Dark accumulator affected by "blue" (non-phy) light
        du[5] = parameters.p7 * BlueD * (1 - P) - parameters.m11 * P * BlueL 
        
        # -- PRR9m
        du[6] = parameters.q3 * P * L - parameters.m12 * PRR9m + 
                (1 + parameters.a3 * parameters.r33 * RVE8p) / 
                    ((1 + parameters.r33 * RVE8p) * (1 + (parameters.r5 * LC)^2) * 
                     (1 + (parameters.r6 * EC)^2) * (1 + (parameters.r7 * TOC1n)^2) * 
                     (1 + (parameters.r40 * PRR5n)^2))
        
        # -- PRR9p
        du[7] = PRR9m - parameters.m13 * PRR9p
        
        # -- PRR7m
        du[8] = 1 / ((1 + (parameters.r8 * LC)^2) * (1 + (parameters.r9 * EC)^2) * 
                     (1 + (parameters.r10 * TOC1n)^2) * (1 + (parameters.r40 * PRR5n)^2)) - 
                parameters.m14 * PRR7m
        
        # -- PRR7p
        du[9] = PRR7m - (parameters.m15 + parameters.m23 * D) * PRR7p
        
        # -- PRR5m
        du[10] = (1 + parameters.a4 * parameters.r34 * RVE8p) / 
                    ((1 + parameters.r34 * RVE8p) * (1 + (parameters.r12 * LC)^2) * 
                     (1 + (parameters.r13 * EC)^2) * (1 + (parameters.r14 * TOC1n)^2)) - 
                 parameters.m16 * PRR5m
        
        # -- PRR5c
        du[11] = PRR5m - (parameters.m17 + parameters.m24 * ZTL) * PRR5c - P5trans
        
        # -- PRR5n
        du[12] = P5trans - parameters.m42 * PRR5n
        
        # -- TOC1m
        du[13] = (1 + parameters.a5 * parameters.r35 * RVE8p) / 
                    ((1 + parameters.r35 * RVE8p) * (1 + (parameters.r15 * LC)^2) * 
                     (1 + (parameters.r16 * EC)^2) * (1 + (parameters.r17 * TOC1n)^2)) - 
                 parameters.m5 * TOC1m
        
        # -- TOC1n
        du[14] = Ttrans - (parameters.m43) / (1 + parameters.m38 * PRR5n) * TOC1n
        
        # -- TOC1c
        du[15] = TOC1m - (parameters.m8 + parameters.m6 * ZTL) * TOC1c - Ttrans
        
        # -- ELF4m
        du[16] = (1 + parameters.a6 * parameters.r36 * RVE8p) / 
                    ((1 + parameters.r36 * RVE8p) * (1 + (parameters.r18 * EC)^2) * 
                     (1 + (parameters.r19 * LC)^2) * (1 + (parameters.r20 * TOC1n)^2)) - 
                 parameters.m7 * ELF4m
        
        # -- ELF4p
        du[17] = parameters.p23 * ELF4m - parameters.m35 * ELF4p - ELF4p^2
        
        # -- ELF4d
        du[18] = ELF4p^2 - parameters.m36 * ELF4d - E34prod
        
        # -- ELF3m
        du[19] = 1/(1 + (parameters.r21 * LC)^2) - parameters.m26 * ELF3m
        
        # -- ELF3p
        du[20] = parameters.p16 * ELF3m - E34prod - E3deg * ELF3p
        
        # -- ELF34
        du[21] = E34prod - parameters.m22 * ELF34 * E3deg
        
        # -- LUXm
        du[22] = (1 + parameters.a7 * parameters.r37 * RVE8p) / 
                    ((1 + parameters.r37 * RVE8p) * (1 + (parameters.r22 * EC)^2) * 
                     (1 + (parameters.r23 * LC)^2) * (1 + (parameters.r24 * TOC1n)^2)) - 
                 parameters.m34 * LUXm
        
        # -- LUXp
        du[23] = LUXm - parameters.m39 * LUXp
        
        # -- COP1c
        du[24] = parameters.n5 - parameters.p6 * COP1c - parameters.m27 * COP1c * 
                    (1 + parameters.p15 * RedL)
        
        # -- COP1n
        du[25] = parameters.p6 * COP1c - 
                    (parameters.n14 + parameters.n6 * RedL * P) * COP1n - 
                        parameters.m27 * COP1n * (1 + parameters.p15 * RedL)
        
        # -- COP1d
        du[26] = (parameters.n14 + parameters.n6 * RedL * P) * COP1n - 
                    parameters.m31 * (1 + parameters.m33 * RedD) * COP1d
        
        # -- ZTL
        du[27] = parameters.p14 - ZGprod - parameters.m20 * ZTL
        
        # -- ZG
        du[28] = ZGprod - parameters.m21 * ZG
        
        # -- GIm
        du[29] = (1 + parameters.a8 * parameters.r38 * RVE8p) / 
                    ((1 + parameters.r38 * RVE8p) * (1 + (parameters.r25 * EC)^2) * 
                     (1 + (parameters.r26 * LC)^2) * (1 + (parameters.r27 * TOC1n)^2)) - 
                 parameters.m18 * GIm
        
        # -- GIc
        du[30] = parameters.p11 * GIm - ZGprod - Gtrans - parameters.m19 * GIc
        
        # -- GIn
        du[31] = Gtrans - parameters.m19 * GIn - parameters.m25 * ELF3tot * 
                    (1 + parameters.m28 * COP1d + parameters.m32 * COP1n) * GIn
        
        # -- NOXm
        du[32] = 1 / ((1 + (parameters.r28 * LC)^2) * (1 + (parameters.r29 * PRR7p)^2)) - 
                    parameters.m44 * NOXm
        
        # -- NOXp
        du[33] = NOXm - parameters.m45 * NOXp
        
        # -- RVE8m
        du[34] = 1 / (1 + (parameters.r30 * PRR9p)^2 + (parameters.r31 * PRR7p)^2 + (parameters.r32 * PRR5n)^2) - 
                    parameters.m46 * RVE8m
        
        # -- RVE8p
        du[35] = RVE8m - parameters.m47 * RVE8p

        # tracing
        
        if (!(isnothing(traceOrNothing)))

            day  = Environment.day(envState)
            pp   = Environment.photoperiod(envState)

            @info "tracing F2014 COP1 calculation @ $(day) - $(time)" 

            # trace clock dynamics
            
            tracing = [ ("1",pp,day,time,du[1],LHYm,LC,parameters.r11,parameters.m1,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing),
                        ("2",pp,day,time,du[2],LHYp,L,D,LHYm,parameters.m4,parameters.m3,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing),
                        ("3",pp,day,time,du[3],CCA1m,LCcommon,parameters.m1,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing),
                        ("4",pp,day,time,du[4],CCA1p,L,D,CCA1m,parameters.m4,parameters.m3,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing),
                        ("5",pp,day,time,du[5],P,BlueD,BlueL,parameters.p7,parameters.m11,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing),
                        ("6",pp,day,time,du[6],PRR9m,P,L,RVE8p,LC,EC,TOC1n,PRR5n,parameters.q3,parameters.m12,parameters.a3,parameters.r33,parameters.r5,parameters.r6,parameters.r7,parameters.r40),
                        ("7",pp,day,time,du[7],PRR9p,PRR9m,parameters.m13,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing),
                        ("8",pp,day,time,du[8],PRR7m,LC,EC,TOC1n,PRR5n,parameters.r8,parameters.r9,parameters.r10,parameters.r40,parameters.m14,missing,missing,missing,missing,missing,missing),
                        ("9",pp,day,time,du[9],PRR7p,PRR7m,D,parameters.m15,parameters.m23,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing),
                        ("10",pp,day,time,du[10],PRR5m,RVE8p,LC,EC,TOC1n,parameters.a4,parameters.r34,parameters.r12,parameters.r13,parameters.r14,parameters.m16,missing,missing,missing,missing,missing),
                        ("11",pp,day,time,du[11],PRR5c,PRR5m,ZTL,P5trans,parameters.m17,parameters.m24,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing),
                        ("12",pp,day,time,du[12],PRR5n,P5trans,parameters.m42,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing),
                        ("13",pp,day,time,du[13],TOC1m,RVE8p,LC,EC,TOC1n,parameters.a5,parameters.r35,parameters.r15,parameters.r16,parameters.r17,parameters.m5,missing,missing,missing,missing,missing),
                        ("14",pp,day,time,du[14],TOC1n,Ttrans,PRR5n,parameters.m43,parameters.m38,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing),
                        ("15",pp,day,time,du[15],TOC1c,TOC1m,ZTL,Ttrans,parameters.m8,parameters.m6,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing),
                        ("16",pp,day,time,du[16],ELF4m,RVE8p,EC,LC,TOC1n,parameters.a6,parameters.r36,parameters.r18,parameters.r19,parameters.r20,parameters.m7,missing,missing,missing,missing,missing),
                        ("17",pp,day,time,du[17],ELF4p,ELF4m,parameters.p23,parameters.m35,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing),
                        ("18",pp,day,time,du[18],ELF4d,ELF4p,E34prod,parameters.m36,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing),
                        ("19",pp,day,time,du[19],ELF3m,LC,parameters.r21,parameters.m26,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing),
                        ("20",pp,day,time,du[20],ELF3p,ELF3m,E34prod,E3deg,parameters.p16,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing),
                        ("21",pp,day,time,du[21],ELF34,E34prod,E3deg,parameters.m22,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing),
                        ("22",pp,day,time,du[22],LUXm,RVE8p,EC,LC,TOC1n,parameters.a7,parameters.r37,parameters.r22,parameters.r23,parameters.r24,parameters.m34,missing,missing,missing,missing,missing),
                        ("23",pp,day,time,du[23],LUXp,LUXm,parameters.m39,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing),
                        ("24",pp,day,time,du[24],COP1c,RedL,parameters.n5,parameters.p6,parameters.m27,parameters.p15,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing),
                        ("25",pp,day,time,du[25],COP1n,COP1c,RedL,P,parameters.p6,parameters.n14,parameters.n6,parameters.m27,parameters.p15,missing,missing,missing,missing,missing,missing,missing),
                        ("26",pp,day,time,du[26],COP1d,RedL,P,COP1n,RedD,parameters.n14,parameters.n6,parameters.m31,parameters.m33,missing,missing,missing,missing,missing,missing,missing),
                        ("27",pp,day,time,du[27],ZTL,ZGprod,parameters.p14,parameters.m20,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing),
                        ("28",pp,day,time,du[28],ZG,ZGprod,parameters.m21,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing),
                        ("29",pp,day,time,du[29],GIm,RVE8p,EC,LC,TOC1n,parameters.a8,parameters.r38,parameters.r25,parameters.r26,parameters.r27,parameters.m18,missing,missing,missing,missing,missing),
                        ("30",pp,day,time,du[30],GIc,GIm,ZGprod,Gtrans,parameters.p11,parameters.m19,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing),
                        ("31",pp,day,time,du[31],GIn,Gtrans,ELF3tot,COP1d,COP1n,parameters.m19,parameters.m25,parameters.m28,parameters.m32,missing,missing,missing,missing,missing,missing,missing),
                        ("32",pp,day,time,du[32],NOXm,LC,PRR7p,parameters.r28,parameters.r29,parameters.m44,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing),
                        ("33",pp,day,time,du[33],NOXp,NOXm,parameters.m45,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing),
                        ("34",pp,day,time,du[34],RVE8m,PRR9p,PRR7p,PRR5n,parameters.r30,parameters.r31,parameters.r32,parameters.m46,missing,missing,missing,missing,missing,missing,missing,missing),
                        ("35",pp,day,time,du[35],RVE8p,RVE8m,parameters.m47,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing,missing) ]

            # cache tracing

            tracingMx = stack(tracing; dims=1)

            trace = get!(traceOrNothing, "F2014-Dynamics", [])

            push!(trace, tracingMx)

        end
    end

end # end: module: common

module COP1

    # dependencies ------------------------------------------------------------
    
    # standard library
    # -

    # third-party
    #
    # - ArgCheck
    # -- argument validation macros
    # -- (https://github.com/jw3126/ArgCheck.jl)

    using ArgCheck

    # package
    
    import ....Simulation
    import ....Models
    import ....Environment
    import ....Clock

    # local

    import ..Common: loadParameters, F2014Dynamics

    # implementation ----------------------------------------------------------

    #
    # Initial state
    #

    function initialState()

        Clock.State( ones(1,35) .* 0.1 )

    end

    #
    # Parameters
    #

    @kwdef struct DynamicsParameters <: Clock.DynamicsParameters
        a3::Float64
        a4::Float64
        a5::Float64
        a6::Float64
        a7::Float64
        a8::Float64
        r1::Float64
        r2::Float64
        r3::Float64
        r4::Float64
        r5::Float64
        r6::Float64
        r7::Float64
        r8::Float64
        r9::Float64
        r10::Float64
        r11::Float64
        r12::Float64
        r13::Float64
        r14::Float64
        r15::Float64
        r16::Float64
        r17::Float64
        r18::Float64
        r19::Float64
        r20::Float64
        r21::Float64
        r22::Float64
        r23::Float64
        r24::Float64
        r25::Float64
        r26::Float64
        r27::Float64
        r28::Float64
        r29::Float64
        r30::Float64
        r31::Float64
        r32::Float64
        r33::Float64
        r34::Float64
        r35::Float64
        r36::Float64
        r37::Float64
        r38::Float64
        r40::Float64
        r41::Float64
        f1::Float64
        f2::Float64
        f3::Float64
        f4::Float64
        f5::Float64
        f6::Float64
        t5::Float64
        t6::Float64
        t7::Float64
        t8::Float64
        t9::Float64
        m1::Float64
        m3::Float64
        m4::Float64
        m5::Float64
        m6::Float64
        m7::Float64
        m8::Float64
        m9::Float64
        m10::Float64
        m11::Float64
        m12::Float64
        m13::Float64
        m14::Float64
        m15::Float64
        m16::Float64
        m17::Float64
        m18::Float64
        m19::Float64
        m20::Float64
        m21::Float64
        m22::Float64
        m23::Float64
        m24::Float64
        m25::Float64
        m26::Float64
        m27::Float64
        m28::Float64
        m29::Float64
        m30::Float64
        m31::Float64
        m32::Float64
        m33::Float64
        m34::Float64
        m35::Float64
        m36::Float64
        m37::Float64
        m38::Float64
        m39::Float64
        m42::Float64
        m43::Float64
        m44::Float64
        m45::Float64
        m46::Float64
        m47::Float64
        n1::Float64
        n5::Float64
        n6::Float64
        n14::Float64
        p6::Float64
        p7::Float64
        p10::Float64
        p11::Float64
        p12::Float64
        p13::Float64
        p14::Float64
        p15::Float64
        p16::Float64
        p23::Float64
        p25::Float64
        p28::Float64
        p29::Float64
        q1::Float64
        q3::Float64
        yhb::Float64
    end

    # functions
    
    function parameters(genotype::Set{String}=Set{String}(), set::Integer=1)

        # raw parameters loaded from common data set definition &
        # corrected for specified genotype

        rawParameters = loadParameters(genotype, set)

        # parameters

        DynamicsParameters(; rawParameters...)

    end

    #
    # Dynamics
    #

    # functions

    # - factory for COP1 dynamics

    function dynamics(parameters::DynamicsParameters)

        @info "creating Clock model for F2014 | Cop1 model"

        dynamics = Clock.Dynamics(parameters)

    end

    # - type-specific implementation (COP1.DynamicsParameters)
    #   F2014 clock model dynamics with the COP1 only variant for the YHB mutant

    function (d::Clock.Dynamics{<: DynamicsParameters})(
                du,                             # calculated matrix of next values
                u,                              # vector  of values
                envState::Environment.State,    # environment state @ day + hour
                time                            # time 
                )

        # light calculations

        BlueL = Environment.light_condition(envState, time)
        BlueD = 1.0 - BlueL;

        RedL  = (d.parameters.yhb + BlueL) / (d.parameters.yhb + 1)
        RedD  = 1 - RedL;

        L     = BlueL;
        D     = BlueD;

        # equations

        F2014Dynamics(du, u, L, D, BlueL, BlueD, RedL, RedD, d.parameters, time, envState, nothing)

    end

    function (d::Clock.Dynamics{<: DynamicsParameters})(
                du,                             # calculated matrix of next values
                u,                              # vector  of values
                parameters::Tuple{Environment.State, Dict{Any,Any}},    
                                                # (environment state @ day + hour, tracing dict)
                time                            # time 
                )

        # parameters
        
        (envState, trace) = parameters

        # light calculations

        BlueL = Environment.light_condition(envState, time)
        BlueD = 1.0 - BlueL;

        RedL  = (d.parameters.yhb + BlueL) / (d.parameters.yhb + 1)
        RedD  = 1 - RedL;

        L     = BlueL;
        D     = BlueD;

        # equations

        F2014Dynamics(du, u, L, D, BlueL, BlueD, RedL, RedD, d.parameters, time, envState, trace)

    end

end # end: module: COP1

module Red

    # dependencies ------------------------------------------------------------
    
    # standard library
    # -

    # third-party
    #
    # - ArgCheck
    # -- argument validation macros
    # -- (https://github.com/jw3126/ArgCheck.jl)

    using ArgCheck

    # package
    
    import ....Simulation
    import ....Models
    import ....Environment
    import ....Clock

    # local

    import ..Common: loadParameters, F2014Dynamics

    # implementation ----------------------------------------------------------

    #
    # Initial state
    #

    function initialState()

        Clock.State( ones(1,35) .* 0.1 )

    end

    #
    # Parameters
    #
    @kwdef struct DynamicsParameters <: Clock.DynamicsParameters
        a3::Float64
        a4::Float64
        a5::Float64
        a6::Float64
        a7::Float64
        a8::Float64
        r1::Float64
        r2::Float64
        r3::Float64
        r4::Float64
        r5::Float64
        r6::Float64
        r7::Float64
        r8::Float64
        r9::Float64
        r10::Float64
        r11::Float64
        r12::Float64
        r13::Float64
        r14::Float64
        r15::Float64
        r16::Float64
        r17::Float64
        r18::Float64
        r19::Float64
        r20::Float64
        r21::Float64
        r22::Float64
        r23::Float64
        r24::Float64
        r25::Float64
        r26::Float64
        r27::Float64
        r28::Float64
        r29::Float64
        r30::Float64
        r31::Float64
        r32::Float64
        r33::Float64
        r34::Float64
        r35::Float64
        r36::Float64
        r37::Float64
        r38::Float64
        r40::Float64
        r41::Float64
        f1::Float64
        f2::Float64
        f3::Float64
        f4::Float64
        f5::Float64
        f6::Float64
        t5::Float64
        t6::Float64
        t7::Float64
        t8::Float64
        t9::Float64
        m1::Float64
        m3::Float64
        m4::Float64
        m5::Float64
        m6::Float64
        m7::Float64
        m8::Float64
        m9::Float64
        m10::Float64
        m11::Float64
        m12::Float64
        m13::Float64
        m14::Float64
        m15::Float64
        m16::Float64
        m17::Float64
        m18::Float64
        m19::Float64
        m20::Float64
        m21::Float64
        m22::Float64
        m23::Float64
        m24::Float64
        m25::Float64
        m26::Float64
        m27::Float64
        m28::Float64
        m29::Float64
        m30::Float64
        m31::Float64
        m32::Float64
        m33::Float64
        m34::Float64
        m35::Float64
        m36::Float64
        m37::Float64
        m38::Float64
        m39::Float64
        m42::Float64
        m43::Float64
        m44::Float64
        m45::Float64
        m46::Float64
        m47::Float64
        n1::Float64
        n5::Float64
        n6::Float64
        n14::Float64
        p6::Float64
        p7::Float64
        p10::Float64
        p11::Float64
        p12::Float64
        p13::Float64
        p14::Float64
        p15::Float64
        p16::Float64
        p23::Float64
        p25::Float64
        p28::Float64
        p29::Float64
        q1::Float64
        q3::Float64
        yhb::Float64
    end

    # functions
    
    function parameters(genotype::Set{String}=Set{String}(), set::Integer=1)

        # raw parameters loaded from common data set definition &
        # corrected for specified genotype

        rawParameters = loadParameters(genotype, set)

        # parameters

        DynamicsParameters(; rawParameters...)

    end

    #
    # Dynamics
    #

    # functions

    # - factory for Red dynamics

    function dynamics(parameters::DynamicsParameters)

        @info "creating Clock model for F2014 | Red model"

        dynamics = Clock.Dynamics(parameters)

    end

    # - type-specific implementation (Red.DynamicsParameters)
    #   F2014 clock model dynamics with the global variant for the YHB mutant

    function (d::Clock.Dynamics{<: DynamicsParameters})(
                du,                             # calculated matrix of next values
                u,                              # vector  of values
                envState::Environment.State,    # environment state @ day + hour
                time                            # time 
                )

        # light calculations

        BlueL = Environment.light_condition(envState, time)
        BlueD = 1.0 - BlueL;

        RedL  = (d.parameters.yhb + BlueL) / (d.parameters.yhb + 1)
        RedD  = 1 - RedL;

        L     = RedL;
        D     = RedD;

        # equations

        F2014Dynamics(du, u, L, D, BlueL, BlueD, RedL, RedD, d.parameters, time, envState, nothing)

    end

    function (d::Clock.Dynamics{<: DynamicsParameters})(
                du,                             # calculated matrix of next values
                u,                              # vector  of values
                parameters::Tuple{Environment.State, Dict{Any,Any}},    
                                                # (environment state @ day + hour, tracing dict)
                time                            # time 
                )

        # light calculations

        BlueL = Environment.light_condition(envState, time)
        BlueD = 1.0 - BlueL;

        RedL  = (d.parameters.yhb + BlueL) / (d.parameters.yhb + 1)
        RedD  = 1 - RedL;

        L     = RedL;
        D     = RedD;

        # equations

        F2014Dynamics(du, u, L, D, BlueL, BlueD, RedL, RedD, d.parameters, time, envState, trace)

    end

end #end: module: Red

end # end: module: F2014
