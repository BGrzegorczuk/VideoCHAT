define [
  'filesaver',
  'consts'

  'underscore'
], (
  saveAs,
  consts
) ->

  class QueueTask
    '''Class keeps information about task to be processed by
    SendChannelWorkers or ReceiveChannelWorkers.
    '''
    ## PRIVATE VARIABLES


    # CALLBACKS
    onProgressChangeCallbk: undefined
    onStatusChangeCallbk: undefined
    onSuccessCallbk: undefined
    onFailureCallbk: undefined


    constructor: (type, file, save_name) ->
      '''
      @param {TASK_TYPE} type - task type from consts.TASK_TYPE
      @param {File} file - JS file object connected with task
      '''
      @id = @_genGuid()
      @type = type
      @file = file
      @status = consts.TASK_STATUS.NEW
      @metadata = {}

      if type is consts.TASK_TYPE.SEND_TASK
        splitted_name = @file.name.split('.')
        extension = (
          if splitted_name.length>1 then splitted_name[splitted_name.length-1] else ''
        )

        @metadata =
          name: file.name
          extension: extension
          size: file.size

      else if type is consts.TASK_TYPE.RECEIVE_TASK
        @file_chunks = [] ## needed for downloading and saving the file on the client side
        @save = =>
          blob = new Blob(
            @file_chunks, {type: "application/octet-stream"})
          saveAs(blob, save_name)
          @metadata.file_chunks = []

      ## metadata common for both types of task
      chunks_no = @_calculateChunksNo()
      _.extend @metadata, {chunks_no: chunks_no}


    _genGuid: ->
      '''Generates unique task id.'''
      "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace /[xy]/g, (c) ->
        r = Math.random() * 16 | 0
        v = (if c is "x" then r else (r & 0x3 | 0x8))
        return v.toString 16


    _calculateChunksNo: ->
      '''.'''
      chunks_no = Math.ceil(@file.size / consts.CHUNK_SIZE)
      return chunks_no


    changeStatus: (status) =>
      unless status in (code for _status, code of consts.TASK_STATUS)
        throw new Error 'Invalid task status.'

      @status = status
      @onStatusChangeCallbk(@) if @onStatusChangeCallbk?

      if @status is consts.TASK_STATUS.COMPLETED
        @onSuccessCallbk(@) if @onSuccessCallbk?

