defmodule JsTracker.Scraper do
  alias JsTracker.{Scraper, Tracker}
  alias ChromeRemoteInterface.PageSession
  alias ChromeRemoteInterface.RPC.{Network, Page}

  require Logger

  def scrape_all do
    Tracker.list_targets
    |> Enum.each(& spawn fn -> Scraper.scrape_and_save(&1) end)
  end

  def scrape_and_save(target) do
    {:ok, _} = target.url
    |> scrape()
    |> Tracker.create_recording(target)
  end

  def scrape(url) do
    Logger.info "Starting Scraper.scrape - #{inspect(self())}: #{url}"
    {:ok, page_pid} = Chromesmith.checkout :chrome_pool, true
    Logger.debug("checked out #{inspect(page_pid)}")
    {:ok, _} = Network.enable(page_pid)
    {:ok, _} = Page.enable(page_pid)
    :ok = PageSession.subscribe(page_pid, "Page.loadEventFired")
    :ok = PageSession.subscribe(page_pid, "Network.responseReceived")
    # navigate to about:blank to ensure that we don't catch events from the previous session
    {:ok, _} = Page.navigate(page_pid, %{url: "about:blank"})
    collect_events(page_pid, false)
    {:ok, _} = Page.navigate(page_pid, %{url: url})
    # to ensure we dont wait forever if Page.loadEventFired never arrives 
    # (we cant use built in timeout of receive because we may still be 
    # receiving Network.responseReceived regularly)
    page_load_timeout = Process.send_after(self(), :page_load_timeout, 30000)
    Logger.debug("start collect_events #{inspect(page_pid)}")
    result = collect_events(page_pid, true)
    Process.cancel_timer(page_load_timeout)
    Logger.debug("done collecting events, checking in #{inspect(page_pid)}")
    :ok = Chromesmith.checkin :chrome_pool, true
    Logger.debug("checked in #{inspect(page_pid)}")
    result
    |> Enum.sort_by(fn(x) -> x.url end)
  end

  defp collect_events(page_pid, collect_stray_events, results \\ []) do
    receive do
      {:chrome_remote_interface, "Page.loadEventFired", _response} ->
        if collect_stray_events do 
          # sometimes Network.responseReceived events come in right after 
          # Page.loadEventFired so we collect events for a few more seconds
          # after Page.loadEventFired
          # (we cant use built in timeout of receive because we may still be 
          # receiving Network.responseReceived regularly)
          stray_event_timeout = Application.get_env(:js_tracker, :stray_event_timeout)
          Process.send_after(self(), :stray_event_timeout, stray_event_timeout)
          collect_events(page_pid, collect_stray_events, results)
        else
          results
        end
      {:chrome_remote_interface, "Network.responseReceived", response} ->
        if response["params"]["type"] == "Script" do
          collect_events(page_pid, collect_stray_events, [ format_event(page_pid, response) | results])
        else
          collect_events(page_pid,collect_stray_events, results)
        end
      :page_load_timeout ->
        results
      :stray_event_timeout ->
        results
    end
  end

  defp format_event(page_pid, response) do
    Logger.debug "#{inspect(self())}: #{inspect(response)}"
    params = response["params"]
    Logger.debug("getting response body #{inspect(page_pid)} (#{params["response"]["url"]})")
    {:ok, body} = Network.getResponseBody(
      page_pid,
      %{requestId: params["requestId"]}
    )
    Logger.debug("    got response body #{inspect(page_pid)} (#{params["response"]["url"]})")
    body_hash = :sha256
    |> :crypto.hash(body["result"]["body"])
    |> Base.encode16(case: :lower)
    File.write("scraped_files/#{body_hash}", body["result"]["body"])


    %{
      url: params["response"]["url"],
      request_headers: params["response"]["headers"],
      response_headers: params["response"]["requestHeaders"],
      body_hash: body_hash
    }
  end
end
