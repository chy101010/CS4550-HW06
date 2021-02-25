defmodule Bulls.Server do
    alias BullsWeb.Game

    def reg(gameName) do
        {:via, Registry, {Bulls.Registry, gameName}}
    end

    # Client 
    # Start a game process with the given gameName
    def start(gameName) do
        spec = %{
            id: __MODULE__,
            start: {__MODULE__, :start_link, [gameName]},
            restart: :permanent,
            type: :worker,
        }
        if(Registry.lookup(Bulls.Registry, gameName)) do
            Bulls.Sup.start_child(spec);
        else
            {:ok}
        end
    end

    def start_link(gameName) do
        game = Game.new(gameName);
        GenServer.start_link(__MODULE__, game, name: reg(gameName))
    end

    def get_view(gameName) do
        GenServer.call(reg(gameName), :view);
    end

    def add_user(gameName, userName) do
        GenServer.cast(reg(gameName), {:join, userName});
    end

    def leave_user(gameName, userName) do
        GenServer.cast(reg(gameName), {:leave, userName});
    end

    def toggle_observer(gameName, username) do
        GenServer.cast(reg(gameName), {:observer, username});
    end

    def toggle_ready(gameName, username) do
        GenServer.cast(reg(gameName), {:ready, username});
    end

    def make_guess(gameName, username, guess) do
        GenServer.call(reg(gameName), {:guess, username, guess});
    end

    def start_game(gameName) do
        GenServer.cast(reg(gameName), {:start, gameName});
    end

    def pass_game(gameName, userName) do
        GenServer.cast(reg(gameName), {:pass, userName});
    end

    def try_check(gameName) do
        GenServer.cast(reg(gameName), {:try_check});
    end 

    # Server 
    @impl true
    def init(state) do 
        {:ok, state}
    end 

    # View
    def handle_call(:view, _from, state) do
        {:reply, Game.view(state), state};
    end

    # Join
    def handle_cast({:join, userName}, state) do
        {:noreply, Game.join_game(state, userName)};
    end

    # Leave
    def handle_cast({:leave, userName}, state) do
        case Game.leave_game(state, userName) do
            {:ok, newState} -> {:noreply, Game.try_reset(newState)};
            {:error, _msg} -> {:noreply, state}
        end
    end

    # Toggle Observer
    def handle_cast({:observer, userName}, state) do
        case Game.observer_game(state, userName) do 
            {:ok, newState} -> {:noreply, newState};
            {:error, msg} -> {:noreply, state};
        end 
    end

    # Toggle Ready 
    def handle_cast({:ready, userName}, state) do
        case Game.ready_game(state, userName) do
            {:ok, newState} -> {:noreply, newState};
            {:error, msg} -> {:noreply, state};
        end
    end


    # Post a guess
    def handle_call({:guess, userName, guess}, _from, state) do
        case Game.guess_game(state, userName, guess) do
            {:error, msg} -> {:reply, {:error, msg}, state};
            {:ok, msg, newState} -> {:reply, {:ok, msg}, newState};
        end
    end

    # Try check out 
    def handle_cast({:try_check}, state) do
        case Game.try_checkout(state) do
            {:ok, checked} ->
                Process.send_after(self(), {:check_out, checked.gameName, checked.turn}, 30000);
                {:noreply, checked};
            {:error, unChecked} ->
                {:noreply, unChecked};
        end 
    end

    # Start Game
    def handle_cast({:start, gameName}, state) do
        case Game.start_game(state) do
            {:error, oldState} ->
                {:noreply, oldState};
            {:ok, newState} ->
                Process.send_after(self(), {:check_out, gameName, 0}, 30000);
                {:noreply, newState};
        end
    end

    # Pass Game
    def handle_cast({:pass, userName}, state) do
        case Game.pass_game(state, userName) do
            {:error, _msg} -> 
                {:noreply, state}
            {:ok, newState} -> 
                {:noreply, newState};
        end
    end

    # Check out turn
    def handle_info({:check_out, gameName, turn}, state) do
        # Leave/Pass/Guess
        if(state.turn == turn && state.game) do
            newState = Game.checkout_turn(state);
            if (newState.game) do
                Process.send_after(self(), {:check_out, gameName, newState.turn}, 30000);
            end
            BullsWeb.Endpoint.broadcast("game:" <> gameName, "view", Game.view(newState));
            {:noreply, newState};
        else 
            {:noreply, state};
        end 
    end
end