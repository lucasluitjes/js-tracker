defmodule JsTracker.Tracker.Target do
  use Ecto.Schema
  import Ecto.Changeset
  alias JsTracker.Tracker.Target


  schema "targets" do
    field :url, :string

    timestamps()
  end

  @doc false
  def changeset(%Target{} = target, attrs) do
    target
    |> cast(attrs, [:url])
    |> validate_required([:url])
  end
end
