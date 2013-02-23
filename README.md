# GUI usage:
To run the GUI:
```
$ racket gui.rkt
```
![ScreenShot](img/ss1.png)

# REPL usage
```
$ racket 
Welcome to Racket v5.3.
-> (require "permissions.rkt")
-> (current-platform)
(platform "Android 2.2.X" 8 "FROYO" #<permission-map>)
-> (lookup-api/re "sms")
'("boolean com.android.contacts.ContactsListActivity$ContactsSearchActivity.smsContact(android.database.Cursor)"
  "boolean com.android.contacts.SearchResultsActivity.smsContact(android.database.Cursor)"
    "boolean com.android.contacts.ContactsListActivity$JoinContactActivity.smsContact(android.database.Cursor)"
      "boolean com.android.contacts.ContactsListActivity.smsContact(android.database.Cursor)")
```

## Find permissions
```
-> (lookup-permission/re "bluetooth")
'("android.permission.BLUETOOTH_ADMIN" "android.permission.BLUETOOTH")
```

## Lookup APIs and their permissions
Note that the lookup-api/re function uses a case sensitive matching:
```
-> (lookup-api/re "sms")
'("boolean com.android.contacts.ContactsListActivity$ContactsSearchActivity.smsContact(android.database.Cursor)"
  "boolean com.android.contacts.SearchResultsActivity.smsContact(android.database.Cursor)"
    "boolean com.android.contacts.ContactsListActivity$JoinContactActivity.smsContact(android.database.Cursor)"
      "boolean com.android.contacts.ContactsListActivity.smsContact(android.database.Cursor)")
```

Now what if you wanted to see for each of these APIs, what permissions do they exercise each individually:
```
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

## Change platform
```
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
