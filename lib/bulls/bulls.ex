defmodule BullsWeb.Game do

    # Done
    # create new/reset
    def new(gameName) do
        %{
            # Track Trun
            turn: 0,
            # Lobby States
            gameName: gameName,
            game: false,
            leaderBoard: %{}, #example: %{ player: [win, loss] }
            players: %{}, #example: %{ player: false}
            observers: MapSet.new(),
            prevWinner: [],
            # Game states
            results: [], #example: [[player, guess, result], ...]
            tempResults: [],
            playerWin: [], #example [[player, 1], [player2, 0]]
            secret: random_secret("", ["1", "2", "3", "4", "5", "6", "7", "8", "9"]),
            execute: [],
        }
    end

    # Done
    def view(state) do
        %{
            results: state.results,
            prevWinner: state.prevWinner,
            leaderBoard: state.leaderBoard,
            players: state.players,
            observers: MapSet.to_list(state.observers),
            gameName: state.gameName,
            game: state.game
        }
    end

    # Done 
    def leave_view() do 
        %{
            results: [],
            preWinner: [],
            leaderBoard: [],
            players: [],
            observers: [],
            gameName: "",
            userName: "",
            isPlayer: false,
            isReady: false
        }
    end 

    # update the state.players and state.observers by adding userName
    # Availability: All
    def join_game(state, userName) do
        if(MapSet.member?(state.observers, userName) || Map.has_key?(state.players, userName)) do
            state;
        else 
           newObserver =  MapSet.put(state.observers, userName);
           %{state | observers: newObserver};
        end
    end

    # update the state.players and state.observers by deleting userName
    # Availability: All
    def leave_game(state, userName) do
        cond do
            MapSet.member?(state.observers, userName) -> 
                newObserver = MapSet.delete(state.observers, userName);
                {:ok, %{state | observers: newObserver}};
            Map.has_key?(state.players, userName) ->
                newPlayers = Map.delete(state.players, userName);
                {:ok, %{state | players: newPlayers}};
            true -> {:error, message: "Unknown Player"}
        end
    end

    # update the state.players and state.observers by moving the userName from o to p or p to o
    # Availability: When game hasn't started
    def observer_game(state, userName) do
        if !state.game do
            cond do
                MapSet.member?(state.observers, userName) ->
                    newObserver = MapSet.delete(state.observers, userName);
                    newPlayers = Map.put(state.players, userName, false);
                    state1 = %{state | observers: newObserver};
                    {:ok, %{state1 | players: newPlayers}};
                Map.has_key?(state.players, userName) ->
                    newPlayers = Map.delete(state.players, userName);
                    newObserver = MapSet.put(state.observers, userName);
                    state1 = %{state | observers: newObserver};
                    {:ok, %{state1 | players: newPlayers}};
                true ->  {:error, messsage: "Unknown Player"};
            end
        else 
            {:error, messsage: "Game Started"};
        end
    end


    # update the state.players by toggling off the ready status of the userName
    # Availability: When game hasn't started
    def ready_game(state, userName) do
        if(!state.game) do
            cond do
                MapSet.member?(state.observers, userName) -> 
                    {:error, messsage: "Not a Player"};
                Map.has_key?(state.players, userName) -> 
                    newPlayers = Map.update!(state.players, userName, fn(readyStatus) -> !readyStatus end);
                    {:ok, %{state | players: newPlayers}};
                true ->  {:error, messsage: "Unknown Player"};     
            end
        else 
            {:error, message: "Game Started"};
        end
    end


    # start the game if all players are ready
    # Availability: when game hasn't started
    def start_game(state) do
        if (Enum.all?(state.players, fn {_username, status} -> status end) && map_size(state.players) >= 1) do
            state1 = %{state | game: true};
            {:ok, state1}
        else 
            {:error, state}
        end
    end


    # If the userName is observer do Nothing
    # Else execute the guess
    def guess_game(state, userName, guess) do
        if(MapSet.member?(state.observers, userName)) do
            {:error, message: "Not a player"};
        else
            #if user hasn't guessed yet
            if !Enum.member?(state.execute, userName) do
                {resp, msg} = validGuess(state, guess)
                case validGuess(state, guess) do
                    {:ok, msg} ->
                        {status, computed} = computeGuess(state.secret, guess, 0, 0, 0)
                            {:ok, %{state | execute: state.execute ++ [userName],
                                tempResults: state.tempResults ++ [[userName, guess, {status, computed}]]
                            }}
                    {:error, msg} -> {:error, message: msg}
                end
            else
                {:ok, state}
            end
        end
    end

    # Player pass
    def pass_game(state, userName) do
        IO.inspect("pass called")
        if(MapSet.member?(state.observers, userName)) do
            {:error, message: "Not a player"};
        else
            #if user hasn't guessed yet
            if !Enum.member?(state.execute, userName) do
                {:ok, %{state | 
                execute: state.execute ++ [userName],
                tempResults: state.tempResults ++ [[userName, "pass", {0, "0A0B"}]]
                }};
            else
                {:error, state}
            end
        end
    end
    
    defp addWinners(state, winner) do
        cond do
            length(state.tempResults) == 0 && winner > 0 ->
                %{state |
                    game: false,
                    execute: []
                }
            length(state.tempResults) == 0 && winner == 0 ->
                %{state |
                    execute: []
                }
            true ->
                head = hd(state.tempResults)
                #head = [player, guess, {status, computed}]
                {status, computed} = Enum.at(head, 2)
                player = Enum.at(head, 0);
                guess = Enum.at(head, 1);
                if status == 1 do
                    state = %{state |
                        prevWinner: state.prevWinner ++ [player],
                        results: state.results ++ [[player, guess, computed]],
                        tempResults: tl(state.tempResults),
                        playerWin: state.playerWin ++ [[player, status]]
                    }
                    addWinners(state, winner+1)
                else 
                    state = %{state |
                        results: state.results ++ [[player, guess, computed]],
                        tempResults: tl(state.tempResults),
                        playerWin: state.playerWin ++ [[player, status]]
                    }
                    addWinners(state, winner)
                end
        end
    end

    defp updateLeaderBoard(state) do
        IO.inspect("STATE DURING UPDATELEADERBOARD")
        IO.inspect(state)
        if length(state.playerWin) == 0 do
            state    
        else 
            head = hd(state.playerWin)
            playerName = Enum.at(head, 0)
            isWin = Enum.at(head, 1)
            #isWin = 1 if win 0 if loss
            if Map.has_key?(state.leaderBoard, playerName) do
                newState = %{ state |
                    playerWin: tl(state.playerWin),
                    leaderBoard: Map.update!(state.leaderBoard, playerName, fn(prev) ->
                        [Enum.at(prev, 0) + isWin, Enum.at(prev, 1) + (1-isWin)] 
                    end)
                }
                updateLeaderBoard(newState)
            else
                newLeaderBoard = Map.put(state.leaderBoard, playerName, [isWin, 1-isWin])
                newState = %{state |
                    playerWin: tl(state.playerWin),
                    leaderBoard: newLeaderBoard
                }
                updateLeaderBoard(newState)
            end
        end
    end

    defp reset(state) do
        newState = updateLeaderBoard(state)
        state1 = %{ newState |
            secret: random_secret("", ["1", "2", "3", "4", "5", "6", "7", "8", "9"]),
            results: [],
            turn: 0
        }
        # %{username: false, username: true}
        newPlayers = Enum.map(state1.players, fn{userName, status} -> {userName, !status} end)
        |> Enum.into(%{})
        %{ state1 | players: newPlayers }
    end

    def add_passed_results(state, players) do
        if length(players) == 0 do
            state
        else 
            player = hd(players)
            if Enum.member?(state.execute, player) do
                add_passed_results(state, tl(players))
            else
                newState = %{ state |
                    tempResults: state.tempResults ++ [[player, "pass", {0, "0A0B"}]]
                }
                add_passed_results(newState, tl(players))
            end
        end
    end
    

    def checkout_turn(state) do
        # check if theres a winner 
        # If yes, turn the state.game to false
        # If no, erase state.execute
        # IO.inspect("STATE BEFORE CHECKOUT")
        # IO.inspect(state)
        newState = add_passed_results(state, Map.keys(state.players))
        # IO.inspect("STATE AFTER ADDING PASSED BEFORE WINNER")
        # IO.inspect(newState)
        newState1 = addWinners(newState, 0)
        # IO.inspect("STATE IN CHECKOUT AFTER ADD WINNERS")
        # IO.inspect(newState1)
        if !newState1.game do
            reset(newState1);
        else 
            %{newState1 |
                playerWin: [],
                # I added
                turn: newState1.turn + 1
            }
        end
    end

    def try_checkout(state) do
        if length(state.execute) == map_size(state.players) && state.game do
            {:ok, checkout_turn(state)} 
        else
            {:error, state}
        end 
    end 

    # Try reset
    def try_reset(state) do
        if(map_size(state.players) == 0) do
            reset(state);
        else 
            state;
        end 
    end 

    # isNaN
    defp isNaN(str) do
        try do
            _x = String.to_integer(str);
            true;
        rescue
            ArgumentError -> false;
        end 
    end 

    defp alreadyGuessed(results, guess) do
        if length(results) == 0 do
            false
        else 
            if Enum.at(hd(results), 1) == guess do
                true
            else
                false or alreadyGuessed(tl(results), guess)
            end 
        end
    end

    #validGuess // Returns a new message
    defp validGuess(st, guess) do
        guessSet = MapSet.new(String.split(guess, "", trim: true));
        cond do 
            alreadyGuessed(st.results, guess) ->
                {:error, message: "Invalid: Require New Guess"};
            MapSet.size(guessSet) != 4 || String.length(guess) != 4 -> 
                {:error, "Invalid: Require 4 Unique Digits"}
            !isNaN(guess) -> 
                {:error, "Invalid: Require Only Numbers"}
            String.at(guess, 0) == "0" -> 
                {:error, "Invalid: 0 can't be the first digit"}
            true -> 
                {:ok, "Guess Processed"}
        end 
    end 

    # computeGuess // Returns guess result
    defp computeGuess(secret, guess, index, bull, cow) do
        if(index < String.length(guess)) do
            cond do
            String.at(guess, index) == String.at(secret, index) ->
                computeGuess(secret, guess, index + 1, bull + 1, cow);
            String.contains?(secret, String.at(guess, index)) ->
                computeGuess(secret, guess, index + 1, bull, cow + 1);
            true ->
                computeGuess(secret, guess, index + 1, bull, cow);
            end 
        else 
            if(bull == 4) do
                {1, "#{bull}A#{cow}B"}
            else 
                {0, "#{bull}A#{cow}B"}
            end 
        end 
    end 

    # Select Secret
    defp random_secret(acc, nums) do
        if String.length(acc) < 4 do
            random = Enum.random(nums);
            if(String.length(acc) == 0) do
                 random_secret(acc <> random, nums -- [random] ++ [0]);
            else 
                random_secret(acc <> random, nums -- [random]);
            end 
        else 
            acc
        end
    end 
end 