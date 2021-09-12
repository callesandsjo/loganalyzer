#!/bin/sh
#
# Script Name: loganalyzer.sh
#
# Description: The following script is Assignment 1 in course DV1457 at Blekinge Tekniska Högskola.
#              It reads log files and outputs information depending on the options.
#

get_most_connection_attempts()
{
    # -c argument: Which IP number has the most most connection attempts.

    if [ -z $LOG_FILE ]
    then
        cat | cut -d " " -f1 | sort | uniq -c | sort -r | awk '{print $2, $1}'
    else
        cat $LOG_FILE | cut -d " " -f1 | sort | uniq -c | sort -r | awk '{print $2, $1}'
    fi

}


get_most_successful_attempts()
{
    # -2 argument: Which IP number has the most successful attempts.
    
    if [ -z $LOG_FILE ]
    then
        cat | awk '$9 == 200' | cut -d " " -f1 | sort | uniq -c | sort -r | awk '{print $2, $1}'
    else
        cat $LOG_FILE | awk '$9 == 200' | cut -d " " -f1 | sort | uniq -c | sort -r | awk '{print $2, $1}'
    fi
}


get_most_bytes_received()
{
    # -t argument: Which IP number get the most bytes sent to them.

    if [ -z $LOG_FILE ]
    then
        cat | cut -d" " -f1,10 | awk '$2 != "-"' | awk '{byte_sum[$1]+=$2}END{for(ip in byte_sum) print ip, byte_sum[ip]}' | sort -rnk2
    else
        cat $LOG_FILE | cut -d" " -f1,10 | awk '$2 != "-"' | awk '{byte_sum[$1]+=$2}END{for(ip in byte_sum) print ip, byte_sum[ip]}' | sort -rnk2
    fi
}


get_most_common_codes_ips()
{
    # -r "What are the most common result codes and where do they come from?"
    
    if [ -z $LOG_FILE ]
    then
        INP="$(cat)"
        MOST_COMMON_CODES_IN_ORDER=$(echo "$INP" | awk '{print $9,$1}' | sort | uniq -c | sort -rk1,1 | awk '{print $2}' | awk '{if(!has_seen[$1]) print $1; has_seen[$1]=1;}')
        for CODE in $MOST_COMMON_CODES_IN_ORDER
        do
            echo "$INP" | awk '{print $9,$1}' | sort | uniq -c | sort -r -k1,1 | awk '{print $2,$3}' | grep "^$CODE"
        done
    else
        MOST_COMMON_CODES_IN_ORDER=$(cat $LOG_FILE | awk '{print $9,$1}' | sort | uniq -c | sort -rk1,1 | awk '{print $2}' | awk '{if(!has_seen[$1]) print $1; has_seen[$1]=1;}')
        for CODE in $MOST_COMMON_CODES_IN_ORDER
        do
            cat $LOG_FILE | awk '{print $9,$1}' | sort | uniq -c | sort -r -k1,1 | awk '{print $2,$3}' | grep "^$CODE"
        done
    fi
}

# problem med att cat rensades efter körning så var tvungen att spara till variabler
get_most_failures()
{
    # -F "What are the most common result codes that indicate failure, and where do thet come from?"
    
    if [ -z $LOG_FILE ]
    then
        INP="$(cat)"
        FAILED_RESULT_CODES_IN_ORDER=$(echo "$INP" | awk '{print $9,$1}' | grep -E "4[0-9]{2} " | sort | uniq -c | sort -rk1,1 | awk '{print $2}' | awk '{if(!has_seen[$1]) print $1; has_seen[$1]=1;}')
        
        for FAILED_CODE in $FAILED_RESULT_CODES_IN_ORDER
        do
            echo "$INP" | awk '{print $9,$1}' | grep -E "4[0-9]{2} " | sort | uniq -c | sort -r -k1,1 | awk '{print $2,$3}' | grep "^$FAILED_CODE"
        done
    else
        FAILED_RESULT_CODES_IN_ORDER=$(cat $LOG_FILE | awk '{print $9,$1}' | grep -E "4[0-9]{2} " | sort | uniq -c | sort -rk1,1 | awk '{print $2}' | awk '{if(!has_seen[$1]) print $1; has_seen[$1]=1;}')
        for FAILED_CODE in $FAILED_RESULT_CODES_IN_ORDER
        do
            cat $LOG_FILE | awk '{print $9,$1}' | grep -E "4[0-9]{2} " | sort | uniq -c | sort -r -k1,1 | awk '{print $2,$3}' | grep "^$FAILED_CODE"
        done
    fi
}

