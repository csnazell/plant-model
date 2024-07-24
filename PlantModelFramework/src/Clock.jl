#                                                                              #
# PlantModelFramework                                                          #
#                                                                              #
# Clock.jl                                                                     #
#                                                                              #
# Clock gene modelling.                                                        #
#                                                                              #
# Notes:                                                                       #
#                                                                              #
# SciML solvers for ordinary differential equations:                           #
# https://docs.sciml.ai/DiffEqDocs/dev/solvers/ode_solve/                      #
#                                                                              #
# ode15s mapping into Julia (from above):                                      #
# "ode15s/vode –> QNDF() or FBDF(), though in many cases Rodas5P(), KenCarp4(),# 
# TRBDF2(), or RadauIIA5() are more efficient.                                 #
#                                                                              # 
# Julia differential equations solvers use du / dt terminology rather than the #
# dy / dt terminology seen in MATLAB.                                          #
#                                                                              #
# Queries:                                                                     #
#                                                                              #
# Should we track solution from solver rather than Output(solution.t,          #
# solution.u)?                                                                 #
#                                                                              #
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

    # - OrdinaryDiffEq
    # -- Ordinary differential equation solvers + utilities
    #    standalone sub-package of SciML / DifferentialEquations
    # -- (https://github.com/SciML/OrdinaryDiffEq.jl)

    using OrdinaryDiffEq

    # package
    
    import ..Simulation
    import ..Models
    import ..Environment

    # implementation ----------------------------------------------------------

    #
    # Output
    # - clock dynamics output data
    #

    struct Output <: Simulation.ModelData
        S
    end

    #
    # State
    # - clock dynamics state data
    #

    struct State <: Simulation.ModelData
        U
    end

    #
    # Dynamics
    # - abstract base type for clock model dynamic behaviour
    #   i.e. the bit that performs the calculations
    #

    abstract type DynamicsParameters end

    struct Dynamics{P <: DynamicsParameters} <: Models.Base 
        parameters::P
    end

    # functions

    function (m::Dynamics)(
                du,                             # calculated matrix of next values
                u,                              # vector  of values
                envState::Environment.State,    # environment state @ day + hour
                t                               # time 
                )
        error("Clock.Dynamics() please implement this abstract functor for your subtype")
    end

    #
    # Model
    # 

    struct Model <: Models.Dynamic

        environment::Environment.Model          # environment model
        clockDynamics::Dynamics                 # clock behaviour
        key::String                             # model identifier
        algorithm                               # ODE problem solver
                                                # - Untyped due to SCIML not typing this 
                                                #   parameter in its code

        function Model(
                environment::Environment.Model,      
                clockDynamics::Dynamics,             
                key::String="model.clock";
                # TODO: DO WE NEED A clock dynamics id here so we know what's running?
                alg=Nothing
                )

            algorithm = isnothing(alg) ? QNDF(autodiff=false) : alg

            new(environment, clockDynamics, key, algorithm)

        end

    end

    # functions

    function (m::Model)(current::Simulation.Frame,
                        history::Vector{Simulation.Frame})

        # last times values

        previousFrame = history[end]

        previousState = Simulation.getState(previousFrame, m.key)

        # environment

        envState = m.environment(Simulation.day(current), Simulation.hour(current))

        # dynamics
        
        problem = ODEProblem(m.clockDynamics,
                             previousState.U,
                             (0.0, 27.0),
                             envState)

        solution = solve(problem, m.algorithm, saveat=0.05)

        # - output

        output = Output(solution)

        Simulation.setOutput(current, m.key, output)

        # - state
        #   NB: MATLAB code uses linear interpolation here however 
        #       in Julia the algorithm used to solve the differential 
        #       equations implicitly specifies the interpolation algorithm
        
        state = State(solution(24))

        Simulation.setState(current, m.key, state)

        # output

        return output

    end

    function entrain(m::Model, 
                     fromState::State,
                     initialFrame::Simulation.Frame,
                     duration::Integer=12,
                     photoperiod::Integer=12)

        # parameter constraints
        
        @argcheck photoperiod  in 0:24 "photoperiod should be within range 1:24"

        # environment

        envState = m.environment(1,1)

        envState = Environment.State(envState.day,
                                     envState.hour, 
                                     envState.temperature,
                                     envState.sunrise,
                                     (envState.sunrise + photoperiod),
                                     envState.dayDuration)

        # entrain clock state

        # - initialise clock model 
        #   entrain for specified duration

        problem = ODEProblem(m.clockDynamics,
                             fromState.U,
                             (0.0, (duration * 24.0)),
                             envState)

        solution = solve(problem, m.algorithm, saveat=0.1)

        # - state
        #   NB: MATLAB code uses linear interpolation here however 
        #       in Julia the algorithm used to solve the differential 
        #       equations implicitly specifies the interpolation algorithm

        entrainedFrame = Simulation.Frame() 

        entrainedState = State(solution.u[end])
        
        Simulation.setState(entrainedFrame, m.key, entrainedState)

        # - run for a day

        run(m, initialFrame, [entrainedFrame])
	
    end

    function run(m::Model,
                 current::Simulation.Frame,
                 history::Vector{Simulation.Frame})::Output

        m(current, history)

    end

    # exports
    
    export run

end
