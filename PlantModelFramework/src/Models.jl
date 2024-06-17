#                                                                              #
# PlantModelFramework                                                          #
#                                                                              #
# Models.jl                                                                    #
#                                                                              #
# Base model type(s).                                                          #
#                                                                              #

module Models

    # dependencies ------------------------------------------------------------

    # package
    
    import ..Simulation

    # implementation ----------------------------------------------------------

    #
    # Base 
    # - base abstract model type
    #

    abstract type Base end

    # functions

    function (m::Base)()
        error("Models.Base() please implement this abstract functor for your subtype")
    end

    #
    # Dynamic
    # - dynamic abstract model type
    #

    abstract type Dynamic <: Base end

    # functions

    function (m::Dynamic)(current::Simulation.Frame,
                          history::Vector{Simulation.Frame})
        error("Models.Dynamic() please implement this abstract functor for your subtype")
    end
    
end
