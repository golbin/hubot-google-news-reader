# Description:
#   Hubot WeirdMeetup Blog Reader
#
# Commands:
#   hubot blog
#
# Author:
#   @golbin

'use strict'

path      = require 'path'
_         = require 'lodash'
Promise   = require 'bluebird'
RSSReader = require path.join __dirname, '/libs/rss-reader'

NEWS_FEED_URL = 'http://news.google.co.kr/news?pz=1&cf=all&ned=kr&hl=ko&output=rss'

CACHE_EXPIRES = 60 * 1000# milliseconds
CACHED_TIME = 0
CACHED_ENTRIES = []

module.exports = (robot) ->
  reader = new RSSReader robot

  robot.respond /blog/i, (msg) ->
    if Date.now() > CACHED_TIME + CACHE_EXPIRES
      reader.fetch(NEWS_FEED_URL)
      .then (entries) ->
        CACHED_ENTRIES = entries
        CACHED_TIME = Date.now()
        send msg
      .catch (err) ->
        msg.send "뉴스를 가져오지 못했습니다."
    else
      send msg

  send (msg) ->
    for entry in CACHED_ENTRIES.splice(0,5)
      msg.send entry.toString()
    msg.send "갱신시간: " + new Date(CACHED_TIME)
