
USE uberhack;

DROP TABLE IF EXISTS User;

/* User table is to store basic user profile data.*/
CREATE TABLE User(
	id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	/* From Uber user profile data */
	token VARCHAR(255), # not sure how long the access token is in uber
	first_name VARCHAR(30),
	last_name VARCHAR(30),
	email VARCHAR(30),
	uber_picture VARCHAR(2083), # an url points to the picture
	uber_promo_code VARCHAR(20),
	uber_uuid VARCHAR(36),# uuid consists of 36 characters - 32 hex digits + 4 dashes
	/* Our user data*/
	register_time DATETIME
);

DROP TABLE IF EXISTS Request;

/* Request table is used to store basic request information for one app request (not uber request) per user */
CREATE TABLE Request (
	id BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	user_id INT, # reference to User's id
	depart_latitude DECIMAL(10,6),
	depart_longtitude DECIMAL(10,6),
	dest_latitude DECIMAL(10,6),
	dest_longtitude DECIMAL(10,6), # since we might use google map api, according to
	                               # https://developers.google.com/maps/articles/phpsqlsearch_v3?csw=1
	depart_price DECIMAL(5,2), # the uber estimated price at where the user depart
	board_price DECIMAL(5, 2), # the uber estimated price at where the user get on the uber car
	accept_price DECIMAL(5,2), # the price target the user can accept

	request_time DATETIME, # the date time when the user starts this request

	is_accept TINYINT(1),  # If the user accepts the this request at last
	is_active TINYINT(1), # If this request is still active
	is_find TINYINT(1), # If we find at least one uber that can satisfy user's request
	uber_request_id VARCHAR(36) # uuid
);





