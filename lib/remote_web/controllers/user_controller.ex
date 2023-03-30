defmodule RemoteWeb.UserController do
  use RemoteWeb, :controller

  alias Remote.UserServer

  def index(conn, _params) do
    {:ok, response} = GenServer.call(UserServer, :get_users)
    json(conn, response)
  end
end
