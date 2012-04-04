// see http://stackoverflow.com/questions/4998908/convert-data-uri-to-file-then-append-to-formdata
// http://blogs.msdn.com/b/ie/archive/2012/01/27/creating-files-through-blobbuilder.aspx
var Blobber = {
  // Take care of vendor prefixes.
  builder: getVendorBuilder(),

  getVendorBuilder: function() {
    window.MozBlobBuilder || window.WebKitBlobBuilder || window.BlobBuilder || new MSBlobBuilder(); 
  },
  dataURItoBlob: function (dataURI) {
    // convert base64 to raw binary data held in a string
    // handle urlencoded as well
    var byteString;
    if (dataURI.split(',')[0].indexOf('base64') >= 0)
        byteString = atob(dataURI.split(',')[1]);
    else
        byteString = unescape(dataURI.split(',')[1]);

    // separate out the mime component
    var mimeString = dataURI.split(',')[0].split(':')[1].split(';')[0]

    // write the bytes of the string to an ArrayBuffer
    var ab = new ArrayBuffer(byteString.length);
    var ia = new Uint8Array(ab);
    for (var i = 0; i < byteString.length; i++) {
        ia[i] = byteString.charCodeAt(i);
    }

    // write the ArrayBuffer to a blob, and you're done
    var bb = new BlobBuilder();
    bb.append(ab);
    return bb.getBlob(mimeString);
  },

  canvas2Blob: function(canvas, browser) {
    var mime = 'image/' + format;
    if (browser == 'mozilla') {
      canvas.mozGetAsFile('image.' + format);
    else {
      Blobber.dataURItoBlob(canvas.toDataURL(mime));
    }
  },

  upload: function (blobOrFile, server_path, parameters, progressBar) {
    var xhr = new XMLHttpRequest();
    xhr.open('POST', server_path, true);
    xhr.onload = function(e) {
      // do some stuff?
    };

    if (parameter_map) {
      $.each(parameter_map, function(header, value) { 
        xhr.setRequestHeader(header, value)  
      });    
    }


    if (progressBar) {
      // Listen to the upload progress.
      // <progress min="0" max="100" value="0">0% complete</progress>
      xhr.upload.onprogress = function(e) {
        if (e.lengthComputable) {
          progressBar.value = (e.loaded / e.total) * 100;
          progressBar.textContent = progressBar.value; // Fallback for unsupported browsers.
        }
      };
    }

    xhr.send(blobOrFile);
  }
}




