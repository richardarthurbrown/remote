defmodule Remote.Repo.Migrations.AddUsersTable do
  use Ecto.Migration

  def up do
    create table(:users) do
      add :points, :integer, default: 0

      timestamps()
    end

    create constraint("users", :points_between_0_100, check: "points >= 0 AND points <= 100")
  end

  def down do
    drop table(:users)
  end
end
