#                                                                              #
# TestBenchmark.jl                                                             #
#                                                                              #
# Simulation for evaluating execution speed of hypocotyl simulation comparable #
# to that in the MATLAB codebase.                                              #
#                                                                              #
# Implemented as an importable function for use with BenchmarkTools.jl         #
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

# dependencies ----------------------------------------------------------------

# standard libraries
# - 

# third-party libraries
# - 

# local package
# -

# project
# -

# implementation --------------------------------------------------------------

function TestBenchmark()
    
    # initial conditions
    
    # - environment
    
    clockGenotype     = Set(["wt"])
    
    floweringGenotype = 2
        
    # - clock model 
        
    clockParameters = Clocks.F2014.COP1.parameters(clockGenotype)
    
    clockBehaviour  = Clocks.F2014.COP1.dynamics(clockParameters)
    
    # - phenology model
    
    plantParameters       = Phenology.Plant.loadParameters(floweringGenotype)
    
    phenologyClockAdapter = Phenologies.ClockAdapters.F2014.COP1.pifcoftAdapter(clockParameters)
    
    phenologyParameters   = Phenologies.PIFCOFT.parameters(clockGenotype)
    
    phenologyBehaviour    = Phenologies.PIFCOFT.dynamics(phenologyClockAdapter, phenologyParameters)
    
    # - hypocotyl model
    
    hypocotylParameters = Features.Hypocotyl.parameters(Features.Hypocotyl.P2011)
    
    hypocotylLength     = Features.Hypocotyl.Length(hypocotylParameters)
    
    #
    # run plant simulation with clock model for 40 days & output results for each 
    # photoperiod (pp)
    #
    
    hypocotylObservations = []
    
    for pp in [Integer(0), Integer(8), Integer(16)]
    
        @info "photoperiod = $(pp)"
    
        #
        # construct simulation components
        #
    
        # environment model
        
        environment = Environment.ConstantModel(sunset=pp)
        
        # clock model 
    
        clock = Clock.Model(environment, clockBehaviour)
    
        # - entrain model
        # - starting conditions @ day 1 + hour 0 (prior to simulation start)
    
        initialFrame = Simulation.Frame()
    
        Clock.entrain(clock, Clocks.F2014.COP1.initialState(), initialFrame)
    
        # phenology model
    
        phenology = Phenology.Model(environment, plantParameters, phenologyBehaviour)
    
        # - configure phenology initial state
    
        Phenology.initialise(phenology, Phenologies.PIFCOFT.initialState(), initialFrame)
    
        # compose plant model
    
        plant = PlantModel(clock, phenology, hypocotylLength)
    
        #
        # run model
        #
    
        simulation = PlantModelFramework.run(plant, 90, initialFrame)
    
    end #end: for pp in [...]

end
