---
title: 'Bitcoin Optech Newsletter #5'
permalink: /en/newsletters/2018/07/24/
name: 2018-07-24-newsletter
type: newsletter
layout: newsletter
lang: en
version: 1
---
This week's newsletter includes information about a new language to describe
output scripts, an update on Bitcoin Core's support for partially-signed
Bitcoin transactions, and news on several other notable Bitcoin Core merges.

## Action items

- Bitcoin Core [0.16.2RC2][] released for testing in preparation for a
  maintenance release that will provide bugfixes and backports.
  Community testing is highly appreciated.  Note, there was no RC1 due
  to a metadata problem being detected during the release process.

## Dashboard items

- Transaction fees are lower than they were this time last week.  Anyone
  who can wait 12 or more blocks for confirmation can reasonably pay the
  default minimum feerate.  It's a good time to [consolidate UTXOs][].

- The number of [native segwit outputs][p2shinfo bech32] had been
  increasing steadily over time, but dropped by about 400,000 (80%) this
  week, possibly due to UTXO consolidation by an exchange.  The average
  number of new native segwit outputs created per hour remains
  relatively constant, indicating no obvious decrease in adoption.

## News

- **Bitcoin Optech publicly announced:** we received great coverage in
  [Bitcoin Magazine][announce bmag], [Coindesk][announce cdesk], and several
  other publications.  This wouldn't have been possible without the
  support of our founding sponsors and member companies.  Thank you!

- **First Optech workshop held in San Francisco:** as
  [previously announced][workshop announce], we held our first workshop
  in San Francisco last week. There were 14 engineers from Bay Area companies and
  open source projects in attendence, and we had great discussions about
  coin selection, replace-by-fee, and child-pays-for-parent. Thanks
  to Square for hosting and Coinbase for helping with organization.

  If you work at a member company and have any requests or suggestions for
  future Optech events (be that location, venue, dates, format, topics,
  or anything else), please contact us. We're here to help our member
  companies!

- **Coin selection RPC unlikely:** In Bitcoin Core's [weekly
  meeting][bcc meeting 7/19], Andrew Chow raised the possibility of
  creating an RPC that would allow users to pass in information about a
  transaction they wanted to create, including a list of available
  inputs, and receive back a list of which inputs would be selected by
  the Bitcoin Core wallet's coin selection algorithm.

    Meeting participants were mostly opposed to providing this feature,
    suggesting that it would be better if it was a library and that
    Bitcoin Core's recent and continuing work towards encapsulating its
    coin selection code would simplify development of a third-party
    library later.  A particular opposition to the idea was that it
    might reduce the pace of development for direct users of the Bitcoin
    Core wallet; as Gregory Maxwell said, "Pressure to maintain a stable
    interface to [coin selection] would be harmful to the project. [...]
    I don’t want to hear 'we can't implement privacy feature X because
    it'll break [the coin selection] interface'."

