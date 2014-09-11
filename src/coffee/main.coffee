define [
  'connection_manager',
  'buffer_queue',
  'processing_queue',
  'queue_task',
  'consts',

  'underscore'
]
, (
  ConnectionManager,
  BufferQueue,
  ProcessingQueue,
  QueueTask,
  consts
) ->

  initializeApplication = ->

    $ ->
      url = window.location.hostname
      room = $('#shareUrl').attr('data-room')
      $localVideo = $('#localVideo')
      $remoteVideo = $('#remoteVideo')

      ## preventing default browser drop behavior
      $(document).on 'drop dragover dragleave dragenter', (e) ->
        e.preventDefault()

      ## bind drag upload
      $(document).fileupload
        singleFileUploads: false
        autoupload: false
        dataType: 'json'
        # fileInput: $('#upload-input')
        dropZone: $remoteVideo
        add: (e, data) ->
          e.stopPropagation()

          # workaround for pasting bug
          if e.originalEvent.delegatedEvent.type == "paste"
            return false

          # if dropping jquery ui droppable, then do not fire upload event
          return if not data.files.length

          _.each data.files, (file) ->
            send_task = new QueueTask(
              consts.TASK_TYPE.SEND_TASK,
              file
            )
            BufferQ.addTask(send_task)


      ## initialize connection manager
      CM = new ConnectionManager(
        url,
        room,
        $localVideo,
        $remoteVideo
      )
      CM.init()

      BufferQ = new BufferQueue()

      ## TODO: initialize processing queue and data channel workers
      ProcessingQ = new ProcessingQueue(BufferQ)
      ProcessingQ.start()


  return initializeApplication
