#                                                                              #
# Clock+PhenologyModel.jl                                                      #
#                                                                              #
# Simple simulation demonstrating PlantModelFramework.                         #
#                                                                              #
# Simulation runs clock model + associated PIF_CO_FT phenology model.          #
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
    
clockParameters = Clocks.F2014.COP1.parameters(clockGenotype)

clockBehaviour  = Clocks.F2014.COP1.dynamics(clockParameters)

# - phenology model

plantParameters       = Phenology.Plant.loadParameters(floweringGenotype)

phenologyClockAdapter = Phenologies.ClockAdapters.F2014.COP1.pifcoftAdapter(clockParameters)

phenologyParameters   = Phenologies.PIFCOFT.parameters(clockGenotype)

phenologyBehaviour    = Phenologies.PIFCOFT.dynamics(phenologyClockAdapter, phenologyParameters)

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

    plant = PlantModel(environment, clock, phenology)

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

    fpThrmDF = joinpath(fpData, "phenology-thrm-COP1+PIFCOFT-$(pp)-julia.tsv")
    
    CSV.write(fpThrmDF, thrmDataframe; delim='\t')

    @info "- thrm data written to \"$(fpThrmDF)\""

    println("- thrm data written to \"$(fpThrmDF)\"")
    
    # - plot
    
    plot(thrmDataframe.day, thrmDataframe.daily, 
            xlims=(1.0, Inf), label="daily", linecolor="blue", legend=true);

    plot!(twinx(), thrmDataframe.day, thrmDataframe.cumulative, 
            xlims=(1.0, Inf), linecolor="red", label="cumulative");

    fpThrmPlot = joinpath(fpPlots, "phenology-thrm-COP1+PIFCOFT-$(pp)-julia.svg")

    savefig(fpThrmPlot)

    @info "- thrm plots written to \"$(fpThrmDF)\""

    println("- thrm plots written to \"$(fpThrmDF)\"")

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

    fpFlwrDF = joinpath(fpData, "phenology-flwr-COP1+PIFCOFT-$(pp)-julia.tsv")
    
    CSV.write(fpFlwrDF, floweringDataframe; delim='\t')

    @info "- flowering data written to \"$(fpFlwrDF)\""

    println("- flowering data written to \"$(fpFlwrDF)\"")

    # - plot
    
    plot(floweringDataframe.day, floweringDataframe.flowered, 
         xlims=(1,Inf), xaxis="days", yaxis="flowered", linecolor="blue", label="flowered", legend=true);

    plot!(twinx(), floweringDataframe.day, floweringDataframe.FTArea, 
          xlims=(1,Inf), yaxis="FTArea", linecolor="red", label="FT area")

    fpFlwrPlot = joinpath(fpPlots, "phenology-flwr-COP1+PIFCOFT-$(pp)-julia.svg")

    savefig(fpFlwrPlot)

    @info "- flowering plots written to \"$(fpFlwrPlot)\""

    println("- flowering plots written to \"$(fpFlwrPlot)\"")

end #end: for pp in [...]
