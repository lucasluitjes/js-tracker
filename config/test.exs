use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :js_tracker, JsTrackerWeb.Endpoint,
  http: [port: 4001],
  server: true

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :js_tracker, JsTracker.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "js_tracker_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :js_tracker, :stray_event_timeout, 1

