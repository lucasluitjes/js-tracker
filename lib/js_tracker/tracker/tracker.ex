defmodule JsTracker.Tracker do
  @moduledoc """
  The Tracker context.
  """
  require IEx
  require Logger
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

  def list_targets(params) do
    list_targets_with_changed()
    |> order_targets(sort_params(params))
    |> Repo.paginate(params, total_count: count_targets())
  end

  def list_targets(params, query) do
    list_targets_with_changed()
    |> order_targets(sort_params(params))
    |> where([t], ilike(t.url, ^"%#{query}%"))
    |> Repo.paginate(params, total_count: count_targets(query))
  end

  defp order_targets(queryable, {o, "changed_at"}) do
    order_by(queryable, {^o, fragment("changed_at")})
  end

  defp order_targets(queryable, {o, f}) do
    f = String.to_atom(f)
    order_by(queryable, {^o, ^f})
  end

  defp count_targets do
    Repo.one(from t in Target, select: count("*"))
  end

  defp count_targets(query) do
    Repo.one(from t in Target, select: count("*"), where: ilike(t.url, ^"%#{query}%"))
  end

  defp sort_params(%{"sort_field" => f, "sort_order" => o}) do
    {String.to_atom(o), f}
  end

  defp sort_params(%{"sort_field" => f}) do
    {:asc, f}
  end

  defp sort_params(_) do
    {:desc, "inserted_at"}
  end

  defp list_targets_with_changed do
    from t in Target,
      join: r in Recording, on: t.id == r.target_id,
      select: %{t | changed_at: fragment("max(?) as changed_at", r.inserted_at)},
      where: r.changed == true,
      group_by: t.id
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
      log_inspect([target.url, (for n <- resources, do: [n.id, n.body_hash, n.url] )])
      log_inspect([target.url, (for n <- last.resources, do: [n.id, n.body_hash, n.url] )])
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

  def get_resource!(id), do: Repo.get!(Resource, id)

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
    {:ok, resource} = %Resource{} |> Resource.changeset(attrs) |> Repo.insert()
    resource
  end

  defp log_inspect(obj) do
    Logger.debug "#{inspect(self())}#{inspect(obj)}"
  end
end
