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

        day::Int32                          # timepoint day  : 1+
        hour::Int8                          # timepoint hour : 0 | 1 - 24
        modelData::Dict{String,ModelData}   # {model key : model data}

        function Frame(day::Integer=1, timepoint::Integer=0)

            # guard condition: parameter bounds checking

            @argcheck day >= 1 "day should be >= 1" 
            @argcheck (timepoint >= 0 && timepoint < 25) "day should be >= 0"

            # construct

            new(day, timepoint, Dict{String,ModelData}())

        end

    end

    # functions

    # - model data

    function getData(frame::Frame, key::String)::Union{ModelData, Nothing}

        Base.get(frame.modelData, key, nothing)

    end

    function setData(frame::Frame, key::String, data::ModelData)

        Base.setindex!(frame.modelData, data, key)

    end

    # - time

    day(frame::Frame) = frame.day

    hour(frame::Frame) = frame.hour

    timepoint(frame::Frame) = ( (frame.day - 1) * 24 ) + frame.hour

    # exports

    export getData, setData

    export day, hour, timepoint

end


