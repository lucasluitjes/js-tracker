defmodule JsTracker.Repo.Migrations.CreateResourcesRecordings do
  use Ecto.Migration

  def change do
    create table(:resources_recordings) do
      add :resource_id, references(:resources)
      add :recording_id, references(:recordings)
    end

    create unique_index(:resources_recordings, [:resource_id, :recording_id])
  end
end
