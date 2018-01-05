defmodule JsTrackerTest do
  use JsTracker.DataCase
  alias JsTracker.{Scraper, Tracker}

  test "Scrape a url" do
    [result | _] = Scraper.scrape("http://localhost:4001")
    assert result.url == "http://localhost:4001/js/app.js"
    assert result.body_hash == "01645e09ad03b4f44cff57f2a008b35e031a181c2cbb672c4309d19ff2734ae7"
  end

  test "Scrape and save all urls" do
    Tracker.create_target(%{url: "http://localhost:4001"})

    Scraper.scrape_all
    :timer.sleep(250)
    Scraper.scrape_all
    :timer.sleep(250)

    [target] = JsTracker.Repo.preload(Tracker.list_targets, :recordings)
    [recording1 | [recording2]] = JsTracker.Repo.preload(target.recordings, :resources)
    [resource] = recording1.resources

    assert Tracker.count_recordings == 2
    assert Tracker.count_resources == 1
    assert recording1.resources == recording2.resources
    assert resource.url == "http://localhost:4001/js/app.js"
    assert resource.body_hash == "01645e09ad03b4f44cff57f2a008b35e031a181c2cbb672c4309d19ff2734ae7"
  end

  test "Scrape a url multiple times and mark changes" do
    {:ok, target} = Tracker.create_target(%{url: "http://localhost:4001"})
    Scraper.scrape_and_save(target)
    Scraper.scrape_and_save(target)
    {:ok, target} = Tracker.update_target(target, %{url: "http://google.com"})
    Scraper.scrape_and_save(target)
    {:ok, target} = Tracker.update_target(target, %{url: "http://localhost:4001"})
    Scraper.scrape_and_save(target)
    Scraper.scrape_and_save(target)
    recordings = for n <- Tracker.list_recordings, do: n.changed
    assert recordings == [true, false, true, true, false]
  end

end
