#!/usr/local/Cellar/bash/4.4.23/bin/bash
# bash paranoia mode
# Needs bash 4+
#
#set -o pipefail
#set -x
#export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

ERRCount=0
declare -A ERRHash

erro() {
  code=$1
  line=$2
  ERRCount=$(expr $ERRCount + $code)
  ERRHash[Line $line]="Code:$code"
}

trap "erro \$? \$LINENO " ERR

true
true
false
true
true
false
true
true
false

for K in "${!ERRHash[@]}";
do
	echo $K --- ${ERRHash[$K]};
done

exit $ERRCount
