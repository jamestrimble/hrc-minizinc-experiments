import sys

lines = [line.strip() for line in sys.stdin.readlines() if line.strip()]

while lines:
    print "{}\t{}\t{}\t{}\t{}".format(
            lines[0], lines[1], int(lines[2].split()[-1]), lines[3], lines[4])
    lines = lines[5:]
