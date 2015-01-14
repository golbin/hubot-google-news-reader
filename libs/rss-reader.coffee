# Description:
#   RSS Entries Fetcher
#
# Author:
#   @golbin

'use strict'

qs         = require 'querystring'
request    = require 'request'
FeedParser = require 'feedparser'
Promise    = require 'bluebird'

module.exports = class RSSReader
  fetch: (url) ->
    new Promise (resolve, reject) =>
      feedparser = new FeedParser
      req = request
        uri: url
        timeout: 10000

      req.on 'error', (err) ->
        reject err

      req.on 'response', (res) ->
        stream = this
        if res.statusCode isnt 200
          return reject "statusCode: #{res.statusCode}"
        stream.pipe feedparser

      feedparser.on 'error', (err) ->
        reject err

      entries = []
      feedparser.on 'data', (chunk) =>
        link = qs.parse(chunk.link).url
        entry =
          url: link
          title: chunk.title
          toString: ->
            s = "#{@title} - #{@url}"
            return s

        entries.push entry

      feedparser.on 'end', ->
        resolve entries

