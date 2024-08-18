#                                                                              #
# TestClock+Tracing.jl                                                         #
#                                                                              #
# Compare clock tracing output from examples/Clock+Tracing.jl with MATLAB      #
# baseline in data/clock-COP1/clock-only/...                                   #
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

# plotting

function plotParameters(fpPlotRoot, parameters, dfTest, dfOutput; filename="parameters")

    fpParameters = joinpath(fpPlotRoot, "$(filename).svg")

    plot()

    for (y, label) in parameters

        plot!(dfTest[:,4], dfTest[:,y], label="$(label) (MATLAB)", linewidth=2, linestyle= :dash)

        plot!(dfOutput[:,4], dfOutput[:,y], label=label)

    end

    savefig(fpParameters)

end

#
# parameter plotting
# - each function plots a particular parameter, unpacking available data from 
#   the supplied dataframes for MATLAB (Test) & Julia (Output) data
#

function plotLHYm(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)
   
    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "LHYm") )

    # dLHYm entries:
    # 1  2   3    4     5      6     7               8    9
    # ID PP, day- time- out--- lt--- parameters----- constants
    # 1, PP, day, time, du[1], LHYm, LC,             r11, m1

    # output

    plotParameters(fpPlotRoot, [(5, "dLHYmdt")], dfTest, dfOutput; filename="output")

    # ltv

    plotParameters(fpPlotRoot, [(6, "LHYm")], dfTest, dfOutput; filename="ltv")

    # parameters

    plotParameters(fpPlotRoot, [(7, "LC")], dfTest, dfOutput; filename="parameters")

    # constants

    plotParameters(fpPlotRoot, [(8, "r11"), (9, "m1")], dfTest, dfOutput; filename="constants")

end

function plotLHYp(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)
   
    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "LHYm") )

    # dLHYp entries:
    # 1  2   3    4     5      6     7  8  9         10, 11
    # ID PP, day- time- out--- lt--- parameters----- constants
    # 2, PP, day, time, du[2], LHYp, L, D, LHYm,     m4, m3

    # output

    plotParameters(fpPlotRoot, [(5,"dLHYpdt")], dfTest, dfOutput; filename="output")

    # ltv

    plotParameters(fpPlotRoot, [(6,"LHYp")], dfTest, dfOutput; filename="ltv")

    # parameters

    plotParameters(fpPlotRoot, [(7,"L"),(8,"D"),(9,"LHYm")], dfTest, dfOutput; filename="parameters")

    # constants

    plotParameters(fpPlotRoot, [(10,"m4"),(11,"m3")], dfTest, dfOutput; filename="constants")

end

function plotCCA1m(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)
   
    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "CCA1m") )

    # dCCA1m entries:
    # 1  2   3    4     5      6      7               8
    # ID PP, day- time- out--- lt---- parameters----- constants
    # 3, PP, day, time, du[3], CCA1m, LCcommon,       m1

    # output

    plotParameters(fpPlotRoot, [(5, "dCCA1mdt")], dfTest, dfOutput; filename="output")

    # ltv

    plotParameters(fpPlotRoot, [(6, "CCA1m")], dfTest, dfOutput; filename="ltv")

    # parameters

    plotParameters(fpPlotRoot, [(7, "LCcommon")], dfTest, dfOutput; filename="parameters")

    # constants

    plotParameters(fpPlotRoot, [(8, "m1")], dfTest, dfOutput; filename="constants")

end

function plotCCA1p(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)
   
    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "CCA1p") )

    # dCCA1p entries:
    # 1  2   3    4     5      6      7  8  9         10  11
    # ID PP, day- time- out--- lt---- parameters----- constants
    # 4, PP, day, time, du[4], CCA1p, L, D, CCA1m,    m4, m3

    # output

    plotParameters(fpPlotRoot, [(5, "dCCA1pdt")], dfTest, dfOutput; filename="output")

    # ltv

    plotParameters(fpPlotRoot, [(6, "CCA1p")], dfTest, dfOutput; filename="ltv")

    # parameters

    plotParameters(fpPlotRoot, [(7, "L"), (8,"D"), (9,"CCA1m")], dfTest, dfOutput; filename="parameters")

    # constants

    plotParameters(fpPlotRoot, [(10, "m4"), (11, "m3")], dfTest, dfOutput; filename="constants")

end

