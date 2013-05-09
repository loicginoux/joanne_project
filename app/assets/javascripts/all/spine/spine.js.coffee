Events =
  bind: (ev, callback) ->
    evs   = ev.split(' ')
    calls = @hasOwnProperty('_callbacks') and @_callbacks or= {}
    for name in evs
      calls[name] or= []
      calls[name].push(callback)
    this

  one: (ev, callback) ->
    @bind ev, handler = ->
      @unbind(ev, handler)
      callback.apply(this, arguments)

  trigger: (args...) ->
    ev = args.shift()
    list = @hasOwnProperty('_callbacks') and @_callbacks?[ev]
    return unless list
    for callback in list
      if callback.apply(this, args) is false
        break
    true

  listenTo: (obj, ev, callback) ->
    obj.bind(ev, callback)
    @listeningTo or= []
    @listeningTo.push obj
    this

  listenToOnce: (obj, ev, callback) ->
    listeningToOnce = @listeningToOnce or = []
    listeningToOnce.push obj
    obj.one ev, ->
      idx = listeningToOnce.indexOf(obj)
      listeningToOnce.splice(idx, 1) unless idx is -1
      callback.apply(this, arguments)
    this

  stopListening: (obj, ev, callback) ->
    if arguments.length is 0
      retain = []
      for listeningTo in [@listeningTo, @listeningToOnce]
        continue unless listeningTo
        for obj in listeningTo when not (obj in retain)
          obj.unbind()
          retain.push(obj)
      @listeningTo = undefined
      @listeningToOnce = undefined

    else if obj
      obj.unbind(ev, callback) if ev
      obj.unbind() unless ev
      for listeningTo in [@listeningTo, @listeningToOnce]
        continue unless listeningTo
        idx = listeningTo.indexOf(obj)
        listeningTo.splice(idx, 1) unless idx is -1

  unbind: (ev, callback) ->
    if arguments.length is 0
      @_callbacks = {}
      return this
    return this unless ev
    evs = ev.split(' ')
    for name in evs
      list = @_callbacks?[name]
      continue unless list
      unless callback
        delete @_callbacks[name]
        continue
      for cb, i in list when (cb is callback)
        list = list.slice()
        list.splice(i, 1)
        @_callbacks[name] = list
        break
    this

Events.on = Events.bind
Events.off = Events.unbind

Log =
  trace: true

  logPrefix: '(App)'

  log: (args...) ->
    return unless @trace
    if @logPrefix then args.unshift(@logPrefix)
    console?.log?(args...)
    this

moduleKeywords = ['included', 'extended']

class Module
  @include: (obj) ->
    throw new Error('include(obj) requires obj') unless obj
    for key, value of obj when key not in moduleKeywords
      @::[key] = value
    obj.included?.apply(this)
    this

  @extend: (obj) ->
    throw new Error('extend(obj) requires obj') unless obj
    for key, value of obj when key not in moduleKeywords
      @[key] = value
    obj.extended?.apply(this)
    this

  @proxy: (func) ->
    => func.apply(this, arguments)

  proxy: (func) ->
    => func.apply(this, arguments)

  constructor: ->
    @init?(arguments...)

