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
    page_pid = checkout()
    clear_page(page_pid)
    result = navigate(page_pid, url)
    checkin(page_pid)
    result
  end

  defp checkout do
    {:ok, page_pid} = Chromesmith.checkout :chrome_pool, true
    Logger.debug("checked out #{inspect(page_pid)}")
    {:ok, _} = Network.enable(page_pid)
    {:ok, _} = Page.enable(page_pid)
    :ok = PageSession.subscribe(page_pid, "Page.loadEventFired")
    :ok = PageSession.subscribe(page_pid, "Network.responseReceived")
    page_pid
  end

  defp clear_page(page_pid) do
    # navigate to about:blank to ensure that we don't catch events from the previous session
    {:ok, _} = Page.navigate(page_pid, %{url: "about:blank"})
    collect_events(page_pid, true)
  end

  defp navigate(page_pid, url) do
    {:ok, _} = Page.navigate(page_pid, %{url: url})
    # to ensure we dont wait forever if Page.loadEventFired never arrives
    # (we cant use built in timeout of receive because we may still be
    # receiving Network.responseReceived regularly)
    page_load_timeout = Process.send_after(self(), :page_load_timeout, 30000)
    Logger.debug("start collect_events #{inspect(page_pid)}")
    result = collect_events(page_pid, true)
    Process.cancel_timer(page_load_timeout)

    Enum.sort_by(result, fn(x) -> x.url end)
  end

  defp checkin(page_pid) do
    Logger.debug("done collecting events, checking in #{inspect(page_pid)}")
    :ok = PageSession.unsubscribe(page_pid, "Page.loadEventFired")
    :ok = PageSession.unsubscribe(page_pid, "Network.responseReceived")
    :ok = Chromesmith.checkin :chrome_pool, page_pid
    Logger.debug("checked in #{inspect(page_pid)}")
  end

  defp collect_events(page_pid, collect_stray_events, results \\ []) do
    receive do
      {:chrome_remote_interface, "Page.loadEventFired", _response} ->
      handle_load_event(page_pid, collect_stray_events, results)
    {:chrome_remote_interface, "Network.responseReceived", response} ->
      handle_response_received(page_pid, collect_stray_events, results, response)
    :page_load_timeout ->
      results
      :stray_event_timeout ->
        results
    end
  end

  # sometimes Network.responseReceived events come in right after
  # Page.loadEventFired so we collect events for a few more seconds
  # after Page.loadEventFired
  # (we cant use built in timeout of receive because we may still be
  # receiving Network.responseReceived regularly)

  defp handle_load_event(page_pid, collect_stray_events, results) do
    if collect_stray_events do
      stray_event_timeout = Application.get_env(:js_tracker, :stray_event_timeout)
      Process.send_after(self(), :stray_event_timeout, stray_event_timeout)
      collect_events(page_pid, false, results)
    else
      results
    end
  end

  defp handle_response_received(page_pid, collect_stray_events, results, response) do
    if response["params"]["type"] == "Script" do
      collect_events(page_pid, collect_stray_events, [ format_event(page_pid, response) | results])
    else
      collect_events(page_pid, collect_stray_events, results)
    end
  end

  defp format_event(page_pid, response) do
    Logger.debug "#{inspect(self())}: #{inspect(response)}"
    params = response["params"]
    body = get_response(page_pid, params)
    body_hash = sha256(body["result"]["body"])
    File.write("scraped_files/#{body_hash}", body["result"]["body"])

    %{
      url: params["response"]["url"],
      request_headers: params["response"]["headers"],
      response_headers: params["response"]["requestHeaders"],
      body_hash: body_hash
    }
  end

  defp get_response(page_pid, params) do
    Logger.debug("getting response body #{inspect(page_pid)} (#{params["response"]["url"]})")
    {:ok, body} = Network.getResponseBody(
      page_pid,
      %{requestId: params["requestId"]}
    )
    Logger.debug("    got response body #{inspect(page_pid)} (#{params["response"]["url"]})")
    body
  end

  defp sha256(body) do
    :sha256
    |> :crypto.hash(body)
    |> Base.encode16(case: :lower)
  end
end
