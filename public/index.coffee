_.each ['s'], (method) ->
  Backbone.Collection.prototype[method] = () ->
    return _[method].apply _, [this.models].concat _.toArray arguments

liteAlert = (message) ->
  console.log message

class SiteFinishView extends Backbone.View
  constructor: ->
    @el = $('#page')
    super
    $('#box').click (e) =>
      e.preventDefault()
      @trigger "addboxclick"
    $(document.body).keydown (e) =>
      if @state is "input" and e.keyCode isnt 27 then return
      keys =
        78: "n"
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
  key_delete: => @removeBox()
  key_n: => @addBox()
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
    @el.html "<textarea>#{@html}</textarea>"
  saveHtml: () =>
    @html = @el.find("textarea").val()
    @el.html @html
    



      

    



