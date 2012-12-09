Example usage:

racket@permissions.rkt> (lookup-permission/re "wifi")
'("android.permission.CHANGE_WIFI_STATE"
  "android.permission.CHANGE_WIFI_MULTICAST_STATE"
    "android.permission.ACCESS_WIFI_STATE")

racket@permissions.rkt> (current-permission-map)
#<permission-map>

racket@permissions.rkt> (permission-map-platform (current-permission-map))
(platform "Android 2.2.X" 8 "FROYO")

racket@permissions.rkt> (platform-api-level (permission-map-platform (current-permission-map)))
8

