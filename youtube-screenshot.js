// ==UserScript==
// @name         YouTube Screenshot Button
// @version      1.0.0
// @description  Screenshots youtube
// @match        *://*.youtube.com/*
// @icon         https://www.google.com/s2/favicons?sz=64&domain=youtube.com
// @grant        none
// @require      https://cdn.jsdelivr.net/npm/@violentmonkey/shortcut@1
// @run-at       document-start
// @noframes
// ==/UserScript==

if (window.trustedTypes && window.trustedTypes.createPolicy) {
    window.trustedTypes.createPolicy('default', {
        createHTML: (string, sink) => string
    });
}

console.log("SCREENSHOt YOUTUBE LOADED");

VM.shortcut.register('\\', () => {
  console.log("shotcut")
  init();
});

VM.shortcut.register('ctrl-left', () => {
  const player = document.querySelector('ytd-player').getPlayer();
  const seconds = 1;
  player.seekToStreamTime(player.getCurrentTime() - seconds)
});

VM.shortcut.register('ctrl-right', () => {
  const player = document.querySelector('ytd-player').getPlayer();
  const seconds = 1;
  player.seekToStreamTime(player.getCurrentTime() + seconds)
});

VM.shortcut.register('alt-left', () => {
  const player = document.querySelector('ytd-player').getPlayer();
  const seconds = 1;
  player.seekToStreamTime(player.getCurrentTime() - seconds)
});

VM.shortcut.register('alt-right', () => {
  const player = document.querySelector('ytd-player').getPlayer();
  const seconds = 1;
  player.seekToStreamTime(player.getCurrentTime() + seconds)
});

VM.shortcut.register('ctrl-s', () => {
screenshot();
});

function screenshot() {
    var title;

    // var headerEls = document.querySelectorAll("h1.title.ytd-video-primary-info-renderer");
    // function SetTitle() {
    //     if (headerEls.length > 0) {
    //         title = headerEls[0].innerText.trim();
    //         return true;
    //     } else {
    //         return false;
    //     }
    // }
    // if (SetTitle() == false) {
    //     headerEls = document.querySelectorAll("h1.watch-title-container");
    //     if (SetTitle() == false)
    //         title = '';
    // }

  //can refactor above to get video title

    var canvas = document.createElement("canvas");
    var player = document.getElementsByClassName("video-stream")[0];
    canvas.width = player.videoWidth;
    canvas.height = player.videoHeight;
    canvas.getContext('2d')
        .drawImage(player, 0, 0, canvas.width, canvas.height);

    var seconds = Math.floor(player.currentTime % 60).toString();
    var minutes = Math.floor((player.currentTime / 60) % 60).toString();
    var hours = Math.floor((player.currentTime / 3600)).toString();
    var time = "";
    if (hours > 0) {
      time = `${hours}-${minutes.padStart(2, '0')}-${seconds.padStart(2, '0')}`;
    }
    else {
      time = `${minutes}-${seconds.padStart(2, '0')}`;
    }

    const screenshotFormat = "jpeg";

    const queryString = window.location.search;
    const urlParams = new URLSearchParams(queryString);
    title = `screenshot ${urlParams.get('v')} ${time}.jpg`;

    const downloadLink = document.createElement("a");
    downloadLink.download = title;

    canvas.toBlob(async function(blob) {
      downloadLink.href = URL.createObjectURL(blob);
      downloadLink.click();
    }, 'image/' + screenshotFormat);
}

function init() {
  console.log("init(), " + performance.now());
  if (document.getElementsByClassName("screenshotButton").length > 0) {
    return;
  }

  var ytpRightControls = document.getElementsByClassName("ytp-right-controls");
  if (ytpRightControls) {
    var screenshotButton = document.createElement("button");
    screenshotButton.className = "screenshotButton ytp-button";
    screenshotButton.style.width = "auto";
    screenshotButton.innerHTML = window.trustedTypes.defaultPolicy.createHTML("Screenshot");
    screenshotButton.style.cssFloat = "left";
    screenshotButton.style.userSelect = "none";
    screenshotButton.onclick = screenshot;

    for (let x = 0; x < ytpRightControls.length; x++) {
      console.log("ytpRightControls #", x, "added")
      ytpRightControls[x].prepend(screenshotButton);
    }

    // ytpRightControls.forEach(function (x) => { x.prepend(screenshotButton); });
  }
  else {
    console.log("CONTROLS NOT FOUND");
  }
}

document.addEventListener('DOMContentLoaded', init.bind(this));

