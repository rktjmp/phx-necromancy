// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).
import "../css/app.css"

// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
var timeout = null
window.addEventListener("phx:page-loading-start", (info) => {
  if (timeout) {
    clearTimeout(timeout)
    timeout = null
  }
  timeout = setTimeout(topbar.show, 200)
})
window.addEventListener("phx:page-loading-stop", (info) => {
  topbar.hide()
  if (timeout) {
    clearTimeout(timeout)
    timeout = null
  }
})

// seems that its preferable to always construct the livesocket but not connect
// it, vs constructing it on demand as redispatched click events don't seem to
// be caught.
let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}})
liveSocket.enableDebug()

let bindConnectForEvent = (el, eventType) => {
  el.addEventListener(eventType, (e) => {
    // if we're not connected, connect and then refire the same event incase
    // we're bound to a phx-click etc.
    if (!liveSocket.isConnected()) {
      window.addEventListener("phx:page-loading-stop", () => {
        el.dispatchEvent(e)
      }, {once: true})
      liveSocket.connect()
    }})
}

window.addEventListener("DOMContentLoaded", () => {
  // This is a generic connect, you could use click, hover, etc.
  // <button data-connect-liveview="click">...
  // will connect the livesocket on click. You could also do
  // <form data-connect-liveview="input">...
  // but this is not redispatched cleanly, you'd instead have to redispatched
  // against the actual input field.
  document.querySelectorAll("[data-connect-liveview]").forEach((el) => {
    bindConnectForEvent(el, el.dataset.connectLiveview)
  })

  // Or we could bind to known phx attribute to always resume
  document.querySelectorAll("[phx-click]").forEach((el) => {
    bindConnectForEvent(el, "click")
  })
})
