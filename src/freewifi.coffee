class FreeWifi
  constructor: (@options = {}) ->
    @options.host          ?= 'wifi.free.fr'
    @options.port          ?= 443
    @options.scheme        ?= 'https'
    @options.verbose       ?= true
    @options.successString ?= 'CONNEXION AU SERVICE REUSSIE'
    @http = if @options.scheme is 'https' then require 'https' else require 'http'

  loginRequired: =>
    throw new Error 'the `login` option is required'    unless @options.login
    throw new Error 'the `password` option is required' unless @options.password

  _prepareQuery: (query) ->
    ["#{key}=#{val}" for key, val of query][0].join('&') + '\n'

  _request: (opts, fn) =>
    opts.host    ?= @options.host
    opts.port    ?= @options.port
    opts.scheme  ?= @options.scheme
    opts.path    ?= '/'
    opts.headers ?= {}
    opts.method  ?= 'GET'
    opts.expects ?= 200
    opts.query   ?= null

    if opts.query
      query = @_prepareQuery opts.query
      opts.headers['Content-Length'] = query.length
      opts.headers['Content-Type'] =   'application/x-www-form-urlencoded'
      opts.headers['Accept'] =         '*/*'
    else
      query = null

    req = @http.request opts, (res) ->
      data = ''
      res.on 'data', (buf) -> data += buf
      res.on 'error', -> console.log 'error'
      res.on 'end', ->
        unless res.statusCode is opts.expects
          return fn true, '',
            code:     res.statusCode
            options:  opts
            response: data
        return fn false, data, res
    req.on 'error', (e) -> return fn true, '', e
    req.end query

  _connectRequest: (fn) =>
    opts =
      method:  'POST'
      path:    '/Auth'
      expects: 200
      query:
        login:    @options.login
        password: @options.password
        submit:   'Valider'
    @_request opts, fn

  _connectVerify: (data, res, fn) =>
    if data.indexOf @options.successString is -1
      fn true,  'Authentication error'
    else
      fn false, 'Success'

  connect: (fn = null) =>
    try
      do @loginRequired
    catch e
      return fn true, e
    @_connectRequest (err, data, res) =>
      return fn true, res if err
      @_connectVerify data, res, fn

module.exports =
  FreeWifi: FreeWifi
