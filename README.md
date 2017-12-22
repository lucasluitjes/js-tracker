# JsTracker

This Elixir web application uses the Chromesmith library to spin up Chrome headless instances, visit websites, and records all the external javascripts used by those websites.

It's part of a project under development, to continuously monitor websites for external dependencies. It's somewhat similar to [OpenWPM](https://github.com/citp/OpenWPM), but with a slightly different aim.

## Phoenix instructions

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
