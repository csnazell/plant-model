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

end #end: for pp in [...]
