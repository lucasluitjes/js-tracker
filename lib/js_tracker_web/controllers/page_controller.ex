defmodule JsTrackerWeb.PageController do
  use JsTrackerWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
