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

initialFrane = Frame()

Clock.entrain(clock,
              Clocks.F2014.initialState(),
              initialFrame)

# phenology model

plantParameters       = Phenology.Plant.loadParameters(floweringGenotype)

phenologyClockAdapter = Phenologues.PIFCOFT.ClockAdapters.F2014.COP1.adapter(clockParameters)

phenologyParameters   = Phenologies.PIFCOFT.parameters(clockGenotype)

phenologyBehaviour    = Phenologies.PIFCOFT.dynamics(phenologyClockAdapter, phenologyParameters)

phenology             = Phenology.Model(environment, phenologyBehaviour)

# plant model

#plant = plantModel(environment, clock, phenology)

#
# run model
#

# dfOutput, dfState = run(plant, days=90, initialFrame)

#
# analysis
#

# ???
