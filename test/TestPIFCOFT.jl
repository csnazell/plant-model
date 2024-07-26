# dependencies -----------------------------------------------------------------

# standard library

# - 

# third-party

# command-line parsing
# https://github.com/zachmatson/ArgMacros.jl
using ArgMacros

# csv parsing
# https://github.com/JuliaData/CSV.jl
using CSV

# dataframes
# https://github.com/JuliaData/DataFrames.jl
using DataFrames

# plotting
# https://github.com/JuliaPlots/Plots.jl
using Plots

# implementation ---------------------------------------------------------------

#
# argument parsing
#

function parseArgs()

    args = 
    @tuplearguments begin
        @helpusage "TestPIFCOFT.jl [--pp=INT] [--start=DAY] [--stop=DAY]"
        @helpdescription """
        Plot comparison of PIFCOFT model tracing.
        """
        @argumentoptional Integer requiredPP "--pp"
        @argumentoptional Integer startDay "--start"
        @argumentoptional Integer stopDay "--stop"
    end

end

#
# helper functions
#

# julia data loading

function loadJuliaDF(fpDFs)

    outputDFs = []

    for fp in fpDFs
    
        try
    
            df = DataFrame( CSV.File(fp, header=false) )
    
            push!(outputDFs, df)
    
        catch e
    
            println("! unable to load $(fp) output data")
    
        end
    
    end
    
    return vcat(outputDFs...)

end

# plotting

function plotParameter(x, y, label, dfTest, dfOutput)

    plot!(dfTest[:,x], dfTest[:,y], label="$(label) (MATLAB)", linewidth=2, linestyle= :dash)

    plot!(dfOutput[:,x], dfOutput[:,y], label=label)

end

function plotParameters(fpPlotRoot, parameters, dfTest, dfOutput; filename="parameters")

    fpParameters = joinpath(fpPlotRoot, "$(filename).svg")

    plot()

    for (y, label) in parameters

        plotParameter(4, y, label, dfTest, dfOutput)

    end

    savefig(fpParameters)

end

function plotTime(fpPlotRoot, dfTest, dfOutput)

    fpTime = joinpath(fpPlotRoot, "time.svg")

    plot()

    plotParameter(4, 5, "modtime", dfTest, dfOutput)

    plotParameter(4, 6, "modtime-adv", dfTest, dfOutput)

    savefig(fpTime)

end

function plotLTV(fpPlotRoot, dfTest, dfOutput, parameterName; ylims=nothing)

    # optional y-limits

    limit = ""

    if isnothing(ylims)

        plot()

    else

        plot(ylim=ylims)

        limit = "-$(ylims[1])-$(ylims[2])-"

    end
    
    # filepath

    fpLTV = joinpath(fpPlotRoot, "$(parameterName)$(limit).svg")

    # plot
    
    plotParameter(4, 8, parameterName, dfTest, dfOutput)

    # save
    
    savefig(fpLTV)

end

function plotOutput(fpPlotRoot, dfTest, dfOutput, parameterName; ylims=nothing)

    # optional y-limits

    limit = ""

    if isnothing(ylims)

        plot()

    else

        plot(ylim=ylims)

        limit = "-$(ylims[1])-$(ylims[2])-"

    end
    
    # filepath

    fpLTV = joinpath(fpPlotRoot, "$(parameterName)$(limit).svg")

    # plot
    
    plotParameter(4, 7, parameterName, dfTest, dfOutput)

    # save
    
    savefig(fpLTV)

end

#
# parameter plotting
# - each function plots a particular parameter, unpacking available data from 
#   the supplied dataframes for MATLAB (Test) & Julia (Output) data
#

function plotPIF4m(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)

    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "PIF4m") )

    # dPIF4mdt entries:
    # 1   2    3  4     5        6                7      8      9
    # PP- day- ID time -------------------------  out -  lt --  parameters -----
    # pp, day, 1, time, modTime, modTimeAdvanced, du[1], PIF4m, EC_adv

    # time

    plotTime(fpPlotRoot, dfTest, dfOutput)

    # parameters

    plotParameters(fpPlotRoot, [(9, "EC_adv")], dfTest, dfOutput)

    # ltv

    plotLTV(fpPlotRoot, dfTest, dfOutput, "PIF4m")

    # output

    plotOutput(fpPlotRoot, dfTest, dfOutput, "dPIF4mdt")

end

