#                                                                              #
# PlantModelFramework                                                          #
#                                                                              #
# Simulation.jl                                                                #
#                                                                              #
# Simulation items & helper functions                                          #
#                                                                              #
                                                                              
module Simulation

    # dependencies ------------------------------------------------------------

    # standard library
    # -

    # third-party
    #
    # - ArgCheck
    # -- argument validation macros
    # -- (https://github.com/jw3126/ArgCheck.jl)

    using ArgCheck

    # package
    # -

    # implementation ----------------------------------------------------------

    #
    # ModelData
    # - abstract base type for model data describing state or output for a pass
    #   of the model
    #

    abstract type ModelData end

    #
    # Frame
    # - container for model data, either output or state, for a pass of the 
    #   plant model simulation
    
    struct Frame 

        day::Int32                          # timepoint day  : 0+
        timepoint::Int8                     # timepoint hour : 0 | 1 - 24
        modelData::Dict{String,ModelData}   # {model key : model data}

        function Frame(day::Integer, timepoint::Integer)

            # guard condition: parameter bounds checking

            @argcheck day >= 0 "day should be >= 0" 
            @argcheck (timepoint >= 0 && timepoint < 25) "day should be >= 0"

            # construct

            new(day, timepoint, Dict{String,ModelData}())

        end

    end

    # functions

    function getData(frame::Frame, key::String)::Union{ModelData, Nothing}

        Base.get(frame.modelData, key, nothing)

    end

    function setData(frame::Frame, key::String, data::ModelData)

        Base.setindex!(frame.modelData, data, key)

    end

    # exports

    export getData, setData

end


