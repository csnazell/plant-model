# Environment Models
Provides a consistent and reproducible description of the state of the environment for a given time point. 

## Construction

### Components

None. The environment is a discrete functional unit. 

## Using An Environment Model

### Creating An Environment Model
An environment model is created by calling the appropriate constructor to create a model. 

Currently PlantModelFramework only contains a single, simple, environment model __ConstantModel__ which provides a mostly steady state environment allowing only for variations in the photoperiod. __ConstantModel__ can be configured with a number of keyword parameters outlined below. If none of these are supplied the returned environment model as a temperature of 22ºC, a photoperiod of 0 hours & a day duration of 24 hours.

#### Example

```julia
# - constant environment model
#   constructor arguments:
#   > temperature=##.# (degrees Celcius) | default = 22.0
#   > sunrise=#        (hour from 0000)     | default = 0
#   > sunset=#         (hour from 0000)     | default = 0         

environment = Environment.ConstantModel(sunset=8)

```

### Using An Environment Model

A description of the state of the environment is obtained by calling the environment model with arguments detailing the point in time. The returned state is a struct containing parameters describing the environment.

The state description can either be interrogated directly or via accessor functions.

```julia
struct State
    day::Int32              # timepoint day  : 0+
    hour::Int8              # timepoint hour : 1 - 24
    temperature::Float32    # temperature @ timepoint (ºC)
    sunrise::Int8           # hour of sunrise @ timepoint : 0 - 24
    sunset::Int8            # hour of sunrise @ timepoint : 0 - 24
    dayDuration::Int8       # duration of day (default: 24)
end
```

#### Example

```julia
# - state @ midday (1200) on Day 1

state = environment(1, 12)

# - time point at which state created:

timepoint_day = day(state)          # 1
timepoint_hour = hour(state)        # 12

# - duration of day

duration = dayDuration(state)       # 24

# - photoperiod

dawn = sunrise(state)               # 0

dusk = sunset(state)                # 8

pp   = photoperiod(state)           # 8

# - temperature

temp_celcius = temperature(state)   # 22.0 ºC
```

A number of utility functions also exist to support Clock (Circadian) & Phenology models. 

__light_fraction(state)__ models light intensity as square wave returning a value between 0.0 & 1.0 based on the photoperiod & hour the state represents. Currently this is used by the Phenology model to calculate daily photothermal units.

__light_condition(state, time)__ is a less simplistic model of light intensity returning a value between 0.0 & 1.0 based on the photoperiod & a time argument passed from the differential equation solver. Currently this is used in the F2014 clock models and the PIF_CO_FT phenology model.

## Creating A New Environment Model

TBD
