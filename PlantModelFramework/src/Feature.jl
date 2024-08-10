#                                                                              #
# PlantModelFramework                                                          #
#                                                                              #
# Feature.jl                                                                   #
#                                                                              #
# Modelling of additional features for a plant model.                          #
#                                                                              #
#    Copyright 2024 Christopher Snazell, Dr Rea L Antoniou-Kourounioti  and    #
#                    The University of Glasgow                                 #
#                                                                              #
#  Licensed under the Apache License, Version 2.0 (the "License");             #
#  you may not use this file except in compliance with the License.            #
#  You may obtain a copy of the License at                                     #
#                                                                              #
#      http://www.apache.org/licenses/LICENSE-2.0                              #
#                                                                              #
#  Unless required by applicable law or agreed to in writing, software         #
#  distributed under the License is distributed on an "AS IS" BASIS,           #
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    #
#  See the License for the specific language governing permissions and         #
#  limitations under the License.                                              #
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
    
    #
    # Features.Model
    #
    # Abstract base type for plant "feature" simulation model
    #

    # type

    abstract type Model <: Models.SimulationModel end
    
    #
    # ClockFeature
    #
    # Abstract base type for plant "feature" simulation model that only 
    # requires Clock model outputs.
    #

    # type

    abstract type ClockFeature <: Model end

    # functions

    function (f::ClockFeature)(output::Clock.Output,
                               current::Simulation.Frame,
                               history::Vector{Simulation.Frame})

        error("Feature.ClockFeature() please implement this abstract functor for your subtype")

    end
    
    #
    # PhenologyFeature
    #
    # Abstract base type for plant "feature" simulation model that only 
    # requires Phenology model outputs.
    #

    # type

    abstract type PhenologyFeature <: Model end

    # functions

    function (f::PhenologyFeature)(output::Phenology.Output,
                                   current::Simulation.Frame,
                                   history::Vector{Simulation.Frame})

        error("Feature.PhenologyFeature() please implement this abstract functor for your subtype")

    end
    
    #
    # ClockPhenologyFeature
    #
    # Abstract base type for plant "feature" simulation model that only 
    # requires Phenology model outputs.
    #

    # type

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

        # dispatch parameters to feature model based on type of FeatureModel

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
