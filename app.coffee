_ = require "underscore"
require("drews-mixins") _
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

exports.app = app

if (!module.parent) 
  app.listen(8002);
  console.log("Express server listening on port %d", app.address().port);

