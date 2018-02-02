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
    Logger.info "#{inspect(self())}: #{url}"
    {:ok, page_pid} = Chromesmith.checkout :chrome_pool, true
    IO.puts("checked out #{inspect(page_pid)}")
    {:ok, _} = Network.enable(page_pid)
    {:ok, _} = Page.enable(page_pid)
    :ok = PageSession.subscribe(page_pid, "Page.loadEventFired")
    :ok = PageSession.subscribe(page_pid, "Network.responseReceived")
    # navigate to about:blank to ensure that we don't catch events from the previous session
    {:ok, _} = Page.navigate(page_pid, %{url: "about:blank"})
    collect_events(page_pid)
    {:ok, _} = Page.navigate(page_pid, %{url: url})
    IO.puts("start collect_events #{inspect(page_pid)}")
    result = collect_events(page_pid)
    IO.puts("done collecting events, checking in #{inspect(page_pid)}")
    :ok = Chromesmith.checkin :chrome_pool, true
    IO.puts("checked in #{inspect(page_pid)}")
    result
    |> Enum.sort_by(fn(x) -> x.url end)
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
    Logger.info "#{inspect(self())}: #{inspect(response)}"
    params = response["params"]
    IO.puts("getting response body #{inspect(page_pid)} (#{params["response"]["url"]})")
    {:ok, body} = Network.getResponseBody(
      page_pid,
      %{requestId: params["requestId"]}
    )
    IO.puts("    got response body #{inspect(page_pid)} (#{params["response"]["url"]})")
    body_hash = :sha256
    |> :crypto.hash(body["result"]["body"])
    |> Base.encode16(case: :lower)
    # File.write(body_hash, body["result"]["body"])


    %{
      url: params["response"]["url"],
      request_headers: params["response"]["headers"],
      response_headers: params["response"]["requestHeaders"],
      body_hash: body_hash
    }
  end
end
