#                                                                              #
# PlantModelFramework                                                          #
#                                                                              #
# Phenologies.jl                                                               #
#                                                                              #
# Root module for Phenologies namespace within package.                        #
#                                                                              #

module Phenologies

    # sub-module: PIFCOFT

    include("PIFCOFT.jl")

    import .PIFCOFT

    export PIFCOFT

    # sub-namespace: ClockAdapters

    module ClockAdapters

        # sub-namespace: F2014

        include("ClockAdapters/F2014.jl")

        import .F2014

        export F2014

    end

end
