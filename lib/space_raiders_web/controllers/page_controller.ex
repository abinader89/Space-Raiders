defmodule SpaceRaidersWeb.PageController do
  use SpaceRaidersWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
