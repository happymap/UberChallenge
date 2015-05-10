from flask_restful import fields, marshal_with, reqparse, Resource, abort
from models import Request
import datetime
import peewee

request_fields = {
  "user_id": fields.Integer,
  "dest_latitude": fields.Float,
  "dest_longitude": fields.Float,
  "target_price": fields.Integer,
  "start_price_estimate": fields.Integer,
  "depart_latitude": fields.Float,
  "depart_longitude": fields.Float,

  "request_id": fields.Integer,
  "end_price_estimate": fields.Integer,
  "product_id": fields.String,

  "current_latitude": fields.Float,
  "current_longitude": fields.Float,
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
    type=int, location='form',
)
request_parser.add_argument(
    'start_price_estimate', dest='start_price_estimate',
    type=int, location='form',
)
request_parser.add_argument(
    'request_id', dest='request_id',
    type=int, location='form',
)
request_parser.add_argument(
    'end_price_estimate', dest='end_price_estimate',
    type=int, location='form',
)
request_parser.add_argument(
    'product_id', dest='product_id',
    type=str, location='form',
)
request_parser.add_argument(
    'current_latitude', dest='current_latitude',
    type=float, location='form',
)
request_parser.add_argument(
    'current_longitude', dest='current_longitude',
    type=float, location='form',
)

class StartRequest(Resource):

    @marshal_with(request_fields)
    def get(self, id):
        try:
            currentRequest = Request.get(id = id)
        except peewee.DoesNotExist:
            abort(404, message="Request {} doesn't exist".format(args.request_id))

        return currentRequest

    def post(self):
        args = request_parser.parse_args()
        currentRequest = Request.create(user = args.user_id,
                              depart_latitude = args.start_latitude,
                              depart_longitude = args.start_longitude,
                              request_time = datetime.datetime.now(),
                              dest_latitude = args.end_latitude,
                              dest_longitude = args.end_longitude,
                              accept_price = args.target_price,
                              depart_price = args.start_price_estimate,
                              status = 3)

        return currentRequest.id, 200

class UpdateRequest(Resource):

    def post(self):
        args = request_parser.parse_args()

        try:
            currentRequest = Request.get(id = args.request_id)
            currentRequest.current_latitude = args.current_latitude
            currentRequest.current_longitude = args.current_longitude
            currentRequest.save()
        except peewee.DoesNotExist:
            abort(404, message="Request {} doesn't exist".format(args.request_id))

        return currentRequest.id, 200


class EndRequest(Resource):

    def post(self):
        args = request_parser.parse_args()

        try:
            currentRequest = Request.get(id = args.request_id)
            currentRequest.status = 6 # status: the request is closed
            currentRequest.board_price = args.end_price_estimate
            currentRequest.product = args.product_id
            currentRequest.save()
        except peewee.DoesNotExist:
            abort(404, message="Request {} doesn't exist".format(args.request_id))

        return args.request_id, 200








