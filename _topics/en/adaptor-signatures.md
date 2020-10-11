---
title: Adaptor signatures

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
aliases:
  - Signature adaptors
  - Scriptless scripts

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Contract Protocols
  - Privacy Enhancements
  - Scripts and Addresses

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Adaptor signatures** (also called **signature adaptors**) are
  auxiliary signature data that commit to a hidden value.  When an
  adaptor is combined with a corresponding signature, it reveals
  the hidden value.  Alternatively, when combined with the hidden value,
  the adaptor reveals the signature.  Other people may create secondary
  adaptors that reuse the commitment even if they don't know the hidden
  value. This makes adaptors a powerful tool for implementing locking in
  bitcoin contracts.

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
extended_summary: |
  Contracts in Bitcoin often require a locking mechanism to ensure the
  atomicity of a set of payments---either all the payments succeed or
  all of them fail.  This locking has traditionally been done by having
  all payments in the set commit to the same hash digest preimage; when
  the party who knows the preimage reveals it onchain, everyone else
  learns it and can unlock their own payments.  Commonly used *hashlocks*
  in Bitcoin consume about 67 bytes <!-- push32:1, preimage:32,
  push32:1, hash:32, OP_CHECKEQUALVERIFY:1 --> and reveal the link
  between the set of payments because they all use the same preimage and
  digest.

  By comparison, signature adaptors never need to be published onchain.   To anyone
  without a corresponding adaptor, a signature created with an adaptor looks
  like any other digital signature, giving adaptors significant efficiency
  and privacy advantages over hashlocks.

  ### Example

  The multiple uses of signature adaptors can be seen in a simple
  coinswap protocol.  For example, Alice can give Bob an adaptor
  for an unsigned transaction that promises to pay him 1 BTC.  An
  adaptor by itself can't be used as a BIP340 signature, so
  Alice hasn't paid Bob yet.

  What the adaptor does provide Bob is a commitment to Alice's hidden
  value.  This commitment includes a parameter Bob can use to create a
  second adaptor that commits to the same hidden value as Alice's
  adaptor.  Bob can make that commitment even without knowing Alice's
  hidden value or his own signature for that commitment.  Bob gives
  Alice his adaptor and a corresponding unsigned transaction that
  promises to pay her 1 BTC.

  Alice has always known the hidden value, so she can combine the hidden
  value with Bob's adaptor to get his signature for the
  transaction that pays her.  She broadcasts the transaction and
  receives Bob's payment.  When Bob sees that transaction onchain, he
  can combine its signature with the adaptor he gave
  Alice, allowing him to derive the hidden value.  Then he can
  combine that hidden value with the adaptor Alice gave him earlier.
  Bob broadcasts
  that transaction to receive Alice's payment, completing the coinswap.

  Besides coinswaps, there are several other [proposed uses][scriptless
  scripts repo] for adaptor signatures.

  <div class="qa_details">
  <details markdown="1"><summary>Click to display the same coinswap example in mathematical terms</summary>
  *In the following example, we assume the use of BIP340
  schnorr signatures.  We use lowercase variables for scalars and
  uppercase variables for elliptic curve points.  We represent
  concatenation with `||` and the hash function with `H()`.*

  Alice creates a valid signature commitment (`s`) for the transaction paying Bob
  (`m`) using her private key (`p`), which corresponds to her public key
  (`P = pG`).  She also uses a private random nonce (`r`), a hidden value
  (`t`), and the elliptic curve points for them (`R = rG, T = tG`):

      s = r + t + H(P || R + T || m) * p

  She subtracts `t` from the signature commitment to produce a signature adaptor:

      s' = s - t

  She gives Bob the adaptor, which consists of the following
  data:

      s', R, T

  Bob can verify the adaptor:

      s' * G ?= R + H(P || R+T || m) * P

  But the adaptor is not a valid BIP340 signature.  For a valid signature, BIP340 expects
  `x` and `Y`, using them with the expression:

      x * G ?= Y + H(P || Y || m) * P

  However,

  - If Bob sets `Y = R` so that it matches the `s'` he received in the
    adaptor, then BIP340 is going to fail on `H(P || R || m)`
    since Alice computed her hash with `H(P || R + T || m)`.

  - If Bob sets `Y = R + T` so that it matches `H(P || R + T || m)`, BIP340
    is going to fail on the initial `Y` since Bob is providing `R + T`
    rather than the needed `R`.

  Therefore Bob can't use the adaptor as a BIP340 signature.
  However, he can create his own adaptor using it.  This is similar to the
  signature Alice created but Bob doesn't commit to `t` here, since Bob
  doesn't know that value.  All variables here except `T` are different
  for Bob than they were for Alice:

      s = r + H(P || R + T || m) * p

  Unlike Alice, Bob doesn't need to tweak his signature.  Bob's signature commitment `s` is
  not a part of a valid signature because it commits to `r` and `R + T`, which
  won't pass BIP340 verification for the same reasons previously described.
  To be valid, the signature needs to commit to `r + t` and `R + T`,
  which Bob can't produce since he doesn't know `t`.

  Bob gives Alice his adaptor:

      s, R, T

  Alice already knew `T`, but `(s, R, T)` is a standard signature
  adaptor so we use its full form.  Alice can produce a
  signature from that adaptor using the hidden `t` value that
  only she knows so far:

      (s + t) * G ?= R + T + H(P || R + T || m) * P

  Alice uses the signature to broadcast Bob's transaction that
  pays her.  When Bob sees `(s + t)` onchain, he can learn the value of `t`:

      t = (s + t) - s

  He can then use `t` to solve the adaptor Alice gave him
  earlier:

      (s' + t) * G ?= R + T + H(P || R + T || m) * P

  Bob uses that signature to broadcast the transaction Alice
  originally gave him.
  </details><br>
  </div>

  ### Relationship to multiparty signatures

  Signature adaptors usually can't secure a contract entirely by
  themselves.  For example, in the above description of a coinswap,
  Alice could double spend her payment to Bob after she learned Bob's
  signature, or Bob could've tried the same in reverse (with more
  difficulty since we assumed Alice's transaction had one confirmation).
  This issue is typically addressed by combining signature adaptors with
  multiparty signatures.  For example, Alice deposits her money into an
  address that can only be spent if both she and Bob collaborate to
  create a valid signature.  Now Alice can provide Bob with an adaptor
  for her half of the multiparty signature, which Bob can accept with
  perfect safety knowing that Alice couldn't double spend the funds
  without his participation.  This may additionally require a timelocked
  refund option in case one party refuses to sign.

  In the [schnorr signature scheme][topic schnorr signatures],
  signature adaptors are usually proposed to be combined with multiparty signature
  schemes such as [MuSig][topic musig] to allow the published
  signature to look like a single-party signature, enhancing
  privacy and efficiency.  This is also possible in ECDSA but it
  requires novel algorithms that are either comparatively slow or
  require additional security assumptions.  Instead, an [alternative scheme][otves] for adaptor
  signatures exists for Bitcoin that uses 2-of-2 `OP_CHECKSIG` multisig;
  this is less efficient and possibly less private---but arguably
  simpler and safer than multiparty ECDSA.

  [otves]: https://github.com/LLFourn/one-time-VES/blob/master/main.pdf
  [scriptless scripts repo]: https://github.com/ElementsProject/scriptless-scripts

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Scriptless scripts slides (PDF)
      link: https://download.wpsoftware.net/bitcoin/wizardry/mw-slides/2017-05-milan-meetup/slides.pdf

    - title: One-time verifiably encrypted signatures (PDF)
      link: https://github.com/LLFourn/one-time-VES/blob/master/main.pdf

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: "Presentation: Blockchain design patterns: Layers and scaling approaches"
    url: /en/newsletters/2019/09/18/#blockchain-design-patterns-layers-and-scaling-approaches
    date: 2019-09-18

  - title: "Taproot privacy gains, including those from signature adaptors"
    url: /en/newsletters/2020/02/19/#tap1
    date: 2020-02-19

  - title: "Boomerang contracts using signature adaptors for LN latency & throughput"
    url: /en/newsletters/2020/02/26/#boomerang-redundancy-improves-latency-and-throughput-in-payment-channel-networks
    date: 2020-02-26

  - title: ECDSA signature adaptors for statechains with secure multiparty computation
    url: /en/newsletters/2020/04/01/#implementing-statechains-without-schnorr-or-eltoo
    date: 2020-04-01

  - title: Work on PTLCs for LN using simplified ECDSA signature adaptors
    url: /en/newsletters/2020/04/08/#work-on-ptlcs-for-ln-using-simplified-ecdsa-adaptor-signatures
    date: 2020-04-08

  - title: Paying for a PTLC pointlock using an signature adaptors
    url: /en/newsletters/2020/06/24/#continued-discussion-about-ln-atomicity-attack
    date: 2020-06-24

  - title: Multiparty ECDSA for scriptless LN channels
    url: /en/newsletters/2018/10/09/#multiparty-ecdsa-for-scriptless-lightning-network-payment-channels
    date: 2018-10-09

  - title: Fast multiparty ECDSA compatible with signature adaptors
    url: /en/newsletters/2018/10/23/#two-papers-published-on-fast-multiparty-ecdsa
    date: 2018-10-23

  - title: Discussion about problems in LN solvable using signature adaptors
    url: /en/newsletters/2018/11/06/#discussion-about-improving-lightning-payments
    date: 2018-11-06

  - title: libsecp256k1-zkp library updated with support for signature adaptors
    url: /en/newsletters/2019/02/26/#schnorr-ready-fork-of-libsecp256k1-available
    date: 2019-02-26

  - title: "Q&A: what's the difference between taproot and signature adaptors?"
    url: /en/newsletters/2019/02/26/#taproot-and-scriptless-scripts-both-use-schnorr-but-how-are-they-different
    date: 2019-02-26

  - title: "Using signature adaptors for witness asymmetric payment channels"
    url: /en/newsletters/2020/09/02/#witness-asymmetric-payment-channels

  - title: Revised witness asymmetric channels proposal with signature adaptors
    url: /en/newsletters/2020/10/14/#updated-witness-asymmetric-payment-channel-proposal

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Schnorr signatures
    link: topic schnorr signatures

  - title: MuSig key and signature aggregation
    link: topic musig

  - title: Using schnorr subtraction to create more private coinswaps
    link: https://joinmarket.me/blog/blog/flipping-the-scriptless-script-on-schnorr/

  - title: Adaptor signatures for discreet log contracts
    link: https://lists.launchpad.net/mimblewimble/msg00485.html
---
