#                                                                              #
# Hypocotyl.jl                                                                 #
#                                                                              #
# Simulation extending Clock+Phenology.jl to add a "feature" model that        #
# calculates hypocotyl length based upon output from clock & phenology models. #
#                                                                              #
# Simulation runs F2014 COP1 clock model + PIF_CO_FT phenology model.          #
#                                                                              #
# This simulation uses the default QNDF solver.                                #
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

using Logging
using LoggingExtras

# third-party libraries

# - CSV.jl
# -- *SV parsing library
# -- (https://github.com/JuliaData/CSV.jl)

using CSV

# - DataFrames.jl
# -- in-memory tabular data
# -- (https://github.com/JuliaData/DataFrames.jl)

using DataFrames

# - Plots.jl
# -- plotting library
# -- (https://github.com/JuliaPlots/Plots.jl)

using Plots

# local package

using PlantModelFramework

# project
# -

# implementation --------------------------------------------------------------

#
# set-up
#

# logging (@debug so we can see everything going on)

logger = FileLogger("hypocotyl.log")

global_logger(logger)

# ensure ./output/ exists
    
fpOutput = mkpath("./output/example/hypocotyl")
fpData   = mkpath( joinpath(fpOutput, "data") )
fpPlots  = mkpath( joinpath(fpOutput, "plots") )

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

    println("photoperiod = $(pp)")
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

    #
    # collecting & plotting data of interest
    #

    # dailyThrm + dailyThrmCumulative
    
    # - data frame 
    #   (skip initial simulation frame since it's @ d=1 | t=0 & has no output)

    thrmValues = 
        map(((d, o),) -> [d, o.dailyThrm, o.dailyThrmCumulative], 
            map(f -> ( Simulation.day(f), Simulation.getOutput(f, phenology.key) ), 
                simulation[2:end]))

    thrmDataframe = DataFrame( stack(thrmValues; dims=1), :auto )
    
    rename!(thrmDataframe, ["day", "daily", "cumulative"])

    fpThrmDF = joinpath(fpData, "phenology-thrm-$(pp)-julia.tsv")

    CSV.write(fpThrmDF, thrmDataframe; delim='\t')
    
    @info "- thrm data written to \"$(fpThrmDF)\" "

    println("- thrm data written to \"$(fpThrmDF)\" ")
    
    # - plot

    fpThrmPlot = joinpath(fpPlots, "phenology-thrm-$(pp)-julia.svg")
    
    plot(thrmDataframe.day, thrmDataframe.daily, 
            xlims=(1.0, Inf), label="daily", linecolor="blue", legend=true);
    plot!(twinx(), thrmDataframe.day, thrmDataframe.cumulative, 
            xlims=(1.0, Inf), linecolor="red", label="cumulative");

    savefig(fpThrmPlot)
    
    @info "- thrm plots written to \"$(fpThrmPlot)\" "

    println("- thrm plots written to \"$(fpThrmPlot)\" ")

    # flowering

    # - data frame
    #   (skip initial simulation frame since it's @ d=1 | t=0 & has no output)

    fpFloweringDF = joinpath(fpData, "phenology-flowering-$(pp)-julia.tsv")

    floweringValues = 
        map(((d, o),) -> (d, o.flowered, o.FTArea), 
            map(f -> ( Simulation.day(f), Simulation.getOutput(f, phenology.key) ),
                simulation[2:end]))

    floweringDataframe = 
        DataFrame( stack(floweringValues; dims=1), :auto)

    rename!(floweringDataframe, ["day", "flowered", "FTArea"])
    
    CSV.write(fpFloweringDF, floweringDataframe; delim='\t')

    @info "- flowering data written to \"$(fpFloweringDF)\" "

    println("- flowering data written to \"$(fpFloweringDF)\" ")

    # - plot

    fpFloweringPlot = joinpath(fpPlots, "phenology-flowering-$(pp)-julia.svg")
    
    plot(floweringDataframe.day, floweringDataframe.flowered, 
         xlims=(1,Inf), xaxis="days", yaxis="flowered", linecolor="blue", label="flowered", legend=true);

    plot!(twinx(), floweringDataframe.day, floweringDataframe.FTArea, 
          xlims=(1,Inf), yaxis="FTArea", linecolor="red", label="FT area")

    savefig(fpFloweringPlot)

    @info "- flowering plots to \"$(fpFloweringPlot)\" "

    println("- flowering plots written to \"$(fpFloweringPlot)\" ")

    # collect hypocotyl lengths
    
    lengthValues = 
        map(((d, o),) -> (d, pp, o.length), 
            map(f -> (Simulation.day(f), Simulation.getOutput(f, hypocotylLength.key) ), 
                simulation[2:end]))


    append!(hypocotylObservations, lengthValues)

end #end: for pp in [...]

#
# hypocotyl data
#

fpSummaryDF = joinpath(fpData, "hypocotyl-summary-julia.tsv")

hypocotylDataframe = 
    DataFrame( stack(hypocotylObservations; dims=1), :auto)

rename!(hypocotylDataframe, ["day", "photoperiod", "length"])

# - data

CSV.write(fpSummaryDF, hypocotylDataframe; delim='\t')
    
@info "hypocotyl summary data written to \"$(fpSummaryDF)\" "

println("hypocotyl summary data written to \"$(fpSummaryDF)\" ")

# - plots

fpSummaryPlot = joinpath(fpPlots, "hypocotyl-summary-julia.svg")

plot(hypocotylDataframe.day, hypocotylDataframe.length, group = hypocotylDataframe.photoperiod)

savefig(fpSummaryPlot)
    
@info "hypocotyl summary plot written to \"$(fpSummaryPlot)\" "

println("hypocotyl summary plot written to \"$(fpSummaryPlot)\" ")

