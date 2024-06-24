import chokidar from 'chokidar';
import fs from 'fs'
import crypto from 'crypto'
// Importing the required modules
import * as ws from 'ws';

import app from './main.js';
import http from 'http';


let server = http.createServer();

function uuidv4() {
    return ([1e7]+-1e3+-4e3+-8e3+-1e11).replace(/[018]/g, c =>
      (c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> c / 4).toString(16)
    );
  }

// Creating a new websocket server
const wss = new ws.WebSocketServer({ 
    server: server,
    perMessageDeflate: false
})
server.on('request', app);
// One-liner for current directory

function updateBuildVersionNumber(appname) {
    let versionNumber= -1;
    if(fs.existsSync('./apps/'+appname+"/version"))
    versionNumber = Number(fs.readFileSync('./apps/'+appname+"/version"))
    fs.writeFileSync('./apps/'+appname+"/version",(versionNumber+1).toString())
}

/** Update eGet's Version number */
async function updateEVN(){
    chokidar.watch('./eget.lua').on('change', (path) => {
        console.log('./eget.lua updated');
        let versionNumber= -1;
        if(fs.existsSync('./version'))
        versionNumber = Number(fs.readFileSync('./version'))
        fs.writeFileSync('./version',(versionNumber+1).toString())
    });
}

updateEVN(); 
let countWatchers = [];

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
    //if(req.headers.app==null) ws.close();
    if(req.headers.app!=null && req.headers.method =="watch")
    choki(req.headers.app);
    console.log("["+wss.clients.size+"]","Client asks for watcher on app "+req.headers.app);
    ws.send(JSON.stringify({type:"keepalive",msg:"Hello!"}))
    // sending message
    if(req.headers['sec-websocket-protocol']=="watchCount"){
        countWatchers.push(ws);
    }
    ws.on("message", data => {
        if(data == "exit") ws.close()
        try{
            if(typeof(data)=="object") data = data.toString()
            let parsedData=JSON.parse(data)
            console.log("WS","Loose Data ",parsedData,"[ is "+typeof(data)+", is parsed to JSON ]");
        } catch {
            console.log("Loose Data",data," [ is "+typeof(data)+", could not be parsed to JSON ]");
            let parsedData=data
            if(!parsedData.type) return;
        }
        //Send for WebApp Register
        if(parsedData.type=="register") {
            ws.id = crypto.randomUUID();
            ws.send(JSON.stringify({type:"registerAnswer",id:ws.id}))
        }
        //Send for WebApp Check Sessions State
        if(parsedData.type=="getState") {
            ws.send(JSON.stringify({type:"getStateAnswer",id:ws.id}));
        }
        //Send from a Turtle or PC, not implemeneted there yet
        if(parsedData.type=="sendCountData") {
            countWatchers.forEach(wse => {
                wse.send(JSON.stringify({type:"somethingChanged",data:parsedData.data}));
            });
            ws.close()
        }
        
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

server.listen(1380, function() {
    console.log(`uwu combo server on 1380`);
});