function plotPIF5m(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)

    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "PIF5m") )

    # dPIF5mdt entries:
    # 1   2    3  4     5        6                7      8      9
    # PP- day- ID time -------------------------  out--  lt---  parameters------
    # pp, day, 2, time, modTime, modTimeAdvanced, du[2], PIF5m, EC_adv

    # time

    plotTime(fpPlotRoot, dfTest, dfOutput)

    # parameters

    plotParameters(fpPlotRoot, [(9, "EC_adv")], dfTest, dfOutput)

    # ltv

    plotLTV(fpPlotRoot, dfTest, dfOutput, "PIF5m")

    # output

    plotOutput(fpPlotRoot, dfTest, dfOutput, "dPIF5mdt")

end

function plotPIFdt(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)

    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "PIF") )
                        
    # dPIFdt entries:
    # 1   2    3  4     5        6                7      8    9      10     11
    # PP- day- ID time--------------------------  out -  lt   parameters--------
    # pp, day, 3, time, modTime, modTimeAdvanced, du[3], PIF, PIF5m, PIF4m, phyB

    # time

    plotTime(fpPlotRoot, dfTest, dfOutput)

    # parameters

    plotParameters(fpPlotRoot, [(9, "PIF5m"), (10, "PIF4m"), (11, "phyB")], dfTest, dfOutput)

    # ltv

    plotLTV(fpPlotRoot, dfTest, dfOutput, "PIF5m")

    # output

    plotOutput(fpPlotRoot, dfTest, dfOutput, "dPIF5mdt")

end

function plotPhyBdt(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)

    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "phyB") )
                        
    # dPhyBdt entries:
    # 1   2    3  4     5        6                7      8     9  10
    # PP- day- ID time -------------------------  out--  lt--  parameters-
    # pp, day, 4, time, modTime, modTimeAdvanced, du[4], phyB, L, PIF

    # time

    plotTime(fpPlotRoot, dfTest, dfOutput)

    # light

    plotParameters(fpPlotRoot, [(9, "L")], dfTest, dfOutput; filename="light")

    # parameters

    plotParameters(fpPlotRoot, [(10, "PIF")], dfTest, dfOutput)

    # ltv

    plotLTV(fpPlotRoot, dfTest, dfOutput, "phyB")

    # output

    plotOutput(fpPlotRoot, dfTest, dfOutput, "dphyBdt")

end

function plotPRdt(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)

    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "PR") )
                        
    # dPRdt entries:
    # 1   2    3  4     5        6                7      8   9
    # PP- day- ID time -------------------------  out--  lt  parameters -
    # pp, day, 5, time, modTime, modTimeAdvanced, du[5], PR, L

    # time

    plotTime(fpPlotRoot, dfTest, dfOutput)

    # light

    plotParameters(fpPlotRoot, [(9, "L")], dfTest, dfOutput; filename="light")

    # ltv

    plotLTV(fpPlotRoot, dfTest, dfOutput, "PR")

    # output

    plotOutput(fpPlotRoot, dfTest, dfOutput, "dPRdt")

end

function plotINTdt(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)

    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "INT") )
                        
    # dINTdt entries:
    # 1   2    3  4     5        6                7      8    9
    # PP- day- ID time -------------------------  out--- lt-- parameters--
    # pp, day, 6  time, modTime, modTimeAdvanced, du[6], INT, PR

    # time

    plotTime(fpPlotRoot, dfTest, dfOutput)

    # parameters

    plotParameters(fpPlotRoot, [(9, "PR")], dfTest, dfOutput)

    # ltv

    plotLTV(fpPlotRoot, dfTest, dfOutput, "INT")

    # output

    plotOutput(fpPlotRoot, dfTest, dfOutput, "dINTdt")

end

function plotIAA29mdt(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)

    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "IAA29m") )
                        
    # dIAA29dt entries:
    # 1   2    3  4     5        6                7      8       9
    # PP- day- ID time -------------------------  out--  lt----- parameters-
    # pp, day, 7, time, modTime, modTimeAdvanced, du[6], IAA29m, PIFact_1

    # time

    plotTime(fpPlotRoot, dfTest, dfOutput)

    # parameters

    plotParameters(fpPlotRoot, [(9, "PIFact_1")], dfTest, dfOutput)

    # ltv

    plotLTV(fpPlotRoot, dfTest, dfOutput, "IAA29m")

    # output

    plotOutput(fpPlotRoot, dfTest, dfOutput, "dIAA29mdt")

end

