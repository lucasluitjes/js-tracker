defmodule JsTrackerTest do
  use ExUnit.Case

  test "Scrape a url" do
    result = JsTracker.Scraper.scrape("http://localhost:4001")
    assert result == ["http://localhost:4001/js/app.js"]
  end
end