define [
  'buffer_queue',
  'consts',

  'underscore'
], (
  BufferQueue,
  consts
) ->

  BQ = undefined
  task = undefined
  send_task = undefined
  receive_task = undefined


  describe 'BufferQueue tests', ->

    beforeEach ->
      BQ = new BufferQueue()
      task =
        id: Math.random()

      send_task = {id: 1, type: consts.TASK_TYPE.SEND_TASK}
      receive_task = {id: 2, type: consts.TASK_TYPE.RECEIVE_TASK}


    it 'should be initialized with empty send_tasks & receive_tasks queues', ->
      expect(BQ.send_tasks).to.be.an('array').and.to.be.empty
      expect(BQ.receive_tasks).to.be.an('array').and.to.be.empty


    it "should be able to add to send_tasks queue", ->
      BQ._addSendTask(task)
      expect(BQ.send_tasks).to.not.be.empty
      expect(BQ.send_tasks).to.have.length(1)


    it "should be able to add to receive_tasks queue", ->
      BQ._addReceiveTask(task)
      expect(BQ.receive_tasks).to.not.be.empty
      expect(BQ.receive_tasks).to.have.length(1)


    it "should be able to add to particular queue, depending on task type", ->
      BQ._addSendTask = sinon.spy()
      BQ._addReceiveTask = sinon.spy()

      BQ.addTask(send_task)
      expect(BQ._addSendTask.called).to.be.true
      expect(BQ._addSendTask.calledWith(send_task)).to.be.true

      BQ.addTask(receive_task)
      expect(BQ._addReceiveTask.called).to.be.true
      expect(BQ._addReceiveTask.calledWith(receive_task)).to.be.true


    it 'should throw an Error if trying to add task of unknown type', ->
      task.type = 'adsasd'
      fn = ->
        BQ.addTask(task)
      expect(fn).to.throw(Error)


    it 'should fetch first send task from the send_tasks queue decreasing its length.
      Also should return null if queue is empty', ->
      _task = BQ.fetchSendTask(task)
      should.not.exist(_task)

      BQ.send_tasks.push(send_task)
      _task = BQ.fetchSendTask(send_task)
      should.exist(_task)
      expect(_task.id).to.be.equal(send_task.id)
      expect(BQ.send_tasks).to.be.empty


    it 'should fetch first receive task from the receive_tasks queue, decreasing its length.
      Also should return null if queue is empty', ->
      _task = BQ.fetchReceiveTask(task)
      should.not.exist(_task)

      BQ.receive_tasks.push(receive_task)
      _task = BQ.fetchReceiveTask(receive_task)
      should.exist(_task)
      expect(_task.id).to.be.equal(receive_task.id)