function plotP(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)
   
    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "P") )

    # dP entries:
    # 1  2   3    4     5      6     7      8        9   10
    # ID PP, day- time- out--- lt--- parameters----- constants
    # 5, PP, day, time, du[5], P,    BlueD, BlueL,   p7, m11

    # output

    plotParameters(fpPlotRoot, [(5, "dPdt")], dfTest, dfOutput; filename="output")

    # ltv

    plotParameters(fpPlotRoot, [(6, "P")], dfTest, dfOutput; filename="ltv")

    # parameters

    plotParameters(fpPlotRoot, [(7, "BlueD"), (8, "BlueL")], dfTest, dfOutput; filename="parameters")

    # constants

    plotParameters(fpPlotRoot, [(9, "p7"), (10, "m11")], dfTest, dfOutput; filename="constants")

end

function plotPRR9m(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)
   
    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "PRR9m") )

    # dPRR9m entries:
    # 1  2   3    4     5      6      7  8  9      10  11  12     13     14  15   16  17   18  19  20  21
    # ID PP, day- time- out--- lt---- parameters------------------------ constants------------------------
    # 6, PP, day, time, du[6], PRR9m, P, L, RVE8p, LC, EC, TOC1n, PRR5n, q3, m12, a3, r33, r5, r6, r7, r40

    # output

    plotParameters(fpPlotRoot, [(5, "dPRR9mdt")], dfTest, dfOutput; filename="output")

    # ltv

    plotParameters(fpPlotRoot, [(6, "PRR9m")], dfTest, dfOutput; filename="ltv")

    # parameters

    plotParameters(fpPlotRoot, [(7, "P"),(8, "L"),(9, "RVE8p"),(10, "LC"),(11, "EC"), (12, "TOC1n"), (13, "PRR5n")], dfTest, dfOutput; filename="parameters")

    # constants

    plotParameters(fpPlotRoot, [(14, "q3"), (15, "m12"), (16, "a3"), (17, "r33"), (18, "r5"), (19, "r6"), (20, "r7"), (21, "r40")], dfTest, dfOutput; filename="constants")

end

function plotPRR9p(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)
   
    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "PRR9p") )

    # dPRR9p entries:
    # 1  2   3    4     5      6      7               8 
    # ID PP, day- time- out--- lt---- parameters----- constants
    # 7, PP, day, time, du[7], PRR9p, PRR9m           m13

    # output

    plotParameters(fpPlotRoot, [(5, "dPRR9pdt")], dfTest, dfOutput; filename="output")

    # ltv

    plotParameters(fpPlotRoot, [(6, "PRR9p")], dfTest, dfOutput; filename="ltv")

    # parameters

    plotParameters(fpPlotRoot, [(7, "PRR9m")], dfTest, dfOutput; filename="parameters")

    # constants

    plotParameters(fpPlotRoot, [(8, "m13")], dfTest, dfOutput; filename="constants")

end

function plotPRR7m(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)
   
    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "PRR7m") )

    # dPRR7m entries:
    # 1  2   3    4     5      6      7   8   9      10     11  12  13   14   15
    # ID PP, day- time- out--- lt---- parameters----------- constants------------
    # 8, PP, day, time, du[8], PRR7m, LC, EC, TOC1n, PRR5n, r8, r9, r10, r40, m14

    # output

    plotParameters(fpPlotRoot, [(5, "dPRR7mdt")], dfTest, dfOutput; filename="output")

    # ltv

    plotParameters(fpPlotRoot, [(6, "PRR7m")], dfTest, dfOutput; filename="ltv")

    # parameters

    plotParameters(fpPlotRoot, [(7, "LC"), (8, "EC"), (9, "TOC1n"), (10, "PRR5n")], dfTest, dfOutput; filename="parameters")

    # constants

    plotParameters(fpPlotRoot, [(11, "r8"), (12, "r9"), (13, "r10"), (14, "r40"), (15, "m14")], dfTest, dfOutput; filename="constants")

end

function plotPRR7p(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)
   
    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "PRR7p") )

    # dPRR7p entries:
    # 1  2   3    4     5      6      7      8   9
    # ID PP, day- time- out--- lt---- parameters constants
    # 9, PP, day, time, du[9], PRR7p, PRR7m, D   m15, m23

    # output

    plotParameters(fpPlotRoot, [(5, "dPRR7pdt")], dfTest, dfOutput; filename="output")

    # ltv

    plotParameters(fpPlotRoot, [(6, "PRR7p")], dfTest, dfOutput; filename="ltv")

    # parameters

    plotParameters(fpPlotRoot, [(7, "PRR7m"), (8, "D")], dfTest, dfOutput; filename="parameters")

    # constants

    plotParameters(fpPlotRoot, [(9, "m15"), (10, "m23")], dfTest, dfOutput; filename="constants")

end

