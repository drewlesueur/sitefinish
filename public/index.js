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
      var keys;
      if (this.state === "input" && e.keyCode !== 27) {
        return;
      }
      keys = {
        78: "n",
        8: "delete",
        46: "delete",
        27: "esc"
      };
      console.log(e.keyCode);
      if (e.keyCode in keys) {
        e.preventDefault();
        this.trigger("key", keys[e.keyCode]);
        return false;
      }
    }, this));
  }
  SiteFinishView.prototype.addBox = function(box) {
    this.el.append(box.view.el);
    box.view.el.bind("dblclick", __bind(function() {
      return this.trigger("boxdblclick", box);
    }, this));
    return box.view.el.bind("mousedown", __bind(function() {
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
    this.removeBox = __bind(this.removeBox, this);;
    this.saveBoxHtml = __bind(this.saveBoxHtml, this);;
    this.editBoxText = __bind(this.editBoxText, this);;
    this.key_esc = __bind(this.key_esc, this);;
    this.key_n = __bind(this.key_n, this);;
    this.key_delete = __bind(this.key_delete, this);;    this.boxes = new Boxes;
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
      var theKey;
      theKey = "key_" + key;
      if (theKey in this) {
        return this[theKey]();
      }
    }, this));
    this.view.bind("boxdblclick", __bind(function(box) {
      return this.editBoxText(box);
    }, this));
    this.view.bind("boxclick", __bind(function(box) {
      return this.setCurrentBox(box);
    }, this));
    this.siteFinishController = new SiteFinishController;
    Backbone.history.start();
  }
  SiteFinishPresenter.prototype.key_delete = function() {
    return this.removeBox();
  };
  SiteFinishPresenter.prototype.key_n = function() {
    return this.addBox();
  };
  SiteFinishPresenter.prototype.key_esc = function() {
    return this.saveBoxHtml();
  };
  SiteFinishPresenter.prototype.editBoxText = function(box) {
    box || (box = this.currentBox);
    this.setCurrentBox(box);
    this.view.state = "input";
    box.view.el.dragsimple("destroy");
    box.view.textify();
    return box.view.el.find("textarea").blur(__bind(function() {
      return this.saveBoxHtml(box);
    }, this));
  };
  SiteFinishPresenter.prototype.saveBoxHtml = function(box) {
    box || (box = this.currentBox);
    if (this.view.state === "input") {
      box.view.saveHtml();
      this.view.state = "not input";
      return box.view.el.dragsimple();
    }
  };
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
    this.setCurrentBox(box);
    done(null, this.currentBox);
    return this.currentBox;
  };
  SiteFinishPresenter.prototype.setCurrentBox = function(box) {
    if (this.view.state === "input") {
      return false;
    }
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
    this.saveHtml = __bind(this.saveHtml, this);;
    this.textify = __bind(this.textify, this);;    BoxView.__super__.constructor.apply(this, arguments);
    this.type = this.model.get('type') || "div";
    this.el = $(this.make(this.type));
    this.el.addClass("box");
    this.el.attr("id", "box" + (++boxCount));
    this.el.css({
      top: "50px",
      left: "50px"
    });
    this.el.dragsimple();
  }
  BoxView.prototype.textify = function() {
    this.html = this.el.html();
    return this.el.html("<textarea>" + this.html + "</textarea>");
  };
  BoxView.prototype.saveHtml = function() {
    this.html = this.el.find("textarea").val();
    return this.el.html(this.html);
  };
  return BoxView;
})();