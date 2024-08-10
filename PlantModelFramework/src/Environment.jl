#                                                                              #
# PlantModelFramework                                                          #
#                                                                              #
# Environment.jl                                                               #
#                                                                              #
# Environment modelling.                                                       #
#                                                                              #
# Environment models report environmental conditions for a given time point    #
# # within a simulation expressed as day and an hour.                          #
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

module Environment

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
    
    import ..Models

    # implementation ----------------------------------------------------------

    #
    # State
    # - base environment state
    #

    struct State
        day::Int32              # timepoint day  : 0+
        hour::Int8              # timepoint hour : 1 - 24
        temperature::Float32    # temperature @ timepoint (ºC)
        sunrise::Int8           # hour of sunrise @ timepoint : 0 - 24
        sunset::Int8            # hour of sunrise @ timepoint : 0 - 24
        dayDuration::Int8       # duration of day (default: 24)
    end

    # accessors

    day(state::State) = state.day

    dayDuration(state::State) = state.dayDuration

    hour(state::State) = state.hour

    photoperiod(state::State) = sunset(state) - sunrise(state)

    sunrise(state::State) = state.sunrise

    sunset(state::State) = state.sunset

    temperature(state::State) = state.temperature

    # functions

    function light_condition(state::State, time::AbstractFloat)

        # guard condition: photoperiod @ 0

        if (photoperiod(state) == 0)
            return 0
        end

        # guard condition: photoperiod @ day

        period        = 24.0        # period of day

        if (photoperiod(state) == Int8(period))
            return 1.0
        end

        # calculate state of light

        lightAmp    =  1.0        # amplitude of light wave
        lightOffset =  0.0        # offset light function result
        twilightPer =  0.00005    # duration of time between value of force in dark and 
                                  # value of force in light

        timeCorrected    = mod((time - (15 * twilightPer)), period)

        dawn = Float64(sunrise(state))
        pp   = Float64(photoperiod(state))

        thingA = (timeCorrected + dawn) / period - floor( floor(timeCorrected + dawn) / period )

        thingB = 1 + tanh( (period / twilightPer) * thingA )
        thingD = 1 + tanh( (period / twilightPer) * thingA - (pp / twilightPer) )  
        thingE = 1 + tanh( (period / twilightPer) * thingA - (period / twilightPer) )

        L = lightOffset + 
            (0.5 * lightAmp * thingB) - 
            (0.5 * lightAmp * thingD) + 
            (0.5 * lightAmp * thingE)

        # light condition

        return L

    end

    function light_fraction(state::State)

        hr = hour(state)

        if     photoperiod(state) == 0

            return 0.0

        elseif photoperiod(state) == 24

            return 1.0 

        elseif hr > sunrise(state) && hr <= sunset(state)

            return 1.0

        else 

            return 0.0

        end

    end

    # exports

    export day, dayDuration, hour, photoperiod, sunrise, sunset, temperature
    export light_condition, light_fraction
    
    #
    # Model
    # - abstract base type for environmental models.
    # 

    abstract type Model <: Models.Base end

    # functions

    function (m::Model)(day::Integer, hour::Integer)::State
        error("Enviroment.Model() please implement this abstract functor for your subtype")
    end

    #
    # ConstantModel
    # - environmental model with constant state
    # 

    struct ConstantModel <: Model

        # fields

        temperature::Float32    # temperature @ timepoint (ºC)
        sunrise::Int8           # hour of sunrise @ timepoint : 0 - 24
        sunset::Int8            # hour of sunrise @ timepoint : 0 - 24
        dayDuration::Int8       # duration of day in hours

        # constructor

        function ConstantModel( ; temperature::AbstractFloat=22.0, 
                                  sunrise::Integer=0, 
                                  sunset::Integer=0,
                                  dayDuration::Integer=24)

            # parameter constraints
            # - sunrise <= sunset & 0 | 1:24

            sunriseCorrected = min(sunrise, sunset)
            sunsetCorrected  = max(sunrise, sunset)

            dayDuration      = max(0, dayDuration)

            @argcheck sunriseCorrected in 0:24 "sunrise should be within range 1:24"
            @argcheck sunsetCorrected in 0:24 "sunset should be within range 1:24"
            @argcheck dayDuration > 0 "duration of day should be > 0"

            # construct

            new(temperature, sunriseCorrected, sunsetCorrected, dayDuration)
        end

    end

    # functions

    function (m::ConstantModel)(day::Integer, hour::Integer)

        state = State(day, hour, m.temperature, m.sunrise, m.sunset, m.dayDuration)

    end

end # module: Environment
