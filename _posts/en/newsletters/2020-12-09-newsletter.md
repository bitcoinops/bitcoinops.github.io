---
title: 'Bitcoin Optech Newsletter #127'
permalink: /en/newsletters/2020/12/09/
name: 2020-12-09-newsletter
slug: 2020-12-09-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposed change to the bech32 address format
for taproot, mentions a bug handling certain QR-encoded addresses, thanks
new members of the Cryptocurrency Open Patent Alliance, and mentions new
features of the Minsc policy language and compiler.  Also included are
our regular sections with summaries of a recent Bitcoin Core PR Review
Club meeting, new software releases and release candidates, and notable
changes to popular Bitcoin infrastructure software.

## Action items

*None this week.*

## News

- **Bech32 addresses for taproot and beyond:** Pieter Wuille
  [published][wuille post] the results of research he conducted with
  Gregory Maxwell into finding an optimal constant for updated [bech32
  addresses][topic bech32] to both eliminate the [mutability problem][]
  and mitigate other data entry problems as best as possible.  He also
  replied to research performed by several individuals ([1][russell
  test], [2][casatta test], [3][schmidt test1], [4][schmidt test2]) into
  which wallets support [forward address compatibility][].
  That research revealed most wallets will need to be updated in order to pay
  [taproot][topic taproot] addresses even if we continue using an
  unchanged [BIP173][] address scheme.  Based on his research and the
  other information available, and if there are no convincing
  objections, he plans to write a BIP for the tweaked bech32 checksum
  formula to be used for segwit v1 addresses (taproot) and subsequent
  segwit versioned addresses.  If the proposed alternative bech32
  addresses are adopted, the following implications exist for wallets
  and services:

    - *Support for current addresses remains unchanged:* wallets that
      can send to current native segwit addresses (version 0) or receive
      to current segwit addresses will continue to work
      without modification.  Current native segwit addresses all start
      with `bc1q`.  P2SH-wrapped segwit addresses are also unaffected.

    - *Wallets that support segwit v1+ addresses now won't be forward compatible:*
      wallets that implemented BIP173 forward compatibility will find it
      doesn't work with taproot and subsequent addresses generated using
      Wuille's new proposal.  Those addresses will fail with a checksum
      mismatch.  According to the survey results posted to the mailing
      list, the only known wallets affected are Bitcoin Core and BRD
      wallet.

    - *All other wallets will need to update eventually anyway:* the
      other wallets and services surveyed don't currently support
      planned taproot addresses, so they'll need to upgrade anyway when
      users start requesting money be sent to those v1 addresses.  For
      any wallets that already support sending to current segwit
      addresses, the update should be easy as the planned algorithm
      change is minimal.

