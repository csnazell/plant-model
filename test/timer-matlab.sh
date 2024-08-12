#
# run matlab script 100 times & log output
#

# results file

fpResults="time-results.out"

# purge results
rm -f ${fpResults}

# run

for i in {1..100}
do
    duration=`matlab -batch "tic; Fit_Model_To_Hypocotyl_Data(); disp(toc)" | tail -n 2 | head -n 1`

    echo ${duration} >> ${fpResults}
done

echo "done"
