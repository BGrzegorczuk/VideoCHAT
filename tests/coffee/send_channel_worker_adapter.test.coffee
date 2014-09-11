define [
  'base_channel_worker_adapter',
  'send_channel_worker_adapter',
  'consts',

  'underscore'
], (
  BaseChannelWorkerAdapter,
  SendChannelWorkerAdapter,
  consts
) ->

  SCWA = undefined
  send_task = undefined
  receive_task = undefined


  describe 'SendChannelWorkerAdapter tests', ->

    beforeEach ->
      SCWA = new SendChannelWorkerAdapter()
      send_task = {id: 1, type: consts.TASK_TYPE.SEND_TASK}
      receive_task = {id: 2, type: consts.TASK_TYPE.RECEIVE_TASK}


    it 'should be inherited from BaseChannelWorkerAdapter', ->
      expect(SCWA).to.be.an.instanceOf(BaseChannelWorkerAdapter)


    it 'should be initialized with specified params', ->
      should.not.exist(SCWA.task)
      expect(SCWA.STATUS).to.be.equal(consts.WORKER_STATUS.WAITING)


    it 'should send data in chunks between users', ->
      expect(false).to.be.true


    it 'should perform actions after each data chunk is successfully sent', ->
      expect(false).to.be.true


    it 'should perform actions after data transfer is successfully sent', ->
      expect(false).to.be.true