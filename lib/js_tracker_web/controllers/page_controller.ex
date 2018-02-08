defmodule JsTrackerWeb.PageController do
  use JsTrackerWeb, :controller

  alias JsTracker.Tracker

  def index(conn, params = %{"q" => query}) do
    {targets, kerosene} = Tracker.list_targets(params, query)
    render(conn, "index.html", targets: targets, kerosene: kerosene, query: query)
  end

  def index(conn, params) do
    {targets, kerosene} = Tracker.list_targets(params)
    render(conn, "index.html", targets: targets, kerosene: kerosene, query: "")
  end

end
