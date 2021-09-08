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


get_most_connection_attempts()
{
    # -c argument: Which IP number has the most most connection attempts.

    LOG_FILE=$1
    cat $LOG_FILE | grep -E -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | sort | uniq -c | sort

}


get_most_successful_attempts()
{
    # -2 argument: Which IP number has the most successful attempts.
    
    LOG_FILE=$1
    cat $LOG_FILE | grep -E '" 200 ' | grep -E -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | sort | uniq -c | sort

}


get_most_bytes_received()
{
    # -t argument: Which IP number get the most bytes sent to them.

    LOG_FILE=$1
    ALL_UNIQUE_IPS=$(cat $LOG_FILE | grep -E '" 200 ' | grep -E -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | sort | uniq);

    BYTES_RECEIVED=""
    for IP in $ALL_UNIQUE_IPS
    do
        BYTES_RECEIVED=$BYTES_RECEIVED"\n"$(cat $LOG_FILE | grep -E '" 200 ' | sort | awk -F ' ' '$1 == "'$IP'" {sum += $10} END {print sum " " "'$IP'"}')
    done

    echo $BYTES_RECEIVED | sort -n
}


help()
{
    echo "Usage: ./log_analyzer.sh [-n N] (-c|-2|-r|-F|-t) <filename>"
}


# check if argument $1 is a number
#number = '^[0-9]+$'
#if [$1 == "-n"] {
#    if ![[$2 =~ $number]]; then
#    
#}

# -r "What are the most common result codes and where do they come from?"
# Cut out the ip addresses with the codes, i.e exclude everything in between.
# bas commando : cat test_logfile.txt | grep -Eo "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" // gets ip adresses
# cat test_logfile.txt | grep -E " [0-9]{3} " // gets result codes
# cat test_logfile.txt |grep -Eo " [0-9]{3} "  | sort | uniq -c // gets the number of times each result code occurs.
# cat test_logfile.txt | grep -Eo "^([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})|( [0-9]{3} )" // gets ip and result code for each line, however is printed on different lines in #output
# cat test_logfile.txt | awk '{print $1,$9}' | sort | uniq -c // gets the number of times an ip address gets a result code  
# cat test_logfile.txt| awk '{print $9,$1}' | sort | uniq -c | sort -r -n -k1 -k2 | awk '{print $2,$3}' // gets everything that -r is asked to do.

# -F "What are the most common result codes that indicate failure, and where do thet come from?"
# bas commando : cat test_logfile.txt| awk '{print $9,$1}' | sort | uniq -c | sort -r -n -k1 -k2 | awk '{print $2,$3}' //-r
# modified the base commando so that the lines with a 4xx result code only gets sorted
# cat test_logfile.txt | awk '{print $9,$1}' | grep -E "4[0-9]{2} " | sort | uniq -c | sort -r -n -k1 -k2 | awk '{print $2,$3}' // should be what -F is asked to do?


