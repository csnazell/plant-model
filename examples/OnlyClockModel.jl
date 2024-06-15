#                                                                              #
# OnlyClockModel.jl                                                            #
#                                                                              #
# Simple simulation demonstrating PlantModelFramework.                         #
#                                                                              #
# ...                                                                          #
#                                                                              #

# dependencies ----------------------------------------------------------------

using PlantModelFramework

# implementation --------------------------------------------------------------

#
# construct model
#

# initial conditions

clockGenotype     = ['wt']

floweringGenotype = 2

environment       = Environment.ConstantModel(sunset=8)

#plantParameters = load("parameter.mat") # ?? phenology only?

# clock model 

clockParameters = Clocks.F2014.COP1.parameters(clockGenotype)

clockBehaviour  = Clocks.F2014.COP1.dynamics(clockParameters)

clock           = Clock.Model(environment, clockBehaviour)

# - entrain model
# - starting conditions @ day 1 + hour 0 (prior to simulation start)

initialOutput = Frame()
initialState  = Frame()

Clock.entrain(clock,
              Clocks.F2014.initialState(),
              initialOutput,
              initialState)

# phenology model

#phenology = phenologyModel() # no-op

# plant model

#plant = plantModel(environment, clock, phenology)

#
# run model
#

# dfOutput, dfState = simulate(plant, days=90, initialOutput, initialState)

#
# analysis
#

# ???
