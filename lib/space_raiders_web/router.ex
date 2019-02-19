defmodule SpaceRaidersWeb.Router do
  use SpaceRaidersWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SpaceRaidersWeb do
    pipe_through :browser

    get "/", PageController, :index
    post "/game", PageController, :game
    get "/game/:name", PageController, :game
    post "/join", PageController, :join
  end
  # Other scopes may use custom stacks.
  # scope "/api", SpaceRaidersWeb do
  #   pipe_through :api
  # end
end
