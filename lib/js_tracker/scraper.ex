defmodule JsTracker.Scraper do
  require IEx
  def scrape(url) do
    {:ok, page_pid} = Chromesmith.checkout :chrome_pool, true
    {:ok, _} = ChromeRemoteInterface.RPC.Network.enable(page_pid)
    {:ok, _} = ChromeRemoteInterface.RPC.Page.enable(page_pid)
    :ok = ChromeRemoteInterface.PageSession.subscribe(page_pid, "Page.loadEventFired")
    :ok = ChromeRemoteInterface.PageSession.subscribe(page_pid, "Network.responseReceived")
    {:ok, _} = ChromeRemoteInterface.RPC.Page.navigate(page_pid, %{url: url})
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
    {:ok, body} = ChromeRemoteInterface.RPC.Network.getResponseBody(
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