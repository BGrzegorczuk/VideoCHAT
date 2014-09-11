###
Module dependencies.
###
port = 3000
SECRET = "1234567890QWERTY"

async = require("async")
express = require('express')
routes = require("./routes")
http = require("http")
path = require("path")
app = express()

## INITIALIZING REDIS CLIENT
# redisCli = require("redis").createClient(
#     host: "192.168.1.21"
#     port: 6379
#     db: 21
#     pass: ""
# )

## INITIALIZING SESSION
# session = require('express-session')
# RedisStore = require("connect-redis")(session)
# app.use express.cookieParser()
# app.use express.session(
#   key: 'app.sess'
#   store: new RedisStore(
#     host: "localhost"
#     port: 6379
#     db: 20
#     pass: ""
#   )
#   secret: SECRET
# )


# all environments
app.set "port", process.env.PORT or 3000
app.set "views", path.join(__dirname, "templates")
app.set "view engine", "jade"

app.use express.favicon()
app.use express.logger("dev")
app.use express.json()
app.use express.urlencoded()
app.use express.methodOverride()
app.use app.router
app.use express.static(path.join(__dirname, "public"))

# development only
app.use express.errorHandler()  if "development" is app.get("env")



io = require("socket.io").listen(app.listen(port))
console.log "Express server listening on port " + app.get("port")


## ROUTES
app.get '/', routes.index
app.get '/:room([A-Za-z0-9]{6})', routes.room
app.get '/leavingPage', routes.leavingPage


## MAIN CODE

io.sockets.on 'connection', (socket) ->

  log = ->
    array = [">>> Message from server: "]
    i = 0

    while i < arguments.length
      array.push arguments[i]
      i++
    socket.emit "log", array



  socket.on 'message', (message) ->
    socket.get 'room', (err, room) ->
      log("Got message from room #{room}: ", message)
      # socket.broadcast.emit('message', data.message)
      io.sockets.to(room).emit('message', message);


  socket.on 'create or join', (room) ->
    numClients = io.sockets.clients(room).length

    log('Room ' + room + ' has ' + numClients + ' client(s)')
    log('Request to create or join room', room)

    if numClients == 0
      socket.join(room)
      socket.set 'room', room
      socket.emit('created', room)
    else if numClients == 1
      io.sockets.in(room).emit('join', room)
      socket.join(room)
      socket.set 'room', room
      socket.emit('joined', room)
    else # max two clients
      socket.emit('full', room)

    socket.emit('emit(): client ' + socket.id + ' joined room ' + room)
    socket.broadcast.emit('broadcast(): client ' + socket.id + ' joined room ' + room)


  socket.on 'disconnect', (data) ->
    console.log 'DISCONNECT'
    ## TODO: 'destroy' room if no users left (check socketio manual)
