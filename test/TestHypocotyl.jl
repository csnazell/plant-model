#                                                                              #
# TestHypocotyl.jl                                                             #
#                                                                              #
# Compare outputs from examples/Hypocotyl.jl with MATLAB baseline output in    #
# data/clock-COP1/hypocotyl-P2011/...                                          #
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

fpTest   = "./test/data/MATLAB/clock-COP1/hypocotyl-P2011"

fpTestOutput = mkpath("./test/output/JULIA/hypocotyl")

fpOutput = "./output/example/hypocotyl/data"

#
# Hypocotyl data
#

# test data

fpTestData = joinpath(fpTest, "hypocotyl-summary.tsv")

dfTest     = DataFrame(CSV.File(fpTestData; delim='\t'))

photoPeriods = sort!( unique!( map(d -> floor(d), collect( dfTest.photoperiod ) ) ) )

# output data

fpJuliaOutput = joinpath(fpOutput, "hypocotyl-summary-julia.tsv")

dfOutput      = DataFrame(CSV.File(fpJuliaOutput; delim='\t'))

# plots

dpi = 300.0

# - A4

width_px  = dpi * 8.27 
height_px =  dpi * 11.69 * 0.4 # < half-height A4

fpLengthsPlot = joinpath(fpTestOutput, "lengths-overview.svg")

# - plots

plots = []

for pp in photoPeriods

    dfTest_pp   = filter(:photoperiod => p -> (p == pp), dfTest)
    dfOutput_pp = filter(:photoperiod => p -> (p == pp), dfOutput)

    plt = plot(dfTest_pp.day, dfTest_pp.length, 
                linewidth=8, linestyle=:dash, 
                    legend=false, 
                        title="$(pp) hr photoperiod", titlefontsize=28)

    plot!(plt, dfOutput_pp.day, dfOutput_pp.length, linewidth=4)

    push!(plots, plt)

end

pltCombined = plot(plots..., layout=(2,2),size=(width_px, height_px))

savefig(pltCombined, fpLengthsPlot)
