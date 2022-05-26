// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import '../scss/main.scss';

// Polyfills / Shims
import "mdn-polyfills/Object.assign"
import "mdn-polyfills/CustomEvent"
import "mdn-polyfills/String.prototype.startsWith"
import "mdn-polyfills/Array.from"
import "mdn-polyfills/Array.prototype.find"
import "mdn-polyfills/Array.prototype.some"
import "mdn-polyfills/NodeList.prototype.forEach"
import "mdn-polyfills/Element.prototype.closest"
import "mdn-polyfills/Element.prototype.matches"
import "mdn-polyfills/Node.prototype.remove"
import "child-replace-with-polyfill"
import "url-search-params-polyfill"
import "formdata-polyfill"
import "classlist-polyfill"
import "new-event-polyfill"
import "@webcomponents/template"
import "shim-keyboard-event-key"
import "core-js/features/set"
import "core-js/features/url"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import { Socket } from 'phoenix';
import 'phoenix_html';
import {LiveSocket} from 'phoenix_live_view';
import SelectContent from './select-content.hook';
import Orientation from './orientation.hook';

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute('content');
let liveSocket = new LiveSocket('/live', Socket, {
  params: { _csrf_token: csrfToken },
  hooks: {
    SelectContent,
    Orientation,
  }
});
liveSocket.connect();
