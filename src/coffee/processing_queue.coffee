define [
  'send_channel_worker_adapter',
  'receive_channel_worker_adapter',
  'consts',

  'underscore'
], (
  SCWorkerAdapter,
  RCWorkerAdapter,
  consts
) ->

  ###
  NOTE: Little hacks are used in this module as we cannot run
  webworkers code from within the testing environment. Though,
  we are using global testing_env variable.
  ###
  testing_env = window.mocha?


  class ProcessingQueue
    '''Queue responsible for processing tasks, both send and receive
    tasks, from BufferQueue.
    '''
    constructor: (@BufferQueue, opts={}) ->
      '''
      @param {BufferQueue} BufferQueue - queue with tasks waiting to be processed.
      @param {plain obj} opts - initialize options:
        {Integer} [2000ms] opts.interval - interval of checking for free workers
          and new tasks from BufferQueue. Optional, 2000ms by default.
        {Integer} [2] opts.workers_no - initially spawned number of
          send and receive workers. Optional, 2s by default.
      '''
      @STARTED = false
      @send_workers = []
      @receive_workers = []

      ## initialize options
      @interval = if opts.interval? then opts.interval else 2000
      @workers_no = if opts.workers_no? then opts.workers_no else 2

      ## add workers
      ## NOTE: see NOTE in the beginning of this file
      if not testing_env
        for x in [1..@workers_no]
          @addSendWorker(new SCWorkerAdapter())
        for x in [1..@workers_no]
          @addReceiveWorker(new RCWorkerAdapter())


    start: ->
      '''Starts ProcessingQueue.'''
      if @STARTED == false
        @STARTED = true
        @loop()
      else
        throw new Error('Queue has already been started')


    stop: ->
      '''Stops ProcessingQueue.'''
      if @STARTED == true
        @STARTED = false
        clearInterval(@loopTicker)
      else
        throw new Error('Queue has not been started yet')


    loop: ->
      '''Starts ProcessingQueue main processing loop which checks for
      free workers and distributes tasks to be processed by those workers.
      '''
      @loopTicker = setInterval =>
        console.log 'tick'

        waiting_send_worker = @getWaitingSendWorker()
        if waiting_send_worker isnt null
          send_task = @checkForSendTask()
          if send_task isnt null
            console.log 'send_task'
            console.log send_task
            @startProcessingSendTask(send_task, waiting_send_worker)

        waiting_receive_worker = @getWaitingReceiveWorker()
        if waiting_receive_worker isnt null
          receive_task = @checkForReceiveTask()
          if receive_task isnt null
            @startProcessingReceiveTask(receive_task, waiting_receive_worker)

      , @interval


    checkForSendTask: ->
      '''Checks if there are send tasks waiting for processing
      if BufferQueue. Returns the task, or null if no task is available.
      '''
      send_task = @BufferQueue.fetchSendTask()
      return send_task


    checkForReceiveTask: ->
      '''Checks if there are receive tasks waiting for processing
      if BufferQueue. Returns the task, or null if no task is available.
      '''
      receive_task = @BufferQueue.fetchReceiveTask()
      return receive_task


    addSendWorker: (send_worker) ->
      '''Adds new send channel worker to process more send tasks at a time.
      Maximum MAX_SEND_WORKERS can be added.
      @param {SendChannelWorkerAdapter} send_worker
      '''
      ## NOTE: see NOTE in the beginning of this file
      if not testing_env and send_worker not instanceof SCWorkerAdapter
        throw new Error 'Worker has to be of an instance of SendChannelWorkerAdapter'

      if @send_workers.length >= consts.MAX_SEND_WORKERS
        throw new Error "Maximum number of send workers is #{consts.MAX_SEND_WORKERS}"

      @send_workers.push(send_worker)


    addReceiveWorker: (receive_worker) ->
      '''Adds new receive channel worker to process more receive tasks at a time.
      Maximum MAX_RECEIVE_WORKERS can be added.
      '''
      ## NOTE: see NOTE in the beginning of this file
      if not testing_env and receive_worker not instanceof RCWorkerAdapter
        throw new Error 'Worker has to be of an instance of ReceiveChannelWorkerAdapter'

      if @receive_workers.length >= consts.MAX_RECEIVE_WORKERS
        throw new Error "Maximum number of send workers is #{consts.MAX_RECEIVE_WORKERS}"

      @receive_workers.push(receive_worker)


    startProcessingSendTask: (task, worker) ->
      '''
      @param {QueueTask} task - task to be processed
      @param {SendChannelWorkerAdapter} worker - processing worker
      '''
      worker.assignTask(task)


    startProcessingReceiveTask: (task, worker) ->
      '''
      @param {QueueTask} task - task to be processed
      @param {ReceiveChannelWorkerAdapter} worker - processing worker
      '''
      worker.assignTask(task)


    getWaitingSendWorker: ->
      '''Returns free send worker which is ready for processing
      next send task, if any. If all workers are busy, returns null.
      '''
      send_worker = null
      try
        _.each @send_workers, (worker) ->
          if worker.isWaiting()
              send_worker = worker
              throw new Error('break') # EcmaScript does not support breaking each loop
      catch e
        if e.message != 'break'
          throw e

      return send_worker


    getWaitingReceiveWorker: ->
      '''Returns free receive worker which is ready for processing
      next receive task, if any. If all workers are busy, returns null.
      '''
      receive_worker = null
      try
        _.each @receive_workers, (worker) ->
          if worker.isWaiting()
              receive_worker = worker
              throw new Error('break') # EcmaScript does not support breaking each loop
      catch e
        if e.message != 'break'
          throw e

      return receive_worker


    ## TODO: DOCS
    getWorkerAssociatedWithTask: (task) ->
      if task.type is consts.TASK_TYPE.SEND_TASK
        worker = @_getSendWorkerAssociatedWithTask(task)
      else if task.type is consts.TASK_TYPE.RECEIVE_TASK
        worker = @_getReceiveWorkerAssociatedWithTask(task)
      else
        throw new Error 'Unknown task type.'

      return worker


    ## TODO: DOCS
    _getSendWorkerAssociatedWithTask: (task) ->
      send_worker = null

      try
        _.each @send_workers, (worker) ->
          if worker.hasTaskAssigned() and worker.task.id == task.id
            send_worker = worker
            throw new Error('break') # EcmaScript does not support breaking each loop
      catch e
        if e.message != 'break'
          throw e

      return send_worker


    ## TODO: DOCS
    _getReceiveWorkerAssociatedWithTask: (task) ->
      receive_worker = null

      try
        _.each @receive_workers, (worker) ->
          if worker.hasTaskAssigned() and worker.task.id == task.id
            receive_worker = worker
            throw new Error('break') # EcmaScript does not support breaking each loop
      catch e
        if e.message != 'break'
          throw e

      return receive_worker