function plotPRR5m(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)
   
    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "PRR5m") )

    # dPRR5m entries:
    # 1   2   3    4     5       6      7      8   9   10     11  12   13   14   15   16 
    # ID  PP, day- time- out---- lt---  parameters----------- constants------------------
    # 10, PP, day, time, du[10], PRR5m, RVE8p, LC, EC, TOC1n, a4, r34, r12, r13, r14, m16

    # output

    plotParameters(fpPlotRoot, [(5, "dPRR5mdt")], dfTest, dfOutput; filename="output")

    # ltv

    plotParameters(fpPlotRoot, [(6, "PRR5m")], dfTest, dfOutput; filename="ltv")

    # parameters

    plotParameters(fpPlotRoot, [(7, "RVE8p"), (8, "LC"), (9, "EC"), (10, "TOC1n")], dfTest, dfOutput; filename="parameters")

    # constants

    plotParameters(fpPlotRoot, [(11, "a4"), (12, "r34"), (13, "r12"), (14, "r13"), (15, "r14"), (16, "m16")], dfTest, dfOutput; filename="constants")

end

function plotPRR5c(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)
   
    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "PRR5c") )

    # dPRR5c entries:
    # 1   2   3    4     5       6      7      8    9        10   11
    # ID  PP, day- time- out---- lt---- parameters---------- constants
    # 11, PP, day, time, du[11], PRR5c, PRR5m, ZTL, P5trans, m17, m24

    # output

    plotParameters(fpPlotRoot, [(5, "dPRR5cdt")], dfTest, dfOutput; filename="output")

    # ltv

    plotParameters(fpPlotRoot, [(6, "PRR5c")], dfTest, dfOutput; filename="ltv")

    # parameters

    plotParameters(fpPlotRoot, [(7, "PRR5m"), (8, "ZTL"), (9, "P5trans")], dfTest, dfOutput; filename="parameters")

    # constants

    plotParameters(fpPlotRoot, [(10, "m17"), (11, "m24")], dfTest, dfOutput; filename="constants")

end

function plotPRR5n(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)
   
    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "PRR5n") )

    # dPRR5n entries:
    # 1   2   3    4     5       6      7          8
    # ID- PP, day- time- out---- lt---- parameters constants
    # 12, PP, day, time, du[12], PRR5n, P5trans,   m42

    # output

    plotParameters(fpPlotRoot, [(5, "dPRR5ndt")], dfTest, dfOutput; filename="output")

    # ltv

    plotParameters(fpPlotRoot, [(6, "PRR5n")], dfTest, dfOutput; filename="ltv")

    # parameters

    plotParameters(fpPlotRoot, [(7, "P5trans")], dfTest, dfOutput; filename="parameters")

    # constants

    plotParameters(fpPlotRoot, [(8, "m42")], dfTest, dfOutput; filename="constants")

end

function plotTOC1m(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)
   
    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "TOC1m") )

    # dTOC1m entries:
    # 1   2   3    4     5       6      7      8   9   10     11  12   13   14   15   16
    # ID- PP, day- time- out---- lt---- parameters----------- constants ----------------
    # 13, PP, day, time, du[13], TOC1m, RVE8p, LC, EC, TOC1n, a5, r35, r15, r16, r17, m5

    # output

    plotParameters(fpPlotRoot, [(5, "dTOC1mdt")], dfTest, dfOutput; filename="output")

    # ltv

    plotParameters(fpPlotRoot, [(6, "TOC1m")], dfTest, dfOutput; filename="ltv")

    # parameters

    plotParameters(fpPlotRoot, [(7, "RVE8p"), (8, "LC"), (9, "EC"), (10, "TOC1n")], dfTest, dfOutput; filename="parameters")

    # constants

    plotParameters(fpPlotRoot, [(11, "a5"), (12, "r35"), (13, "r15"), (14, "r16"), (15, "r17"), (16, "m5")], dfTest, dfOutput; filename="constants")

end

function plotTOC1n(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)
   
    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "TOC1n") )

    # dTOC1n entries:
    # 1   2   3    4     5       6      7       8       9    10
    # ID  PP, day- time- out---- lt---  parameters----- constants
    # 14, PP, day, time, du[14], TOC1n, Ttrans, PRR5n,  m43, m38

    # output

    plotParameters(fpPlotRoot, [(5, "dTOC1ndt")], dfTest, dfOutput; filename="output")

    # ltv

    plotParameters(fpPlotRoot, [(6, "TOC1n")], dfTest, dfOutput; filename="ltv")

    # parameters

    plotParameters(fpPlotRoot, [(7, "Ttrans"), (8, "PRR5n")], dfTest, dfOutput; filename="parameters")

    # constants

    plotParameters(fpPlotRoot, [(9, "m43"), (10, "m38")], dfTest, dfOutput; filename="constants")

