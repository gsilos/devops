#!/usr/bin/env python

import requests
import json

def notifyslack(msg, level=0):

    if level == 1:
        icon_emoji = ":exclamation:"
    elif level == 2:
        icon_emoji = ":warning:"
    else:
        icon_emoji = ":panda_face:"

    data = {
        "channel": "#channelname",
        "username": "botname",
        "text": msg,
        "icon_emoji": icon_emoji
    }

    requests.post(
        'https://hooks.slack.com/services/XXXXXXXXX/XXXXXXXXX/XXXXXXXXXXXXXXXXXXXXXXXX',
        data=json.dumps(data)
    )

notifyslack("hello world")
