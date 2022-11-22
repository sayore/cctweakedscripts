
const express = require('express')
const app = express()

app.get('*', (req, res, next) => {
    console.log(req.url)
    next()
})

app.get('/', (req, res) => {
    console.log("Hello")
    res.send('Hello World!')
})

app.get('/apps/*', (req, res, next) => {
    next()
})

app.get('/libs/*', (req, res, next) => {
    next()
})

app.get('/eget.lua', (req, res, next) => {
    res.sendFile(__dirname + req.url)
})

app.use('/apps', express.static('apps'))
app.use('/libs', express.static('libs'))

module.exports = app