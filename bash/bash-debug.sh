#!/bin/bash

# Be paranoid about what is going on...
PS4='${FUNCNAME[0]} (${LINENO}): '
set -x
trap "error_report \$? \$LINENO " ERR
RRCount=0
declare -A ERRHash

# Functions

function createjob() {

jobname=$1
    
if [ -z "$jobname" ]
then
	echo "job name was not specified"
	exit 1
fi

branch=$2

if [ -z "$branch" ]
then
      echo "branch was not specified"
      exit 1
fi

APIUSER=curl
APIKEY=value
TOKEN=value
JOB=$jobname
BRANCH=$branch
JENKINSFQDN=jenkins.domain.net
CURLOPT="-s --connect-timeout 5 -u ${APIUSER}:${APIKEY}"

curlanswer=$(curl ${CURLOPT} -I -X POST http://$JENKINSFQDN/view/devops/job/${JOB}/buildWithParameters?sha1=${branch})
#curlanswer=$(curl ${CURLOPT} -I -X POST http://$JENKINSFQDN/view/devops/job/${JOB}/build?token=${TOKEN})
RET=$?

# Trying to create the job
if [[ $RET -eq 0 ]]; then

	if [[ "$curlanswer" = *Created* ]]; then
		if [[ "$curlanswer" = *Location* ]]; then
			location=$(echo "$curlanswer" | grep Location | awk '{print $2}' | tr '\r' '\n')
		else
			echo "No Location found"
			exit 1
		fi
	else
		echo No Job Created
		exit 1
	fi

else

	echo Something went wrong while curling $JENKINSFQDN. Here is the error
	echo "$curlanswer"
	echo "Here is the return code: $RET"
	exit 1

fi

# Job was created
queuestatus="${location}api/json"

try=30

while [ $try -ne 0 ] 
do
	echo Pooling jenkins to get triggered JOB ID. Pool it for $try times, then if it fails, we ignore it.
	curlanswer=$(curl $CURLOPT -X GET $queuestatus)
	RET=$?

	if [[ $RET -eq 0 ]]; then
		echo "$curlanswer" | jq -r ' .executable.url '|grep -q --color=never http
		if [[ $? -eq 0 ]]; then
			job=$(echo "$curlanswer" | jq -r ' .executable.url')
        	echo job ${JOB} started
        	echo $job
            break
		elif [[ $(echo "$curlanswer" | jq -r ' .why') = *Waiting* ]]; then
			echo Jenkins is taking some time... lets give it more $try times...
			echo "Curl Answered: $curlanswer"
			echo "curl returned $RET"
        else
        	echo Something weird happened. but we wont give up. Lets try more $try times...
			echo "Curl Answered: $curlanswer"
			echo "curl returned $RET"
		fi
	else
		echo Something went wrong while getting JOB STATUS at $JENKINSFQDN. I will try more $try times.
		echo "Curl Answered: $curlanswer"
		echo "curl returned: $RET"
	fi
    
    try=$((try-1))
    sleep 1 
    
done

}

function error_report() {
  code=$1
  line=$2
  ERRCount=$(expr $ERRCount + $code)
  ERRHash[Line $line]="Return Code: $code"
}

function error_care() {
  code=$1
  message=$2
  if [ $code != 0 ]; then
    echo "CRITICAL: $message"
    exit 1
  fi
}

function notifyslack() {

msg=$1
slack=https://hooks.slack.com/services/XXXXXXXXX/XXXXXXXXXX/XXXXXXXXXXXXXXXXXXXXXXXX

slackresponse=$(curl -s -X POST -d @- $slack <<EOF
{ 
	"username": "cool username", 
	"channel" : "#channel" , 
	"icon_emoji" : ":ok:" , 
	"text" : "$msg" 
}
EOF
)

RET=$?

echo "curl answered: $slackresponse"
echo "curl returned: $RET"

}

# End Functions

# Main

###################################
# commands for this job starts here
###################################

true
false
true
key1="var1"
key2="var2"

notifyslack "<!here>, \`${key1}\` \`${key2}\`"

#################################
# commands for this job ends here
#################################

for K in "${!ERRHash[@]}";
do
	echo $K --- ${ERRHash[$K]};
done

exit $ERRCount

# End Main
