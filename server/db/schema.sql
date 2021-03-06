
USE uberhack;

DROP TABLE IF EXISTS User;

/* User table is to store basic user profile data.*/
CREATE TABLE User(
	id BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	/* From Uber user profile data */
	token VARCHAR(255), # not sure how long the access token is in uber
	first_name VARCHAR(30),
	last_name VARCHAR(30),
	email VARCHAR(30),
	uber_picture VARCHAR(2083), # an url points to the picture
	uber_promo_code VARCHAR(20),
	uber_uuid VARCHAR(36),# uuid consists of 36 characters - 32 hex digits + 4 dashes
	/* Our user data*/
	register_time DATETIME,
	refresh_token VARCHAR(255),
	token_expires INT
);

DROP TABLE IF EXISTS Request;

/* Request table is used to store basic request information for one app request (not uber request) per user */
CREATE TABLE Request (
	id BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	user_id BIGINT, # reference to User's id
	depart_latitude DECIMAL(10,6),
	depart_longitude DECIMAL(10,6),
	current_latitude DECIMAL(10,6),
	current_longitude DECIMAL(10,6),
	dest_latitude DECIMAL(10,6),
	dest_longitude DECIMAL(10,6), # since we might use google map api, according to
	                               # https://developers.google.com/maps/articles/phpsqlsearch_v3?csw=1
	depart_price DECIMAL(5,2), # the uber estimated price at where the user depart
	board_price DECIMAL(5, 2), # the uber estimated price at where the user get on the uber car
	accept_price DECIMAL(5,2), # the price target the user can accept

	request_time DATETIME, # the date time when the user starts this request
	status TINYINT, # 3 when request is created -- at the point when user start a request
	                # 6 when request is closed. -- at the point when user is on board
	uber_request_id VARCHAR(36), # uuid
	parse_key VARCHAR(255), # key for Parse
	product_id VARCHAR(255)
);

DROP TABLE IF EXISTS Price_Inquiry;
/* PriceInquiry table is used to store best estimated price info from Uber's estimate price API
   Note: Uber's response will be a set of products but we only store the one with best upper bound
   price here.*/
CREATE TABLE Price_Inquiry (
	id BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	request_id BIGINT, # reference to Request's id
 	current_latitude DECIMAL(10,6),
	current_longitude DECIMAL(10,6),
	best_price_upper INT, #the lowest upper bound price we get
	uber_product_id VARCHAR(36), # the product id with that price
	uber_currency VARCHAR(5), # ISO 4217 currency code
	uber_display_name VARCHAR(36),
	uber_duration INT, # Expected activity duration (in seconds). Always show duration in minutes.
	distance FLOAT # Expected activity distance (in miles).
);







