import { readdir, readdirSync, readFileSync } from 'fs'
import express from 'express'
let app = express()
import path from 'node:path';
import pug from 'pug';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

console.log(__dirname)

app.set('view engine', 'pug');

app.get('*', (req, res, next) => {
    console.log(req.url)
    next()
})

app.get('/', (req, res) => {
    console.log(path.join(__dirname,"./static/index.pug"))
    res.render(path.join(__dirname,"./static/index.pug"))
})

app.get('/api/getapps', async (req, res) => {
    let appList = readdirSync(path.join(__dirname,"./apps"))

    res.send(appList)
    res.end()
})

app.get('/apps/*', (req, res, next) => {
    next()
})

app.get('/libs/*', (req, res, next) => {
    next()
})

app.get('/eget.lua', (req, res, next) => {
    res.setHeader('Content-Type','text/plain');
    res.send(readFileSync(path.join(__dirname,"./eget.lua"),{encoding:'utf-8'}))
    res.end()
})

app.get('/install.lua', (req, res, next) => {
    res.setHeader('Content-Type','text/plain; charset=utf-8');

    let toSend = loadLibsBlindly("./libs/");
    toSend+=removeRequire(readFileSync(path.join(__dirname,"./install.lua"),{encoding:'utf-8'}))
    
    res.send(addLineNumbers(toSend))
    res.end()
})

app.use('/apps', express.static('apps'))
app.use('/libs', express.static('libs'))
//app.use('/', express.static('static'))

//app.all('/*',async (req, res, next) => {
//    res.send(`{"msg":"Fuck off m8y"}`)
//    res.statusCode=404
//    res.end()
//})



function loadLibsBlindly(orgRelativePath) {
    var toSend = "";
    var dirs = readdirSync(path.join(__dirname, orgRelativePath));
    console.log("Loaded libs: [ "+dirs.join(", ") + " ]")
    dirs.forEach(element => {
        var file = readFileSync(path.join(__dirname, orgRelativePath, element), { encoding: 'utf-8' })
            .toString()

        file = removeModuleReturn(file);
        file = removeRequire(file)
        toSend+=file
    });
    
    return toSend;
}

function addLineNumbers(str) {
    var split = str.split('\n');
    var retval=""
    split.forEach((v,i)=>retval+="\n--[[ "+i+": ]]"+v)
    return retval
}

function removeRequire(str) {
    return str.split("\n").map((v, i) => {
        if (v.includes('require'))
            return "-- REMOVED REQUIRE " + v;
        else
            return v;
    }).join('\r\n')
}

function removeModuleReturn(str) {
    var split = str.split('return');
    split.pop();
    let strF = split.join('return')
    return strF;
}

export default app