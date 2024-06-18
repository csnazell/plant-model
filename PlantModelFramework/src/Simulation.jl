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
        outputData::Dict{String,ModelData}  # output: {model key : model data}
        stateData::Dict{String,ModelData}   # state: {model key : model data}

        function Frame(day::Integer=1, hour::Integer=0)

            # guard condition: parameter bounds checking

            @argcheck day >= 1 "day should be >= 1" 
            @argcheck (hour >= 0 && hour < 25) "hour should be >= 0 && < 25"

            # construct

            new(day, hour, Dict{String,ModelData}(), Dict{String,ModelData}())

        end

    end

    # functions

    # - model data

    function getOutput(frame::Frame, key::String)::Union{ModelData, Nothing}

        Base.get(frame.outputData, key, nothing)

    end

    function setOutput(frame::Frame, key::String, data::ModelData)

        Base.setindex!(frame.outputData, data, key)

    end

    function getState(frame::Frame, key::String)::Union{ModelData, Nothing}

        Base.get(frame.stateData, key, nothing)

    end

    function setState(frame::Frame, key::String, data::ModelData)

        Base.setindex!(frame.stateData, data, key)

    end

    # - time

    day(frame::Frame) = frame.day

    hour(frame::Frame) = frame.hour

    timepoint(frame::Frame) = ( (frame.day - 1) * 24 ) + frame.hour

    # exports

    export getOutput, setOutput, getState, setState

    export day, hour, timepoint

end


