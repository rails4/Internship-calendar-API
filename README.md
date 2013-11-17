Calendar API
============

# User

## User index

Request: `GET http://calendar-api.shellyapp.com/users`

Success: returns an array of users in the database in JSON. In case of no users
returns an empty array.

## User update

Request: `PUT http://calendar-api.shellyapp.com/users/:id`,
with parameters containing `{ email: 'email' }` and/or `{ password: 'password' }`

Success: updates user with id of `:id` with given params
Returns: `200` and `'message' => 'User updated successfully!'`

Fail: user with `:id` not found
Returns: `404` and `'message' => 'User not found'`

Fail: email given in params is already taken
Returns: `409` and `'message' => 'Email already taken'`

Fail: email and/or password given in params is invalid
Returns: `400` and `'message' => 'Invalid params'`

# Event

## Event create

Request: `POST http://calendar-api.shellyapp.com/events`

Success: create new event with given params
Returns: `200` and `'message' => 'Event was successfully created'`

Fail: create new event with blank params
Returns: `400` and `'message' => 'Validation failed: blank params'`

Fail: create new event with end date earlier than start date
Returns: `400` and `'message' => 'Invalid date: end date is earlier than start date'`
