#!/bin/sh
#
# Script Name: loganalyzer.sh
#
# Description: The following script is Assignment 1 in course DV1457 at Blekinge Tekniska Högskola.
#              It reads log files and outputs information depending on the arguments.
#


# -c most connection attempts: cat test_logfile.txt | grep -E -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | sort | uniq -c | sort -r | head -n 1

# -2 most successful attempts: cat test_logfile.txt | grep -E " 200 " | grep -E -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | sort | uniq -c | sort -r | head -n 1

# regex ändrades för att match inte skulle bli fel

# -t Which IP number get the most bytes sent to them: 
#ASD=$(cat test_logfile.txt | grep -E '" 200 ' | grep -E -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | sort | uniq);

#ASD2=""
#for IP in $ASD
#do
#    ASD2=$ASD2"\n"$(cat test_logfile.txt | grep -E '" 200 ' | sort | awk -F ' ' '$1 == "'$IP'" {sum += $10} END {print sum " " "'$IP'"}')
#done

#echo $ASD2 | sort -n -r

help()
{
    echo "Usage: log_sum.sh [-n N] (-c|-2|-r|-F|-t) <filename>"
}

# check if argument $1 is a number
#number = '^[0-9]+$'
#if [$1 == "-n"] {
#    if ![[$2 =~ $number]]; then
#    
#}