- **First use of output script descriptors:** Pieter Wuille has opened
  PR [#13697][] to Bitcoin Core that implements his [output script
  descriptors][] language for describing which output scripts
  (scriptPubKeys) a wallet should monitor for.  This particular PR only
  applies to the recently-added [`scantxoutset`][#12196] RPC but Wuille's
  ultimate goal is to use this new language elsewhere in the API and "to
  remove the need for importing scripts and keys entirely, and instead
  make the wallet just be a list of these descriptors plus associated
  metadata."

- **BIP174 Partially-Signed Bitcoin Transaction (PSBT) support merged:** this
  provides a standardized format that multiple wallets can use to
  communicate information about transactions that need to be signed,
  so that hot wallets can get signatures from cold wallets or hardware
  wallets, multisig transactions can be signed by multiple wallets, and
  multiple wallets can collaboratively create multiparty transactions such
  as CoinJoins.  Several RPCs are added with this merge:
  `walletprocesspsbt`, `walletcreatefundedpsbt`, `decodepsbt`,
  `combinepsbt`, `finalizepsbt`, `createpsbt`, and `convertpsbt`.  For a
  full description, see PR [#13557][].

## Notable Bitcoin Core merges

*Not including those previously discussed in the News section.*

{% comment %}
git log --merges b25a4c2284babdf1e8cf0ec3b1402200dd25f33f..07ce278455757fb46dab95fb9b97a3f6b1b84faf
{% endcomment %}

- [#9662][]: New wallets can now be created with private keys disabled.
  This is primarily meant for users who want to exclusively use their
  wallet in conjunction with another program or hardware wallet that
  stores private keys.  This could also be useful to companies that want
  to use Bitcoin Core features (like coin selection) by creating a
  wallet, importing their addresses (but not private keys), and then
  performing whatever actions they desire, such as using the
  [`fundrawtransaction`][rpc fundrawtransaction] RPC.

- [#12196][]: New `scantxoutset` RPC method that allows searching the
  set of spendable bitcoins (UTXOs) for those matching an address,
  public key, private key, or HD keypath.  The main expected use for
  this is "funds sweeping" where transactions matching an old wallet are
  found and transferred to a new wallet.  Although this RPC will almost
  certainly be included in Bitcoin Core 0.17, it will likely be marked
  as experimental so that its API can be freely changed in subsequent
  releases. This API is likely to be
  updated to support output script descriptors, which is planned to
  happen before 0.17.

- [#13604][]: Bitcoin-Qt is now built by default in addition to bitcoind
  on 32-bit ARM systems, and should be distributed by default with the
  other binaries for that system from BitcoinCore.org for future
  releases.  Bitcoin-Qt with 64-bit ARM is not yet supported by default.

- [#13298][]: The node now sends all announcements ([invs][inv]) for
  new transactions to all of its incoming peers at the same time, after
  a random delay.  Previously, Satoshi Nakamoto [added a feature][rand
  delay] to Bitcoin (the software) that waited for a different random
  delay for each peer before sending an announcement so that a
  transaction would propagate around the network somewhat unpredictably,
  preventing spy nodes from being able to assume that the first peer
  they received a transaction from was likely the peer that created it.

    However, later investigators realized that someone operating
    multiple spy nodes could make multiple connections to each node to
    increase their chances of being the first to receive a given
    transaction, allowing the spy to again guess which node create the
    transaction.  This merge improves the situation by preventing a spy
    making multiple connections from receiving any more information than
    a spy with one connection.  Outgoing connections (which are selected
    by the node itself using certain rules) continue to use the old
    behavior so that transactions continue to propagate unpredictably.

    This change might increase transaction propagation delay slightly,
    although developers commenting on the PR think the effect will be
    minimal.  It may also cause bandwidth usage to be less evenly
    distributed over time.   However, it could (in theory) end up
    reducing the number of incoming connections to upgraded nodes, if spy
    nodes no longer find making multiple connections to be useful,
    reducing overall wasted bandwidth.

- [#13652][]: The [`abandontransaction`][rpc abandontransaction] RPC has
  been fixed to abandon all descendant transactions, not just children.

## Coming attractions

Next week's newsletter will feature a field report from Anthony Towns, a
developer at Xapo, about how they consolidated around 4 million UTXOs to
prepare for potential future fee increases.

We love getting contributions to the newsletter from member companies. If you'd like
to share your experiences in implementing better Bitcoin technology, please contact us!

[bcc meeting 7/19]: https://bitcoincore.org/en/meetings/2018/07/19/
[rand delay]: https://github.com/bitcoin/bitcoin/commit/22f721dbf23cf5ce9e3ded9bcfb65a3894cc0f8c#diff-118fcbaaba162ba17933c7893247df3aR718
[p2shinfo bech32]: https://p2sh.info/dashboard/db/bech32-statistics?orgId=1
[consolidate utxos]: https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#Consolidation
[0.16.2rc2]: https://bitcoincore.org/bin/bitcoin-core-0.16.2/test.rc2/
[announce bmag]: https://bitcoinmagazine.com/articles/chaincode-devs-google-alumni-create-industry-group-help-bitcoin-scale/
[announce cdesk]: https://www.coindesk.com/bitcoins-biggest-startups-are-backing-a-new-effort-to-keep-fees-low/
[inv]: https://bitcoin.org/en/developer-reference#inv
[workshop announce]: /en/newsletters/2018/06/26/#first-optech-workshop

{% include references.md %}
{% include link-to-issues.md issues="13697,13557,12196,9662,12196,13604,13298,13652" %}
