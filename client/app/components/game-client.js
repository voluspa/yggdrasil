import Ember from 'ember';
import GameChannel from 'vilive/utils/game-channel';

export default Ember.Component.extend({
  init() {
    this.set('messages', Ember.makeArray());
    GameChannel.init(this.get('session-manager').currentToken());
    GameChannel.on('event', payload => {
      this.putMessage({
        server: {
          text: payload.body
        }
      });
    });
    this._super(...arguments);
  },

  actions: {
    sendCommand() {
      const command = this.get('command');

      if (!command || command.length === 0) { return; }

      this.putMessage({
        client: {
          text: command
        }
      });

      GameChannel.push('user_cmd', {body: command});
      this.set('command', null);
    }
  },

  /**
    This does not fire after each message is inserted just when the component
    is inserted, in here we are going to focus on the text box.
  */
  didInsertElement() {
    this.$('#command-input').focus();
  },

  /**
    Need to scroll the div after the message has been rendered.
    otherwise it stops short and scroll to last message inserted
  */
  scrollToBottomMessages() {
    const div = this.$('.panel-body');
    Ember.run.schedule('afterRender', () => {
      div.scrollTop(div.prop("scrollHeight") - div.prop("clientHeight"));
    });
  },

  putMessage(msg) {
    this.get('messages').pushObject(msg);
    this.scrollToBottomMessages();
  },

  willDestroy() {
    GameChannel.destroy();
  }
});
