#                                                                              #
# PlantModelFramework                                                          #
#                                                                              #
# Features/Hypocotyl.jl                                                        #
#                                                                              #
# Hypocotyl feature models                                                     #
#                                                                              #
# Model:                                                                       # 
# - ???                                                                        #
#                                                                              #

module Hypocotyl

    # dependencies ------------------------------------------------------------
    
    # standard library
    # -

    # third-party
    #
    # - Accessors
    # -- struct copying & modification
    # -- (https://github.com/JuliaObjects/Accessors.jl)

    using Accessors

    # - ArgCheck
    # -- argument validation macros
    # -- (https://github.com/jw3126/ArgCheck.jl)

    using ArgCheck
    
    # - CSV.jl
    # -- *SV parsing library
    # -- (https://github.com/JuliaData/CSV.jl)

    using CSV

    # - DataInterpolations.jl
    # -- Interpolation of 1-Dimensional data (part of SciML)
    # -- (https://github.com/SciML/DataInterpolations.jl

    using DataInterpolations

    # = Trapz
    # -- Trapezoidal integration library
    # -- (https://github.com/francescoalemanno/Trapz.jl)
    
    using Trapz

    # package
    
    import ....Simulation
    import ....Models
    import ....Environment
    import ....Phenology
    import ....Feature

    # implementation ----------------------------------------------------------

    #
    # Common: Hypocotyl
    #
    
    # parameters

    # - constants

    const P2011 = 1
    const F2014 = 2

    # - types

    @kwdef struct Parameters
        a1::Float64
        a2::Float64
        a3::Float64
    end

    # - functions
    
    # TODO: MEMOISE?
    function parameters(set::Integer)

        # validate argument

        @argcheck (set in [P2011, F2014]) "unrecognised parameter set value (should be P2011 or F2014)"

        # parameters location

        fnTSV = "P2011.tsv"

        if (set == F2014)

            fnTSV = "F2014.tsv"

        end

        fpParameters = normpath(joinpath(@__DIR__), "Data", "Hypocotyl", fnTSV)

        # load

        @info "loading $(fnTSV) parameters from $(fpParameters)"

        parameters = Dict( map(r -> (Symbol(r[1]) , Float64( r[2] )), CSV.File(fpParameters, delim="\t")) )

        # parameters
        
        return Parameters(; parameters...)

    end
    
    # 
    # Feature: Hypocotyl Length
    #
    
    # model

    # - types

    struct Length <: Feature.PhenologyFeature
        parameters::Parameters
        key::String

        function Length(parameters, key="model.hypocotyl.length")

            new(parameters, key)

        end
    end

    # - functions

    function (f::Length)(output::Phenology.Output,          # phenology model output
                         current::Simulation.Frame,         # current simulation frame
                         history::Vector{Simulation.Frame}  # previous simulation frames
                        )

        # calculation

        # - calculation

        length = f.parameters.a1 * trapz(output.S.t, (min.(output.S[8,:], f.parameters.a3) .- f.parameters.a2))

        # - output

        output = LengthOutput(length)

        Simulation.setOutput(current, f.key, output)

        # - state
        
        # - 

    end

    # output

    struct LengthOutput <: Simulation.ModelData
        length::Float64
    end

    # state

    # - 

end #end: module: Hypocotyl

