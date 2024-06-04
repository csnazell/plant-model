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
# - state : State structure defining environmental state properties            #
#                                                                              #

module Environment

    #
    # types
    #

#    struct State
#        day::UInt32             # timepoint day  : 0+
#        hour::UInt8             # timepoint hour : 1 - 24
#        temperature:Float32     # temperature @ timepoint (ºC)
#        sunrise::UInt8          # hour of sunrise @ timepoint : 0 - 24
#        sunset::UInt8           # hour of sunrise @ timepoint : 0 - 24
#    end
    
    #
    # constructors
    #

    function debug()
        print("Environment!")
    end
    
#    function simple(temperature::Float32=22.0, sunrise::UInt8=0, sunset::UInt8=0)
#
#        model = 
#            function(day::UInt32, hour::UInt8)
#            
#                state = State(day, hour, temperature, sunrise, sunset)
#
#            end
#
#        return model
#
#    end

end
