WebSocketServer = require("ws").Server
http = require("http")
express = require("express")
app = express()
port = process.env.PORT or 5000
app.use express.static(__dirname + "/")
server = http.createServer(app)
server.listen port
console.log "http server listening on %d", port
wss = new WebSocketServer(server: server)
console.log "websocket server created"
positions = {}

wss.broadcast = (data) =>
  for i of wss.clients
    wss.clients[i].send data

wss.on "connection", (ws) =>
  ws.on "message", (message) =>
    p = JSON.parse message
    switch p.e
      when "add_me"
        name = p.d['name']
        id = p.d['id']
        ws.id = id
        ws.send JSON.stringify
          e: "current_state"
          d: positions
        positions[id] = 
          name: name
        wss.broadcast JSON.stringify
          e: "new_client"
          d:
            id: id
            name: name
        wss.broadcast JSON.stringify
          e: "message"
          d: "#{name} has just joined."
      
      when "update_my_position"
        id = p.d['id']
        position = p.d['position']
        positions[id].translate = position.translate
        positions[id].rotate = position.rotate
        positions[id].index = position.index
        wss.broadcast JSON.stringify
          e: "update_client_position"
          d:
            id: id
            position: position
        
  ws.on "close", =>
    name = positions[ws.id].name
    delete positions[ws.id]
    wss.broadcast JSON.stringify
      e: "client_left"
      d: ws.id
    wss.broadcast JSON.stringify
      e: "message"
      d: "#{name} has just left."