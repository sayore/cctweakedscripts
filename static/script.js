function clog() {
    console.log()
}
let cache = {};
const exampleSocket = new WebSocket("ws://"+window.location.hostname,['watchCount']);
exampleSocket.onopen = (event) => {
    exampleSocket.send("Here's some text that the server is urgently awaiting!");

    if(localStorage.getItem("SID")==null)
    { exampleSocket.send(JSON.stringify({type:"register"})) }
    else {
        console.log(localStorage.getItem("SID"))
    }
    
};
exampleSocket.onmessage = (event) => {
    try{
        var parsedData=JSON.parse(event.data)
        console.log("WS","Loose Data",parsedData," [ is "+typeof(event.data)+", is parsed to JSON ]");
    } catch {
        var parsedData=event.data
        console.log("Loose Data",parsedData," [ is "+typeof(event.data)+", could not be parsed to JSON ]");
    }
    if(parsedData.type=="somethingChanged") {
        console.log(parsedData.data)
        //if(!!parsedData.data.name && !!cache[""+parsedData.data.name]) {
        //    cache[""+parsedData.data.name].count+=parsedData.count;
        //} else {
        //    cache[""+parsedData.data.name]={count:parsedData.count};
        //}
        items.innerText=""
        if(!!parsedData.data) {
            Object.entries(parsedData.data).forEach((v,k)=>{
                items.innerHTML+="<div style='display:flex;width:320px;margin:auto;'><div style='flex:1px;'>"+v[1]+"</div>" + "<div style=''>"+v[0]+"</div></div>"
            })
        }
    }
    if(parsedData.type=="registerAnswer") {
        exampleSocket.send(JSON.stringify({type:"getState"}))
        console.log(parsedData.id)
        localStorage.setItem("SID",parsedData.id)
    }
    if(parsedData.type=="getStateAnswer") {
        console.log(parsedData.id)
    }
}
/**
 * 
 * @param {CloseEvent} event 
 */
exampleSocket.onclose = (event)=>{
    console.log("Lost connection")
    window.location.href=window.location.href+" "
}