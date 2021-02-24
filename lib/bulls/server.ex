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

    # Done
    def start_link(gameName) do
        game = Game.new(gameName);
        GenServer.start_link(__MODULE__, game, name: reg(gameName))
    end

    # Done
    def get_view(gameName) do
        GenServer.call(reg(gameName), :view);
    end

    # Done // TODO? Error Handling
    def add_user(gameName, userName) do
        GenServer.cast(reg(gameName), {:join, userName});
    end

    # Done // TODO? Error Handling
    def leave_user(gameName, userName) do
        GenServer.cast(reg(gameName), {:leave, userName});
    end

    # Done // TODO? Error Handling
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
            {:ok, newState} -> {:noreply, newState};
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
            {:ok, newState} -> {:reply, {:ok}, newState};
        end
    end

    # Start Game
    def handle_cast({:start, gameName}, state) do
        case Game.start_game(state) do
            {:error, oldState} ->
                {:noreply, oldState};
            {:ok, newState} ->
                send(self(), {:check_out, gameName});
                {:noreply, newState};
        end
    end

    # Pass Game
    def handle_cast({:pass, userName}, state) do
        case Game.pass_game(state, userName) do
            {:error, _msg} -> 
                {:noreply, state}
            {:ok, newSocket} ->
                {:noreply, newSocket};
        end
    end

    # Check out turn
    def handle_info({:check_out, gameName}, state) do
        IO.puts("called Checkout");
        newState = Game.checkout_turn(state);
        if (newState.game) do
            Process.send_after(self(), {:check_out, gameName}, 4000);
        end
        BullsWeb.Endpoint.broadcast("game:" <> gameName, "view", Game.view(newState));
        {:noreply, newState};
    end
end