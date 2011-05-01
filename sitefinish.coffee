_ = require "underscore"
require("drews-mixins") _
fs = require "fs"
path = require "path"
express = require('express');
app = module.exports = express.createServer();
app.configure () ->
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(app.router);
  app.use(express.static(__dirname + '/public'));

app.configure 'development', () ->
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true })); 

app.configure 'production', () ->
  app.use(express.errorHandler()); 

# Routes
app.get /^\/\w+$/, (req, res) ->
  console.log "loading site"
  res.sendfile "public/index.html"

app.post "/:site", (req, res) ->
  saveTo = "/home/drew/sites/#{req.params.site}.sf.the.tl"
  if not path.existsSync saveTo
    fs.mkdir "", '0777', (err) ->
      if err
        console.log "there was an error"
        return res.send err, 500
      res.send {}
  else
    res.send {}



  


exports.app = app

if (!module.parent) 
  app.listen(8002);
  console.log("Express server listening on port %d", app.address().port);