class Model extends Module
  @extend Events

  @records: []
  @irecords: {}
  @crecords: {}
  @attributes: []

  @configure: (name, attributes...) ->
    @className = name
    @deleteAll()
    @attributes = attributes if attributes.length
    @attributes and= makeArray(@attributes)
    @attributes or=  []
    @unbind()
    this

  @toString: -> "#{@className}(#{@attributes.join(", ")})"

  @find: (id) ->
    record = @exists(id)
    throw new Error("\"#{@className}\" model could not find a record for the ID \"#{id}\"") unless record
    return record

  @exists: (id) ->
    (@irecords[id] ? @crecords[id])?.clone()

  @refresh: (values, options = {}) ->
    if options.clear
      @deleteAll()

    records = @fromJSON(values)
    records = [records] unless isArray(records)

    for record in records
      if record.id and @irecords[record.id]
        @records[@records.indexOf(@irecords[record.id])] = record
      else
        record.id or= record.cid
        @records.push(record)
      @irecords[record.id]  = record
      @crecords[record.cid] = record

    @sort()

    result = @cloneArray(records)
    @trigger('refresh', @cloneArray(records))
    result

  @select: (callback) ->
    (record.clone() for record in @records when callback(record))

  @findByAttribute: (name, value) ->
    for record in @records
      if record[name] is value
        return record.clone()
    null

  @findAllByAttribute: (name, value) ->
    @select (item) ->
      item[name] is value

  @each: (callback) ->
    callback(record.clone()) for record in @records

  @all: ->
    @cloneArray(@records)

  @first: ->
    @records[0]?.clone()

  @last: ->
    @records[@records.length - 1]?.clone()

  @count: ->
    @records.length

  @deleteAll: ->
    @records  = []
    @irecords = {}
    @crecords = {}

  @destroyAll: (options) ->
    record.destroy(options) for record in @records

  @update: (id, atts, options) ->
    @find(id).updateAttributes(atts, options)

  @create: (atts, options) ->
    record = new @(atts)
    record.save(options)

  @destroy: (id, options) ->
    @find(id).destroy(options)

  @change: (callbackOrParams) ->
    if typeof callbackOrParams is 'function'
      @bind('change', callbackOrParams)
    else
      @trigger('change', arguments...)

  @fetch: (callbackOrParams) ->
    if typeof callbackOrParams is 'function'
      @bind('fetch', callbackOrParams)
    else
      @trigger('fetch', arguments...)

  @toJSON: ->
    @records

  @fromJSON: (objects) ->
    return unless objects
    if typeof objects is 'string'
      objects = JSON.parse(objects)
    if isArray(objects)
      (new @(value) for value in objects)
    else
      new @(objects)

  @fromForm: ->
    (new this).fromForm(arguments...)

  @sort: ->
    if @comparator
      @records.sort @comparator
    @records

  # Private

  @cloneArray: (array) ->
    (value.clone() for value in array)

  @idCounter: 0

  @uid: (prefix = '') ->
    uid = prefix + @idCounter++
    uid = @uid(prefix) if @exists(uid)
    uid

  # Instance

  constructor: (atts) ->
    super
    @load atts if atts
    @cid = @constructor.uid('c-')

  isNew: ->
    not @exists()

  isValid: ->
    not @validate()

  validate: ->

  load: (atts) ->
    if atts.id then @id = atts.id
    for key, value of atts
      if atts.hasOwnProperty(key) and typeof @[key] is 'function'
        @[key](value)
      else
        @[key] = value
    this

  attributes: ->
    result = {}
    for key in @constructor.attributes when key of this
      if typeof @[key] is 'function'
        result[key] = @[key]()
      else
        result[key] = @[key]
    result.id = @id if @id
    result

  eql: (rec) ->
    !!(rec and rec.constructor is @constructor and
        (rec.cid is @cid) or (rec.id and rec.id is @id))

  save: (options = {}) ->
    unless options.validate is false
      error = @validate()
      if error
        @trigger('error', error)
        return false

    @trigger('beforeSave', options)
    record = if @isNew() then @create(options) else @update(options)
    @stripCloneAttrs()
    @trigger('save', options)
    record

  stripCloneAttrs: ->
    return if @hasOwnProperty 'cid' # Make sure it's not the raw object
    for own key, value of @
      delete @[key] if @constructor.attributes.indexOf(key) > -1
    this

  updateAttribute: (name, value, options) ->
    atts = {}
    atts[name] = value
    @updateAttributes(atts, options)

  updateAttributes: (atts, options) ->
    @load(atts)
    @save(options)

  changeID: (id) ->
    records = @constructor.irecords
    records[id] = records[@id]
    delete records[@id]
    @id = id
    @save()

  destroy: (options = {}) ->
    @trigger('beforeDestroy', options)

    # Remove record from model
    records = @constructor.records.slice(0)
    for record, i in records when @eql(record)
      records.splice(i, 1)
      break
    @constructor.records = records

    # Remove the ID and CID
    delete @constructor.irecords[@id]
    delete @constructor.crecords[@cid]

    @destroyed = true
    @trigger('destroy', options)
    @trigger('change', 'destroy', options)
    if @listeningTo
      @stopListening()
    @unbind()
    this

  dup: (newRecord) ->
    result = new @constructor(@attributes())
    if newRecord is false
      result.cid = @cid
    else
      delete result.id
    result

  clone: ->
    createObject(this)

  reload: ->
    return this if @isNew()
    original = @constructor.find(@id)
    @load(original.attributes())
    original

  toJSON: ->
    @attributes()

  toString: ->
    "<#{@constructor.className} (#{JSON.stringify(this)})>"

  fromForm: (form) ->
    result = {}
    for key in $(form).serializeArray()
      result[key.name] = key.value
    @load(result)

  exists: ->
    @constructor.exists(@id)

  # Private

  update: (options) ->
    @trigger('beforeUpdate', options)

    records = @constructor.irecords
    records[@id].load @attributes()

    @constructor.sort()

    clone = records[@id].clone()
    clone.trigger('update', options)
    clone.trigger('change', 'update', options)
    clone

  create: (options) ->
    @trigger('beforeCreate', options)
    @id          = @cid unless @id

    record       = @dup(false)
    @constructor.records.push(record)
    @constructor.irecords[@id]  = record
    @constructor.crecords[@cid] = record

    @constructor.sort()

    clone        = record.clone()
    clone.trigger('create', options)
    clone.trigger('change', 'create', options)
    clone

  bind: (events, callback) ->
    @constructor.bind events, binder = (record) =>
      if record && @eql(record)
        callback.apply(this, arguments)
    # create a wrapper function to be called with 'unbind' for each event
    for singleEvent in events.split(' ')
      do (singleEvent) =>
        @constructor.bind "unbind", unbinder = (record, event, cb) =>
          if record && @eql(record)
            return if event and event isnt singleEvent
            return if cb and cb isnt callback
            @constructor.unbind(singleEvent, binder)
            @constructor.unbind("unbind", unbinder)
    this

  one: (events, callback) ->
    @bind events, handler = =>
      @unbind(events, handler)
      callback.apply(this, arguments)

  trigger: (args...) ->
    args.splice(1, 0, this)
    @constructor.trigger(args...)

  listenTo: (obj, events, callback) ->
    obj.bind events, callback
    @listeningTo or= []
    @listeningTo.push(obj)

  listenToOnce: (obj, events, callback) ->
    listeningToOnce = @listeningToOnce or= []
    listeningToOnce.push obj
    obj.bind events, handler = =>
      idx = listeningToOnce.indexOf(obj)
      listeningToOnce.splice(idx, 1) unless idx is -1
      obj.unbind(events, handler)
      callback.apply(obj, arguments)

  stopListening: (obj, events, callback) ->
    if arguments.length is 0
      retain = []
      for listeningTo in [@listeningTo, @listeningToOnce]
        continue unless listeningTo
        for obj in @listeningTo when not (obj in retain)
          obj.unbind()
          retain.push(obj)
      @listeningTo = undefined
      @listeningToOnce = undefined
      return

    if obj
      obj.unbind() unless events
      obj.unbind(events, callback) if events
      for listeningTo in [@listeningTo, @listeningToOnce]
        continue unless listeningTo
        idx = listeningTo.indexOf(obj)
        listeningTo.splice(idx, 1) unless idx is -1

  unbind: (events, callback) ->
    if arguments.length is 0
      @trigger('unbind')
    else if events
      for event in events.split(' ')
        @trigger('unbind', event, callback)

