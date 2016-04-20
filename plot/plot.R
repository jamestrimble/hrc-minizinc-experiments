library(dplyr)

experiments <- list.dirs("../results", full.names=FALSE, recursive=FALSE)

# Get detailed results from Iain's runs.
ds <- lapply(1:4, function(n) {
	d <- read.csv(file.path("../../hrc-minizinc-experiments-iain", paste0("exp", n, ".csv")),
		     	    header=TRUE)
	d$n <- n
	d <- d[c("param", "Iteration", "MaximumSize", "MinBlockingPairs", "TimeTaken", "n")]
	names(d) <- c("param", "instance", "size", "num_bp", "time", "n")
	d$time <- d$time / 1000 # Convert ms to seconds
	d		     
})
iain <- do.call(rbind, ds)
iain$solvable <- iain$num_bp == 0
iain_data_for_run <- function(n) {iain[iain$n==n, 1:4]}

# Create d, a data frame of all our results
ds <- lapply(experiments, function(e) {
	d <- read.delim(file.path("..", "results", e, "summary.out"),
		     	    header=FALSE,
			        col.names=c("param", "instance", "size", "num_bp", "timestamp", "time"))
	d$e <- e
	d$e_number <- as.integer(gsub("[^0-9]", "", e))
	d$uses_presolve <- !grepl("no_presolve", e)
	# Read whether solvable from Iain's results
	d$solvable <- iain$solvable[iain$n == as.integer(gsub("[^0-9]", "", e))]
	d				     
})
d <- do.call(rbind, ds)

# Check that results are as expected from Iain's runs using CPLEX
check_expected <- function(n, experiment_name) {
	expected <- iain_data_for_run(n)
    actual <- d[d$e==experiment_name, 1:4]
    print(nrow(expected))
    print(nrow(actual))
    if (!all(expected==actual))	{
    	print(paste("discrepancy: ", n, experiment_name))
    	for (i in 1:nrow(expected))
			if (!all(expected[i,] == actual[i,]))
				print(rbind(expected[i,], actual[i,]))
    }
}
                      
for (e in experiments) {
	check_expected(gsub("[^0-9]", "", e), e)
}

# Where timeouts occurred, set time to 1800 seconds
d$time[d$time >= 1800] <- 1800
d$timeout <- d$time == 1800

# Show timeouts
timeout_runs <- d[d$timeout, ]
timeout_runs
write.csv(timeout_runs, "output/timeout_runs.csv")
print(paste("Number of timeouts:", nrow(timeout_runs)))

# Summarise results
mean_times <- d %>%
	group_by(e, e_number, uses_presolve) %>%
	summarise(mean_time=mean(time))
write.csv(mean_times, "output/mean_times.csv")
	
mean_times_by_solvable <- d %>%
	group_by(e, e_number, uses_presolve, solvable) %>%
	summarise(mean_time=mean(time))
write.csv(mean_times_by_solvable, "output/mean_times_by_solvable.csv")

mean_times_by_param <- d %>%
	group_by(e, e_number, uses_presolve, param) %>%
	summarise(mean_time=mean(time))
write.csv(mean_times_by_param, "output/mean_times_by_param.csv")
	
mean_times_by_param_and_solvable <- d %>%
	group_by(e, e_number, uses_presolve, param, solvable) %>%
	summarise(mean_time=mean(time))
write.csv(mean_times_by_param_and_solvable, "output/mean_times_by_param_and_solvable.csv")

iain_mean_times <- iain %>%
	group_by(n) %>%
	summarise(mean_time=mean(time))
write.csv(iain_mean_times, "output/iain_mean_times.csv")
	
iain_mean_times_by_solvable <- iain %>%
	group_by(n, solvable) %>%
	summarise(mean_time=mean(time))
write.csv(iain_mean_times_by_solvable, "output/iain_mean_times_by_solvable.csv")

iain_mean_times_by_param <- iain %>%
	group_by(n, param) %>%
	summarise(mean_time=mean(time))
write.csv(iain_mean_times_by_param, "output/iain_mean_times_by_param.csv")
	
iain_mean_times_by_param_and_solvable <- iain %>%
	group_by(n, param, solvable) %>%
	summarise(mean_time=mean(time))
write.csv(iain_mean_times_by_param_and_solvable, "output/iain_mean_times_by_param_and_solvable.csv")

# Create plots
pdf("output/cp-vs-mip.pdf", width=9, height=5)
op <- par(mgp = c(2,1,0), mar=c(4,3,3,1)+0.1)
x_labels <- c("Number of Residents", "Number of Couples", "Number of Hospitals", "Pref List Length")
par(mfrow=c(2, 4))
for (solvable in c(1,0)) {
	for (i in 1:4) {
		plot_data <- mean_times_by_param_and_solvable[mean_times_by_param_and_solvable$e_number==i &
				mean_times_by_param_and_solvable$solvable==solvable, ]
		plot_data_presolve <- plot_data[plot_data$uses_presolve, ]
		plot_data_no_presolve <- plot_data[!plot_data$uses_presolve, ]
		iain_plot_data <- iain_mean_times_by_param_and_solvable[
				iain_mean_times_by_param_and_solvable$n==i & iain_mean_times_by_param_and_solvable$solvable==solvable, ]
		plot_params <- matrix(rep(plot_data_presolve$param, 3), ncol=3)
		plot_times <- matrix(c(plot_data_presolve$mean_time, plot_data_no_presolve$mean_time,
		                       iain_plot_data$mean_time), ncol=3)
		#plot(plot_data_presolve[, c("param", "mean_time")], type="b")
		matplot(plot_params, plot_times, type="b", ylab="Mean Time (s)", xlab=x_labels[i], pch=1:3, col="black",
				main=paste0("Experiment ", i, ",\n", ifelse(solvable, "Solvable", "Unsolvable")))
		legend(ifelse(i==3, "topright", "topleft"), inset=.02,
					legend=c("CP, presolve on", "CP, presolve off", "MIP"),
					pch=1:3, col="black", bty="n")
	}
}
par(op)
dev.off()

# Overall average run times (remember that timeouts are recorded as 1800s)
print(mean(d$time[d$uses_presolve]))
print(mean(d$time[!d$uses_presolve]))
print(mean(iain$time))
print(sum(d$time[!d$uses_presolve]) / sum(iain$time))
print(sum(iain$time) / sum(d$time[d$uses_presolve]))
