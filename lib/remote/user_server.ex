defmodule Remote.UserServer do
  use GenServer
  import Ecto.Query

  alias Remote.Repo
  alias Remote.User

  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_state) do
    # Start a one-minute timer to trigger the :update_users call
    Process.send_after(self(), :update_users, 60_000)

    # Initialize state with a random number and nil timestamp
    {:ok, [generate_random_number(), nil]}
  end

  def handle_call(:get_users, _from, state) do
    # Query the database for users with more points than the minimum number
    users = query_database(state)

    # Update state with current timestamp but preserve current minimum point number,
    # and return the result
    refreshed_timestamp = DateTime.utc_now()
    current_random_number = hd(state)

    {:reply, {:ok, %{users: users, timestamp: Enum.at(state, 1)}},
     [current_random_number, refreshed_timestamp]}
  end

  def handle_info(:update_users, state) do
    # Update every user's points in the database
    update_database()

    # Restart timer
    Process.send_after(self(), :update_users, 60_000)

    # Refresh state with a new random number
    {:noreply, [generate_random_number(), Enum.at(state, 1)]}
  end

  defp query_database(state) do
    # Query the database for users with more points than the minimum number
    # and limit to 2 results
    min_number = hd(state)
    Repo.all(from u in User, where: u.points > ^min_number, limit: 2)
  end

  defp update_database() do
    # Update every user's points in the database using a random number.
    # Uses `fragment/1` to directly update points, ensuring different random
    # numbers for each user, and updates the 'updated_at' timestamp
    timestamp = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)

    update(User,
      set: [
        points: fragment("floor(random() * 100 + 1)"),
        updated_at: ^timestamp
      ]
    )
    |> Repo.update_all([])
  end

  defp generate_random_number() do
    # Generate a random number between 0 and 100
    Enum.random(1..100)
  end
end
