---
title: 'Bulletin Hebdomadaire Bitcoin Optech #256'
permalink: /fr/newsletters/2023/06/21/
name: 2023-06-21-newsletter-fr
slug: 2023-06-21-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume une discussion sur l'extension des factures BOLT11 pour demander deux paiements.
Vous y trouverez également une autre contribution à notre série hebdomadaire limitée sur la politique de mempool, ainsi
que nos sections régulières décrivant les mises à jour des clients et des services, les nouvelles versions et les
versions candidates, ainsi que les changements apportés aux principaux logiciels d'infrastructure Bitcoin.


## Nouvelles

- **Proposition d'extension des factures BOLT11 pour demander deux paiements :** Thomas Voegtlin a [posté][v 2p] sur la
  liste de diffusion de Lightning-Dev pour suggérer que les factures [BOLT11][] soient étendues pour permettre optionnellement
  à un destinataire de demander deux paiements séparés à un utilisateur, avec chaque paiement ayant un secret et un montant
  séparés. Voegtlin explique comment cela pourrait être utile à la fois pour les [submarine swaps][topic submarine swaps] et
  les [canaux JIT][topic jit channels] :

    - *Les swaps sous-marins*, où le paiement d'une facture LN offchain permet de recevoir des fonds onchain (les swaps
      sous-marins peuvent également fonctionner dans l'autre sens, de onchain à offchain, mais cela n'est pas discuté ici).
      Le bénéficiaire onchain choisit un secret et le payeur offchain paie un [HTLC][topic htlc] au hash de ce secret, qui
      est acheminé par LN à un fournisseur de services d'échange sous-marin. Le fournisseur de services reçoit un HTLC offchain
      pour ce secret et crée une transaction onchain en payant ce HTLC.  Lorsque l'utilisateur est convaincu que la transaction
      onchain est sécurisée, il divulgue le secret pour régler le HTLC onchain, ce qui permet au prestataire de services de
      régler le HTLC offchain (et tous les paiements transmis sur le LN qui dépendent également du même secret).

        Toutefois, si le destinataire ne divulgue pas son secret, le prestataire de services ne recevra aucune compensation
        et devra dépenser la sortie onchain qu'il vient de créer, ce qui implique des coûts pour aucun gain. Pour éviter cet
        abus, les services d'échange sous-marin existants exigent que le dépensier paie une redevance en utilisant le LN avant
        que le service ne crée une transaction sur la chaîne (le service peut éventuellement rembourser une partie ou la
        totalité de cette redevance si la HTLC sur la chaîne est réglée). Les frais initiaux et l'échange sous-marin portent
        sur des montants différents et doivent être réglés à des moments différents, de sorte qu'ils doivent utiliser des
        secrets différents. Une facture BOLT11 actuelle ne peut contenir qu'un seul engagement pour un secret et un seul
        montant, de sorte que tout portefeuille effectuant des échanges sous-marins doit être programmé pour gérer
        l'interaction avec le serveur ou nécessite que l'expéditeur et le destinataire complètent un flux de travail
        en plusieurs étapes.

    - *Les canaux JIT (Just-in-Time)*, où un utilisateur sans canaux (ou sans liquidité) crée un canal virtuel avec un
      fournisseur de services ; lorsque le premier paiement de ce canal virtuel arrive, le fournisseur de services crée
      une transaction onchain qui finance le canal et contient ce paiement. Comme pour toute LN HTLC, le paiement offchain
      est effectué selon un secret que seul le destinataire (l'utilisateur) connaît. Si l'utilisateur est convaincu que
      la transaction de financement du canal JIT est sécurisée, il divulgue le secret pour réclamer le paiement.

        Cependant, si l'utilisateur ne divulgue pas son secret, le fournisseur de services ne recevra aucune compensation
        et encourra des coûts sur la chaîne pour aucun gain. Voegtlin pense que les fournisseurs de services de canaux JIT
        existants évitent ce problème en demandant à l'utilisateur de divulguer son secret avant que la transaction de
        financement ne soit sécurisée, ce qui, selon lui, peut créer des problèmes juridiques et empêcher les portefeuilles
        non hébergés d'offrir un service similaire.

    Voegtlin suggests that allowing a BOLT11 invoice to contain two
    separate commitments to secrets, each for a different amount, will
    allow using one secret and amount for an upfront fee to pay the
    onchain transaction costs and the other secret and amount for the
    actual submarine swap or JIT channel funding.  The proposal received
    several comments, a few of which we'll summarize:

    - *Dedicated logic required for submarine swaps:* Olaoluwa Osuntokun
      [notes][o 2p] that the receiver of a submarine swap needs to create a
      secret, distribute it, and then settle a payment to it onchain.  The cheapest
      way to settle it is by interacting with the swap service provider.
      If the spender and receiver are going to interact with the service
      provider anyway, as is often the case with some existing
      implementations where the spender and receiver are the same entity,
      they don't need to communicate extra information using an invoice.
      Voegtlin [replied][v 2p2] that a dedicated piece of software can handle
      the interaction, eliminating the need for additional logic in the
      offchain wallet that pays out the funds and the onchain wallet
      that receives the funds---but this is only possible if the LN
      wallet can pay two separate secrets and amounts in the same
      invoice.

    - *BOLT11 ossified:* Matt Corallo [répond][c 2p] qu'il n'a pas encore été possible de faire en sorte que toutes les
      implémentations LN mettent à jour leur support BOLT11 pour supporter les factures qui ne contiennent pas de montant
      (pour permettre les [paiements spontanés][topic spontaneous payments]), donc il ne pense pas que l'ajout d'un champ
      supplémentaire soit une approche pratique pour le moment.  Bastien Teinturier fait un [commentaire similaire][t 2p],
      suggérant d'ajouter un support aux [offres][topic offers] à la place. Voegtlin [n'est pas d'accord][v 2p3] et pense
      que l'ajout d'un soutien est pratique.

    - *Splice-out alternative:* Corallo also inquires about why the
      protocol should be modified to support submarine swaps if [splice
      outs][topic splicing] become available.  It wasn't mentioned in
      the thread, but both submarine swaps and splice outs allow moving
      offchain funds into an onchain output---however splice outs can be
      more efficient onchain and aren't vulnerable to uncompensated fee
      problems.  Voegtlin answers that submarine swaps allow an LN user
      to increase their capacity for receiving new LN payments, which
      splicing does not.

    The discussion appeared to be ongoing at the time of writing.

## Waiting for confirmation #6: Policy Consistency

_A limited weekly [series][policy series] about transaction relay,
mempool inclusion, and mining transaction selection---including why
Bitcoin Core has a more restrictive policy than allowed by consensus and
how wallets can use that policy most effectively._

{% include specials/policy/en/06-consistency.md %}

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Greenlight libraries open sourced:**
  Non-custodial CLN node service provider [Greenlight][news162 greenlight] has
  [announced][decker twitter] a [repository][github greenlight] of client
  libraries and language bindings as well a [testing framework guide][greenlight testing].

- **Tapscript debugger Tapsim:**
  [Tapsim][github tapsim] is a script execution debugging (see [Newsletter
  #254][news254 tapsim]) and visualization tool for
  [tapscript][topic tapscript] using btcd.

- **Bitcoin Keeper 1.0.4 announced:**
  [Bitcoin Keeper][] is a mobile wallet that supports multisig, hardware signers,
  [BIP85][], and with the latest release, [coinjoin][topic coinjoin] support
  using the [Whirlpool protocol][gitlab whirlpool].

- **Lightning wallet EttaWallet announced:**
  The mobile [EttaWallet][github ettawallet] was recently [announced][ettawallet
  blog] with Lightning features enabled by LDK and a strong usability focus
  inspired by the [daily spending wallet][bitcoin design guide] reference design
  from the Bitcoin Design Community.

- **zkSNARK-based block header sync PoC announced:**
  [BTC Warp][github btc warp] is a light client sync proof-of-concept
  using zkSNARKs to prove and verify a chain of Bitcoin block headers. A [blog post][btc warp
  blog] provides details on the approaches taken.

- **lnprototest v0.0.4 released:**
  The [lnprototest][github lnprototest] project is a test suite for LN including "a set of test
  helpers written in Python3, designed to make it easy to write new tests when
  you propose changes to the lightning network protocol, as well as test
  existing implementations".

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Eclair v0.9.0][] is a new release of this LN implementation that
  "contains a lot of preparatory work for important (and complex)
  lightning features: [dual-funding][topic dual funding],
  [splicing][topic splicing] and [BOLT12 offers][topic offers]."  The
  features are experimental for now.  The release also "makes plugins
  more powerful, introduces mitigations against various types of DoS, and
  improves performance in many areas of the codebase."

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [LDK #2294][] adds support for replying to [onion messages][topic
  onion messages] and brings LDK closer to full support for
  [offers][topic offers].

- [LDK #2156][] adds support for [keysend payments][topic spontaneous
  payments] that use [simplified multipath payments][topic multipath
  payments].  LDK previously supported both of those technologies, but
  only when they were used separately.  Multipath payments must use
  [payment secrets][topic payment secrets] but LDK previously rejected
  keysend payments with payment secrets, so descriptive errors, a
  configuration option, and a warning about downgrading are added to
  mitigate any potential problems.

{% include references.md %}
{% include linkers/issues.md v=2 issues="2294,2156" %}
[policy series]: /en/blog/waiting-for-confirmation/
[v 2p]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/003977.html
[o 2p]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/003978.html
[v 2p2]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/003979.html
[c 2p]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/003980.html
[t 2p]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/003982.html
[v 2p3]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/003981.html
[eclair v0.9.0]: https://github.com/ACINQ/eclair/releases/tag/v0.9.0
[news162 greenlight]: /en/newsletters/2021/08/18/#blockstream-announces-non-custodial-ln-cloud-service-greenlight
[decker twitter]: https://twitter.com/Snyke/status/1666096470884515840
[github greenlight]: https://github.com/Blockstream/greenlight
[greenlight testing]: https://blockstream.github.io/greenlight/tutorials/testing/
[github tapsim]: https://github.com/halseth/tapsim
[news254 tapsim]: /en/newsletters/2023/06/07/#using-matt-to-replicate-ctv-and-manage-joinpools
[Bitcoin Keeper]: https://bitcoinkeeper.app/
[gitlab whirlpool]: https://code.samourai.io/whirlpool/whirlpool-protocol
[github ettawallet]: https://github.com/EttaWallet/EttaWallet
[ettawallet blog]: https://rukundo.mataroa.blog/blog/introducing-ettawallet/
[bitcoin design guide]: https://bitcoin.design/guide/daily-spending-wallet/
[github btc warp]: https://github.com/succinctlabs/btc-warp
[btc warp blog]: https://blog.succinct.xyz/blog/btc-warp
[github lnprototest]: https://github.com/rustyrussell/lnprototest
