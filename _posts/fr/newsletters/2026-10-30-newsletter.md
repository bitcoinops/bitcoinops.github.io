---
title: 'Bulletin Hebdomadaire Bitcoin Optech #429'
permalink: /fr/newsletters/2026/10/30/
name: 2026-10-30-newsletter-fr
slug: 2026-10-30-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit un protocole de création de transactions de silent payments à partir de portefeuilles multipartites,
résume la divulgation responsable d'une vulnérabilité de déni de service qui affectait d'anciennes versions de Core Lightning, et explique
la mise à jour de la politique de sécurité de Bitcoin Core pour les vulnérabilités facilement découvrables. Sont également incluses nos
rubriques habituelles avec une sélection de questions et réponses de Bitcoin Stack Exchange, des annonces de nouvelles versions et versions
candidates, et des descriptions de changements notables dans des logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

- **Silent payments pour les portefeuilles multipartites** : Oleksandr Kurbatov a [posté][sp multi del] sur Delving Bitcoin la description
  d'un protocole permettant d'utiliser des entrées multipartites dans des transactions de [silent payment][topic silent payments].
  [BIP352][] ne recommande pas d'utiliser ce type d'entrée en raison de l'absence de preuve de sécurité. Le protocole permet à un expéditeur
  multipartite de calculer la part ECDH comme une somme pondérée des contributions des signataires, tout en fournissant une preuve agrégée
  [DLEQ][topic dleq], appelée AggDLEQ, pour prouver que la part ECDH est correctement dérivée de la clé d'entrée. La proposition fonctionne
  avec plusieurs protocoles multipartites, tels que [FROST][BIPs #2070] et [MuSig2][topic musig].

  Le protocole proposé repose sur deux tours. Un coordinateur fournit le contexte, contenant l'ensemble des signataires, les coefficients du
  protocole de signature et le tweak, le matériel de clé, la transaction, et un identifiant de session. Au cours du premier tour, chaque
  signataire génère deux nonces aléatoires et renvoie au coordinateur les messages nécessaires pour AggDLEQ, tels que la part ECDH calculée
  à partir de son propre fragment de clé et les engagements de nonce. Ces messages sont utilisés par le coordinateur pour calculer la part
  ECDH combinée et un challenge. Au cours du second tour, chaque signataire produit une contribution à la preuve basée sur le challenge
  fourni. Si les réponses sont correctes, le coordinateur agrège toutes les réponses en une preuve unique compatible avec [BIP374][].

  Kurbatov a déclaré que le protocole ne nécessite aucune modification de BIP352, BIP374, BIP375, ni des protocoles de signature MuSig2 et
  FROST, et aucun nouveau champ PSBT, car les messages AggDLEQ ne sont échangés qu'entre les signataires via le canal du coordinateur du
  portefeuille. Il a indiqué qu'un article avec des preuves de sécurité est en cours de revue interne, mais a noté que son affirmation selon
  laquelle les signataires corrompus et le coordinateur ne peuvent pas forger une preuve ou une signature repose sur une hypothèse dont la
  difficulté reste une question ouverte.

- **Divulgation d'un DoS d'annonce de canal auto-référentielle dans CLN :** Nishant Bansal a [posté][cln selfref dos] sur Delving Bitcoin
  pour divulguer une vulnérabilité de déni de service affectant les versions 25.02 à 26.04 de Core Lightning (CLN). CLN ne vérifiait jamais
  que les deux identifiants de nœud dans une [channel announcement][topic channel announcements] différaient, de sorte qu'une annonce
  désignant le même nœud comme les deux extrémités passait la validation et était écrite dans le magasin gossip sur disque avant d'être
  chargée dans le graphe des canaux en mémoire. Son chargement ajoutait deux fois le nœud inconnu, ce qui déclenchait une assertion
  d'absence de doublon dans `gossipd` et faisait planter le nœud. Le message stocké faisait ensuite à nouveau planter le nœud à chaque
  redémarrage jusqu'à ce que l'opérateur le supprime manuellement, ce qu'une simple mise à niveau ne faisait pas.

  Un attaquant n'avait besoin que de financer une sortie 2-sur-2 qu'il contrôlait et de signer l'annonce avec ces clés et une nouvelle clé
  de nœud, de sorte que le coût se limitait aux frais onchain. Les anciennes versions de CLN acceptent et relaient une telle annonce sans
  planter, elles pouvaient donc la transporter jusqu'aux nœuds vulnérables que l'attaquant ne pouvait pas atteindre directement.

  Bansal a trouvé le bug avec une cible de fuzzing gossip proposée plus tard dans [Core Lightning #9115][]. Il a été [divulgué de manière
  responsable][topic responsible disclosures] en avril et corrigé dans [CLN 26.04.1][cln 26.04.1] (voir le [Bulletin #398][news398 cln
  26041]) par [Core Lightning #9082][], qui rejette toute annonce dont `node_id_1` n'est pas strictement inférieur à `node_id_2`. [BOLTs
  #1333][] a ajouté la même exigence côté récepteur à [BOLT7][], qui n'imposait auparavant cet ordre qu'aux émetteurs. Les opérateurs
  utilisant encore une version affectée devraient mettre à niveau vers la dernière version.

- **Mise à jour de la politique de sécurité de Bitcoin Core** : Antoine Poinsot a [posté][poinsot policy ml] sur la liste de diffusion
  Bitcoin-Dev que Bitcoin Core a amendé sa [politique de sécurité][core security policy] (voir le [Bulletin #306][news306 disclosure]) pour
  les vulnérabilités qu'il classe comme facilement découvrables, comme celles trouvées à l'aide d'une simple requête à un grand modèle de
  langage. Le projet a constaté une augmentation des signalements de ce type de bugs, qui peuvent être redécouverts ou déduits à partir de
  correctifs discrets. Plutôt que d'attendre la prochaine version majeure et l'embargo fondé sur la sévérité qu'applique par ailleurs la
  politique, Bitcoin Core rétroporte désormais un correctif sur chaque version maintenue, publie des versions mineures dès que possible, et
  publie un avis en même temps. Les trois vulnérabilités décrites dans la section des changements notables dans le code de cette semaine
  ([Bitcoin Core #36665][], [#36667][bitcoin core #36667], et [#36669][bitcoin core #36669]) ont été divulguées sous cette nouvelle
  classification. Leurs correctifs ont été fusionnés après le tag de 32.0, donc 32.0 n'a jamais été publiée et [Bitcoin Core 32.1][]
  (décrite ci-dessous), ainsi que 31.2, 30.4 et 29.5, les embarquent à la place.

## Questions et réponses sélectionnées de Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech cherchent des réponses à leurs
questions---ou quand nous avons quelques moments libres pour aider les utilisateurs curieux ou confus. Dans cette rubrique mensuelle, nous
mettons en lumière certaines des questions et réponses les mieux votées postées depuis notre dernière mise à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Pourquoi Bitcoin utilise-t-il à la fois un identifiant de transaction et un identifiant de transaction témoin ?]({{bse}}131077) Pieter
  Wuille explique que [segwit][topic segwit] a déplacé les signatures et d'autres données malléables dans le témoin, que le txid exclut,
  afin que des chaînes présignées de transactions non confirmées continuent de fonctionner. Les entrées continuent donc de référencer des
  txids. Les blocs s'engagent en plus envers des wtxids afin qu'un nœud recevant un bloc avec des données de témoin altérées puisse le
  rejeter définitivement au lieu de retraiter chaque variante qu'un pair lui propose. [BIP339][] a ensuite étendu l'utilisation du wtxid au
  relais de transactions pour des raisons similaires de déni de service.

- [Comment signer un MuSig avec Bitcoin Core]({{bse}}131086) Ava Chow explique que la signature [MuSig2][topic musig] se fait en deux tours,
  de sorte que chaque portefeuille doit traiter la [PSBT][topic psbt] deux fois. Le premier passage ajoute le nonce public du portefeuille
  et le second, exécuté sur la PSBT combinée une fois que tous les nonces sont présents, ajoute sa signature partielle, après quoi
  `finalizepsbt` produit la transaction. L'auteur de la question a publié un [exemple][bc musig2] de création et de dépense depuis une
  adresse MuSig2 avec Bitcoin Core.

- [Qu'est-ce qui a changé dans la version 70017 du protocole P2P Bitcoin par rapport à 70016 ?]({{bse}}131080) Ava Chow explique que
  [BIP434][] assigne le nouveau numéro de version parce qu'il introduit un nouveau message `feature` échangé pendant la poignée de main
  `version`. Le message lui-même permet aux pairs d'annoncer et de négocier des fonctionnalités optionnelles pendant toute la durée d'une
  connexion, remplaçant la pratique historique consistant à augmenter la version du protocole ou à définir un message dédié pour chaque
  nouvelle fonctionnalité (voir le [Bulletin #386][news386 bip434]). Bitcoin Core a implémenté le message et l'augmentation de version plus
  tôt cette année (voir le [Bulletin #410][news410 bip434]), et les deux sont inclus dans [Bitcoin Core 32.1][], décrite ci-dessous.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires. Veuillez envisager de mettre à niveau vers
les nouvelles versions ou d'aider à tester les versions candidates._

- [Bitcoin Core 32.1][] est la dernière version majeure de l'implémentation de nœud complet prédominante du réseau. La version 32.0 a été
  taguée mais n'a jamais été complètement publiée en raison de problèmes de dernière minute. Cette version inclut les trois correctifs de
  sécurité décrits ci-dessous. Les autres changements incluent l'[estimation des frais][topic fee estimation] basée sur le mempool,
  [PSBT][topic psbt]v2 par défaut, les exportations de portefeuilles watch-only, et une validation des blocs plus rapide. Les index
  existants des transactions et des dépenseurs de sorties de transaction restent compatibles mais doivent être reconstruits pour économiser
  de l'espace disque. Voir les [notes de version][bcc32.1 rn] pour les détails et les considérations de mise à niveau. Les versions 29.x et
  antérieures ont atteint la fin de leur cycle de vie et ne recevront plus de mises à jour.

- [Bitcoin Core 31.2][] est une version de maintenance de l'implémentation prédominante de nœud complet. Elle inclut les mêmes trois
  correctifs de sécurité que 32.1. Elle exclut également de l'avertissement de soft fork inconnu [BIP9][] les bits de version que [BIP323][]
  réserve comme espace de nonce supplémentaire pour les mineurs (voir le [Bulletin #409][news409 bip323]), plafonne la file d'attente
  `-privatebroadcast` à 10 000 transactions, et compacte régulièrement la base de données chainstate. Voir les [notes de version][bcc31.2
  rn] pour les détails.

- [Bitcoin Core 30.4][] est une version de maintenance pour une série précédente de versions majeures. Elle inclut les mêmes trois
  correctifs de sécurité que 32.1, la modification de l'avertissement BIP323, et la suppression d'une seed DNS. Voir les [notes de
  version][bcc30.4 rn] pour les détails.

- [Bitcoin Core 29.5][] est une version de maintenance pour une série précédente de versions majeures. Elle inclut les mêmes trois
  correctifs de sécurité que 32.1 et la suppression d'une seed DNS. Voir les [notes de version][bcc29.5 rn] pour les détails.

- [Eclair 0.14.6][] est une version de sécurité pour cette implémentation de nœud LN. Elle inclut les correctifs de suivi des frais pour le
  force-close du [splicing][topic splicing] et le [financement à la volée][topic jit channels] décrits ci-dessous. Le projet recommande
  fortement la mise à niveau car des pairs malveillants peuvent exploiter certains des problèmes corrigés.

- [LND v0.21.5-beta][lnd0215] et [v0.20.6-beta][lnd0206] sont des versions de maintenance de cette populaire implémentation de nœud LN,
  faisant suite aux versions candidates couvertes dans le [Bulletin #428][news428 releases]. Les deux incluent les correctifs de feerate
  d'engagement décrits ci-dessous, ainsi que des correctifs pour une allocation mémoire excessive lors de l'analyse des enregistrements TLV
  et des interblocages de base de données SQL, et un nettoyage de démarrage plus rapide sur les nœuds utilisant SQL.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning
BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #36665][] corrige une [vulnérabilité d'épuisement mémoire][core tcp oom] qui permettait à un pair connecté de faire planter
  des nœuds exécutés sur Windows, macOS ou BSD. Bien que Bitcoin Core interrompe les lectures depuis un pair lorsque sa file de réception
  devient trop grande, son backend de sockets `select()` continuait à surveiller les conditions exceptionnelles. Un pair pouvait envoyer des
  données urgentes TCP pour déclencher des lectures supplémentaires et contourner la limite de file d'attente. Désormais, les conditions
  exceptionnelles ne sont surveillées que lorsque les lectures sont activées pour cette socket. Linux utilise un backend de sockets
  différent et n'était pas affecté.

- [Bitcoin Core #36667][] ajoute un délai d'expiration qui déconnecte un pair si le tampon d'envoi du nœud pour ce pair dépasse sa limite
  pendant plus de 20 minutes, atténuant une [croissance mémoire non bornée][core paused send oom]. Bitcoin Core continue à mettre en file
  d'attente certaines annonces de transactions même après dépassement de cette limite. En général, un délai d'expiration de ping finirait
  par déconnecter un pair lisant lentement. Cependant, les pairs prétendant utiliser une version de protocole antérieure à [BIP31][]
  pouvaient éviter cela. Cela permettait à un pair malveillant de maintenir une connexion ouverte pendant que les annonces en file d'attente
  s'accumulaient progressivement. Le nouveau délai d'expiration s'applique quelle que soit la version du protocole du pair. Les nœuds
  utilisant l'option `-blocksonly` étaient beaucoup moins affectés.

- [Bitcoin Core #36669][] corrige un [débordement de fichier undo][core undo overflow] qui pouvait corrompre les données nécessaires pour
  déconnecter des blocs lors d'une réorganisation. Comme les données undo peuvent dépasser la taille des données de bloc correspondantes, un
  fichier undo peut dépasser 4 Gio et faire déborder son décalage 32 bits, écrasant ainsi des données plus anciennes. Une réorganisation
  ultérieure pouvait arrêter le nœud, nécessitant une réindexation avec une version corrigée pour récupérer. Le correctif augmente la taille
  du décalage de fichier à 64 bits. Il utilise également des appels de positionnement de fichier 64 bits sur Windows, où dépasser 2 Gio
  pouvait arrêter le nœud même sans réorganisation. L'exploitation nécessite de miner des milliers de blocs spécialement construits. Pour le
  cas de corruption, elle nécessite aussi de positionner précisément ces blocs dans les fichiers de blocs du nœud visé, suivi d'une
  réorganisation. La divulgation considère cela comme impraticable. Les nœuds sur systèmes 32 bits ou avec un stockage des blocs en FAT32
  sont toujours affectés.

- [BIPs #2130][] ajoute le brouillon [BIP139][], Wallet Metadata Export Format, spécifiant un format JSON pour exporter les comptes de
  portefeuille et leurs [descripteurs de scripts de sortie][topic descriptors], les informations sur les signataires, les [étiquettes][topic
  wallet labels], les transactions, les coins, et les [PSBTs][topic psbt] (voir le [Bulletin #399][news399 metadata]). Ce format permet le
  transfert de métadonnées entre portefeuilles et la restauration d'informations qui ne peuvent pas être récupérées par une seule sauvegarde
  de seed. La spécification interdit d'inclure des clés privées de dépense ou des seeds mnémoniques dans les exports mainnet, de sorte que
  ces exports complètent une sauvegarde de clés distincte.

- [Core Lightning #9627][] met à jour `xpay` pour tenir compte de la limite de 1 300 octets d'informations de routage de [BOLT4][] pour
  l'oignon de paiement avant de sélectionner une route de paiement. Auparavant, la recherche de chemin pouvait réussir, mais la construction
  de l'oignon pouvait échouer si le chemin sélectionné dépassait la limite. Cela pouvait faire échouer un paiement même lorsqu'un chemin
  plus court aurait pu fonctionner. `xpay` calcule désormais l'espace disponible après avoir pris en compte la charge utile finale du
  receveur ou le [blinded path][topic rv routing] de la facture, puis transmet à askrene une limite de sauts correspondante via un nouveau
  paramètre `maxhops` sur son RPC `getroutes`. Le calcul du coût de recherche de chemin dans askrene ajoute également une pénalité pour
  chaque saut afin de favoriser les routes plus courtes.

- [Eclair #3417][] et [#3419][eclair #3419] améliorent la gestion du force-close lorsque des [transactions de splice][topic splicing]
  restent non confirmées (voir le [Bulletin #427][news427 eclair splicing]). Pour les canaux non-zero-conf, Eclair sélectionne désormais
  l'engagement le plus récent dont la transaction de financement est confirmée ou présente dans le mempool de son backend Bitcoin, en
  réévaluant ce choix à mesure que des blocs arrivent ou que des transactions de splice sont publiées. Il inclut également les ancêtres de
  financement non confirmés dans les calculs de frais [CPFP][topic cpfp] d'ancre et commence à réclamer les sorties des engagements distants
  non révoqués pour les états de financement antérieurs après une confirmation. Le nouveau paramètre
  `require-confirmed-inputs-for-splicing`, activé par défaut, exige des entrées confirmées du pair lors du splicing et empêche Eclair
  d'initier un autre splice tant que le précédent n'est pas confirmé. Les changements garantissent également qu'un engagement local
  précédemment publié est reconnu s'il est confirmé après qu'Eclair soit passé à un engagement différent. Auparavant, Eclair pouvait laisser
  son propre solde et ses sorties [HTLC][topic htlc] non réclamés.

- [Eclair #3416][] corrige un bug qui permettait à un pair d'obtenir de manière répétée du [financement à la volée][topic jit channels] sans
  payer les frais convenus de [liquidity advertisement][topic liquidity advertisements]. Auparavant, un pair pouvait rejeter les paiements
  proposés destinés à couvrir ces frais, alors qu'Eclair pouvait quand même compléter l'achat de liquidité. Désormais, Eclair signale les
  achats sous-payés et bloque le pair pour tout achat ultérieur payé à partir de paiements futurs (`from_future_htlc`). Le règlement
  d'autres parties d'un [paiement multipath][topic multipath payments] n'efface pas cet indicateur. Les pairs marqués comptent dans la
  limite existante de pairs suspects, qui désactive globalement cette méthode de paiement une fois atteinte. Les indicateurs sont effacés au
  redémarrage, par intervention de l'opérateur, ou si la transaction de financement est abandonnée avant publication.

- [LDK #5314][] corrige une fuite de confidentialité dans le relais des [onion message][topic onion messages] qui pouvait relier un [canal
  non annoncé][topic unannounced channels] à sa sortie de financement onchain. Un attaquant pouvait dériver un identifiant de canal court
  (SCID) candidat à partir de l'emplacement d'une sortie dans la blockchain. En se connectant aux deux extrémités supposées du canal et en
  leur envoyant un onion message qui revenait vers lui-même, l'attaquant pouvait utiliser le SCID pour identifier le canal entre elles. La
  réception du message confirmerait le lien entre la sortie et les nœuds. LDK refuse désormais de résoudre de vrais SCID pour les canaux non
  annoncés lors du relais d'onion messages. Les alias SCID restent utilisables. Cela complète les protections de confidentialité du relais
  HTLC couvertes dans le [Bulletin #426][news426 ldk5028].

- [LDK #5412][] corrige un bug de déni de service dans son serveur [LSPS2][BLIP52] pour les [canaux juste-à-temps][topic jit channels].
  Auparavant, un client pouvait soumettre à répétition le même identifiant de requête tant que la requête d'origine restait en attente.
  Chaque doublon augmentait le compteur global de requêtes en attente du service et remplaçait l'entrée stockée. L'atteinte de la limite de
  1 000 requêtes amenait le LSP à rejeter des requêtes d'autres clients, malgré un nombre bien inférieur de requêtes réelles à traiter. Les
  identifiants dupliqués sont désormais rejetés sans augmenter le compteur ni remplacer la requête d'origine.

- [LND #11164][] fait progresser son implémentation gossip-v2 en mettant à jour les formats de message pour correspondre à la dernière
  [proposition de gossip taproot][bolts #1059], ce qui permettrait aux nœuds d'[annoncer et vérifier des canaux taproot][topic channel
  announcements]. Les messages d'échange de signatures incluent désormais l'identifiant de transaction de financement pour distinguer les
  tentatives de financement en préparation du [splicing][topic splicing] et transportent des signatures partielles [MuSig2][topic musig]
  séparées pour le nœud et les clés de financement. Les changements corrigent également l'encodage des champs de frais et de capacité et
  préservent les champs optionnels contenant des valeurs par défaut. Cela préserve les octets signés lorsque les messages sont décodés puis
  réencodés, évitant ainsi les échecs de vérification des signatures.

- [LND #11373][] et [#11380][lnd #11380] appliquent de façon cohérente le feerate minimal existant de LND pour les engagements, de 253
  sat/kw, lors de l'ouverture des canaux et des mises à jour de frais. Auparavant, définir `max-commit-fee-rate-anchors=1` plafonnait le
  taux à 1 sat/vbyte, soit 250 sat/kw, légèrement en dessous du minimum. Un canal pouvait s'ouvrir à ce taux, mais il ne pouvait pas
  transporter de [HTLCs][topic htlc] tant que son initiateur n'augmentait pas le taux, car les mises à jour d'engagement ultérieures le
  rejetaient. LND relève désormais au minimum les taux d'ouverture proposés localement et rejette les propositions entrantes en dessous de
  ce seuil. Il vérifie également les mises à jour de frais entrantes et sortantes par rapport au minimum avant de les enregistrer ou de les
  envoyer, au lieu de ne les rejeter qu'au moment de signer les engagements. LND tente d'augmenter le feerate des canaux existants ouverts
  sous le minimum, mais ces canaux restent incapables de transporter des HTLCs si leur initiateur ne peut pas se permettre cette
  augmentation.

- [BTCPay Server #7744][] et [#7748][btcpay server #7748] corrigent deux erreurs lors de l'autorisation par les marchands des clés API
  d'application. Des permissions optionnelles qu'un marchand avait décochées pouvaient quand même être accordées. De plus, une application
  pouvait demander une permission limitée à un autre magasin et voir cette portée utilisée à la place du magasin sélectionné par le
  marchand. Les correctifs préservent les choix de permissions du marchand et retirent les portées de magasin fournies par l'application
  avant d'appliquer la sélection du magasin du marchand. Ces changements affectent l'émission des clés, à la suite des correctifs
  d'application des permissions couverts dans le [Bulletin
  #428][news428 btcpay7684]. Les clés précédemment émises conservent leurs
  permissions et peuvent devoir être révoquées si elles accordent un accès non intentionnel.

{% include snippets/recap-ad.md when="2026-11-03 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2070,36665,36667,36669,2130,9627,3417,3419,3416,5314,5412,11164,1059,11373,11380,7744,7748,9082,9115,1333" %}

[sp multi del]: https://delvingbitcoin.org/t/silent-payments-for-multiparty-wallets/2960
[Bitcoin Core 32.1]: https://bitcoincore.org/bin/bitcoin-core-32.1/
[bcc32.1 rn]: https://bitcoincore.org/en/releases/32.1/
[Bitcoin Core 31.2]: https://bitcoincore.org/bin/bitcoin-core-31.2/
[bcc31.2 rn]: https://bitcoincore.org/en/releases/31.2/
[news409 bip323]: /fr/newsletters/2026/06/12/#bitcoin-core-34779
[Bitcoin Core 30.4]: https://bitcoincore.org/bin/bitcoin-core-30.4/
[bcc30.4 rn]: https://bitcoincore.org/en/releases/30.4/
[Bitcoin Core 29.5]: https://bitcoincore.org/bin/bitcoin-core-29.5/
[bcc29.5 rn]: https://bitcoincore.org/en/releases/29.5/
[Eclair 0.14.6]: https://github.com/ACINQ/eclair/releases/tag/v0.14.6
[lnd0215]: https://github.com/lightningnetwork/lnd/releases/tag/v0.21.5-beta
[lnd0206]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.6-beta
[core tcp oom]: https://bitcoincore.org/en/2026/10/28/disclose-tcp-oom/
[core paused send oom]: https://bitcoincore.org/en/2026/10/28/disclose-fpausesend-oom/
[core undo overflow]: https://bitcoincore.org/en/2026/10/28/disclose-undo-overflow/
[LDK #5314]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5314
[LDK #5412]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5412
[BIP31]: https://github.com/bitcoin/bips/blob/master/bip-0031.mediawiki
[BLIP52]: https://github.com/lightning/blips/blob/master/blip-0052.md
[news399 metadata]: /fr/newsletters/2026/04/03/#projet-de-bip-pour-un-format-de-metadonnees-de-sauvegarde-de-portefeuille
[news428 releases]: /fr/newsletters/2026/10/23/#mises-à-jour-et-versions-candidates
[news426 ldk5028]: /fr/newsletters/2026/10/09/#ldk-5028
[news428 btcpay7684]: /fr/newsletters/2026/10/23/#btcpay-server-7684
[news427 eclair splicing]: /fr/newsletters/2026/10/16/#eclair-3396
[cln selfref dos]: https://delvingbitcoin.org/t/cln-self-referential-channel-announcement-dos-disclosure/2974
[cln 26.04.1]: https://github.com/ElementsProject/lightning/releases/tag/v26.04.1
[news398 cln 26041]: /fr/newsletters/2026/05/01/#core-lightning-26-04-1
[poinsot policy ml]: https://groups.google.com/g/bitcoindev/c/70VSp_ARD5Q
[core security policy]: https://bitcoincore.org/en/security-advisories/
[news306 disclosure]: /fr/newsletters/2024/06/07/#divulgation-a-venir-de-vulnerabilites-affectant-les-anciennes-versions-de-bitcoin-core
[bc musig2]: https://learningbitcoin.blockchaincommons.com/18_3_Using_Bitcoin_With_MuSig2/
[news386 bip434]: /fr/newsletters/2026/01/02/#negociation-de-fonctionnalites-entre-pairs
[news410 bip434]: /fr/newsletters/2026/06/19/#bitcoin-core-35221
