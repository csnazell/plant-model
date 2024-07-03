#                                                                              #
# PlantModelFramework                                                          #
#                                                                              #
# Feature.jl                                                                   #
#                                                                              #
# Modelling of additional features for a plant model.                          #
#                                                                              #

module Feature

    # dependencies ------------------------------------------------------------
    
    # standard library
    # -

    # - OrdinaryDiffEq
    # -- Ordinary differential equation solvers + utilities
    #    standalone sub-package of SciML / DifferentialEquations
    # -- (https://github.com/SciML/OrdinaryDiffEq.jl)

    using OrdinaryDiffEq

    # package
    
    import ..Simulation
    import ..Models
    import ..Environment
    import ..Clock
    import ..Phenology

    # implementation ----------------------------------------------------------

    abstract type Model <: Models.Dynamic end
    
    #
    # Clock-dependent
    #

    abstract type ClockFeature <: Model end

    # functions

    function (f::ClockFeature)(output::Clock.Output,
                               current::Simulation.Frame,
                               history::Vector{Simulation.Frame})

        error("Feature.ClockFeature() please implement this abstract functor for your subtype")

    end
    
    #
    # Phenology-dependent
    #

    abstract type PhenologyFeature <: Model end

    # functions

    function (f::PhenologyFeature)(output::Phenology.Output,
                                   current::Simulation.Frame,
                                   history::Vector{Simulation.Frame})

        error("Feature.PhenologyFeature() please implement this abstract functor for your subtype")

    end
    
    #
    # Clock+Phenology-dependent
    #
/
    abstract type ClockPhenologyFeature <: Model end

    # functions

    function (f::ClockPhenologyFeature)(clockOutput::Clock.Output,
                                        phenologyOutput::Phenology.Output,
                                        current::Simulation.Frame,
                                        history::Vector{Simulation.Frame})

        error("Feature.ClockPhenologyFeature() please implement this abstract functor for your subtype")

    end
    
    #
    # helper methods
    #

    function run(m::Model, 
                 clockOutput::Clock.Output, 
                 phenologyOutput::Union{Nothing, Phenology.Output}, 
                 current::Simulation.Frame, 
                 history::Vector{Simulation.Frame})

        # validate parameters

        requiresPhenology = isa(m, PhenologyFeature) || isa(m, ClockPhenologyFeature)

        if (requiresPhenology && isnothing(phenologyOutput))
            error("attempting to run a feature ($(typeof(m))) requiring phenology model")
        end

        # dispatch parameters to feature model

        if isa(m, ClockFeature)
            m(clockOutput, current, history)
        elseif isa(m, PhenologyFeature)
            m(phenologyOutput, current, history)
        elseif isa(m, ClockPhenologyFeature)
            m(clockOutput, phenologyOutput, current, history)
        else
            error("unrecognised feature type: $(typeof(m))")
        end

    end

    # exports

    export run

end # end: module: Feature
