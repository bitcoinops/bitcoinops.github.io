---
title: 'Bulletin Hebdomadaire Bitcoin Optech #309'
permalink: /fr/newsletters/2024/06/28/
name: 2024-06-28-newsletter-fr
slug: 2024-06-28-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume une recherche sur l'estimation de la probabilité qu'un
paiement LN (Lightning Network) soit réalisable. On y trouvera également nos
rubriques habituelles avec des questions et réponses populaires
de la communauté Bitcoin Stack Exchange, des annonces de nouvelles versions et
versions candidates, ainsi que les changements apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Estimation de la probabilité qu'un paiement LN soit réalisable :** René Pickhardt a
  [posté][pickhardt feasible1] sur Delving Bitcoin à propos de l'estimation de la probabilité qu'un
  paiement LN soit réalisable étant donné la connaissance publique de la capacité maximale d'un canal
  mais sans aucune connaissance de sa distribution de solde actuelle. Par exemple, Alice a un canal avec Bob
  et Bob a un canal avec Carol. Alice connaît la capacité du canal Bob-Carol mais pas la part de ce
  solde contrôlée par Bob ni la part contrôlée par Carol.

  Pickhardt note que certaines distributions de richesse sont impossibles dans un réseau de paiement.
  Par exemple, Carol ne peut pas recevoir plus d'argent dans son canal avec Bob que la capacité de ce
  canal. Lorsque toutes les distributions impossibles sont exclues, il peut être utile de considérer
  toutes les distributions de richesse restantes comme également susceptibles de se produire. Cela
  peut être utilisé pour produire une métrique de la probabilité qu'un paiement soit réalisable.

  Par exemple, si Alice souhaite envoyer un paiement de 1 BTC à Carol, et que les seuls canaux par
  lesquels il peut passer sont Alice-Bob et Bob-Carol, alors nous pouvons examiner quel pourcentage de
  distributions de richesse dans le canal Alice-Bob et le canal Bob-Carol permettrait à ce paiement de
  réussir. Si le canal Alice-Bob a une capacité de plusieurs BTC, la plupart des distributions de
  richesse possibles permettraient au paiement de réussir. Si le canal Bob-Carol a une capacité de
  juste un peu plus de 1 BTC, alors la plupart des distributions de richesse possibles empêcheraient
  le paiement de réussir. Cela peut être utilisé pour calculer la probabilité globale de faisabilité
  d'un paiement de 1 BTC d'Alice à Carol.

  La probabilité de faisabilité rend clair que de nombreux paiements LN qui semblent naïvement
  possibles ne réussiront pas en pratique. Elle fournit également une base utile pour faire des
  comparaisons.
  Dans une [réponse][pickhardt feasible2], Pickhardt décrit comment la métrique de probabilité
  pourrait être utilisée par les portefeuilles et les logiciels d'entreprise pour prendre
  automatiquement certaines décisions intelligentes au nom de ses utilisateurs.

## Questions et réponses sélectionnées de Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech
cherchent des réponses à leurs questions---ou quand nous avons quelques moments libres pour aider
les utilisateurs curieux ou confus. Dans cette fonctionnalité mensuelle, nous mettons en lumière
certaines des questions et réponses les mieux votées publiées depuis notre dernière mise à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aa
nswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}


- [Comment est calculé la progression du Téléchargement Initial de Bloc (IBD) ?]({{bse}}123350)
  Pieter Wuille pointe vers la fonction `GuessVerificationProgress` de Bitcoin Core
  et explique que le total estimé des transactions dans la chaîne utilise des statistiques codées en
  dur qui sont mises à jour dans le cadre de chaque version majeure.

- [Qu'est-ce que l'`augmentation de progression par heure` pendant la synchronisation ?]({{bse}}123279)
  Pieter Wuille précise que l'augmentation de progression par heure est le pourcentage de
  la blockchain synchronisée par heure et non une augmentation du taux de progression. Il continue
  en notant les raisons pour lesquelles la progression n'est pas constante et peut varier.

- [Une coordonnée Y pair doit-elle être imposée après chaque opération de modification de clé, ou seulement à la fin ?]({{bse}}119485)
  Pieter Wuille est d'accord sur le fait que décider quand effectuer une négation de clé pour imposer
  des [clés publiques uniquement x][topic X-only public keys] est largement une question
  d'opinion tout en soulignant les avantages et inconvénients au sein de différents protocoles.

- [Portefeuilles mobiles pour Signet ?]({{bse}}123045)
  Murch liste quatre applications de portefeuille mobile compatibles avec [signet][topic signet] :
  Nunchuk, Lava, Envoy et Xverse.

- [Quel bloc a eu le plus de frais de transaction ? Pourquoi ?]({{bse}}7582)
  Murch révèle le bloc 409,008 avec les frais dénommés en bitcoin les plus élevés (291.533
  BTC causés par une sortie de changement manquante) et le bloc 818,087 avec les frais
  dénommés en USD les plus élevés (3,189,221.5 USD, également supposés être causés par une sortie de
  changement manquante).

