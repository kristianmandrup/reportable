var FileUploader = {

  onFilesDoUpload: function(document, server_path) {
    document.querySelector('input[type="file"]').addEventListener('change', function(e) {
        XhrFiler.uploadFiles(server_path, this.files);
    }, false);
  },

  // requires Blobber from html5.blop_uploader.js
  onFilesDoChunkUpload: function(document, server_path) {
    document.querySelector('input[type="file"]').addEventListener('change', function(e) {
      var blob = this.files[0];

      const BYTES_PER_CHUNK = 1024 * 1024; // 1MB chunk sizes.
      const SIZE = blob.size;

      var start = 0;
      var end = BYTES_PER_CHUNK;

      while(start < SIZE) {

        // Note: blob.slice has changed semantics and been prefixed. See http://goo.gl/U9mE5.
        if ('mozSlice' in blob) {
          var chunk = blob.mozSlice(start, end);
        } else {
          var chunk = blob.webkitSlice(start, end);
        }

        Blobber.upload(chunk, server_path);

        start = end;
        end = start + BYTES_PER_CHUNK;
      }
    }, false);
  }
}


