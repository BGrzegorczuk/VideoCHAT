define [
  'connection_manager',
  'consts'
], (
  ConnectionManager,
  consts
) ->

  CM = undefined


  describe 'ConnectionManager tests', ->

    beforeEach ->

      CM = new ConnectionManager(
        'localhost',
        'xxx',
        [],
        []
      )


    it 'should have parameters assigned on instantiation', ->
      expect(CM.isInitiator).to.be.false
      expect(CM.isStarted).to.be.false
      expect(CM.isChannelReady).to.be.false
      expect(CM.turnReady).to.be.false
      should.exist(CM.pc_config)
      should.exist(CM.pc_config.iceServers)
      expect(CM.pc_config).to.have.keys(['iceServers'])
      expect(CM.pc_config.iceServers).to.be.an('array').and.not.to.be.empty
      should.exist(CM.pc_constraints)
      expect(CM.pc_constraints).to.have.keys(['optional'])
      expect(CM.pc_constraints.optional).to.be.an('array').and.not.to.be.empty
      should.exist(CM.sdpConstraints)
      expect(CM.sdpConstraints).to.have.keys(['mandatory'])


    it 'should establish web socket connection on init', ->
      CM.connect = sinon.spy()
      CM.handleUserMedia = sinon.spy()
      CM.handleUserMediaError = sinon.spy()

      CM.init()
      expect(CM.connect.called).to.be.true


    it 'should get user media info using browser funciton, independently from the browser', ->
      CM.connect = sinon.spy()
      CM.handleUserMedia = sinon.spy()
      CM.handleUserMediaError = sinon.spy()

      should.exist(getUserMedia)
      CM.init()

