---
title: 'Bulletin Hebdomadaire Bitcoin Optech #255'
permalink: /fr/newsletters/2023/06/14/
name: 2023-06-14-newsletter-fr
slug: 2023-06-14-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume une discussion sur l'autorisation de relayer les transactions contenant des données dans le
champ annexe taproot et des liens vers un projet de BIP pour les paiements silencieux. Vous trouverez également une nouvelle
contribution à notre série hebdomadaire limitée sur la politique mempool, ainsi que nos sections habituelles résumant une réunion
du Bitcoin Core PR Review Club, annonçant les nouvelles versions de logiciels et les versions candidates, et décrivant les
principaux changements apportés aux logiciels d'infrastructure Bitcoin les plus répandus.

## Nouvelles

- **Discussion sur les annexes à taproot :** JJoost Jager a [posté][jager annex] sur la liste de diffusion Bitcoin-Dev
  une demande de modification du relais de transaction et de la politique de minage de Bitcoin Core afin de permettre le
  stockage de données arbitraires dans le champ annexe [taproot][topic taproot].  Ce champ est une partie optionnelle des
  données du témoin pour les transactions taproot. S'il est présent, les signatures dans taproot et [tapscript][topic tapscript]
  doivent s'engager sur ses données (ce qui rend impossible l'ajout, la suppression ou la modification par un tiers),
  mais il n'a pas d'autre objectif défini pour l'instant---il est réservé aux futures mises à jour du protocole, en particulier
  aux soft forks.

    Bien qu'il y ait eu des [propositions antérieures][riard annex] pour définir un format pour l'annexe, elles n'ont pas été
    largement acceptées et mises en œuvre. Jager a proposé deux formats ([1][jager annex], [2][jager annex2]) qui pourraient
    être utilisés pour permettre à quiconque d'ajouter des données arbitraires à l'annexe d'une manière qui ne compliquerait
    pas de manière significative les efforts de normalisation ultérieurs qui pourraient être regroupés avec un soft fork.

    Greg Sanders [a répondu][annexe sanders] pour demander quelles données Jager voulait spécifiquement stocker dans
    l'annexe et a décrit sa propre utilisation de l'annexe en testant le protocole [LN-Symmetry][topic eltoo] avec la
    proposition de soft fork [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] à l'aide de Bitcoin Inquisition (voir le
    [Bulletin d'information #244][news244 annex]). Sanders a également décrit un problème avec l'annexe : dans un protocole
    multipartite (comme un [coinjoin][topic coinjoin]), chaque signature n'engage que l'annexe pour l'entrée contenant
    cette signature---et non les annexes pour d'autres entrées dans la même transaction. Cela signifie que si Alice, Bob
    et Mallory signent ensemble une coinjoin, Alice et Bob n'ont aucun moyen d'empêcher Mallory de diffuser une version
    de la transaction avec une annexe importante qui retarde sa confirmation. Étant donné que Bitcoin Core et d'autres nœuds
    complets ne relaient pas actuellement les transactions contenant des annexes, ce problème ne se pose pas pour l'instant.
    Jager [a répondu][jager annex4] qu'il souhaite stocker des signatures à partir de clés éphémères pour un type de
    [coffre-fort][topic vaults] qui ne nécessite pas de soft fork, et il [a suggéré][jager annex3] que certains
    [travaux antérieurs][bitcoin core #24007] dans Bitcoin Core pourraient éventuellement résoudre le problème du relais
    des annexes dans certains protocoles multipartites.

- **Projet de BIP pour les paiements silencieux :** Josie Baker and Ruben Somsen
  [posted][bs sp] to the Bitcoin-Dev mailing list a draft BIP for
  [silent payments][topic silent payments], a type of reusable payment
  code that will produce a unique onchain address each time it is used,
  preventing [output linking][topic output linking].  Output linking can
  significantly reduce the privacy of users (including users not
  directly involved in a transaction).  The draft goes into detail about
  the benefits of the proposal, its tradeoffs, and how software can
  effectively use it.  Several insightful comments have already been
  posted on the [PR][bips #1458] for the BIP.

## Waiting for confirmation #5: Policy for Protection of Node Resources

_A limited weekly [series][policy series] about transaction relay,
mempool inclusion, and mining transaction selection---including why
Bitcoin Core has a more restrictive policy than allowed by consensus and
how wallets can use that policy most effectively._

{% include specials/policy/en/05-dos.md %}

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

[Allow inbound whitebind connections to more aggressively evict peers when slots are full][review club 27600]
is a PR by Matthew Zipkin (pinheadmz) that improves a node operator's
ability in certain cases to configure desired peers for the node.
Specifically, if the node operator has whitelisted a potential inbound
peer (for example, a light client controlled by the node operator), then
without this PR, and depending on the node's peer state, it's possible
that the node will deny this light client's connection attempt.

This PR makes it much more likely that the desired peer will be able to
connect to our node. It does this by evicting an existing inbound peer
that, without this PR, would have been ineligible for eviction.

{% include functions/details-list.md
  q0="Why does this PR only apply to inbound peer requests?"
  a0="Our node _initiates_ outbound connections; this PR modifies how
      the node _reacts_ to an incoming connection request.
      Outbound nodes can be evicted, but that's done with an entirely
      separate algorithm."
  a0link="https://bitcoincore.reviews/27600#l-33"

  q1="What is the impact of the `force` parameter of `SelectNodeToEvict()`
      on the return value?"
  a1="Specifying `force` as `true` ensures that a non-`noban` inbound peer
      is returned, if one exists, even if it would otherwise be protected
      from eviction.
      Without the PR, it would not return a peer if they all are excluded
      (protected) from eviction."
  a1link="https://bitcoincore.reviews/27600#l-70"

  q2="How is the function signature of `EraseLastKElements()` changed in this PR?"
  a2="It changed from being a `void` return function to returning the last
      entry that was _removed_ from the eviction candidates list. (This
      \"protected\" node might be evicted if necessary.)
      However, as a result of discussion during the review club meeting,
      the PR was later simplified such that this function is no longer modified."
  a2link="https://bitcoincore.reviews/27600#l-126"

  q3="`EraseLastKElements` used to be a templated function, but this PR removes
      the two template arguments. Why? Are there any downsides to this change?"
  a3="This function was and (with this PR) is being called with unique template
      arguments, so there is no need for the function to be templated.
      The PR's changes to this function were reverted, so it's still templated,
      because changing this would be beyond the scope of the PR."
  a3link="https://bitcoincore.reviews/27600#l-126"

  q4="Suppose we pass a vector of 40 eviction candidates to `SelectNodeToEvict()`.
      Before and after this PR, what’s the theoretical maximum of Tor nodes
      that can be protected from eviction?"
  a4="Both with and without the PR, the number would be 34 out of 40, assuming
      they're not `noban` and inbound."
  a4link="https://bitcoincore.reviews/27600#l-156"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Core Lightning 23.05.1][] is a maintenance release for this LN
  implementation.  Its release notes say, "this is a bugfix-only release
  which repairs several crashes reported in the wild. It is a
  recommended upgrade for anyone on v23.05."

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #27501][] adds a `getprioritisedtransactions` RPC that
  returns a map of all fee deltas created by the user with
  `prioritisetransaction`, indexed by txid. The map also indicates whether
  each transaction is present in the mempool.  See also [Newsletter
  #250][news250 getprioritisedtransactions].

- [Core Lightning #6243][] updates the `listconfigs` RPC to put all
  configuration information in a single dictionary and also passes the
  state of all configuration options to restarted plugins.

- [Eclair #2677][] increases the default `max_cltv` from 1,008 blocks
  (about one week) to 2,016 blocks (about two weeks). This extends the
  maximum permitted number of blocks until a payment attempt
  times out. The change is motivated by nodes on the network raising
  their reserved time window to address an expiring HTLC
  (`cltv_expiry_delta`) in response to high on-chain feerates. Similar
  changes have been [merged to LND][lnd max_cltv] and CLN.

- [Rust bitcoin #1890][] adds a method for counting the number of
  signature operations (sigops) in non-tapscript scripts.  The number of
  sigops is limited per block and Bitcoin Core's transaction selection
  code for mining treats transactions with a high ratio of sigops per
  size (weight) as if they were larger transactions, effectively
  lowering their feerate.  That means it can be important for
  transaction creators to use something like this new method to check
  the number of sigops they are using.

{% include references.md %}
{% include linkers/issues.md v=2 issues="27501,6243,2677,1890,1458,24007" %}
[policy series]: /en/blog/waiting-for-confirmation/
[jager annex]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021731.html
[riard annex]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/020991.html
[jager annex2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021756.html
[sanders annex]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021736.html
[news244 annex]: /en/newsletters/2023/03/29/#bitcoin-inquisition-22
[jager annex3]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021743.html
[bs sp]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021750.html
[jager annex4]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021737.html
[Core Lightning 23.05.1]: https://github.com/ElementsProject/lightning/releases/tag/v23.05.1
[review club 27600]: https://bitcoincore.reviews/27600
[news250 getprioritisedtransactions]: /en/newsletters/2023/05/10/#bitcoin-core-pr-review-club
[lnd max_cltv]: /en/newsletters/2019/10/23/#lnd-3595
