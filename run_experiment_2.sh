TIMEFORMAT='%3R'

export PATH=$PATH:../../Programs/minizinc/minizinc-2.0.12/bin:../../Programs/chuffed/chuffed-install/bin

for nc in $(seq 0 5 30)
do
  for i in $(seq 1 1000)
  do
    echo ${nc}
    echo $i
    numbp=0
    result=1
    time while !(python ../hrc-minizinc/hrc-to-minizinc.py $numbp $1 \
        < ../MIN_BP_HRC_Experiments/Experiment_2/100_-_10_-_${nc}_-_100_-_3_-_5_-_false_-_5_-_5_-_Iteration_$i.txt \
        > tmp.dzn \
        && mzn2fzn ../hrc-minizinc/hrc.mzn tmp.dzn -o tmp.fzn \
        && fzn_chuffed tmp.fzn | solns2out ../hrc-minizinc/hrc.ozn \
        > tmp.out &&
        awk '/UNSAT/ {exit 1} /[0-9]/ {result=$1;result_exists=1} END {if (result_exists) print result}' tmp.out)
    do
      ((numbp += 1))
    done
    echo $numbp
    date
  done
done

rm tmp.*
