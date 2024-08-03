#                                                                              #
# TestPhenology.jl                                                             #
#                                                                              #
# Compare phenology output from examples/Clock+Phenology.jl with MATLAB        #
# baseline in data/clock-COP1/phenology/...                                    #
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

fpTest   = "./test/data/MATLAB/clock-COP1/phenology"

fpTestOutput = mkpath("./test/output/JULIA/phenology")

fpOutput = "./output/example/clock+phenology/data"

#
# helper functions
#

function loadJuliaDF(fpDFs)

    outputDFs = []

    for fp in fpDFs
    
        try
    
            df = DataFrame(CSV.File(fp))
    
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

function plotClockInputs(pp, d, fpOutput, fnPrefix, dfTest, dfOutput)

    for name in filter(n -> !(n in ["PP", "D"]), names(dfTest))

        fn = replace(name, "." => "-")

        fpParamOutput = mkpath(joinpath(fpOutput, fn))

        fpPlot = joinpath(fpParamOutput, "$(fnPrefix)-$(pp)-$(d)-$(fn).svg")

        plot(dfTest[:,name], label="MATLAB", linewidth=2, linestyle= :dash)

        plot!(dfOutput[:,name], label="JULIA")

        savefig(fpPlot)

    end

end

function plotOverview(pp, fpOutput, fnPrefix, dfTest, dfOutput, x, layout, size=(500,400), titleMap=Dict())

    fpPlot = joinpath(fpOutput, "$(fnPrefix)-$(pp)-overview.svg")

    colNames  = filter(n -> !(n in ["PP", x]), names(dfTest))

    plots  = []

    for n in colNames

        title = get(titleMap, n, n)

        plt = plot(dfTest[:, x], dfTest[:,n], label="MATLAB", linewidth=8, linestyle= :dash, title=title, titlefontsize=28,
                   legend=false)
        plot!(plt, dfOutput[:, x], dfOutput[:,n], label="JULIA", linewidth=4)

        push!(plots, plt)

    end

    pltOverview = plot(plots..., layout=layout, size=size)

    savefig(pltOverview, fpPlot)

end

#
# phenology
#
# - output phenology data
#

# test data

fpTestPhenology = joinpath(fpTest, "F2014-COP1-PIFCOFT-phenology.csv")

dfTest = DataFrame(CSV.File(fpTestPhenology))

photoPeriods = sort!( unique!( map(d -> floor(d), collect( dfTest.PP ) ) ) )

# output data

fpJuliaOutputs = map(pp -> joinpath(fpOutput, "phenology-COP1-PIFCOFT-$(pp)-julia.csv"), photoPeriods)

dfOutput = loadJuliaDF(fpJuliaOutputs)

# plots

println("comparison data will be written to \"$(fpTestOutput)\" ")

dpi = 300.0

# - A4

width_px  = dpi * 8.27
height_px =  dpi * 11.69 * 0.5 # half-height A4

## - photoperiods

for pp in photoPeriods

    fpTestOutputPP = mkpath(joinpath(fpTestOutput, "PP-$(pp)"))

    dfTest_pp = filter(:PP => p -> (p == pp), dfTest)

    dfOutput_pp = filter(:PP => p -> (p == pp), dfOutput)

    plotParameters(pp, fpTestOutputPP, "phenology-output", dfTest_pp, dfOutput_pp, "D")

    titleMap = Dict("DayPhenThrm"=>"Photothermal Units (Day)", "CumPhenThrm"=>"Photothermal Units (Cumulative)")

    plotOverview(pp, fpTestOutputPP, "phenology", dfTest_pp, dfOutput_pp, "D", (2,2), (width_px, height_px), titleMap)

end

#
# clock inputs
#
# - output clock input values (mapped values from clock outputs)
#

# test data

fpTestClockInputs = joinpath(fpTest, "F2014-COP1-PIFCOFT-clock-inputs.csv")

dfTest = DataFrame(CSV.File(fpTestClockInputs))

photoPeriods = sort!( unique!( map(d -> floor(d), collect( dfTest.PP ) ) ) )

# output data

fpJuliaClockInputs = map(pp -> joinpath(fpOutput, "clock-inputs-COP1-PIFCOFT-$(pp)-julia.csv"), photoPeriods)

dfOutput = loadJuliaDF(fpJuliaClockInputs)

# plots

for pp in photoPeriods

    dfTest_pp = filter(:PP => p -> (p == pp), dfTest)

    days = sort!( unique!( map(d -> floor(d), collect( dfTest_pp.D ) ) ) )

    fpTestOutputClockInputs = mkpath(joinpath(fpTestOutput, "PP-$(pp)", "clock-inputs"))

    for day in days

        dfTest_pp_d = filter(:D => d -> (d == day), dfTest_pp)

        dfOutput_pp_d = filter([:PP,:D] => (p, d) -> ((p == pp) && (d == day)), dfOutput)

        plotClockInputs(pp, day, fpTestOutputClockInputs, "clock-inputs", dfTest_pp_d, dfOutput_pp_d)

    end

end

