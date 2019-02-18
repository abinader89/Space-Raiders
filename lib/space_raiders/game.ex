defmodule SpaceRaiders.Game do

  def get_players do
  players = Enum.map(0..1, &(%{id: &1}))
  Enum.map players, fn %{id: no} = identifier ->
  Map.put(identifier, :posn, %{x: 25 * (1 + no), y: 250})
    |> Map.put(:lives, 3)
    |> Map.put(:powerups, 0)
    end
  end

  def get_aliens do
    aliens = Enum.map(0..24, &(%{id: &1}))
    Enum.map aliens, fn %{id: no} = identifier ->
    cond do
    no < 5 ->
      Map.put(identifier, :posn, %{x: 10 * (1 + no), y: 15})
      |> Map.put(:health, 2)
    no < 10 ->
      Map.put(identifier, :posn, %{x: 10 * (1 + (rem(no, 5))), y: 25}) 
      |> Map.put(:health, 2)
    no < 15 ->
      Map.put(identifier, :posn, %{x: 10 * (1 + (rem(no, 5))), y: 35})
      |> Map.put(:health, 2)
    no < 20 ->
      Map.put(identifier, :posn, %{x: 10 * (1 + (rem(no, 5))), y: 45})
      |> Map.put(:health, 2)
    no < 25 ->
      Map.put(identifier, :posn, %{x: 10 * (1 + (rem(no, 5))), y: 55})
      |> Map.put(:health, 2)
    end
    end
  end

  def get_barriers do
    barriers = Enum.map(0..2, &(%{id: &1}))
    Enum.map barriers, fn %{id: no} = identifier ->
    Map.put(identifier, :posn, %{x: 33 * (1 + no), y: 220})
    |> Map.put(:health, 10)
    end
  end

  def get_lasers do
    lasers = Enum.map(0..1, &(%{id: &1}))
    Enum.map lasers, fn %{id: _no} = identifier ->
    Map.put(identifier, :inplay, false)
    |> Map.put(:posn, %{x: 0, y: 0}) # these have to be calculated based on the player
    end
  end

  def new do
    state = %{}
    players = get_players()
    lasers = get_lasers()
    aliens = get_aliens()
    barriers = get_barriers()

    Map.put(state, :players, players)
      |> Map.put(:lasers, lasers)
      |> Map.put(:aliens, aliens)
      |> Map.put(:barriers, barriers)
      |> Map.put(:right_shift, true)
      |> Map.put(:counter, 1)
  end

  # move: This function is the mapping to the left/right keys for the user to move his craft
  # game: state
  # playerID: integer mapping to players id field in the state
  # dir: atom :left or :right specifying the direction that the player should move

  # Logic for a new state
  def move(state, playerID, dir) do

  delta = move_help(state, playerID, dir) + Enum.at(state[:players], playerID).posn.x
  new_posn = Map.put(Enum.at(state[:players], playerID).posn, :x, delta)

  players = state[:players]
  updated_players = Enum.map players, fn %{id: num} = identifier ->
    if num == playerID do
        Map.put(identifier, :posn, new_posn)
    else
        identifier
    end
    end

  lasers = state[:lasers]
  aliens = state[:aliens]
  barriers = state[:barriers]
  right_shift = state[:right_shift]
  counter = state[:counter]

  state = %{}
  Map.put(state, :players, updated_players)
    |> Map.put(:lasers, lasers)
    |> Map.put(:aliens, aliens)
    |> Map.put(:barriers, barriers)
    |> Map.put(:right_shift, right_shift)
    |> Map.put(:counter, counter)
  end

  # Logic for calculating delta
  def move_help(state, playerID, dir) do
    players = state[:players]
    x = Enum.at(players, playerID).posn.x
    cond do
    dir == :left and x > 10 ->
      -5 
    dir == :right and x < 255 ->
      5
    true ->
    x
    end
  end

  # on_tick will be called to update the state
  def on_tick(state) do
    players = state[:players]
    lasers = state[:lasers]
    aliens = state[:aliens]
    barriers = state[:barriers]
    new_counter = rem(state[:counter] + 1, 100)
    right_shift = state[:right_shift]

    updated_lasers = update_lasers(lasers)
    updated_aliens = update_aliens(aliens, new_counter, right_shift)
    updated_right_shift = update_shift(right_shift, new_counter)

    state = %{}
    Map.put(state, :players, players)
      |> Map.put(:lasers, updated_lasers)
      |> Map.put(:aliens, updated_aliens)
      |> Map.put(:barriers, barriers)
      |> Map.put(:right_shift, updated_right_shift)
      |> Map.put(:counter, new_counter)
    end

  # delegate to update_lasers with the lasers map in the state
  def update_lasers(lasers) do
    Enum.map lasers, fn %{id: _no} = laser ->
    cond do
    laser[:inplay] and laser[:posn].y > 5 ->
        new_y = laser[:posn].y - 5
        Map.put(laser, :posn, %{x: laser[:posn].x, y: new_y})
    laser[:inplay] ->
        Map.put(laser, :inplay, false)
    true ->
        laser
    end
    end
  end

  # delegate to update_aliens with the aliens map in the state
  def update_aliens(aliens, counter, _right_shift) when counter == 0 do
        Enum.map aliens, fn %{id: _no} = alien ->
        new_y = alien[:posn].y + 5
        Map.put(alien, :posn, %{x: alien[:posn].x, y: new_y})
  end
  end

  def update_aliens(aliens, _descend, right_shift) when right_shift do
        Enum.map aliens, fn %{id: _no} = alien ->
        new_x = alien[:posn].x + 5
        Map.put(alien, :posn, %{x: new_x, y: alien[:posn].y})
  end
  end

  def update_aliens(aliens, _descend, _right_shift) do
        Enum.map aliens, fn %{id: _no} = alien ->
        new_x = alien[:posn].x - 5
        Map.put(alien, :posn, %{x: new_x, y: alien[:posn].y})
  end
  end

  # delegate to update_shift with the right_shift map in the state
  def update_shift(shift, counter) do 
    if counter == 0 do
      not shift
    else
      shift
    end
  end
end
