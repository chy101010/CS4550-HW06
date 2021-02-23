import React, { useState, useEffect } from 'react';
import { ch_join_lobby, ch_join, state_update, ch_leave} from './socket';

import Lobby from './lobby';

function Main() {
    const [state, setState] = useState({
        results: [],
        preWinner: "",
        leaderBoard: [],
        players: [],
        observers: [],
        gameName: "",
        userName: "",
        isPlayer: false,
        isReady: false
    })

    useEffect(() => {
        state_update(state);
        ch_join(setState);
    })

    const handleUserNameChange = (ev) => {
        setState((prev) => ({
            ...prev,
            userName: ev.target.value
        }))
    }

    const handleGameNameChange = (ev) => {
        setState((prev) => ({
            ...prev,
            gameName: ev.target.value
        }))
    }

    function joinGame() {
        ch_join_lobby(state.gameName, state.userName);
    }

    function handleToggleObserver() {
        ch_toggle_observer(state.userName,)
    }

    function handleReady() {

    }

    function handleLeave() {
        ch_leave();
    }


    if (typeof (state.game) == "undefined") {
        return (
            <div>
            <h1>Login</h1>
            <h2>Enter Game Name</h2>
            <input id="login" onChange={handleGameNameChange} value={state.gameName} type="text" />
            <h2>Enter User Name</h2>
            <input id="login" onChange={handleUserNameChange} value={state.userName} type="text" />
            <button onClick={joinGame}>Join Game</button>
            </div>
            )
    }
    else {
        return (
            <Lobby
                userName={state.userName}
                gamename={state.gameName}
                observers={state.observers}
                players={state.players}
                isPlayer={state.isPlayer}
                leaderBoard={state.leaderBoard}
                isReady={state.isReady}
                preWinner={state.preWinner}
                handleReady={handleReady}
                handleToggleObserver={handleToggleObserver}
                handleLeave={handleLeave}
            />
        )
    }
}

export default Main;