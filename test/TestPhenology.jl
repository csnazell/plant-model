#                                                                              #
# TestPhenology.jl                                                             #
#                                                                              #
# Compare phenology output from examples/Clock+PhenologyModels.jl with MATLAB  #
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

fpTestOutput = mkpath("./test/output/JULIA/phenology-PIFCOFT")

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

#
# phenology
#
# - output phenology output
#

# test data

fpTestPhenology = joinpath(fpTest, "F2014-COP1-PIFCOFT-phenology.csv")

dfTest = DataFrame(CSV.File(fpTestPhenology))

photoPeriods = sort!( unique!( map(d -> floor(d), collect( dfTest.PP ) ) ) )

# output data

fpJuliaOutputs = map(pp -> joinpath(fpOutput, "phenology-COP1-PIFCOFT-$(pp)-julia.csv"), photoPeriods)

dfOutput = loadJuliaDF(fpJuliaOutputs)

# plots

for pp in photoPeriods

    dfTest_pp = filter(:PP => p -> (p == pp), dfTest)

    dfOutput_pp = filter(:PP => p -> (p == pp), dfOutput)

    plotParameters(pp, fpTestOutput, "phenology-output", dfTest_pp, dfOutput_pp, "D")

end
