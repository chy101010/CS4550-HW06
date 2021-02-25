import React, { useState, useEffect } from 'react';
import { ch_join_lobby, ch_join, state_update, ch_leave, ch_toggle_observer, ch_toggle_ready, ch_guess, ch_pass} from './socket';

import Lobby from './lobby';
import Game from './game';

function Main() {
    const [state, setState] = useState({
        results: [],
        preWinner: [],
        leaderBoard: [],
        players: [],
        observers: [],
        gameName: "",
        userName: "",
        message: "",
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
        ch_toggle_observer();
    }

    function handleReady() {
        ch_toggle_ready();
    }

    function handleLeave() {
        ch_leave();
    }

    function handleGuess(guess) {
        ch_guess(guess);
    }

    function handlePass() {
        ch_pass();
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
    else if (!state.game){
        return (
            <Lobby
                userName={state.userName}
                gamename={state.gameName}
                observers={state.observers}
                players={state.players}
                leaderBoard={state.leaderBoard}
                preWinner={state.preWinner}
                handleReady={handleReady}
                handleToggleObserver={handleToggleObserver}
                handleLeave={handleLeave}
            />
        )
    }
    else {
        return (
            <Game
                results = {state.results} 
                message = {state.message}
                handleLeave={handleLeave}
                handleGuess={handleGuess}
                handlePass={handlePass}
            />
        )
    }
}

export default Main;