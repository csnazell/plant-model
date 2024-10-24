#                                                                              #
# Clock+Phenology+Tracing.jl                                                   #
#                                                                              #
# Simulation demonstrating PlantModelFramework utilising a clock model &       #
# phenology model in conjunction.                                              #
#                                                                              #
# Simulation runs F2014 COP1 clock model + PIF_CO_FT phenology model.          #
#                                                                              #
# This simulation overrides the default QNDF solver with Rodas5P.              #
#                                                                              #
# Use test/TestPhenology.jl to further unpack data saved from this simulation  #
# & compare with reference MATLAB data from test/data/MATLAB.                  #
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

# - OrdinaryDiffEq
# -- Ordinary differential equation solvers + utilities
#    standalone sub-package of SciML / DifferentialEquations
# -- (https://github.com/SciML/OrdinaryDiffEq.jl)

using OrdinaryDiffEq

# - Plots.jl
# -- plotting library
# -- (https://github.com/JuliaPlots/Plots.jl)

using Plots

# local package

using PlantModelFramework
using PlantModelFramework: Clocks as PMFClocks # avoid clash with OrdinaryDiffEq

# project
# -

# implementation --------------------------------------------------------------

#
# set-up
#

# logging (@debug so we can see everything going on)

logger = FileLogger("clock+phenology-models.log")

global_logger(logger)

# ensure ./output/... exists
    
fpOutput = mkpath("./output/example/clock+phenology")
fpData   = mkpath( joinpath(fpOutput, "data") )
fpPlots  = mkpath( joinpath(fpOutput, "plots") )

# initial conditions

# - environment

clockGenotype     = Set(["wt"])

floweringGenotype = 2
    
# - clock model 
    
clockParameters = PMFClocks.F2014.COP1.parameters(clockGenotype)

clockBehaviour  = PMFClocks.F2014.COP1.dynamics(clockParameters)

# - phenology model

plantParameters       = Phenology.Plant.loadParameters(floweringGenotype)

phenologyClockAdapter = Phenologies.ClockAdapters.F2014.COP1.pifcoftAdapter(clockParameters)

phenologyParameters   = Phenologies.PIFCOFT.parameters(clockGenotype)

phenologyBehaviour    = Phenologies.PIFCOFT.dynamics(phenologyClockAdapter, phenologyParameters)

# - ODE solver

solver = Rodas5P(autodiff=false)

#
# run plant simulation with clock model for 40 days & output results for each 
# photoperiod (pp)
#

for pp in [Integer(0), Integer(8), Integer(16)]

    println("photoperiod = $(pp)")
    @info "photoperiod = $(pp)"

    #
    # construct simulation components
    #

    # environment model
    
    environment = Environment.ConstantModel(sunset=pp)
    
    # clock model 

    clock = Clock.Model(environment, clockBehaviour; alg=solver)

    # - entrain model
    # - starting conditions @ day 1 + hour 0 (prior to simulation start)

    initialFrame = Simulation.Frame()

    Clock.entrain(clock, 
                  PMFClocks.F2014.COP1.initialState(), 
                  initialFrame)

    # phenology model

    phenology = Phenology.Model(environment, plantParameters, phenologyBehaviour; alg=solver, tracing=true)

    # - configure phenology initial state

    Phenology.initialise(phenology, Phenologies.PIFCOFT.initialState(), initialFrame)

    # compose plant model

    plant = PlantModel(clock, phenology)

    #
    # run model
    #

    simulation = PlantModelFramework.run(plant, 90, initialFrame)

    #
    # collecting & plotting data of interest
    #

    # phenology

    # - data

    phenologyValues = 
        map(((d, h, o),) -> [pp, d, o.dailyThrm, o.dailyThrmCumulative, o.flowered, o.FTArea], 
            Simulation.getOutputs(simulation[2:end], phenology.key))

    phenologyDF = DataFrame( stack(phenologyValues; dims=1), :auto)

    rename!(phenologyDF, ["PP", "D", "DayPhenThrm", "CumPhenThrm", "Flowered", "FTArea"]) 

    fpPhenology = joinpath(fpData, "phenology-COP1-PIFCOFT-$(pp)-julia.csv")

    CSV.write(fpPhenology, phenologyDF)

    @info "- phenology data written to \"$(fpPhenology)\""

    println("- phenology data written to \"$(fpPhenology)\"")

    # - plot

    # -- thrm

    fpThrmPlot = joinpath(fpPlots, "phenology-COP1-PIFCOFT-thrm-$(pp)-julia.svg")
    
    plot(phenologyDF.D, phenologyDF.DayPhenThrm, 
            xlims=(1.0, Inf), label="daily", linecolor="blue", legend=true);

    plot!(twinx(), phenologyDF.D, phenologyDF.CumPhenThrm, 
            xlims=(1.0, Inf), linecolor="red", label="cumulative");

    savefig(fpThrmPlot)

    @info "- thrm plots written to \"$(fpThrmPlot)\""

    println("- thrm plots written to \"$(fpThrmPlot)\"")

    # -- flowering

    fpFlwrPlot = joinpath(fpPlots, "phenology-COP1-PIFCOFT-flwr-$(pp)-julia.svg")
    
    plot(phenologyDF.D, phenologyDF.Flowered, 
         xlims=(1,Inf), xaxis="days", yaxis="flowered", linecolor="blue", label="flowered", legend=true);

    plot!(twinx(), phenologyDF.D, phenologyDF.FTArea, 
          xlims=(1,Inf), yaxis="FTArea", linecolor="red", label="FT area")

    savefig(fpFlwrPlot)

    @info "- flowering plots written to \"$(fpFlwrPlot)\""

    println("- flowering plots written to \"$(fpFlwrPlot)\"")

    # model: clock inputs
    # - recalculate phenology clock input for a given clock model output & log
    # - skip initial frame as it's @ D1 T0

    dayDFs = []

    for (d, h, o) in Simulation.getOutputs(simulation[2:end], clock.key)

        i = phenologyClockAdapter(o)

        days = fill(d, length(i.EC))

        periods = fill(pp, length(i.EC))

        m = hcat(periods, days, i.EC, i.COP1n_n, i.LHY, i.PRR9, i.PRR7, i.PRR5, i.cP, i.GIn, i.TOC1)
    
        push!(dayDFs, DataFrame(m, :auto))

    end

    clockInputsDF = reduce(vcat, dayDFs)

    rename!(clockInputsDF, ["PP", "D", "EC", "COP1n_n", "LHY", "PRR9", "PRR7", "PRR5", "cP", "GIn", "TOC1"])

    fpClockInputs = joinpath(fpData, "clock-inputs-COP1-PIFCOFT-$(pp)-julia.csv")

    CSV.write(fpClockInputs, clockInputsDF)

    @info "- clock inputs written to \"$(fpClockInputs)\""

    println("- clock inputs written to \"$(fpClockInputs)\"")

end #end: for pp in [...]
