define [
  'processing_queue',
  'consts',

  'underscore'
], (
  ProcessingQueue,
  consts
) ->

  BQ = undefined
  PQ = undefined


  describe 'ProcessingQueue tests', ->

    beforeEach ->

      BQ =
        send_tasks: []
        receive_tasks: []
        fetchSendTask: sinon.stub().returns(null)
        fetchReceiveTask: sinon.stub().returns(null)

      PQ = new ProcessingQueue(BQ)


    it 'should initialize with particular param values', ->
      expect(PQ.STARTED).to.be.false
      expect(PQ.send_workers).to.be.an('array')
      expect(PQ.receive_workers).to.be.an('array')
      should.exist(PQ.interval)


    it 'should be able to start the queue processing loop', ->
      should.not.exist(PQ.loopTicker)
      PQ.start()
      expect(PQ.STARTED).to.be.true
      should.exist(PQ.loopTicker)


    it 'should throw an Error if trying to start already started queue', ->
      PQ.STARTED = true
      fn = ->
        PQ.start()
      expect(fn).to.throw(Error)


    it 'should be able to stop the queue processing loop', ->
      PQ.start()
      PQ.stop()
      expect(PQ.STARTED).to.be.false


    it 'should throw an Error if trying to stop already stopped queue', ->
      fn = ->
        PQ.stop()
      expect(fn).to.throw(Error)


    it 'should check for send task from its BufferQueue', ->
      PQ.checkForSendTask()
      expect(BQ.fetchSendTask.called).to.be.true
      expect(BQ.fetchSendTask.callCount).to.be.equal(1)


    it 'should check for receive task from its BufferQueue', ->
      PQ.checkForReceiveTask()
      expect(BQ.fetchReceiveTask.called).to.be.true
      expect(BQ.fetchReceiveTask.callCount).to.be.equal(1)


    it 'should add new send worker of type SendChannelWorkerAdapter', ->
      PQ.send_workers = []
      PQ.addSendWorker()
      expect(PQ.send_workers).to.have.length(1)
      PQ.addSendWorker()
      expect(PQ.send_workers).to.have.length(2)


    it 'should throw an Error if trying to add too much send workers', ->
      # creating fake send workers
      PQ.send_workers = []
      while PQ.send_workers.length < consts.MAX_SEND_WORKERS
        PQ.send_workers.push Math.floor(Math.random() * 10)

      fn = ->
        PQ.addSendWorker()
      expect(fn).to.throw(Error)


    it 'should add new receive worker of type ReceiveChannelWorkerAdapter', ->
      PQ.receive_workers = []
      PQ.addReceiveWorker()
      expect(PQ.receive_workers).to.have.length(1)
      PQ.addReceiveWorker()
      expect(PQ.receive_workers).to.have.length(2)


    it 'should throw an Error if trying to add too much receive workers', ->
      # creating fake receive workers
      PQ.receive_workers = []
      while PQ.receive_workers.length < consts.MAX_RECEIVE_WORKERS
        PQ.receive_workers.push Math.floor(Math.random() * 10)

      fn = ->
        PQ.addReceiveWorker()
      expect(fn).to.throw(Error)


    it 'should start processing send task by assigning it to given SendChannelWorker', ->
      send_task = sinon.stub()
      send_channel_worker =
        assignTask: sinon.spy()

      PQ.startProcessingSendTask(send_task, send_channel_worker)

      expect(send_channel_worker.assignTask.called).to.be.true
      expect(send_channel_worker.assignTask.calledWith(send_task)).to.be.true


    ## TODO: should be handled in BaseChannelWorker
    # it 'should throw an Error while assigning send task to improper worker', ->

    ## TODO: should be handled in BaseChannelWorker
    # it 'should throw an Error while assigning send task to already processing SendChannelWorker', ->


    it 'should start processing receive task by assigning it to given ReceiveChannelWorker', ->
      receive_task = sinon.stub()
      receive_channel_worker =
        assignTask: sinon.spy()

      PQ.startProcessingReceiveTask(receive_task, receive_channel_worker)

      expect(receive_channel_worker.assignTask.called).to.be.true
      expect(receive_channel_worker.assignTask.calledWith(receive_task)).to.be.true


    ## TODO: should be handled in BaseChannelWorker
    # it 'should throw an Error while assigning receive task to improper worker', ->

    ## TODO: should be handled in BaseChannelWorker
    # it 'should throw an Error while assigning receive task to already processing ReceiveChannelWorker', ->


    it 'should return free SendChannelWorker waiting for task to be assigned,
      or null if there is no waiting workers', ->
      PQ.send_workers = []
      PQ.receive_workers = []
      busy_worker = {id: 1, isWaiting: sinon.stub().returns(false)}
      free_worker = {id: 2, isWaiting: sinon.stub().returns(true)}

      _worker = PQ.getWaitingSendWorker()
      should.not.exist(_worker)

      PQ.send_workers.push(busy_worker)
      _worker = PQ.getWaitingSendWorker()
      should.not.exist(_worker)

      PQ.send_workers.push(free_worker)
      _worker = PQ.getWaitingSendWorker()
      should.exist(_worker)
      expect(_worker.id).to.be.equal(free_worker.id)


    it 'should return free ReceiveChannelWorker waiting for task to be assigned,
      or null if there is no waiting workers', ->
      PQ.send_workers = []
      PQ.receive_workers = []
      busy_worker = {id: 1, isWaiting: sinon.stub().returns(false)}
      free_worker = {id: 2, isWaiting: sinon.stub().returns(true)}

      _worker = PQ.getWaitingReceiveWorker()
      should.not.exist(_worker)

      PQ.send_workers.push(busy_worker)
      _worker = PQ.getWaitingReceiveWorker()
      should.not.exist(_worker)

      PQ.receive_workers.push(free_worker)
      _worker = PQ.getWaitingReceiveWorker()
      should.exist(_worker)
      expect(_worker.id).to.be.equal(free_worker.id)


    it 'should return send worker associated with particular send task,
      or return null if not found', ->
      task = {id: 1}
      worker =
        hasTaskAssigned: sinon.stub().returns(true)
        task: task

      _worker = PQ._getSendWorkerAssociatedWithTask(task)
      should.not.exist(_worker)

      PQ.send_workers.push(worker)
      _worker = PQ._getSendWorkerAssociatedWithTask(task)
      should.exist(_worker)
      expect(_worker.task.id).to.be.equal(task.id)


    it 'should return receive worker associated with particular receive task,
      or return null if not found', ->
      task = {id: 1}
      worker =
        hasTaskAssigned: sinon.stub().returns(true)
        task: task

      _worker = PQ._getReceiveWorkerAssociatedWithTask(task)
      should.not.exist(_worker)

      PQ.receive_workers.push(worker)
      _worker = PQ._getReceiveWorkerAssociatedWithTask(task)
      should.exist(_worker)
      expect(_worker.task.id).to.be.equal(task.id)


    it 'should return particular worker connected with given task, depending on task type,
      or return null if not found', ->
      send_task = {id: 1, type: consts.TASK_TYPE.SEND_TASK}
      receive_task = {id: 2, type: consts.TASK_TYPE.RECEIVE_TASK}
      worker =
        hasTaskAssigned: sinon.stub().returns(true)

      ## use spies rather than original methods
      PQ._getSendWorkerAssociatedWithTask = sinon.spy()
      PQ._getReceiveWorkerAssociatedWithTask = sinon.spy()

      PQ.getWorkerAssociatedWithTask(send_task)
      expect(PQ._getSendWorkerAssociatedWithTask.called).to.be.true
      expect(PQ._getSendWorkerAssociatedWithTask.calledWith(send_task)).to.be.true

      PQ.getWorkerAssociatedWithTask(receive_task)
      expect(PQ._getReceiveWorkerAssociatedWithTask.called).to.be.true
      expect(PQ._getReceiveWorkerAssociatedWithTask.calledWith(receive_task)).to.be.true


    it 'should throw an Error if trying to get task of unknown type', ->
      task = {id: 1, type: 'adsasd'}
      fn = ->
        PQ.getWorkerAssociatedWithTask(task)
      expect(fn).to.throw(Error)

