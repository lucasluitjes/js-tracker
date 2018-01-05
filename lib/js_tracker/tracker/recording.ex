defmodule JsTracker.Tracker.Recording do
  use Ecto.Schema
  import Ecto.Changeset
  alias JsTracker.Tracker.Recording

  schema "recordings" do
    field :changed, :boolean
    belongs_to :target, JsTracker.Tracker.Target
    many_to_many :resources, JsTracker.Tracker.Resource, join_through: "resources_recordings"

    timestamps()
  end

  @doc false
  def changeset(%Recording{} = recording, attrs, resources \\ []) do
    recording
    |> cast(attrs, [:target_id, :changed])
    |> put_assoc(:resources, resources)
    |> assoc_constraint(:target)
  end
end
