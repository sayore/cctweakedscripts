const chokidar = require('chokidar');
const fs = require('fs')
// Importing the required modules
const WebSocketServer = require('ws');
let app = require('./main');

let server = require('http').createServer();
 
// Creating a new websocket server
const wss = new WebSocketServer.Server({ 
    server: server,
    perMessageDeflate: false
})
server.on('request', app);
// One-liner for current directory

function updateBuildVersionNumber(appname) {
    var versionNumber= -1;
    if(fs.existsSync('./apps/'+appname+"/version"))
    versionNumber = Number(fs.readFileSync('./apps/'+appname+"/version"))
    fs.writeFileSync('./apps/'+appname+"/version",(versionNumber+1).toString())
}

/** Update eGet's Version number */
async function updateEVN(){
    chokidar.watch('./eget.lua').on('change', (path) => {
        console.log('./eget.lua updated');
        var versionNumber= -1;
        if(fs.existsSync('./version'))
        versionNumber = Number(fs.readFileSync('./version'))
        fs.writeFileSync('./version',(versionNumber+1).toString())
    });
}

updateEVN(); 
var openedApps=[];

// Creating connection using websocket
wss.on("connection", (ws,req) => {
    async function choki(appname){
        chokidar.watch('./apps/'+appname+"/**/*.lua").on('change', (path) => {
            console.log("["+wss.clients.size+"]",path);
            updateBuildVersionNumber(appname)
            ws.send(JSON.stringify({type:"update",path}))
            console.log("["+wss.clients.size+"]","update");
        });
    }
    if(req.headers.app==null) ws.close();
    if(req.headers.app!=null && req.headers.method =="watch")
    choki(req.headers.app);
    console.log("["+wss.clients.size+"]","Client asks for watcher on app "+req.headers.app);
    ws.send(JSON.stringify({type:"keepalive",msg:"Hello!"}))
    // sending message
    ws.on("message", data => {
        console.log("["+wss.clients.size+"]",`Client has sent us: ${data}`)
        if(data == "exit") ws.close()
    });
    // handling what to do when clients disconnects from server
    ws.on("close", () => {
        console.log("["+wss.clients.size+"]","the client has disconnected");
        ws.close();
    });
    // handling client connection error
    ws.onerror = function () {
        console.log("["+wss.clients.size+"]","Some Error occurred")
    }
});

server.listen(80, function() {
    console.log(`uwu combo server on 80`);
});