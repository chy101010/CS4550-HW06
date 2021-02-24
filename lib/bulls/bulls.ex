defmodule BullsWeb.Game do

    # Done
    # create new/reset
    def new(gameName) do
        %{
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
        IO.inspect(state.tempResults)
        IO.inspect("guess game")
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
        if(MapSet.member?(state.observers, userName)) do
            {:error, message: "Not a player"};
        else
            #if user hasn't guessed yet
            if !Enum.member?(state.execute, userName) do
                {:ok, %{state | execute: state.execute ++ [userName]}};
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
                    leaderBoard: Map.update!(state.leaderBoard, playerName, fn(prev) -> [Enum.at(prev, 0) + isWin, Enum.at(prev, 1) + (1-isWin)] end)
                }
                updateLeaderBoard(newState)
            else
                newLeaderBoard = Map.put(state.leaderBoard, playerName, [isWin, 1-isWin])
                newState = %{state |
                    leaderBoard: newLeaderBoard
                }
                updateLeaderBoard(newState)
            end
        end
    end

    defp reset(state) do
        state1 = %{ state |
            secret: random_secret("", ["1", "2", "3", "4", "5", "6", "7", "8", "9"]),
            results: [],
            playerWin: []
        }
        # %{username: false, username: true}
        newPlayers = Enum.map(state1.players, fn{userName, status} -> {userName, !status} end)
        |> Enum.into(%{})
        state2 = %{ state1 |
            players: newPlayers
        }
        updateLeaderBoard(state2)
    end

    def checkout_turn(state) do
        # check if theres a winner 
        # If yes, turn the state.game to false
        # If no, erase state.execute
        newState = addWinners(state, 0)
        IO.inspect(state);
        if !newState.game do
           reset(newState);
        else 
            %{newState |
                playerWin: []
            }
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
                IO.puts("Already Guessed");
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

    # compareGuess // Returns guesses, result, lives, message
    defp compareGuess(st, guess) do
        {status, computed} = computeGuess(st.secret, guess, 0, 0, 0);
        state0 = %{st | 
                    guesses: MapSet.put(st.guesses, guess), 
                    result: st.result ++ [computed],
                    lives: st.lives - 1};
        cond do
            (status == 1) ->
                %{state0 | game: false, message: {:ok, "Won the Game"}};
            (state0.lives == 0) ->
                %{state0 | game: false, message: {:ok, "Lost the Game"}};
            true ->
                state0;
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