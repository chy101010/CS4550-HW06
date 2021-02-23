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

// // Now that you are connected, you can join channels with a topic:
// let channel = socket.channel("game:1", {})

// SetState
// let callback = null;

// User-Side States
// let state = {
//   guesses: [],
//   lives: 8,
//   message: "",
//   result: [],
  // User Input doesn't need to be stored in the socket
//   input: ""
// };

// Update the states with the given {@param st}
// function state_update(st) {
//   state = st;
//   if (callback) {
//     callback(st);
//   }
// }

// Passes in setState after re-render
// export function ch_join(cb) {
//   callback = cb;
//   callback(state);
// }

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


// joins a lobby with a game name
export function ch_join_lobby(gameName, userName) {
  let channel = socket.channel("game:" + gameName, {userName: userName})
  channel.join()
    .receive("ok", response => {
      // response.input = "";
      // state_update(response);
      console.log(response);
    })
    .receive("error", resp => { 
      console.log("Unable to join", resp) 
    })
}



export default socket
