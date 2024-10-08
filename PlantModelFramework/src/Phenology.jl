#                                                                              #
# PlantModelFramework                                                          #
#                                                                              #
# Phenology.jl                                                                 #
#                                                                              #
# Phenology modelling boilerplate.                                             #
#                                                                              #
# Specific phenology model behaviour modelling is provided by the              #
# implementations found in Phenologies.* (Phenologies/).                       #
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

module Phenology

module Plant

    # dependencies ------------------------------------------------------------
    
    # standard library
    # - 

    # third-party
    # - CSV.jl
    # -- *SV parsing library
    # -- (https://github.com/JuliaData/CSV.jl)

    using CSV
    
    # package
    # -

    # implementation ----------------------------------------------------------

    #
    # parameters
    #
    # Notes:
    # - Parameter values lifted from MATLAB codebase & parameter names extraced 
    #   from code. Those parameters which do not appear to be used have been 
    #   labeled p## where ## corresponds to the index (1-based) within the 
    #   original data.
    #
    # - Some of the entries in the original MATLAB .mat file are the same 
    #   parameter but for the alternate genotype. As a consequence the .tsv
    #   file included here adopts the two columns of the clock model and folds 
    #   the alternate genotype parameters into a separate column, duplicating 
    #   those values which are common.
    #

    @kwdef struct Parameters
        Tb::Float64
        Tvmin::Float64
        Tvmax::Float64
        Vsat::Float64
        v::Float64
        sigma::Float64
        m::Float64
        Dld::Float64
        CSDL::Float64
        CLDL::Float64
        Fb::Float64
        Dsd::Float64
        Threshold::Float64
        Night::Float64
        Phot_a::Float64
        Phot_b::Float64
        Phot_c::Float64
        Phot_n::Float64
        p19::Float64
        p20::Float64
        p21::Float64
        p22::Float64
        p23::Float64
        p24::Float64
        p25::Float64
        p26::Float64
        p27::Float64
        p28::Float64
        p29::Float64
        p30::Float64
        p31::Float64
        p32::Float64
        p33::Float64
        p34::Float64
        p35::Float64
        p36::Float64
        p37::Float64
        p38::Float64
        p39::Float64
        p40::Float64
        p41::Float64
        p42::Float64
        p43::Float64
        p44::Float64
        p45::Float64
        p46::Float64
        p47::Float64
        p48::Float64
        p49::Float64
        p50::Float64
        p51::Float64
        p52::Float64
        p53::Float64
        p54::Float64
        p55::Float64
        p56::Float64
        p57::Float64
        p58::Float64
        p59::Float64
        p60::Float64
        p61::Float64
        p62::Float64
        p63::Float64
        p64::Float64
        p65::Float64
        p66::Float64
        p67::Float64
        p68::Float64
        p69::Float64
        p70::Float64
        p71::Float64
        p72::Float64
        p81::Float64
        p82::Float64
        p83::Float64
        p84::Float64
        p85::Float64
    end

    # TODO: MEMOISE?
    function loadParameters(thresholdGenotype::Integer)

        fpParameters = normpath(joinpath(@__DIR__), "Phenologies", "Data", "Plants", "Parameters.tsv")

        @info "loading plant parameters (set @ $(thresholdGenotype)) from $(fpParameters)"

        column = thresholdGenotype + 1

        rawParameters = Dict( map(r -> (Symbol(r[1]) , Float64( r[column] )), CSV.File(fpParameters, delim="\t")) )

        # overriden parameters
        # - lifted verbatim from MATLAB phen.m 72 - 75
        
        rawParameters[:Phot_a] = 1;
        rawParameters[:Phot_b] = -0.4016;
        rawParameters[:Phot_c] = 2.7479;
        rawParameters[:Phot_n] = 3;

        # parameters

        Parameters(; rawParameters...)

    end

