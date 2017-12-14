defmodule JsTracker.Tracker.Resource do
  use Ecto.Schema
  import Ecto.Changeset
  alias JsTracker.Tracker.Resource

  schema "resources" do
    field :url, :string
    field :body_hash, :string
    field :request_headers, :map
    field :response_headers, :map
    many_to_many :recordings, JsTracker.Tracker.Recording, join_through: "resources_recordings"
    timestamps()
  end

  @doc false
  def changeset(%Resource{} = resource, attrs) do
    resource
    |> cast(attrs, [:url, :body_hash, :request_headers, :response_headers])
    |> validate_required([:url, :body_hash, :request_headers, :response_headers])
  end
end
