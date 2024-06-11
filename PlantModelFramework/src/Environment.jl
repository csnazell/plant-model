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

    # functions

    photoperiod(state::State) = sunset(state) - sunrise(state)

    sunrise(state::State) = state.sunrise

    sunset(state::State) = state.sunset

    temperature(state::State) = state.temperature

    # exports

    export photoperiod, sunrise, sunset, temperature
    
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
