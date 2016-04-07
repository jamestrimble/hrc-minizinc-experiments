SHELL := /bin/bash
EXPERIMENTS := 1
CHUFFED_TIMEOUT := 900 

.PHONY: all
all: $(foreach i, $(EXPERIMENTS), results/exp$i/summary.out results/exp$i/mean_times.out) \
     $(foreach i, $(EXPERIMENTS), results/exp$i_no_presolve/summary.out results/exp$i_no_presolve/mean_times.out)

results/%/mean_times.out: results/%/summary.out
	awk -f calc_averages.awk -v type="$<" $< > $@

results/%/summary.out: results/%/results.out results/%/times.out
	./join_results.sh $^ > $@

results/exp1/results.out results/exp1/times.out:
	mkdir -p $(dir $@) && \
	CHUFFED_TIMEOUT=${CHUFFED_TIMEOUT} ./run_experiment_1.sh 2> $(dir $@)times.out | tee $(dir $@)results.out
results/exp1_no_presolve/results.out results/exp1_no_presolve/times.out:
	mkdir -p $(dir $@) && \
	CHUFFED_TIMEOUT=${CHUFFED_TIMEOUT} ./run_experiment_1.sh --no-presolve 2> $(dir $@)times.out | tee $(dir $@)results.out

results/exp2/results.out results/exp2/times.out:
	mkdir -p $(dir $@) && \
	CHUFFED_TIMEOUT=${CHUFFED_TIMEOUT} ./run_experiment_2.sh 2> $(dir $@)times.out | tee $(dir $@)results.out
results/exp2_no_presolve/results.out results/exp2_no_presolve/times.out:
	mkdir -p $(dir $@) && \
	CHUFFED_TIMEOUT=${CHUFFED_TIMEOUT} ./run_experiment_2.sh --no-presolve 2> $(dir $@)times.out | tee $(dir $@)results.out

results/exp3/results.out results/exp3/times.out:
	mkdir -p $(dir $@) && \
	CHUFFED_TIMEOUT=${CHUFFED_TIMEOUT} ./run_experiment_3.sh 2> $(dir $@)times.out | tee $(dir $@)results.out
results/exp3_no_presolve/results.out results/exp3_no_presolve/times.out:
	mkdir -p $(dir $@) && \
	CHUFFED_TIMEOUT=${CHUFFED_TIMEOUT} ./run_experiment_3.sh --no-presolve 2> $(dir $@)times.out | tee $(dir $@)results.out

results/exp4/results.out results/exp4/times.out:
	mkdir -p $(dir $@) && \
	CHUFFED_TIMEOUT=${CHUFFED_TIMEOUT} ./run_experiment_4.sh 2> $(dir $@)times.out | tee $(dir $@)results.out
results/exp4_no_presolve/results.out results/exp4_no_presolve/times.out:
	mkdir -p $(dir $@) && \
	CHUFFED_TIMEOUT=${CHUFFED_TIMEOUT} ./run_experiment_4.sh --no-presolve 2> $(dir $@)times.out | tee $(dir $@)results.out

clean:
	rm -rf results/*
