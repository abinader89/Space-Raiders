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
    if(name !=[]) do
      game = SpaceRaiders.Game.new()
      GenServer.start_link(__MODULE__, %{:game => game, :name => name}, name: reg(name))
    else
      GenServer.start_link(__MODULE__, %{})
    end
  end

  def move(name, direction) do
     GenServer.call(reg(name), {:move, name, direction})
  end

  def handle_call({:move, name, direction}, _from, game) do
    game = SpaceRaiders.Game.move(game,1,  direction)
    {:reply, game, game}
  end

  def init(state) do
    if (state != %{}) do
      %{:game => game, :name => name} = state
      schedule_update(1_000, name)
     end
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
    "calling broadcase " <>name |> IO.inspect
    SpaceRaidersWeb.Endpoint.broadcast!("space_raiders" <> name, "new_tick", response)
  end

end
