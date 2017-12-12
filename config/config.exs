# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :js_tracker,
  ecto_repos: [JsTracker.Repo]

# Configures the endpoint
config :js_tracker, JsTrackerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Q0u565oPQF0Kwj2BHxdD3d9NTSQxcAzhYEojGvAIEhVijgoWPEhC9FE9eg4MnRuv",
  render_errors: [view: JsTrackerWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: JsTracker.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :js_tracker, JsTracker.Scheduler,
  jobs: [
    {"* * * * *",      {IO, :puts, ["test"]}}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
