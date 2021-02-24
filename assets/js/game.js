import React, { useState } from 'react';

function Game(props) {
  const [state, setState] = useState("");

  const handleUserNameChange = (ev) => {
    setState(ev.target.value);
  }

  function handleGuess() {
    props.handleGuess(state);
  }

  let results = [];
  for(let index = 0; index < props.results.length; index++) {
    results.push(
      <tr key={index + 50}>
          <td key={index + 100}>{props.results[index][0]}</td>
          <td key={index + 150}>{props.results[index][1]}</td>
          <td key={index + 100}>{props.results[index][2]}</td>
      </tr>
      )
  }
  return (
    <div>
      <table>
        <thead>
          <tr>
            <td>Player</td>
            <td>Guess</td>
            <td>Result</td>
          </tr>
        </thead>
        <tbody>
          {results}
        </tbody>
      </table>

      <input onChange={handleUserNameChange} value={state} type="text" maxLength="4"/>
      <button onClick={handleGuess}>Guess!</button>
      <button onClick={props.handleLeave}>Leave</button>
      <button onClick={props.handlePass}>Pass</button>
    </div>);
}

export default Game;