function plotATHB2mdt(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)

    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "ATHB2m") )
                        
    # dATHB2mdt entries:
    # 1   2    3  4     5        6                7      8       9
    # PP- day- ID time -------------------------  out--  lt----  parameters--
    # pp, day, 8, time, modTime, modTimeAdvanced, du[6], ATHB2m, PIFact_2

    # time

    plotTime(fpPlotRoot, dfTest, dfOutput)

    # parameters

    plotParameters(fpPlotRoot, [(9, "PIFact_2")], dfTest, dfOutput)

    # ltv

    plotLTV(fpPlotRoot, dfTest, dfOutput, "ATHB2m")

    # output

    plotOutput(fpPlotRoot, dfTest, dfOutput, "dATHB2mdt")

end

# - CO Model

function plotCDF1mdt(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)

    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "CDF1m") )
                        
    # dCDF1mdt entries:
    # 1   2    3  4     5        6                7      8      9    10    11    12    13
    # PP- day- ID time -------------------------  out--- lt---- parameters -----------------
    # pp, day, 9, time, modTime, modTimeAdvanced, du[9], CDF1m, LHY, PRR9, PRR7, PRR5, TOC1

    # time

    plotTime(fpPlotRoot, dfTest, dfOutput)

    # parameters

    plotParameters(fpPlotRoot, [(9, "LHY"), (10, "PRR9"), (11, "PRR7"), (12, "PRR5"), (13, "TOC1")], dfTest, dfOutput)

    # ltv

    plotLTV(fpPlotRoot, dfTest, dfOutput, "CDF1m")

    # output

    plotOutput(fpPlotRoot, dfTest, dfOutput, "dCDF1mdt")

end

function plotFKF1mdt(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)

    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "FKF1m") )
                        
    # dFKF1mdt entries:
    # 1   2    3   4     5        6                7       8      9  10   11
    # PP- day- ID  time -------------------------  out---- lt---- parameters-
    # pp, day, 10, time, modTime, modTimeAdvanced, du[10], FKF1m, L, LHY, EC
    
    # time

    plotTime(fpPlotRoot, dfTest, dfOutput)

    # light

    plotParameters(fpPlotRoot, [(9, "L")], dfTest, dfOutput; filename="light")

    # parameters

    plotParameters(fpPlotRoot, [(10, "LHY"), (11, "EC")], dfTest, dfOutput)

    # ltv

    plotLTV(fpPlotRoot, dfTest, dfOutput, "FKF1m")

    # output

    plotOutput(fpPlotRoot, dfTest, dfOutput, "dFKF1mdt")

end

function plotFKF1dt(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)

    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "FKF1") )
                        
    # dFKF1dt entries:
    # 1   2    3   4     5        6                7       8     9      10 11
    # PP- day- ID  time -------------------------  out---- lt--  parameters--
    # pp, day, 11, time, modTime, modTimeAdvanced, du[11], FKF1, FKF1m, L, GIn
    #
    # time

    plotTime(fpPlotRoot, dfTest, dfOutput)

    # light

    plotParameters(fpPlotRoot, [(10, "L")], dfTest, dfOutput; filename="light")

    # parameters

    plotParameters(fpPlotRoot, [(9, "FKF1m"), (11, "GIn")], dfTest, dfOutput)

    # ltv

    plotLTV(fpPlotRoot, dfTest, dfOutput, "FKF1")

    # output

    plotOutput(fpPlotRoot, dfTest, dfOutput, "dFKF1dt")

end

function plotCDF1dt(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)

    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "CDF1") )
                        
    # dCDF1dt entries:
    # 1   2    3   4     5        6                7       8     9      10    11
    # PP- day- ID  time -------------------------  out---- lt -  parameters ------
    # pp, day, 12, time, modTime, modTimeAdvanced, du[12], CDF1, CDF1m, FKF1, GIn

    # time

    plotTime(fpPlotRoot, dfTest, dfOutput)

    # parameters

    plotParameters(fpPlotRoot, [(9, "CDF1m"), (10, "FKF1"), (11, "GIn")], dfTest, dfOutput)

    # ltv

    plotLTV(fpPlotRoot, dfTest, dfOutput, "CDF1")

    # output

    plotOutput(fpPlotRoot, dfTest, dfOutput, "dCDF1dt")

end

function plotCOmdt(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)

    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "COm") )
                        
    # dCOmdt entries:
    # 1   2    3   4     5        6                7       8    9     10 11
    # PP- day- ID  time -------------------------  out---- lt-- parameters -----
    # pp, day, 13, time, modTime, modTimeAdvanced, du[13], COm, CDF1, L, COP1n_n

    # time

    plotTime(fpPlotRoot, dfTest, dfOutput)

    # light

    plotParameters(fpPlotRoot, [(10, "L")], dfTest, dfOutput; filename="light")

    # parameters

    plotParameters(fpPlotRoot, [(9, "CDF1"), (11, "COP1n_n")], dfTest, dfOutput)

    # ltv

    plotLTV(fpPlotRoot, dfTest, dfOutput, "COm")

    # output

    plotOutput(fpPlotRoot, dfTest, dfOutput, "dCOmdt")

