import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";

const cdp = process.env.VERIFY_BLOG_CDP;
const origin = process.env.VERIFY_BLOG_ORIGIN;
const scratch = process.env.VERIFY_BLOG_SCRATCH;
const [command, ...args] = process.argv.slice(2);

if (!cdp || !origin || !scratch || !command) {
  console.error("usage: drive.mjs <open|text|attr|count|hrefs|click|screenshot> ...");
  process.exit(2);
}

const fail = (message) => {
  console.error(message);
  process.exit(1);
};

const version = await fetch(`http://127.0.0.1:${cdp}/json/version`);
if (!version.ok) fail(`cdp version failed: ${version.status}`);
const browser = await version.json();
const ws = new WebSocket(browser.webSocketDebuggerUrl);
await new Promise((resolve, reject) => {
  ws.addEventListener("open", resolve, { once: true });
  ws.addEventListener("error", () => reject(new Error("cdp websocket failed")), { once: true });
});

let nextId = 0;
const pending = new Map();
const listeners = [];

ws.addEventListener("message", (event) => {
  const message = JSON.parse(event.data);
  if (message.id && pending.has(message.id)) {
    const { resolve, reject } = pending.get(message.id);
    pending.delete(message.id);
    if (message.error) reject(new Error(message.error.message));
    else resolve(message.result ?? {});
    return;
  }
  if (message.method) {
    for (const listener of listeners) listener(message);
  }
});

const send = (method, params = {}, sessionId) => {
  const id = ++nextId;
  return new Promise((resolve, reject) => {
    pending.set(id, { resolve, reject });
    const payload = { id, method, params };
    if (sessionId) payload.sessionId = sessionId;
    ws.send(JSON.stringify(payload));
  });
};

const deadline = setTimeout(() => fail("drive timed out"), 30000);

const targetFile = join(scratch, "target.id");
const listed = await (await fetch(`http://127.0.0.1:${cdp}/json/list`)).json();
let targetId = existsSync(targetFile) ? readFileSync(targetFile, "utf8").trim() : "";
if (!listed.some((target) => target.id === targetId)) {
  ({ targetId } = await send("Target.createTarget", { url: "about:blank" }));
  writeFileSync(targetFile, targetId);
}
const { sessionId } = await send("Target.attachToTarget", { targetId, flatten: true });
const call = (method, params) => send(method, params, sessionId);

const evaluate = async (expression) => {
  const result = await call("Runtime.evaluate", {
    expression,
    returnByValue: true,
    awaitPromise: true,
  });
  if (result.exceptionDetails) {
    const detail = result.exceptionDetails.exception?.description || result.exceptionDetails.text;
    fail(detail || "page evaluate failed");
  }
  return result.result.value;
};

await call("Page.enable");
await call("Network.enable");
await call("Network.setBypassServiceWorker", { bypass: true });
await call("Emulation.setDeviceMetricsOverride", {
  width: 1280,
  height: 800,
  deviceScaleFactor: 1,
  mobile: false,
});

let documentStatus = "";
listeners.push((message) => {
  if (message.sessionId !== sessionId) return;
  if (message.method !== "Network.responseReceived") return;
  if (message.params.type !== "Document") return;
  documentStatus = message.params.response.status;
});

const waitForLoad = () =>
  new Promise((resolve) => {
    const timer = setTimeout(() => resolve(false), 15000);
    const onMessage = (message) => {
      if (message.sessionId !== sessionId || message.method !== "Page.loadEventFired") return;
      clearTimeout(timer);
      listeners.splice(listeners.indexOf(onMessage), 1);
      resolve(true);
    };
    listeners.push(onMessage);
  });

const pageFacts = () =>
  evaluate(`({
    href: location.href,
    path: location.pathname,
    title: document.title,
    main: Boolean(document.querySelector("main#main-content"))
  })`);

const printPage = async () => {
  const page = await pageFacts();
  if (!page.main) fail(`no main#main-content at ${page.href}`);
  console.log(`status: ${documentStatus}`);
  console.log(`url: ${page.href}`);
  console.log(`path: ${page.path}`);
  console.log(`title: ${page.title}`);
};

