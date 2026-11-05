// Local helper server for the showcase reel encoder.
//   node tool/reel/server.js <framesDir> [port]
// Serves the encoder page, the rendered PNG frames (/frames/000123.png),
// reference videos (/ref/<name>) and accepts the finished MP4 (POST /save?name=).
const http = require("http");
const fs = require("fs");
const path = require("path");

const here = __dirname;
const frames = path.resolve(process.argv[2] || path.join(here, "frames"));
const port = Number(process.argv[3] || 8771);
const out = path.resolve(here, "..", "..", "build", "reel");
const refDir = path.join(process.env.USERPROFILE || "", "Downloads", "ZeepalmLabs_Videos");
const types = { ".html": "text/html", ".js": "text/javascript", ".png": "image/png", ".mp4": "video/mp4", ".json": "application/json" };

http
  .createServer((req, res) => {
    const url = new URL(req.url, "http://x");
    const send = (file) => {
      if (!fs.existsSync(file) || fs.statSync(file).isDirectory()) {
        res.writeHead(404);
        return res.end();
      }
      res.writeHead(200, { "Content-Type": types[path.extname(file)] || "application/octet-stream", "Cache-Control": "no-store" });
      fs.createReadStream(file).pipe(res);
    };
    if (req.method === "POST" && url.pathname === "/save") {
      fs.mkdirSync(out, { recursive: true });
      const name = path.basename(url.searchParams.get("name") || "reel.mp4");
      const file = path.join(out, name);
      const ws = fs.createWriteStream(file);
      req.pipe(ws);
      ws.on("finish", () => {
        console.log("saved " + file + " (" + fs.statSync(file).size + " bytes)");
        res.end(file);
      });
      return;
    }
    if (url.pathname === "/info") {
      const n = fs.existsSync(frames) ? fs.readdirSync(frames).filter((f) => f.endsWith(".png")).length : 0;
      res.writeHead(200, { "Content-Type": "application/json" });
      return res.end(JSON.stringify({ frames: n }));
    }
    if (url.pathname.startsWith("/frames/")) return send(path.join(frames, path.basename(url.pathname)));
    if (url.pathname.startsWith("/ref/")) return send(path.join(refDir, decodeURIComponent(path.basename(url.pathname))));
    if (url.pathname.startsWith("/out/")) return send(path.join(out, path.basename(url.pathname)));
    send(path.join(here, url.pathname === "/" ? "encoder.html" : path.basename(url.pathname)));
  })
  .listen(port, () => console.log("reel server on http://localhost:" + port + " frames=" + frames));
