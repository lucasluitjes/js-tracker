defmodule JsTracker.Repo.Migrations.RecordingChangedAttribute do
  use Ecto.Migration

  def change do
    alter table(:recordings) do
      add :changed, :boolean, default: false, null: false
    end
  end
end
