defmodule JsTracker.Scraper do
  alias JsTracker.{Scraper, Tracker}
  alias ChromeRemoteInterface.PageSession
  alias ChromeRemoteInterface.RPC.{Network, Page}

  def scrape_all do
    Tracker.list_targets
    |> Enum.each(fn target ->
      Task.start(Scraper, :scrape_and_save, [target])
    end)
  end

  def scrape_and_save(target) do
    scrape(target.url)
    |> Enum.each(fn result ->
      result
      |> Map.put(:target_id, target.id)
      |> Tracker.create_recording
    end)
  end

  def scrape(url) do
    {:ok, page_pid} = Chromesmith.checkout :chrome_pool, true
    {:ok, _} = Network.enable(page_pid)
    {:ok, _} = Page.enable(page_pid)
    :ok = PageSession.subscribe(page_pid, "Page.loadEventFired")
    :ok = PageSession.subscribe(page_pid, "Network.responseReceived")
    {:ok, _} = Page.navigate(page_pid, %{url: url})
    result = collect_events(page_pid)
    :ok = Chromesmith.checkin :chrome_pool, true
    result
  end

  defp collect_events(page_pid, results \\ []) do
    receive do
      {:chrome_remote_interface, "Page.loadEventFired", _response} ->
        results
      {:chrome_remote_interface, "Network.responseReceived", response} ->
        if response["params"]["type"] == "Script" do
          collect_events(page_pid, [ format_event(page_pid, response) | results])
        else
          collect_events(page_pid, results)
        end
    end
  end

  defp format_event(page_pid, response) do
    params = response["params"]
    {:ok, body} = Network.getResponseBody(
      page_pid,
      %{requestId: params["requestId"]}
    )

    body_hash = :crypto.hash(:sha256, body["result"]["body"])
    |> Base.encode16(case: :lower)

    %{
      url: params["response"]["url"],
      request_headers: params["response"]["headers"],
      response_headers: params["response"]["requestHeaders"],
      body_hash: body_hash
    }
  end
end