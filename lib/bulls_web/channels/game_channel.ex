defmodule BullsWeb.GameChannel do
  use BullsWeb, :channel

  @impl true
  def join("game:" <> _id, payload, socket) do
    if authorized?(payload) do
      game = BullsWeb.Game.new();
      socket1 = assign(socket, :game, game);
      view = BullsWeb.Game.view(game);
      {:ok, view, socket1};
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Handle guess
  @impl true
  def handle_in("guess", %{"guess" => guess}, socket) do
    game0 = socket.assigns[:game];
    if (!BullsWeb.Game.isOver?(game0)) do
      game1 = BullsWeb.Game.validGuess(game0, guess);
      case game1[:message] do
        {:error, _message} ->
          view = BullsWeb.Game.view(game1);
          {:reply, {:ok, view}, socket}
        {:ok, _message} ->
          game2 = BullsWeb.Game.compareGuess(game1, guess);
          view = BullsWeb.Game.view(game2);
          socket1 = assign(socket, :game, game2);
          {:reply, {:ok, view}, socket1};
      end
    else
      view = BullsWeb.Game.view(game0);
      {:reply, {:ok, view}, socket};
    end
  end

  # Uncatched arguments 
  @impl true
  def handle_in("guess", _x, socket) do
    game0 = socket.assigns[:game];
    view = BullsWeb.Game.view(game0);
    {:reply, {:ok, view}, socket};
  end

  # Handle rest 
  @impl true
  def handle_in("reset", _payload, socket) do
      game = BullsWeb.Game.new();
      socket1 = assign(socket, :game, game);
      view = BullsWeb.Game.view(game);
      {:reply, {:ok, view}, socket1};
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (game:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
