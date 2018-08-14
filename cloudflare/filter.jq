#!/usr/bin/env bash
# filter and send to elasticsearch
case "$1" in
	"")
	echo "Uso: $0 -uri|-nouri"
	;;
	#change startswitch value
	-uri)
		cat * | \
		jq 'select(.ClientRequestURI | startswith("/someuri"))
		| .EdgeEndTimestamp |= ((((  tostring ) | .[0:13] ) | tonumber))' | \
		jq -s 'reduce range(0,length) as $i ( . ; .[$i].RayID = "\($i+1)") |.[]' -c | \
		curl -s -o /dev/null -XPOST localhost:9200/cloudflare/_bulk --data-binary @-
	;;
	-nouri)
		cat * | \
        	jq ' .EdgeEndTimestamp |= ((((  tostring ) | .[0:13] ) | tonumber))' | \
        	jq -s 'reduce range(0,length) as $i ( . ; .[$i].RayID = "\($i+1)") |.[]' -c | \
		jq -c '. | {"index": {"_index": "cloudflare", "_type": "logs", "_id": .RayID}}, .' | \
        	curl -s -o /dev/null -XPOST localhost:9200/cloudflare/_bulk --data-binary @-\
	;;
esac
