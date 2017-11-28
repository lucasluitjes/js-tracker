defmodule JsTracker.Scraper do
  require IEx
  def scrape(url) do
    {:ok, page_pid} = Chromesmith.checkout :chrome_pool, true
    {:ok, _} = ChromeRemoteInterface.RPC.Network.enable(page_pid)
    {:ok, _} = ChromeRemoteInterface.RPC.Page.enable(page_pid)
    :ok = ChromeRemoteInterface.PageSession.subscribe(page_pid, "Page.loadEventFired")
    :ok = ChromeRemoteInterface.PageSession.subscribe(page_pid, "Network.responseReceived")
    {:ok, _} = ChromeRemoteInterface.RPC.Page.navigate(page_pid, %{url: url})
    :ok = Chromesmith.checkin :chrome_pool, true
    collect_events()
  end

  defp collect_events(results \\ []) do
    receive do
      {:chrome_remote_interface, "Page.loadEventFired", _response} ->
        results
      {:chrome_remote_interface, "Network.responseReceived", response} ->
        payload = response["params"]["response"]["url"]
        if response["params"]["type"] == "Script" do
          collect_events([ payload | results])
        else
          collect_events(results)
        end
    end
  end
end