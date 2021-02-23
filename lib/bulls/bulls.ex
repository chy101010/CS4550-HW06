defmodule BullsWeb.Game do

    # Done
    # create new/reset
    def new(gameName) do
        %{
            gameName: gameName,
            game: false,
            leaderBoard: %{}, #example: %{ player: (win, loss) }
            players: %{}, #example: %{ player: false}
            observers: MapSet.new(),
            results: [], #example: [{player, guess, result}, ...]
            prevWinner: "",
            secret: random_secret("", ["1", "2", "3", "4", "5", "6", "7", "8", "9"]),
        }
    end

    # Done
    def view(state) do
        %{
            results: state.results,
            prevWinner: state.prevWinner,
            leaderBoard: state.leaderBoard,
            players: Map.to_list(state.players),
            observers: MapSet.to_list(state.observers),
            gameName: state.gameName,
            game: state.game
        }
    end

    # Done 
    def leave_view() do 
        %{
            results: [],
            preWinner: "",
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
    def join_game(state, userName) do
        if(MapSet.member?(state.observers, userName) || Map.has_key?(state.players, userName)) do
            {:error, message: "Duplicate Player"};
        else 
           newObserver =  MapSet.put(state.observers, userName);
           {:ok, %{state | observers: newObserver}};
        end
    end

    # update the state.players and state.observers by deleting userName
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
    
    # # isOver?
    # def isOver?(st) do
    #     !st.game;
    # end  

    # # isNaN
    # defp isNaN(str) do
    #     try do
    #         _x = String.to_integer(str);
    #         true;
    #     rescue
    #         ArgumentError -> false;
    #     end 
    # end 

    # #validGuess // Returns a new message
    # def validGuess(st, guess) do
    #     guessSet = MapSet.new(String.split(guess, "", trim: true));
    #     cond do 
    #         MapSet.member?(st.guesses, guess) -> 
    #             %{st | message: {:error, "Invalid: Require New Guess"}};
    #         MapSet.size(guessSet) != 4 || String.length(guess) != 4 -> 
    #             %{st | message: {:error, "Invalid: Require 4 Unique Digits"}};
    #         !isNaN(guess) -> 
    #             %{st | message: {:error, "Invalid: Require Only Numbers"}};
    #         String.at(guess, 0) == "0" -> 
    #             %{st | message: {:error, "Invalid: 0 can't be the first digit"}};
    #         true -> 
    #             %{st | message: {:ok, "Guess Processed"}};
    #     end 
    # end 

    # # computeGuess // Returns guess result
    # defp computeGuess(secret, guess, index, bull, cow) do
    #     if(index < String.length(guess)) do
    #         cond do
    #         String.at(guess, index) == String.at(secret, index) ->
    #             computeGuess(secret, guess, index + 1, bull + 1, cow);
    #         String.contains?(secret, String.at(guess, index)) ->
    #             computeGuess(secret, guess, index + 1, bull, cow + 1);
    #         true ->
    #             computeGuess(secret, guess, index + 1, bull, cow);
    #         end 
    #     else 
    #         if(bull == 4) do
    #             {1, "#{bull}A#{cow}B"}
    #         else 
    #             {-1, "#{bull}A#{cow}B"}
    #         end 
    #     end 
    # end 

    # # compareGuess // Returns guesses, result, lives, message
    # def compareGuess(st, guess) do
    #     {status, computed} = computeGuess(st.secret, guess, 0, 0, 0);
    #     state0 = %{st | 
    #                 guesses: MapSet.put(st.guesses, guess), 
    #                 result: st.result ++ [computed],
    #                 lives: st.lives - 1};
    #     cond do
    #         (status == 1) ->
    #             %{state0 | game: false, message: {:ok, "Won the Game"}};
    #         (state0.lives == 0) ->
    #             %{state0 | game: false, message: {:ok, "Lost the Game"}};
    #         true ->
    #             state0;
    #     end 
    # end 

    # Select Secret
    def random_secret(acc, nums) do
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