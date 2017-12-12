defmodule JsTrackerWeb.TargetController do
  use JsTrackerWeb, :controller

  alias JsTracker.Tracker
  alias JsTracker.Tracker.Target

  def index(conn, _params) do
    targets = Tracker.list_targets()
    render(conn, "index.html", targets: targets)
  end

  def new(conn, _params) do
    changeset = Tracker.change_target(%Target{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"target" => target_params}) do
    case Tracker.create_target(target_params) do
      {:ok, target} ->
        conn
        |> put_flash(:info, "Target created successfully.")
        |> redirect(to: target_path(conn, :show, target))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    target = Tracker.get_target!(id)
    render(conn, "show.html", target: target)
  end

  def edit(conn, %{"id" => id}) do
    target = Tracker.get_target!(id)
    changeset = Tracker.change_target(target)
    render(conn, "edit.html", target: target, changeset: changeset)
  end

  def update(conn, %{"id" => id, "target" => target_params}) do
    target = Tracker.get_target!(id)

    case Tracker.update_target(target, target_params) do
      {:ok, target} ->
        conn
        |> put_flash(:info, "Target updated successfully.")
        |> redirect(to: target_path(conn, :show, target))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", target: target, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    target = Tracker.get_target!(id)
    {:ok, _target} = Tracker.delete_target(target)

    conn
    |> put_flash(:info, "Target deleted successfully.")
    |> redirect(to: target_path(conn, :index))
  end
end
