#!/bin/sh
#
# Script Name: loganalyzer.sh
#
# Description: The following script is Assignment 1 in course DV1457 at Blekinge Tekniska Högskola.
#              It reads log files and outputs information depending on the arguments.
#


# most connection attempts: cat test_logfile.txt | grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+" | uniq -c | sort -r | head -n 1

# most successful attempts: cat test_logfile.txt | grep -e " 200 " | grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+" | uniq -c | sort -r | head -n 1

