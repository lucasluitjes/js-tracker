defmodule JsTracker.Repo.Migrations.RecordingBelongsToTarget do
  use Ecto.Migration

  def change do
    alter table(:recordings) do
      add :target_id, references(:targets)
    end
  end
end
