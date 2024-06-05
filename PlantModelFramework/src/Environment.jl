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
# - state : EnvState structure defining environmental state properties            #
#                                                                              #

module Environment

    export photoperiod, sunrise, sunset, temperature

    #
    # types
    #

    # base environment state

    # - type

    struct EnvState
        day::UInt32             # timepoint day  : 0+
        hour::UInt8             # timepoint hour : 1 - 24
        temperature::Float32    # temperature @ timepoint (ºC)
        sunrise::UInt8          # hour of sunrise @ timepoint : 0 - 24
        sunset::UInt8           # hour of sunrise @ timepoint : 0 - 24
    end

    # - functions

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
    # models             
    #

    function simpleModel(temperature::AbstractFloat=22.0, 
                         sunrise::Integer=0, 
                         sunset::Integer=0)

        model = 
            let t = temperature, sr = sunrise, ss = sunset

                # parameter constraints
                # - sunrise <= sunset & 0 | 1:24

                sr = min(sr, ss)
                ss = max(sr, ss)

                @assert sr in 0:24 "sunrise should be within range 1:24"
                @assert ss in 0:24 "sunset should be within range 1:24"

                # model

                function(day::Integer, hour::Integer)
                    state = EnvState(day, hour, t, sr, ss)

                    return state
                end

            end

        return model

    end

end
