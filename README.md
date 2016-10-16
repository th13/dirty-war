The Dirty War
----

The server code is written in LiveScript, a functional language that compiles down to JavaScript.
Client code can be written in any language that compiles to JavaScript.

### Server IO API
The following are events that the server will emit to you:

`connected` ->

`id: Int`

Informs your client that it has successfully connected to the server. `id` will be your client's ID, which doubles as your team number. It will have a value of 1, 2, or 3.

`game-ready` ->

`message: String`

Informs your client that the game is ready to begin. The server will emit this will all 3 teams have connected. `message` is a message stating that the game is ready to begin and prompting your client for its 100 random numbers.
**NOTE:** Additionally, `game-ready` will be emitted in the event of a tie between teams. The server will reset each team's points and clear the list of numbers. If you want to be able to submit a new list in this case, ensure in your code that when you listen for the `game-ready` event that you have something set up to submit the correct list.

`list-shuffled` ->

`numbers: [Int]`

Informs your client that the server has received all lists from the 3 teams and has randomly assigned each list to a team (i.e., shuffled the list of numbers). `numbers` is a list of each list of random numbers, with its index in the array corresponding to your `team number - 1` (0 is team 1, etc).

`running-round` ->

`numbers: [Int]`

`winner: Int`

Informs your client that a round is being run. `numbers` corresponds to a list of each team's number being played in the current round. `winner` is the team number that wins (1, 2, or 3). `winner` returns `false` if there is a tie.

`game-won` ->

`winner: Int`

Informs your client that the game has completed and a winner was decided. `winner` contains the team number of the winning team (1, 2, or 3).

### Client IO API
The following are events that you MUST emit to the server for the game to behave.

`rand-numbers` ->

`team: Int`

`numbers: [Int]`

Informs the server of your chosen random numbers. `numbers` should be a list of your 100 numbers. This should be called after you receive a `game-ready` event.

### Event Chronology
1. Server is started up. 
2. Each client connects. 
3. Server emits a `connected` event to each client.
4. When all 3 clients are connected, server emits `game-ready`.
5. Server waits until all 3 clients emit `rand-numbers` with their 100 random numbers in an object with key `numbers`.
6. Server then randomly assigns the numbers to each team.
7. Server emits `list-shuffled` to the teams with the newly shuffled lists.
8. Server shuffles EACH of the team's lists (so the elements are now in random order for selection during the game).
9. Server creates a list of lists representing each round to play. Each element in this list will be `[team 1's nth num, team 2's nth num, team 3's nth num]`.
10. Server runs 100 rounds by comparing the numbers. The team with the highest number in each round gets a point. No points are given if there is a tie for the highest number. On each round, the server will emit a `running-round` event with `numbers` being the numbers that are being compared in this round and `winner` being the team that wins (1, 2, or 3).
11. Server decides the winner (or a tie). If there is a winner, the server emits a `game-won` event with an object specifying the `winner` (the team number that wins [1, 2, or 3]). If there is a tie, then the server will clear its data and restart the game by sending another `game-ready` event.

