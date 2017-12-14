defmodule JsTracker.Repo.Migrations.CreateRecording do
  use Ecto.Migration

  def change do
    create table(:recordings) do
      timestamps()
    end
  end
end
