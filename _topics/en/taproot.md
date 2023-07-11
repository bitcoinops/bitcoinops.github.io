---
title: Taproot

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Soft Forks
  - Scripts and Addresses
  - Privacy Enhancements

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
excerpt: >
  **Taproot** is a proposed soft fork change to Bitcoin that will allow
  payments to schnorr public keys that may optionally commit to a script
  that can be revealed at spend time.

## Optional
primary_sources:
    - title: BIP341
    - title: Original description
      link: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-January/015614.html
    - title: Original implementation
      link: https://github.com/bitcoin/bitcoin/pull/19953

## Optional
optech_mentions:
  - title: Reducing taproot commitment size
    url: /en/newsletters/2019/05/29/#move-the-oddness-byte

  - title: "Executive briefing: the next soft fork"
    url: /en/2019-exec-briefing/#the-next-softfork
    date: 2019-06-14
    feature: true

  - title: Overview of Taproot and Tapscript
    url: /en/newsletters/2019/05/14/#soft-fork-discussion

  - title: Extended summary of bip-taproot and bip-tapscript
    url: /en/newsletters/2019/05/14/#overview-of-the-taproot--tapscript-proposed-bips
    feature: true

  - title: Taproot (major developments of 2018, January)
    url: /en/newsletters/2018/12/28/#taproot

  - title: What a taproot soft fork might look like
    url: /en/newsletters/2018/12/18/#description-about-what-might-be-included-in-a-schnorr-taproot-soft-fork

  - title: "Suggested removal of P2SH address wrapper from taproot proposal"
    url: /en/newsletters/2019/09/25/#comment-if-you-expect-to-need-p2sh-wrapped-taproot-addresses

  - title: Update on changes to schnorr, taproot, and tapscript
    url: /en/newsletters/2019/10/16/#taproot-update

  - title: Announcement of structured taproot review
    url: /en/newsletters/2019/10/23/#taproot-review

  - title: Bitcoin Optech schnorr/taproot workshop
    url: /en/schorr-taproot-workshop/
    date: 2019-10-29
    feature: true

  - title: Impact of bech32 length-change mutablity on v1 segwit script length
    url: /en/newsletters/2019/11/13/#taproot-review-discussion-and-related-information

  - title: Blog post about x-only schnorr pubkeys
    url: /en/newsletters/2019/11/13/#x-only-pubkeys

  - title: "2019 year-in-review: taproot"
    url: /en/newsletters/2019/12/28/#taproot

  - title: Final organized review, presentation slides, and LN integration ideas
    url: /en/newsletters/2020/01/08/#final-week-of-organized-taproot-review

  - title: btcdeb adds `tap` command for experimenting with taproot and tapscript
    url: /en/newsletters/2020/02/05/#taproot-and-tapscript-experimentation-tool

  - title: Discussion about taproot versus alternatives
    url: /en/newsletters/2020/02/19/#discussion-about-taproot-versus-alternatives

  - title: Taproot security from quantum computing threats
    url: /en/newsletters/2020/02/26/#could-taproot-create-larger-security-risks-or-hinder-future-protocol-adjustments-re-quantum-threats

  - title: "Security analysis: taproot in the generic group model"
    url: /en/newsletters/2020/03/04/#taproot-in-the-generic-group-model

  - title: Request for additional signature commitment to previous scriptPubKeys
    url: /en/newsletters/2020/05/13/#request-for-an-additional-taproot-signature-commitment

  - title: "Request for comments on amending BIP341 taproot transaction digest"
    url: /en/newsletters/2020/05/20/#evaluate-proposed-changes-to-bip341-taproot-transaction-digest

  - title: Example sizes of multisig taproot transactions
    url: /en/newsletters/2020/05/27/#what-are-the-sizes-of-single-sig-and-2-of-3-multisig-taproot-inputs

  - title: Taproot eliminates vulnerability related to segwit fee overpayment attack
    url: /en/newsletters/2020/06/10/#fee-overpayment-attack-on-multi-input-segwit-transactions

  - title: BIP341 transaction digest amended with extra commitment to scriptPubKeys
    url: /en/newsletters/2020/06/10/#bips-920

  - title: "Coinpool: using taproot to help create payment pools"
    url: /en/newsletters/2020/06/17/#coinpool-generalized-privacy-for-identifiable-onchain-protocols

  - title: New chatroom for discussing taproot activation
    url: /en/newsletters/2020/07/22/#new-irc-room

  - title: Upgrading LN commitment formats, including for taproot
    url: /en/newsletters/2020/07/29/#upgrading-channel-commitment-formats

  - title: Question about leaf versions in taproot
    url: /en/newsletters/2020/07/29/#what-are-leaf-versions-in-taproot

  - title: Question about the different features in taproot for upgrading
    url: /en/newsletters/2020/07/29/#what-are-the-different-upgradability-features-in-the-bip-taproot-bip341-proposal

  - title: Discussion about backporting wtxid relay for taproot activation
    url: /en/newsletters/2020/07/29/#bitcoin-core-18044

  - title: "Discussion of various topics, including taproot activation"
    url: /en/newsletters/2020/08/05/#sydney-meetup-discussion

  - title: Discussion about taproot activation parameters
    url: /en/newsletters/2020/09/02/#taproot-activation

  - title: "Bitcoin Core #19953 merged with consensus implementation of BIP341"
    url: /en/newsletters/2020/10/21/#bitcoin-core-19953

  - title: Summary of results from surveying developers about taproot activation
    url: /en/newsletters/2020/11/04/#taproot-activation-survey-results

  - title: Website tracking miner support for taproot before signaling begins
    url: /en/newsletters/2020/11/25/#website-listing-miner-support-for-taproot-activation

  - title: "2020 year in review: Taproot, tapscript, and schnorr signatures"
    url: /en/newsletters/2020/12/23/#taproot

  - title: "Meeting to discuss taproot activation mechanisms"
    url: /en/newsletters/2021/01/27/#scheduled-meeting-to-discuss-taproot-activation

  - title: "Summary of taproot activation discussion & additional meeting scheduled"
    url: /en/newsletters/2021/02/10/#taproot-activation-meeting-summary-and-follow-up

  - title: "Summary of taproot activation discussion regarding BIP8 `LOT` parameter"
    url: /en/newsletters/2021/02/24/#taproot-activation-discussion

  - title: "Alternative methods of activating taproot discussed"
    url: /en/newsletters/2021/03/10/#taproot-activation-discussion

  - title: "Documenting the intention to use and build upon taproot"
    url: /en/newsletters/2021/03/10/#documenting-the-intention-to-use-and-build-upon-taproot

  - title: "Discussion of quantum computer attacks on taproot"
    url: /en/newsletters/2021/03/24/#discussion-of-quantum-computer-attacks-on-taproot

  - title: Regular meetings scheduled to help activate taproot
    url: /en/newsletters/2021/03/24/#weekly-taproot-activation-meetings

  - title: "Compromise proposed to use MTP to activate taproot with speedy trial"
    url: /en/newsletters/2021/04/14/#taproot-activation-discussion

  - title: "Bitcoin Core #21377 and #21686 add taproot activation mechanism and params"
    url: /en/newsletters/2021/04/21/#bitcoin-core-21377

  - title: "Miners encouraged to start signaling readiness for taproot"
    url: /en/newsletters/2021/05/05/#miners-encouraged-to-start-signaling-for-taproot

  - title: "Bitcoin Core 0.21.1 released ready to activate taproot"
    url: /en/newsletters/2021/05/05/#bitcoin-core-0-21-1

  - title: "BIPs #1104 adds activation parameters to the BIP341 taproot specification"
    url: /en/newsletters/2021/05/05/#bips-1104

  - title: "Rust Bitcoin #589 starts implementing support for taproot and schnorr signatures"
    url: /en/newsletters/2021/05/12/#rust-bitcoin-589

  - title: "Bitcoin Core #22051 adds support for importing descriptors for taproot outputs"
    url: /en/newsletters/2021/06/09/#bitcoin-core-22051

  - title: "Taproot locked in; activation to occur at block 709,632"
    url: /en/newsletters/2021/06/16/#taproot-locked-in

  - title: "Bitcoin Core #21365 allows the wallet to create signatures for P2TR spends"
    url: /en/newsletters/2021/06/23/#bitcoin-core-21365

  - title: Proposed BIP to standardize a wallet path for single-sig P2TR addresses
    url: /en/newsletters/2021/06/30/#key-derivation-path-for-single-sig-p2tr

  - title: "BIPs #1137 adds BIP86 with a key derivation scheme for single key P2TR outputs"
    url: /en/newsletters/2021/07/07/#bips-1137

  - title: Sparrow wallet adds support for P2TR keypath spends on regtest and signet
    url: /en/newsletters/2021/07/21/#sparrow-1-4-3-supports-p2tr

  - title: "Updating LN for taproot: P2TR channels"
    url: /en/newsletters/2021/09/01/#preparing-for-taproot-11-ln-with-taproot

  - title: "BTCPay server #2830 adds support for P2TR receiving and spending"
    url: /en/newsletters/2021/09/15/#btcpay-server-2830

  - title: "Specter v1.6.0 adds support for single-key taproot"
    url: /en/newsletters/2021/09/22/#specter-v1-6-0-supports-single-key-taproot

  - title: "Fully Noded v0.2.26 adds support for P2TR receiving and spending"
    url: /en/newsletters/2021/09/22/#fully-noded-v0-2-26-released

  - title: "Preparing for taproot: is cooperation always an option?"
    url: /en/newsletters/2021/10/13/#preparing-for-taproot-17-is-cooperation-always-an-option

  - title: "Taproot trivia: origins, naming, and related prior work"
    url: /en/newsletters/2021/10/20/#preparing-for-taproot-18-trivia

  - title: "Expanded test vectors for taproot published"
    url: /en/newsletters/2021/11/03/#taproot-test-vectors

  - title: "Taproot activated at block height 709,632"
    url: /en/newsletters/2021/11/17/#taproot-activated

  - title: "BIPs #1225 updates BIP341 with extended taproot test vectors"
    url: /en/newsletters/2021/11/17/#bips-1225

  - title: "2021 year-in-review: taproot"
    url: /en/newsletters/2021/12/22/#taproot

  - title: "Question: is it possible to convert a taproot address into a v0 native segwit address?"
    url: /en/newsletters/2022/01/26/#is-it-possible-to-convert-a-taproot-address-into-a-v0-native-segwit-address

  - title: "Bitcoin Core #23536 begins enforcing taproot on all blocks (except one) with segwit active"
    url: /en/newsletters/2022/04/06/#bitcoin-core-23536

  - title: "LND #6450 adds support for signing PSBTs that spend taproot outputs"
    url: /en/newsletters/2022/05/18/#lnd-6450

  - title: "Why P2TR outputs should use the noscript commitments when only keypath spending is desired"
    url: /en/newsletters/2022/06/29/#bip-341-should-key-path-only-p2tr-be-eschewed-altogether

## Optional
see_also:
  - title: MAST
    link: topic mast

  - title: Tapscript
    link: topic tapscript

  - title: Schnorr signatures
    link: topic schnorr signatures

  - title: Pay-to-contract
    link: topic p2c
---
Coins protected by taproot may be spent either by satisfying one of
the committed scripts or by simply providing a signature that verifies
against the public key (allowing the script to be kept private).
Taproot is intended for use with schnorr signatures that simplify
multiparty construction (e.g. using [MuSig][topic musig]) and with MAST to
allow committing to more than one script, any one of which may be
used at spend time.

{% include references.md %}
