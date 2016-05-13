# FreeSWITCH Push
Some mobile softphones, such as Linphone and Zoiper, allow the signaling server to wake them up with
a push notification. This is a quick script I threw together to send those push notifications from
our FreeSWITCH server.

**Currently this is mostly just an internal script so it's got some annoying hard coded bits. Feel
free to fix those and submit a pull request!**

## Keys
Unfortunately, the way GCM works requires the app to approve the GCM sender, which means you'll need
to compile it yourself and use your own GCM keys. More documentation on this might be forthcoming.
(pull requests gladly accepted)

## Config
Right now the config must be in `/etc/pushkeys.conf`. It looks a bit like this:
```json
{
    "gcm": {
        "9999999999999": "asdf"
    }
}
```
Where `9999999999999` is the GCM app ID and `asdf` is the key. I'd like to move this to a
ConfigParser format eventually.

## Setting up with FreeSWITCH
I have two dialplan rules to make this work. First

`set: sleeptime=${system push.py  push ${destination_number}@${domain_name}}`

and second:

`sleep: ${sleeptime}`

## Other usage
To see all of the registration contact details, just run `push.py status <extension>@<domain>`.

# Warning
I have no idea what I'm doing. Please open an issue if you see something stupid that I did.
