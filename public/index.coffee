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
      console.log e.keyCode
      if e.keyCode in [8, 46] # the delete keys
        e.preventDefault()
        @trigger "key", "delete"
        return false
   addBox: (box) =>
     @el.append box.view.el
     box.view.el.bind "dblclick", =>
       @trigger "boxdblclick", box
     box.view.el.bind "click", =>
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
      if key is "delete"
        console.log "trying to delete"
        @removeBox()
    @view.bind "boxdblclick", (box) =>
      box.view.textify()
    @view.bind "boxclick", (box) =>
      @setCurrentBox box
    @siteFinishController = new SiteFinishController
    Backbone.history.start()
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
    @currentBox = box
    done null, @currentBox
    return @currentBox
  setCurrentBox: (box) => 
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
      top: "200px"
      left: "200px"
    @el.dragsimple()
  textify: () =>
    @html = @el.html()
    @el.html "<textarea>#{html}</textarea>"



      

    



