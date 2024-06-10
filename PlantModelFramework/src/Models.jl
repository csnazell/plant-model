#                                                                              #
# PlantModelFramework                                                          #
#                                                                              #
# Models.jl                                                                    #
#                                                                              #
# Base model type(s).                                                          #
#                                                                              #

module Models

    #
    # Base 
    #

    abstract type Base end

    function (m::Base)()
        error("Models.Base() please implement this abstract functor for your subtype")
    end
    
end
