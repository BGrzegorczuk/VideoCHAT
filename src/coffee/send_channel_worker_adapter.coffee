define [
  'base_channel_worker_adapter',
  'consts'
], (
  BaseChannelWorkerAdapter,
  consts
) ->

  testing_env = window.mocha?


  class SendChannelWorkerAdapter extends BaseChannelWorkerAdapter

    constructor: ->
      if not testing_env
        @worker = new Worker(
          'http://localhost:3000/javascripts/webworkers/send_channel_worker.js')
      super()


    sendData: ->
      '''Sends data between users in chunks. Data is sent peer-to-peer
      over WebRTC protocol.'''


    onDataChunkSent: ->
      '''Performs actions after each data chunk is successfully sent.'''


    onDataComplete: ->
      '''Performs actions after data transfer is successfully finished.'''

