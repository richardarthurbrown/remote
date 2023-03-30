defmodule Remote.UserServerTest do
  use ExUnit.Case

  alias Remote.Repo
  alias Remote.User
  alias Remote.UserServer

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Remote.Repo)
  end

  test "handle_call(:get_users) returns users with more points than minimum" do
    users = [
      %{points: 10},
      %{points: 40},
      %{points: 70},
      %{points: 80}
    ]

    Enum.each(users, fn user -> Repo.insert!(User.changeset(%User{}, user)) end)

    state = [50, nil]

    assert {:reply, {:ok, result}, _state} = UserServer.handle_call(:get_users, self(), state)

    assert length(result.users) == 2
  end

  test "handle_call(:get_users) updates timestamp in state" do
    state = [50, DateTime.utc_now()]

    assert {:reply, _result, new_state} = UserServer.handle_call(:get_users, self(), state)

    assert new_state != state
  end

  test "handle_info(:update_users) updates all users' points in the database" do
    # Insert 3 users with varying point values
    users = [
      %{points: 10},
      %{points: 20},
      %{points: 30}
    ]

    Enum.each(users, fn user -> Repo.insert!(User.changeset(%User{}, user)) end)

    # Mock the state of the UserServer
    state = [50, nil]

    # Call the handle_info function to update users' points
    assert {:noreply, _new_state} = UserServer.handle_info(:update_users, state)

    # Assert that all users' points have been updated
    updated_users = Repo.all(User)
    assert Enum.all?(updated_users, fn user -> user.points > 0 and user.points <= 100 end)
  end

  test "handle_info(:update_users) refreshes min_number in state with new random number" do
    # Mock the state of the UserServer
    state = [50, nil]

    # Call the handle_info function to refresh min_number
    {:noreply, new_state} = UserServer.handle_info(:update_users, state)

    # Assert that the new state has a different random number for min_number
    assert hd(new_state) != 50
  end
end