Model::on = Model::bind
Model::off = Model::unbind

class Controller extends Module
  @include Events
  @include Log

  eventSplitter: /^(\S+)\s*(.*)$/
  tag: 'div'

  constructor: (options) ->
    @options = options

    for key, value of @options
      @[key] = value

    @el  = document.createElement(@tag) unless @el
    @el  = $(@el)
    @$el = @el

    @el.addClass(@className) if @className
    @el.attr(@attributes) if @attributes

    @events = @constructor.events unless @events
    @elements = @constructor.elements unless @elements

    context = @
    while parent_prototype = context.constructor.__super__
      @events = $.extend({}, parent_prototype.events, @events) if parent_prototype.events
      @elements = $.extend({}, parent_prototype.elements, @elements) if parent_prototype.elements
      context = parent_prototype

    @delegateEvents(@events) if @events
    @refreshElements() if @elements

    super

  release: =>
    @trigger 'release', this
    @el.remove()
    @unbind()
    @stopListening()

  $: (selector) -> $(selector, @el)

  delegateEvents: (events) ->
    for key, method of events

      if typeof(method) is 'function'
        # Always return true from event handlers
        method = do (method) => =>
          method.apply(this, arguments)
          true
      else
        unless @[method]
          throw new Error("#{method} doesn't exist")

        method = do (method) => =>
          @[method].apply(this, arguments)
          true

      match      = key.match(@eventSplitter)
      eventName  = match[1]
      selector   = match[2]

      if selector is ''
        @el.bind(eventName, method)
      else
        @el.delegate(selector, eventName, method)

  refreshElements: ->
    for key, value of @elements
      @[value] = @$(key)

  delay: (func, timeout) ->
    setTimeout(@proxy(func), timeout || 0)

  html: (element) ->
    @el.html(element.el or element)
    @refreshElements()
    @el

  append: (elements...) ->
    elements = (e.el or e for e in elements)
    @el.append(elements...)
    @refreshElements()
    @el

  appendTo: (element) ->
    @el.appendTo(element.el or element)
    @refreshElements()
    @el

  prepend: (elements...) ->
    elements = (e.el or e for e in elements)
    @el.prepend(elements...)
    @refreshElements()
    @el

  replace: (element) ->
    [previous, @el] = [@el, $(element.el or element)]
    previous.replaceWith(@el)
    @delegateEvents(@events)
    @refreshElements()
    @el

