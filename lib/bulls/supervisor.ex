defmodule Bulls.Sup do 
    # Create a supervised game process 
    def start_child(spec) do 
        DynamicSupervisor.start_child(__MODULE__, spec);
    end 
end 