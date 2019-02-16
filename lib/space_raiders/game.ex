defmodule SpaceRaiders.Game do

# the state is a map with ids, 0-#
# 0, 1 = players
# 2-27 = aliens
# 28, 29 = lasers
def new do
  aliens = 2..27
  state = Enum.map(0..29, &(%{id: &1}))
  Enum.map state, fn %{id: no} = identifier ->
    cond do
    no == 0 or no == 1 ->
      Map.put(identifier, :posn, %{x: 50, y: 50}) # these need to be distinct values
      |> Map.put(:lives, 3)
      |> Map.put(:powerups, nil)
    Enum.member?(aliens, no) ->
      Map.put(identifier, :posn, %{x: 50, y: 50}) # and these as well
      |> Map.put(:health, 2)
    no == 28 or no == 29 -> 
      Map.put(identifier, :posn, nil)
     end
    end
end
end
