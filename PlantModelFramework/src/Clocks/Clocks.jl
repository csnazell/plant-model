#                                                                              #
# PlantModelFramework                                                          #
#                                                                              #
# Clocks.jl                                                                    #
#                                                                              #
# Root module for Clocks namespace within package.                             #
#                                                                              #
#    Copyright 2024 Christopher Snazell, Dr Rea L Antoniou-Kourounioti and     #
#                     The University of Glasgow                                #
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

module Clocks

    # sub-module: F2014

    include("F2014.jl")

    import .F2014

    export F2014

end

