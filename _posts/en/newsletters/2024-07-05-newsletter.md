---
title: 'Bitcoin Optech Newsletter #310'
permalink: /en/newsletters/2024/07/05/
name: 2024-07-05-newsletter
slug: 2024-07-05-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes the disclosure of 10 vulnerabilities
affecting old versions of Bitcoin Core and describes a proposal to allow
BOLT11 invoices to include blinded paths.  Also included are our regular
sections announcing new releases and release candidates and summarizing
notable changes to popular Bitcoin infrastructure software.

## News

- **Disclosure of vulnerabilities affecting Bitcoin Core versions before 0.21.0:**
  Antoine Poinsot [posted][poinsot disclose] to the Bitcoin-Dev mailing
  list a link to an [announcement][bcco announce] of 10 vulnerabilites
  affecting versions of Bitcoin Core that have been past their
  end-of-life for almost two years<!-- 0.21.x EOL 2022-10-01 per
  https://bitcoincore.org/en/lifecycle/ -->.  We summarize the
  disclosures below: {% assign timestamp="0:59" %}

  - [Remote code execution due to bug in miniupnpc][]: before Bitcoin
    Core 0.11.1 (released October 2015), nodes had [UPnP][] enabled by
    default to allow them to receive incoming connections through
    [NAT][].  This was accomplished using the [miniupnpc library][],
    which Aleksandar Nikolic discovered to be vulnerable to various
    remote attacks ([CVE-2015-6031][]).  This was fixed in the upstream
    library, the fix incorporated into Bitcoin Core, and an update was
    made to disable UPnP by default.  While investigating the bug,
    Bitcoin developer Wladimir J. Van Der Laan discovered another remote
    code execution vulnerability in the same library.  This was
    [responsibly disclosed][topic responsible disclosures], fixed in the
    upstream library, and incorporated into Bitcoin Core 0.12 (released
    February 2016).

  - [Node crash DoS from multiple peers with large messages][]: before
    Bitcoin Core 0.10.1, nodes would accept P2P messages up to about 32
    megabytes in size.  Nodes, then and now, also allowed up to about
    130 connections by default<!-- 125 incoming + 8 outgoing on old
    nodes; more on recent nodes -->.  If every peer sent a maximum-size
    message at roughly the same time, this would force a node to
    allocate about 4 gigabytes of memory in addition to the node's other
    requirements, which was more than many nodes had available.  The
    vulnerability was responsibly disclosed by BitcoinTalk.org user
    Evil-Knievel, assigned [CVE-2015-3641][],  and fixed in Bitcoin Core
    0.10.1 by limiting the maximum message size to about 2 megabytes
    (later increased to about 4 megabytes for segwit).

  - [Censorship of unconfirmed transactions][]: new transactions are
    typically announced by a peer informing a node of the transaction
    txid or wtxid.  The first time a node sees a txid or wtxid, it
    requests the complete transaction from the first peer that announced
    it.  As the node waits for that peer to respond, it keeps track of
    other peers that announce the same txid or wtxid.  If the first peer
    doesn't respond with the transaction before a timeout, the node
    requests it from the second peer (and, if that request times out,
    the third peer, and so on).

    Before Bitcoin Core 0.21.0, a node only kept track of 50,000
    requests.  This allowed the first peer to announce a txid, delay
    responding to the node's request for the full transaction, wait for
    all of the node's other peers to announce the transaction, and send
    50,000 announcements of other txids (possibly all of them bogus).
    That way, when the node's original request to the first peer timed
    out, it wouldn't request it from any other peers.  The attacker (the
    first peer) could repeat this attack indefinitely to permanently
    prevent the node from ever receiving the transaction.  Note that
    censorship of unconfirmed transactions can prevent transaction from
    being confirmed promptly, which can lead to the loss of funds in
    contract protocols such as LN.  John Newbery, citing co-discovery by
    Amiti Uttarwar, responsibly disclosed the vulnerability and a fix
    was released in Bitcoin Core 0.21.0.

  - [Unbound ban list CPU/memory DoS][]: Bitcoin Core
    [PR #15617][bitcoin Core #15617] (first included in version 0.19.0)
    added code that checked every IP address banned by the local node up
    to 2,500 times whenever a P2P `getaddr` message was received.  The
    length of a node's ban list was unbound and it could grow to immense
    size if an attacker controlled a large number of IP addresses (e.g.
    easy-to-obtain IPv6 address).  When the list was long, each
    `getaddr` request could consume an excessive amount of CPU and
    memory, potentially making the node unusable or leading to a crash.
    The vulnerability was assigned [CVE-2020-14198][] and fixed in
    Bitcoin Core 0.20.1. <!-- FYI: not responsibly disclosed -->

  - [Netsplit from excessive time adjustment][]: older versions of
    Bitcoin Core allowed their clocks to be skewed by an average of the
    time reported by the first 200 peers they connected to.  The code
    meant to allow a maximum skew of 70 minutes.  All versions of
    Bitcoin Core temporarily ignore any blocks with a timestamp more
    than two hours in the future.  A combination of two bugs could allow
    an attacker to skew the victims clock more than two hours into the
    past, resulting in it potentially ignoring blocks with accurate
    timestamps.  The vulnerability was responsibly disclosed by
    developer practicalswift and fixed in Bitcoin Core 0.21.0.

  - [CPU DoS and node stalling from orphan handling][]: Bitcoin Core
    nodes keep a cache of up to 100 transactions, called _orphan
    transactions_, for which the node doesn't have the necessary parent
    transaction details in its mempool or UTXO set.  After a new
    transaction is validated, the node checks to see if any of the
    orphan transactions can now be processed.  Before Bitcoin Core
    0.18.0, each time the orphan cache was checked, the node would
    attempt to validate each of the orphan transactions using the latest
    mempool and UTXO state.  If all 100 of the cached orphan
    transactions were constructed to require excessive CPU to validate,
    the node would waste an excessive amount of CPU and would not be
    able to process new blocks and transactions for several hours.  This
    attack was essentially free to perform: orphan transactions are free
    to create because they can reference non-existent parent
    transaction.  A stalled node would be unable to generate block
    templates, potentially preventing a miner from earning revenue, and
    could be used to prevent transactions from being confirmed,
    potentially resulting in users of contract protocols (such as LN)
    losing money.  Developer sec.eine responsibly disclosed the
    vulnerability and it was fixed in Bitcoin Core 0.18.0.

  - [Memory DoS from large `inv` messages][]: a P2P `inv` message can
    contain a list of up to 50,000 block header hashes.  Modern Bitcoin
    Core nodes before version 0.20.0 would reply to that message with a
    separate P2P `getheaders` message for each hash it didn't recognize,
    with each message being about 1 kilobyte.  That resulted in the node
    storing about 50 megabytes of messages in memory waiting for its peer
    to accept them.  This could be performed by all of a node's peers
    (up to approximately 130 by default) to use more than 6.5 gigabytes
    of memory in addition to the node's regular memory
    requirements---enough to crash many nodes.  Crashed nodes may be
    unable to process timely transactions for users of contract
    protocols, potentially resulting in the loss of money.  John Newbery
    responsibly disclosed the vulnerability and provided a fix that
    responded to any number of hashes in an `inv` message with a single
    `getheaders` message; the fix was included in Bitcoin Core 0.20.0.

  - [Memory DoS using low-difficulty headers][]: since Bitcoin Core
    0.10, a node requests that each of its peers send it block headers from
    their _best blockchain_ (valid blockchain with the most
    proof-of-work).  A known problem with this approach is that a
    malicious peer could spam the node with a large number of bogus
    headers belonging to low-difficulty blocks (e.g. difficulty-1),
    which are trivial to create with modern ASIC mining equipment.
    Bitcoin Core initially addressed this problem by only accepting
    headers on a chain that matched _checkpoints_ hardcoded into Bitcoin
    Core.  The last checkpoint, though from 2014,<!-- block 295,000 -->
    had a moderately high difficulty by modern standards, so it would
    require significant effort to create bogus headers starting from it.
    However, a code change incorporated in Bitcoin Core 0.12 allowed the
    node to begin accepting low-difficulty headers into memory,
    potentially allowing an attacker to fill memory with bogus headers.
    This could lead to the node crashing, which could result in the loss
    of funds for users of contract protocols (such as LN).  Cory Fields
    responsibly disclosed the vulnerability and it was fixed in version
    0.15.0.

  - [CPU-wasting DoS due to malformed requests][]: before Bitcoin Core
    0.20.0, an attacker or buggy peer could send an malformed P2P
    `getdata` message that would result in the message processing thread
    consuming 100% CPU.  The node would also no longer be able to
    receive messages from the attacker for the duration of its
    connection, although it would still be able to receive messages from
    honest peers.  This could be problematic for nodes on computers with
    small numbers of CPU cores but was otherwise a nuisance.  John
    Newbery responsibly disclosed the vulnerability and provided a fix,
    which was incorporated into Bitcoin Core 0.20.0.

  - [Memory-related crash in attempts to parse BIP72 URIs][]: Bitcoin
    Core before 0.20.0 supported the [BIP70 payment protocol][topic
    bip70 payment protocol] which extended [BIP21][] `bitcoin:` URIs
    with an `r` parameter defined in [BIP72][] that references an
    HTTP(S) URL.  Bitcoin Core would attempt to download the file at the
    URL and store it in memory for parsing, but if the file was larger
    than the available memory, Bitcoin Core would eventually be
    terminated.  As the attempted download happens in the background, a
    user might walk away from the node before the crash happens,
    preventing them from noticing the crash and promptly restarting what
    could be a crucial service.  The vulnerability was responsibly
    disclosed by Michael Ford and fixed by removing BIP70 support in
    Bitcoin Core 0.20.0 (see [Newsletter #70][news70 bip70]).

  Poinsot's announcement said additional vulnerabilities fixed in
  Bitcoin Core 22.0 would be announced later this month, and
  vulnerabilities fixed in 23.0 would follow next month.
  Vulnerabilities fixed in later versions will be disclosed according to
  Bitcoin Core's [new disclosure policy][] as previously discussed (see
  [Newsletter #306][news306 disclosure]).

- **Adding a BOLT11 invoice field for blinded paths:** Elle Mouton
  [posted][mouton b11b] to Delving Bitcoin a proposed BLIP specification
  for an optional field that could be added to [BOLT11][] invoices to
  communicate a [blinded path][topic rv routing] for paying the
  receiver's node.  For example, businessperson Bob wants to receive a
  payment from customer Alice but does not want to disclose the identity
  of his node or of the peers with whom he shares channels.  He
  generates a blinded path starting a few hops out from his node and
  adds that to an otherwise-standard BOLT11 invoice that he gives Alice.
  If Alice uses software that can parse that invoice and route a
  payment using blinded paths, she can pay Bob.

  If Alice uses software that doesn't support the BLIP, she will be
  unable to pay the invoice and will receive an error message.

  Mouton notes in the BLIP that blinded paths in BOLT11 is only intended
  to be used until the [offers][topic offers] protocol has been widely
  deployed for communicating invoices, as that natively uses blinded
  paths and has other advantages over BOLT11 invoices.

  Bastien Teinturier [argued][teinturier b11b] against the idea and the
  related idea of exposing the offers invoice format.  He prefers
  instead to focus on full deployment of offers, believing that it will
  get the system towards its ultimate state faster as well as eliminate
  the burden of supporting intermediate states for an indefinite amount
  of time.  He believes that users receiving error codes when attempting
  to pay BOLT11 invoices with blinded paths will ask developers to add
  support for that feature, distracting them from working on offers.

  Olaoluwa Osuntokun [replied][osuntokun b11b] that he prefers to work
  on blinded paths separately from the other dependencies of offers to
  ensure that it works as well as possible.  He imagines BOLT11 invoices
  with blinded paths being used in protocols such as [L402][] where
  clients are already directly communicating with servers, giving them
  many of the benefits of offers, so they only need this small upgrade
  to use blinded paths to obtain the same privacy that offers would
  provide.

  At the time of writing, it wasn't clear whether the discussion had
  concluded.  BLIPs are optional specifications and it appeared from the
  discussion that this BLIP might be implemented in LND but not in
  Eclair or lightning-kmp (the basis for Phoenix wallet); plans for
  other implementations were not discussed. {% assign timestamp="22:17" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 26.2rc1][] is a release candidate for a maintenance
  version of Bitcoin Core's older release series. {% assign timestamp="36:43" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #28167][] introduces `-rpccookieperms` as a new `bitcoind`
  startup option, allowing users to set file read permissions for the RPC
  authentication cookie by choosing between owner (default), group, or all
  users. {% assign timestamp="37:48" %}

- [Bitcoin Core #30007][] adds Ava Chow's (achow101) DNS seeder to `chainparams`
  to provide an additional trusted source of peer discovery. It uses
  [Dnsseedrs][dnsseedrs], a new open source bitcoin DNS seeder written in Rust that
  crawls node addresses on the IPv4, IPv6, Tor v3, I2P,
  and CJDNS networks. {% assign timestamp="39:07" %}

- [Bitcoin Core #30200][] introduces a new `Mining` interface.  Existing
  RPCs like `getblocktemplate` and `generateblock` begin using the
  interface immediately.  Future work like a [Stratum V2][topic pooled
  mining] interface that uses Bitcoin Core as the template provider will
  use the new mining interface. {% assign timestamp="40:37" %}

- [Core Lightning #7342][] corrects the handling of a startup edge case where
  the service aborts because it detects that `bitcoind` has gone backwards on
  its block height, which may happen during a blockchain reorganization.
  It will now wait for the block header height to reach the previous
  level and begin scanning the newly received (reorged) blocks. {% assign timestamp="41:33" %}

- [LND #8796][] loosens restrictions on channel opening parameters by now
  allowing peers to initiate non-[zero-conf][topic zero-conf channels] channels
  with a `min_depth` of zero. Nonetheless, LND will still wait for at least one
  confirmation before considering the channel usable. This change improves
  interoperability with other Lightning implementations that support this, such
  as LDK, and aligns with the [BOLT2][] specification. {% assign timestamp="42:55" %}

- [LDK #3125][] introduces support for encoding and parsing `HeldHtlcAvailable`
  and `ReleaseHeldHtlc` messages required by the upcoming implementation of
  [async payments][topic async payments] protocol. It also adds [onion message][topic onion messages]
  payloads to these messages, and an `AsyncPaymentsMessageHandler` trait for
  `OnionMessenger`. {% assign timestamp="45:26" %}

- [BIPs #1610][] adds [BIP379][BIP379 md] with a specification for [Miniscript][topic
  miniscript], a language that compiles to Bitcoin Script but which allows
  composition, templating, and definitive analysis. See [Newsletter #304][news304
  miniscript] for an earlier reference to this BIP. {% assign timestamp="46:21" %}

- [BIPs #1540][] adds BIPs [328][bip328], [390][bip390], and [373][bip373] with a specification for a
  [MuSig2][topic musig] derivation scheme for aggregate keys (328), output
  script [descriptors][topic descriptors] (390), and [PSBT][topic psbt] fields
  to allow MuSig2 data to be included in a PSBT of any version (373). MuSig2 is
  a protocol for aggregating public keys and signatures for the [schnorr digital
  signature][topic schnorr signatures] algorithm that requires only two rounds
  of communication (MuSig1 requires three) to provide a signing experience
  that does not differ excessively from script-based multisig. The derivation scheme allows for
  [BIP32][topic bip32]-style extended public keys to be constructed from a [BIP327][]
  MuSig2 aggregate public key. {% assign timestamp="49:07" %}

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28167,30007,30200,7342,8796,3125,1610,1540,15617" %}
[bitcoin core 26.2rc1]: https://bitcoincore.org/bin/bitcoin-core-26.2/
[mouton b11b]: https://delvingbitcoin.org/t/blip-bolt-11-invoice-blinded-path-tagged-field/991
[teinturier b11b]: https://delvingbitcoin.org/t/blip-bolt-11-invoice-blinded-path-tagged-field/991/5
[osuntokun b11b]: https://delvingbitcoin.org/t/blip-bolt-11-invoice-blinded-path-tagged-field/991/6
[l402]: https://github.com/lightninglabs/L402
[remote code execution due to bug in miniupnpc]: https://bitcoincore.org/en/2024/07/03/disclose_upnp_rce/
[cve-2015-6031]: https://nvd.nist.gov/vuln/detail/CVE-2015-6031
[node crash dos from multiple peers with large messages]: https://bitcoincore.org/en/2024/07/03/disclose_receive_buffer_oom/
[censorship of unconfirmed transactions]: https://bitcoincore.org/en/2024/07/03/disclose_already_asked_for/
[unbound ban list cpu/memory dos]: https://bitcoincore.org/en/2024/07/03/disclose-unbounded-banlist/
[netsplit from excessive time adjustment]: https://bitcoincore.org/en/2024/07/03/disclose-timestamp-overflow/
[cpu dos and node stalling from orphan handling]: https://bitcoincore.org/en/2024/07/03/disclose-orphan-dos/
[memory dos from large `inv` messages]: https://bitcoincore.org/en/2024/07/03/disclose-inv-buffer-blowup/
[memory dos using low-difficulty headers]: https://bitcoincore.org/en/2024/07/03/disclose-header-spam/
[cpu-wasting dos due to malformed requests]: https://bitcoincore.org/en/2024/07/03/disclose-getdata-cpu/
[news70 bip70]: /en/newsletters/2019/10/30/#bitcoin-core-17165
[memory-related crash in attempts to parse BIP72 URIs]: https://bitcoincore.org/en/2024/07/03/disclose-bip70-crash/
[cve-2020-14198]: https://nvd.nist.gov/vuln/detail/CVE-2020-14198
[news306 disclosure]: /en/newsletters/2024/06/07/#upcoming-disclosure-of-vulnerabilities-affecting-old-versions-of-bitcoin-core
[upnp]: https://en.wikipedia.org/wiki/Universal_Plug_and_Play
[nat]: https://en.wikipedia.org/wiki/Network_address_translation
[miniupnpc library]: https://miniupnp.tuxfamily.org/
[poinsot disclose]: https://mailing-list.bitcoindevs.xyz/bitcoindev/xsylfaVvODFtrvkaPyXh0mIc64DWMCchxiVdTApFqJ_0Q5v0bOoDpS_36HwDKmzdDO9U2RKMzESEiVaq47FTamegi2kCNtVZeDAjSR4G7Ic=@protonmail.com/
[bcco announce]: https://bitcoincore.org/en/security-advisories/
[new disclosure policy]: https://mailing-list.bitcoindevs.xyz/bitcoindev/rALfxJ5b5hyubGwdVW3F4jtugxnXRvc-tjD_qwW7z73rd5j7lXGNdEHWikmSdmNG3vkSOIwEryZzOZr_DgmVDDmt9qsX0gpRAcpY9CfwSk4=@protonmail.com/T/#u
[CVE-2015-3641]: https://nvd.nist.gov/vuln/detail/CVE-2015-3641
[dnsseedrs]: https://github.com/achow101/dnsseedrs
[news304 miniscript]: /en/newsletters/2024/05/24/#proposed-miniscript-bip
[BIP379 md]: https://github.com/bitcoin/bips/blob/master/bip-0379.md
