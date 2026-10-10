/*! Drape embed v1 — "Try on with Drape" button for store product pages.
 *
 *  <script src="https://<drape-host>/embed/v1.js" data-drape-key="pk_demo_drape" async></script>
 *  <button data-drape-product="abaya-classic" data-drape-colorway="emerald" data-drape-lang="en">Try on with Drape</button>
 *
 *  Clicking opens Drape in a popup (never an iframe, so the camera works). When the buyer adds their look,
 *  this script fires a `drape:add-to-cart` event on `document` with { sessionId, items, lip }.
 *  Only messages from the Drape host are accepted.
 */
(function () {
  "use strict";
  var script = document.currentScript;
  if (!script || !script.src) return;
  var HOST = new URL(script.src).origin;
  var DEFAULT_KEY = script.getAttribute("data-drape-key") || "";
  var DOCS = "https://github.com/Ramy888/YouCamNewSkin-Drape#embed";
  var warned = {};

  function warn(code, message, fix) {
    if (warned[code + message]) return;
    warned[code + message] = true;
    console.warn("[Drape] " + code + ": " + message + " Fix: " + fix + " (" + DOCS + ")");
  }

  function flowUrl(btn) {
    var key = btn.getAttribute("data-drape-key") || DEFAULT_KEY;
    var product = btn.getAttribute("data-drape-product");
    if (!key) warn("DRAPE_BAD_KEY", "No publishable key on the script tag or button.", 'Add data-drape-key="pk_…" to the <script> tag.');
    if (!product) warn("DRAPE_PRODUCT_NOT_FOUND", "Button has no data-drape-product.", "Set it to the product id from your seller console.");
    var q = new URLSearchParams({
      pk: key,
      product: product || "",
      colorway: btn.getAttribute("data-drape-colorway") || "",
      lang: btn.getAttribute("data-drape-lang") || document.documentElement.lang || "en",
      origin: window.location.origin,
    });
    return HOST + "/app/#/start?" + q.toString();
  }

  function open(btn) {
    var url = flowUrl(btn);
    var w = window.open(url, "drape", "popup=yes,width=480,height=880");
    if (!w) {
      warn("DRAPE_POPUP_BLOCKED", "The browser blocked the Drape window.", "Drape now opens in a new tab instead.");
      var a = document.createElement("a");
      a.href = url;
      a.target = "_blank";
      a.rel = "opener";
      document.body.appendChild(a);
      a.click();
      a.remove();
    }
  }

  function bind(root) {
    var buttons = (root || document).querySelectorAll("[data-drape-product]");
    for (var i = 0; i < buttons.length; i++) {
      var b = buttons[i];
      if (b.__drape) continue;
      b.__drape = true;
      b.addEventListener("click", function (e) {
        e.preventDefault();
        open(e.currentTarget);
      });
    }
    return buttons.length;
  }

  // Cart events from the Drape window. Origin must be the Drape host; anything else is ignored.
  window.addEventListener("message", function (e) {
    if (e.origin !== HOST) return;
    var d = e.data;
    if (!d || d.type !== "drape:add-to-cart" || !Array.isArray(d.items)) return;
    document.dispatchEvent(new CustomEvent("drape:add-to-cart", { detail: { sessionId: d.sessionId, items: d.items, lip: d.lip || null } }));
  });

  function init() {
    if (bind(document) === 0) {
      warn("DRAPE_PRODUCT_NOT_FOUND", "No [data-drape-product] buttons found on this page.", "Add a button with data-drape-product, or call Drape.bind() after rendering.");
    }
  }

  window.Drape = { bind: bind, open: open, host: HOST, version: "1" };
  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", init);
  else init();
})();
