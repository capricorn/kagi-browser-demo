# Orion Demo Project

This project implements a simple web browser per the [specification](https://hackmd.io/@vprelovac/B1_TvFIxa).

A few notes:
- All state is in memory; extension installs are _not_ preserved.
- [Marginalia](https://search.marginalia.nu/) is the default search engine for queries.
- The Top Sites API is defined according to [this spec](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/topSites/get).
In particular, it [limits](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/topSites/get#oneperdomain) the appearance of a given domain
to a single occurrence and 'breaks ties' with recency if the visit count of two domains is equal.

## Demo

[![Demo](https://img.youtube.com/vi/d2-lxTEWB78/maxresdefault.jpg)](https://www.youtube.com/watch?v=d2-lxTEWB78)
