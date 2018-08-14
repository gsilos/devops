#!/usr/bin/env bash

cd /path/to/data
echo removing old data from elasticsearch
curl -X DELETE localhost:9200/cloudflare
echo -en '\ncreating schema in elasticsearch\n'
curl -X PUT localhost:9200/cloudflare --data-binary @/path/to/cloudflare-mapping.json
echo -en '\n'

echo filtering and loading into elasticsearch
../filter.jq $1

echo "now go to kibana and have fun"
