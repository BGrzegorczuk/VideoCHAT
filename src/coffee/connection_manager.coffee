define ['socket.io', 'adapter'], (sio) ->

  class ConnectionManager

    constructor: (@server_url, @room, @$localVideo, @$remoteVideo) ->
      @isInitiator = false
      @isStarted = false
      @isChannelReady = false
      @turnReady = false

      ## INIT STUFF
      if webrtcDetectedBrowser is "firefox"
          @pc_config =
              iceServers: [url: "stun:23.21.150.121"] # number IP
      else
          @pc_config =
              iceServers: [url: "stun:stun.l.google.com:19302"]

      @pc_constraints =
          optional: [
              {DtlsSrtpKeyAgreement: true},
              {RtpDataChannels: true}
          ]

      ## Set up audio and video regardless of what devices are present.
      @sdpConstraints =
          mandatory:
              OfferToReceiveAudio:true
              OfferToReceiveVideo:true


    init: ->
      @connect()

      constraints =
          video: true
          audio: true

      getUserMedia constraints, @handleUserMedia, @handleUserMediaError
      console.log "Getting user media with constraints", constraints


    connect: ->
      @socket = sio.connect(@server_url)

      @socket.on 'connect', =>

        @socket.emit "create or join", @room

        @socket.on 'log', (array) ->
            console.log.apply(console, array)

        @socket.on 'message', (message) =>
            # console.log '====== on message ====='
            # console.log "Client received message:", message
            if message is "got user media"
                @maybeStart()
            else if message.type is "offer"
                console.log '**** OFFER MESSAGE'
                @maybeStart()  if not @isInitiator and not @isStarted
                @pc.setRemoteDescription new RTCSessionDescription(message)
                @doAnswer(@sdpConstraints)
            else if message.type is "answer" and @isStarted
                console.log '**** ANSWER MESSAGE'
                @pc.setRemoteDescription new RTCSessionDescription(message)
                @$remoteVideo.css 'opacity', 1
            else if message.type is "candidate" and @isStarted
                # console.log '**** CANDIDATE MESSAGE'
                candidate = new RTCIceCandidate(
                    sdpMLineIndex: message.label
                    candidate: message.candidate
                )
                @pc.addIceCandidate(candidate)
            else handleRemoteHangup()  if message is "bye" and @isStarted

        @socket.on 'created', =>
            console.log('Created room ' + @room)
            @isInitiator = true

        @socket.on 'join', (room) =>
            console.log('Another peer made a request to join room ' + @room)
            console.log('This peer is the initiator of room ' + @room + '!')
            @isChannelReady = true

        @socket.on 'joined', =>
            console.log('This peer has joined room ' + @room)
            @isChannelReady = true

        @socket.on "leave", ->
            window.location = '/leavingPage'

        ## room can contain of max 2 users
        @socket.on 'full', (room) =>
            alert('Room ' + @room + ' is full.')
            window.location = '/leavingPage'

        @socket.on 'disconnect', (data) =>
            console.log 'DISCONNETED'


    sendMessage: (message) =>
      console.log('Client sending message: ', message)
      @socket.emit('message', message)


    handleUserMedia: (stream) =>
      console.log 'Adding local stream.'
      @$localVideo[0].src = window.URL.createObjectURL(stream)
      @$localVideo.css 'visibility', 'visible'
      @$remoteVideo.css 'visibility', 'visible'
      @localStream = stream
      @sendMessage "got user media"
      @maybeStart()  if @isInitiator


    handleUserMediaError: (error) =>
      console.log "getUserMedia error: ", error


    maybeStart: =>
      console.log 'MAYBE START'
      if (
        not @isStarted and
        @localStream? and
        @isChannelReady
      )
        @createPeerConnection()
        @pc.addStream(@localStream)
        @isStarted = true
        console.log "isInitiator", @isInitiator
        @doCall()  if @isInitiator


    doCall: =>
      console.log 'Sending offer to peer'
      @pc.createOffer(@setLocalAndSendMessage, @handleCreateOfferError)


    doAnswer: (sdpConstraints) =>
      console.log 'Sending answer to peer.'
      @pc.createAnswer(@setLocalAndSendMessage, null, sdpConstraints)


    handleCreateOfferError: (err) =>
      console.log "createOffer() error: ", err


    setLocalAndSendMessage: (sessionDescription) =>
      console.log 'setLocalAndSendMessage'
      # Set Opus as the preferred codec in SDP if Opus is present.
      # sessionDescription.sdp = preferOpus(sessionDescription.sdp)
      @pc.setLocalDescription(sessionDescription)
      console.log "setLocalAndSendMessage sending message", sessionDescription
      @sendMessage(sessionDescription)


    createPeerConnection: =>
      try
        @pc = new RTCPeerConnection(@pc_config, @pc_constraints)
        @pc.onicecandidate = @onIceCandidate
        @pc.onaddstream = @onRemoteStreamAdded
        @pc.onremovestream = @onRemoteStreamRemoved
        console.log(
          "Created RTCPeerConnnection with:\n" + "  config: '" +
          JSON.stringify(@pc_config) + "';\n" + "  constraints: '" +
          JSON.stringify(@pc_constraints) + "'."
        )
      catch e
        console.log "Failed to create PeerConnection, exception: " + e.message
        alert "Cannot create RTCPeerConnection object."
        return null

      ###
      ## Try to create Data Channel
      if @isInitiator
        try
          # Reliable Data Channels not yet supported in Chrome
          @sendChannel = @pc.createDataChannel("sendDataChannel",
              reliable: false
          )
          @sendChannel.onmessage = @onMessage
          @sendChannel.onopen = @onSendChannelStateChange
          @sendChannel.onclose = @onSendChannelStateChange
          trace "Created send data channel"
        catch e
          alert "Failed to create data channel. " + "You need Chrome M25 or later with RtpDataChannel enabled"
          trace "createDataChannel() failed with exception: " + e.message

      else
        @pc.ondatachannel = @gotReceiveChannel
      ###



    # Data Channel stuff

    ###
    gotReceiveChannel: (event) =>
      ## NOTE: missleading names sendChannel & receiveChannel !!!
      trace "Receive Channel Callback"
      @sendChannel = event.channel
      @sendChannel.onmessage = @onMessage
      @sendChannel.onopen = @onReceiveChannelStateChange
      @sendChannel.onclose = @onReceiveChannelStateChange


    onMessage: (event) =>
      trace "Received message: " + event.data
      # receiveTextarea.value = event.data


    onSendChannelStateChange: =>
      ## NOTE: missleading names sendChannel & receiveChannel !!!
      readyState = @sendChannel.readyState
      trace "Send channel state is: " + readyState
      # enableMessageInterface readyState is "open"


    onReceiveChannelStateChange: =>
      ## NOTE: missleading names sendChannel & receiveChannel !!!
      readyState = @sendChannel.readyState
      trace "Receive channel state is: " + readyState
      # enableMessageInterface readyState is "open"
    ###


    onIceCandidate: (event) =>
      console.log 'onIceCandidate event: ', event
      if event.candidate?
        @sendMessage
          type: 'candidate'
          label: event.candidate.sdpMLineIndex
          id: event.candidate.sdpMid
          candidate: event.candidate.candidate
      else
        console.log('End of candidates.')


    onRemoteStreamAdded: (event) =>
      console.log 'Remote stream added.'
      @$remoteVideo[0].src = window.URL.createObjectURL(event.stream)
      @remoteStream = event.stream


    onRemoteStreamRemoved: (event) =>
      console.log 'Remote stream removed. Event: ', event


    requestTurn: (turn_url) =>
      turnExists = false
      for i of @pc_config.iceServers
        if @pc_config.iceServers[i].url.substr(0, 5) is "turn:"
          turnExists = true
          @turnReady = true
          break
      unless turnExists
        console.log "Getting TURN server from ", turn_url

        # No TURN server. Get one from computeengineondemand.appspot.com:
        xhr = new XMLHttpRequest()
        xhr.onreadystatechange = =>
          if xhr.readyState is 4 and xhr.status is 200
            turnServer = JSON.parse(xhr.responseText)
            console.log "Got TURN server: ", turnServer
            @pc_config.iceServers.push
              url: "turn:" + turnServer.username + "@" + turnServer.turn
              credential: turnServer.password
            @turnReady = true

        xhr.open "GET", turn_url, true
        xhr.send()


    disconnect: =>
      @socket.disconnect()

