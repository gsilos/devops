#!/usr/bin/env bash
echo "please remember to fill your cloudflare credentials, zoneid..."
CLOUDFLARE_EMAIL=email@domain
CLOUDFLARE_APIKEY=hash_api_key
CLOUDFLARE_ZONEID=hash_zone_id

# Time math is relative to what time is now.
QUERY_TIME_RANGE=60		# 60 minutes means: the range we want to collect records. it can be from 1 to 60.
CLOUDFLARE_DELAY_LIMIT=5	# 5 minutes means: cloudflare cant show records younger than 5 minutes.
QUERY_TIME_START=`expr $QUERY_TIME_RANGE + $CLOUDFLARE_DELAY_LIMIT`
QUERY_TIME_END=`expr $CLOUDFLARE_DELAY_LIMIT`
RELATIVE_TIME_START=0		# in hours. zero means now. 1 means, from 1 hour ago... and so on.
LOGEXTENSION=0

# check if jq is installed

which jq
if [ $? -ne 0 ]; then
        echo "required: install https://stedolan.github.io/jq/"
        exit
fi

#Adjust relative time
if [[ !  -z  $1  ]]; then
	if [ "$1" -gt "0" ]; then
		RELATIVE_TIME_START=$(expr $1 \* 60)
		LOGEXTENSION=$1
	fi
fi
TMPLOG=./cloudflare.log.$LOGEXTENSION

# So... how much log can we collect? Cloudflare only retain the last 72hours of logs.
# Each request to the /logs/received endpoint can retrieve a maximum 1 hour range.
# The setup above is configuring start/end to take the last hour.
# CET to UTC is applied here.

os=`uname`
if [ $os = "Darwin" ]; then
	start=`date -u -v -${QUERY_TIME_START}M -v -${RELATIVE_TIME_START}M "+%Y-%m-%dT%H:%M:%SZ"`
	end=`date -u -v -${QUERY_TIME_END}M -v -${RELATIVE_TIME_START}M "+%Y-%m-%dT%H:%M:%SZ"`
elif [ $os = "Linux" ]; then
  # TODO: apply relative time here.
	start=`date --utc  -d '${QUERY_TIME_START} minutes ago' +'%Y-%m-%dT%H:%M:%SZ'`
	end=`date --utc -d '${QUERY_TIME_END} minutes ago' +'%Y-%m-%dT%H:%M:%SZ'`
else
	echo "change-me, or run me in linux or macos."
	exit
fi

# Get records from the API and save it to TMPLOG

echo "Collecting logs for $RELATIVE_TIME_START"
curl -o ${TMPLOG} -H "X-Auth-Email: ${CLOUDFLARE_EMAIL}" -H "X-Auth-Key: ${CLOUDFLARE_APIKEY}" "https://api.cloudflare.com/client/v4/zones/${CLOUDFLARE_ZONEID}/logs/received?start=${start}&end=${end}&fields=ClientIP,ClientDeviceType,ClientRequestProtocol,ClientRequestHost,ClientRequestMethod,ClientRequestURI,ClientRequestUserAgent,EdgeResponseStatus,EdgeResponseBytes,EdgeEndTimestamp,RayID,CacheResponseStatus,CacheCacheStatus,OriginIP"

# query/filter the TMPLOG to show the top 10 404.

#jq 'select(.EdgeResponseStatus == 404) | .ClientRequestURI' "${TMPLOG}.${RELATIVE_TIME_START}" | sort -n | uniq -c | sort -nr | head -10
