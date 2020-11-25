# FreeSWITCH Push
Some mobile softphones, such as Linphone and Zoiper, allow the signaling server to wake them up with
a push notification. This is a quick script I threw together to send those push notifications from
our FreeSWITCH server.

**Currently this is mostly just an internal script so it's got some annoying hard coded bits. Feel
free to fix those and submit a pull request! Right now it only supports linphone**

## Keys
Unfortunately, the way GCM works requires the app to approve the GCM sender, which means you'll need
to compile it yourself and use your own GCM keys. More documentation on this might be forthcoming.
(pull requests gladly accepted)

## Config
Right now you will need to put your google-account.json from firebase here
```
/etc/firebase/google-account.json
```


## Setting up with FreeSWITCH
Corrently you will need the following dependencies
* [lua-firebase](https://github.com/mopo3ilo/lua-firebase)
* lua-cjson
* lua-basexx
* lua-luaossl
<br><br>Better details comming soon™

# Warning
I have no idea what I'm doing. Please open an issue if you see something stupid that I did.
