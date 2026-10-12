// Layla Boutique: a second fictional demo store using the same page template as Noor Modest, with its own name,
// product and colours. Shows Drape on more than one shop (and in Drape's catalogue, filtered by store).
window.NOOR_CONFIG = {
  drapeHost: location.hostname === "localhost" || location.hostname === "127.0.0.1" ? "http://localhost:8787" : "https://drape.ramy-comm.workers.dev",
  drapeKey: "pk_layla_demo",
  store: {
    name: "Layla Boutique",
    short: "Layla",
    tagline: "Boutique",
    title: "Woven kaftan coat",
    product: "kaftan-coat",
    colorway: "saffron",
    crumbs: "Coats / Kaftans",
    details: "Open-front woven kaftan coat with embroidered trim and wide sleeves. Layer it over an abaya or a long dress.",
    nav: ["Kaftans", "Coats", "Scarves", "Gifts"],
    theme: { navy: "#2f3b2b", ink: "#22281f", coral: "#a8742c", blush: "#f3ece0", line: "#e4ddd0" },
  },
};