end

function plotTOC1c(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)
   
    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "TOC1c") )

    # dTOC1c entries:
    # 1   2   3    4     5       6      7      8    9       10  11
    # ID  PP  day  time  out---  lt---  parameters--------  constants
    # 15, PP, day, time, du[15], TOC1c, TOC1m, ZTL, Ttrans, m8, m6

    # output

    plotParameters(fpPlotRoot, [(5, "dTOC1cdt")], dfTest, dfOutput; filename="output")

    # ltv

    plotParameters(fpPlotRoot, [(6, "TOC1c")], dfTest, dfOutput; filename="ltv")

    # parameters

    plotParameters(fpPlotRoot, [(7, "TOC1m"), (8, "ZTL"), (9, "Ttrans")], dfTest, dfOutput; filename="parameters")

    # constants

    plotParameters(fpPlotRoot, [(10, "m8"), (11, "m6")], dfTest, dfOutput; filename="constants")

end

function plotELF4m(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)
   
    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "ELF4m") )

    # dELF4m entries:
    # 1   2   3    4     5       6      7      8   9   10     11  12   13   14   15   16
    # ID  PP, day  time  out---  lt---  parameters----------  constants-----------------
    # 16, PP, day, time, du[16], ELF4m, RVE8p, EC, LC, TOC1n, a6, r36, r18, r19, r20, m7

    # output

    plotParameters(fpPlotRoot, [(5, "dELF4mdt")], dfTest, dfOutput; filename="output")

    # ltv

    plotParameters(fpPlotRoot, [(6, "ELF4m")], dfTest, dfOutput; filename="ltv")

    # parameters

    plotParameters(fpPlotRoot, [(7, "RVE8p"), (8, "EC"), (9, "LC"), (10, "TOC1n")], dfTest, dfOutput; filename="parameters")

    # constants

    plotParameters(fpPlotRoot, [(11, "a6"), (12, "r36"), (13, "r18"), (14, "r19"), (15, "r20"), (16, "m7")], dfTest, dfOutput; filename="constants")

end

function plotELF4p(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)
   
    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "ELF4p") )

    # dELF4p entries:
    # 1   2   3    4     5       6      7          8    9
    # ID  PP, day  time- out---  lt---  parameters constants
    # 17, PP, day, time, du[17], ELF4p, ELF4m,     p23, m35

    # output

    plotParameters(fpPlotRoot, [(5, "dELF4pdt")], dfTest, dfOutput; filename="output")

    # ltv

    plotParameters(fpPlotRoot, [(6, "ELF4p")], dfTest, dfOutput; filename="ltv")

    # parameters

    plotParameters(fpPlotRoot, [(7, "ELF4m")], dfTest, dfOutput; filename="parameters")

    # constants

    plotParameters(fpPlotRoot, [(8, "p23"), (9, "m35")], dfTest, dfOutput; filename="constants")

end

function plotELF4d(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)
   
    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "ELF4d") )

    # dELF4d entries:
    # 1   2   3    4     5       6      7      8        9
    # ID  PP, day  time  out---  lt---  parameters----  constants
    # 18, PP, day, time, du[18], ELF4d, ELF4p, E34prod, m36

    # output

    plotParameters(fpPlotRoot, [(5, "dELF4ddt")], dfTest, dfOutput; filename="output")

    # ltv

    plotParameters(fpPlotRoot, [(6, "ELF4d")], dfTest, dfOutput; filename="ltv")

    # parameters

    plotParameters(fpPlotRoot, [(7, "ELF4p"), (8, "E34prod")], dfTest, dfOutput; filename="parameters")

    # constants

    plotParameters(fpPlotRoot, [(9, "m36")], dfTest, dfOutput; filename="constants")

end

function plotELF3m(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)
   
    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "ELF3m") )

    # dELF3m entries:
    # 1   2   3    4     5       6      7               8    9
    # ID  PP, day  time  out---  lt---  parameters----- constants
    # 19, PP, day, time, du[19], ELF3m, LC,             r21, m26

    # output

    plotParameters(fpPlotRoot, [(5, "dELF3mdt")], dfTest, dfOutput; filename="output")

    # ltv

    plotParameters(fpPlotRoot, [(6, "ELF3m")], dfTest, dfOutput; filename="ltv")

    # parameters

    plotParameters(fpPlotRoot, [(7, "LC")], dfTest, dfOutput; filename="parameters")

    # constants

    plotParameters(fpPlotRoot, [(8, "r21"), (9, "m26")], dfTest, dfOutput; filename="constants")

