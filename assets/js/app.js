// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"
import $ from "jquery";
import socket from "./socket"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"
import game_init from "./game"

$(() => {
  console.log("init")
  let root = $('#root')[0];
  let channel = socket.channel("space_raiders:" + window.gameName, {user: window.userName})
  game_init(root, channel);
});
