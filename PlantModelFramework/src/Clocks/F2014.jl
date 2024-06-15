#                                                                              #
# PlantModelFramework                                                          #
#                                                                              #
# Clocks/F2014.jl                                                              #
#                                                                              #
# Clock gene models for F2014                                                  #
#                                                                              #
# Model:                                                                       # 
# - Fogelmark K, Troein C (2014)                                               #
#   Rethinking Transcriptional Activation in the Arabidopsis Circadian Clock.  #
#   PLoS Comput Biol 10(7): e1003705. doi:10.1371/journal.pcbi.1003705         #
#                                                                              #

module Clocks

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
    # -

    # implementation ----------------------------------------------------------

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

end

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

    import ..Common: loadParameters

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

        dynamics = Clock.Dynamics(parameters)

    end

    # - type-specific implementation (COP1.DynamicsParameters)
    #   F2014 clock model dynamics with the COP1 only variant for the YHB mutant

    function (d::Clock.Dynamics{<: DynamicsParameters})(
                du,                             # calculated matrix of next values
                u,                              # vector  of values
                envState::Environment.State,    # environment state @ day + hour
                t                               # time 
                )

        # map variables to supplied u vector
        
        (LHYm, LHYp, CCA1m, CCA1p, P, PRR9m, PRR9p, PRR7m, PRR7p, PRR5m, PRR5c, 
         PRR5n, TOC1m, TOC1n, TOC1c, ELF4m, ELF4p, ELF4d, ELF3m, ELF3p, ELF34, 
         LUXm, LUXp, COP1c, COP1n, COP1d, ZTL, ZG, GIm, GIc, GIn, NOXm, NOXp, 
         RVE8m, RVE8p) = u

        # light calculations

        BlueL = light_conditions(envState)
        BlueD = 1.0 - BlueL;

        RedL  = (d.parameters.yhb + L) / (d.parameters.yhb + 1)
        RedD  = 1 - RedL;

        L     = BlueL;
        D     = BlueD;

        # equations

        # - common terms

        LC = (LHYp + d.parameters.f5 * CCA1p)

        LCcommon = (d.parameters.q1 * L * P + d.parameters.n1) / 
                    (1 + (d.parameters.r1 * PRR9p)^2 + (d.parameters.r2 * PRR7p)^2 + 
                            (d.paramters.r3 * PRR5n)^2 + (d.parameters.r4 * TOC1n)^2)

        EC = ((LUXp + d.parameters.f6 * NOXp) * (ELF34 + d.parameters.f1 * ELF3p)) / 
                (1 + d.parameters.f3 * (LUXp + d.paramters.f2 * NOXp) + d.paramters.f4 * 
                    (ELF34 + d.parameters.f1 * ELF3p))

        P5trans = d.parameters.t5 * PRR5c - d.parameters.t6 * PRR5n
        
        Ttrans = d.parameters.t7 * TOC1c - (d.parameters.t8) / (1 + d.parameters.m37 * PRR5n) * TOC1n
        
        E34prod = d.parameters.p25 * ELF3p * ELF4d
        
        E3deg = d.parameters.m30 * COP1d + d.parameters.m29 * COP1n + d.parameters.m9 + d.parameters.m10 * GIn
        
        ZGprod = d.parameters.p12 * ZTL * GIc - (d.parameters.p13 * BlueD + d.parameters.p10 * BlueL) * ZG
        
        ELF3tot = ELF3p + ELF34
        
        Gtrans = d.parameters.p28 * GIc - (d.parameters.p29) / (1 + d.parameters.t9 * ELF3tot) * GIn

        # - differential equations

        # -- LHYm
        du[1] = (LCcommon) / (1 + (d.parameters.r11 * LC)^2) - d.parameters.m1 * LHYm
        
        # -- LHYp
        du[2] = (L + d.parameters.m4 * D) * LHYm - d.parameters.m3 * LHYp
        
        # -- CCA1m
        du[3] = LCcommon - d.parameters.m1 * CCA1m
        
        # -- CCA1p
        du[4] = (L + d.parameters.m4 * D) * CCA1m - d.parameters.m3 * CCA1p
        
        # -- P
        #    Dark accumulator affected by "blue" (non-phy) light
        du[5] = d.parameters.p7 * BlueD * (1 - P) - d.parameters.m11 * P * BlueL 
        
        # -- PRR9m
        du[6] = d.parameters.q3 * P * L - d.parameters.m12 * PRR9m + 
                (1 + d.parameters.a3 * d.parameters.r33 * RVE8p) / 
                    ((1 + d.parameters.r33 * RVE8p) * (1 + (d.parameters.r5 * LC)^2) * 
                     (1 + (d.parameters.r6 * EC)^2) * (1 + (d.parameters.r7 * TOC1n)^2) * 
                     (1 + (d.parameters.r40 * PRR5n)^2))
        
        # -- PRR9p
        du[7] = PRR9m - d.parameters.m13 * PRR9p
        
        # -- PRR7m
        du[8] = 1 / ((1 + (d.parameters.r8 * LC)^2) * (1 + (d.parameters.r9 * EC)^2) * 
                     (1 + (d.parameters.r10 * TOC1n)^2) * (1 + (d.parameters.r40 * PRR5n)^2)) - 
                d.parameters.m14 * PRR7m
        
        # -- PRR7p
        du[9] = PRR7m - (d.parameters.m15 + d.parameters.m23 * D) * PRR7p
        
        # -- PRR5m
        du[10] = (1 + d.parameters.a4 * d.parameters.r34 * RVE8p) / 
                    ((1 + d.parameters.r34 * RVE8p) * (1 + (d.parameters.r12 * LC)^2) * 
                     (1 + (d.parameters.r13 * EC)^2) * (1 + (d.parameters.r14 * TOC1n)^2)) - 
                 d.parameters.m16 * PRR5m
        
        # -- PRR5c
        du[11] = PRR5m - (d.parameters.m17 + d.parameters.m24 * ZTL) * PRR5c - P5trans
        
        # -- PRR5n
        du[12] = P5trans - d.parameters.m42 * PRR5n
        
        # -- TOC1m
        du[13] = (1 + d.parameters.a5 * d.parameters.r35 * RVE8p) / 
                    ((1 + d.parameters.r35 * RVE8p) * (1 + (d.parameters.r15 * LC)^2) * 
                     (1 + (d.parameters.r16 * EC)^2) * (1 + (d.parameters.r17 * TOC1n)^2)) - 
                 d.parameters.m5 * TOC1m
        
        # -- TOC1n
        du[14] = Ttrans - (d.parameters.m43) / (1 + d.parameters.m38 * PRR5n) * TOC1n
        
        # -- TOC1c
        du[15] = TOC1m - (d.parameters.m8 + d.parameters.m6 * ZTL) * TOC1c - Ttrans
        
        # -- ELF4m
        du[16] = (1 + d.parameters.a6 * d.parameters.r36 * RVE8p) / 
                    ((1 + d.parameters.r36 * RVE8p) * (1 + (d.parameters.r18 * EC)^2) * 
                     (1 + (d.parameters.r19 * LC)^2) * (1 + (d.parameters.r20 * TOC1n)^2)) - 
                 d.parameters.m7 * ELF4m
        
        # -- ELF4p
        du[17] = d.parameters.p23 * ELF4m - d.parameters.m35 * ELF4p - ELF4p^2
        
        # -- ELF4d
        du[18] = ELF4p^2 - d.parameters.m36 * ELF4d - E34prod
        
        # -- ELF3m
        du[19] = 1/(1 + (d.parameters.r21 * LC)^2) - d.parameters.m26 * ELF3m
        
        # -- ELF3p
        du[20] = d.parameters.p16 * ELF3m - E34prod - E3deg * ELF3p
        
        # -- ELF34
        du[21] = E34prod - d.parameters.m22 * ELF34 * E3deg
        
        # -- LUXm
        du[22] = (1 + d.parameters.a7 * d.parameters.r37 * RVE8p) / 
                    ((1 + d.parameters.r37 * RVE8p) * (1 + (d.parameters.r22 * EC)^2) * 
                     (1 + (d.parameters.r23 * LC)^2) * (1 + (d.parameters.r24 * TOC1n)^2)) - 
                 d.parameters.m34 * LUXm
        
        # -- LUXp
        du[23] = LUXm - d.parameters.m39 * LUXp
        
        # -- COP1c
        du[24] = d.parameters.n5 - d.parameters.p6 * COP1c - d.parameters.m27 * COP1c * 
                    (1 + d.parameters.p15 * RedL)
        
        # -- COP1n
        du[25] = d.parameters.p6 * COP1c - 
                    (d.parameters.n14 + d.parameters.n6 * RedL * P) * COP1n - 
                        d.parameters.m27 * COP1n * (1 + d.parameters.p15 * RedL)
        
        # -- COP1d
        du[26] = (d.parameters.n14 + d.parameters.n6 * RedL * P) * COP1n - 
                    d.parameters.m31 * (1 + d.parameters.m33 * RedD) * COP1d
        
        # -- ZTL
        du[27] = d.parameters.p14 - ZGprod - d.parameters.m20 * ZTL
        
        # -- ZG
        du[28] = ZGprod - d.parameters.m21 * ZG
        
        # -- GIm
        du[29] = (1 + d.parameters.a8 * d.parameters.r38 * RVE8p) / 
                    ((1 + d.parameters.r38 * RVE8p) * (1 + (d.parameters.r25 * EC)^2) * 
                     (1 + (d.parameters.r26 * LC)^2) * (1 + (d.parameters.r27 * TOC1n)^2)) - 
                 d.parameters.m18 * GIm
        
        # -- GIc
        du[30] = d.parameters.p11 * GIm - ZGprod - Gtrans - d.parameters.m19 * GIc
        
        # -- GIn
        du[31] = Gtrans - d.parameters.m19 * GIn - d.parameters.m25 * ELF3tot * 
                    (1 + d.parameters.m28 * COP1d + d.parameters.m32 * COP1n) * GIn
        
        # -- NOXm
        du[32] = 1 / ((1 + (d.parameters.r28 * LC)^2) * (1 + (d.parameters.r29 * PRR7p)^2)) - 
                    d.parameters.m44 * NOXm
        
        # -- NOXp
        du[33] = NOXm - d.parameters.m45 * NOXp
        
        # -- RVE8m
        du[34] = 1 / (1 + (d.parameters.r30 * PRR9p)^2 + (d.parameters.r31 * PRR7p)^2 + (d.parameters.r32 * PRR5n)^2) - 
                    d.parameters.m46 * RVE8m
        
        # -- RVE8p
        du[35] = RVE8m - d.parameters.m47 * RVE8p
    end

end

end

end