end

function plotELF3p(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)
   
    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "ELF3p") )

    # dELF3p entries:
    # 1   2   3    4     5       6      7      8        9      10
    # ID  PP, day  time  out---  lt---  parameters-----------  constants
    # 20, PP, day, time, du[20], ELF3p, ELF3m, E34prod, E3deg, p16

    # output

    plotParameters(fpPlotRoot, [(5, "dELF3pdt")], dfTest, dfOutput; filename="output")

    # ltv

    plotParameters(fpPlotRoot, [(6, "ELF3p")], dfTest, dfOutput; filename="ltv")

    # parameters

    plotParameters(fpPlotRoot, [(7, "ELF3m"), (8, "E34prod"), (9, "E3deg")], dfTest, dfOutput; filename="parameters")

    # constants

    plotParameters(fpPlotRoot, [(10, "p16")], dfTest, dfOutput; filename="constants")

end

function plotELF34(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)
   
    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "ELF34") )

    # dLHYm entries:
    # 1   2   3    4     5       6      7        8      9
    # ID  PP, day  time  out---  lt---  parameters----  constants
    # 21, PP, day, time, du[21], ELF34, E34prod, E3deg, m22

    # output

    plotParameters(fpPlotRoot, [(5, "dELF34dt")], dfTest, dfOutput; filename="output")

    # ltv

    plotParameters(fpPlotRoot, [(6, "ELF34")], dfTest, dfOutput; filename="ltv")

    # parameters

    plotParameters(fpPlotRoot, [(7, "E34prod"), (8, "E3deg")], dfTest, dfOutput; filename="parameters")

    # constants

    plotParameters(fpPlotRoot, [(9, "m22")], dfTest, dfOutput; filename="constants")

end

function plotLUXm(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)
   
    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "LUXm") )

    # dLUXm entries:
    # 1   2   3    4     5       6     7      8   9   10     11  12   13   14   15   16
    # ID  PP, day  time  out---  lt--  parameters----------  constants------------------
    # 22, PP, day, time, du[22], LUXm, RVE8p, EC, LC, TOC1n, a7, r37, r22, r23, r24, m34

    # output

    plotParameters(fpPlotRoot, [(5, "dLUXmdt")], dfTest, dfOutput; filename="output")

    # ltv

    plotParameters(fpPlotRoot, [(6, "LUXm")], dfTest, dfOutput; filename="ltv")

    # parameters

    plotParameters(fpPlotRoot, [(7, "RVE8p"), (8, "EC"), (9, "LC"), (10, "TOC1n")], dfTest, dfOutput; filename="parameters")

    # constants

    plotParameters(fpPlotRoot, [(11, "a7"), (12, "r37"), (13, "r22"), (14, "r23"), (15, "r24"), (16, "m34")], dfTest, dfOutput; filename="constants")

end

function plotLUXp(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)
   
    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "LUXp") )

    # dLUXp entries:
    # 1   2   3    4     5       6     7               8 
    # ID  PP, day  time  out--   lt--  parameters----- constants
    # 23, PP, day, time, du[23], LUXp, LUXm,           m39

    # output

    plotParameters(fpPlotRoot, [(5, "dLUXpdt")], dfTest, dfOutput; filename="output")

    # ltv

    plotParameters(fpPlotRoot, [(6, "LUXp")], dfTest, dfOutput; filename="ltv")

    # parameters

    plotParameters(fpPlotRoot, [(7, "LUXm")], dfTest, dfOutput; filename="parameters")

    # constants

    plotParameters(fpPlotRoot, [(8, "m39")], dfTest, dfOutput; filename="constants")

end

function plotCOP1c(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)
   
    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "COP1c") )

    # dCOP1c entries:
    # 1   2   3    4     5       6      7          8   9   10   11
    # ID  PP, day  time  out---  lt---  parameters constants-------
    # 24, PP, day, time, du[24], COP1c, RedL,      n5, p6, m27, p15

    # output

    plotParameters(fpPlotRoot, [(5, "dCOP1cdt")], dfTest, dfOutput; filename="output")

    # ltv

    plotParameters(fpPlotRoot, [(6, "COP1c")], dfTest, dfOutput; filename="ltv")

    # parameters

    plotParameters(fpPlotRoot, [(7, "RedL")], dfTest, dfOutput; filename="parameters")

    # constants

    plotParameters(fpPlotRoot, [(8, "n5"), (9, "p6"), (10, "m27"), (11, "p15")], dfTest, dfOutput; filename="constants")

end

