Calendar API
============

API Architecture:
-------------
  
Base URL for all requests is: `http://calendar-api.shellyapp.com/`

# Event

## Event index

Request: `GET http://calendar-api.shellyapp.com/events`

Success: returns an hash of events from the database in JSON. In case of no events
returns an empty hash.

## Event show

Request: `GET http://calendar-api.shellyapp.com/event/:id`

Require parameters:

  - `id`: event's id, which has to be showed.

If successful fetch event: returns `200` with event description in JSON.

If fails when there is no event: return `404 'message' => 'Expected event with given id is not found!'`.

If fails when : return `401 'message' => 'Don't have rights to show this event'`

## Delete event

Request: `DELETE http://calendar-api.shellyapp.com/event/:id`

Require parameters:

  - `id`: event's id, which has to be deleted.

If successful - returns `200` with "Event has been deleted" message.

In case of problems will return `404 Error` with "Event not found!" message.

# User

## User index

Request: `GET http://calendar-api.shellyapp.com/users`

Success: returns an array of users in the database in JSON. In case of no users
returns an empty array.

## User show

Request: `GET http://calendar-api.shellyapp.com/users/:id`

Success: returns HTTP 200 code and user attributes in JSON

Fail: user with `:id` not found
Returns: `404` and `'message' => 'User not found'`

## User create

Request: `POST http://calendar-api.shellyapp.com/users`,
with parameters containing `{ email: 'email' }` and `{ password: 'password' }`

Success: creates user with given params
Returns: `200` and `'message' => 'User created successfully'`

Fail: email given in params is already taken
Returns: `409` and `'message' => 'Email already taken'`

Fail: email and/or password given in params is invalid
Returns: `400` and `'message' => 'Invalid params'`

## User update

Request: `PUT http://calendar-api.shellyapp.com/users/:id`,
with parameters containing `{ email: 'email' }` and/or `{ password: 'password' }`

Success: updates user with id of `:id` with given params
Returns: `200` and `'message' => 'User updated successfully'`

Fail: user with `:id` not found
Returns: `404` and `'message' => 'User not found'`

Fail: email given in params is already taken
Returns: `409` and `'message' => 'Email already taken'`

Fail: email and/or password given in params is invalid
Returns: `400` and `'message' => 'Invalid params'`
