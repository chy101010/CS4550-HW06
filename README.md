# Bulls And Cows 

Design Choice 
1. Once a game has started, any observers join will immediately join the game, but they won't be able to do any execution
2. Players can leave before a game ends to dodge losing count
3. Multiple users can join a game with the same username. Internally, they will be treated as one player
4. A turn is checked out after 30 seconds or all players have executed: "guess" | "pass" | leave
5. When all players left during a game, the game will return to the lobby without couting win and lose
6. The frontend chose not to display the player passing results

Attribution: some of the codes(deployment scripts and etc..) in this assignment are derived from Nat Tuck's lectures
