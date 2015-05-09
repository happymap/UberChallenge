from flask_restful import fields, marshal_with, reqparse, Resource, abort
from models import User
import datetime
import peewee

request_fields = {
  "first_name": fields.String,
  "last_name": fields.String,
  "email": fields.String,
  "picture": fields.String,
  "uber_uuid": fields.String,
  "token": fields.String,
  "refresh_token": fields.String,
  "token_expires": fields.Integer,
}

user_parser = reqparse.RequestParser()

user_parser.add_argument(
    'first_name', dest='first_name',
    type=str, location='form',
)
user_parser.add_argument(
    'last_name', dest='last_name',
    type=str, location='form',
)
user_parser.add_argument(
    'email', dest='email',
    type=str, location='form',
)
user_parser.add_argument(
    'picture', dest='picture',
    type=str, location='form',
)
user_parser.add_argument(
    'uber_uuid', dest='uber_uuid',
    type=str, location='form',
)
user_parser.add_argument(
    'token', dest='token',
    type=str, location='form',
)
user_parser.add_argument(
    'refresh_token', dest='refresh_token',
    type=str, location='form',
)
user_parser.add_argument(
    'token_expires', dest='token_expires',
    type=str, location='form',
)

class ApiUser(Resource):
    def post(self):

        args = user_parser.parse_args()

        try:
            currentUser = User.get(id=args.uber_uuid)
        except peewee.DoesNotExist:
            currentUser = User.create(first_name = args.first_name,
                                      last_name = args.last_name,
                                      email = args.email,
                                      uber_picture = args.picture,
                                      uber_uuid = args.uber_uuid,
                                      token = args.token,
                                      register_time = datetime.datetime.now())

        return currentUser.id, 200





