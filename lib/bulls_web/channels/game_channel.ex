defmodule BullsWeb.GameChannel do
  use BullsWeb, :channel
  alias Bulls.Server
  alias BullsWeb.Game

    # Attaching the given {@ userName} to {@ view} and returns the {@ view}
  defp attachNames(view, userName) do
    Map.put(view, :userName, userName);
  end

  # Attaching the given {@ msg} to {@ view} and returns the {@ view}
  defp attachMsg(view, msg) do 
    Map.put(view, :message, msg);
  end

  # Handling user joining a lobby of the {@ gameName} name
  # Start a new game process if the progress doesn't exist
  # Redirect the user back to Login if gameName | userName is ""
  @impl true
  def join("game:" <> gameName, %{"userName" => userName} = payload, socket) do
    if(gameName == "" || userName == "") do
      view = Game.leave_view();
      {:ok, view, socket};
    else 
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
  end

  # Handling a user leave a lobby/game
  # When a player leaves a game, it will join back as an observer
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

  # Handling a user's request to switch between observer and player  
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

  # Handling a user's request to switch ready 
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


  # Handling an user's guess
  @impl 
  def handle_in("guess", %{"guess" => guess} = payload, socket) do
    gameName = socket.assigns[:gameName];
    userName = socket.assigns[:userName];
    {_status, msg} = Server.make_guess(gameName, userName, guess);
    socket1 = assign(socket, :message, msg);
    # Try Check_Out
    Server.try_check(gameName);
    # BroadCast
    send(self(), {:after_join, gameName});
    {:noreply, socket1};
  end

  # Handling a user's pass
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

  # To remove Warning
  @impl true
  def handle_info("onClose", socket) do
    {:noreply, socket};
  end 

  # Listening to after_join and broadcast a new view to the subscribers
  @impl true
  def handle_info({:after_join, gameName}, socket) do
    view = Server.get_view(gameName);
    broadcast(socket, "view", view);
    {:noreply, socket};
  end

  # Intercepting broadcasts and attaches userName and Message
  intercept ["view"]
  @impl true
  def handle_out("view", msg, socket) do
    push(socket, "view", attachMsg(attachNames(msg, socket.assigns[:userName]), socket.assigns[:message]));
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end