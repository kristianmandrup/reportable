// add this to an image in order to extend it with this functionality!
var ImageMagic = {
  showColorImg: function () {
      this.style.display = "none";
      this.nextSibling.style.display = "inline";
  },
  showGrayImg: function () {
      this.previousSibling.style.display = "inline";
      this.style.display = "none";
  },
  removeColors: function (images, canvas) {
      var aImages = document.getElementsByClassName("grayscale");
      var nImgsLen = aImages.length;
      var oCtx = oCanvas.getContext("2d");
      
      for (var nWidth, nHeight, oImgData, oGrayImg, nPixel, aPix, nPixLen, nImgId = 0; nImgId < nImgsLen; nImgId++) {
          oColorImg = aImages[nImgId];
          nWidth = oColorImg.offsetWidth;
          nHeight = oColorImg.offsetHeight;
          oCanvas.width = nWidth;
          oCanvas.height = nHeight;
          oCtx.drawImage(oColorImg, 0, 0);
          oImgData = oCtx.getImageData(0, 0, nWidth, nHeight);
          aPix = oImgData.data;
          nPixLen = aPix.length;
          for (nPixel = 0; nPixel < nPixLen; nPixel += 4) {
              aPix[nPixel + 2] = aPix[nPixel + 1] = aPix[nPixel] = (aPix[nPixel] + aPix[nPixel + 1] + aPix[nPixel + 2]) / 3;
          }
          oCtx.putImageData(oImgData, 0, 0);
          oGrayImg = new Image();
          oGrayImg.src = oCanvas.toDataURL();
          oGrayImg.onmouseover = showColorImg;
          oColorImg.onmouseout = showGrayImg;
          oCtx.clearRect(0, 0, nWidth, nHeight);
          oColorImg.style.display = "none";
          oColorImg.parentNode.insertBefore(oGrayImg, oColorImg);
      }
  }
}