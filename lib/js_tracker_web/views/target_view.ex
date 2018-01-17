defmodule JsTrackerWeb.TargetView do
  use JsTrackerWeb, :view

  def time_in_words(str) do
     {:ok, result} = Elixir.Timex.Format.DateTime.Formatters.Relative.format(str, "{relative}")
     result
  end

end
