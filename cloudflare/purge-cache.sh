#!/usr/bin/env bash
# https://api.cloudflare.com/#zone-purge-files-by-url

source ~/.cloudflare

CLOUDFLARE_ENDPOINT="purge_cache"

case "$1" in
	"")
	echo "Uso: $0 -aS"
	RETVAL=1
	;;
	-a)
	curl -X POST "https://api.cloudflare.com/client/v4/zones/${CLOUDFLARE_ZONEID}/${CLOUDFLARE_ENDPOINT}" \
		-H "X-Auth-Email: ${CLOUDFLARE_EMAIL}" \
		-H "X-Auth-Key: ${CLOUDFLARE_APIKEY}" \
		-H "Content-Type: application/json" \
		--data '{"purge_everything":true}'
	echo
	;;
	-S)
	if [[ -z $2 ]]; then
		echo "specify a url. Example: https://domain.com/file.txt"
		exit
	fi
	URL=$2
	curl -X POST "https://api.cloudflare.com/client/v4/zones/${CLOUDFLARE_ZONEID}/${CLOUDFLARE_ENDPOINT}" \
	-H "X-Auth-Email: ${CLOUDFLARE_EMAIL}" \
	-H "X-Auth-Key: ${CLOUDFLARE_APIKEY}" \
	-H "Content-Type: application/json" \
	--data '{"files":["'${URL}'"]}'
	echo
	;;
esac