end

function plotCOdt(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)

    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "CO") )
                        
    # dCOdt entries:
    # 1   2    3   4     5        6                7       8   9    10 11       12
    # PP- day- ID  time--------------------------  out---- lt- parameters ----------
    # pp, day, 14, time, modTime, modTimeAdvanced, du[14], CO, COm, L, COP1n_n, FKF1

    # time

    plotTime(fpPlotRoot, dfTest, dfOutput)

    # light

    plotParameters(fpPlotRoot, [(10, "L")], dfTest, dfOutput; filename="light")

    # parameters

    plotParameters(fpPlotRoot, [(9, "COm"), (11, "COP1n_n"), (12, "FKF1")], dfTest, dfOutput)

    # ltv

    plotLTV(fpPlotRoot, dfTest, dfOutput, "CO")

    plotLTV(fpPlotRoot, dfTest, dfOutput, "CO"; ylims=(-5,5))

    # output

    plotOutput(fpPlotRoot, dfTest, dfOutput, "dCOdt")

    plotOutput(fpPlotRoot, dfTest, dfOutput, "dCOdt"; ylims=(-5,5))

end

function plotFTmdt(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)

    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "FTm") )
                        
    # dFTmdt entries:
    # 1   2    3   4     5        6                7       8    9       10    11
    # PP- day- ID  time--------------------------  out---- lt-- parameters------
    # pp, day, 15, time, modTime, modTimeAdvanced, du[15], FTm, PIFtot, CDF1, CO

    # time

    plotTime(fpPlotRoot, dfTest, dfOutput)

    # parameters

    plotParameters(fpPlotRoot, [(9, "PIFtot"), (10, "CDF1"), (11, "CO")], dfTest, dfOutput)

    plotParameters(fpPlotRoot, [(9, "PIFtot"), (10, "CDF1")], dfTest, dfOutput; filename="parameters-wo-co")

    # ltv

    plotLTV(fpPlotRoot, dfTest, dfOutput, "FTm")

    plotLTV(fpPlotRoot, dfTest, dfOutput, "FTm"; ylims=(-5,5))

    # output

    plotOutput(fpPlotRoot, dfTest, dfOutput, "dFTmdt")

    plotOutput(fpPlotRoot, dfTest, dfOutput, "dFTmdt"; ylims=(-5,5))

end

# - other

function plotInducedC1dt(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)

    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "InducedC1") )
                        
    # dInducedC1dt entries:
    # 1   2    3   4     5        6                7       8          9
    # PP- day- ID  time--------------------------  out---  lt-------  parameters--
    # pp, day, 16, time, modTime, modTimeAdvanced, du[16], InducedC1, PIFact_3

    # time

    plotTime(fpPlotRoot, dfTest, dfOutput)

    # parameters

    plotParameters(fpPlotRoot, [(9, "PIFact_3")], dfTest, dfOutput)

    # ltv

    plotLTV(fpPlotRoot, dfTest, dfOutput, "InducedC1")

    # output

    plotOutput(fpPlotRoot, dfTest, dfOutput, "dInducedC1dt")

end

function plotInducedC2dt(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)

    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "InducedC2") )
                        
    # dInducedC2dt entries:
    # 1   2    3   4     5        6                7       8          9
    # PP- day- ID  time--------------------------  out --  lt ------  parameters -
    # pp, day, 17, time, modTime, modTimeAdvanced, du[17], InducedC2, PIFact_4

    # time

    plotTime(fpPlotRoot, dfTest, dfOutput)

    # parameters

    plotParameters(fpPlotRoot, [(9, "PIFact_4")], dfTest, dfOutput)

    # ltv

    plotLTV(fpPlotRoot, dfTest, dfOutput, "InducedC2")

    # output

    plotOutput(fpPlotRoot, dfTest, dfOutput, "dInducedC2dt")

end

