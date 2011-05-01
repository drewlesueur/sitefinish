_.assertClose = (val, otherVal, within, message) ->
  if Math.abs(otherVal - val) <= within
    _.assertPass val, otherVal, message, "within #{within} of", _.assertClose
  else
    _.assertFail val, otherVal, message, "within #{within} of", _.assertClose

_.assertSee = (text, message) ->
  if $("body:contains('#{text}'):visible").length !=0
    _.assertPass text, "[html body]", message, "see", _.assertSee 
  else
    _.assertFail text, "[html body]", message, "see", _.assertSee 

_.assertNoSee = (text, message) ->
  if $("body:contains('#{text}'):visible").length !=0
    _.assertFail text, "not that!", message, "see", _.assertSee 
  else
    _.assertPass text, "[html body]", message, "see", _.assertSee 

tests = {}

test = (title, func) ->
  tests[title] = func

  

test "Title should be SiteFinish", (done) ->
  _.assertEqual document.title, "SiteFinish",
  "Title should equali SiteFinsh"
  done()

test "adding a box to the screen", (done) ->
  app.view.trigger "addboxclick"
  _.assertEqual $('#box1').length, 1,
  "One box should be on the screen"
  done()


test "should be able to delete a specific box", (done) ->
  box1 = app.addBox()
  box2 = app.addBox()
  box3 = app.addBox()
  #box2.handleClick()
  app.view.trigger "boxclick", box2
  app.view.trigger "key", "delete"
  _.assertOk not(app.boxes.include(box2)), "box2 is gone"
  _.assertOk app.boxes.include(box1), "box1 is there"
  _.assertOk app.boxes.include(box3), "box3 is there"
  app.removeBox box1
  app.removeBox box3
  done()
  
  
test "Should be able to delete a box", (done) ->
  app.view.trigger "key", "delete"
  _.assertEqual $('#box1').length, 0,
  "The added box should be gone"

  done()
#test "Should be able to "



server = (method, callback) ->
  if _.isArray method
    [method, args...] = method
  $.ajax 
    url: "/#{method}"
    type: "POST"
    contentType: 'application/json'
    data: args
    dataType: 'json'
    processData: false
    success: (data) -> callback null, data
    error: (data) -> callback data

testsComplete = (err, results) -> 
  results = """
    #{_.getAssertCount()} tests ran
    #{_.getPassCount()} tests passed
    #{_.getFailCount()} tests failed
  """

  $('#test-text').html results.replace /\n/g, "<br />"
  console.log results
  

runTest = (testName) ->
  testName = testName.replace /_/g, " "
  _.wait 1000, () ->
    _.series [tests[testName]], testsComplete
  
runTests = () ->
  _.wait 1000, () ->
    newTests = {}
    _.each tests, (test, key) ->
      newTests[key] = (done) -> 
        console.log key
        test(done)
    _.series newTests, testsComplete
