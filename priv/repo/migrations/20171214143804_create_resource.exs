defmodule JsTracker.Repo.Migrations.CreateResource do
  use Ecto.Migration

  def change do
    create table(:resources) do
      add :url, :text
      add :body_hash, :text
      add :request_headers, :map
      add :response_headers, :map
      timestamps()
    end
  end
end
