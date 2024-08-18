#                                                                              #
# PlantModelFramework                                                          #
#                                                                              #
# Clock.jl                                                                     #
#                                                                              #
# Clock gene modelling boilerplate.                                            #
#                                                                              #
# Specific circadian (clock) behaviour modelling is provided by the            #
# implementations found in Clocks.* (Clocks/).                                 #
#                                                                              #
# Notes:                                                                       #
#                                                                              #
# SciML solvers for ordinary differential equations:                           #
# https://docs.sciml.ai/DiffEqDocs/dev/solvers/ode_solve/                      #
#                                                                              #
# Original MATLAB code used ode15s, default mapping into Julia uses QNDF but   #
# can be overriden by configuring the 'alg' keyword parameter when             #
# constructing the clock model.                                                #
#                                                                              # 
# Julia differential equations solvers use du / dt terminology rather than the #
# dy / dt terminology seen in MATLAB.                                          #
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

    # - SciMLBase.jl
    # -- SciMLBase.jl is the core interface definition of the SciML packages
    # -- (https://github.com/SciML/SciMLBase.jl)

    using SciMLBase: AbstractODEAlgorithm

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

    function (m::Dynamics)(
                du,                             # calculated matrix of next values
                u,                              # vector  of values
                parameters::Tuple{Environment.State, Dict{Any,Any}},    
                                                # (environment state @ day + hour, tracing dict)
                t                               # time 
                )
        error("Clock.Dynamics() please implement this abstract functor for your subtype")
    end


    #
    # Model
    #
    # Concrete implementation of Models.SimulationModel for plant clock behaviour
    # 

    # type

    struct Model <: Models.SimulationModel

        environment::Environment.Model          # environment model
        clockDynamics::Dynamics                 # clock behaviour
        key::String                             # model identifier
        tracing::Bool                           # flag: tracing enabled
        algorithm::AbstractODEAlgorithm         # ODE problem solver

        function Model(
                environment::Environment.Model,      
                clockDynamics::Dynamics,             
                key::String="model.clock";
                # TODO: DO WE NEED A clock dynamics id here so we know what's running?
                tracing::Bool=false,
                alg::Union{Nothing,AbstractODEAlgorithm}=nothing
                )

            algorithm = isnothing(alg) ? QNDF(autodiff=false) : alg

            new(environment, clockDynamics, key, tracing, algorithm)

        end

    end

    # functions

    function (m::Model)(current::Simulation.Frame,
                        history::Vector{Simulation.Frame},
                        envStateOrNothing::Union{Nothing,Environment.State}=nothing)

        # last times values

        previousFrame = history[end]

        previousState = Simulation.getState(previousFrame, m.key)

        # environment
        # - entrainment can use a different environmental set-up from 
        #   the regular simulation (defaults to a 12 hour photoperiod)
        #   it's therefore necessary to be able to override the environment
        #   state when running the model during entrainment

        if (isnothing(envStateOrNothing))

            envState = m.environment(Simulation.day(current), Simulation.hour(current))

        else

            envState = envStateOrNothing

            sr   = Environment.sunrise(envState)
            ss   = Environment.sunset(envState)
            temp = Environment.temperature(envState)

            @info "clock model utilising environment (sr=$(sr) | ss=$(ss) | T=$(temp))"

        end

        # dynamics

        if (tracing(m))
        
            problem = ODEProblem(m.clockDynamics,
                                 previousState.U,
                                 (0.0, 27.0),
                                 (envState, Simulation.getTrace(current, m.key)))

        else
        
            problem = ODEProblem(m.clockDynamics,
                                 previousState.U,
                                 (0.0, 27.0),
                                 envState)

        end

        solution = solve(problem, m.algorithm, saveat=0.05, reltol=1e-6)

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

        solution = solve(problem, m.algorithm, saveat=0.1, reltol=1e-6)

        # - state
        #   NB: MATLAB code uses linear interpolation here however 
        #       in Julia the algorithm used to solve the differential 
        #       equations implicitly specifies the interpolation algorithm

        entrainedFrame = Simulation.Frame() 

        entrainedState = State(solution.u[end])
        
        Simulation.setState(entrainedFrame, m.key, entrainedState)

        # - run for a day

        m(initialFrame, [entrainedFrame], envState)
	
    end

    function run(m::Model,
                 current::Simulation.Frame,
                 history::Vector{Simulation.Frame})::Output

        m(current, history)

    end

    #
    # tracing
    #

    tracing(m::Model) = m.tracing 

    # exports
    
    export run

end
