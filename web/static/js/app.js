/*globals $ */

// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "deps/phoenix_html/web/static/js/phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".
import socket from "./socket"

window.app = {
  start () {
    if (window.location.pathname !== "/client") return

    socket.init((err) => {
      if (err) return alert(err.message)

      let $cmd = $("#command")
      let $events = $("#events")

      socket.on("event", payload => {
        $events.append(`<li>[${Date()}] ${payload.message}`)
      })

      $cmd.on("keypress", e => {
        if (e.keyCode !== 13) return

        let cmdText = $cmd.val()
        socket.push("player_cmd", { text: cmdText })
        $cmd.val("")
      })

      socket.join()
    })
  }
}
