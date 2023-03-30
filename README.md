# Remote

A small test application built with Elixir and Phoenix.

# Prerequisites and Setup

Ensure you have Elixir 1.14.3 and Erlang/OTP 24 or higher on your system. Also ensure you have a Postgres server running at localhost:5432 with a default user (username: postgres, password: postgres) in place.

To set up the application, run `mix setup` in the application's root directory. This will install dependencies and set up the database and seeds.

# Running the Application

Start your server with `mix phx.server`, or start in interactive mode with `iex -S mix phx.server`.

To generate a response from the API, visit <http://localhost:4000> in your browser, or put the following command in your terminal:

`curl http://localhost:4000`

Note that the list of returned users from the API will be empty until the first time the application refreshes the user point values, which happens every minute.

# Testing

Run `mix test` to see test output.
