Calendar API
============

# User

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
