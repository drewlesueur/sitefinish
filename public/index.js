var Box, BoxView, Boxes, SiteFinishController, SiteFinishPresenter, SiteFinishView, boxCount, liteAlert;
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
  for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
  function ctor() { this.constructor = child; }
  ctor.prototype = parent.prototype;
  child.prototype = new ctor;
  child.__super__ = parent.prototype;
  return child;
};
_.each(['s'], function(method) {
  return Backbone.Collection.prototype[method] = function() {
    return _[method].apply(_, [this.models].concat(_.toArray(arguments)));
  };
});
liteAlert = function(message) {
  return console.log(message);
};
SiteFinishView = (function() {
  __extends(SiteFinishView, Backbone.View);
  function SiteFinishView() {
    this.setCurrentBox = __bind(this.setCurrentBox, this);;
    this.removeBox = __bind(this.removeBox, this);;
    this.addBox = __bind(this.addBox, this);;    this.el = $('#page');
    SiteFinishView.__super__.constructor.apply(this, arguments);
    $('#box').click(__bind(function(e) {
      e.preventDefault();
      return this.trigger("addboxclick");
    }, this));
    $(document.body).keydown(__bind(function(e) {
      var _ref;
      console.log(e.keyCode);
      if ((_ref = e.keyCode) === 8 || _ref === 46) {
        e.preventDefault();
        this.trigger("key", "delete");
        return false;
      }
    }, this));
  }
  SiteFinishView.prototype.addBox = function(box) {
    this.el.append(box.view.el);
    box.view.el.bind("dblclick", __bind(function() {
      return this.trigger("boxdblclick", box);
    }, this));
    return box.view.el.bind("click", __bind(function() {
      return this.trigger("boxclick", box);
    }, this));
  };
  SiteFinishView.prototype.removeBox = function(box) {
    return box.view.el.remove();
  };
  SiteFinishView.prototype.setCurrentBox = function(box) {
    $('.box.selected').removeClass("selected");
    return box.view.el.addClass("selected");
  };
  return SiteFinishView;
})();
SiteFinishController = (function() {
  __extends(SiteFinishController, Backbone.Controller);
  function SiteFinishController() {
    this.test = __bind(this.test, this);;
    this.tests = __bind(this.tests, this);;    SiteFinishController.__super__.constructor.apply(this, arguments);
  }
  SiteFinishController.prototype.routes = {
    "test": "test",
    "tests/:test": "tests"
  };
  SiteFinishController.prototype.tests = function(test) {
    return runTest(test);
  };
  SiteFinishController.prototype.test = function() {
    return runTests();
  };
  return SiteFinishController;
})();
SiteFinishPresenter = (function() {
  function SiteFinishPresenter() {
    this.setCurrentBox = __bind(this.setCurrentBox, this);;
    this.addBox = __bind(this.addBox, this);;
    this.removeBox = __bind(this.removeBox, this);;    this.boxes = new Boxes;
    this.boxes.bind("add", __bind(function(box, boxes) {
      return this.view.addBox(box);
    }, this));
    this.boxes.bind("remove", __bind(function(box, boxes) {
      return this.view.removeBox(box);
    }, this));
    this.view = new SiteFinishView();
    this.view.bind("addboxclick", __bind(function(done) {
      return this.addBox(done);
    }, this));
    this.view.bind("key", __bind(function(key) {
      if (key === "delete") {
        console.log("trying to delete");
        return this.removeBox();
      }
    }, this));
    this.view.bind("boxdblclick", __bind(function(box) {
      return box.view.textify();
    }, this));
    this.view.bind("boxclick", __bind(function(box) {
      return this.setCurrentBox(box);
    }, this));
    this.siteFinishController = new SiteFinishController;
    Backbone.history.start();
  }
  SiteFinishPresenter.prototype.removeBox = function(box) {
    var index, newCurrentBox, oldBox;
    box || (box = this.currentBox);
    if (!box) {
      return;
    }
    index = this.boxes.indexOf(box);
    this.boxes.remove(box);
    oldBox = box;
    newCurrentBox = app.boxes.s(index - 1, 1)[0];
    console.log(newCurrentBox);
    if (newCurrentBox) {
      this.setCurrentBox(newCurrentBox);
    }
    return oldBox;
  };
  SiteFinishPresenter.prototype.addBox = function(done) {
    var box;
    if (done == null) {
      done = function() {};
    }
    done || (done = function() {});
    box = new Box({
      type: "div"
    });
    box.view = new BoxView({
      model: box
    });
    this.boxes.add(box);
    this.currentBox = box;
    done(null, this.currentBox);
    return this.currentBox;
  };
  SiteFinishPresenter.prototype.setCurrentBox = function(box) {
    this.view.setCurrentBox(box);
    return this.currentBox = box;
  };
  return SiteFinishPresenter;
})();
Boxes = (function() {
  __extends(Boxes, Backbone.Collection);
  Boxes.prototype.url = "/boxes";
  Boxes.prototype.model = Box;
  function Boxes() {
    Boxes.__super__.constructor.apply(this, arguments);
  }
  return Boxes;
})();
Box = (function() {
  __extends(Box, Backbone.Model);
  function Box() {
    Box.__super__.constructor.apply(this, arguments);
  }
  return Box;
})();
boxCount = 0;
BoxView = (function() {
  __extends(BoxView, Backbone.View);
  function BoxView() {
    this.textify = __bind(this.textify, this);;    BoxView.__super__.constructor.apply(this, arguments);
    this.type = this.model.get('type') || "div";
    this.el = $(this.make(this.type));
    this.el.addClass("box");
    this.el.attr("id", "box" + (++boxCount));
    this.el.css({
      top: "200px",
      left: "200px"
    });
    this.el.dragsimple();
  }
  BoxView.prototype.textify = function() {
    this.html = this.el.html();
    return this.el.html("<textarea>" + html + "</textarea>");
  };
  return BoxView;
})();