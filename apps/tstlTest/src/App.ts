/** 
 * @customName require
 * @noSelf
 */
declare const rq: <T>(name: string) => T;
import { Testing } from "./Testing";
import { DateTimeFormatter } from './commons/Time'
import { ColorPrinter } from './commons/ColorPrinter'
import { init, setInterval, setTimeout, start } from "./commons/setTimeout";
let running = true;

ColorPrinter.printlnColoredString(`&8 ### Imports done&0`);

ColorPrinter.printlnColoredString(`&8 ### Read Dir&0`);
// Function to list files in a directory
function listFilesInDirectory(directoryPath: string): void {
  const files: string[] = fs.list(directoryPath); // Assume fs.list() returns an array of strings

  if (files !== undefined) {
      for (const file of files) {
          const filePath = `${directoryPath}/${file}`; // Construct full file path

          ColorPrinter.printlnColoredString(`&3 File ->${file.toString().padEnd(20, ' ')}&0 ${fs.isDir(filePath) ? '&4 File&0' : '&5 File&0'}`)
      }
  } else {
      print(`Directory not found or empty: ${directoryPath}`);
  }
}

listFilesInDirectory('/eget/libs');

print("Requesting JSON")
const myson:json = rq<json>(''+'/eget/libs/json')  
ColorPrinter.printlnColoredString(`&8 ### Import JSON done&0`);

const utcTime = DateTimeFormatter.getCurrentUTCTime();


// Set the time zone offset to CEST (UTC+2)
DateTimeFormatter.setTimeZoneOffset(2 * 60 * 60 * 1000); // CEST: UTC+2

const germanFormattedCEST = DateTimeFormatter.formatGermanDateTime(utcTime);
const isoFormattedCEST = DateTimeFormatter.formatISO8601(utcTime);

ColorPrinter.printlnColoredString(`&8 ### Time checks&0`);

ColorPrinter.writeColumns("German | ISO &2" , germanFormattedCEST, isoFormattedCEST+"&0");

let shocked = new LuaTable();
shocked.set('a','hello');
shocked.set('b','hallow');

//declare const json: object;
declare const _G: LuaTable;

// Test

print(myson.encode(shocked))

let myarr = [1,2,3,4] 

myarr.forEach((value) => ColorPrinter.printColoredString(value.toString()+" "))

let fun = () => print('hello')

fun()

Testing.myfunc()

let testing = new Testing()

//ColorPrinter.printlnColoredString(`&8 ### Task Tests starting&0`);
/*
// Define the task queue to hold tasks
const taskQueue: { callback: () => void, executeAt: number, interval?: number }[] = [];

// Function to add a task to the queue
function addTask(callback: () => void, executeAt: number, interval?: number): void {
    taskQueue.push({ callback, executeAt, interval });
}

// Main loop to check and execute tasks every second
function mainLoop(): void {
    while (running) {
        const currentTime = os.clock();

        // Execute tasks that are due
        const tasksToExecute = taskQueue.filter(task => task.executeAt <= currentTime);
        tasksToExecute.forEach(task => {
            task.callback();

            // If it's a repeated task, reschedule it
            if (task.interval !== undefined) {
                task.executeAt = os.clock() + task.interval; // Reschedule for next execution
            } else {
                // Remove non-repeating task from the queue
                const index = taskQueue.indexOf(task);
                if (index !== -1) {
                    taskQueue.splice(index, 1);
                }
            }
        });

        // Sleep for 1 second before checking again
        os.sleep(1);
    }
}

// Example usage
function repeatedTask(): void {
    print("Repeated task executed at " + os.clock() + " " + taskQueue.length);
}

function oneTimeTask(): void {
    print("One-time task executed at " + os.clock()); 
}


function oneEndTest(): void {
    ColorPrinter.printlnColoredString(`&8 ### Time checks done&0`);
    ColorPrinter.printlnColoredString(`&8 ### Tests were all succseful. Exiting&0`);
    running = false;
}

let count=0
let beforeTestTime = DateTimeFormatter.getCurrentUTCTime();
function oneSecondEndTest(): void {
    ColorPrinter.printlnColoredString(`&8 ### ${(DateTimeFormatter.getCurrentUTCTime()-beforeTestTime)/1000} should be ${++count} seconds&0`);
}

ColorPrinter.printlnColoredString("&2start Timeout 3s&0")


// Schedule repeated task every 20 seconds 
print("Started 20 Second rep Task") 
addTask(repeatedTask, os.clock() + 3, 3);

// Schedule repeated task every 1 seconds 
print("Started 1 Second rep Task uwu")
addTask(oneSecondEndTest, os.clock() + 1, 1);

// Schedule one-time task after 5 seconds
print("Started 5 Second single Task")
addTask(oneTimeTask, os.clock() + 5);

// Schedule one-time task after 5 seconds
print("Started 30 Second single Task")
addTask(oneEndTest, os.clock() + 30);

// Start the main loop
mainLoop();
*/
init(()=>{
    print("Main loop done")
})

setTimeout(async() => ColorPrinter.printlnColoredString("&2Timeout 3s done&0"), 3000)
setInterval(async() => ColorPrinter.printlnColoredString("&Interval 5s exec&0"), 5000)

// Start handling events in the main loop
start()

// This point is unreachable in the current setup since handleEvents is an endless loop
print("Program finished")
