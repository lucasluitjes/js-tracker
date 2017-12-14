defmodule JsTracker.Tracker.Recording do
  use Ecto.Schema
  import Ecto.Changeset
  alias JsTracker.Tracker.Recording


  schema "recordings" do
    field :url, :string
    field :body_hash, :string
    field :request_headers, :map
    field :response_headers, :map
    belongs_to :target, JsTracker.Tracker.Target

    timestamps()
  end

  @doc false
  def changeset(%Recording{} = recording, attrs) do
    recording
    |> cast(attrs, [:url, :body_hash, :request_headers, :response_headers, :target_id])
    |> assoc_constraint(:target)
    |> validate_required([:url, :body_hash, :request_headers, :response_headers])
  end
end
