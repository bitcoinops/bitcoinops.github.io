---
title: 'Bulletin Hebdomadaire Bitcoin Optech #279'
permalink: /fr/newsletters/2023/11/29/
name: 2023-11-29-newsletter-fr
slug: 2023-11-29-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume une mise à jour de la spécification des annonces de liquidité. Sont également incluses nos rubriques
habituelles avec des questions et réponses populaires de la communauté Bitcoin Stack Exchange, des annonces de nouvelles versions et
versions candidates, ainsi que les changements apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Mise à jour de la spécification des annonces de liquidité :** Lisa Neigut a [publié][neigut liqad] sur la liste de diffusion
  Lightning-Dev pour annoncer une mise à jour de la spécification des [annonces de liquidité][topic liquidity advertisements]. Cette
  fonctionnalité, implémentée dans Core Lightning et actuellement en cours de développement pour Eclair, permet à un nœud d'annoncer
  qu'il est prêt à contribuer des fonds à un [canal à financement double][topic dual funding]. Si un autre nœud accepte l'offre en
  demandant l'ouverture d'un canal, le nœud demandeur doit payer au nœud offrant des frais initiaux. Cela permet à un nœud ayant besoin
  de liquidité entrante (par exemple, un commerçant) de trouver des pairs bien connectés pouvant fournir cette liquidité à un taux du
  marché, en utilisant uniquement des logiciels open source et le protocole de diffusion décentralisé LN.

    Les mises à jour comprennent quelques changements structurels ainsi qu'une plus grande flexibilité quant à la durée du contrat et
    au plafond des frais de transfert. Le message a reçu plusieurs réponses sur la liste de diffusion et d'autres modifications de la
    [spécification][bolts #878] sont attendues. Le message de Neigut note également que la construction actuelle des annonces de liquidité
    et des annonces de canal rend théoriquement possible de prouver cryptographiquement un cas où une partie viole son contrat. Il reste
    à résoudre le problème de concevoir une preuve de fraude compacte pouvant être utilisée dans un contrat de caution pour inciter
    au respect du contrat.

## Questions et réponses sélectionnées de Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech cherchent des réponses à leurs
  questions, ou lorsque nous avons quelques moments libres pour aider les utilisateurs curieux ou confus. Dans cette rubrique
  mensuelle, nous mettons en évidence certaines des questions et réponses les plus votées publiées depuis notre dernière mise
  à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Le schéma de signature numérique Schnorr est-il un schéma interactif de multisignature, et également pas un schéma non interactif agrégé ?]({{bse}}120402)
  Pieter Wuille décrit les différences entre les multisignatures, l'agrégation de signatures, l'agrégation de clés et le multisig
  Bitcoin, et mentionne plusieurs schémas connexes, notamment [BIP340][], [les signqtures de Schnorr][topic schnorr signatures],
  [MuSig2][topic musig], FROST et Bellare-Neven 2006.

