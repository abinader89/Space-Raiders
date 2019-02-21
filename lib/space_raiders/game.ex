defmodule SpaceRaiders.Game do

  def get_player(name, id) do
    player = %{id: id, name: name}
    Map.put(player, :posn, %{x: 200 * (1 + id), y: 250})
      |> Map.put(:lives, 3)
      |> Map.put(:powerups, 0)
  end

  def add_player(game, name) do
    id = game[:players]
            |> Enum.reduce(0, fn player, acc ->   cond do
                                                    player[:name] == name -> -1
                                                    player[:id] >= acc && acc != -1 -> player[:id] + 1
                                                    true -> acc
                                                 end end)
    cond do
      id == -1 -> game
      true ->
       player = get_player(name, id)
       newPlayers =  game[:players] ++ [player]
       Map.put(game, :players, newPlayers)
    end
  end

  def get_aliens do
    aliens = Enum.map(0..24, &(%{id: &1}))
    Enum.map aliens, fn %{id: no} = identifier ->
    cond do
    no < 5 ->
      Map.put(identifier, :posn, %{x: 25 * (1 + no), y: 25})
      |> Map.put(:health, 2)
    no < 10 ->
      Map.put(identifier, :posn, %{x: 25 * (1 + (rem(no, 5))), y: 50})
      |> Map.put(:health, 2)
    no < 15 ->
      Map.put(identifier, :posn, %{x: 25 * (1 + (rem(no, 5))), y: 75})
      |> Map.put(:health, 2)
    no < 20 ->
      Map.put(identifier, :posn, %{x: 25 * (1 + (rem(no, 5))), y: 100})
      |> Map.put(:health, 2)
    no < 25 ->
      Map.put(identifier, :posn, %{x: 25 * (1 + (rem(no, 5))), y: 125})
      |> Map.put(:health, 2)
    end
    end
  end

  def get_barriers do
    barriers = Enum.map(0..2, &(%{id: &1}))
    Enum.map barriers, fn %{id: no} = identifier ->
    Map.put(identifier, :posn, %{x: 150 * (1 + no), y: 220})
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

  def new(user) do
    state = %{}
    players = [get_player(user, 0)]
    lasers = get_lasers()
    aliens = get_aliens()
    barriers = get_barriers()

    Map.put(state, :players, players)
      |> Map.put(:lasers, lasers)
      |> Map.put(:aliens, aliens)
      |> Map.put(:barriers, barriers)
      |> Map.put(:right_shift, true)
      |> Map.put(:counter, 1)
      |> Map.put(:alien_lasers, [])
      |> Map.put(:over, false)
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
    Map.put(state, :players, updated_players)
  end

  # Logic for calculating delta
  def move_help(state, playerID, dir) do
    players = state[:players]
    x = Enum.at(players, playerID).posn.x
    cond do
    dir == :left and x > 10 ->
      -5
    dir == :right and x < 600 ->
      5
    true ->
      0
    end
  end

  # logic for the players firing
  def fire(state, playerID) do
  laser = Enum.at(state[:lasers], playerID)
  if not laser.inplay do
      player_x = Enum.at(state[:players], playerID)[:posn].x
      new_posn = %{x: player_x, y: 250}
      lasers = state[:lasers]
      fired_lasers = Enum.map lasers, fn %{id: num} = identifier ->
      if num == playerID do
          Map.put(identifier, :posn, new_posn)
          |> Map.put(:inplay, true)
      else
          identifier
      end
      end
      Map.put(state, :lasers, fired_lasers)
  else
      state
  end
  end

  # on_tick will be called to update the state
  def on_tick(state) do
    players = state[:players]
    lasers = state[:lasers]
    alien_lasers = state[:alien_lasers]
    aliens = state[:aliens]
    barriers = state[:barriers]
    new_counter = rem(state[:counter] + 1, 100)
    right_shift = state[:right_shift]


    updated_lasers = update_lasers(lasers)
    updated_alien_lasers = update_alien_lasers(alien_lasers, aliens, new_counter) |> update_alien_lasers
    updated_aliens = update_aliens(aliens, new_counter, right_shift)
    updated_right_shift = update_shift(right_shift, new_counter)
    {updated_aliens, updated_lasers} = check_for_collision(updated_aliens, updated_lasers, 15, 15)
    {updated_players, updated_alien_lasers} = check_for_collision(players, updated_alien_lasers, 15, 15)
    {updated_barriers, updated_alien_lasers} = check_for_collision(barriers, updated_alien_lasers, 60, 10)
    state = Map.put(state, :players, updated_players)
      |> Map.put(:lasers, updated_lasers)
      |> Map.put(:alien_lasers, updated_alien_lasers)
      |> Map.put(:aliens, updated_aliens)
      |> Map.put(:barriers, updated_barriers)
      |> Map.put(:right_shift, updated_right_shift)
      |> Map.put(:counter, new_counter)
    Map.put(state, :over, is_game_over(state))
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

  def is_game_over(state) do
      %{players: players, aliens: aliens} = state
      cond do
        length(players) == 0 -> true
        length(aliens) == 0 -> true
        List.last(aliens)[:posn].y >= hd(players)[:posn].y -> true
        true -> false
      end
  end

  def check_for_laser_collision(lasers, aliens, hitWidth, hitLength) do
     lasers
          |> Enum.map(fn laser ->
                         %{x: lx, y: ly} =
                                cond do
                                  laser[:posn] != nil -> laser[:posn]
                                  true -> laser
                                end
                                didhit = Enum.reduce(aliens, false, fn
                                                                    alien, isStillAlive ->
                                                                    %{posn: %{x: ax, y: ay}} = alien
                                                                    cond do
                                                                      isStillAlive != false -> isStillAlive
                                                                      abs(lx - ax) < hitWidth && abs(ly - ay) < hitLength ->true
                                                                      true -> isStillAlive
                                                                     end
                                 end)
                          cond do
                            didhit -> Map.merge(laser, %{inplay: false})
                            true -> laser
                          end
             end)

  end

  def check_for_collision(aliens, lasers, hitWidth, hitLength) do
    updated_aliens = aliens
          |> Enum.filter(fn alien ->
                            %{posn: %{x: ax, y: ay}} = alien
                            alive = Enum.reduce(lasers,
                                        true,
                                        fn laser,
                                           hascollided -> {%{x: lx, y: ly}, inplay} =
                                                          cond do
                                                            laser[:posn] != nil -> {laser[:posn], laser[:inplay]}
                                                            true -> {laser, true}
                                                          end
                                                          cond do
                                                           inplay === false -> hascollided
                                                           hascollided != true -> hascollided
                                                           abs(lx - ax) < hitWidth && abs(ly - ay) < hitLength -> false
                                                           true -> true
                                                           end end)
                              alive
                        end)
      lasers = check_for_laser_collision(lasers, aliens, hitWidth, hitLength)
     {updated_aliens, lasers}
  end

  # delegate to update_alien_lasers with the aliens_lasers map in the state
  # logic for spawning lasers
  def update_alien_lasers(alien_lasers, aliens, counter) do
    if (rem(counter, 33) == 0) do
        upper_bound = length(aliens) - 1
        combatantID = Enum.random(0..upper_bound)
        combatant = Enum.at(aliens, combatantID)
        lasers_posn = combatant[:posn]
        _aliens_lasers = [ lasers_posn | alien_lasers ]
        else
        alien_lasers
    end
  end

  # logic for updating the lasers
  def update_alien_lasers(alien_lasers) when length(alien_lasers) > 0 do
    head = hd(alien_lasers)
    if head do
        Enum.filter(alien_lasers, fn posn -> posn[:y] < 255 end)
        |> Enum.map(fn posn -> Map.put(posn, :y, posn[:y] + 5) end)
    end
    end

    def update_alien_lasers(_empty) do
    []
    end

  # delegate to update_aliens with the aliens map in the state
  def update_aliens(aliens, counter, _right_shift) when counter == 0 do
        Enum.map aliens, fn %{id: _no} = alien ->
        new_y = alien[:posn].y + 5
        Map.put(alien, :posn, %{x: alien[:posn].x, y: new_y})
  end
  end

  def update_aliens(aliens, _counter, right_shift) when right_shift do
        Enum.map aliens, fn %{id: _no} = alien ->
        new_x = alien[:posn].x + 5
        Map.put(alien, :posn, %{x: new_x, y: alien[:posn].y})
  end
  end

  def update_aliens(aliens, _counter, _right_shift) do
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


  def disconnect(game, id) do
    %{players: players} = game
    updatedPlayers = players
                       |> Enum.reduce([], fn player, acc ->
                                            cond do
                                              (player[:id] != id) -> [player | acc]
                                               true -> acc
                                             end
                                           end)
        game = game
              |> Map.put(:players, updatedPlayers)
        {game, false}
    cond do
      length(players) == 1 -> {game, true}
      true -> {game, false}
      end
  end
end
