#!/usr/bin/env python
"""FreeSWITCH Push.

Send GCM/Apple Push/Windows Phone Push notifications to mobile softphones.
"""
import sys
import requests
import ESL
import json
con = ESL.ESLconnection("127.0.0.1", "8021", "ClueCon")


keys = json.load(open("/etc/pushkeys.conf"))


def parse_contact(unparse):
    """parse_reg(contact): parses FreeSWITCH registration strings.

    Parameters:
        * contact: a single contact string. The sofia_contact function returns a comma separated
                   list of all of the contact strings for a given extension
    Returns:
        a dict of all of the variables in the contact string, or False if the string is an error
"""
    components = unparse.split(";")
    c = components[0].split("/", 2)
    if c[0] == "error":
        return False
    args = {}
    for component in components[1:]:
        if "=" in component:
            key, value = component.strip().split("=", 2)
            args[key] = value
        else:
            args[component.strip()] = None
    out = {
        "args": args,
        "profile": None,
        "uri": None
    }
    if len(c) > 1:
        out["profile"] = c[1]
    if len(c) > 2:
        out["uri"] = c[2]
    return out


def zoiper(url):
    """Send a Zoiper push notification to a WP8 device."""
    headers = {"Content-Type": "text/xml", "X-NotificationClass": 4}
    postdata = """<?xml version="1.0" encoding="utf-8"?><root><Value1>Zoiper</Value1><Value2>Incoming</Value2><Value3>Call</Value3></root>"""
    requests.post(url, data=postdata, headers=headers)


def gcm(key, token, data=None):
    """Send a GCM push notification."""
    url = "https://gcm-http.googleapis.com/gcm/send"
    headers = {
        "Authorization": "key=%s" % keys['gcm'][key],
        "Content-Type": "application/json"
    }
    postdata = {"to": token}
    if data is not None:
        postdata['data'] = data
    requests.post(url, data=json.dumps(postdata), headers=headers)


def linphone(args):
    """Trigger a push notification for Linphone."""
    if args['pn-type'] == "google":
        if args['app-id'] in keys['gcm']:
            gcm(args['app-id'], args['pn-tok'])

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: %s [action] [extension@realm]" % sys.argv[0])
        print("\nThe following actions are supported:")
        print(" * push - checks all of the contact strings stored for the extension and sends them push notifications if applicable")
        print(" * status - displays all of the contact strings, mostly for debugging")
    else:
        action = sys.argv[1]
        contacts = con.api("sofia_contact %s" % sys.argv[2]).getBody().split(",")
        if action == "push":
            delay = 0
            for contact in contacts:
                c = parse_contact(contact)
                if c:
                    if "X-PUSH-URI" in c['args']:
                        zoiper(c['args']['X-PUSH-URI'])
                        if delay < 2000:
                            delay = 2000
                    elif "pn-type" in c['args']:
                        linphone(c['args'])
                        if delay < 2000:
                            delay = 2000
            print(str(delay))
        elif action == "status":
            for contact in contacts:
                c = parse_contact(contact)
                if c:
                    print("\n%s on profile %s" % (c['uri'], c['profile']))
                    for i in c['args']:
                        print(" * %s:\t%s" % (i, c['args'][i]))
                else:
                    print("No contact found")
