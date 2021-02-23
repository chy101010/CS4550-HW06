// import React, {useState, useEffect} from 'react';
// import { ch_join, ch_push, ch_reset, store_input} from './socket';


// export function Bulls() {
//   // States
//   const [state, setState] = useState({
//     // User guesses
//     guesses: [],
//     // Lives
//     lives: 0,
//     // Message
//     message: "",
//     // Results
//     result: [],
//     // Input
//     input: ""
//   });

//   // Sends setState when render
//   useEffect(() => {
//     ch_join(setState);
//   });

//   console.log(state.secret);
  
//   // Send the input to the channel to process the guess
//   const submitGuess = () => {
//     ch_push(state.input);
//   }

//   // onChange handler for the text-input element, set the state {input} to text-input's value
//   const handleOnChange = ({ target }) => {
//     store_input(target.value);
//     setState((prev) => ({
//       ...prev,
//       input: target.value
//     }))
//   }

//   // onKeyDown handler for the text-input element if "Enter" is pressed, then the guess of the user will be processed
//   const handleKeyDown = (event) => {
//     if (event.key === "Enter") {
//       submitGuess();
//     }
//   }

//   // onClick hanlder for the button-input element if this element is clicked, then the guess of the user will be processed
//   const handleClickGuess = () => {
//     submitGuess();
//   }


//   // Send the reset request to the channel 
//   const handleClickReset = () => {
//     ch_reset();
//   }

  
//   let rows = [];
//   for (let i = 0; i < state.guesses.length; i++) {
//     let oldGuess = <td>{state.guesses[i]}</td>;
//     let message = <td>{state.result[i]}</td>;
//     rows.push(<tr>{[oldGuess, message]}</tr>);
//   }
//   return (
//     <div className="App">
//       <h1>4 Digits</h1>
//       <h4>{state.message}</h4>
//       <h5>Lives:{state.lives}</h5>
//       <input id="input" onChange={handleOnChange} onKeyDown={handleKeyDown} value={state.input} type="text" maxLength="4"/>
//       <input onClick={handleClickGuess} type="button" value="Guess!" />
//       <input onClick={handleClickReset} className="button button-clear" type="button" value="Reset" />
//       <table>
//         <thead>
//           <tr>
//             <td>Guess</td>
//             <td>Result</td>
//           </tr>
//         </thead>
//         <tbody>
//           {rows}
//         </tbody>
//       </table>
//       <p>Note: If the matching digits are in their right positions, they are "bulls", if in different positions, they are "cows".</p>
//     </div>);
// }