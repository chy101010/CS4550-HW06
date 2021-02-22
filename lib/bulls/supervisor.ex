defmodule Bulls.Supervisor do 
    use DynamicSupervisor

    # Client 
    def start_child(spec) do 
        DynamicSupervisor.start_child(__MODULE__, spec);
    end 

end 