function plotRepressedC1dt(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)

    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "RepressedC1") )
                        
    # dRepressedC1dt entries:
    # 1   2    3   4     5        6                7       8            9
    # PP- day- ID  time--------------------------  out---- lt---------- parameters-
    # pp, day, 18, time, modTime, modTimeAdvanced, du[18], RepressedC1, PIFact_5

    # time

    plotTime(fpPlotRoot, dfTest, dfOutput)

    # parameters

    plotParameters(fpPlotRoot, [(9, "PIFact_5")], dfTest, dfOutput)

    # ltv

    plotLTV(fpPlotRoot, dfTest, dfOutput, "RepressedC1")

    # output

    plotOutput(fpPlotRoot, dfTest, dfOutput, "dRepressedC1dt")

end

# - unknown function

function plotUnknown(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)
    println(" - unknown parameter: $(parameter)  @ day: $(day) in pp: $(pp)")
end

# - plot function dispatch based on ID

plotDispatch = Dict(# PIF model
                    1  => plotPIF4m,
                    2  => plotPIF5m,
                    3  => plotPIFdt,
                    4  => plotPhyBdt,
                    5  => plotPRdt,
                    6  => plotINTdt,
                    7  => plotIAA29mdt,
                    8  => plotATHB2mdt,
                    # CO model
                    9  => plotCDF1mdt,
                    10 => plotFKF1mdt,
                    11 => plotFKF1dt,
                    12 => plotCDF1dt,
                    13 => plotCOmdt,
                    14 => plotCOdt,
                    15 => plotFTmdt,
                    16 => plotInducedC1dt,
                    17 => plotInducedC2dt,
                    18 => plotRepressedC1dt
                   )

# main entry point -------------------------------------------------------------

# ensure base directories exist

fpTest   = "./test/data/MATLAB/clock-COP1/phenology"

fpTestOutput = mkpath("./test/output/JULIA/phenology-PIFCOFT/tracing")

fpOutput = "./output/example/clock+phenology/data"

# command-line arguments

args = parseArgs()

#
# phenology tracing
#
# - output PIFCOFT phenology model calculation tracing
#

# test data

fpTestTracing = joinpath(fpTest, "F2014-COP1-PIFCOFT-tracing.csv")

dfTest = DataFrame(CSV.File(fpTestTracing, header=false))

photoPeriodsTest = sort!( unique!( map(d -> floor(d), collect( dfTest[:,1] ) ) ) )

parameters   = sort!( unique!( map(p -> floor(p), collect( dfTest[:,3] ) ) ) )

# output data

fpJuliaTracing = map(pp -> joinpath(fpOutput, "phenology-tracing-COP1-PIFCOFT-$(pp)-julia.csv"), photoPeriodsTest)

dfOutput = loadJuliaDF(fpJuliaTracing)

photoPeriodsOutput = sort!( unique!( map(d -> floor(d), collect( dfOutput[:,1] ) ) ) )

# photoperiods

photoperiods = []

if ( !( isnothing(args.requiredPP) ) )

    photoperiods = 
        sort!( collect( intersect( Set(photoPeriodsTest), Set(photoPeriodsOutput), Set(args.requiredPP) ) ) )

else

    photoperiods = 
        sort!( collect( intersect( Set(photoPeriodsTest), Set(photoPeriodsOutput) ) ) )

end

# plots

for pp in photoperiods

    println("- processing photoperiod @ $(pp)")

    # common days in photoperiod pp

    # - common days

    daysTest   = Set( map(d -> floor(d), collect( ( filter(r -> r.Column1 == pp, dfTest) )[:, 2] ) ) )

    daysOutput = Set( map(d -> floor(d), collect( ( filter(r -> r.Column1 == pp, dfOutput) )[:, 2] ) ) )

    days = sort!( collect( intersect(daysTest, daysOutput) ) )

    # - restrict according to arguments

    if ( !( isnothing(args.stopDay) ) )

        days = filter(d -> d <= args.stopDay, days)

    end

    if ( !( isnothing(args.startDay) ) )

        days = filter(d -> d >= args.startDay, days)

    end

    # process days

    for day in days

        println("-- @ day $(day)")

        for parameter in parameters

            print(".")

            # chunk dataframes

            dfTest_pp_d_p   = 
                filter([:Column1, :Column2, :Column3] => (pd, dy, pt) -> ((pd == pp) && (dy == day) && (pt == parameter)), 
                       dfTest) 

            dfOutput_pp_d_p =
                filter([:Column1, :Column2, :Column3] => (pd, dy, pt) -> ((pd == pp) && (dy == day) && (pt == parameter)), 
                       dfOutput) 

            # dispatch

            plotFunc = get(plotDispatch, parameter,  plotUnknown)

            # plot
    
            plotFunc(pp, day, parameter, fpTestOutput, dfTest_pp_d_p, dfOutput_pp_d_p)

        end

        print("\n")

    end

end

println(" done .")
