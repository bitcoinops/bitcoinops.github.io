---
title: Statechains

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Contract Protocols

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Statechains
      link: https://medium.com/@RubenSomsen/statechains-non-custodial-off-chain-bitcoin-transfer-1ae4845a4a39

    - title: Statechains with ECDSA and without eltoo
      link: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017714.html

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: "Bitcoin Core contributor meeting discussion topic: blind statechains"
    url: /en/newsletters/2019/06/12/#assumeutxo

  - title: Discussion about implementing statechains without schnorr or eltoo
    url: /en/newsletters/2020/04/01/#implementing-statechains-without-schnorr-or-eltoo

  - title: Transcript about watchtowers and their usefulness for statechains
    url: /en/newsletters/2020/07/01/#watchtowers-and-bolt13

  - title: Transcript of discussion about multiple topics, including statechains
    url: /en/newsletters/2020/09/02/#sydney-meetup-discussion

  - title: Discussion about blind MuSig2 signing for statechains
    url: /en/newsletters/2023/08/02/#safety-of-blind-musig2-signing

  - title: Mercury Layer announced as an implementation of statechains using blind signing
    url: /en/newsletters/2024/01/24/#mercury-layer-announced

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Eltoo
    link: topic eltoo

  - title: Signature adaptors
    link: topic adaptor signatures

  - title: Multisignatures
    link: topic multisignature

  - title: Signer delegation
    link: topic signer delegation

  - title: Sidechains
    link: topic sidechains

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Statechains** are a proposed offchain system for allowing a user
  (such as Alice) to delegate the ability to spend a UTXO to another
  user (Bob), who can then further delegate the spending authority to a
  third user (Carol), etc.

---

The offchain delegation operations are all performed using [signature
adaptors][topic adaptor signatures] and the cooperation of a trusted
third party who uses the [eltoo][topic eltoo] mechanism and their
knowledge of every previous delegation operation to ensure each
new delegation uses a state number higher than any previously used
state number.  These incrementing state numbers ensure an onchain spend by
the most recent delegate (Carol) can take precedence over spends by
previous delegates (Alice and Bob), assuming the trusted third party
hasn’t colluded with a previous delegate to cheat.

Beyond colluding with a delegated signer (such as previous delegates
Alice or Bob), there is no way for the trusted third party to steal
funds.  A delegated signer
can always spend the UTXO onchain without needing permission from the
trusted third party, arguably making statechains less trusted than
federated [sidechains][topic sidechains].

Although initially described for use with [schnorr][topic schnorr
signatures]-based signature adaptors, there has been work to adapt the
protocol to ECDSA-based [multisignatures][topic multisignature] and to
use decrementing locktime similar to that proposed for [duplex
micropayment channels][] rather than eltoo.  This would make statechains
usable on Bitcoin without depending on any proposed consensus changes.

{% include references.md %}
{% include linkers/issues.md issues="" %}
[duplex micropayment channels]: https://tik-old.ee.ethz.ch/file//716b955c130e6c703fac336ea17b1670/duplex-micropayment-channels.pdf
