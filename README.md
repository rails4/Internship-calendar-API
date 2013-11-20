Calendar API
============

How to join the project
-----------------------

1. Install ruby 2.0 (you can use rvm) `$ rvm get stable && rvm install ruby-2.0.0`
2. Clone app repository: `git clone git@github.com:gotar/Internship-calendar-API.git`
3. Join shelly cloud: `http://shellycloud.com/documentacion/joining_cloud`
4. Inform someone from project to add you to Shelly organization

How to run locally
------------------

1. Install MongoDB: `http://www.mongodb.org/downloads`
2. Start MongoDB
3. Install gems: `$ bundle`
4. Check if all test pass: `$ bundle exec rspec`
5. Run development server: `$ bundle exec rackup`

API Architecture
----------------

Base URL for all requests is: `http://calendar-api.shellyapp.com/`

# Event

## Event index

Request: `GET http://calendar-api.shellyapp.com/events`

Success: returns an hash of events from the database in JSON. In case of no events
returns an empty hash.

## Delete event

Request: `DELETE http://calendar-api.shellyapp.com/event/:id`

Require parameters:

  - `id`: event's id, which has to be deleted.

If successful - returns `200` with "Event has been deleted" message.

In case of problems will return `404 Error` with "Event not found!" message.

# User

## User show

Request: `GET /users/:id`

If success: returns `200 and user attributes in JSON`

If Fail: user with :id not found Returns: `404 'message' => 'User not found'`

## User create

Request: `POST /users`

Require parameters:

* `email`: unique user email
* `password`: crtypted password

If successfull: returns: `200 'message' => 'User create successfully!'`

If Fail: email given in params is already taken Returns: `409 'message' => 'Email already taken'`

If Fail: email and/or password given in params is invalid Returns: `400 'message' => 'Invalid params'`

## User update

Request: `PUT /users/:id`,

with parameters containing `{ email: 'email' }` and/or `{ password: 'password' }`

Success: updates user with id of `:id` with given params
Returns: `200` and `'message' => 'User updated successfully!'`

Fail: user with `:id` not found
Returns: `404` and `'message' => 'User not found'`

Fail: email given in params is already taken
Returns: `409` and `'message' => 'Email already taken'`

Fail: email and/or password given in params is invalid
Returns: `400` and `'message' => 'Invalid params'`

## User delete

Request: `DELETE http://calendar-api.shellyapp.com/user/`

Require parameters:

 - none, current user will be deleted

If successful - returns `200` with "The user has been removed!" message.
If fail: `403` and `'message' => 'Forbidden''


# Event

## Event create

Request: `POST /events`

Require parameters:
* `name`: event name
* `description`: event description
* `category`: event category
* `subcategory`: event subcategory
* `start_time`: event start date with time
* `end_time`: event end date with time
* `city`: event location  city
* `address`: event location adress
* `country`: event location country
* `private`: event private value equale **true** or **false**

If successful: returns `200 'message' => 'Event was successfully created'`

If fail: returns `400 'message' => 'Validation failed: blank params'`

Fail: create new event with end date earlier than start date

Returns: `400` and `'message' => 'Invalid date: end date is earlier than start date'`