defmodule Twitter.Repo.Migrations.TweetUserId do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      remove :username
      add :user_id, :integer
    end
  end
end
