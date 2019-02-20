defmodule SpaceRaiders.Timer do
  use GenServer

  alias SpaceRaiders.BackupAgent

  def reg(name) do
    {:via, Registry, {SpaceRaiders.GameReg, name}}
  end


  def start(name, user) do
    spec = %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [%{name: name, user: user}]},
      restart: :permanent,
      type: :worker,
    }
    SpaceRaiders.GameSup.start_child(spec)
  end

  def start_link(params) do
    if(params !=[]) do
      %{:name => name, :user => user} = params
      game = SpaceRaiders.BackupAgent.get(name) || SpaceRaiders.Game.new(user)
      if(SpaceRaiders.BackupAgent.get(name) != nil) do
        join(name, user)
      end
      GenServer.start_link(__MODULE__, %{:game => game, :name => name}, name: reg(name))
    else
      GenServer.start_link(__MODULE__, %{})
    end
  end

  def move(name, direction, id) do
     GenServer.call(reg(name), {:move, name, direction, id})
  end

  def fire(name, id) do
    GenServer.call(reg(name), {:fire, name, id})
  end

  def join(name, user) do
    GenServer.call(reg(name), {:join, name, user})
  end

  def handle_call({:join, name, user}, _from, game) do
    game = SpaceRaiders.Game.add_player(game, user)
    BackupAgent.put(name, game)
    {:reply, game, game}
  end

  def handle_call({:fire, name, id}, _from, game) do
    game = SpaceRaiders.Game.fire(game, id);
    BackupAgent.put(name, game)
    {:reply, game, game}
  end

  def handle_call({:move, name, direction, id}, _from, game) do
    game = SpaceRaiders.Game.move(game, id,  direction)
    BackupAgent.put(name, game)
    {:reply, game, game}
  end

  def init(state) do
    if (state != %{}) do
      %{:game => game, :name => name} = state
      schedule_update(100, name)
     end
    {:ok, state}
  end

  def handle_info("tick:"<> name, state) do
   game = cond do
      state[:game] != nil -> game = SpaceRaiders.Game.on_tick(state[:game])
      true -> SpaceRaiders.Game.on_tick(state)
    end
    broadcast(game, name)
    BackupAgent.put(name, game)
    schedule_update(100, name)
    {:noreply, game}
  end

  def schedule_update(time, name) do
    Process.send_after(self(), "tick:" <> name, time)
  end


  defp broadcast(response, name) do
    SpaceRaidersWeb.Endpoint.broadcast!("space_raiders" <> name, "new_tick", response)
  end

end
