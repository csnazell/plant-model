#                                                                              #
# Hypocotyl.jl                                                                 #
#                                                                              #
# Simple simulation demonstrating PlantModelFramework.                         #
#                                                                              #
# Extends behaviour of Clock+PhenologyModels.jl to add a "feature" model that  #
# calculates hypocotyl length based upon outputs from clock & phenology model. #
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

    plant = PlantModel(environment, clock, phenology, hypocotylLength)

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
    
    @info "thrmDataframe -> \"plots/phenology-thrm-$(pp)-julia.tsv\" " 
    CSV.write("plots/phenology-thrm-$(pp)-julia.tsv", thrmDataframe; delim='\t')
    
    # - plot
    
    plot(thrmDataframe.day, thrmDataframe.daily, 
            xlims=(1.0, Inf), label="daily", linecolor="blue", legend=true);
    plot!(twinx(), thrmDataframe.day, thrmDataframe.cumulative, 
            xlims=(1.0, Inf), linecolor="red", label="cumulative");

    title!("Phenology (COP1 + PIF_CO_FT) Thrm\n(photoperiod = $(pp)) (JULIA)") 

    @info "plot      -> \"plots/phenology-thrm-$(pp)-julia.svg\" " 
    savefig("plots/phenology-thrm-$(pp)-julia.svg")

    # flowering

    # - data frame
    #   (skip initial simulation frame since it's @ d=1 | t=0 & has no output)

    floweringValues = 
        map(((d, o),) -> (d, o.flowered, o.FTArea), 
            map(f -> ( Simulation.day(f), Simulation.getOutput(f, phenology.key) ),
                simulation[2:end]))

    floweringDataframe = 
        DataFrame( stack(floweringValues; dims=1), :auto)

    rename!(floweringDataframe, ["day", "flowered", "FTArea"])
    
    @info "floweringDataframe -> \"plots/phenology-flowering-$(pp)-julia.tsv\" " 
    CSV.write("plots/phenology-flowering-$(pp)-julia.tsv", floweringDataframe; delim='\t')

    # - plot
    
    plot(floweringDataframe.day, floweringDataframe.flowered, 
         xlims=(1,Inf), xaxis="days", yaxis="flowered", linecolor="blue", label="flowered", legend=true);
    plot!(twinx(), floweringDataframe.day, floweringDataframe.FTArea, 
          xlims=(1,Inf), yaxis="FTArea", linecolor="red", label="FT area")

    title!("Phenology (COP1 + PIF_CO_FT) Flowering\n(photoperiod = $(pp)) (JULIA)") 

    @info "plot      -> \"plots/phenology-flowering-$(pp)-julia.svg\" " 
    savefig("plots/phenology-flowering-$(pp)-julia.svg")

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

hypocotylDataframe = 
    DataFrame( stack(hypocotylObservations; dims=1), :auto)

rename!(hypocotylDataframe, ["day", "photoperiod", "length"])

# - data
    
@info "hypocotyl data -> \"plots/hypocotyl-data-julia.tsv\" " 
CSV.write("plots/hypocotyl-data-julia.tsv", hypocotylDataframe; delim='\t')

# - plots

plot(hypocotylDataframe.day, hypocotylDataframe.length, group = hypocotylDataframe.photoperiod)

@info "plot      -> \"plots/hypocotyl-length-julia.svg\" " 
savefig("plots/hypocotyl-length-julia.svg")

