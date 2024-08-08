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
    # - model base abstract type 
    #

    abstract type Base end

    # functions

    function (m::Base)()
        error("Models.Base() please implement this abstract functor for your subtype")
    end

    #
    # SimulationModel
    # - base type for a model describing a simulation
    #

    abstract type SimulationModel <: Base end

    # functions

    function (m::SimulationModel)(current::Simulation.Frame,
                          history::Vector{Simulation.Frame})
        error("Models.SimulationModel() please implement this abstract functor for your subtype")
    end
    
end
