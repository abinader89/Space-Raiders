defmodule SpaceRaidersWeb.SpaceRaidersChannel do
  use SpaceRaidersWeb, :channel

  alias SpaceRaiders.Game

  def join("space_raiders" <> name , payload, socket) do
    if authorized?(payload) do
      SpaceRaiders.Timer.start(name)
      {:ok, %{"join" => name}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("move", %{"direction" => direction, "id" => id}, socket) do
    game = socket.assigns[:game]
        |> Game.move(id, String.to_atom(direction))
        |> IO.inspect
    socket = socket
          |> assign(:game, game)
      {:reply, {:ok, %{"game" => game}}, socket}
  end


  def handle_in("new_tick", msg, socket) do
    "sending response" |> IO.inspect
    push(socket, "new_tick", msg)
    {:noreply, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (space_raiders:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
