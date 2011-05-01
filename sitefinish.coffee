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
  console.log "saving #{req.params.site}"
  saveTo = "/home/drew/sites/#{req.params.site}.sf.the.tl"
  console.log saveTo
  if not path.existsSync saveTo
    console.log "it doesnt exist"
    fs.mkdir saveTo, '0777', (err) ->
      if err
        console.log "there was an error"
        return res.send err, 500
  console.log "going to save the file"
  req.body.page ||= "hello world"
  console.log "the data is #{req.body.page}"
  content = """
    <!doctype html>
    <html>
    <head>
    <style>
      .box {
        position: absolute;
      }
    </style>
    </head>
    <body>
      #{req.body.page}
    </body>
    </html>
  """

  fs.writeFile "#{saveTo}/index.html", content, (err) ->
    if err then return res.send err, 500 
    res.send {}


  


exports.app = app

if (!module.parent) 
  app.listen(8002);
  console.log("Express server listening on port %d", app.address().port);

