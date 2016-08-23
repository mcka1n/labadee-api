Events API
==========

Labadee - Events API takes its name from a port/beach located on the northern coast of [Haiti](https://en.wikipedia.org/wiki/Haiti).

I started this small project while I was visiting this beautiful beach in Haiti, I got inspired by the warm blue waters, the hundreds of *events* and tours near the beach and of course by the friendly people from the flea markets.

## API Resources

**Current version:** v1

### Users

  - [GET /users](#get-users) **Not available yet**
  - [GET /users/:id](#get-usersid) **Not available yet**
  - [POST /users](#post-users)
  - [POST /sign_in](#post-sign_in)

### Events

  - [GET /events](#get-events)
  - [GET /events/:id](#get-eventsid)
  - [POST /events](#post-events)
  - [PUT /events/:id](#put-eventsid)
  - [DELETE /events/:id](#delete-eventsid)

### Attendees

  - [GET /events/:event_id/attendees](#get-eventsevent_id-attendees)
  - [GET /events/:event_id/attendees/:id](#get-eventsevent_id-attendeesid)
  - [POST /events/:event_id/attendees](#post-eventsevent_id-attendees)

## Installation

### Notes

Make sure you have MongoDB installed and running on your computer (or server).

1. Clone the repo.

       git clone https://github.com/mcka1n/labadee-api.git

2. `bundle install`.
2. run `rake db:seed` in order to 'install' the default values for users and clients.
4. `rake db:mongoid:create_indexes`
5. `rails s`


## Getting started with the API

### Authentication

I'm using a simple way to authenticate Clients (other apps or scripts) and Users.

#### Client Authentication (key)

For testing and debugging purposes you can run the seeds to create a default client, this will give you a client key which is required in every call to the API.

As a developer you have to send this client `key` as a get param on every request you make, no exceptions.

#### User Authentication (token)

Each and every user will have a `token` field, this token contains a value used for authentication. Every time you sign in with email & password, the token will be refreshed and a new one will be returned.

As a developer you have to send as query params both client `key` and user's `token` on each request, except:

- Sign in
- Sign up

### Authentication Examples

     POST http://localhost:3000/v1/users/sign_in?key=Bnb@fUCodG_j-ywdnty

**Params:**

```
  {
    "user": {
      "email": "andre+test0@gmail.com",
      "password": "1234%678P"
    }
  }
```
**Response:**

```
Status: 200 OK

{
  "success": true,
  "auth_token": "W00tszBmuqdw4tsPY_rY",
  "email": "andre+test0@gmail.com"
}
```
