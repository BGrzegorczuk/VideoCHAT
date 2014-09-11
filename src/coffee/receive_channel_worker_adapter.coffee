define [
  'base_channel_worker_adapter',
  'consts'
], (
  BaseChannelWorkerAdapter,
  consts
) ->

  testing_env = window.mocha?


  class ReceiveChannelWorkerAdapter extends BaseChannelWorkerAdapter

    constructor: ->
      if not testing_env
        @worker = new Worker(
          'http://localhost:3000/javascripts/webworkers/receive_channel_worker.js')
      super()


    ## NOTE: is it needed?
    receiveData: ->


    onDataChunkReceived: ->


    onDataComplete: ->


