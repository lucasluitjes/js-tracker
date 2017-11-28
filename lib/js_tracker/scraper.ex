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
    # TODO clean this up
    url = response["params"]["response"]["url"]
    id = response["params"]["requestId"]
    request_headers = response["params"]["response"]["headers"]
    response_headers = response["params"]["response"]["requestHeaders"]
    {:ok, body} = ChromeRemoteInterface.RPC.Network.getResponseBody(page_pid, %{requestId: id})
    body_hash = :crypto.hash(:sha256, body["result"]["body"])
    |> Base.encode16(case: :lower)
    %{
      url: url,
      request_headers: request_headers,
      response_headers: response_headers,
      body_hash: body_hash
    }
  end
end