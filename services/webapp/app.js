#!/usr/bin/env node

const path = require('path');
const express = require('express');

const app = express();

// Configure express to use ejs as template engine
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, "views"));

// Determine port number to listen on
const port = process.env["PORT"] || 3000;

// Dynamic URL routes

app.get('/', function(req, res) {
    res.render('index', { virtualHost: req.hostname });
});

// Start the app server
app.listen(port);
