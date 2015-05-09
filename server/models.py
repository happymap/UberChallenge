# Database: uberhack
# Peewee version: 2.5.1

from peewee import *

database = MySQLDatabase('uberhack', **{'password': 'uberhack', 'user': 'uberhack'})

class UnknownField(object):
    pass

class BaseModel(Model):
    class Meta:
        database = database

class User(BaseModel):
    email = CharField(null=True)
    first_name = CharField(null=True)
    id = PrimaryKeyField()
    last_name = CharField(null=True)
    register_time = DateTimeField(null=True)
    token = CharField(null=True)
    uber_picture = CharField(null=True)
    uber_promo_code = CharField(null=True)
    uber_uuid = CharField(null=True)

    class Meta:
        db_table = 'User'

class Request(BaseModel):
    accept_price = DecimalField(null=True)
    board_price = DecimalField(null=True)
    depart_latitude = DecimalField(null=True)
    depart_longtitude = DecimalField(null=True)
    depart_price = DecimalField(null=True)
    dest_latitude = DecimalField(null=True)
    dest_longtitude = DecimalField(null=True)
    id = PrimaryKeyField()
    is_accept = IntegerField(null=True)
    is_active = IntegerField(null=True)
    is_find = IntegerField(null=True)
    request_time = DateTimeField(null=True)
    uber_request_id = CharField(db_column='uber_request_id', null=True)
    #user_id = ForeignKeyField(User, related_name='requests')
    user_id = IntegerField(null=True)

    class Meta:
        db_table = 'Request'

class PriceInquiry(BaseModel):
    best_price_upper = IntegerField(null=True)
    current_latitude = DecimalField(null=True)
    current_longtitude = DecimalField(null=True)
    distance = FloatField(null=True)
    id = BigIntegerField(primary_key=True)
    request_id = ForeignKeyField(Request, related_name='prices')
    uber_currency = CharField(null=True)
    uber_display_name = CharField(null=True)
    uber_duration = IntegerField(null=True)
    uber_product_id = CharField(db_column='uber_product_id', null=True)

    class Meta:
        db_table = 'Price_Inquiry'
