#
# run julia script 100 times & log output
#

# results file

fpResults="time-results.out"

# purge results

rm -f ${fpResults}

touch ${fpResults}

# run

for i in {1..2}
do
    duration=`/usr/bin/time --format=%E --output=${fpResults} --append julia --project=. test/TestScript.jl`
done

echo "done"
