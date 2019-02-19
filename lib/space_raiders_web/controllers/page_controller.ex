defmodule SpaceRaidersWeb.PageController do
  use SpaceRaidersWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  # login flow modeled off nat tucks hangman code on github
  def join(conn, %{"join" => %{"user" => user, "game" => game}}) do
    conn
      |> put_session(:user, user)
      |> put_session(:game, game)
      |> redirect(to: "/game/#{game}")
  end

  def game(conn, params) do
    user = get_session(conn, :user)
    if user do
      render conn, "game.html", game: params["name"], user: user
    else
      conn
        |> put_flash(:error , "No username chosen")
        |> redirect(to: "/")
      end
  end
end
