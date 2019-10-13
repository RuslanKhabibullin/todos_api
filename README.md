[![Build Status](https://semaphoreci.com/api/v1/khabibullin_ruslan/todos_api/branches/master/badge.svg)](https://semaphoreci.com/khabibullin_ruslan/todos_api)

# TodosApi
## Description
Elixir backend for todos app. Currently implemented user stories:
- User can sign up
- User can sign in
- User can sign in through Google
- User can edit profile
- User can get profile
- User can destroy profile
- User can get other users
- User can create todo
- User can get own todos
- User can update own todos
- User can delete own todos

## Endpoints
- `GET /api/auth/google` - sign in through Google
- `POST /api/auth/sign_in` - sign in with email and pass
- `POST /api/auth/sign_up` - sign up with email and pass

Secured endpoints (authorization header with token required):
- `GET /api/users/:id` - get user data by id
- `PUT /api/users/:id` - update user
- `DELETE /api/users/:id` - delete user
- `GET /api/todos` - get current user todos
- `GET /api/todos/:id` - get todo by id
- `PUT /api/todos/:id` - update todo by id
- `DELETE /api/todos/:id` - delete todo by id


## Installing
To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Documentation
Generate documentation with `mix docs`
