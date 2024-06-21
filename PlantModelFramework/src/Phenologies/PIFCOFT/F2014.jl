#                                                                              #
# PlantModelFramework                                                          #
#                                                                              #
# Phenologies/PIFCOFT/F2014.jl                                                 #
#                                                                              #
# Adapters for F2014 clock output. Adapts clock output into form compatible    #
# with PIF_CO_FT phenology model.                                              #
#                                                                              #

module Phenologies

module PIFCOFT

module ClockAdapters

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
    import .....PIFCOFT

    # implementation ----------------------------------------------------------

    #
    # ClockInput
    #
    
    # functions

    # - factory for COP1 dynamics

    function adapter(parameters::F2014.COP1.DynamicsParameters)

        adapter = Phenology.ClockOutputAdapter(parameters)

    end

    # - type-specific adapter implementation (COP1.DynamicsParameters)

    function (a::Phenology.ClockOutputAdapter{<: F2014.COP1.DynamicsParameters})(clockOutput::Clock.Output)::PIFCOFT.ClockInput

        # clock model properties

        LUXp  = clockOutput.U[:,23] 
        NOXp  = clockOutput.U[:,33] 
        ELF34 = clockOutput.U[:,21] 
        ELF3p = clockOutput.U[:,20] 

        # phenology clock inputs

        cP      = clockOutput.U[:,5] 
        COP1n_n = clockOutput.U[:,25] 
        EC      = ( (LUXp + a.parameters.f6 * NOXp) .* (ELF34 + a.parameters.f1 * ELF3p) ) ./ 
                    ( 1 + a.parameters.f3 * (LUXp + a.parameters.f2 * NOXp) + a.parameters.f4 * (ELF34 + a.parameters.f1 * ELF3p) )
        GIn     = clockOutput.U[:,31] * 40.9 
        LHY     = ( clockOutput.U[:,2] + clockOutput.U[:,4] ) / 1.561   # LHY + CCA1
        PRR5    = clockOutput.U[:,12] * 0.841                           # nuclear
        PRR7    = clockOutput.U[:,9] / 2.6754 
        PRR9    = Y[:,7] 
        TOC1    = clockOutput.U[:,14] * 1.21                            # nuclear
        T       = clockOutput.T

        # clockinput

        Phenology.ClockInput(cp, COP1n_n, EC, GIn, LHY, PRR5, PRR7, PRR9, TOC1, T)

    end

end #end: module: COP1

end #end: module: F2014

end #end: module: ClockAdapters

end #end: module: PIFCOFT

end #end: module: Phenologies

