var runTest, runTests, server, test, tests, testsComplete;
var __slice = Array.prototype.slice;
_.assertClose = function(val, otherVal, within, message) {
  if (Math.abs(otherVal - val) <= within) {
    return _.assertPass(val, otherVal, message, "within " + within + " of", _.assertClose);
  } else {
    return _.assertFail(val, otherVal, message, "within " + within + " of", _.assertClose);
  }
};
_.assertSee = function(text, message) {
  if ($("body:contains('" + text + "'):visible").length !== 0) {
    return _.assertPass(text, "[html body]", message, "see", _.assertSee);
  } else {
    return _.assertFail(text, "[html body]", message, "see", _.assertSee);
  }
};
_.assertNoSee = function(text, message) {
  if ($("body:contains('" + text + "'):visible").length !== 0) {
    return _.assertFail(text, "not that!", message, "see", _.assertSee);
  } else {
    return _.assertPass(text, "[html body]", message, "see", _.assertSee);
  }
};
tests = {};
test = function(title, func) {
  return tests[title] = func;
};
test("Title should be SiteFinish", function(done) {
  _.assertEqual(document.title, "SiteFinish", "Title should equali SiteFinsh");
  return done();
});
test("adding a box to the screen", function(done) {
  app.view.trigger("addboxclick");
  _.assertEqual($('#box1').length, 1, "One box should be on the screen");
  return done();
});
test("should be able to delete a specific box", function(done) {
  var box1, box2, box3;
  box1 = app.addBox();
  box2 = app.addBox();
  box3 = app.addBox();
  app.view.trigger("boxclick", box2);
  app.view.trigger("key", "delete");
  _.assertOk(!(app.boxes.include(box2)), "box2 is gone");
  _.assertOk(app.boxes.include(box1), "box1 is there");
  _.assertOk(app.boxes.include(box3), "box3 is there");
  app.removeBox(box1);
  app.removeBox(box3);
  return done();
});
test("hitting n should add new box", function(done) {
  var newLength, oldLength;
  oldLength = app.boxes.length;
  app.view.trigger("key", "n");
  newLength = app.boxes.length;
  _.assertEqual(newLength, oldLength + 1, "n should add box");
  app.removeBox();
  return done();
});
test("Should be able to delete a box", function(done) {
  app.view.trigger("key", "delete");
  _.assertEqual($('#box1').length, 0, "The added box should be gone");
  return done();
});
test("should be able to edit the text of a box", function(done) {
  var box;
  box = app.addBox();
  _.assertOk(box.view.el.hasClass("dragsimple"));
  app.view.trigger("boxdblclick", box);
  _.assertOk(!box.view.el.hasClass("dragsimple"), "is draggable");
  _.assertOk(box.view.el.hasClass("selected"), "is selected");
  box.view.el.find("textarea").val("test text");
  app.view.trigger("key", "esc");
  _.assertEqual(box.view.el.text(), "test text", "edit success");
  app.editBoxText(box);
  box.view.el.find("textarea").val("hazte valer").blur();
  _.assertEqual(box.view.el.text(), "hazte valer", "edit success on blur");
  return done();
});
test("selected box shold be highlighted", function(done) {
  return done();
});
server = function(method, callback) {
  var args, _ref;
  if (_.isArray(method)) {
    _ref = method, method = _ref[0], args = 2 <= _ref.length ? __slice.call(_ref, 1) : [];
  }
  return $.ajax({
    url: "/" + method,
    type: "POST",
    contentType: 'application/json',
    data: args,
    dataType: 'json',
    processData: false,
    success: function(data) {
      return callback(null, data);
    },
    error: function(data) {
      return callback(data);
    }
  });
};
testsComplete = function(err, results) {
  results = "" + (_.getAssertCount()) + " tests ran\n" + (_.getPassCount()) + " tests passed\n" + (_.getFailCount()) + " tests failed";
  $('#test-text').html(results.replace(/\n/g, "<br />"));
  return console.log(results);
};
runTest = function(testName) {
  testName = testName.replace(/_/g, " ");
  return _.wait(1000, function() {
    return _.series([tests[testName]], testsComplete);
  });
};
runTests = function() {
  return _.wait(1000, function() {
    var newTests;
    newTests = {};
    _.each(tests, function(test, key) {
      return newTests[key] = function(done) {
        console.log(key);
        return test(done);
      };
    });
    return _.series(newTests, testsComplete);
  });
};