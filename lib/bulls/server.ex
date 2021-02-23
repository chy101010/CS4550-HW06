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

    #dDone
    def start_link(gameName) do
        game = Game.new();
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

    # def post_guess(gameName, username, guess) do
        
    # end

    # def ready(gameName, username) do
        
    # end

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

    def handle_call(:view, _from, state) do
        {:reply, Game.view(state), state};
    end

    def handle_call({:join, userName}, _from, state) do
        case Game.join_game(state, userName) do 
            {:ok, state} -> {:reply, {:ok} ,state};
            {:error, msg} -> {:reply, {:error}, state};
        end 
    end 
end