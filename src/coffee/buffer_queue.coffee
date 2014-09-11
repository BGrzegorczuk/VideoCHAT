define ['consts', 'js_extensions'], (consts) ->

  class BufferQueue
    '''Queue responsible for buffering new send and receive tasks
    until ProcessingQueue processes them.
    '''

    constructor: ->
      @send_tasks = []
      @receive_tasks = []


    addTask: (task) ->
      '''Add task to the queue. task.type indicated which queue
      should be populated.
      @param {QueueTask} task - task to be added.
      '''
      if task.type is consts.TASK_TYPE.SEND_TASK
        @_addSendTask(task)
      else if task.type is consts.TASK_TYPE.RECEIVE_TASK
        @_addReceiveTask(task)
      else
        throw new Error 'Unknown task type.'


    _addSendTask: (task) ->
      '''Adds new task to send_tasks queue.
      @param {QueueTask} task - task to be added.
      '''
      @send_tasks.push task


    _addReceiveTask: (task) ->
      '''Adds new task to receive_tasks queue.
      @param {QueueTask} task - task to be added.
      '''
      @receive_tasks.push task


    fetchSendTask: ->
      '''Returns first task from the send_tasks queue or null if
      queue is empty. Also the task is removed from the queue.
      '''
      send_task = null
      if @send_tasks.length
        send_task = @send_tasks.shift()
      return send_task


    fetchReceiveTask: ->
      '''Returns first task from the receive_tasks queue or null if
      queue is empty. Also the task is removed from the queue.
      '''
      receive_task = null
      if @receive_tasks.length
        receive_task = @receive_tasks.shift()
      return receive_task
