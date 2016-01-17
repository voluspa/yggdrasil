import { Socket } from 'vilive/utils/phoenix';
import ENV from 'vilive/config/environment';

let socket = null;
let channel = null;

export default {
  init (token) {
    socket = new Socket(ENV.yggdrasil.socket + '/socket',
                        {params: {token: token}});
    socket.connect();
    socket.onError((err) => { console.log("socket error", err) });

    // Now that you are connected, you can join channels with a topic:
    channel = socket.channel("game:lobby", {"token": token});
    channel.join()
      .receive("ok", resp => { console.log("Joined successfully", resp); })
      .receive("error", resp => { console.log("Unable to join", resp); });
  },

  push (message, payload) {
    channel.push(message, payload);
  },

  on (event, callback) {
    channel.on(event, callback);
  },

  onSocketError(callback) {
    socket.onError(callback);
  },

  destroy() {
    console.log('destroyed game object');
    channel.disconnect();
  }
};
