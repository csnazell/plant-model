# plant-model

A partial re-implementation of the Arabidopsis Framework Model v2 ([Github](https://github.com/danielseaton/frameworkmodel)) utilising Julia with a focus on flexibility and extensibility. 

Expresses a simulation as a set of models describing the circadian (clock) behavivour, plant phenology (based on clock), and "features" which are models that utilise the outputs from the configured models for clock, phenology or both.

Plant simulation state is recorded as a series of "frames" which the models utilise to record data and which can then be processed after the simulation.

## Installation

Implemented using Julia 1.10.x.

The Julia project provides a self-contained definition of the development environment and dependencies. 

Follow these steps to ensure the project environment & dependencies are fully satisfied and available:

1. clone this repo
2. cd into repo
3. enter julia repl
4. enter package manager
   - `]` 
5. activate project
   - `activate .` 
6. install plant model framework & dependencies
	- `dev PlantModelFramework`
7. install project space dependencies
	- `instantiate`

A simple simulation can be constructed & run as follows:

```julia
# dependencies

using PlantModelFramework

# simulation initial conditions
# - conditions @ T0
initialFrame = Simulation.Frame()

# - environment model
environment = Environment.ConstantModel(sunset=8)

# circadian (clock) model
# - configuration
clockParameters = Clocks.F2014.COP1.parameters(Set(["wt"]))
    
clockBehaviour  = Clocks.F2014.COP1.dynamics(clockParameters)

clock = Clock.Model(environment, clockBehaviour)

# - prepare clock model (initial conditions -> initial T0 frame)
Clock.entrain(clock, Clocks.F2014.COP1.initialState(), initialFrame)

# construct plant simulation
plant = PlantModel(clock)
    
# run simulation    
simulationResults = PlantModelFramework.run(plant, 40, initialFrame)

```

## Plant Simulations

[examples/](https://github.com/csnazell/plant-model/tree/main/examples) directory contains a number of scripts constructing example plant simulations & plotting output.

The scripts run simulations with example data output & plotting. All have debug logging enabled and are relatively verbose in terms of output to aid understanding.

### [examples/Clock.jl](https://github.com/csnazell/plant-model/blob/main/examples/Clock.jl)

40 day simulation utilising only a clock model (F2014_COP1).

### [examples/Clock+Phenology.jl](https://github.com/csnazell/plant-model/blob/main/examples/Clock%2BPhenology.jl))

90 day simulation (or until flowering occurs) utilising clock (F2014_COP1) & phenology (PIF_CO_FT) models. Replaces default QNDF differential equation solver with a RODAS5P solver

### [examples/Clock+Phenology+Tracing.jl](https://github.com/csnazell/plant-model/blob/main/examples/Clock%2BPhenology%2BTracing.jl)

Demonstrates tracing capabilities by recording phenology model data whilst simulation data in-flight. Generates a considerable amount of data.

### [examples/Hypocotyl.jl](https://github.com/csnazell/plant-model/blob/main/examples/Hypocotyl.jl)

Extends Clock+Phenology.jl with addition of a "Feature" model that simulates hypocotyl development based on outputs of phenology model.

## Diagrams

![Diagram illustrating hierarchy of components & how they are composed to build a plant simulation](/docs/simulation-structure.svg)

Simulation is constructed by creating a set of sub-models describing the circadian (clock) behaviour, the plant phenology behaviour (optional) and an optional number of plant "features". These models are then brought together into a plant model instance that manages the simulation process & retuns a history of the simulation behaviour expressed as data captured in a list of simulation "frames".

![Diagram illustrating hierarchy of types used by plant model](/docs/type-hierarchy.svg) 

Julia types used to implement plant simulation framework.
