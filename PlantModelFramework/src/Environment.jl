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
# Environment models are derived from the Model abstract base type. They are a #
# Julia "functor" (NB: not a proper functor) of the form:                      #
#                                                                              #
# - model(day, timepoint) -> state                                             #
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
    end

    # accessors

    photoperiod(state::State) = sunset(state) - sunrise(state)

    sunrise(state::State) = state.sunrise

    sunset(state::State) = state.sunset

    temperature(state::State) = state.temperature

    # functions

    function light_condition(state::State, t::AbstractFloat)

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

        tCorrected    = mod((t - (15 * twilightPer)), period)

        dawn = Float64(sunrise(state))
        pp   = Float64(photoperiod(state))

        thingA = (tCorrected + dawn) / period - floor( floor(tCorrected + dawn) / period )

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

        if     photoperiod(envState) == 0

            return 0.0

        elseif photoperiod(envState) == 24

            return 1.0 

        elseif hr > sunrise(envState) && hr <= sunset(envState)

            return 1.0

        else 

            return 0.0

        end

    end

    # exports

    export photoperiod, sunrise, sunset, temperature
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

        # constructor

        function ConstantModel( ; temperature::AbstractFloat=22.0, 
                                  sunrise::Integer=0, 
                                  sunset::Integer=0)

            # parameter constraints
            # - sunrise <= sunset & 0 | 1:24

            sunriseCorrected = min(sunrise, sunset)
            sunsetCorrected  = max(sunrise, sunset)

            @argcheck sunriseCorrected in 0:24 "sunrise should be within range 1:24"
            @argcheck sunsetCorrected in 0:24 "sunset should be within range 1:24"

            # construct

            new(temperature, sunriseCorrected, sunsetCorrected)
        end

    end

    # functions

    function (m::ConstantModel)(day::Integer, hour::Integer)

        state = State(day, hour, m.temperature, m.sunrise, m.sunset)

    end

end # module: Environment
