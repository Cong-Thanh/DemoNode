app = require("http").createServer()

io = require("socket.io")(app)

app.listen 8080

console.log "Server is listening at port 8080"

positions = {}

io.configure ->
  io.set 'transports', ['websocket', 'flashsocket', 'htmlfile', 'xhr-polling', 'jsonp-polling']

io.sockets.on "connection", (socket) ->
  
  socket.on "add_me", (name) ->
        
    socket.name = name

    socket.emit "current_state", positions
    
    positions[socket.id] = 
      name: name

    socket.broadcast.emit "new_client", socket.id, name

    io.sockets.emit "message", "#{name} has just joined."

  socket.on "update_my_position", (position) ->

    positions[socket.id].translate = position.translate
    positions[socket.id].rotate = position.rotate
    positions[socket.id].index = position.index

    socket.broadcast.emit "update_client_position", socket.id, position

  socket.on "disconnect", ->
    
    delete positions[socket.id]

    io.sockets.emit "client_left", socket.id

    io.sockets.emit "message", "#{socket.name} has just left."