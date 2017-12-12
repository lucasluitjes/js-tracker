defmodule JsTrackerTest do
  use JsTracker.DataCase

  test "Scrape a url" do
    [result | _] = JsTracker.Scraper.scrape("http://localhost:4001")
    assert result.url == "http://localhost:4001/js/app.js"
    assert result.body_hash == "01645e09ad03b4f44cff57f2a008b35e031a181c2cbb672c4309d19ff2734ae7"
  end

  test "Scrape and save all urls" do
    JsTracker.Tracker.create_target(%{url: "http://localhost:4001"})
    JsTracker.Scraper.scrape_all
    :timer.sleep(1000)
    [result] = JsTracker.Tracker.list_recordings
    assert result.url == "http://localhost:4001/js/app.js"
    assert result.body_hash == "01645e09ad03b4f44cff57f2a008b35e031a181c2cbb672c4309d19ff2734ae7"
  end
end