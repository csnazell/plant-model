#                                                                              #
# OnlyClockModel.jl                                                            #
#                                                                              #
# Simple simulation demonstrating PlantModelFramework.                         #
#                                                                              #
# For a selection of photoperiods run the COP1 clock model & output the        #
# interpolated result @ 24:00 from clock model output to dataframe & plot.     #
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
    
    plant = PlantModel(environment, clock)
    
    #
    # run model
    #
    
    simulation = PlantModelFramework.run(plant, 40, initialFrame)
    
    #
    # collecting & plotting interpolated clock values @ 2400 | 0000
    #
    
    # - dataframe
    
    clockValues_2400 = 
        map(f -> ( Simulation.getState(f, clock.key) ).U, simulation)
    
    dataframe = DataFrame( vcat(clockValues_2400...), :auto )
    
    rename!(dataframe, ["x$(i)" => "P$(i)" for i in 1:ncol(dataframe)])
    
    @info "dataframe -> \"states-$(pp)-julia.tsv\" " 
    CSV.write("states-$(pp)-julia.tsv", dataframe; delim='\t')
    
    # - plot
    #   clock has 35 parameters & we're mostly interested in the shape
    #   so legend is suppressed for the moment
    
    plot(Matrix(dataframe), legend=false);
    
    @info "plot      -> \"states-$(pp)-julia.svg\" " 
    savefig("states-$(pp)-julia.svg")

end #end: for pp in [...]
