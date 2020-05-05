import sys

interval = 250000

for index, line in enumerate(sys.stdin):
    if index % interval == 0:
        sys.stdout.write(line)
