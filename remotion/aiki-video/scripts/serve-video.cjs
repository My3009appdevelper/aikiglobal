const http = require("http");
const fs = require("fs");
const path = require("path");

const filePath = path.join(__dirname, "..", "out", "AikiDosCaras.mp4");
const videoPath = "/AikiDosCaras.mp4";
const port = Number(process.env.AIKI_VIDEO_PORT || 8080);
const page = `<!doctype html>
<html lang="es">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Aiki · Dos caras</title>
    <style>
      :root { color-scheme: light; font-family: Inter, system-ui, sans-serif; }
      * { box-sizing: border-box; }
      body {
        margin: 0;
        min-height: 100svh;
        display: grid;
        place-items: center;
        padding: 20px;
        background: linear-gradient(180deg, #d8b879 0%, #f7f0e7 58%, #fffaf2 100%);
      }
      main { width: min(100%, 520px); }
      video {
        display: block;
        width: 100%;
        max-height: calc(100svh - 40px);
        object-fit: contain;
        border-radius: 22px;
        background: #241716;
        box-shadow: 0 24px 70px rgba(48, 25, 22, 0.28);
      }
    </style>
  </head>
  <body>
    <main>
      <video controls playsinline preload="metadata" src="${videoPath}"></video>
    </main>
  </body>
</html>`;

const server = http.createServer((request, response) => {
  const requestPath = new URL(request.url, "http://localhost").pathname;

  if (requestPath === "/") {
    response.writeHead(200, {
      "Content-Type": "text/html; charset=utf-8",
      "Cache-Control": "no-cache",
    });
    response.end(page);
    return;
  }

  if (requestPath !== videoPath) {
    response.writeHead(404);
    response.end("Not found");
    return;
  }

  fs.stat(filePath, (statError, stats) => {
    if (statError) {
      response.writeHead(404);
      response.end("Video not found");
      return;
    }

    const baseHeaders = {
      "Content-Type": "video/mp4",
      "Accept-Ranges": "bytes",
      "Cache-Control": "no-cache",
    };
    const range = request.headers.range;

    if (!range) {
      response.writeHead(200, { ...baseHeaders, "Content-Length": stats.size });
      fs.createReadStream(filePath).pipe(response);
      return;
    }

    const match = /bytes=(\d*)-(\d*)/.exec(range);
    if (!match) {
      response.writeHead(416, { "Content-Range": `bytes */${stats.size}` });
      response.end();
      return;
    }

    const start = match[1] ? Number(match[1]) : Math.max(0, stats.size - Number(match[2] || 0));
    const end = match[2] ? Number(match[2]) : stats.size - 1;

    if (start > end || start >= stats.size) {
      response.writeHead(416, { "Content-Range": `bytes */${stats.size}` });
      response.end();
      return;
    }

    response.writeHead(206, {
      ...baseHeaders,
      "Content-Length": end - start + 1,
      "Content-Range": `bytes ${start}-${end}/${stats.size}`,
    });
    fs.createReadStream(filePath, { start, end }).pipe(response);
  });
});

server.listen(port, "0.0.0.0", () => {
  console.log(`Aiki video server listening on port ${port}`);
});
