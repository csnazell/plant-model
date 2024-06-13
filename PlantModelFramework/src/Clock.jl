#                                                                              #
# PlantModelFramework                                                          #
#                                                                              #
# Clock.jl                                                                     #
#                                                                              #
# Clock gene modelling.                                                        #
#                                                                              #
# ...                                                                          #
#                                                                              #

module Clock

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
    
    import ..Simulation
    import ..Models
    import ..Environment

    # implementation ----------------------------------------------------------

    #
    # Output
    # - clock dynamics output data
    #

    struct Output
        T
        Y
    end

    #
    # State
    # - clock dynamics state data
    #

    struct State
        Y_previous
    end

    #
    # Dynamics
    # - abstract base type for clock model dynamic behaviour
    #   i.e. the bit that performs the calculations
    #

    abstract type Dynamics <: Models.Base end

    abstract type DynamicsParameters end

    # functions

    function (m::Dynamics)()
        # MATLAB: dynamics(t,y,P,sunrise,sunset) -> vector(values) 2011 ~> 30 | 2014 ~> 35
        # t: time (segment)
        # y: vector values
        # P: clock parameters vector
        # sunrise: value hour -+-> environment 
        # sunset: value hour  -|
        error("Clock.Dynamics() please implement this abstract functor for your subtype")
    end

    #
    # Model
    # - abstract base type for clock models.
    # 

    struct Model <: Models.Dynamic

        environment::Environment.Model          # environment model
        clockDynamics::Dynamics                 # clock behaviour
        clockParameters::DynamicsParameters     # clock behaviour parameters
        key::String                             # model identifier

        function Model(
                environment::Environment.Model,      
                clockDynamics::Dynamics,             
                clockParameters::DynamicsParameters, 
                key::String="model.clock"
                # TODO: DO WE NEED A clock dynamics id here so we know what's running?
                )

            new(environment, clockDynamics, clockParameters, key)

        end

    end

    # functions

    function (m::Model)(outputCurrent::Simulation.Frame,
                        outputHistory::Simulation.Frame,
                        stateCurrent::Vector{Simulation.Frame},
                        stateHistory::Vector{Simulation.Frame})

        previousState = stateHistory[end]

        # output
        # FIXME: IMPLEMENT
	    # MATLAB: % Run model for 27 hours:
	    #   Tout = 0:0.05:27;
	    #   [T,Y] = ode15s(@(t,y) clock_dynamics(t,y,parameters,sunrise,sunset),Tout,y0);

        # FIXME: REMOVE PLACEHOLDER
        # PLACEHOLDER
        # T = [541x1]  
        T = reshape(0.0:0.05:27, (541, 1))
        # Y = [541x35] | 541 == # time increments & 35 == length(y0) | 
        Y = broadcast(+, zeros(Float64, 35, 541), previousState.Y_previous)
        # PLACEHOLDER
	
        setData(outputCurrent, m.key, Output(T, Y))

        # state
        # FIXME: IMPLEMENT
        # MATLAB: % work out the clock state at ZT24 i.e. at the start of the next day
        #         clock_state_0 = interp1q(clock_output.T,clock_output.Y,24);
        
        # FIXME: REMOVE PLACEHOLDER
        # PLACEHOLDER
        clock_state_0 = vcat(previousState.Y_previous)
        # PLACEHOLDER

        setData(stateCurrent, m.key, State(clock_state_0))

    end

    function entrain(m::Model, 
                     fromState::State,
                     outputInitial::Simulation.Frame,
                     stateInitial::Simulation.Frame,
                     duration::Integer=12,
                     photoperiod::Integer=12)::Output

        # MATLAB: entrain_clock_model(clock_parameters,
        #                             clock_dynamics,
        #                             sunrise(1),
        #                             sunrise(1)+options.entrain,
        #                             options.y0);
        # MATLAB: entrain_clock_model(parameters,
        #                             clock_dynamics,
        #                             sunrise,
        #                             sunset,
        #                             y0)

        # parameter constraints
        
        @argcheck photoperiod  in 0:24 "photoperiod should be within range 1:24"

        # environment

        sr = sunrise(m.environment)
        ss = sr + photoperiod

        # entrain clock state
        # FIXME: IMPLEMENT

        # - initialise clock model
        
        # MATLAB:   % Initialise clock model (12 days)
	    # MATLAB:   [~,Ycinit] = ode15s(@(t,y) clock_dynamics(t,y,parameters,sunrise,sunset),0:0.1:(12*24),y0);
	    # MATLAB:   y0 = Ycinit(end,:)';
        
        # FIXME: REMOVE PLACEHOLDER
        # PLACEHOLDER
        y0 = vcat(fromState.Y_previous)
        # PLACEHOLDER

        stateEntrained = Frame()

        set(stateEntrained, m.key, State(y0))

        # - run for a day

        run(m, 1, 1, outputInitial, [], stateInitial, [stateEntrained])
	
    end

    function run(m::Model,
                 outputCurrent::Simulation.Frame,
                 outputHistory::Simulation.Frame,
                 stateCurrent::Vector{Simulation.Frame},
                 stateHistory::Vector{Simulation.Frame})

        m(outputCurrent, outputHistory, stateCurrent, stateHistory)

    end

    # exports
    
    export run

end
