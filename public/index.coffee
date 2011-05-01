_.each ['s'], (method) ->
  Backbone.Collection.prototype[method] = () ->
    return _[method].apply _, [this.models].concat _.toArray arguments

server = (args...) ->
  method = args[0]

  if args.length is 2
    if _.isFunction(args[1])
      callback = args[1]
    else
      data = args[1]
  else if args.length is 3
    data = args[1]
    callback = args[2]

  #data ||= {}
  callback ||= ->

  if _.isArray method
    [method, args...] = method

  if _.s(method, 0,1)[0] isnt "/"
    method = "/#{method}"
  $.ajax 
    url: method
    type: "POST"
    contentType: 'application/json'
    data: data
    dataType: 'json'
    processData: false
    success: (data) ->
      console.log "there was success"
      callback null, data
    error: (data) ->
      console.log data
      console.log "there was a server error"
      callback data

liteAlert = (message) ->
  console.log message

class SiteFinishView extends Backbone.View
  constructor: ->
    @el = $('#page')
    super
    $('#box').click (e) =>
      e.preventDefault()
      @trigger "addboxclick"
    $('#save').click (e) =>
      e.preventDefault()
      @trigger "save"
    $(document.body).keydown (e) =>
      if @state is "input" and e.keyCode isnt 27 then return
      keys =
        78: "n"
        73: "i"
        8: "delete"
        46: "delete"
        27: "esc"
      console.log e.keyCode
      if e.keyCode of keys
        e.preventDefault()
        @trigger "key", keys[e.keyCode]
        return false
   addBox: (box) =>
     @el.append box.view.el
     box.view.el.bind "dblclick", =>
       @trigger "boxdblclick", box
     box.view.el.bind "mousedown", =>
       @trigger "boxclick", box
   removeBox: (box) =>
     box.view.el.remove()
   setCurrentBox: (box) =>
     $('.box.selected').removeClass "selected"
     box.view.el.addClass "selected"

class SiteFinishController extends Backbone.Controller
  constructor: () ->
    super
  routes:
    "test": "test"
    "tests/:test": "tests"
  tests: (test) =>
    runTest test
  test: () =>
    runTests() 

class SiteFinishPresenter
  constructor: ->
    @boxes = new Boxes
    @boxes.bind "add", (box, boxes) =>
      @view.addBox box
    @boxes.bind "remove", (box, boxes) =>
      @view.removeBox box
      

    @view = new SiteFinishView()
    @view.bind "addboxclick", (done) => @addBox(done)
    @view.bind "key", (key) =>
      theKey = "key_#{key}"
      if theKey of @
        @[theKey]()
    @view.bind "boxdblclick", (box) => @editBoxText(box)
    @view.bind "boxclick", (box) =>
      @setCurrentBox box
    @siteFinishController = new SiteFinishController
    Backbone.history.start()
    @view.bind "save", (done= ->) =>
      send = 
        page: $('#page').html()
      send = JSON.stringify send
      server "#{@getPathName()}", send, (err, data) ->
        done err, data
    @showLink()
  getPathName: ->
    pathname = location.pathname
    if pathname is "/" then pathname = "/meta"
    pathname
  getLink: =>
    pathname = @getPathName()
    subdomain = _.s pathname, 1
    @link = "http://#{subdomain}.sf.the.tl"
    return @link
  showLink: =>
    # if aimee is "happy"
    #   alert "happy"

    # if (aimee == "happy") {
    #   alert("happy");
    # }

    # if ($aimee == "happy") {
    #   alert("happy");
    # }

    # if aimee == "happy":
    #   alert("happy")

    # if aimee == "happy"
    #   alert "happy"
    # end
    $('#link').attr("href", @getLink).text @getLink
    
  key_delete: => @removeBox()
  key_n: => @addBox()
  key_i: => @editBoxText()
  key_esc: => @saveBoxHtml()
  editBoxText: (box) =>
    box ||= @currentBox
    @setCurrentBox box
    @view.state = "input"
    box.view.el.dragsimple "destroy"
    box.view.textify()
    box.view.el.find("textarea").blur () => @saveBoxHtml box
  saveBoxHtml: (box)=>
    box ||= @currentBox
    if @view.state is "input"
      box.view.saveHtml()
      @view.state = "not input"
      box.view.el.dragsimple()
      
  removeBox: (box) =>
    box ||= @currentBox
    if not box
      return 
    index = @boxes.indexOf box
    @boxes.remove box
    oldBox = box
    newCurrentBox = app.boxes.s(index - 1, 1)[0]
    console.log newCurrentBox
    if newCurrentBox
      @setCurrentBox newCurrentBox
    return oldBox
  addBox: (done=->) =>
    done ||= ->
    box = new Box type: "div"
    box.view = new BoxView model: box
    @boxes.add box
    @setCurrentBox box
    done null, @currentBox
    return @currentBox
  setCurrentBox: (box) => 
    if @view.state == "input" then return false 
    @view.setCurrentBox box 
    @currentBox = box
    
    
class Boxes extends Backbone.Collection
  url: "/boxes"
  model: Box
  constructor: () ->
    super

class Box extends Backbone.Model
  constructor: ->
    super

boxCount = 0    
class BoxView extends Backbone.View
  constructor: ->
    super
    @type = @model.get('type') || "div"
    @el = $ @make @type 
    @el.addClass "box"
    @el.attr "id", "box#{++boxCount}"
    @el.css
      top: "50px"
      left: "50px"
    @el.dragsimple()
  textify: () =>
    @html = @el.html()
    width = @el.width() - 10
    height = @el.height() - 10
    @el.html "<textarea style=\"width:#{width}px; height:#{height}px\">#{@html}</textarea>"
    @el.find("textarea").focus()
  saveHtml: () =>
    @html = @el.find("textarea").val()
    @el.html @html
    



      

    