function plotCOP1n(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)
   
    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "COP1n") )

    # dCOP1n entries:
    # 1   2   3    4     5       6      7      8     9  10  11   12  13   14
    # ID  PP  day  time  out---  lt---  parameters----  constants------------ 
    # 25, PP, day, time, du[25], COP1n, COP1c, RedL, P, p6, n14, n6, m27, p15

    # output

    plotParameters(fpPlotRoot, [(5, "dCOP1ndt")], dfTest, dfOutput; filename="output")

    # ltv

    plotParameters(fpPlotRoot, [(6, "COP1n")], dfTest, dfOutput; filename="ltv")

    # parameters

    plotParameters(fpPlotRoot, [(7, "COP1c"), (8, "RedL"), (9, "P")], dfTest, dfOutput; filename="parameters")

    # constants

    plotParameters(fpPlotRoot, [(10, "p6"), (11, "n14"), (12, "n6"), (13, "m27"), (14, "p15")], dfTest, dfOutput; filename="constants")

end

function plotCOP1d(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)
   
    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "COP1d") )

    # dCOP1d entries:
    # 1   2   3    4     5       6      7     8  9      10    11   12  13   14
    # ID  PP  day  time  out---  lt---  parameters----------  constants--------
    # 26, PP, day, time, du[26], COP1d, RedL, P, COP1n, RedD, n14, n6, m31, m33

    # output

    plotParameters(fpPlotRoot, [(5, "dCOP1ddt")], dfTest, dfOutput; filename="output")

    # ltv

    plotParameters(fpPlotRoot, [(6, "COP1d")], dfTest, dfOutput; filename="ltv")

    # parameters

    plotParameters(fpPlotRoot, [(7, "RedL"), (8, "P"), (9, "COP1n"), (10, "RedD")], dfTest, dfOutput; filename="parameters")

    # constants

    plotParameters(fpPlotRoot, [(11, "n14"), (12, "n6"), (13, "m31"), (14, "m33")], dfTest, dfOutput; filename="constants")

end

function plotZTL(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)
   
    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "ZTL") )

    # dZTL entries:
    # 1   2   3    4     5       6    7          8    9
    # ID  PP  day  time  out---  lt-  parameters constants
    # 27, PP, day, time, du[27], ZTL, ZGprod,    p14, m20

    # output

    plotParameters(fpPlotRoot, [(5, "dZTLdt")], dfTest, dfOutput; filename="output")

    # ltv

    plotParameters(fpPlotRoot, [(6, "ZTL")], dfTest, dfOutput; filename="ltv")

    # parameters

    plotParameters(fpPlotRoot, [(7, "ZGprod")], dfTest, dfOutput; filename="parameters")

    # constants

    plotParameters(fpPlotRoot, [(8, "p14"), (9, "m20")], dfTest, dfOutput; filename="constants")

end

function plotZG(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)
   
    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "ZG") )

    # dZG entries:
    # 1   2   3    4     5       6   7          8
    # ID  PP, day  time  out---  lt  parameters constants
    # 28, PP, day, time, du[28], ZG, ZGprod,    m21

    # output

    plotParameters(fpPlotRoot, [(5, "dZGdt")], dfTest, dfOutput; filename="output")

    # ltv

    plotParameters(fpPlotRoot, [(6, "ZG")], dfTest, dfOutput; filename="ltv")

    # parameters

    plotParameters(fpPlotRoot, [(7, "ZGprod")], dfTest, dfOutput; filename="parameters")

    # constants

    plotParameters(fpPlotRoot, [(8, "m21")], dfTest, dfOutput; filename="constants")

end

function plotGIm(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)
   
    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "GIm") )

    # dGIm entries:
    # 1   2   3    4     5       6    7      8   9   10     11  12   13   14   15   16
    # ID  PP  day  time  out---  lt-  parameters----------  constants
    # 29, PP, day, time, du[29], GIm, RVE8p, EC, LC, TOC1n, a8, r38, r25, r26, r27, m18

    # output

    plotParameters(fpPlotRoot, [(5, "dGImdt")], dfTest, dfOutput; filename="output")

    # ltv

    plotParameters(fpPlotRoot, [(6, "GIm")], dfTest, dfOutput; filename="ltv")

    # parameters

    plotParameters(fpPlotRoot, [(7, "RVE8p"), (8, "EC"), (9, "LC"), (10, "TOC1n")], dfTest, dfOutput; filename="parameters")

    # constants

    plotParameters(fpPlotRoot, [(11, "a8"), (12, "r38"), (13, "r25"), (14, "r26"), (15, "r27"), (16, "m18")], dfTest, dfOutput; filename="constants")

