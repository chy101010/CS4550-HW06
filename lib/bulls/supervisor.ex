defmodule Bulls.Sup do 
    # Client 
    def start_child(spec) do 
        DynamicSupervisor.start_child(__MODULE__, spec);
    end 

    def terminate_child(gameName) do
        DynamicSupervisor.terminate_child(__MODULE__, gameName);
    end
end 