defmodule Remote.Repo.Migrations.AddUsersTable do
  use Ecto.Migration

  def up do
    create table(:users) do
      add :points, :integer, default: 0

      timestamps()
    end
  end
end
