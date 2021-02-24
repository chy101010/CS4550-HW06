// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket,
// and connect at the socket path in "lib/web/endpoint.ex".
//
// Pass the token on params as below. Or remove it
// from the params if you are not using authentication.
import { Socket } from "phoenix"

let socket = new Socket("/socket", { params: { token: "" } })

socket.connect();

socket.onClose(() =>{
  channel.push("onClose", "");
});

// // Now that you are connected, you can join channels with a topic:
// let channel = socket.channel("game:1", {})

// SetState
let callback = null;

// Channel
let channel = null;

// User-Side States
let state = {
};

// Update the states with the given {@param st}
export function state_update(st) {
  state = st;
  console.log(state);
  if (callback) {
    callback(st);
  }
}

// Passes in setState after re-render
export function ch_join(cb) {
  callback = cb;
  callback(state);
}

// joins a lobby with a gameName
export function ch_join_lobby(gameName, userName) {
  channel = socket.channel("game:" + gameName, {userName: userName})
  channel.join()
    .receive("ok", response => {
      state_update(response);
      channel.on("view", state_update);
    })
    .receive("error", resp => { 
      console.log("Unable to join", resp) 
    })
}

// leave a game/lobby 
export function ch_leave() {
  channel.push("leave", "")
    .receive("ok", response => {
      state_update(response);
      channel.leave();
    })
    .receive("error", resp => { 
      console.log("Unable to reset", resp) 
    })
}

// observer toggle
export function ch_toggle_observer() {
  channel.push("toggleObserver", "");
}

// player toggle
export function ch_toggle_ready() {
  channel.push("toggleReady", "");
} 

// player guess
export function ch_guess(guess = "wrong") {
  channel.push("guess", {guess: guess});
}

// player guess
export function ch_pass() {
  channel.push("pass", "");
}



export default socket
