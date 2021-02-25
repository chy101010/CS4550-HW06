defmodule BullsWeb.GameChannel do
  use BullsWeb, :channel
  alias Bulls.Server
  alias BullsWeb.Game

  defp attachNames(view, userName) do
    Map.put(view, :userName, userName);
  end

  @impl true
  def join("game:" <> gameName, %{"userName" => userName} = payload, socket) do
    if(gameName == "" || userName == "") do
      view = Game.leave_view();
      {:ok, view, socket};
    end
    if authorized?(payload) do
      # Creates a game process with the given gameName if doesn't exist
      Server.start(gameName);
      # Joins the game process with the give userName
      Server.add_user(gameName, userName)
      # Gets the View
      view = Server.get_view(gameName);
      # BroadCast
      send(self(), {:after_join, gameName});
      socket1 = assign(socket, :userName, userName)
      |> assign(:gameName, gameName);
      {:ok, attachNames(view, userName), socket1};
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  def handle_in("leave", _payload, socket) do
    gameName = socket.assigns[:gameName];
    userName = socket.assigns[:userName];
    # Leave
    Server.leave_user(gameName, userName);
    # Check Ready
    Server.start_game(gameName);
    # Try Check_Out
    Server.try_check(gameName);
    send(self(), {:after_join, gameName});
    # Clear Socket Assigns
    socket1 = assign(socket, :gameName, nil)
    |> assign(:userName, nil)
    view = Game.leave_view();
    {:reply, {:ok, view}, socket};
  end

  @impl true
  def handle_in("toggleObserver", _payload, socket) do
    gameName = socket.assigns[:gameName];
    userName = socket.assigns[:userName];
    # Toggle observer
    Server.toggle_observer(gameName, userName);
    # Start Game
    Server.start_game(gameName);
    # BroadCast
    send(self(), {:after_join, gameName});
    {:noreply, socket};
  end

  @impl true
  def handle_in("toggleReady", _payload, socket) do
    gameName = socket.assigns[:gameName];
    userName = socket.assigns[:userName];
    # Toggle observer
    Server.toggle_ready(gameName, userName);
    # Check Ready
    Server.start_game(gameName);
    # BroadCast
    send(self(), {:after_join, gameName});
    {:noreply, socket};
  end


  # TODO display msg to the user
  @impl 
  def handle_in("guess", %{"guess" => guess} = payload, socket) do
    gameName = socket.assigns[:gameName];
    userName = socket.assigns[:userName];
    Server.make_guess(gameName, userName, guess);
    # Try Check_Out
    Server.try_check(gameName);
    # BroadCast
    send(self(), {:after_join, gameName});
    {:noreply, socket};
  end

  @impl
  def handle_in("pass", _payload, socket) do
    gameName = socket.assigns[:gameName];
    userName = socket.assigns[:userName];
    Server.pass_game(gameName, userName);
    # Try Check_Out
    Server.try_check(gameName);
    send(self(), {:after_join, gameName});
    {:noreply, socket};
  end


  @impl true
  def handle_info({:after_join, gameName}, socket) do
    view = Server.get_view(gameName);
    broadcast(socket, "view", view);
    {:noreply, socket};
  end

  intercept ["view"]
  @impl true
  def handle_out("view", msg, socket) do
    push(socket, "view", attachNames(msg, socket.assigns[:userName]));
    {:noreply, socket}
  end


  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end