- [bitcoin-cli listtransactions montant des frais est complètement erroné, pourquoi ?]({{bse}}123391)
  Ava Chow note que cette divergence se produit lorsque le portefeuille de Bitcoin Core n'est pas au
  courant de l'une des entrées d'une transaction, mais connaît les autres, comme dans l'exemple donné
  dans la question d'une transaction [payjoin][topic payjoin]. Elle continue en notant que "Le
  portefeuille ne devrait vraiment pas retourner les frais ici puisqu'il ne peut pas
  les déterminer avec précision."

- [Les clés publiques non compressées utilisaient-elles le préfixe `04` avant que les clés publiques compressées ne soient utilisées ?]({{bse}}123252)
  Pieter Wuille explique qu'historiquement la vérification de signature était effectuée par la
  bibliothèque OpenSSL qui permet des clés publiques non compressées (préfixe `04`), compressées
  (préfixes `02` et `03`), et hybrides (préfixes `06` et `07`).

- [Que se passe-t-il si la valeur d'un HTLC est inférieure à la limite de poussière ?]({{bse}}123393)
  Antoine Poinsot souligne que toute sortie dans une transaction d'engagement LN
  pourrait avoir une valeur inférieure à la [limite de poussière][topic uneconomical outputs] ce qui
  résulte en l'utilisation des satoshis de ces sorties pour les frais (voir [HTLCs coupés][topic trimmed htlc]).

- [Comment fonctionne subtractfeefrom ?]({{bse}}123262)
  Murch donne un aperçu de comment la [sélection de pièces][topic coin selection] dans
  Bitcoin Core fonctionne lorsque l'option `subtractfeefrom` est utilisée. Il note également que
  l'utilisation de `subtractfeefromoutput` cause plusieurs bugs lors de la recherche de transactions
  sans changement.

- [Quelle est la différence entre les 3 répertoires d'index "blocks/index/", "bitcoin/indexes" et "chainstate" ?]({{bse}}123364)
  Ava Chow énumère certains répertoires de données dans Bitcoin Core :

  - `blocks/index` qui contient la base de données LevelDB pour l'index des blocs
  - `chainstate/` qui contient la base de données LevelDB pour l'ensemble UTXO
  - `indexes/` qui contient les index optionnels txindex, coinstatsindex et blockfilterindex

## Mises à jour et versions candidates

*Nouvelles versions et candidats à la version pour les projets d'infrastructure Bitcoin populaires.
Veuillez envisager de passer aux nouvelles versions ou d'aider à tester les candidats à la version.*

- [LND v0.18.1-beta][] est une version mineure qui corrige "un [problème][lnd #8862] qui
  survient lors de la gestion d'une erreur après avoir tenté de diffuser des transactions si un
  backend btcd avec une version antérieure (pré-v0.24.2) est utilisé."

- [Bitcoin Core 26.2rc1][] est un candidat pour une version de maintenance de la série
  de versions antérieures de Bitcoin Core.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core
lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust
Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo], [Propositions
d'Amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips
repo], [Inquisition Bitcoin][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #29575][] simplifie le système de notation des comportements incorrects des pairs
  pour n'utiliser que deux augmentations : 100 points (résulte en une déconnexion immédiate et une
  désapprobation) et 0 point (comportement autorisé). La plupart des types de comportements incorrects
  sont évitables et ont été augmentés à un score de 100, tandis que deux comportements que des nœuds
  honnêtes et fonctionnant correctement pourraient effectuer dans certaines circonstances ont été
  réduits à 0. Ce PR supprime également l'heuristique qui ne considère que les messages P2P `headers`
  contenant un maximum de huit en-têtes de blocs comme une annonce possible [BIP130][] d'un nouveau
  bloc. Bitcoin Core traite désormais tous les messages `headers` qui ne se connectent pas à un arbre
  de blocs connu par le nœud comme des annonces de nouveaux blocs potentielles et demande les blocs
  manquants.

- [Bitcoin Core #28984][] ajoute le support pour une version limitée de [replace-by-fee][topic rbf]
  pour les [paquets][topic package relay] avec des clusters de taille deux (un parent, un enfant),
  incluant les transactions Topologically Restricted Until Confirmation ([TRUC][topic v3 transaction
  relay]) (alias transactions v3). Ces clusters ne peuvent remplacer qu'un cluster existant de la même
  taille ou plus petit. Voir le [Bulletin #296][news296 packagerbf] pour le contexte associé.

- [Core Lightning #7388][] supprime la capacité de créer des canaux [de style sortie ancré][topic anchor
  outputs] avec des frais non nuls pour se conformer aux changements dans la spécification BOLT faits
  en 2021 (voir le [Bulletin #165][news165 anchors]), tout en maintenant le support pour les canaux
  existants. Core Lightning était la seule implémentation à ajouter cela complètement, et seulement en
  mode expérimental, avant qu'il ne soit découvert comme étant non sécurisé (voir le [Bulletin
  #115][news115 anchors]) et remplacé par des canaux ancré sans frais. D'autres mises à jour
  incluent le rejet de `encrypted_recipient_data`
  contenant à la fois `scid` et `node`, analysant le formatage LaTeX ajouté à la spécification onion,
  et d'autres changements dans la spécification BOLT mentionnés dans les Bulletins [#259][news259
  bolts] et [#305][news305 bolts].

- [LND #8734][] améliore le processus d'abandon de l'estimation de route de paiement lorsque
  l'utilisateur interrompt la commande RPC `lncli estimateroutefee` en rendant la boucle de paiement
  consciente du contexte de streaming du client. Auparavant, interrompre cette commande pousserait le
  serveur à continuer inutilement le [sondage de paiement][topic payment probes] des routes. Voir le
  Bulletin [#293][news293 routefee] pour une référence précédente à cette commande.

- [LDK #3127][] implémente le transfert non strict pour améliorer la fiabilité des paiements, comme
  spécifié dans [BOLT4][], permettant aux [HTLCs][topic htlc] d'être transférés à un pair via des
  canaux autres que celui spécifié par `short_channel_id` dans le message onion. Les canaux avec le
  moins de liquidité sortante capable de passer le HTLC sont sélectionnés pour maximiser la
  probabilité de succès pour les HTLCs subséquents.

- [Rust Bitcoin #2794][] implémente l'application de la limite de taille de script de rachat de 520
  octets pour P2SH et de la limite de taille de script de témoin de 10 000 octets pour P2WSH en
  ajoutant des constructeurs susceptibles de faillir à `ScriptHash` et `WScriptHash`.

- [BDK #1395][] supprime la dépendance `rand` tant dans son utilisation explicite qu'implicite, la
  remplaçant par `rand-core` pour simplifier les dépendances, éviter la complexité ajoutée de
  `thread_rng` et `getrandom`, et offrir une plus grande flexibilité en permettant aux utilisateurs de
  passer leurs propres Générateurs de Nombres Aléatoires (RNGs).

- [BIPs #1620][] et [BIPs #1622][] ajoutent des changements à la spécification [BIP352][] des
  [paiements silencieux][topic silent payments]. Les discussions dans le PR mettant en œuvre les
  paiements silencieux dans la bibliothèque `secp256k1` recommandent d'ajouter un traitement des cas
  limites à [BIP352][], spécifiquement pour gérer les sommes de clés privées/publiques invalides pour
  l'envoi et la numérisation : échouer si la somme des clés privées est zéro (pour l'expéditeur), et
  échouer si la somme des clés publiques est le point à l'infini (pour le destinataire). Dans #1622,
  BIP352 est modifié pour calculer `input_hash` après l'agrégation des clés, et non avant, pour
  réduire la redondance et rendre le processus plus clair pour l'expéditeur et le destinataire.

- [BOLTs #869][] introduit un nouveau protocole de quiescence de canal sur BOLT2, qui vise à rendre
  les [mises à niveau de protocole][topic channel commitment upgrades] et les changements majeurs aux
  canaux de paiement plus sûrs et plus efficaces en assurant un état de canal stable pendant le
  processus. Le protocole introduit un nouveau type de message, `stfu` (SomeThing Fundamental is
  Underway), qui ne peut être envoyé que si l'`option_quiesce` a été négociée. Après l'envoi de
  `stfu`, l'expéditeur arrête tous les messages de mise à jour. Le destinataire doit alors cesser
  d'envoyer des mises à jour et répondre avec `stfu` si possible, de sorte que le canal devienne
  complètement quiescent. Voir les Bulletins [#152][news152 quiescence] et [#262][news262
  quiescence].

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29575,28984,7388,8734,3127,2794,1395,1620,1622,869,8862" %}
[bitcoin core 26.2rc1]: https://bitcoincore.org/bin/bitcoin-core-26.2/
[pickhardt feasible1]: https://delvingbitcoin.org/t/estimating-likelihood-for-lightning-payments-to-be-in-feasible/973
[pickhardt feasible2]: https://delvingbitcoin.org/t/estimating-likelihood-for-lightning-payments-to-be-in-feasible/973/4
[lnd v0.18.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.1-beta
[news296 packagerbf]: /fr/newsletters/2024/04/03/#bitcoin-core-29242
[news259 bolts]: /fr/newsletters/2024/05/31/#bolts-1092
[news305 bolts]:/fr/newsletters/2023/07/12/#proposition-de-nettoyage-de-la-specification-ln
[news293 routefee]: /fr/newsletters/2024/03/13/#lnd-8136
[news152 quiescence]: /en/newsletters/2021/06/09/#c-lightning-4532
[news262 quiescence]:/fr/newsletters/2023/08/02/#eclair-2680
[news115 anchors]: /en/newsletters/2020/09/16/#stealing-onchain-fees-from-ln-htlcs
[news165 anchors]: /en/newsletters/2021/09/08/#bolts-824
