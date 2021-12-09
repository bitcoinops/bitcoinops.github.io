{% capture /dev/null %}
<!--
issues.md: creates Markdown reference-style links to issues, pull
requests, and other templated URLs.

  Input:
    - issues: (CSV) the issue numbers to create links for separated by
      commas with no spaces.  For a given number, a separate link will
      be created for *all* supported repositories

  Output:
    List of Markdown reference-style links

  Example:
    Input:
      % include linkers/issues.md issues="123,456" %
    Output
      [bitcoin core #123]: https://github.com/bitcoin/bitcoin/issues/123
      [lnd #123]: https://github.com/lightningnetwork/lnd/issues/123
      [bitcoin core #456]: https://github.com/bitcoin/bitcoin/issues/456
      [lnd #456]: https://github.com/lightningnetwork/lnd/issues/456
-->
{% assign _issues = include.issues | split: "," %}
{% endcapture %}{% for _issue in _issues %}
[bitcoin core #{{_issue}}]: https://github.com/bitcoin/bitcoin/pull/{{_issue}}
[bitcoin core gui #{{_issue}}]: https://github.com/bitcoin-core/gui/pull/{{_issue}}
[lnd #{{_issue}}]: https://github.com/lightningnetwork/lnd/pull/{{_issue}}
[c-lightning #{{_issue}}]: https://github.com/ElementsProject/lightning/pull/{{_issue}}
[libsecp256k1 #{{_issue}}]: https://github.com/bitcoin-core/secp256k1/pull/{{_issue}}
[eclair #{{_issue}}]: https://github.com/ACINQ/eclair/pull/{{_issue}}
[bips #{{_issue}}]: https://github.com/bitcoin/bips/pull/{{_issue}}
[bolts #{{_issue}}]: https://github.com/lightning/bolts/pull/{{_issue}}
[rust bitcoin #{{_issue}}]: https://github.com/rust-bitcoin/rust-bitcoin/pull/{{_issue}}
[rust-lightning #{{_issue}}]: https://github.com/rust-bitcoin/rust-lightning/pull/{{_issue}}
[review club #{{_issue}}]: https://bitcoincore.reviews/{{_issue}}
[hwi #{{_issue}}]: https://github.com/bitcoin-core/HWI/pull/{{_issue}}
[btcpay server #{{_issue}}]: https://github.com/btcpayserver/btcpayserver/pull/{{_issue}}
[bdk #{{_issue}}]: https://github.com/bitcoindevkit/bdk/pull/{{_issue}}
{% endfor %}
