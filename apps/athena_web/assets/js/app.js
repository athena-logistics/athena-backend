// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import 'child-replace-with-polyfill';
import 'classlist-polyfill';
import 'formdata-polyfill';
import 'mdn-polyfills/Array.from';
// Polyfills / Shims
import 'mdn-polyfills/CustomEvent';
import 'mdn-polyfills/Element.prototype.closest';
import 'mdn-polyfills/Element.prototype.matches';
import 'mdn-polyfills/NodeList.prototype.forEach';
import 'mdn-polyfills/String.prototype.startsWith';
// Import local files
//
// Local files can be imported directly using relative paths, for example:
import { Socket } from 'phoenix';
// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import 'phoenix_html';
import LiveSocket from 'phoenix_live_view';
import 'shim-keyboard-event-key';
import 'url-search-params-polyfill';
import '../scss/main.scss';

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute('content');
let liveSocket = new LiveSocket('/live', Socket, {
  params: { _csrf_token: csrfToken },
  hooks: {
    SelectContent: {
      mounted() {
        if (!this.el.hidden) this.focus();
        this.hiddenBefore = this.el.hidden;
      },
      updated() {
        if (this.hiddenBefore && !this.el.hidden) this.focus();
        this.hiddenBefore = this.el.hidden;
      },
      focus() {
        this.el.focus();
        this.el.select();
      }
    }
  }
});
liveSocket.connect();
