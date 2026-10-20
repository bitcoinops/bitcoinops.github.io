---
title: 'Bulletin Hebdomadaire Bitcoin Optech #413'
permalink: /fr/newsletters/2026/07/10/
name: 2026-07-10-newsletter-fr
slug: 2026-07-10-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit des recherches sur l'utilisation de codes fountain pour permettre aux nœuds élagués de contribuer au
téléchargement initial des blocs. Sont également incluses nos sections régulières annonçant de nouvelles versions et versions candidates, et
décrivant des changements notables dans les logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

- **Utilisation des codes fountain pour l'IBD** : Lucas Lima a [publié][fount del] sur Delving Bitcoin ses dernières recherches sur
  l'utilisation des [codes fountain][fount wiki] pour permettre aux nœuds élagués de contribuer à l'Initial Block Download (IBD), sans
  augmenter significativement leurs besoins en stockage.

  Lima a fourni un [article de blog][fount blog] dédié dans lequel il explique comment cela pourrait être réalisé en divisant l'ensemble de
  la chaîne en époques, des segments de longueur fixe composés de `k` blocs, en encodant ces époques à l'aide de codes fountain, et en
  envoyant ces encodages, appelés gouttelettes, avec les en-têtes de blocs aux nœuds qui ont besoin de reconstruire la chaîne. Le nœud
  récepteur, appelé nœud seau, doit collecter et décoder suffisamment de gouttelettes appartenant à une certaine époque afin de reconstruire
  les `k` blocs. Les en-têtes de blocs sont ensuite utilisés pour vérifier que les données reçues sont valides, empêchant les nœuds
  malveillants de corrompre la chaîne reconstruite.

  Certains points critiques ont été soulevés lors de la discussion. En particulier, les développeurs ont mis en évidence la nécessité d'un
  grand nombre de pairs connectés pour réussir à reconstruire la chaîne, un IBD plus lent, le risque d'empreinte des nœuds, et une possible
  augmentation de la surface d'attaque DoS.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires. Veuillez envisager de mettre à niveau vers
les nouvelles versions ou d'aider à tester les versions candidates._

