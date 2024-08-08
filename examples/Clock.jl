#                                                                              #
# Clock.jl                                                                     #
#                                                                              #
# Simulation demonstrating PlantModelFramework utilising just a clock model.   #
#                                                                              #
# Simulation runs F2014 COP1 clock model.                                      #
#                                                                              #
# This simulation uses the default QNDF solver.                                #
#                                                                              #
# Use test/TestClocks.jl to further unpack data saved from this simulation &   #
# compare with reference MATLAB data from test/data/MATLAB.                    # 
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

logger = FileLogger("only-clock-model.log")

global_logger(logger)

# initial conditions

# - environment

clockGenotype     = Set(["wt"])

floweringGenotype = 2
    
# - clock model 
    
clockParameters = Clocks.F2014.COP1.parameters(clockGenotype)
    
clockBehaviour  = Clocks.F2014.COP1.dynamics(clockParameters)

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

    Clock.entrain(clock,
                  Clocks.F2014.COP1.initialState(),
                  initialFrame)

    #
    # compose plant model
    #
    
    plant = PlantModel(clock)
    
    #
    # run model
    #
    
    simulation = PlantModelFramework.run(plant, 40, initialFrame)

    #
    # collecting & plotting clock values & state
    #

    clockParameters =
        ["LHYm", "LHYp", "CCA1m", "CCA1p", "P", "PRR9m", "PRR9p", "PRR7m", "PRR7p", 
         "PRR5m", "PRR5c", "PRR5n", "TOC1m", "TOC1n", "TOC1c", "ELF4m", "ELF4p", 
         "ELF4d", "ELF3m", "ELF3p", "ELF34", "LUXm", "LUXp", "COP1c", "COP1n", 
         "COP1d", "ZTL", "ZG", "Gim", "Gic", "Gin", "NOXm", "NOXp", "RVE8m", "RVE8p"]

    qualifiedClockParameters = map(p -> "F2014.COP1." * p, clockParameters)

    # - ensure ./output/ exists
    
    fpOutput = mkpath("./output/example/onlyclock")
    fpData   = mkpath( joinpath(fpOutput, "data") )
    fpPlots  = mkpath( joinpath(fpOutput, "plots") )

    # entrained output

    entrainedSol = ( Simulation.getOutput(simulation[1], clock.key) ).S

    entrainedDF = DataFrame(entrainedSol)
    
    rename!(entrainedDF, pushfirst!(copy(qualifiedClockParameters), "T"))

    fpEntrainedDF = joinpath(fpData, "output-entrained-$(pp)-julia.csv")
    
    CSV.write(fpEntrainedDF, entrainedDF)
    
    # final output

    lastSol = ( Simulation.getOutput(simulation[end], clock.key) ).S

    finalDF = DataFrame(lastSol)
    
    rename!(finalDF, pushfirst!(copy(qualifiedClockParameters), "T"))

    fpFinalDF = joinpath(fpData, "output-final-$(pp)-julia.csv")
    
    CSV.write(fpFinalDF, finalDF)

    # interpolated clock values @ 2400 | 0000 (state)
    
    # - dataframe
    
    clockValues_2400 = 
        map(f -> ( Simulation.getState(f, clock.key) ).U, simulation)
    
    dataframe = DataFrame( vcat(clockValues_2400...), :auto )

    rename!(dataframe, qualifiedClockParameters)
    
    days = map(((i, v),) -> floor(v) * (i - 1), enumerate(ones(length(clockValues_2400))))

    insertcols!(dataframe, 1, :D => days)

    fpDF = joinpath(fpData, "states-$(pp)-julia.csv")
    
    CSV.write(fpDF, dataframe)

    @info "- interpolated data written to \"$(fpDF)\""

    println("- interpolated data written to \"$(fpDF)\"")
    
    # - plot
    #   clock has 35 parameters & we're mostly interested in the shape
    #   so legend is suppressed for the moment

    fpPlot = joinpath(fpPlots, "states-$(pp)-julia.svg")
    
    subset = dataframe[:, 2:ncol(dataframe)]
    
    plot(dataframe.D, Matrix(subset), legend=false);

    title!("Interpolated Properties @ 2400")

    savefig(fpPlot)

    @info "- interpolated data plotted to \"$(fpPlot)\""

    println("- interpolated data plotted to \"$(fpPlot)\"")

end #end: for pp in [...]