end

function plotGIc(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)
   
    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "GIc") )

    # dLHYm entries:
    # 1   2   3    4     5       6    7    8       9       10   11
    # ID  PP  day  time  out---  lt-  parameters---------  constants
    # 30, PP, day, time, du[30], GIc, GIm, ZGprod, Gtrans, p11, m19

    # output

    plotParameters(fpPlotRoot, [(5, "dGIcdt")], dfTest, dfOutput; filename="output")

    # ltv

    plotParameters(fpPlotRoot, [(6, "GIc")], dfTest, dfOutput; filename="ltv")

    # parameters

    plotParameters(fpPlotRoot, [(7, "GIm"), (8, "ZGprod"), (9, "Gtrans")], dfTest, dfOutput; filename="parameters")

    # constants

    plotParameters(fpPlotRoot, [(10, "p11"), (11, "m19")], dfTest, dfOutput; filename="constants")

end

function plotGIn(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)
   
    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "GIn") )

    # dGIn entries:
    # 1   2   3    4     5       6    7       8        9      10     11   12   13   14
    # ID  PP  day  time  out---  lt-  parameters-------------------  constants---------
    # 31, PP, day, time, du[31], GIn, Gtrans, ELF3tot, COP1d, COP1n, m19, m25, m28, m32

    # output

    plotParameters(fpPlotRoot, [(5, "dGIndt")], dfTest, dfOutput; filename="output")

    # ltv

    plotParameters(fpPlotRoot, [(6, "GIn")], dfTest, dfOutput; filename="ltv")

    # parameters

    plotParameters(fpPlotRoot, [(7, "Gtrans"), (8, "ELF3tot"), (9, "COP1d"), (10, "COP1n")], dfTest, dfOutput; filename="parameters")

    # constants

    plotParameters(fpPlotRoot, [(11, "m19"), (12, "m25"), (13, "m28"), (14, "m32")], dfTest, dfOutput; filename="constants")

end

function plotNOXm(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)
   
    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "NOXm") )

    # dNOXm entries:
    # 1   2   3    4     5       6     7   8      9    10   11
    # ID  PP  day  time  out---  lt--  parameters constants----
    # 32, PP, day, time, du[32], NOXm, LC, PRR7p, r28, r29, m44

    # output

    plotParameters(fpPlotRoot, [(5, "dNOXmdt")], dfTest, dfOutput; filename="output")

    # ltv

    plotParameters(fpPlotRoot, [(6, "NOXm")], dfTest, dfOutput; filename="ltv")

    # parameters

    plotParameters(fpPlotRoot, [(7, "LC"), (8, "PRR7p")], dfTest, dfOutput; filename="parameters")

    # constants

    plotParameters(fpPlotRoot, [(9, "r28"), (10, "r29"), (11, "m44")], dfTest, dfOutput; filename="constants")

end

function plotNOXp(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)
   
    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "NOXp") )

    # dNOXp entries:
    # 1   2   3    4     5       6     7               8 
    # ID  PP  day  time  out---  lt--  parameters----- constants
    # 33, PP, day, time, du[33], NOXp, NOXm,           m45

    # output

    plotParameters(fpPlotRoot, [(5, "dNOXpdt")], dfTest, dfOutput; filename="output")

    # ltv

    plotParameters(fpPlotRoot, [(6, "NOXp")], dfTest, dfOutput; filename="ltv")

    # parameters

    plotParameters(fpPlotRoot, [(7, "NOXm")], dfTest, dfOutput; filename="parameters")

    # constants

    plotParameters(fpPlotRoot, [(8, "m45")], dfTest, dfOutput; filename="constants")

end

function plotRVE8m(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)
   
    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "RVE8m") )

    # dRVE8m entries:
    # 1   2   3    4     5       6      7      8      9      10   11   12   13
    # ID  PP  day  time  out---  lt---  parameters---------  constants---------
    # 34, PP, day, time, du[34], RVE8m, PRR9p, PRR7p, PRR5n, r30, r31, r32, m46

    # output

    plotParameters(fpPlotRoot, [(5, "dRVE8mdt")], dfTest, dfOutput; filename="output")

    # ltv

    plotParameters(fpPlotRoot, [(6, "RVE8m")], dfTest, dfOutput; filename="ltv")

    # parameters

    plotParameters(fpPlotRoot, [(7, "PRR9p"), (8, "PRR7p"), (9, "PRR5n")], dfTest, dfOutput; filename="parameters")

    # constants

    plotParameters(fpPlotRoot, [(10, "r30"), (11, "r31"), (12, "r32"), (13, "m46")], dfTest, dfOutput; filename="constants")