- [Est-il conseillé d'utiliser un nœud complet de version candidate sur le réseau principal ?]({{bse}}120375)
  Vojtěch Strnad et Murch soulignent que l'exécution de versions candidates de Bitcoin Core sur le réseau principal ne pose que peu
  de risques pour le _réseau_ Bitcoin, mais les utilisateurs des API, du portefeuille ou d'autres fonctionnalités de Bitcoin Core
  doivent faire preuve de prudence et effectuer des tests appropriés pour leur configuration.

- [Quelle est la relation entre nLockTime et nSequence?]({{bse}}120256) Antoine Poinsot et Pieter Wuille répondent à une série de
  questions de Stack Exchange sur `nLockTime` et `nSequence`, y compris la [relation entre les deux]({{bse}}120273), le [but initial
  de `nLockTime`]({{bse}}120276), les [valeurs potentielles de `nSequence`]({{bse}}120254) et la relation avec [BIP68]({{bse}}120320)
  et [`OP_CHECKLOCKTIMEVERIFY`]({{bse}}120259).

- [Que se passerait-il si nous fournissons à OP_CHECKMULTISIG plus de signatures que le nombre seuil (m) ?]({{bse}}120604)
  Pieter Wuille explique que bien que cela était possible auparavant, le [BIP147][] soft fork de malleabilité des éléments de pile
  factices n'autorise plus la présence d'un élément de pile supplémentaire dans OP_CHECKMULTISIG et OP_CHECKMULTISIGVERIFY avec une
  valeur arbitraire.

- [Qu'est-ce que la "politique" (mempool) ?]({{bse}}120269)
  Antoine Poinsot définit les termes "politique" et "standardness" dans le contexte de Bitcoin Core et donne quelques exemples.
  Il renvoie également à la série de Bitcoin Optech sur la [série en attente de confirmation][policy series] sur cette politique.

- [Que signifie Pay to Contract (P2C) ?]({{bse}}120362)
  Vojtěch Strnad décrit [Pay-to-Contract (P2C)][topic p2c] et renvoie à la [proposition originale][p2c paper].

- [Une transaction non-segwit peut-elle être sérialisée dans le format segwit ?]({{bse}}120317)
  Pieter Wuille souligne que bien que plusieurs anciennes versions de Bitcoin Core
  permettaient involontairement le format de sérialisation étendu pour les transactions non-segwit, [BIP144][] spécifie que les
  transactions non-segwit doivent utiliser l'ancien format de sérialisation.

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets d’infrastructure
Bitcoin. Veuillez envisager de passer aux nouvelles versions ou d’aider à tester
les versions candidates.*

- [Core Lightning 23.11][] est une version de la prochaine version majeure de
  cette implémentation de nœud LN. Elle offre une flexibilité supplémentaire au
  mécanisme d'authentification _rune_, une vérification de sauvegarde améliorée, de nouvelles
  fonctionnalités pour les plugins.

- [Bitcoin Core 26.0rc3][] est un candidat à la prochaine version majeure
  de l'implémentation de nœud complet prédominante. Un [guide de test][26.0 testing] est disponible.

## Modifications de code et de documentation notables

*Modifications notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo],
[Eclair][eclair repo], [LDK][ldk repo],[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Interface de portefeuille
matériel (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], et
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Rust Bitcoin #2213][] modifie la prédiction du poids pour les entrées P2WPKH lors du processus de l'estimation des frais. Depuis
  les versions [0.10.3][bcc 0.10.3] et [0.11.1][bcc 0.11.1] de Bitcoin Core, les transactions avec des signatures de haute taille
  sont considérées comme non standard. Par conséquent, les processus de construction de transactions peuvent supposer en toute
  sécurité que les signatures ECDSA sérialisées prendront au maximum 72 octets au lieu de la limite supérieure précédemment utilisée
  de 73 octets.

- [BDK #1190][] ajoute une nouvelle méthode `Wallet::list_output` qui récupère tous les outputs dans le portefeuille, à la fois les
  outputs dépensés et les outputs non dépensés. Auparavant, il était facile d'obtenir une liste d'outputs non dépensés mais difficile
  d'obtenir une liste d'outputs dépensés.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2213,1190,878" %}
[bitcoin core 26.0rc3]: https://bitcoincore.org/bin/bitcoin-core-26.0/
[26.0 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/26.0-Release-Candidate-Testing-Guide
[core lightning 23.11]: https://github.com/ElementsProject/lightning/releases/tag/v23.11
[neigut liqad]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-November/004217.html
[policy series]: /fr/blog/waiting-for-confirmation/
[p2c paper]: https://arxiv.org/abs/1212.3257
[bcc 0.11.1]: https://bitcoin.org/en/release/v0.11.1#test-for-lows-signatures-before-relaying
[bcc 0.10.3]: https://bitcoin.org/en/release/v0.10.3#test-for-lows-signatures-before-relaying