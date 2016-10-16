require! {
  ramda: R
  './shuffle'
}

# Necessary global state representing number of active connections.
@num-connected = 0
# A list of each of the teams' lists
@lists = Array(3)
# Each teams' points
@points = [0 0 0]


# Message indicating someone has connected/disconnected from the server.
status-message = (n, disconnected = false) ->
  "User #{if disconnected then 'dis' else ''}connected.\n  Number of connections: #{n}"

# Callback to run once we have a connection to the socket.
# Returns the new number of connected users
on-connected = (socket, n) ->
  n++
  socket.emit \connected id: n
  console.log <| status-message n
  n

# Callback to run when a client disconnects.
# Returns the new number of connected users
on-disconnected = (n) ->
  n--
  console.log <| status-message n, true
  n

# We return index+1 (aka team number) instead of the raw index because in
# comparisons later on, 0 will give us bad results with if statements.
compare = (nums) ->
  max = R.max nums.0, nums.1

  if max < nums.2
    return 3
  else if nums.0 is nums.1
    return false
  else if nums.0 < nums.1
    return 2
  else
    return 1

run-round = (io, nums) ~~>
  winner = compare nums   # Team number
  if winner then @points[winner - 1]++
  io.emit \running-round, numbers: nums, winner: winner

# Main function that sets up the listeners on a socket.
export start = (io) ~>
  socket <~ io.on \connection
  @num-connected = on-connected socket, @num-connected

  # Game can begin when all teams have connected.
  if @num-connected is 3
    console.log '\nGame is starting. Waiting on all teams to submit their numbers.'
    io.emit \game-ready, do
      message: 'Game is ready to begin.\nPlease submit your list: '

  do
    { team, numbers } <~ socket.on \rand-numbers
    console.log "Received numbers from team #{team}: #{numbers}"
    @lists[team - 1] = numbers
    if @lists[0]? and @lists[1]? and @lists[2]?
      # Reassign the lists randomly
      @lists = shuffle @lists
      console.log @lists
      io.emit \list-shuffled numbers: @lists

      # Play the war game
      # Shuffle each list & zip them for easy comparison
      @lists = R.map((list) -> shuffle list) <| @lists
      zipped = R.zip @lists[0], @lists[1]
      zipped = R.zipWith ((a, b) -> (R.append b, a)), zipped, @lists[2]
      console.log zipped
      R.forEach run-round(io), zipped
      R.addIndex(R.forEach)(
        (val, idx) -> console.log "Team #{idx + 1}: #{val} pts.",
        @points
      )
      winner = compare @points
      if winner
        console.log "WE HAVE A WINNER! CONGRATULATIONS TO:\n  Team #{winner}!"
        io.emit \game-won winner: winner
        setTimeout process.exit, 6000
      else
        @lists = null
        @lists = Array(3)
        @points = [0 0 0]
        io.emit \game-ready, do
          message: 'No winner! New round beginning!'

  <~ socket.on \disconnect
  @num-connected = on-disconnected @num-connected
