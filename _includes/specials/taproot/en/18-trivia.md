{% auto_anchor %}

- **What is a taproot?** Wikipedia [says][wikipedia taproot], "A taproot
  is a large, central, and dominant root from which other roots sprout
  laterally. Typically a taproot is somewhat straight and very thick, is
  tapering in shape, and grows directly downward.  In some plants, such
  as the carrot, the taproot is a storage organ so well developed that
  it has been cultivated as a vegetable."

    How does this apply to Bitcoin?

    - "I always assumed the origin of the name was 'taps into the Merkle
      root', but I don't actually know what Gregory Maxwell's thinking
      was."  ---Pieter Wuille ([source][wuille taproot name])

    - "I originally had to look the word up; but I took it as the key
      path being the 'taproot' because that's the tasty one that you
      make carrot soup out of, and the merklized scripts would be the
      other lesser roots that you hope to ignore."  ---Anthony Towns
      ([source][towns taproot name])

    - "The name originated in a visualization of a tree with a thick
      central truck like a dandelion taproot---the technique is mostly
      useful because of the assumption that there is one high
      probability path and the rest is fuzzy stragglers, and I thought
      it was a good one because of the punny fact that it verifies
      script-path spends by tapping into the hidden commitment in the
      root.

      [...] Alas, calling the hash tree with the sorted interior nodes a
      'myrtle tree' didn't catch on. (Myrtle tree because the set of
      policies with an equal hash root are ones whos ordering differs by
      a permutation which can be defined by a t-function, and Myrtle is
      the family which includes melaleuca, the tea-tree, and it sounds
      like 'merkle'. :p )" ---Gregory Maxwell ([source][maxwell taproot
      name])

- **Schnorr signatures predate ECDSA:** we talk about [schnorr signatures][topic
  schnorr signatures] as an upgrade on Bitcoin's original ECDSA
  signatures because they make it easier to implement various
  cryptographic tricks, but the schnorr signature algorithm predates the
  DSA algorithm that ECDSA is based upon.  Indeed, DSA was created in
  part to circumvent Claus Peter Schnorr's [patent on schnorr signatures][schnorr patent]
  but Schnorr still [claimed][schnorr letter] "[my] patents apply to various
  implementations of discrete log signatures of that sorts and hence
  covers the use of Nyberg-Rueppel and DSA signatures in these
  instances."  No court is known to have supported Schnorr's claim and
  his patent expired by 2011.

- **Unsure what name to use:** although it didn't work out, there
  was a [suggestion][dryja bn sigs] early in the development of adapting
  schnorr signatures for Bitcoin that Claus Peter Schnorr's name shouldn't be
  used in association with them because his patent on them prevented the
  widespread use of a valuable cryptographic technique for over 20
  years.  Pieter Wuille [writes][wuille dls], "we did consider calling
  [BIP340][] 'DLS' for 'Discrete Logarithm Signatures', but I think we
  eventually didn't go through with that because the name Schnorr was
  already so much talked about."

- **Schnorr signatures for twisted Edwards curves:** an application of schnorr
  signatures using elliptic curves was published in 2011. <!-- https://ed25519.cr.yp.to/papers.html -->
  The scheme,
  [EdDSA][], is now the basis of several standards.  Although not used
  in Bitcoin consensus, references to it in the context of other systems
  can be found in many of the Bitcoin repositories tracked by Optech.
  <!-- source: quick git grep -i -->

- **Pay to contract:** Ilja Gerhardt and Timo Hanke created a
  [protocol][gh p2c], presented by Hanke at the 2013 San Jose Bitcoin
  conference, <!-- source: Wuille; I found some independent confirmation in dead links on Google -harding -->
  for allowing a payment to commit to the hash of its contract.  Anyone
  with a copy of the contract, and the nonce used to avoid certain
  attacks, can verify the commitment---but to anyone else the payment
  looks like any other Bitcoin payment.

    A slight improvement to this *pay-to-contract* (P2C) protocol was
    included in the [2014 paper][sidechains.pdf] about
    [sidechains][topic sidechains], <!-- Algorithm 1:
    GenerateCrossChainAddress --> where the commitment also includes the
    original public key to pay.  Taproot uses this same construction
    but, instead of committing to the terms of an offchain contract, the
    output creator commits to consensus-enforced terms chosen by the
    receiver for how they can spend the received bitcoins onchain.

- **A Good Morning:** the idea to use P2C so that payments to scripts
  can look identical onchain to paying public keys was invented in Los
  Altos, California, at the diner "A Good Morning" on 22 January 2018.
  Pieter Wuille writes that the idea was developed by Andrew Poelstra
  and Gregory Maxwell "while I briefly left the table... !$%@" [sic].
  <!-- personal correspondence with Wuille -harding -->

<!-- weird comment below because HTML has silly rules about anchor ids -->
- **<!--x-->2.5 years in 1.5 days:** choosing the optimal constant for
  [bech32m][topic bech32] required [about][wuille matrix elimination]
  2.5 years of CPU time, which was performed in just 1.5 days mostly
  using a CPU cluster belonging to Gregory Maxwell.

*We thank Anthony Towns, Gregory Maxwell, Jonas Nick, Pieter Wuille, and Tim Ruffing for enjoyable conversations
related to this column.  Any errors are the author's.*

{% endauto_anchor %}

[wikipedia taproot]: https://en.wikipedia.org/wiki/Taproot
[dryja bn sigs]: https://diyhpl.us/wiki/transcripts/discreet-log-contracts/
[bitcoin.pdf]: https://www.opencrypto.org/bitcoin.pdf
[schnorr patent]: https://patents.google.com/patent/US4995082
[ed25519]: https://ed25519.cr.yp.to/ed25519-20110926.pdf
[eddsa]: https://en.wikipedia.org/wiki/EdDSA
[gh p2c]: https://arxiv.org/abs/1212.3257
[sidechains.pdf]: https://www.blockstream.com/sidechains.pdf
[wuille matrix elimination]: https://twitter.com/pwuille/status/1335761447884713985
[wuille dls]: https://github.com/bitcoinops/bitcoinops.github.io/pull/667#discussion_r731372937
[wuille taproot name]: https://github.com/bitcoinops/bitcoinops.github.io/pull/667#discussion_r731371163
[towns taproot name]: https://github.com/bitcoinops/bitcoinops.github.io/pull/667#discussion_r731523855
[schnorr letter]: https://web.archive.org/web/19991117143502/http://grouper.ieee.org/groups/1363/letters/SchnorrMar98.html
[maxwell taproot name]: https://github.com/bitcoinops/bitcoinops.github.io/pull/667#discussion_r732189216
