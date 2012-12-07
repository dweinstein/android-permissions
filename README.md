Example usage:

racket@permissions.rkt> (lookup-permission/re (platform->permission-map 'froyo) "wifi")
'("android.permission.CHANGE_WIFI_STATE"
  "android.permission.CHANGE_WIFI_MULTICAST_STATE"
  "android.permission.ACCESS_WIFI_STATE")

