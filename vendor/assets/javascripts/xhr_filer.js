var XhrFiler = {
	uploadFiles: function (url, files) {
	  var formData = new FormData();

	  for (var i = 0, file; file = files[i]; ++i) {
	    formData.append(file.name, file);
	  }

	  var xhr = new XMLHttpRequest();
	  xhr.open('POST', url, true);
	  xhr.onload = function(e) { ... };

	  xhr.send(formData);  // multipart/form-data
	}
}
