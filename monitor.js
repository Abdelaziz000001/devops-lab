// The watcher. Loaded first, before any app code, so nothing escapes it.
const KEY = "ingeniums_errors";

window.onerror = function (msg, src, line) {
  const list = JSON.parse(localStorage.getItem(KEY) || "[]");
  list.push({ msg: String(msg), src: String(src), line: line, ts: Date.now() });
  localStorage.setItem(KEY, JSON.stringify(list.slice(-500)));
};
