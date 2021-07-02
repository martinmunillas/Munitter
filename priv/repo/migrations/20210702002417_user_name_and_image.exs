defmodule Twitter.Repo.Migrations.UserNameAndImage do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :name, :string
      add :image, :string
    end
  end
end
