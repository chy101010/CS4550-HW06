import React from 'react';

function Lobby(props) {

    // Display
    // gamename
    // Display prev winner 
    // players
    // leader boarder

    // Function
    // player or observer
    // toggle if they're ready


    // TODO refactor 
    let leaderBoard = [];
    for (const [index, [key, value]] of Object.entries(Object.entries(props.leaderBoard))) {
        leaderBoard.push(
            <tr key={index + 50}>
                <td key={index + 100}>{key}</td>
                <td key={index + 150}>{value[0]}/{value[1]}</td>
            </tr>
        )
    }

    // TODO refactor 
    let observerBoard = [];
    for(let index = 0; index < props.observers.length; index++) {
        observerBoard.push(
            <tr key={index + 50}>
                <td key={index + 1000}>{`Username: ${props.observers[index]}`}</td>
            </tr>
        )
    }

    // TODO refactor
    let playersBoard = [];
    let index = 0;
    for (const [key, value] of Object.entries(props.players)) {
        playersBoard.push(
            <tr key={index + 1950}>
                <td key={index + 2000}>{key}</td>
                <td key={index + 2050}>{"" + value}</td>
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
                        <th>leaderBoard</th>
                        <th>Win/Lose</th>
                    </tr>
                </thead>
                <tbody>
                    {leaderBoard}
                </tbody>
            </table>
            <table>
                <thead>
                    <tr>
                        <th>Players</th>
                        <th>Ready</th>
                    </tr>
                </thead>
                <tbody>
                    {playersBoard}
                </tbody>
            </table>
            <table>
                <thead>
                    <tr>
                        <th>observers</th>
                    </tr>
                </thead>
                <tbody>
                    {observerBoard}
                </tbody>
            </table>
            <h1>Player: {props.userName}</h1>
            <button onClick={props.handleToggleObserver}>Toggle Observer({props.isPlayer})</button>
            <button onClick={props.handleReady}>Toggle Ready{props.isReady}</button>
            <button onClick={props.handleLeave}>Leave</button>
        </div>
    )

}

export default Lobby;