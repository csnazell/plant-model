#                                                                              #
# PlantModelFramework                                                          #
#                                                                              #
# Features.jl                                                                  #
#                                                                              #
# Root module for Features namespace within package.                           #
#                                                                              #

module Features

    # sub-module: PIFCOFT

    include("Hypocotyl.jl")

    import .Hypocotyl

    export Hypocotyl

end

