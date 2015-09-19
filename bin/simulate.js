ws = new WebSocket('ws://localhost:5000')
platforms = ['Linux', 'Macintosh', 'Windows', 'Other']

function randomPlatform() {
  return platforms[Math.floor(Math.random()*platforms.length)]
}

function sendData() {
  ws.send(randomPlatform());
}

setTimeout(sendData, 1000)
