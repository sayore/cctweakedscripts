const chokidar = require('chokidar');
// Importing the required modules
const WebSocketServer = require('ws');
 
// Creating a new websocket server
const wss = new WebSocketServer.Server({ port: 8081 })

// One-liner for current directory


// Creating connection using websocket
wss.on("connection", (ws,req) => {
    async function choki(appname){
        chokidar.watch('./apps/'+appname).on('change', (path) => {
            console.log(path);
            ws.send(JSON.stringify({type:"update",path}))
            console.log("update");
        });
    }
    if(req.headers.app==null) ws.close();
    if(req.headers.app!=null)
    choki(req.headers.app);
    console.log("Client asks for watcher on app "+req.headers.app);
    ws.send(JSON.stringify({type:"keepalive",msg:"Hello!"}))
    // sending message
    ws.on("message", data => {
        console.log(`Client has sent us: ${data}`)
    });
    // handling what to do when clients disconnects from server
    ws.on("close", () => {
        console.log("the client has connected");
    });
    // handling client connection error
    ws.onerror = function () {
        console.log("Some Error occurred")
    }
});
console.log("The WebSocket server is running on port 8081");

