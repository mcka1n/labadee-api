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

Make sure you have MongoDB installed on your computer(or server).

1. Clone the repo.
2. `bundle install`.
2. run `rake db:seed` in order to 'install' the default values for users and clients.
4. `rake db:mongoid:create_indexes`
5. `rails server`