- [Bitcoin Core 31.1][] est une version de maintenance de l'implémentation de nœud complet prédominante. Elle corrige une fuite d'adresse IP
  dans `-privatebroadcast` qui pourrait compromettre la [confidentialité de l'origine des transactions][topic transaction origin privacy]
  (voir le [Bulletin #409][news409 privatebroadcast]), et inclut des correctifs pour le compactage de la base de données chainstate, la
  migration de portefeuille, l'estimation de la taille des entrées, l'agrégation de clés [MuSig2][topic musig], et la gestion des proxys
  lors des reconnexions du [transport P2P v2][topic v2 p2p transport]. Voir les [notes de version][bcc31.1 rn] pour plus de détails.

- [LND v0.20.2-beta][] est une version de maintenance de cette implémentation populaire de nœud LN. Elle corrige une panique de repli DNS et
  un bug de règlement d'intercepteur de transfert onchain, et ajoute la validation de l'expiration CLTV du [HTLC][topic htlc] au saut final
  abordée la semaine dernière (voir le [Bulletin #412][news412 cltv]).

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning
BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #32489][] ajoute une RPC `exportwatchonlywallet` qui exporte une version watch-only du portefeuille actuellement chargé vers
  un nouveau fichier de portefeuille, qui peut être chargé sur un autre nœud à l'aide de la RPC `restorewallet` (voir le bulletin
  [#366][news366 watchonly]). Le portefeuille exporté contient les [descripteurs][topic descriptors] publics du portefeuille d'origine, les
  transactions, les étiquettes et autres métadonnées, mais pas les clés privées. Auparavant, les utilisateurs devaient construire
  manuellement un tel portefeuille en important des descripteurs publics.

- [Bitcoin Core #32606][] met à jour le [relai de blocs compacts][topic compact block relay] afin d'ignorer les messages de blocs compacts
  provenant de pairs qui n'ont pas négocié cette prise en charge avec `sendcmpct`, de pairs non sélectionnés par le nœud pour les annonces à
  haute bande passante avec `sendcmpct(1)`, et chaque fois que le nœud local fonctionne en mode `-blocksonly`. Étant donné que les blocs
  compacts sont reconstruits à l'aide de transactions provenant du mempool du récepteur, leur traitement peut révéler quelles transactions
  le récepteur n'a pas encore ou possède déjà. Cela est particulièrement indésirable pour les nœuds en mode blocs seuls, car les
  transactions de leurs mempools sont plus susceptibles d'avoir une origine locale.

- [Bitcoin Core #34020][] ajoute les méthodes `getTransactionsByTxID()` et `getTransactionsByWitnessID()` à l'interface IPC de minage (voir
  les bulletins [#310][news310 mining] et [#323][news323 mining]). Chaque méthode prend une liste de txids ou de wtxids et renvoie les
  transactions sérialisées correspondantes depuis le mempool du nœud, ou des éléments vides pour les transactions qu'il ne connaît pas. Cela
  est utile pour la déclaration de jobs personnalisés de [Stratum v2][topic pooled mining], où un pool peut vouloir demander uniquement les
  transactions d'un modèle de bloc proposé par un mineur qu'il ne possède pas déjà.

- [Core Lightning #9104][] et [#9292][core lightning #9292] ajoutent une prise en charge expérimentale du protocole de fermeture coopérative
  `option_simple_close` (voir le [Bulletin #342][news342 simpleclose]). Les fermetures coopératives héritées exigent que les pairs s'accordent
  sur une unique transaction de fermeture et sur des frais, et s'ils ne sont pas d'accord, la fermeture peut rester bloquée. Simple close
  évite ce problème en permettant à chaque pair de proposer une transaction de fermeture valide qui soustrait les frais qu'il a choisis de
  sa propre sortie. Les deux versions peuvent être signées et diffusées, et la transaction conflictuelle qui est confirmée en premier ferme
  le canal. CLN implémente ce flux dans un nouveau sous-démon `simpleclosed`, qui retarde la diffusion de sa propre version lorsque la
  version du pair paie des frais plus élevés. [#9292][core lightning #9292] corrige un cas limite dans lequel CLN rejetait une transaction
  simple-close signée qui remplaçait la sortie non économique du fermeur par un `OP_RETURN` autorisé de valeur nulle, provoquant une
  fermeture forcée.

- [Eclair #3323][] fait échouer les [HTLCs][topic htlc] entrants dont l'expiration CLTV est à plus de 2016 blocs (environ deux semaines)
  dans le futur. Cela étend la politique existante d'expiration maximale d'Eclair pour les HTLCs sortants, ce qui réduit le risque que des
  fonds soient verrouillés pendant une période prolongée et rend plus difficiles les [attaques de bourrage de canaux][topic channel jamming
  attacks]. Eclair accepte temporairement un HTLC problématique dans l'engagement du canal puis le fait échouer, car le rejeter purement et
  simplement forcerait la fermeture du canal.

- [LND #10832][] poursuit l'implémentation par LND des [offres BOLT12][topic offers] en ajoutant la prise en charge des messages
  `InvoiceRequest` (voir [Bulletin #410][news410 bolt12]). Le nouveau code ajoute l'encodage TLV, le décodage et la
  validation structurelle, tout en reportant la vérification des signatures et la vérification croisée avec l'offre correspondante à des PR
  ultérieures.

{% include snippets/recap-ad.md when="2026-07-14 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32489,32606,34020,9104,9292,3323,10832" %}
[fount del]: https://delvingbitcoin.org/t/fountain-codes-a-way-to-reduce-blockchain-storage-costs/2624
[fount wiki]: https://en.wikipedia.org/wiki/Fountain_code
[fount blog]: https://lucasdbr05.com/posts/fountain-codes/
[Bitcoin Core 31.1]: https://bitcoincore.org/bin/bitcoin-core-31.1/
[bcc31.1 rn]: https://bitcoincore.org/en/releases/31.1/
[LND v0.20.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.2-beta
[news366 watchonly]: /fr/newsletters/2025/08/08/#bitcoin-core-pr-review-club
[news310 mining]: /fr/newsletters/2024/07/05/#bitcoin-core-30200
[news323 mining]: /fr/newsletters/2024/10/04/#bitcoin-core-30510
[news342 simpleclose]: /fr/newsletters/2025/02/21/#bolts-1205
[news410 bolt12]: /fr/newsletters/2026/06/19/#lnd-10789
[news409 privatebroadcast]: /fr/newsletters/2026/06/12/#bitcoin-core-35410
[news412 cltv]: /fr/newsletters/2026/07/03/#lnd-10927
