defmodule JsTrackerWeb.Router do
  use JsTrackerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug BasicAuth, use_config: {:js_tracker, :basic_auth}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", JsTrackerWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/targets", TargetController
    resources "/recordings", RecordingController, only: [:index]
    resources "/resources", ResourceController, only: [:index, :show]

  end

  # Other scopes may use custom stacks.
  # scope "/api", JsTrackerWeb do
  #   pipe_through :api
  # end
end
