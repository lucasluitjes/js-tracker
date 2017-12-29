defmodule JsTrackerWeb.PageController do
  use JsTrackerWeb, :controller

  alias JsTracker.Tracker
  
  def index(conn, params) do
    {targets, kerosene} = Tracker.paginate_targets(params)
    render(conn, "index.html", targets: targets, kerosene: kerosene)
  end
end
