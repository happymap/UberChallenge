# Code generated by:
# python -m pwiz -e mysql -u uberhack -i uberhack -P uberhack
# Date: May 09, 2015 05:29PM
# Database: uberhack
# Peewee version: 2.5.1

from peewee import *

database = MySQLDatabase('uberhack', **{'password': 'uberhack', 'user': 'uberhack'})

class UnknownField(object):
    pass

class BaseModel(Model):
    class Meta:
        database = database

class PriceInquiry(BaseModel):
    best_price_upper = IntegerField(null=True)
    current_latitude = DecimalField(null=True)
    current_longtitude = DecimalField(null=True)
    distance = FloatField(null=True)
    id = PrimaryKeyField()
    request = BigIntegerField(db_column='request_id', null=True)
    uber_currency = CharField(null=True)
    uber_display_name = CharField(null=True)
    uber_duration = IntegerField(null=True)
    uber_product = CharField(db_column='uber_product_id', null=True)

    class Meta:
        db_table = 'Price_Inquiry'

class Request(BaseModel):
    accept_price = DecimalField(null=True)
    board_price = DecimalField(null=True)
    current_latitude = DecimalField(null=True)
    current_longtitude = DecimalField(null=True)
    depart_latitude = DecimalField(null=True)
    depart_longtitude = DecimalField(null=True)
    depart_price = DecimalField(null=True)
    dest_latitude = DecimalField(null=True)
    dest_longtitude = DecimalField(null=True)
    id = PrimaryKeyField()
    parse_key = CharField(null=True)
    request_time = DateTimeField(null=True)
    status = IntegerField(null=True)
    uber_request = CharField(db_column='uber_request_id', null=True)
    user = IntegerField(db_column='user_id', null=True)
    product = CharField(db_column='product_id', null=True)

    class Meta:
        db_table = 'Request'

class User(BaseModel):
    email = CharField(null=True)
    first_name = CharField(null=True)
    id = PrimaryKeyField()
    last_name = CharField(null=True)
    refresh_token = CharField(null=True)
    register_time = DateTimeField(null=True)
    token = CharField(null=True)
    token_expires = IntegerField(null=True)
    uber_picture = CharField(null=True)
    uber_promo_code = CharField(null=True)
    uber_uuid = CharField(null=True)

    class Meta:
        db_table = 'User'

