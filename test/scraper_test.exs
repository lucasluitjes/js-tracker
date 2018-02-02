defmodule JsTrackerTest do
  use JsTracker.DataCase
  alias JsTracker.{Scraper, Tracker}

  test "Scrape a url" do
    [result | _] = Scraper.scrape("http://localhost:4001/test_mock/test.html")
    assert result.url == "http://localhost:4001/test_mock/test.js"
    assert result.body_hash == "b80112c06818d86d16f0185c023439b4364af3c61971b8eaeb90d6f094dc8a6b"
  end

  test "Scrape and save all urls" do
    Tracker.create_target(%{url: "http://localhost:4001/test_mock/test.html"})

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
    assert resource.url == "http://localhost:4001/test_mock/test.js"
    assert resource.body_hash == "b80112c06818d86d16f0185c023439b4364af3c61971b8eaeb90d6f094dc8a6b"
  end

  test "Scrape a url multiple times and mark changes" do
    {:ok, target} = Tracker.create_target(%{url: "http://localhost:4001/test_mock/test.html"})
    IO.puts "target_ur: #{target.url}"
    Scraper.scrape_and_save(target)
    Scraper.scrape_and_save(target)
    {:ok, target} = Tracker.update_target(target, %{url: "http://google.com"})
    IO.puts "target_ur: #{target.url}"
    Scraper.scrape_and_save(target)
    {:ok, target} = Tracker.update_target(target, %{url: "http://localhost:4001/test_mock/test.html"})
    IO.puts "target_ur: #{target.url}"
    Scraper.scrape_and_save(target)
    Scraper.scrape_and_save(target)
    recordings = for n <- Tracker.list_recordings, do: n.changed
    assert recordings == [true, false, true, true, false]
  end
end
