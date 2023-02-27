---
layout: page
title: About
permalink: /about/
---

The Bitcoin Operations Technology Group (Optech) works to bring the best
open source technologies and techniques to Bitcoin-using businesses in
order to lower costs and improve customer experiences.

An initial focus for the group is working with its member organizations to
reduce transaction sizes and minimize the effect of subsequent transaction fee
increases.  We provide [workshops][], [documentation][scaling book],
[weekly newsletters][], [original research][dashboard], [case studies
and announcements][blog], a [podcast][], and help facilitate improved relations between
businesses and the open source community.

[scaling book]: https://github.com/bitcoinops/scaling-book
[workshops]: /workshops
[weekly newsletters]: /en/newsletters/
[dashboard]: https://dashboard.bitcoinops.org/
[blog]: /en/blog/
[podcast]: /en/podcast/

If you're an engineer or manager at a Bitcoin company or an open source contributor and you'd like to be a part of this, please
contact us at [info@bitcoinops.org](mailto:info@bitcoinops.org).

## Funding

Optech does not exist to make a profit, and all materials and documentation
produced are released under the MIT license.

Seed funding was provided by Wences Casares and John Pfeffer to cover outside
contractors and incidental expenses. Resources are provided by Chaincode Labs
to support Optech.

Our generous member companies pay an annual contribution to cover expenses.

## Optech Contributors

All material produced by Bitcoin Optech is open source and released under the
MIT license. Anyone is welcome to contribute by opening issues and pull
requests, reviewing newsletters and other material, and contributing
translations. Our most regular contributors are:

{% assign contributors = site.data.contributors.contributors | sort: "name" %}
{% include contributors.html id="contributors" %}

{% include sponsors.html %}

## Former Optech Contributors

We thank all of our previous contributors for their efforts.

{% assign contributors = site.data.contributors.contributors_alum | sort: "name" %}
{% include contributors.html id="contributors_alum" %}
