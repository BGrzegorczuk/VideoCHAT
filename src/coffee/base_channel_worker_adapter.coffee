define [
  'consts'
], (
  consts
) ->

  testing_env = window.mocha?


  class BaseChannelWorkerAdapter

    constructor: ->
      @task = null
      @STATUS = consts.WORKER_STATUS.WAITING

      if not testing_env
        @worker.addEventListener 'message', (e) ->
          @_handleMessageFromWorker(e)


    _handleMessageFromWorker: (msg) ->
      '''Processes command coming from the worker by performing
      proper action.
      @param {plain obj} msg - message from the worker
      '''
      switch msg.cmd
        when 'log' then @_onLogMsg(msg.msg)
        when 'progress' then @_onProgress(msg.data)
        when 'status' then @_onChangeStatus(msg.status)
        when 'complete' then @_onComplete(msg.data)


    sendMessageToWorker: (cmd, data={}) ->
      '''Sends command to the worker to perform some actions.
      @param {plain obj} cmd - command for the worker
      @param {plain obj} data - optional data for the worker
      '''
      @worker.postMessage
        cmd: cmd
        data: data


    startProcessing: ->
      '''Sends message to the worker to start processing the task and to
      change its state to consts.WORKER_STATUS.BUSY'''
      @sendMessageToWorker 'start_processing'


    stopProcessing: ->
      '''Sends message to the worker to stop processing the task and to
      change its state to consts.WORKER_STATUS.WAITING'''
      @sendMessageToWorker 'stop_processing'


    _onLogMsg: (msg) ->
      '''Loggs message from the worker.'''
      console.info 'MSG FROM THE WORKER >>> ', msg


    _onProgress: (data) ->
      '''Performs actions on each chunk processed by the worker to
      indicate processing progress.'''


    _onComplete: (data) ->
      '''Performs actions after worker successfully finished processing
      the task.'''


    _onChangeStatus: (status) ->
      '''Notifies about changes in worker status.'''
      unless status in (code for _status, code of consts.WORKER_STATUS)
        throw new Error 'Invalid status.'

      @STATUS = status


    assignTask: (task) ->
      '''Assigns task for worker to be processed.
      @param {QueueTask} task - task to assined for the worker'''
      unless task.type in (code for type, code of consts.TASK_TYPE)
        throw new Error 'Invalid task type.'

      if @hasTaskAssigned()
        throw new Error 'Worker already has a task assigned.'

      @task = task
      @STATUS = consts.WORKER_STATUS.BUSY
      @startProcessing()


    unassignTask: ->
      '''Rejects task for worker if any.'''
      if @hasTaskAssigned()
        @task = null
        @STATUS = consts.WORKER_STATUS.WAITING
        @stopProcessing()


    hasTaskAssigned: ->
      return @task isnt null


    isBusy: ->
      '''Checks if worker is busy that means it is currently processing a task.'''
      return @STATUS == consts.WORKER_STATUS.BUSY


    isWaiting: ->
      '''Checks if worker is free and waiting to process a task.'''
      return @STATUS == consts.WORKER_STATUS.WAITING
