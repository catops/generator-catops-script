chai = require 'chai'
sinon = require 'sinon'
expect = chai.expect
helper = require 'hubot-mock-adapter-helper'
TextMessage = require('hubot/src/message').TextMessage

chai.use require 'sinon-chai'

class Helper
  constructor: (@robot, @adapter, @user)->

  sendMessage: (done, message, callback)->
    @sendMessageHubot(@user, message, callback, done, 'send')

  replyMessage: (done, message, callback)->
    @sendMessageHubot(@user, message, callback, done, 'reply')

  sendMessageHubot: (user, message, callback, done, event)->
    @adapter.on event, (envelop, string) ->
      try
        callback(string)
        done()
      catch e
        done e
    @adapter.receive new TextMessage(user, message)


describe '<%= scriptName %>', ->
  {robot, user, adapter} = {}
  messageHelper = null

  beforeEach (done)->
    helper.setupRobot (ret) ->
      process.setMaxListeners(0)
      {robot, user, adapter} = ret
      messageHelper = new Helper(robot, adapter, user)
      process.env.HUBOT_AUTH_ADMIN = user['id']
      messageHelper.robot.auth = isAdmin: ->
        return process.env.HUBOT_AUTH_ADMIN.split(',').indexOf(user['id']) > -1
      do done

  afterEach ->
    robot.shutdown()

  beforeEach ->
    require('../src/<%= scriptName %>')(robot)

  describe 'really cool feature', ->
    it 'greets you back', (done)->
      # if it's a `respond` event, use `replyMessage`
      messageHelper.replyMessage done, 'hubot hello', (result) ->
        expect(result[0]).to.equal('hello!')

  describe 'other really cool feature', ->
    # if it's just a general `hear` event, use `sendMessage`
    it 'denies your rly if you\'re not an admin', (done) ->
      process.env.HUBOT_AUTH_ADMIN = []
      messageHelper.sendMessage done, 'orly', (result) ->
        expect(result[0]).to.equal('Sorry, only admins can do that.')

    it 'confirms your rly if you\'re an admin', (done)->
      messageHelper.sendMessage done, 'orly', (result) ->
        expect(result[0]).to.equal('yarly')
