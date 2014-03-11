# Description:
#   Updates from GMail
#
# Configuration:
#   GMAIL_USER
#   GMAIL_PASSWORD
#   GMAIL_LABEL
#   GMAIL_FETCH_INTERVAL
#
# Commands:
#   hubot fetch-gmail start - Start the gmail update via IMAP
#   hubot fetch-gmail change <mins> - Change the interval of gmail updates
#   hubot fetch-gmail stop - Stop the gmail update
#
# Author:
#   udzura / (pksunkara)
#
# See Also:
#   https://github.com/github/hubot-scripts/blob/master/src/scripts/kickstarter.coffee

inbox        = require 'inbox'
{MailParser} = require 'mailparser'

_ = require 'lodash'
  
module.exports = (robot) ->
  timer = 0
  interval = parseInt(process.env.GMAIL_FETCH_INTERVAL || 1)
  label = process.env.GMAIL_LABEL || "Inbox"
  client = false

  robot.respond /fetch-gmail start/i, (msg) ->
    if not client
      client = initClient(msg)
      if client
        msg.send "Started the GMail fetch"
    else
      msg.send "Its already running!"

  robot.respond /fetch-gmail stop/i, (msg) ->
    if client
      client.close()
      client = false
      clearTimeout timer
      msg.send "Stopped the GMail fetch"

  robot.respond /fetch-gmail change ([1-9][0-9]*)/i, (msg) ->
    clearTimeout timer
    interval = parseInt msg.match[1]
    setTimer interval, msg
    msg.send "Changed the GMail fetch interval"

  initClient = (msg) ->
    robot.logger.info "Initializing IMAP client..."
    _client = inbox.createConnection false, "imap.gmail.com", {
      secureConnection: true
      auth:
        user: process.env.GMAIL_USER
        pass: process.env.GMAIL_PASSWORD
    }
    _client.lastfetch = 0
    _client.connect()
    _client.on 'connect', () ->
      _client.openMailbox label, (e, info) ->
        if e
          msg.send e
          return false
        robot.logger.info("Message count in #{label}: " + info.count)
        setTimer interval, msg
    return _client

  setTimer = (_interval, msg) ->
    timer = setTimeout doFetch, _interval * 60 * 1000, ((e, mail) ->
      if e
        robot.logger.info e
      else
        robot.logger.info "Get mail: ", mail.subject
        mailDetail = ""
        sender = mail.from[0]
        mailDetail += "From: #{sender.name} <#{sender.address}>\n"
        mailDetail += "Subject: #{mail.subject}\n"
        if mail.text
          mailDetail += "\n"
          mailDetail += mail.text
        msg.send mailDetail
      ), (() ->
        robot.logger.info "Max UID: #{client.lastfetch}"
        setTimer interval, msg
      )

  doFetch = (callback, onFinish) ->
    robot.logger.info "Check it!"
    client.listMessages -10, (e, messages) ->
      maxUID = _.max(_.map messages, (m) -> m.UID)
      if e
        callback e
      else if maxUID <= client.lastfetch
        callback(new Error "No new mail")
      else
        for message in messages
          if client.lastfetch < message.UID
            stream = client.createMessageStream(message.UID)
            mailparser = new MailParser()
            mailparser.on 'end', (mail) ->
              callback(null, mail)
            stream.pipe(mailparser)
        client.lastfetch = maxUID
      onFinish()
