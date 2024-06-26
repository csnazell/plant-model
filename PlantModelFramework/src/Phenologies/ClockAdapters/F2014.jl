#                                                                              #
# PlantModelFramework                                                          #
#                                                                              #
# Phenologies/ClockAdapters/F2014.jl                                           #
#                                                                              #
# Adapters for F2014 clock output.                                             #
#                                                                              #
# Implements adapter behaviour for Phenology.ClockOutputAdapters with          #
# concrete combinations of Phenology.ClockInputs and Clock.ClockOutputs.       #
#                                                                              #

module F2014

    module COP1

    # dependencies ------------------------------------------------------------
    
    # standard library
    # -

    # third-party
    # - 

    # package
    
    import ......Clock
    import ......Clocks.F2014 as F2014
    import ......Phenology
    import ....PIFCOFT

    # implementation ----------------------------------------------------------

    #
    # COP1.DynamicsParameters -> PIFCOFT.ClockInput
    #
    
    # functions

    # - factory
    
    function pifcoftAdapter(parameters::F2014.COP1.DynamicsParameters)

        Phenology.ClockOutputAdapter(parameters)

    end

    # - type-specific adapter implementation 

    function (a::Phenology.ClockOutputAdapter{<: F2014.COP1.DynamicsParameters})(clockOutput::Clock.Output)::PIFCOFT.ClockInput

        Umatrix = vcat(clockOutput.U...)

        # clock model properties

        LUXp  = Umatrix[:,23] 
        NOXp  = Umatrix[:,33] 
        ELF34 = Umatrix[:,21] 
        ELF3p = Umatrix[:,20] 

        # phenology clock inputs

        cP      = Umatrix[:,5] 
        COP1n_n = Umatrix[:,25] 
        EC      = ( (LUXp .+ a.parameters.f6 * NOXp) .* (ELF34 .+ a.parameters.f1 * ELF3p) ) ./ 
                   ( 1.0 .+ a.parameters.f3 * (LUXp + a.parameters.f2 * NOXp) + a.parameters.f4 * (ELF34 + a.parameters.f1 * ELF3p) )
        GIn     = Umatrix[:,31] * 40.9 
        LHY     = ( Umatrix[:,2] + Umatrix[:,4] ) / 1.561   # LHY + CCA1
        PRR5    = Umatrix[:,12] * 0.841                           # nuclear
        PRR7    = Umatrix[:,9] / 2.6754 
        PRR9    = Umatrix[:,7] 
        TOC1    = Umatrix[:,14] * 1.21                            # nuclear
        T       = clockOutput.T

        # clockinput

        PIFCOFT.ClockInput(cP, COP1n_n, EC, GIn, LHY, PRR5, PRR7, PRR9, TOC1, T)

    end

    end #end: module: COP1

end #end: module: F2014
