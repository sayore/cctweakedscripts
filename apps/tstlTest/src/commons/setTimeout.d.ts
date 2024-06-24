type Task = {
  type: "timeout" | "interval";
  timer: number;
  callback: () => void;
  delay?: number;
  interval?: number;
};

declare function init(mainLoop?: () => void): void;
declare function start(): void;
declare function setTimeout(callback: () => void, delay: number): Task;
declare function setInterval(callback: () => void, interval: number): Task;
declare function clearTimeout(task: Task): void;
declare function clearInterval(task: Task): void;

export { init, start, setTimeout, setInterval, clearTimeout, clearInterval }; 