const queryExpression = (selector, body) => `(() => {
  const nodes = [...document.querySelectorAll(${JSON.stringify(selector)})];
  ${body}
})()`;

if (command === "open") {
  const path = args[0];
  if (!path || !path.startsWith("/")) fail("open requires a path starting with /");
  const loaded = waitForLoad();
  await call("Page.navigate", { url: `${origin}${path}` });
  if (!(await loaded)) fail(`load timed out for ${path}`);
  await printPage();
} else if (command === "text") {
  const selector = args[0];
  if (!selector) fail("text requires a selector");
  const found = await evaluate(queryExpression(selector, `
    if (nodes.length !== 1) return { ok: false, count: nodes.length };
    return { ok: true, text: nodes[0].textContent.replace(/\\s+/g, " ").trim() };
  `));
  if (!found.ok) fail(`${selector} matched ${found.count} elements`);
  console.log(found.text);
} else if (command === "attr") {
  const [selector, name] = args;
  if (!selector || !name) fail("attr requires a selector and an attribute name");
  const found = await evaluate(queryExpression(selector, `
    if (nodes.length !== 1) return { ok: false, count: nodes.length };
    return { ok: true, value: nodes[0].getAttribute(${JSON.stringify(name)}) };
  `));
  if (!found.ok) fail(`${selector} matched ${found.count} elements`);
  if (found.value === null) fail(`${selector} has no ${name}`);
  console.log(found.value);
} else if (command === "count") {
  const selector = args[0];
  if (!selector) fail("count requires a selector");
  const count = await evaluate(`document.querySelectorAll(${JSON.stringify(selector)}).length`);
  console.log(count);
} else if (command === "hrefs") {
  const selector = args[0];
  if (!selector) fail("hrefs requires a selector");
  const rows = await evaluate(queryExpression(selector, `
    return nodes.map((node) => {
      const href = node.getAttribute("href") || "";
      const path = new URL(href, location.href).pathname;
      const text = node.textContent.replace(/\\s+/g, " ").trim();
      return path + "\\t" + text;
    });
  `));
  if (rows.length === 0) fail(`${selector} matched 0 elements`);
  console.log(rows.join("\n"));
} else if (command === "click") {
  const selector = args[0];
  if (!selector) fail("click requires a selector");
  const before = await evaluate("location.href");
  const loaded = waitForLoad();
  const found = await evaluate(queryExpression(selector, `
    if (nodes.length !== 1) return { ok: false, count: nodes.length };
    nodes[0].click();
    return { ok: true };
  `));
  if (!found.ok) fail(`${selector} matched ${found.count} elements`);
  const started = Date.now();
  let moved = false;
  while (Date.now() - started < 8000) {
    const href = await evaluate("location.href");
    if (href !== before) {
      moved = true;
      break;
    }
    await new Promise((resolve) => setTimeout(resolve, 50));
  }
  if (!moved) fail(`${selector} did not change the url`);
  const after = new URL(await evaluate("location.href"));
  const previous = new URL(before);
  if (after.pathname !== previous.pathname) await loaded;
  await printPage();
} else if (command === "screenshot") {
  let width = 0;
  let height = 0;
  let out = "";
  for (let i = 0; i < args.length; i += 1) {
    if (args[i] === "--width") width = Number(args[++i]);
    else if (args[i] === "--height") height = Number(args[++i]);
    else if (args[i] === "--out") out = args[++i];
    else fail(`unknown screenshot argument: ${args[i]}`);
  }
  if (!width || !height || !out) fail("screenshot requires --width, --height, and --out");
  await call("Emulation.setDeviceMetricsOverride", {
    width,
    height,
    deviceScaleFactor: 1,
    mobile: width < 768,
  });
  await evaluate("document.fonts.ready");
  await evaluate("new Promise((resolve) => requestAnimationFrame(() => requestAnimationFrame(resolve)))");
  const shot = await call("Page.captureScreenshot", { format: "png" });
  mkdirSync(dirname(out), { recursive: true });
  writeFileSync(out, Buffer.from(shot.data, "base64"));
  console.log(`screenshot: ${out}`);
  console.log(`viewport: ${width}x${height}`);
} else {
  fail(`unknown drive command: ${command}`);
}

clearTimeout(deadline);
ws.close();
