function notify {
	DST=123456789
	BOTID=123456789:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	MSG=$1
	curl --connect-timeout 3 -s -o /dev/null https://api.telegram.org/bot${BOTID}/sendMessage?chat_id="$DST"\&text="$MSG"
}