# problem med att sortera gruppvis
help()
{
    echo "Usage: ./loganalyzer.sh [-n N] (-c|-2|-r|-F|-t) <filename>"
}


check_option_used()
{
    if [ ! -z $OPTION_USED ]
    then
        echo "Too many options used."
        help
        exit 1
    else
        OPTION_USED=1
    fi
}

# problem med att få optional arguments
# väljer att skriva en egen hantering av argument
handle_args()
{
    if [ $# -eq 0 ]; then
        help
        exit 1
    fi

    while [ "$1" != "" ]; do
        case "$1" in
            -n)
                if [ -z $2 ]
                then
                    help
                    exit 1
                fi

                LIMIT_LINES=$(echo $2 | grep -Eo '^[0-9]+$')
                if [ ! $? -eq "0" ]
                then
                    help
                    exit 1
                fi
                shift;;
            -e)
                CHECKING_IP=1
                ;;
            -c)
                check_option_used
                FLAG="c"
                ;;
            -2)
                check_option_used
                FLAG="2"
                ;;
            -t)
                check_option_used
                FLAG="t"
                ;;
            -r)
                check_option_used
                FLAG="r"
                ;;
            -F)
                check_option_used
                FLAG="F"
                ;;
            *)
                if [ $# -eq 1 ]
                then
                    LOG_FILE=$1
                else
                    help
                    exit 1
                fi
                ;;
            esac
        shift
    done


    case $FLAG in
        c)
            OUTPUT=$(get_most_connection_attempts $LOG_FILE)
            FORMAT=0
            ;;
        2)
            OUTPUT=$(get_most_successful_attempts $LOG_FILE)
            FORMAT=0
            ;;
        t)
            OUTPUT=$(get_most_bytes_received $LOG_FILE)
            FORMAT=0
            ;;
        r)
            OUTPUT=$(get_most_common_codes_ips $LOG_FILE)
            FORMAT=1
            ;;
        F)
            OUTPUT=$(get_most_failures $LOG_FILE)
            FORMAT=1
            ;;
        *)
            echo "No main options were chosen."
            help
            exit 1
            ;;
    esac
}


format_output()
{
    if [ $FORMAT -eq 1 ]
    then
        RESULT_CODES=$(echo "$OUTPUT" | cut -d " " -f1 | uniq)
        if [ -z $LIMIT_LINES ]
        then
            for RESULT_CODE in $RESULT_CODES
            do
                echo "$OUTPUT" | grep "^$RESULT_CODE" | awk '{print $1"\t"$2}'
                echo ""
            done
        else
            for RESULT_CODE in $RESULT_CODES
            do
                echo "$OUTPUT" | grep "^$RESULT_CODE" | awk '{print $1"\t"$2}' | head -n $LIMIT_LINES
                echo ""
            done

        fi
    else
        if [ -z $LIMIT_LINES ]
        then
            echo "$OUTPUT" | awk '{print $1"\t"$2}'
        else
            echo "$OUTPUT" | head -n $LIMIT_LINES | awk '{print $1"\t"$2}'
        fi
    fi
}



main()
{
    handle_args $@
    format_output
}


main $@



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


# cat test_logfile.txt | awk '{print $9,$1}' | grep -E "4[0-9]{2} " | sort | uniq -c | sort -r -n -k2,2 | awk '{print $2,$3}'

ips_from_blacklist()
{
    while read in; do nslookup "$in" | tail -n 2 | grep Address | cut -d " " -f 2; done < dns.blacklist.txt
}

compare_ips()
{
    BLACKLISTED_IPS=$(ips_from_blacklist)

    echo "$OUTPUT" | awk '{for(blacklisted_ip in '"$BLACKLISTED_IPS"')if ($1 == blacklisted_ip) print $1, $2, "*Blacklisted!*"'
    echo "$BLACKLISTED_IPS"
}