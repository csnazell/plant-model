#                                                                              #
# TestClocks.jl                                                                #
#                                                                              #
# Compare clock state from examples/Clock.jl with MATLAB baseline output in    #
# data/clock-COP1/clock-only/...                                               #
#                                                                              #

# dependencies -----------------------------------------------------------------

# standard library

# - 

# third-party

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

fpTest   = "./test/data/MATLAB/clock-COP1/clock-only"

fpTestOutput = mkpath("./test/output/JULIA/clock-COP1")

fpOutput = "./output/example/onlyclock/data"

#
# helper functions
#

function loadJuliaDF(fpDFs)

    outputDFs = []

    for (pp, fp) in fpDFs
    
        try
    
            df = DataFrame(CSV.File(fp))
    
            periods = fill(pp, nrow(df))
    
            insertcols!(df, 1, :PP => periods)
    
            push!(outputDFs, df)
    
        catch e
    
            error("unable to load $(fp) output data")
    
        end
    
    end
    
    return vcat(outputDFs...)

end

function plotParameters(pp, fpOutput, fnPrefix, dfTest, dfOutput, x)

    for name in filter(n -> !(n in ["PP", x]), names(dfTest))

        fn = replace(name, "." => "-")

        fpPlot = joinpath(fpOutput, "$(fnPrefix)-$(pp)-$(fn).svg")

        plot(dfTest[:, x], dfTest[:,name], label="MATLAB", linewidth=2, linestyle= :dash)

        plot!(dfOutput[:, x], dfOutput[:,name], label="JULIA")

        savefig(fpPlot)

    end

end

function plotOverview(pp, fpOutput, fnPrefix, dfTest, dfOutput, x, layout, size=(500,400))

    fpPlot = joinpath(fpOutput, "$(fnPrefix)-$(pp)-overview.svg")

    colNames  = filter(n -> !(n in ["PP", x]), names(dfTest))

    plots  = []

    for n in colNames

        (_, _, title) = split(n, ".")

        plt = plot(dfTest[:, x], dfTest[:,n], label="MATLAB", linewidth=8, linestyle= :dash, title=title, titlefontsize=28,
                   legend=false)
        plot!(plt, dfOutput[:, x], dfOutput[:,n], label="JULIA", linewidth=4)

        push!(plots, plt)

    end

    pltOverview = plot(plots..., layout=layout, size=size)

    savefig(pltOverview, fpPlot)

end

#
# entrained output
#
# - output following entrainment step before model runs
# - frame[1] in Julia model
#

# test data

fpTestEntrained = joinpath(fpTest, "F2014-COP1-Output-Entrained.csv")

dfTest = DataFrame(CSV.File(fpTestEntrained))

photoPeriods = sort!( unique!( map(d -> floor(d), collect( dfTest.PP ) ) ) )

# output data

fpJuliaOutputs = map(pp -> (pp, joinpath(fpOutput, "output-entrained-$(pp)-julia.csv")), photoPeriods)

dfOutput = loadJuliaDF(fpJuliaOutputs)

# plots

dpi = 300.0

# - A4

width_px  = dpi * 8.27
height_px =  dpi * 11.69  

# - plot

for pp in photoPeriods

    fpEntrainedOutput = mkpath(joinpath(fpTestOutput, "PP-$(pp)", "entrained"))

    dfTest_pp = filter(:PP => p -> (p == pp), dfTest)

    dfOutput_pp = filter(:PP => p -> (p == pp), dfOutput)

    plotParameters(pp, fpEntrainedOutput, "entrained", dfTest_pp, dfOutput_pp, "T")

    plotOverview(pp, fpEntrainedOutput, "entrained", dfTest_pp, dfOutput_pp, "T", (9,4), (width_px, height_px))

end

#
# final output
#
# - output at end of simulation run
# - frame[end] in Julia model
#

# test data

fpTestFinal = joinpath(fpTest, "F2014-COP1-Output-Final.csv")

dfTest = DataFrame(CSV.File(fpTestFinal))

photoPeriods = sort!( unique!( map(d -> floor(d), collect( dfTest.PP ) ) ) )

# output data

fpJuliaOutputs = map(pp -> (pp, joinpath(fpOutput, "output-final-$(pp)-julia.csv")), photoPeriods)

dfOutput = loadJuliaDF(fpJuliaOutputs)

# plots

for pp in photoPeriods

    fpFinalOutput = mkpath(joinpath(fpTestOutput, "PP-$(pp)", "final"))

    dfTest_pp = filter(:PP => p -> (p == pp), dfTest)

    dfOutput_pp = filter(:PP => p -> (p == pp), dfOutput)

    plotParameters(pp, fpFinalOutput, "final-output", dfTest_pp, dfOutput_pp, "T")

    plotOverview(pp, fpFinalOutput, "final-output", dfTest_pp, dfOutput_pp, "T", (9,4), (width_px, height_px))

end

#
# state data
#
# - state Y | U values snapped @ 24hr interpolation from solution
# - initial state (@ 0) output of entrainment process
#

# test data

fpTestStates = joinpath(fpTest, "F2014-COP1-State-2400.csv")

dfTest = DataFrame(CSV.File(fpTestStates))

photoPeriods = sort!( unique!( map(d -> floor(d), collect( dfTest.PP ) ) ) )

# output data

fpJuliaOutputs = map(pp -> (pp, joinpath(fpOutput, "states-$(pp)-julia.csv")), photoPeriods)

dfOutput = loadJuliaDF(fpJuliaOutputs)

# plots

println("comparison data will be written to \"$(fpTestOutput)\" ")

for pp in photoPeriods

    fpStateOutput = mkpath(joinpath(fpTestOutput, "PP-$(pp)", "state"))

    dfTest_pp = filter(:PP => p -> (p == pp), dfTest)

    dfOutput_pp = filter(:PP => p -> (p == pp), dfOutput)

    plotParameters(pp, fpStateOutput, "state", dfTest_pp, dfOutput_pp, "D")

    plotOverview(pp, fpStateOutput, "state", dfTest_pp, dfOutput_pp, "D", (9,4), (width_px, height_px))

end
