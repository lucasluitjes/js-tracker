defmodule JsTracker.Repo.Migrations.CreateRecording do
  use Ecto.Migration

  def change do
    create table(:recordings) do
      add :url, :text
      add :body_hash, :text
      add :request_headers, :map
      add :response_headers, :map
      timestamps()
    end
  end
end
