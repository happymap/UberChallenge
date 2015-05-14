import sys, MySQLdb, requests, json, httplib




DB_INFO = {'user': 'uberhack', 
'passwd': 'uberhack', 
'host': '127.0.0.1', 
'port': 3306,
'name': 'uberhack'
}

ACTIVE_STATUS = 3
CANCELLED_STATUS = 1
CLOSED_STATUS = 6 

#DB COL positions
USER_ID_POS = 1
CURRENT_LAT_POS = 4
CURRENT_LON_POS = 5
DEST_LAT_POS = 6
DEST_LON_POS = 7
ACCEPT_PRICE_POS = 10


ACTIVE_REQUEST_QUERY = 'select * from Request'# where status =  %d' % ACTIVE_STATUS

connection = httplib.HTTPSConnection('api.parse.com', 443)
connection.connect()

def scan_table():
    try:
        dbconn = MySQLdb.connect(user=DB_INFO['user'], passwd=DB_INFO['passwd'],
            host=DB_INFO['host'], port=DB_INFO['port'], db=DB_INFO['name'])
        cursor = dbconn.cursor()
        query = (ACTIVE_REQUEST_QUERY)
        cursor.execute(query)
        print cursor.fetchall()
        for row in cursor:
            userId = row[USER_ID_POS]
            current_lat = row[CURRENT_LAT_POS]
            current_lon = row[CURRENT_LON_POS]
            dest_lat = row[DEST_LAT_POS]
            dest_lon = row[DEST_LON_POS]
            target_price = row[ACCEPT_PRICE_POS]
            request_uber(current_lat, current_lon, dest_lat, dest_lon, userId, target_price)
            print current_lat, current_lon, dest_lat, dest_lon, userId, target_price

    except Exception, e:
        print e
        print "Failed to connect to mysql db"
        sys.exit(0)

def request_uber(start_lat, start_long, end_lat, end_long, userId, price):
    url = 'https://api.uber.com/v1/estimates/price'
    parameters = {
        'server_token': 'F9nBuEYcivdIOi17iOrtWCMbwwtBy28cW9N4Vq6a',
        'start_latitude': start_lat,
        'start_longitude': start_long,
        'end_latitude': end_lat,
        'end_longitude': end_long
    }

    response = requests.get(url, params=parameters)

    data = response.json()
    print data['prices']
    for ride in data['prices']:
        low_estimate = ride['low_estimate']
        if low_estimate is not None and low_estimate <= price:
            notify_parse(userId, price)
            print ride['low_estimate']
            print price
            break

def notify_parse(userId, price):
    channel = "userId-%d" % userId
    message = "Good news, your target price of %d has been met." % price
    connection.request('POST', '/1/push', json.dumps({
           "channels": [
             channel
           ],
           "data": {
             "alert": message
           }
         }), {
           "X-Parse-Application-Id": "P5wz7xWh6lObh25omhnaK4YElPx4OUKFNYyWKkx4",
           "X-Parse-REST-API-Key": "W1CH7rssFkWuiikvXyGHLcx2XijL549piposYF5a",
           "Content-Type": "application/json"
         })
    result = json.loads(connection.getresponse().read())
    print result

scan_table()