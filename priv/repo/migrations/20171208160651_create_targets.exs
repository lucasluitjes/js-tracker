defmodule JsTracker.Repo.Migrations.CreateTargets do
  use Ecto.Migration

  def change do
    create table(:targets) do
      add :url, :string

      timestamps()
    end

  end
end
