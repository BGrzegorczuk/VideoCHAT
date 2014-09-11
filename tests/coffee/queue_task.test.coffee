define [
  'queue_task',
  'consts'
], (
  QueueTask,
  consts
) ->

  file = undefined
  send_task = undefined
  receive_task = undefined

  chunks_no = 10


  describe 'QueueTask tests', ->

    beforeEach ->
      file =
        name: 'picture.jpg'
        size: consts.CHUNK_SIZE * chunks_no

      send_task = new QueueTask(consts.TASK_TYPE.SEND_TASK, file)
      receive_task = new QueueTask(consts.TASK_TYPE.RECEIVE_TASK, file, 'save_name')


    it 'should have _genUid method which return unique 36-char length string', ->
      expect(send_task._genGuid()).to.be.a('string').and.to.have.length(36)
      expect(receive_task._genGuid()).to.be.a('string').and.to.have.length(36)
      expect(send_task.id).to.not.be.equal(receive_task.id)


    it 'should be assigned some parameters on creation, specific for different task types', ->
      expect(send_task.type).to.be.equal(consts.TASK_TYPE.SEND_TASK)
      expect(send_task.file).to.be.an('object').and.to.be.equal(file)
      expect(send_task.status).to.be.equal(consts.TASK_STATUS.NEW)
      expect(send_task.metadata).to.have.keys(
        ['name', 'extension', 'size', 'chunks_no'])

      expect(receive_task.type).to.be.equal(consts.TASK_TYPE.RECEIVE_TASK)
      expect(receive_task.file).to.be.an('object').and.to.equal(file)
      expect(receive_task.status).to.be.equal(consts.TASK_STATUS.NEW)
      expect(receive_task.metadata).to.have.keys(['chunks_no'])
      expect(receive_task.file_chunks).to.be.an('array').and.to.be.empty
      expect(receive_task.save).to.be.a('function')


    it 'should properly calculate number of chunks depending on the file size', ->
      expect(send_task.metadata.chunks_no).to.be.equal(chunks_no)
      expect(receive_task.metadata.chunks_no).to.be.equal(chunks_no)

      file.size = consts.CHUNK_SIZE * chunks_no + 1
      task = new QueueTask(consts.TASK_TYPE.SEND_TASK, file)
      expect(task.metadata.chunks_no).to.be.equal(chunks_no + 1)

      file.size = consts.CHUNK_SIZE * chunks_no + 1
      task = new QueueTask(consts.TASK_TYPE.SEND_TASK, file)
      expect(task.metadata.chunks_no).to.be.equal(chunks_no + 1)


    it 'should be able to change its status', ->
      send_task.changeStatus(consts.TASK_STATUS.STARTED)
      expect(send_task.status).to.be.equal(consts.TASK_STATUS.STARTED)
      send_task.changeStatus(consts.TASK_STATUS.STOPPED)
      expect(send_task.status).to.be.equal(consts.TASK_STATUS.STOPPED)


    it 'should throw an Error when trying to change to invalid status', ->
      status = 'adsasd'
      fn = ->
        send_task.changeStatus(status)
      expect(fn).to.throw(Error)


    it 'should call onStatusChangeCallbk callback on each status change', ->
      send_task.onStatusChangeCallbk = sinon.spy()

      send_task.changeStatus(consts.TASK_STATUS.STARTED)
      expect(send_task.onStatusChangeCallbk.called).to.be.true

      send_task.changeStatus(consts.TASK_STATUS.STOPPED)
      send_task.changeStatus(consts.TASK_STATUS.COMPLETED)
      expect(send_task.onStatusChangeCallbk.callCount).to.be.equal(3)


    it 'should call onSuccessCallbk callback if status is changed to completed', ->
      send_task.onSuccessCallbk = sinon.spy()

      send_task.changeStatus(consts.TASK_STATUS.COMPLETED)
      expect(send_task.onSuccessCallbk.called).to.be.true



