defmodule JsTrackerWeb.ResourceController do
  use JsTrackerWeb, :controller

  alias JsTracker.Tracker
  alias JsTracker.Tracker.Resource

  def index(conn, params) do
    %{"recording_id" => recording_id} = params
    resources = Tracker.list_resources(recording_id)
    render(conn, "index.html", resources: resources)
  end
end
