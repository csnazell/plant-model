#                                                                              #
# OnlyClockModel.jl                                                            #
#                                                                              #
# Simple simulation demonstrating PlantModelFramework.                         #
#                                                                              #
# ...                                                                          #
#                                                                              #

# dependencies ----------------------------------------------------------------

# standard libraries

using Logging
using LoggingExtras

# third-party libraries

using PlantModelFramework

# package
# -

# implementation --------------------------------------------------------------

#
# set-up
#

# logging (@debug so we can see everything going on)

logger = FileLogger("clock+phenology-models.log")

global_logger(logger)

#
# construct model
#

# initial conditions

clockGenotype     = Set(["wt"])

floweringGenotype = 2

environment       = Environment.ConstantModel(sunset=8)

initialFrame = Simulation.Frame()

# clock model 

clockParameters = Clocks.F2014.COP1.parameters(clockGenotype)

clockBehaviour  = Clocks.F2014.COP1.dynamics(clockParameters)

clock           = Clock.Model(environment, clockBehaviour)

# - entrain model
# - starting conditions @ day 1 + hour 0 (prior to simulation start)

Clock.entrain(clock,
              Clocks.F2014.COP1.initialState(),
              initialFrame)

# phenology model

plantParameters       = Phenology.Plant.loadParameters(floweringGenotype)

phenologyClockAdapter = Phenologies.ClockAdapters.F2014.COP1.pifcoftAdapter(clockParameters)

phenologyParameters   = Phenologies.PIFCOFT.parameters(clockGenotype)

phenologyBehaviour    = Phenologies.PIFCOFT.dynamics(phenologyClockAdapter, phenologyParameters)

phenology             = Phenology.Model(environment, plantParameters, phenologyBehaviour)

# - configure phenology initial state

Phenology.initialise(phenology, Phenologies.PIFCOFT.initialState(), initialFrame)

# plant model

plant = PlantModel(environment, clock, phenology)

#
# run model
#

history = PlantModelFramework.run(plant, 90, initialFrame)

#
# analysis
#

# ???
