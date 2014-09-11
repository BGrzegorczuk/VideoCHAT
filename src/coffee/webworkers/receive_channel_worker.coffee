'''
  Receive channel worker
'''

importScripts('../vendor/require.js')

## initialize worker globals
IS_BUSY = false
CHUNKS_COUNT_TOTAL = undefined
DATA_SIZE_RECEIVED = undefined # data that have been already received
DATA_SIZE_TOTAL = undefined # real data size - with padding
CHUNK_INDEX = undefined # chunk to send index
METADATA = undefined
BLOB = undefined
STOP_PROCESSING = false
HOST = undefined
# for transfer speed calculations
CHUNKS_DOWNLOAD_TIMES = undefined


require [
  '../consts'
],
(
  consts
) ->


  CHUNK_SIZE = consts.CHUNK_SIZE


  onDownloadComplete = ->

  onChunkReceived = ->

  downloadChunks = ->
