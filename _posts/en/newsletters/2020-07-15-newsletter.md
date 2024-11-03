---
title: 'Bitcoin Optech Newsletter #106'
permalink: /en/newsletters/2020/07/15/
name: 2020-07-15-newsletter
slug: 2020-07-15-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposed update to the draft BIP118
`SIGHASH_NOINPUT` and summarizes notable changes to popular Bitcoin
infrastructure projects.

## Action items

*None this week.*

## News

- **BIP118 update:** Anthony Towns [posted][towns post] to the
  Bitcoin-Dev mailing list a link to a PR that proposes to replace the
  existing text of the [BIP118][] draft of [SIGHASH_NOINPUT][topic
  sighash_anyprevout] with the [draft specification][anyprevout spec] for
  `SIGHASH_ANYPREVOUT` and `SIGHASH_ANYPREVOUTANYSCRIPT`.  Both
  proposals describe optional signature hash (sighash) flags that do not
  commit to the particular UTXOs (inputs/previous outputs) being spent
  in a transaction, making it possible to create a signature for a
  transaction without knowing which UTXO it will spend.  That feature can
  be used by the proposed [eltoo][topic eltoo] settlement layer to allow
  creating a series of transactions where any later transaction can
  spend the value from any earlier transaction, allowing an offchain
  contract to be settled in its latest state even if earlier states are
  confirmed onchain.

  The main difference between the noinput and anyprevout proposals is
  that noinput would require its own new version of segwit but
  anyprevout uses one of the upgrade features from the proposed [BIP342][]
  specification of [tapscript][topic tapscript].  Additional
  differences between the proposals are described in the [revised
  text][anyprevout revisions] itself.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #19219][] clarifies the [distinction][ban vs discourage] between manual peer banning
  and automated peer discouragement, and it reduces worst-case resource usage
  by placing the IP addresses of misbehaving peers into a non-persisted rolling bloom filter to
  prevent them from abusing Bitcoin Core's limited connection slots. Such peers are now
  logged as *discouraged* rather than *banned* to reflect the changes made in
  [#14929][Bitcoin Core #14929] (see [Newsletter #32][news32 bcc14929]).
  By contrast, incoming connections are never accepted
  from manually banned peers, and their addresses and subnets are persisted to
  banlist.dat on shutdown and reloaded on startup. Banning can be used to
  prevent connections with spy nodes or other griefers---although neither banning nor discouragement protects
  against DoS attacks, as it is trivial for an attacker to reconnect using
  different IP addresses.

  This PR marks the beginning of a series of current and future changes to peer
  management. In related merges this week, [#19464][Bitcoin Core #19464] removes the
  `-banscore` configuration option, and [#19469][Bitcoin Core #19469] updates the
  `getpeerinfo` RPC to deprecate the `banscore` field.  Further improvements to
  [resource usage][cuckoo filter], [inbound connection optimization][eviction-logic]
  and user interfaces related to peer management are currently in development.

- [Bitcoin Core #19328][] updates the `gettxoutsetinfo` RPC with a new
  `hash_type` parameter that allows specifying how to generate a
  checksum of the current UTXO set.  Currently the only two options are
  `hash_serialized_2`, which produces the checksum that has been the
  default since Bitcoin Core 0.15 (September 2017), or `none`, which
  returns no checksum.  It's [planned][Bitcoin Core #18000] to later
  allow a [muhash][]-based checksum along with an index that will allow
  returning the checksum much more quickly than is now possible (in less
  than two seconds, per early testing by an Optech contributor).  For
  now, requesting the `none` result allows the `gettxoutsetinfo` RPC to
  run much more quickly, which is useful for anyone running it after
  each block (e.g. to audit the number of spendable bitcoins).  For
  historical context on fast UTXO set checksums, see this [2017
  post][wuille rolling] by Pieter Wuille.

- [Bitcoin Core #19191][] updates the `-whitebind` and `-whitelist`
  configuration settings with a new `download` permission.  When this
  permission is applied to a peer, it will be allowed to continue
  downloading from the local node even if the node has reached its
  `-maxuploadtarget` maximum upload limit.  This makes it easy for a
  node to restrict how much data it offers to the public network
  without restricting how much it offers to local peers on the same
  private network.  The existing `noban` permission also gives peers
  with that permission an unlimited download capability, but that may be
  changed in a future release.

- [LND #971][] adds support for controlling the maximum pending value in
  outstanding HTLCs (which are at risk of being locked up) with `openchannel`'s
  new `remote_max_value_in_flight_msat` flag. This new flag will be available to
  LND users via both the RPC interface and the command line.

- [LND #4281][] adds an `--external-hosts` command line flag that accepts
  a list of one or more domain names.  LND will periodically poll DNS
  for each domain's IP address and advertise that LND is listening for
  connections on that address.  This makes it easy for users of [dynamic
  DNS][] services to automatically update their node's advertised IP
  address.

{% include references.md %}
{% include linkers/issues.md issues="19219,14929,19464,19469,19328,19191,971,4281,18000" %}
[dynamic dns]: https://en.wikipedia.org/wiki/Dynamic_DNS
[towns post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-July/018038.html
[anyprevout spec]: https://github.com/ajtowns/bips/blob/bip-anyprevout/bip-0118.mediawiki
[anyprevout revisions]: https://github.com/ajtowns/bips/blob/bip-anyprevout/bip-0118.mediawiki#revisions
[wuille rolling]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2017-May/014337.html
[muhash]: https://cseweb.ucsd.edu/~mihir/papers/inchash.pdf
[bitcoin core 0.15]: https://bitcoincore.org/en/releases/0.15.0/#low-level-rpc-changes
[cuckoo filter]: https://github.com/bitcoin/bitcoin/pull/19219#issuecomment-652685715
[eviction-logic]: https://github.com/bitcoin/bitcoin/issues/19500#issuecomment-657257874
[news32 bcc14929]: /en/newsletters/2019/02/05/#bitcoin-core-14929
[ban vs discourage]: https://github.com/bitcoin/bitcoin/blob/f4de89edfa8be4501534fec0c662c650a4ce7ef2/src/banman.h#L29-L55
[hwi]: https://github.com/bitcoin-core/HWI
