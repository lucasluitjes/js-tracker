defmodule JsTrackerWeb.RecordingController do
  use JsTrackerWeb, :controller

  alias JsTracker.Tracker
  alias JsTracker.Tracker.Recording

  def index(conn, params) do
    %{"target_id" => target_id} = params
    {recordings, kerosene} = Tracker.paginate_recordings(target_id, params)
    render(conn, "index.html", recordings: recordings, kerosene: kerosene)
  end
end
