---
title: 'Bitcoin Optech Newsletter #254'
permalink: /en/newsletters/2023/06/07/
name: 2023-06-07-newsletter
slug: 2023-06-07-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes mailing list discussion about using
the MATT proposal to manage joinpools and replicate functions of the
`OP_CHECKTEMPLATEVERIFY` proposal.  Also included is another entry in
our limited weekly series about mempool policy, plus our regular
sections for announcing new software releases and release candidates and
describing notable changes to popular Bitcoin infrastructure software.

## News

- **Using MATT to replicate CTV and manage joinpools:** Johan Torås
  Halseth [posted][halseth matt-ctv] to the Bitcoin-Dev mailing list
  about using the `OP_CHECKOUTPUTCONTRACTVERIFY` opcode (COCV) from the
  Merklize All The Things (MATT) proposal (see Newsletters
  [#226][news226 matt] and [#249][news249 matt]) to replicate the
  functionality of the [OP_CHECKTEMPLATEVERIFY][topic
  op_checktemplateverify] proposal.  For committing a transaction with
  multiple outputs, each output would require using a different COCV
  opcode.  By comparison, a single CTV opcode could commit to all the
  outputs.  That makes COCV less efficient but, as he notes, "simple
  enough to be interesting".

    Beyond just describing the functionality, Halseth also provides a
    [demo][halseth demo] of the operation using [Tapsim][], a tool for
    "debugging Bitcoin Tapscript transactions [...] aimed at developers
    wanting to play with Bitcoin script primitives, aid in script
    debugging, and visualize the VM state as scripts are executed."

    In a separate thread, Halseth [posted][halseth matt-joinpool] about
    using MATT plus [OP_CAT][] to create a [joinpool][topic joinpools]
    (also called a _coinpool_ or a _payment pool_).  Again, he provides
    an [interactive demo][demo joinpool] using Tapsim.  He also provided
    several suggested modifications to the opcodes in the MATT proposal
    based on the results of his experimental implementation.   Salvatore
    Ingala, the originator of the MATT proposal, [replied][ingala matt]
    favorably.

## Waiting for confirmation #4: Feerate estimation

_A limited weekly [series][policy series] about transaction relay,
mempool inclusion, and mining transaction selection---including why
Bitcoin Core has a more restrictive policy than allowed by consensus and
how wallets can use that policy most effectively._

{% include specials/policy/en/04-feerate-estimation.md %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND 0.16.3-beta][] is a maintenance release for this popular LN node
  implementation.  Its release notes say, "this release contains only
  bug fixes and is intended to optimize the recently added mempool
  watching logic, and also fix several suspected inadvertent force close
  vectors".  For more information about the mempool-watching logic, see
  [Newsletter #248][news248 lnd mempool].

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #26485][] RPC: Accept options as named-only parameters FIXME:glozow

- [Eclair #2642][] adds a `closedchannels` RPC  that provides data
  about the node’s closed channels.  See also a similar PR from Core
  Lightning mentioned in [Newsletter #245][news245 listclosedchannels].

- [LND #7645][] sweep+lnrpc: enforce provided fee rate is no less than relay fee FIXME:bitschmidty

- [LND #7726][] will always spend all HTLCs paying the local node if a
  channel needs to be settled onchain.  It will sweep those HTLCs even
  if it might cost more in transaction fees to sweep them than they are
  worth.  Compare this to a PR from Eclair described in [last week's
  newsletter][news253 sweep] where that program now won't attempt to
  claim an HTLC that is [uneconomical][topic uneconomical outputs].
  Comments in the PR thread mention that LND is working toward other
  changes that will enhance its ability to calculate the costs and gains
  related to settling HTLCs (both offchain and onchain), allowing it to
  make optimal decisions in the future.

- [LDK #2293][] disconnects and then reconnects to peers if they haven't
  responded within a reasonable amount of time.  This may mitigate a
  problem with other LN software that sometimes stops responding,
  leading to channels being forced closed.

{% include references.md %}
{% include linkers/issues.md v=2 issues="2642,26485,7645,7726,2293" %}
[policy series]: /en/blog/waiting-for-confirmation/
[news226 matt]: /en/newsletters/2022/11/16/#general-smart-contracts-in-bitcoin-via-covenants
[news249 matt]: /en/newsletters/2023/05/03/#matt-based-vaults
[news253 sweep]: /en/newsletters/2023/05/31/#eclair-2668
[news245 listclosedchannels]: /en/newsletters/2023/04/05/#core-lightning-5967
[halseth matt-ctv]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021730.html
[halseth demo]: https://github.com/halseth/tapsim/blob/b07f29804cf32dce0168ab5bb40558cbb18f2e76/examples/matt/ctv2/README.md
[tapsim]: https://github.com/halseth/tapsim
[halseth matt-joinpool]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021719.html
[demo joinpool]: https://github.com/halseth/tapsim/tree/matt-demo/examples/matt/coinpool
[ingala matt]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021724.html
[news248 lnd mempool]: /en/newsletters/2023/04/26/#lnd-7564
[lnd 0.16.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.3-beta
