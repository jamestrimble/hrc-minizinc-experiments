BEGIN {FS="\t"}

{counts[$1 " " $4] += 1; tot_time[$1 " " $4] += $6}

END {
    for (key in counts) {
        print type, key, counts[key], tot_time[key]/counts[key]
    }
}
