from flask import Flask, g
from flask_restful import Api
from resources.ApiUser import ApiUser
from resources.ApiRequest import StartRequest, EndRequest, UpdateRequest, CancelRequest
from resources.ApiPriceInquiry import ApiPriceInquiry
from peewee import *

app = Flask(__name__)
api = Api(app)

database = MySQLDatabase('uberhack', **{'password': 'uberhack', 'user': 'uberhack'})

@app.before_request
def before_request():
    g.db = database
    g.db.connect()

# @app.teardown_request
# def teardown_request(exception):
#     db = getattr(g, 'db', None)
#     if db is not None:
#         db.close()

@app.after_request
def after_request(response):
    g.db.close()
    return response

#------------------------------------------------------------

#
# Actually setup the Api resource routing here
#
api.add_resource(ApiUser, '/user/login', '/user/<string:id>')
api.add_resource(StartRequest, '/request/start', '/request/<string:id>')
api.add_resource(EndRequest, '/request/end')
api.add_resource(UpdateRequest, '/request/location')
api.add_resource(CancelRequest, '/request/cancel')


if __name__ == '__main__':
    import logging
    logging.basicConfig(filename='error.log',level=logging.DEBUG)
    app.run(debug=True)
    #app.run('0.0.0.0', port=8080, debug=True)