- **Thwarted upgrade to uppercase bech32 QR codes:** BTCPay Server
  recently implemented an optimization described in [BIP173][] (covered
  in [Newsletter #46][bech32 upper]) of creating QR codes for bech32
  addresses that [start with][bip21 lowercase] all capital letters in
  order to create smaller and less complex QR codes.  Unfortunately, a
  merchant using BTCPay soon [reported][btcpay #2099] that one of their
  customers was unable to pay the new QR codes.  With impressive speed,
  contributors to BTCPay confirmed that the wallet software used by the
  customer did not properly implement [RFC3986][] case insensitive
  schema parsing.  Although the wallet's developers quickly resolved the
  issue, BTCPay contributors reverted the QR code change and began
  testing a large number of popular user wallets to see how many
  supported uppercase `bitcoin:` schema strings.  Unfortunately, from
  their initial results, it appears several other popular wallets also
  don't implement case insensitive RFC3986 schema parsing.  Anyone
  interested in addressing the problem is encouraged to [help
  test][btcpay #2110] so that the developers of the affected wallets can
  be notified about the issue.

- **Cryptocurrency Open Patent Alliance (COPA) gains new members:**
  Square Crypto [announced][square tweet] on Twitter that several new organizations
  joined this alliance to prevent patents from being abused to prevent
  innovation and adoption of cryptocurrency technology.  We join many
  others in thanking all the current members of COPA: ARK.io, Bithyve,
  Blockchain Commons, Blockstack, Blockstream, Carnes Validadas,
  Cloudeya Ltd., Coinbase, Foundation Devices, Horizontal Systems,
  Kraken, Mercury Cash, Protocol Labs, Request Network, SatoshiLabs,
  Square, Transparent Systems, and VerifyChain.

{% comment %}<!-- Here's me hacking my own policy that (1) releases
should now be in the Releases section, (2) I only cover releases of the
projects listed in the Notable Code Changes section, and (3) Minsc isn't
one of those projects.  The following isn't technically a release
announcement, it's the announcement new features which *just happens* to
correspond with a release.  Yeah, maybe I should have better policies or
just be more laid back.-->{% endcomment %}

- **Minsc adds new features:** a recent [release][minsc 0.2] of this
  policy language and compiler adds support for several new data types:
  pubkeys, hashes, polices, [miniscript][topic miniscript],
  [descriptors][topic descriptors], addresses, and networks.  It also
  adds new functions for conversions: `miniscript()`, `wsh()`, `wpkh()`,
  `sh()` and `address()`.  Here's an [example][minsc example] taken from
  the project's website that uses a specified public key, as a [BIP32][]
  extended public key with derivation path, and several conversion
  functions, returning the set of data specified on the final line:

    ```hack
    $alice = xpub68Gmy5EdvgibQVfPdqkBBCHxA5htiqg55crXYuXoQRKfDBFA1WEjWgP6LHhwBZeNK1VTsfTFUHCdrfp1bgwQ9xv5ski8PX9rL2dZXvgGDnw/9/0;

    $policy = pk($alice/1/3) && older(1 month);
    $miniscript = miniscript($policy); // compile policy to miniscript
    $descriptor = wsh($miniscript); // wrap with a p2wsh descriptor
    $address = address($descriptor); // generate the address

    [ $policy, $miniscript, $descriptor, $address ]
    ```

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

FIXME:jonatack

{% include functions/details-list.md
  q0="FIXME"
  a0="FIXME"
  a0link="https://bitcoincore.reviews/19055-2#FIXME"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 0.21.0rc2][Bitcoin Core 0.21.0] is a release candidate
  for the next major version of this full node implementation and its
  associated wallet and other software.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [LND #4782][] anchor-wtserver FIXME:bitschmidty

{% include references.md %}
{% include linkers/issues.md issues="20564,4782" %}
[bitcoin core 0.21.0]: https://bitcoincore.org/bin/bitcoin-core-0.21.0/
[mutability problem]: /en/newsletters/2019/12/28/#bech32-mutability
[forward address compatibility]: /en/bech32-sending-support/#automatic-bech32-support-for-future-soft-forks
[russell test]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-October/018256.html
[casatta test]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-October/018257.html
[schmidt test1]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-October/018258.html
[schmidt test2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-November/018268.html
[btcd #1661]: https://github.com/btcsuite/btcd/issues/1661
[bech32 upper]: /en/bech32-sending-support/#creating-more-efficient-qr-codes-with-bech32-addresses
[btcpay #2099]: https://github.com/btcpayserver/btcpayserver/issues/2099
[rfc3986]: https://tools.ietf.org/html/rfc3986#section-3.1
[square tweet]: https://twitter.com/sqcrypto/status/1334626548515663872
[minsc 0.2]: https://github.com/shesek/minsc/releases/tag/v0.2.0
[minsc example]: https://min.sc/#c=%24alice%20%3D%20xpub68Gmy5EdvgibQVfPdqkBBCHxA5htiqg55crXYuXoQRKfDBFA1WEjWgP6LHhwBZeNK1VTsfTFUHCdrfp1bgwQ9xv5ski8PX9rL2dZXvgGDnw%2F9%2F0%3B%0A%0A%24policy%20%3D%20pk%28%24alice%2F1%2F3%29%20%26%26%20older%281%20month%29%3B%0A%24miniscript%20%3D%20miniscript%28%24policy%29%3B%20%2F%2F%20compile%20policy%20to%20miniscript%0A%24descriptor%20%3D%20wsh%28%24miniscript%29%3B%20%2F%2F%20wrap%20with%20a%20p2wsh%20descriptor%0A%24address%20%3D%20address%28%24descriptor%29%3B%20%2F%2F%20generate%20the%20address%0A%0A%5B%20%24policy%2C%20%24miniscript%2C%20%24descriptor%2C%20%24address%20%5D
[wuille post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-December/018292.html
[bip21 lowercase]: /en/bech32-sending-support/#bip21-complications
[btcpay #2110]: https://github.com/btcpayserver/btcpayserver/issues/2110
