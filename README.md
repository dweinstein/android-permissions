# Get racket and this code
* Grab the racket language from http://racket-lang.org/download/
* Add the 'racket' binary to your path:
``` $ export PATH="/Users/user/Downloads/Local Applications/Racket\ v5.3/bin/:${PATH}" ```
* Download this code: 
```
$ git clone git@github.com:dweinstein/android-permissions.git
```
* You can either run DrRacket and load the 'gui.rkt' file and run it, or use the terminal:

# GUI usage:
To run the GUI (open a terminal and navigate to this directory):
```
$ racket gui.rkt
```
![ScreenShot](img/ss1.png)

# REPL usage
```racket
$ racket 
Welcome to Racket v5.3.
-> (require "permissions.rkt")
-> (current-platform)
(platform "Android 2.2.X" 8 "FROYO" #<permission-map>)
```
## API available
From https://github.com/dweinstein/android-permissions/blob/master/permissions.rkt
```racket
(provide platform-for-version
         lookup/perm->apis
         lookup/api->perm
         lookup-permission/re
         lookup-api/re
         get-platform-strings
         get-permission-strings
         current-platform)
```

## Change platform
By changing the 'current-platform' you can adjust the context of the methods when doing lookup operations.

```racket
-> (current-platform)
(platform "Android 2.2.X" 8 "FROYO" #<permission-map>)
-> (current-platform 'ics)
-> (current-platform)
(platform
 "Android 4.0, 4.0.1, 4.0.2"
  14
   "ICE_CREAM_SANDWICH"
    #<permission-map>)
```

## Find permissions
```racket
-> (lookup-permission/re "bluetooth")
'("android.permission.BLUETOOTH_ADMIN" "android.permission.BLUETOOTH")
```

## Lookup APIs and their permissions
Note that the lookup-api/re function uses a case sensitive matching:
```racket
-> (lookup-api/re "sms")
'("boolean com.android.contacts.ContactsListActivity$ContactsSearchActivity.smsContact(android.database.Cursor)"
  "boolean com.android.contacts.SearchResultsActivity.smsContact(android.database.Cursor)"
    "boolean com.android.contacts.ContactsListActivity$JoinContactActivity.smsContact(android.database.Cursor)"
      "boolean com.android.contacts.ContactsListActivity.smsContact(android.database.Cursor)")
```

Now what if you wanted to see for each of these APIs, what permissions do they exercise each individually:
```racket
-> (map (lambda (api) 
            (lookup/api->perm api)) 
        (lookup-api/re "sms"))
'(("android.permission.GET_ACCOUNTS"
      "android.permission.WRITE_CONTACTS"
      "android.permission.READ_CONTACTS")
  ("android.permission.GET_ACCOUNTS"
     "android.permission.WRITE_CONTACTS"
      "android.permission.READ_CONTACTS")
  ("android.permission.GET_ACCOUNTS"
      "android.permission.WRITE_CONTACTS"
      "android.permission.READ_CONTACTS")
  ("android.permission.GET_ACCOUNTS"
      "android.permission.WRITE_CONTACTS"
      "android.permission.READ_CONTACTS"))
```

Now we see that they all somehow interact with GET_ACCOUNTS, WRITE_CONTACTS, and READ_CONTACTS.

