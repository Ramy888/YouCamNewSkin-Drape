// Where the Drape host lives. Local: wrangler dev on 8787. Deployed: replaced by the deploy script.
window.NOOR_CONFIG = {
  drapeHost: location.hostname === "localhost" || location.hostname === "127.0.0.1" ? "http://localhost:8787" : "https://drape.ramy-comm.workers.dev",
  drapeKey: "pk_demo_drape",
};