end # end: module: Plant

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

    # = Trapz
    # -- Trapezoidal integration library
    # -- (https://github.com/francescoalemanno/Trapz.jl)
    
    using Trapz

    # package
    
    import ..Simulation
    import ..Models
    import ..Environment
    import ..Clock

    # local
    
    import .Plant

    # implementation ----------------------------------------------------------

    #
    # ClockInput
    #

    abstract type ClockInput end

    struct ClockOutputAdapter{P <: Clock.DynamicsParameters} <: Models.Base 
        parameters::P
    end

    # functions

    function (a::ClockOutputAdapter)(clockOutput)::ClockInput
        error("Phenology.ClockOutputAdapter() please implement this abstract functor for your subtype")
    end

    #
    # Output
    # - phenology dynamics output data
    #

    struct Output <: Simulation.ModelData
        dailyThrm::Float64
        dailyThrmCumulative::Float64
        flowered::Bool
        FTArea::Float64
        S
    end

    # functions

    function hasFlowered(output::Union{Nothing, Output})::Bool

        # guard condition: output undefined

        if ( isnothing( output ) )

            return 0

        end

        # output defined
        
        return output.flowered

    end

    #
    # State
    # - clock dynamics state data
    #

    struct State <: Simulation.ModelData
        dailyThrmCumulative::Float64
        U
    end

    #
    # Dynamics
    # - abstract base type for phenology model dynamic behaviour
    #   i.e. the bit that performs the calculations
    #

    abstract type DynamicsParameters end

    struct Dynamics{P <: DynamicsParameters, Q <: Clock.DynamicsParameters} <: Models.Base 
        clockAdapter::ClockOutputAdapter{Q}
        parameters::P
    end

    # functions

    function (m::Dynamics)(
                du,                             # calculated matrix of next values
                u,                              # vector of values
                parameters::Tuple{Clock.Output, Environment.State},    
                                                # parameters for dynamics calculations
                t                               # time 
                )
        error("Phenology.Dynamics() please implement this abstract functor for your subtype")
    end

    function (m::Dynamics)(
                du,                             # calculated matrix of next values
                u,                              # vector of values
                parameters::Tuple{Clock.Output, Environment.State, Dict{Any,Any}},    
                                                # parameters for dynamics calculations
                t                               # time 
                )
        error("Phenology.Dynamics() please implement this abstract functor for your subtype")
    end

    #
    # Model
    #
    # Concrete implementation of Models.SimulationModel for plant phenology behaviour
    # 

    struct Model <: Models.SimulationModel

        environment::Environment.Model          # environment model
        plant::Plant.Parameters                 # plant model parameters
        phenologyDynamics::Dynamics             # phenology model behaviour
        key::String                             # model identifier
        tracing::Bool                           # flag: tracing enabled
        algorithm::AbstractODEAlgorithm         # ODE problem solver

        function Model(
                environment::Environment.Model,      
                plant::Plant.Parameters,
                dynamics::Dynamics,             
                key::String="model.phenology";
                # TODO: DO WE NEED A phenology dynamics id here so we know what's running?
                tracing::Bool=false,
                alg::Union{Nothing,AbstractODEAlgorithm}=nothing
                )

            algorithm = isnothing(alg) ? QNDF(autodiff=false) : alg

            new(environment, plant, dynamics, key, tracing, algorithm)

        end

    end

    # functions

    function (m::Model)(clockOutput::Clock.Output,
                        current::Simulation.Frame,
                        history::Vector{Simulation.Frame})

        # last times values

        previousFrame = history[end]

        previousState = Simulation.getState(previousFrame, m.key)
        
        # environment

        envState = m.environment(Simulation.day(current), Simulation.hour(current))

        # dynamics

        if (tracing(m))

            problem = ODEProblem(m.phenologyDynamics,
                                 previousState.U,
                                 (0.0, 24.0),
                                 (clockOutput, envState, Simulation.getTrace(current, m.key)))

        else
        
            problem = ODEProblem(m.phenologyDynamics,
                                 previousState.U,
                                 (0.0, 24.0),
                                 (clockOutput, envState))

        end

        solution = solve(problem, m.algorithm, reltol=1e-6)

        # mptu calculation (Daily Phenology Thrm)

        dailyFTArea = trapz(solution.t, solution[15,:]);

        # - photoperiod component

        mptuPhotoperiod = 
            m.plant.Phot_a + m.plant.Phot_b * m.plant.Phot_c ^ m.plant.Phot_n / 
                (m.plant.Phot_c ^ m.plant.Phot_n + dailyFTArea ^ m.plant.Phot_n);

        # - hourly components

        cumulativeVernalisation = 0.0

        dailyPhenThrm = 0.0

        for hour in 1:24

            envState = m.environment(Simulation.day(current), hour)

            # thermal component

            mptuThermal = _mptuThermal(m.plant, envState)

            # vernalisation component

            (mptuVernalization, cumulativeVernalisation) = 
                _mptuVernalization(m.plant, envState, cumulativeVernalisation)

            # modified photothermal unit

            mptu = mptuVernalization * mptuPhotoperiod * mptuThermal

            # cumulative mptu
            
            dailyPhenThrm = dailyPhenThrm + mptu

        end
        
        # state

        cumulativeDailyThrmLTV = 
            isnothing(previousState) ? 0.0 : previousState.dailyThrmCumulative

        cumulativeDailyThrm = dailyPhenThrm + cumulativeDailyThrmLTV
        
        state = State(cumulativeDailyThrm, solution[end])

        Simulation.setState(current, m.key, state)

        # output

        flowered = cumulativeDailyThrm > m.plant.Threshold

        # - output
        
        output = Output(dailyPhenThrm, cumulativeDailyThrm, flowered, dailyFTArea, solution)

        Simulation.setOutput(current, m.key, output)

        return output

    end

    function initialise(m::Model, fromState::State, initialFrame::Simulation.Frame)

        Simulation.setState(initialFrame, m.key, fromState)

    end

    function run(m::Union{Nothing, Model},
                 clockOutput::Clock.Output,
                 current::Simulation.Frame,
                 history::Vector{Simulation.Frame})::Union{Nothing, Output}

        # guard condition: phenology model not specified
        
        if ( isnothing(m) )

            return nothing

        end

        # run model

        m(clockOutput, current, history)

    end

    #
    # tracing
    #

    tracing(m::Model) = m.tracing 

    # functions (internal)

    function _mptuThermal(plant::Plant.Parameters, envState::Environment.State)

        lightFraction = Environment.light_fraction(envState)

        envTemperature = Environment.temperature(envState)

        unscaledThermals = (envTemperature - plant.Tb);

        thermals = 
            # daytime component
            max(0, (unscaledThermals * lightFraction)) +
            # nighttime component
            (max(0, (unscaledThermals * (1.0 - lightFraction))) * plant.Night)

        # mptu: thermal

        return thermals

    end

    function _mptuVernalization(plant::Plant.Parameters, env::Environment.State, cumulativeLTV::Float64)

        temp = Environment.temperature(env)

        # effective vernalization
        # - (vernalization: induction of plant's flowering process)

        effective = 0.0
            
        if ((temp >= plant.Tvmin) && (temp <= plant.Tvmax))

            effective = 
                exp(plant.v) * (temp - plant.Tvmin) ^ plant.m * (plant.Tvmax - temp) ^ plant.sigma * 1;

        end

        # cumulative vernalization hours

        cumulative = cumulativeLTV + effective

        # vernalization fraction

        vernalization = 1.0;

        if	cumulative <= plant.Vsat

            vernalization = plant.Fb + cumulative * (1.0 - plant.Fb) / plant.Vsat;

        end

        # mptu: vernalization
        
        return (vernalization, cumulative)
    end

    # exports
    
    export initialise, run

end # end: module: Phenology
