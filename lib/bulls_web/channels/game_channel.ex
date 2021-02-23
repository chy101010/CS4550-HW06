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
      Server.add_user(gameName, userName);
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
    Server.leave_user(gameName, userName);
    send(self(), {:after_join, gameName});
    socket1 = assign(socket, :gameName, nil)
    |> assign(:userName, nil)
    view = Game.leave_view();
    {:reply, {:ok, view}, socket1};
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
