import React, {useState} from 'react';


function Lobby(props) {

    function getPlayerStatus(isPlayer) {
        return isPlayer ? "Player" : "Observer";
    }

    function getReadyStatus(isReady) {
        return isReady ? "Ready" : "Not Ready";
    }

    // Display
    // gamename
    // Display prev winner 
    // players
    // leader boarder

    // Function
    // player or observer
    // toggle if they're ready

    let display = [];
    for (const [index, [key, value]] of Object.entries(Object.entries(props.leaderBoard))) {
        display.push(
            <tr key={index+50}>
                <td key={index+100}>{key}</td>
                <td key={index+150}>{value[0]}/{value[1]}</td>
            </tr>
        )
    }


    return (
        <div id="lobby">
            <h1>Lobby: {props.gamename}</h1>
            <h1>Previous Winner: {props.prevWinner}</h1>

            <table>
                <thead>
                    <tr>
                        <th>Player</th>
                        <th>Output</th>
                    </tr>
                </thead>
                <tbody>
                    {display}
                </tbody>
            </table>
            <h1>Player: {props.userName}</h1>
            <button onClick={props.handleToggleObserver}>getPlayerStatus({props.isPlayer})</button>
            <button onClick={props.handleReady}>getReadyStatus({props.isReady})</button>
            <button onClick={props.handleLeave}>Leave</button>
        </div>
    )

}

export default Lobby;