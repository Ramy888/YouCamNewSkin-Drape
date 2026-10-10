import { describe, expect, it } from "vitest";
import { linkKeys, validLink } from "../src/links";

describe("linkKeys", () => {
  it("ignores www, case, trailing slash, query and hash", () => {
    expect(linkKeys("https://www.Shop.com/Products/Abaya/?utm=x#top")).toEqual(["url:shop.com/products/abaya"]);
    expect(linkKeys("http://shop.com/products/abaya")).toEqual(["url:shop.com/products/abaya"]);
  });
  it("matches an Amazon product by ASIN on any Amazon domain and URL shape", () => {
    expect(linkKeys("https://www.amazon.ae/Satin-Abaya/dp/B0ABCDEF12?th=1")).toContain("amazon:B0ABCDEF12");
    expect(linkKeys("https://amazon.com/gp/product/b0abcdef12")).toContain("amazon:B0ABCDEF12");
  });
  it("does not invent an ASIN on non-Amazon sites", () => {
    expect(linkKeys("https://shop.com/dp/B0ABCDEF12")).toEqual(["url:shop.com/dp/b0abcdef12"]);
  });
  it("rejects anything that is not a web address", () => {
    expect(validLink("javascript:alert(1)")).toBe(false);
    expect(validLink("not a url")).toBe(false);
    expect(validLink("https://shop.com/x")).toBe(true);
  });
});
