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
      |> Map.put(:right_shift, false)
  end

  # move: This function is the mapping to the left/right keys for the user to move his craft
  # game: state
  # playerID: integer mapping to players id field in the state
  # dir: atom :left or :right specifying the direction that the player should move

  # Logic for a new state
  def move(game, playerID, dir) do

  delta = move_help(game, playerID, dir) + Enum.at(game[:players], playerID).posn.x
  new_posn = Map.put(Enum.at(game[:players], playerID).posn, :x, delta)

  players = game[:players]
  updated_players = Enum.map players, fn %{id: num} = identifier ->
    if num == playerID do
        Map.put(identifier, :posn, new_posn)
    else
        identifier
      end
    end

  lasers = game[:lasers]
  aliens = game[:aliens]
  barriers = game[:barriers]
  right_shift = game[:right_shift]

  state = %{}
  Map.put(state, :players, updated_players)
    |> Map.put(:lasers, lasers)
    |> Map.put(:aliens, aliens)
    |> Map.put(:barriers, barriers)
    |> Map.put(:right_shift, right_shift)
  end

  # Logic for calculating delta
  def move_help(game, playerID, dir) do
    players = game[:players]
    x = Enum.at(players, playerID).posn.x
    cond do
    dir == :left and x > 10 ->
      Enum.at(players, playerID).posn.x - 5
    dir == :right and x < 255 ->
      Enum.at(players, playerID).posn.x + 5
    true ->
    x
    end
  end
end
