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

// Updates the user-side input with the given {@param input}
// export function store_input(input) {
//   state.input = input;
// }

// Pushes the guess to the channel
// export function ch_push(guess = "wrong") {
//   channel.push("guess", { guess: guess })
//     .receive("ok", response => {
//       response.input = "";
//       state_update(response);
//     })
//     .receive("error", response => {
//       ("Unable to push", response)
//     });
// }

// // Requests a reset 
// export function ch_reset() {
//   channel.push("reset", "")
//   .receive("ok", response => {
//     response.input = "";
//     state_update(response);
//   })
//   .receive("error", resp => { 
//     console.log("Unable to reset", resp) 
//   })
// }


// joins a lobby with a gameName
export function ch_join_lobby(gameName, userName) {
  channel = socket.channel("game:" + gameName, {userName: userName})
  channel.join()
    .receive("ok", response => {
      state_update(response);
      channel.on("view", state_update);
      // channel.onClose();
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



export default socket