end

function plotRVE8p(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)
   
    # plots root

    fpPlotRoot = mkpath( joinpath(fpPlotsRoot, "PP-$(pp)", "Day-$(day)", "RVE8p") )

    # dRVE8p entries:
    # 1   2   3    4     5       6      7          8
    # ID  PP  day  time  out---  lt---  parameters constants
    # 35, PP, day, time, du[35], RVE8p, RVE8m,     m47

    # output

    plotParameters(fpPlotRoot, [(5, "dRVE8p")], dfTest, dfOutput; filename="output")

    # ltv

    plotParameters(fpPlotRoot, [(6, "RVE8p")], dfTest, dfOutput; filename="ltv")

    # parameters

    plotParameters(fpPlotRoot, [(7, "RVE8m")], dfTest, dfOutput; filename="parameters")

    # constants

    plotParameters(fpPlotRoot, [(8, "m47")], dfTest, dfOutput; filename="constants")

end

# - unknown function

function plotUnknown(pp, day, parameter, fpPlotsRoot, dfTest, dfOutput)
    println(" - unknown parameter: $(parameter)  @ day: $(day) in pp: $(pp)")
end

# - plot function dispatch based on ID

plotDispatch = Dict(1 => plotLHYm,
                    2 => plotLHYp,
                    3 => plotCCA1m,
                    4 => plotCCA1p,
                    5 => plotP,
                    6 => plotPRR9m,
                    7 => plotPRR9p,
                    8 => plotPRR7m,
                    9 => plotPRR7p,
                    10 => plotPRR5m,
                    11 => plotPRR5c,
                    12 => plotPRR5n,
                    13 => plotTOC1m,
                    14 => plotTOC1n,
                    15 => plotTOC1c,
                    16 => plotELF4m,
                    17 => plotELF4p,
                    18 => plotELF4d,
                    19 => plotELF3m,
                    20 => plotELF3p,
                    21 => plotELF34,
                    22 => plotLUXm,
                    23 => plotLUXp,
                    24 => plotCOP1c,
                    25 => plotCOP1n,
                    26 => plotCOP1d,
                    27 => plotZTL,
                    28 => plotZG,
                    29 => plotGIm,
                    30 => plotGIc,
                    31 => plotGIn,
                    32 => plotNOXm,
                    33 => plotNOXp,
                    34 => plotRVE8m,
                    35 => plotRVE8p
                   )

# main entry point -------------------------------------------------------------

# ensure base directories exist

fpTest   = "./test/data/MATLAB/clock-COP1/clock-only"

fpTestOutput = mkpath("./test/output/JULIA/clock-tracing")

fpOutput = "./output/example/onlyclock/data"

println("comparison data will be written to \"$(fpTestOutput)\" ")

# command-line arguments

args = parseArgs()

#
# clock tracing
#
# - output PIFCOFT phenology model calculation tracing
#

# photoperiods

photoperiods = [Int(0), Int(8), Int(16)]

if ( !( isnothing(args.requiredPP) ) )

    photoperiods = sort!( collect( intersect( Set(photoperiods), Set(args.requiredPP) ) ) )

end

for pp in photoperiods

    println("- processing photoperiod @ $(pp)")

    # test data

    fpTestTracing = joinpath(fpTest, "F2014-COP1-Tracing-PP-$(pp).csv")

    dfTest = DataFrame(CSV.File(fpTestTracing, header=false))

    parameters   = sort!( unique!( map(p -> floor(p), collect( dfTest[:,1] ) ) ) )

    # output data

    fpJuliaTracing = joinpath(fpTest, "F2014-COP1-Tracing-PP-$(pp).csv")

    dfOutput = DataFrame(CSV.File(fpJuliaTracing, header=false))

    # common days in photoperiod pp

    # - common days

    daysTest   = Set( map(d -> floor(d), collect( dfTest[:, 3] ) ) )

    daysOutput = Set( map(d -> floor(d), collect( dfOutput[:, 3] ) ) )

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

            dfTest_d_p   = 
                filter([:Column1, :Column3] => (pt, dy) -> ((dy == day) && (pt == parameter)), dfTest) 

            dfOutput_d_p =
                filter([:Column1, :Column3] => (pt, dy) -> ((dy == day) && (pt == parameter)), dfOutput) 

            # dispatch

            plotFunc = get(plotDispatch, parameter,  plotUnknown)

            # plot
    
            plotFunc(pp, day, parameter, fpTestOutput, dfTest_d_p, dfOutput_d_p)

        end

        print("\n")

    end

end

println(" done .")
