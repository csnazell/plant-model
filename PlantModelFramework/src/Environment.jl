#                                                                              #
# PlantModelFramework                                                          #
#                                                                              #
# Environment.jl                                                               #
#                                                                              #
# Environment model.                                                           #
#                                                                              #
# Environment models report climate conditions for a given time point within a #
# simulation.                                                                  #
#                                                                              #
# Environment models conform to:                                               #
# - func model(day, timepoint) -> state                                        #
#                                                                              #
# where:                                                                       #
#                                                                              #
# - day   : UInt8 unsigned integer                                             #
# - hour  : UInt8 timepoint hour (1 - 24)                                      #
# - state : EnvState structure defining environmental state properties         #
#                                                                              #

module Environment

    export photoperiod, sunrise, sunset, temperature

    #
    # state
    # - base environment state
    #

    # type

    struct EnvState
        day::UInt32             # timepoint day  : 0+
        hour::UInt8             # timepoint hour : 1 - 24
        temperature::Float32    # temperature @ timepoint (ºC)
        sunrise::UInt8          # hour of sunrise @ timepoint : 0 - 24
        sunset::UInt8           # hour of sunrise @ timepoint : 0 - 24
    end

    # functions

    function photoperiod(state::EnvState)
        return sunset(state) - sunrise(state)
    end

    function sunrise(state::EnvState)
        return state.sunrise
    end

    function sunset(state::EnvState)
        return state.sunset
    end

    function temperature(state::EnvState)
        return state.temperature
    end
    
    #
    #
    # models             
    #
    #

    #
    # Model
    #
    # Abstract base type for environmental models.
    # 

    abstract type Model end

    function (m::Model)(day::Integer, hour::Integer)::EnvState
        error("Enviroment.Model() please implement this abstract functor for your subtype")
    end

    #
    # SimpleModel
    #
    # Constant environmental model
    # 

    struct SimpleModel <: Model

        # fields

        temperature::Float32    # temperature @ timepoint (ºC)
        sunrise::UInt8          # hour of sunrise @ timepoint : 0 - 24
        sunset::UInt8           # hour of sunrise @ timepoint : 0 - 24

        # constructor

        function SimpleModel( ; temperature::AbstractFloat=22.0, 
                                sunrise::Integer=0, 
                                sunset::Integer=0)

            # parameter constraints
            # - sunrise <= sunset & 0 | 1:24

            sunrise = min(sunrise, sunset)
            sunset = max(sunrise, sunset)

            @assert sunrise in 0:24 "sunrise should be within range 1:24"
            @assert sunset in 0:24 "sunset should be within range 1:24"

            # construct

            new(temperature, sunrise, sunset)
        end

    end

    # functions

    function (m::SimpleModel)(day::Integer, hour::Integer)

        state = EnvState(day, hour, m.temperature, m.sunrise, m.sunset)

    end

end
