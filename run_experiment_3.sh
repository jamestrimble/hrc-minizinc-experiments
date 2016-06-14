TIMEFORMAT='%3R'

export PATH=$PATH:../../Programs/minizinc/minizinc-2.0.12/bin:~/chuffed/binary/linux

for nh in $(seq 10 10 100)
do
  for i in $(seq 1 1000)
  do
    echo ${nh}
    echo $i
    numbp=0
    result=1
    time while !(python ../hrc-minizinc/hrc-to-minizinc.py $numbp $1 \
        < ../MIN_BP_HRC_Experiments/Experiment_3/100_-_${nh}_-_10_-_100_-_3_-_5_-_false_-_5_-_5_-_Iteration_$i.txt \
        > tmp.dzn \
        && mzn2fzn ../hrc-minizinc/hrc.mzn tmp.dzn -o tmp.fzn \
        && fzn_chuffed -time_out=$CHUFFED_TIMEOUT tmp.fzn | awk 'NR>1' | solns2out ../hrc-minizinc/hrc.ozn \
        > tmp.out &&
        awk '/UNSAT/ {exit 1} /[0-9]/ {result=$1;result_exists=1} END {if (NR==0) {print -1;exit} else if (result_exists) print result}' tmp.out)
    do
      ((numbp += 1))
    done
    echo $numbp
    date
  done
done

rm tmp.*
