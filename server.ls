require! {
  hapi: Hapi
  'socket.io': IO
  inert: Inert
  './socket': Socket
}

# Creates a new Hapi server and executes the callback with the server object.
create-server = (then_) ->
  (server = new Hapi.Server!).connection { port: 3000 }
  then_ server

# Run the server
server <- create-server!
Socket.start <| IO server.listener    # server.listener contains the http server object
err <- server.start
if err then throw err
console.log "Server running on #{server.info.uri}"
