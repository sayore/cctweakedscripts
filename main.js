import { readdir, readdirSync, readFileSync } from 'fs'
import express from 'express'
let app = express()
import path from 'node:path';
import pug from 'pug';
import fs from 'fs'
import { fileURLToPath } from 'node:url';
import bodyParser from 'body-parser';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

console.log(__dirname)

if (!fs.existsSync("./upload")) {
    fs.mkdirSync("./upload");
}

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

app.set('view engine', 'pug');

app.get('*', (req, res, next) => {
    console.log(req.ip + ": " + req.url)
    next()
})

// Route to handle file append based on timestamp
app.post('/upload/:scriptname', (req, res) => {
    const scriptname = req.params.scriptname;
    const filePath = path.join("./upload", `${scriptname}.txt`);
    console.log(req.params)

    // Append file content
    fs.appendFile(filePath, req.body + '\n', err => {
        if (err) {
            console.error('Error appending to file:', err);
            res.status(500).send('Error appending to file');
        } else {
            console.log('Data appended to file successfully:', filePath);
            res.send('Data appended to file successfully');
        }
    });
});

app.get('/', (req, res) => {
    console.log(path.join(__dirname,"./static/index.pug"))
    res.render(path.join(__dirname,"./static/index.pug"))
})

app.get('/live', (req, res) => {
    res.send(true)
    res.end();
})

app.get('/api/getapps', async (req, res) => {
    let appList = readdirSync(path.join(__dirname,"./apps"))

    res.send(appList)
    res.end()
})

app.get('/api/getappversion/:app', async (req, res) => {
    //get app version
    //check if app exists
    //read version
    let appVersion
    if(!fs.existsSync(path.join(__dirname,"./apps/"+req.params.app))){
        appVersion = fs.readFileSync(path.join(__dirname,"./apps/"+req.params.app+"/version"),{encoding:'utf-8'})
    } else {
        appVersion = -1
    }
    
    res.send(appVersion)
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

// Recursively find all files in a directory
function findFiles(dir, baseDir = dir) {
    let results = [];
    let list = fs.readdirSync(dir);
    list.forEach((file) => {
        let fullPath = path.join(dir, file);
        let relativePath = path.relative(baseDir, fullPath).split(path.sep).join('/');
        try {
            let stat = fs.lstatSync(fullPath);
            if (stat.isDirectory()) {
                results = results.concat(findFiles(fullPath, baseDir));
            } else {
                results.push(relativePath);
            }
        } catch (e) {
            results.push(relativePath);
        }
    });
    return results;
}

app.get('/dirAsList/*', (req, res) => {
    // Create a list of files in the directory
    // Guard against invalid paths, only make /apps/* requests, deny anything else
    let pathParts = req.path.split('/');
    pathParts.shift();
    pathParts.shift();

    if (pathParts[0] === 'apps') {
        const targetDir = path.join(__dirname, './apps/', pathParts.slice(1).join('/'));
        if (fs.existsSync(targetDir) && fs.lstatSync(targetDir).isDirectory()) {
            let appList = findFiles(targetDir);
            res.send(appList);
        } else {
            res.status(404).send("Directory not found");
        }
    } else {
        res.status(400).send("Invalid path (" + pathParts + ")");
    }
});

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