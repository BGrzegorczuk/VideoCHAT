define [
  'base_channel_worker_adapter',
  'consts',

  'underscore'
], (
  BaseChannelWorkerAdapter,
  consts
) ->

  BCWA = undefined
  send_task = undefined
  receive_task = undefined


  describe 'BaseChannelWorkerAdapter tests', ->

    beforeEach ->
      BCWA = new BaseChannelWorkerAdapter()
      send_task = {id: 1, type: consts.TASK_TYPE.SEND_TASK}
      receive_task = {id: 2, type: consts.TASK_TYPE.RECEIVE_TASK}


    it 'should be initialized with specified params', ->
      should.not.exist(BCWA.task)
      expect(BCWA.STATUS).to.be.equal(consts.WORKER_STATUS.WAITING)


    it 'should send message to the worker to perform some actions', ->
      msg =
        cmd: 'cmd'
        data: {a: 1, b: 2}
      BCWA.worker =
        postMessage: sinon.spy()

      BCWA.sendMessageToWorker(msg.cmd, msg.data)
      expect(BCWA.worker.postMessage.called).to.be.true
      expect(BCWA.worker.postMessage.calledWith(msg))
        .to.be.true


    it 'should start worker processing', ->
      sinon.spy()
      BCWA.sendMessageToWorker = sinon.spy(BCWA, 'sendMessageToWorker')
      BCWA.worker =
        postMessage: sinon.spy()

      BCWA.startProcessing()
      expect(BCWA.sendMessageToWorker.called).to.be.true
      expect(BCWA.sendMessageToWorker.calledOnce).to.be.true
      expect(BCWA.worker.postMessage.called).to.be.true
      expect(BCWA.worker.postMessage.calledWith({cmd: 'start_processing', data: {}}))
        .to.be.true


    it 'should stop worker processing', ->
      BCWA.sendMessageToWorker = sinon.spy(BCWA, 'sendMessageToWorker')
      BCWA.worker =
        postMessage: sinon.spy()

      BCWA.stopProcessing()
      expect(BCWA.sendMessageToWorker.called).to.be.true
      expect(BCWA.sendMessageToWorker.calledOnce).to.be.true
      expect(BCWA.worker.postMessage.called).to.be.true
      expect(BCWA.worker.postMessage.calledWith({cmd: 'stop_processing', data: {}}))
        .to.be.true


    it 'should log the message from the Worker', ->
      log_msg =
        cmd: 'log'
        msg: 'LOG MSG'
      BCWA._onLogMsg = sinon.spy()
      BCWA.worker =
        postMessage: sinon.spy()

      BCWA._handleMessageFromWorker(log_msg)
      expect(BCWA._onLogMsg.called).to.be.true
      expect(BCWA._onLogMsg.calledWith(log_msg.msg)).to.be.true


    it 'should perform proper actions on "progress" command from the Worker', ->
      progress_msg =
        cmd: 'progress'
        data: {}

      BCWA._onProgress = sinon.spy()

      BCWA._handleMessageFromWorker(progress_msg)
      expect(BCWA._onProgress.called).to.be.true
      expect(BCWA._onProgress.calledWith(progress_msg.data)).to.be.true


    it 'should perform proper actions on "status" command from the Worker', ->
      status_msg =
        cmd: 'status'
        status: 'status'

      BCWA._onChangeStatus = sinon.spy()

      BCWA._handleMessageFromWorker(status_msg)
      expect(BCWA._onChangeStatus.called).to.be.true
      expect(BCWA._onChangeStatus.calledWith(status_msg.status)).to.be.true


    it 'should perform proper actions on "complete" command from the Worker', ->
      complete_msg =
        cmd: 'complete'
        data: {}

      BCWA._onComplete = sinon.spy()

      BCWA._handleMessageFromWorker(complete_msg)
      expect(BCWA._onComplete.called).to.be.true
      expect(BCWA._onComplete.calledWith(complete_msg.data)).to.be.true


    it 'should assign the task', ->
      BCWA.startProcessing = sinon.spy()
      BCWA.assignTask(send_task)
      should.exist(BCWA.task)
      expect(BCWA.task.id).to.be.equal(send_task.id)
      expect(BCWA.startProcessing.called).to.be.true


    it 'should throw an Error if trying to assign task when
      another task is already assigned', ->
      BCWA.task = send_task
      BCWA.startProcessing = sinon.spy()
      fn = ->
        BCWA.assignTask(send_task)
      expect(fn).to.throw(Error)


    it 'should throw an Error if trying to assign task of unknown type', ->
      BCWA.task = {id: 1, type: 'asdasd'}
      BCWA.startProcessing = sinon.spy()
      fn = ->
        BCWA.assignTask(send_task)
      expect(fn).to.throw(Error)


    it 'should unassign the task', ->
      BCWA.task = send_task
      BCWA.stopProcessing = sinon.spy()
      BCWA.unassignTask()
      should.not.exist(BCWA.task)
      expect(BCWA.stopProcessing.called).to.be.true


    it 'should check if task is already assigned', ->
      expect(BCWA.hasTaskAssigned()).to.be.false
      BCWA.task = send_task
      expect(BCWA.hasTaskAssigned()).to.be.true


    it 'should check if worker is busy', ->
      BCWA.STATUS = consts.WORKER_STATUS.WAITING
      expect(BCWA.isBusy()).to.be.false
      BCWA.STATUS = consts.WORKER_STATUS.BUSY
      expect(BCWA.isBusy()).to.be.true


    it 'should check if worker is waiting', ->
      BCWA.STATUS = consts.WORKER_STATUS.BUSY
      expect(BCWA.isWaiting()).to.be.false
      BCWA.STATUS = consts.WORKER_STATUS.WAITING
      expect(BCWA.isWaiting()).to.be.true


    it 'should change its status', ->
      BCWA._onChangeStatus(consts.WORKER_STATUS.BUSY)
      expect(BCWA.STATUS).to.be.equal(consts.WORKER_STATUS.BUSY)


    it 'should throw an Error if trying to change status to an invalid one', ->
      fn = ->
        BCWA._onChangeStatus('asdasd')
      expect(fn).to.throw(Error)



