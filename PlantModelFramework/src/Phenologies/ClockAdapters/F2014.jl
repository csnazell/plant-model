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

module Common

    # dependencies ------------------------------------------------------------
    
    # standard library
    # -

    # third-party
    # - 

    # package
    
    import ....PIFCOFT

    # local
    # -

    # implementation ----------------------------------------------------------

    function createClockInput(T, U, parameters)
        
        # clock model properties

        LUXp  = U[:,23] 
        NOXp  = U[:,33] 
        ELF34 = U[:,21] 
        ELF3p = U[:,20] 

        # phenology clock inputs

        cP      = U[:,5] 
        COP1n_n = U[:,25] 
        EC      = ( (LUXp .+ parameters.f6 * NOXp) .* (ELF34 .+ parameters.f1 * ELF3p) ) ./ 
                   ( 1.0 .+ parameters.f3 * (LUXp + parameters.f2 * NOXp) + parameters.f4 * (ELF34 + parameters.f1 * ELF3p) )
        GIn     = U[:,31] * 40.9 
        LHY     = ( U[:,2] + U[:,4] ) / 1.561   # LHY + CCA1
        PRR5    = U[:,12] * 0.841               # nuclear
        PRR7    = U[:,9] / 2.6754 
        PRR9    = U[:,7] 
        TOC1    = U[:,14] * 1.21                # nuclear

        # clockinput

        PIFCOFT.ClockInput(cP, COP1n_n, EC, GIn, LHY, PRR5, PRR7, PRR9, TOC1, T)

    end

end # end: module: Common

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

    # local

    import ..Common: createClockInput

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

        return createClockInput(clockOutput.T, vcat(clockOutput.U...), a.parameters)

    end

end #end: module: COP1

module Red

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

    # local

    import ..Common: createClockInput

    # implementation ----------------------------------------------------------

    #
    # Red.DynamicsParameters -> PIFCOFT.ClockInput
    #
    
    # functions

    # - factory
    
    function pifcoftAdapter(parameters::F2014.Red.DynamicsParameters)

        Phenology.ClockOutputAdapter(parameters)

    end

    # - type-specific adapter implementation 

    function (a::Phenology.ClockOutputAdapter{<: F2014.Red.DynamicsParameters})(clockOutput::Clock.Output)::PIFCOFT.ClockInput

        return createClockInput(clockOutput.T, vcat(clockOutput.U...), a.parameters)

    end

end #end: module: Red

end #end: module: F2014
