alias Remote.Repo
alias Remote.User

# batch size limit for postgresql transactions of 65535, divided by three because there
# are three parameters in each insert operation
batch_size = 21845

# generate list of maps to create user structs
users =
  for _i <- 1..1_000_000 do
    %{
      points: 0,
      inserted_at: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second),
      updated_at: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
    }
  end

# chunk the original list to fit in the batch size
chunked_users = Enum.chunk_every(users, batch_size)

# insert seeded user records
for user_list <- chunked_users do
  Ecto.Multi.new()
  |> Ecto.Multi.insert_all(:insert_all, User, user_list)
  |> Repo.transaction()
end
