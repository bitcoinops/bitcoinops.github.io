---
title: Adaptor signatures

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#aliases:

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Contract Protocols
  - Privacy Enhancements
  - Scripts and Addresses

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Adaptor signatures** are auxiliary signature data that commit to a a
  hidden value.  When an adaptor signature is combined with a final
  signature, it reveals the hidden value.  Alternatively, when combined
  with the hidden value, it reveals the final signature.  The commitment
  may be reused in other signatures without the secondary signers
  knowing the hidden value or their own final signature.

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
extended_summary: |
  Adaptor signatures never need to be published onchain.   To anyone
  without a corresponding adaptor signature, a final signature looks
  like any other digital signature, giving adaptor signatures efficiency
  and privacy advantages over other onchain locking mechanisms such as
  hashlocks and preimages.

  ### Example

  The multiple uses of adaptor signatures can be seen in a simple
  coinswap protocol.  For example, Alice can give Bob an adaptor
  signature for a transaction that promises to pay him 1 BTC.  An
  adaptor signature by itself can't be used as a final signature, so
  Alice hasn't paid Bob yet.

  What the adaptor signature does provide Bob is a commitment to Alice's
  hidden value.  This commitment is made in the form of a value Bob can
  can use to create a second adaptor signature that commits to the same
  hidden value as Alice's adaptor signature.  Bob can make that
  commitment even without knowing Alice's hidden value or his own final
  signature for that commitment.  Bob gives Alice his adaptor signature
  and a corresponding transaction that promises to pay her 1 BTC.

  Alice has always known the hidden value, so she can combine the hidden
  value with Bob's adaptor signature to get his final signature for the
  transaction that pays her.  She broadcasts the transaction and
  receives Bob's payment.  When Bob sees that transaction onchain, he
  can combine its final signature with the adaptor signature he gave
  Alice, allowing him to to derive the hidden value.  Then he can
  combine that hidden value with the adaptor signature Alice gave him to
  get her final signature for the first transaction.  Bob broadcasts
  that transaction to receive Alice's payment, completing the coinswap.

  Besides coinswaps, there are several other [proposed uses][scriptless
  scripts repo] for adaptor signatures.

  <div class="qa_details">
  <details markdown="1"><summary>Click to show the same coinswap example in mathematical terms</summary>
  *In the following example, we assume the use of BIP340-compatible
  schnorr signatures.  We use lowercase variables for scalars and
  uppercase variables for elliptic curve points.  We represent
  concatenation with `||` and the hash function with `H()`.*

  Alice creates a valid final signature (`s`) for the transaction paying Bob
  (`m`) using her private key (`p`), which corresponds to her public key
  (`P = pG`).  She also uses a private random nonce (`r`), a hidden value
  (`t`), and the elliptic curve points for them (`R = rG, T = tG`):

      s = r + t + H(P || R + T || m) * p

  She removes `t` from the final signature to produce an adaptor
  signature:

      s' = s - t

  She gives Bob the adaptor signature, which consists of the following
  data:

      s', R, T

  Bob can verify the adaptor signature:

      s' * G ?= R + H(P || R+T || m) * P

  But it's not a valid signature.  For a valid signature, BIP340 expects
  `x` and `Y`, using them with the expression:

      x * G ?= Y + H(P || Y || m) * P

  However,

  - If Bob sets `Y=R` so that it matches the `s'` he received in the
    adaptor signature, then BIP340 is going to fail on `H(P || R || m)`
    since Alice computed her hash with `H(P || R + T || m)`.

  - If Bob sets `Y=R + T` so that it matches `H(P || R + T || m)`, BIP340
    is going to fail on the initial `Y` since Bob is providing `R + T`
    rather than the needed `R`.

  Therefore Bob can't use the adaptor signature as a final signature.
  However, he can create his own signature using it.  This is similar to
  signature Alice created but Bob doesn't commit to `t` here, since Bob
  doesn't know that value.  All variables here except `T` are different
  for Bob than they were for Alice:

      s = r + H(P || R + T || m) * p

  Unlike Alice, Bob doesn't need to tweak his signature.  Bob's `s` is
  not a valid signature because it commits to `r` and `R + T`, which
  won't pass BIP340 verification for the same reasons previously described.
  To be valid, the signature needs to commit to `r + t` and `R + T`,
  which Bob can't produce since he doesn't know `t`.

  Bob gives Alice his adaptor signature:

      s, R, T

  Alice already knew `T`, but `(s, R, T)` is a standard adaptor
  signature so we use its full form.  Alice can produce a final
  signature from that adaptor signature using the hidden `t` value that
  only she knows so far:

      (s + t) * G ?= R + T + H(P || R + T || m) * P

  Alice uses the final signature to broadcast Bob's transaction that
  pays her.  When Bob sees `(s + t)` onchain, he can learn the value of `t`:

      t = (s + t) - s

  He can then use `t` to solve the adaptor signature Alice gave him
  earlier:

      (s' + t) * G ?= R + T + H(P || R + T || m) * P

  Bob uses that final signature to broadcast the transaction Alice
  originally gave him.
  </details><br>
  </div>

  ### Relationship to multiparty signatures

  Adaptor signatures usually can't secure a contract entirely by
  themselves.  For example, in the above description of a coinswap,
  Alice could double spend her payment to Bob after she learned Bob's
  final signature, or Bob could've tried the same in reverse (with more
  difficulty since we assumed Alice's transaction had one confirmation).
  This is usually addressed by combining adaptor signatures with
  multiparty signatures.  For example, Alice deposits her money into an
  address that requires signatures from both her and Bob to spend.  Now
  Alice can provide Bob with an adaptor signature for her half of the
  multiparty transaction, which Bob can accept with perfect safety
  knowing that Alice couldn't double spend the transaction without a
  signature from him.  This may additionally require a timelocked refund
  option in case one party refuses to sign.

  In the [schnorr signature scheme][topic schnorr signatures], adaptor
  signatures are usually proposed to be combined with signature
  aggregation schemes such as [MuSig][topic musig] to allow the final
  multiparty signature to look like a single-party signature, enhancing
  privacy and efficiency.  This is also possible in ECDSA but it
  requires additional security assumptions and relatively novel
  algorithms.  Instead, an [alternative scheme][otves] for adaptor
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

  - title: "Taproot privacy gains, including those from adaptor signatures"
    url: /en/newsletters/2020/02/19/#tap1
    date: 2020-02-19

  - title: "Boomerang contracts using adaptor signatures for LN latency & throughput"
    url: /en/newsletters/2020/02/26/#boomerang-redundancy-improves-latency-and-throughput-in-payment-channel-networks
    date: 2020-02-26

  - title: ECDSA adaptor signatures for statechains with secure multiparty computation
    url: /en/newsletters/2020/04/01/#implementing-statechains-without-schnorr-or-eltoo
    date: 2020-04-01

  - title: Work on PTLCs for LN using simplified ECDSA adaptor signatures
    url: /en/newsletters/2020/04/08/#work-on-ptlcs-for-ln-using-simplified-ecdsa-adaptor-signatures
    date: 2020-04-08

  - title: Paying for a PTLC pointlock using an adaptor signature
    url: /en/newsletters/2020/06/24/#continued-discussion-about-ln-atomicity-attack
    date: 2020-06-24

  - title: Multiparty ECDSA for scriptless LN channels
    url: /en/newsletters/2018/10/09/#multiparty-ecdsa-for-scriptless-lightning-network-payment-channels
    date: 2018-10-09

  - title: Fast multiparty ECDSA compatible with adaptor signatures
    url: /en/newsletters/2018/10/23/#two-papers-published-on-fast-multiparty-ecdsa
    date: 2018-10-23

  - title: Discussion about problems in LN solvable using adaptor signatures
    url: /en/newsletters/2018/11/06/#discussion-about-improving-lightning-payments
    date: 2018-11-06

  - title: libsecp256k1-zkp library updated with support for adaptor signatures
    url: /en/newsletters/2019/02/26/#schnorr-ready-fork-of-libsecp256k1-available
    date: 2019-02-26

  - title: "Q&A: what's the difference between taproot and adaptor signatures?"
    url: /en/newsletters/2019/02/26/#taproot-and-scriptless-scripts-both-use-schnorr-but-how-are-they-different
    date: 2019-02-26

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Schnorr signatures
    link: topic schnorr signatures

  - title: MuSig key and signature aggregation
    link: topic musig

---
