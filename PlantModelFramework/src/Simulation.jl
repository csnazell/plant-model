#                                                                              #
# PlantModelFramework                                                          #
#                                                                              #
# Simulation.jl                                                                #
#                                                                              #
# Simulation items & helper functions                                          #
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

        day::Int32                              # timepoint day  : 1+
        hour::Int8                              # timepoint hour : 0 | 1 - 24
        outputData::Dict{String,ModelData}      # output: {model key : model data}
        stateData::Dict{String,ModelData}       # state: {model key : model data}
        traceData::Dict{String,Dict{Any,Any}}   # trace: {model key : dict}

        function Frame(day::Integer=1, hour::Integer=0)

            # guard condition: parameter bounds checking

            @argcheck day >= 1 "day should be >= 1" 
            @argcheck (hour >= 0 && hour < 25) "hour should be >= 0 && < 25"

            # construct

            new(day, hour, Dict{String,ModelData}(), Dict{String,ModelData}(), Dict{String,Dict{Any,Any}}())

        end

    end

    # functions

    # - model data

    function getOutput(frame::Frame, key::String)::Union{ModelData, Nothing}

        Base.get(frame.outputData, key, nothing)

    end

    function getOutputs(frames::Vector{Frame}, key::String)::Vector{Tuple{Int32, Int8, ModelData}}

        map(f -> (day(f), hour(f), getOutput(f, key)), frames) 

    end

    function setOutput(frame::Frame, key::String, data::ModelData)

        Base.setindex!(frame.outputData, data, key)

    end

    function getState(frame::Frame, key::String)::Union{ModelData, Nothing}

        Base.get(frame.stateData, key, nothing)

    end

    function getStates(frames::Vector{Frame}, key::String)::Vector{Tuple{Int32, Int8, ModelData}}

        map(f -> (day(f), hour(f), getState(f, key)), frames) 

    end

    function setState(frame::Frame, key::String, data::ModelData)

        Base.setindex!(frame.stateData, data, key)

    end

    function getTrace(frame::Frame, key::String)::Dict{Any,Any}

        Base.get!(frame.traceData, key, Dict{Any,Any}())

    end

    function getTraces(frames::Vector{Frame}, key::String)::Vector{Tuple{Int32, Int8, Dict{Any,Any}}}

        map(f -> (day(f), hour(f), getTrace(f, key)), frames) 

    end

    # - time

    day(frame::Frame) = frame.day

    hour(frame::Frame) = frame.hour

    timepoint(frame::Frame) = ( (frame.day - 1) * 24 ) + frame.hour

    # exports

    export getOutput, setOutput, getState, setState, getTrace, getTraces

    export day, hour, timepoint

end
