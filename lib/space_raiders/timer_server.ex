defmodule SpaceRaiders.Timer do
  use GenServer

  def reg(name) do
    {:via, Registry, {SpaceRaiders.GameReg, name}}
  end


  def start(name) do
    spec = %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [name]},
      restart: :permanent,
      type: :worker,
    }
    SpaceRaiders.GameSup.start_child(spec)
  end

  def start_link(name) do
    game = SpaceRaiders.Game.new()
    GenServer.start_link(__MODULE__, %{:game => game, :name => name}, name: reg(name))
  end

  def init(state) do
    %{:game => game, :name => name} = state
    schedule_update(1_000, name)
    broadcast(game, name)
    {:ok, state}
  end

  def handle_info("tick:"<> name, state) do
   game = cond do
      state[:game] != nil -> game = SpaceRaiders.Game.on_tick(state[:game])
      true -> SpaceRaiders.Game.on_tick(state)
    end
    broadcast(game, name)
    schedule_update(1_000, name)
    {:noreply, game}
  end

  def schedule_update(time, name) do
    Process.send_after(self(), "tick:" <> name, time)
  end


  defp broadcast(response, name) do
    SpaceRaidersWeb.Endpoint.broadcast!("space_raiders:" <> name, "new_tick", response)
  end

end
