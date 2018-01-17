defmodule JsTrackerWeb.PageController do
  use JsTrackerWeb, :controller

  alias JsTracker.Tracker

  def index(conn, params = %{"q" => query}) do
    {targets, kerosene} =
    query
    |> Tracker.search_targets()
    |> Tracker.paginate_targets(params)
    render(conn, "index.html", targets: targets, kerosene: kerosene, query: query)
  end

  def index(conn, params) do
    {targets, kerosene} = Tracker.paginate_targets(params)
    render(conn, "index.html", targets: targets, kerosene: kerosene, query: "")
  end

end
