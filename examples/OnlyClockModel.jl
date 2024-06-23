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

logger = FileLogger("only-clock-model.log")

global_logger(logger)

#
# construct model
#

# initial conditions

clockGenotype     = Set(["wt"])

floweringGenotype = 2

environment       = Environment.ConstantModel(sunset=8)

# clock model 

clockParameters = Clocks.F2014.COP1.parameters(clockGenotype)

clockBehaviour  = Clocks.F2014.COP1.dynamics(clockParameters)

clock           = Clock.Model(environment, clockBehaviour)

# - entrain model
# - starting conditions @ day 1 + hour 0 (prior to simulation start)

initialFrame = Simulation.Frame()

Clock.entrain(clock,
              Clocks.F2014.COP1.initialState(),
              initialFrame)

# plant model

plant = PlantModel(environment, clock)

#
# run model
#

history = PlantModelFramework.run(plant, 40, initialFrame)

#
# analysis
#

# ???
