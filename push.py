import json,httplib
connection = httplib.HTTPSConnection('api.parse.com', 443)
connection.connect()
connection.request('POST', '/1/push', json.dumps({
       "channels": [
         "userId-11"
       ],
       "data": {
         "alert": "Hi yifan"
       }
     }), {
       "X-Parse-Application-Id": "P5wz7xWh6lObh25omhnaK4YElPx4OUKFNYyWKkx4",
       "X-Parse-REST-API-Key": "W1CH7rssFkWuiikvXyGHLcx2XijL549piposYF5a",
       "Content-Type": "application/json"
     })
result = json.loads(connection.getresponse().read())
print result
