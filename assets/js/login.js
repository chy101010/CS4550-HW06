import React, {useState, useEffect} from 'react';
import {ch_join, ch_join_lobby} from './socket';

function Login() {

    const [state, setState] = useState({
        userName: "",
        gameName: ""
    })

    const handleUserNameChange = (ev) => {
        setState((prev) => ({
            ...prev,
            userName: ev.target.value;
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

    return (
        <div>
            <h1>Login</h1>
            <h2>Enter Game Name</h2>
            <input id="login" onChange={handleGameNameChange} value={gameName} type="text"/>
            <h2>Enter User Name</h2>
            <input id="login" onChange={handleUserNameChange} value={userName} type="text"/>
            <button onClick={joinGame}>Join Game</button>
        </div>
    )
}

export default Login;