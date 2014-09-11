#
# * ROUTES for VideoCHAT application.
#

generateRoomName = (length) ->
  haystack = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  room_name = ""

  i = 0
  while i < length
    room_name += haystack.charAt(Math.floor(Math.random() * 62))
    i++

  return room_name


exports.index = (req, res) ->
  room = generateRoomName(6)
  res.render 'index.jade',
    shareURL: req.protocol + "://" + req.get("host") + "/" + room
    room: room


exports.room = (req, res) ->
  room = req.params.room
  res.render 'index.jade',
    shareURL: req.protocol + "://" + req.get("host") + "/" + room
    room: room


exports.leavingPage = (req, res) ->
  res.render 'leavingPage.jade'