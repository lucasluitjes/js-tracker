defmodule JsTracker.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(JsTracker.Repo, []),
      # Start the endpoint when the application starts
      supervisor(JsTrackerWeb.Endpoint, []),
      # Start your own worker by calling: JsTracker.Worker.start_link(arg1, arg2, arg3)
      # worker(JsTracker.Worker, [arg1, arg2, arg3]),
      Chromesmith.child_spec(:chrome_pool, [process_pool_size: 1, page_pool_size: 6]),
      worker(JsTracker.Scheduler, [])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: JsTracker.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    JsTrackerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
