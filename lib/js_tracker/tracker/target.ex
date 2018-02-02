defmodule JsTracker.Tracker.Target do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias JsTracker.Tracker.{Target, Recording}


  schema "targets" do
    field :url, :string
    field :changed_at, :date, virtual: true
    has_many :recordings, JsTracker.Tracker.Recording

    timestamps()
  end

  @doc false
  def changeset(%Target{} = target, attrs) do
    target
    |> cast(attrs, [:url])
    |> validate_required([:url])
  end
end
