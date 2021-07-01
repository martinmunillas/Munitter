defmodule Twitter.Repo.Migrations.AddEditedToTweet do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :edited, :boolean
    end
  end
end
