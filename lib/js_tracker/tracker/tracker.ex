defmodule JsTracker.Tracker do
  @moduledoc """
  The Tracker context.
  """
  require IEx
  import Ecto.Query, warn: false
  alias JsTracker.Repo
  alias JsTracker.Tracker.{Target, Recording, Resource}

  @doc """
  Returns the list of targets.

  ## Examples

      iex> list_targets()
      [%Target{}, ...]

  """
  def list_targets do
    Repo.all(Target)
  end

  @doc """
  Returns the paginated list of targets

  """
  def paginate_targets(params) do
    Target
    |> order_by(asc: :inserted_at)
    |> Repo.paginate(params)
  end

  @doc """
  Gets a single target.

  Raises `Ecto.NoResultsError` if the Target does not exist.

  ## Examples

      iex> get_target!(123)
      %Target{}

      iex> get_target!(456)
      ** (Ecto.NoResultsError)

  """
  def get_target!(id), do: Repo.get!(Target, id)

  @doc """
  Creates a target.

  ## Examples

      iex> create_target(%{field: value})
      {:ok, %Target{}}

      iex> create_target(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_target(attrs \\ %{}) do
    %Target{}
    |> Target.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a target.

  ## Examples

      iex> update_target(target, %{field: new_value})
      {:ok, %Target{}}

      iex> update_target(target, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_target(%Target{} = target, attrs) do
    target
    |> Target.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Target.

  ## Examples

      iex> delete_target(target)
      {:ok, %Target{}}

      iex> delete_target(target)
      {:error, %Ecto.Changeset{}}

  """
  def delete_target(%Target{} = target) do
    Repo.delete(target)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking target changes.

  ## Examples

      iex> change_target(target)
      %Ecto.Changeset{source: %Target{}}

  """
  def change_target(%Target{} = target) do
    Target.changeset(target, %{})
  end

  def list_recordings do
    Recording
    |> order_by(asc: :inserted_at)
    |> Repo.all
  end

  def paginate_recordings(target_id, params) do
    Recording
    |> where(target_id: ^target_id)
    |> order_by(asc: :inserted_at)
    |> Repo.paginate(params)
  end

  def create_recording(resources, target) do
    resources = for n <- resources, do: find_or_create_resource(n)
    changed = changed_recording(target, resources)
    %Recording{}
    |> Recording.changeset(%{target_id: target.id, changed: changed}, resources)
    |> Repo.insert()
  end

  def changed_recording(target, resources) do
    last = last_recording(target)
    if last do
      last.resources != resources
    else
      true
    end
  end

  def last_recording(target) do
    last = Repo.one(from x in Recording, order_by: [desc: x.id], limit: 1)
    Repo.preload(last, :resources)
  end

  def count_recordings do
    Repo.one(from r in Recording, select: count("*"))
  end

  def list_resources do
    Repo.all(Resource)
  end

  def list_resources(recording_id) do
    recording = Recording
    |> Repo.get(recording_id)
    |> Repo.preload([:resources])
    recording.resources
  end

  def count_resources do
    Repo.one(from r in Resource, select: count("*"))
  end

  def find_or_create_resource(r) do
    case Repo.get_by(Resource, url: r.url, body_hash: r.body_hash) do
      resource when is_nil(resource) -> create_resource(r)
      resource -> resource
    end
  end

  def create_resource(attrs \\ %{}) do
    with {:ok, resource} <- %Resource{} |> Resource.changeset(attrs) |> Repo.insert() do
      resource
    end
  end
end
