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

    # Done
    def add_user(gameName, userName) do
        GenServer.call(reg(gameName), {:join, userName}) 
    end

    # Done
    def leave_user(gameName, userName) do
        GenServer.cast(reg(gameName), {:leave, userName});
    end

    # def post_guess(gameName, username, guess) do
        
    # end

    def toggleReady(gameName, username) do
        GenServer.call(reg(gameName), username);
    end

    # def add_user(gameName, username) do
        
    # end

    # def switchObserver(gameName, username) do
        
    # end

    # def leave(gameName, username) do
        
    # end

    # def reset(gameName) do
        
    # end

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
    def handle_call({:join, userName}, _from, state) do
        case Game.join_game(state, userName) do 
            {:ok, state} -> {:reply, {:ok} ,state};
            {:error, msg} -> {:reply, {:error}, state};
        end 
    end

    # Leave
    def handle_cast({:leave, userName}, state) do
        {:ok, newState} = Game.leave_game(state, userName);
        {:noreply, newState};
    end

    # Ready 
    def handle_call({:ready, userName}, _from, state) do
        

    end
end