# Utilities & Shims

$ = window?.jQuery or window?.Zepto or (element) -> element

createObject = Object.create or (o) ->
  Func = ->
  Func.prototype = o
  new Func()

isArray = (value) ->
  Object::toString.call(value) is '[object Array]'

isBlank = (value) ->
  return true unless value
  return false for key of value
  true

makeArray = (args) ->
  Array::slice.call(args, 0)

# Globals

Spine = @Spine   = {}
module?.exports  = Spine

Spine.version    = '1.1.0'
Spine.isArray    = isArray
Spine.isBlank    = isBlank
Spine.$          = $
Spine.Events     = Events
Spine.Log        = Log
Spine.Module     = Module
Spine.Controller = Controller
Spine.Model      = Model

# Global events

Module.extend.call(Spine, Events)

# JavaScript compatability

Module.create = Module.sub =
  Controller.create = Controller.sub =
    Model.sub = (instances, statics) ->
      class Result extends this
      Result.include(instances) if instances
      Result.extend(statics) if statics
      Result.unbind?()
      Result

Model.setup = (name, attributes = []) ->
  class Instance extends this
  Instance.configure(name, attributes...)
  Instance

Spine.Class = Module



Spine = @Spine
$     = Spine.$

hashStrip    = /^#*/
namedParam   = /:([\w\d]+)/g
splatParam   = /\*([\w\d]+)/g
escapeRegExp = /[-[\]{}()+?.,\\^$|#\s]/g

class Spine.Route extends Spine.Module
  @extend Spine.Events

  @historySupport: window.history?.pushState?

  @routes: []

  @options:
    trigger: true
    history: false
    shim: false
    replace: false

  @add: (path, callback) ->
    if (typeof path is 'object' and path not instanceof RegExp)
      @add(key, value) for key, value of path
    else
      @routes.push(new @(path, callback))

  @setup: (options = {}) ->
    @options = $.extend({}, @options, options)

    if (@options.history)
      @history = @historySupport and @options.history

    return if @options.shim

    if @history
      $(window).bind('popstate', @change)
    else
      $(window).bind('hashchange', @change)
    @change()

  @unbind: ->
    return if @options.shim

    if @history
      $(window).unbind('popstate', @change)
    else
      $(window).unbind('hashchange', @change)

  @navigate: (args...) ->
    options = {}

    lastArg = args[args.length - 1]
    if typeof lastArg is 'object'
      options = args.pop()
    else if typeof lastArg is 'boolean'
      options.trigger = args.pop()

    options = $.extend({}, @options, options)

    path = args.join('/')
    return if @path is path
    @path = path

    @trigger('navigate', @path)

    @matchRoute(@path, options) if options.trigger

    return if options.shim

    if @history and options.replace
      history.replaceState({}, document.title, @path)
    else if @history
      history.pushState({}, document.title, @path)
    else
      window.location.hash = @path

  # Private

  @getPath: ->
    if @history
      path = window.location.pathname
      path = '/' + path if path.substr(0,1) isnt '/'
    else
      path = window.location.hash
      path = path.replace(hashStrip, '')
    path

  @getHost: ->
    "#{window.location.protocol}//#{window.location.host}"

  @change: ->
    path = @getPath()
    return if path is @path
    @path = path
    @matchRoute(@path)

  @matchRoute: (path, options) ->
    for route in @routes when route.match(path, options)
      @trigger('change', route, path)
      return route

  constructor: (@path, @callback) ->
    @names = []

    if typeof path is 'string'
      namedParam.lastIndex = 0
      while (match = namedParam.exec(path)) != null
        @names.push(match[1])

      splatParam.lastIndex = 0
      while (match = splatParam.exec(path)) != null
        @names.push(match[1])

      path = path.replace(escapeRegExp, '\\$&')
                 .replace(namedParam, '([^\/]*)')
                 .replace(splatParam, '(.*?)')

      @route = new RegExp("^#{path}$")
    else
      @route = path

  match: (path, options = {}) ->
    match = @route.exec(path)
    return false unless match
    options.match = match
    params = match.slice(1)

    if @names.length
      for param, i in params
        options[@names[i]] = param

    @callback.call(null, options) isnt false

# Coffee-script bug
Spine.Route.change = Spine.Route.proxy(Spine.Route.change)

Spine.Controller.include
  route: (path, callback) ->
    Spine.Route.add(path, @proxy(callback))

  routes: (routes) ->
    @route(key, value) for key, value of routes

  navigate: ->
    Spine.Route.navigate.apply(Spine.Route, arguments)

module?.exports = Spine.Route


Spine  = @Spine
$      = Spine.$

class Spine.Manager extends Spine.Module
  @include Spine.Events

  constructor: ->
    @controllers = []
    @bind 'change', @change
    @add(arguments...)

  add: (controllers...) ->
    @addOne(cont) for cont in controllers

  addOne: (controller) ->
    controller.bind 'active', (args...) =>
      @trigger('change', controller, args...)
    controller.bind 'release', =>
      @controllers.splice(@controllers.indexOf(controller), 1)

    @controllers.push(controller)

  deactivate: ->
    @trigger('change', false, arguments...)

  # Private

  change: (current, args...) ->
    for cont in @controllers
      if cont is current
        cont.activate(args...)
      else
        cont.deactivate(args...)

Spine.Controller.include
  active: (args...) ->
    if typeof args[0] is 'function'
      @bind('active', args[0])
    else
      args.unshift('active')
      @trigger(args...)
    @

  isActive: ->
    @el.hasClass('active')

  activate: ->
    @el.addClass('active')
    @

  deactivate: ->
    @el.removeClass('active')
    @

class Spine.Stack extends Spine.Controller
  controllers: {}
  routes: {}

  className: 'spine stack'

  constructor: ->
    super

    @manager = new Spine.Manager

    for key, value of @controllers
      throw Error "'@#{ key }' already assigned - choose a different name" if @[key]?
      @[key] = new value(stack: @)
      @add(@[key])

    for key, value of @routes
      do (key, value) =>
        callback = value if typeof value is 'function'
        callback or= => @[value].active(arguments...)
        @route(key, callback)

    @[@default].active() if @default

  add: (controller) ->
    @manager.add(controller)
    @append(controller)

module?.exports = Spine.Manager
module?.exports.Stack = Spine.Stack