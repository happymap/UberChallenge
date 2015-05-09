from flask_restful import fields, marshal_with, reqparse, Resource, abort
from models import Request
import datetime
import peewee

request_fields = {
  "user_id": fields.Integer,
  "start_latitude": fields.Float,
  "start_longitude": fields.Float,
  "end_latitude": fields.Float,
  "end_longitude": fields.Float,
  "target_price": fields.Float,
  "start_price_estimate": fields.Float,
  "start_time": fields.Integer,

  "request_id": fields.Integer,
  "end_price_estimate": fields.Float,
  "saving": fields.Float,
  "end_time": fields.Integer,
  "product_id": fields.String,
}

request_parser = reqparse.RequestParser()

request_parser.add_argument(
    'user_id', dest='user_id',
    type=int, location='form',
)
request_parser.add_argument(
    'start_latitude', dest='start_latitude',
    type=float, location='form',
)
request_parser.add_argument(
    'start_longitude', dest='start_longitude',
    type=float, location='form',
)
request_parser.add_argument(
    'end_latitude', dest='end_latitude',
    type=float, location='form',
)
request_parser.add_argument(
    'end_longitude', dest='end_longitude',
    type=float, location='form',
)
request_parser.add_argument(
    'target_price', dest='target_price',
    type=float, location='form',
)
request_parser.add_argument(
    'start_price_estimate', dest='start_price_estimate',
    type=float, location='form',
)
request_parser.add_argument(
    'start_time', dest='start_time',
    type=int, location='form',
)
request_parser.add_argument(
    'request_id', dest='request_id',
    type=int, location='form',
)
request_parser.add_argument(
    'end_price_estimate', dest='end_price_estimate',
    type=float, location='form',
)
request_parser.add_argument(
    'saving', dest='saving',
    type=float, location='form',
)
request_parser.add_argument(
    'end_time', dest='end_time',
    type=int, location='form',
)
request_parser.add_argument(
    'product_id', dest='product_id',
    type=str, location='form',
)

class StartRequest(Resource):

    def get(self, id):
        print "called get"

    def post(self):
        args = request_parser.parse_args()
        currentRequest = Request.create(user_id=args.user_id,
                              depart_latitude=args.start_latitude,
                              depart_longitude=args.start_longitude,
                              request_time=datetime.datetime.now())

        return currentRequest.id, 200


class EndRequest(Resource):

    def post(self):
        args = request_parser.parse_args()

        try:
            currentRequest = Request.get(id=args.request_id)
            currentRequest.is_accept = True
            currentRequest.save()
        except peewee.DoesNotExist:
            abort(404, message="Request {} doesn't exist".format(args.request_id))

        return args.request_id, 200








