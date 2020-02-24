// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import '../scss/main.scss';

// Polyfills / Shims
import 'mdn-polyfills/CustomEvent';
import 'mdn-polyfills/String.prototype.startsWith';
import 'mdn-polyfills/Array.from';
import 'mdn-polyfills/NodeList.prototype.forEach';
import 'mdn-polyfills/Element.prototype.closest';
import 'mdn-polyfills/Element.prototype.matches';
import 'child-replace-with-polyfill';
import 'url-search-params-polyfill';
import 'formdata-polyfill';
import 'classlist-polyfill';
import 'shim-keyboard-event-key';

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import 'phoenix_html';

// Import local files
//
// Local files can be imported directly using relative paths, for example:
import { Socket } from 'phoenix';
import LiveSocket from 'phoenix_live_view';

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute('content');
let liveSocket = new LiveSocket('/live', Socket, {
  params: { _csrf_token: csrfToken },
  hooks: {
    SelectContent: {
      mounted() {
        this.el.select();
      }
    }
  }
});
liveSocket.connect();
