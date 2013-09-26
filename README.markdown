Tangerine for iOS
-----------------

Welcome to tangerine-ios based on Couchbase-lite

This project works slightly different than most couchbase-lite apps as the couchbase-lite
project is included as a subproject. Because of this you need to deal with multiple
levels of submodules. These submodules relies on several forks.

Clone this repo:

    git clone https://github.com/jeffrafter/tangerine-ios.git

Go into the project and get the first layer of submodules

    git submodule init
    git submodule update

This should fetch both couchbase-lite-ios and Tangerine-community.

Now you need the submodules for couchbase-lite

    cd couchbase-lite-ios
    git submodule init
    git submodule update

At this point you should be able to open the XCode project. Compile for the iOS 7.0 iPad
simulator. Everything should run and you should see some logging saying that

    2013-09-26 00:51:23.548 Tangerine[68848:a0b] Listening on http://localhost:59840/tangerine/_design/tangerine/index.html#login
    2013-09-26 00:51:23.620 Tangerine[68848:a0b] View loaded
    2013-09-26 00:51:23.622 Tangerine[68848:a0b] Database loaded
    2013-09-26 00:51:23.624 Tangerine[68848:a0b] View loaded

All you should see is a white screen with a Start button. If you click that now, you'll
see a 404 and then need to restart the app. At this point you'll want to setup the
couchapp. There are three strategies for this:

1. Replicate from a local or remote couchdb (in AppDelegate change #define noreplicate to replicate)
2. Load from a bundled cblite (in AppDelegate change #define nobundled to bundled)
3. couchapp push to the running server

We'll try the couchapp push. Change to the Tangerine-community/app directory. You'll need to
create a .couchapprc file:

    {
      "env" : {
        "default" : {
          "db" : "http://admin:password@localhost:59840/tangerine"
        }
      }
    }

From this point you should be able to push (from the app folder)

    $ /usr/local/share/python/couchapp push
    2013-09-26 00:58:21 [INFO] Visit your CouchApp here:
    http://localhost:59840/tangerine/_design/tangerine/index.html

Back in the simulator, clicking Start (and waiting a very long time) will yield an orange bar (sometimes).
It should give you a login screen (where you can use the credentials: admin/password).

If you want to see what is happening you can change CBLHTTPResponse.m to EnableLog

    EnableLog(YES);
    EnableLogTo(CBLListenerVerbose, YES);


