import os
import tornado.ioloop
import tornado.web

UPLOAD_DIR = "images"
os.makedirs(UPLOAD_DIR, exist_ok=True)

CHUNK_SIZE = 64 * 1024  # 64 KB

class UploadPageHandler(tornado.web.RequestHandler):
    async def get(self):
        self.write("""
        <!DOCTYPE html>
        <html>
        <head>
            <title>Upload Image</title>
            <style>
                body { font-family: sans-serif; margin: 40px; }
                .box { border: 1px solid #ccc; padding: 20px; width: 300px; }
            </style>
        </head>
        <body>
            <h2>Upload an Image</h2>
            <div class="box">
                <form action="/upload" method="post" enctype="multipart/form-data">
                    <input type="file" name="file" required><br><br>
                    <button type="submit">Upload</button>
                </form>
            </div>
        </body>
        </html>
        """)

class UploadHandler(tornado.web.RequestHandler):
    async def post(self):
        """
        Accepts multipart/form-data with a file field named 'file'.
        """
        if "file" not in self.request.files:
            self.set_status(400)
            self.finish({"error": "Missing file field"})
            return

        fileinfo = self.request.files["file"][0]
        filename = fileinfo.filename
        body = fileinfo.body

        # Deterministic write
        path = os.path.join(UPLOAD_DIR, filename)
        with open(path, "wb") as f:
            f.write(body)

        self.finish({"status": "ok", "filename":path} )


# class StreamImageHandler(tornado.web.RequestHandler):
#     async def get(self, filename):
#         path = os.path.join(UPLOAD_DIR, filename)

#         if not os.path.exists(path):
#             self.set_status(404)
#             self.finish(f"Image {{path}} not found")
#             return

#         self.set_header("Content-Type", "image/jpeg")  # or detect dynamically
#         self.set_header("Content-Disposition", f"inline; filename={filename}")

#         with open(path, "rb") as f:
#             while True:
#                 chunk = f.read(CHUNK_SIZE)
#                 if not chunk:
#                     break
#                 await self.write(chunk)
#                 await self.flush()

#         self.finish()


def make_app():
    return tornado.web.Application([
        (r"/", UploadPageHandler),
        (r"/upload", UploadHandler),
        # (r"/stream/(.*)", StreamImageHandler),
        (r"/images/(.*)", tornado.web.StaticFileHandler, {"path": UPLOAD_DIR}),
    ],)


if __name__ == "__main__":
    app = make_app()
    app.listen(8888)
    print("Server running on http://localhost:8888")
    tornado.ioloop.IOLoop.current().start()