---
title: 'Bulletin Hebdomadaire Bitcoin Optech #316'
permalink: /fr/newsletters/2024/08/16/
name: 2024-08-16-newsletter-fr
slug: 2024-08-16-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit une nouvelle forme de manipulation temporelle (time warp) qui
est particulièrement conséquente pour le nouveau testnet4, résume les discussions sur les mesures de
mitigation proposées pour les préoccupations de déni de service des messages onion, sollicite des
retours sur une proposition permettant aux payeurs LN d'optionnellement s'identifier, et annonce un
changement majeur dans la compilation de Bitcoin Core qui pourrait affecter les développeurs et
intégrateurs en aval. Sont également incluses nos sections
régulières décrivant les mises à jour des clients et services, avec les annonces de nouvelles versions et les changements
apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Nouvelle vulnérabilité de manipulation temporelle dans testnet4 :** Mark "Murch" Erhardt a
  [publié][erhardt warp] sur Delving Bitcoin pour décrire une attaque [découverte][zawy comment] par
  le développeur Zawy pour exploiter le nouvel algorithme d'ajustement de difficulté de
  [testnet4][topic testnet]. Testnet4 a appliqué une solution issue du soft fork de [nettoyage du
  consensus][topic consensus cleanup] pour le mainnet qui est censée bloquer l'attaque de
  [manipulation temporelle][topic time warp]. Cependant, Zawy a décrit une attaque similaire à la
  manipulation temporelle qui pourrait être utilisée même avec la nouvelle règle pour réduire la
  difficulté de minage à 1/16ème de sa valeur normale. Erhardt a étendu l'attaque de Zawy pour
  permettre de réduire la difficulté à sa valeur minimale. Nous décrivons plusieurs attaques liées
  sous une forme simplifiée ci-dessous :

  Les blocs Bitcoin sont produits de manière stochastique, avec la difficulté censée être _ajustée_
  tous les 2 016 blocs pour maintenir le temps moyen entre les blocs à environ 10 minutes.
  L'illustration simplifiée suivante montre ce qui est supposé se passer avec un taux constant de
  production de blocs, étant donné un ajustement tous les 5 blocs (réduit de tous les 2 016 blocs pour
  rendre l'illustration lisible) :

  ![Illustration du minage honnête avec un hashrate constant (simplifié)](/img/posts/2024-time-warp/reg-blocks.png)

  Un mineur malhonnête (ou un cabal de mineurs) possédant légèrement plus de 50% du hashrate peut
  censurer les blocs produits par les autres mineurs légèrement moins nombreux. Cela conduirait
  naturellement à la production d'un seul bloc toutes les 20 minutes en moyenne. Après 2 016 blocs
  produits selon ce schéma, la difficulté s'ajusterait à 1/2 de sa valeur originale pour retourner le
  taux de blocs ajoutés à la chaîne principale à un bloc toutes les 10 minutes en moyenne :

  ![Illustration de la censure de blocs par un attaquant possédant légèrement plus de 50% du hashrate total du réseau (simplifié)](/img/posts/2024-time-warp/50p-attack.png)

  Une attaque de manipulation temporelle se produit lorsque les mineurs malhonnêtes utilisent leur
  majorité de hashrate pour forcer les horodatages dans la plupart des blocs à utiliser la valeur
  minimale autorisée. À la fin de chaque période de réajustement de 2 016 blocs, ils augmentent le
  temps de l'en-tête de bloc au [temps réel][] pour faire semblant que la production des blocs a pris
  plus de temps qu'elle ne l'a réellement fait, conduisant à une difficulté plus basse pour la période
  suivante.

  <!-- TODO:harding peut probablement intégrer l'illustration ci-dessous dans la page du sujet sur le
  décalage temporel -->

  ![Illustration d'une attaque classique de décalage temporel (simplifiée)](/img/posts/2024-time-warp/classic-time-warp.png)

  La [nouvelle règle][testnet4 rule] appliquée à testnet4 résout ce problème en
  empêchant le premier bloc d'une nouvelle période de recalibrage d'avoir un
  horodatage beaucoup plus ancien que son bloc précédent (le dernier bloc de la
  période précédente).

  Comme l'attaque de décalage temporel originale, la version d'Erhardt de l'attaque de Zawy
  augmente l'heure de l'en-tête de la plupart des blocs du minimum absolu. Cependant, pour
  deux périodes de recalibrage sur trois, elle avance le temps pour
  le dernier bloc d'une période et le premier bloc de la période suivante. Cela diminue la difficulté
  au maximum autorisé chaque période (1/4 de la valeur actuelle). Pour la troisième période, elle
  utilise le temps le plus bas autorisé pour tous les blocs, plus le premier bloc de la période
  suivante, ce qui augmente la difficulté à la valeur maximale (4x). En d'autres termes, la difficulté
  diminue de 1/4, diminue à nouveau à 1/16, puis augmente à 1/4 de sa valeur originale :

  ![Illustration de la version d'Erhardt de la nouvelle attaque de décalage temporel de Zawy (simplifiée)](/img/posts/2024-time-warp/new-time-warp.png)

  Le cycle de trois périodes peut être répété indéfiniment pour réduire
  la difficulté de 1/4 à chaque cycle, la réduisant finalement à un niveau qui
  permet aux mineurs de produire jusqu'à [6 blocs par seconde][erhardt se].

  Pour réduire la difficulté de 1/4 dans une période de recalibrage, les mineurs attaquants
  doivent régler le temps des blocs de recalibrage à 8 semaines de plus que le bloc au
  début de la période actuelle. Pour faire cela
  deux fois de suite au début de l'attaque nécessite finalement de régler
  le temps de certains blocs à 16 semaines dans le futur. Les nœuds complets
  n'accepteront pas des blocs datés de plus de deux heures dans le futur, empêchant
  les blocs malveillants d'être acceptés pendant 8 semaines pour le premier ensemble de blocs et 16
  semaines pour le second ensemble de blocs. Pendant que les mineurs attaquants attendent que leurs
  blocs soient acceptés, ils peuvent créer
  des blocs supplémentaires à des difficultés toujours plus faibles. Tout bloc créé par
  des mineurs honnêtes pendant les 16 semaines que les attaquants préparent leur
  attaque sera réorganisé offchain lorsque les nœuds complets commenceront
  à accepter les blocs des attaquants ; cela pourrait marquer chaque transaction
  confirmée pendant ce temps comme non confirmée ou invalide
  (_conflicted_) sur la chaîne actuelle.

  Erhardt suggère de résoudre l'attaque avec un soft fork qui exige
  que l'horodatage du dernier bloc d'une période de recalibrage soit supérieur
  à celui du premier bloc de cette période. Zawy a proposé
  plusieurs solutions, y compris interdire aux horodatages des blocs de
  diminuer (ce qui pourrait créer des problèmes si certains mineurs créent des blocs près de
  la limite future de deux heures imposée par les nœuds), ou au moins les empêcher de diminuer de plus
  de deux heures environ.

  Globalement, sur le mainnet, la nouvelle attaque de décalage temporel est similaire à l'
  attaque originale dans ses exigences en matière d'équipement minier, sa capacité
  à être détectée à l'avance, ses conséquences pour les utilisateurs, et la
  relative simplicité d'un soft fork pour la corriger. Elle dépend d'un
  attaquant maintenant le contrôle sur au moins 50 % du taux de hachage pendant au moins un mois,
  tout en signalant probablement aux utilisateurs qu'une attaque était imminente et en espérant qu'ils
  ne réagissent pas, ce qui pourrait être assez difficile sur le mainnet. Comme Zawy le [note][zawy
  testnet risk], l'attaque est beaucoup plus facile sur le testnet : une petite quantité d'équipement
  minier moderne suffit pour atteindre 50 % du taux de hachage sur le testnet et préparer l'attaque en
  toute discrétion. Un attaquant pourrait alors, en théorie, produire plus de 500 000 blocs par jour.
  Seul quelqu'un prêt à dédier une plus grande quantité de taux de hachage au testnet pourrait arrêter
  un attaquant à moins que l'attaque soit prévenue en utilisant un soft fork.

  Au moment de la rédaction, les compromis entre les solutions proposées étaient en cours de
  discussion.

- **Discussion sur le risque de DoS des messages Onion :** Gijs van Dam a [posté][vandam onion] sur
  Delving Bitcoin pour discuter d'un récent [article][bk onion] par les chercheurs Amin Bashiri et
  Majid Khabbazian à propos des [messages onion][topic onion messages]. Les chercheurs notent que
  chaque message onion peut être transmis à travers de nombreux nœuds (481 sauts selon les calculs de
  Van Dam), gaspillant potentiellement la bande passante pour tous ces nœuds. Ils décrivent plusieurs
  méthodes pour réduire le risque d'abus de bande passante, incluant une méthode astucieuse exigeant
  une quantité exponentiellement croissante de PoW pour chaque saut supplémentaire, rendant les routes
  courtes moins couteuses en calcul que les routes longues.

  Matt Corallo a suggéré d'essayer d'abord une idée précédemment proposée (voir le [Bulletin
  #207][news207 onion]) pour fournir une contre-pression sur les nœuds envoyant trop de messages onion
  avant de travailler sur quelque chose de plus compliqué.

- **Identification et authentification optionnelles des payeurs LN :** Bastien Teinturier a
  [posté][teinturier auth] sur Delving Bitcoin pour proposer des méthodes permettant aux payeurs
  d'inclure éventuellement des données supplémentaires avec leurs paiements qui permettraient aux
  receveurs d'identifier ces paiements comme provenant d'un contact connu. Par exemple, si Alice
  génère une [offre][topic offers] que Bob paie, elle peut vouloir une preuve cryptographique que le
  paiement vient de Bob et non d'un tiers se faisant passer pour Bob. Les offres sont conçues par
  défaut pour cacher les identités du payeur et du récepteur, donc des mécanismes supplémentaires
  sont nécessaires pour permettre une identification et une authentification facultatives.

  Teinturier commence par décrire un mécanisme de distribution d'une souscription de _clé de contact_ que Bob peut
  utiliser pour divulguer une clé publique à Alice. Il décrit ensuite trois candidats potentiels pour
  un mécanisme opt-in supplémentaire que Bob peut utiliser pour signer ses paiements à Alice. Si Bob
  utilise ce mécanisme, le portefeuille LN d'Alice peut authentifier cette signature comme appartenant
  à Bob et afficher cette information pour elle. Dans les paiements non authentifiés, les champs
  définis par le payeur (tels que le champ `payer_note` en forme libre) peuvent être marqués comme
  non fiables pour décourager les utilisateurs de se fier aux informations fournies.

  Des retours sur les méthodes cryptographiques à utiliser sont demandés, avec Teinturier prévoyant de
  publier [BLIP42][blips #42] avec une spécification pour les méthodes sélectionnées.

- **Passage de Bitcoin Core au système de compilation CMake :** Cory Fields a [posté][fields cmake]
  sur la liste de diffusion Bitcoin-Dev pour annoncer le passage imminent de Bitcoin Core du système
  de compilation GNU autotools au
  système de compilation CMake, qui a été dirigé par Hennadii Stepanov avec des contributions de
  Michael Ford pour les corrections de bugs et la modernisation, avec des revues et contributions de
  plusieurs autres développeurs (y compris Fields). Cela ne devrait pas affecter ceux qui utilisent
  les binaires compilés disponibles sur BitcoinCore.org---ce que nous attendons que la plupart
  des gens utilisent. Cependant, les développeurs et les intégrateurs qui construisent leurs propres
  binaires pour les tests ou la personnalisation peuvent être affectés---surtout ceux travaillant sur
  des plateformes ou des configurations de compilations peu communes.

  L'email de Fields fournit des réponses aux questions anticipées et demande à quiconque construit
  Bitcoin Core par lui-même de tester la [PR #30454][bitcoin core #30454] et de signaler tout problème.
  Cette PR est prévue pour être fusionnée dans les prochaines semaines avec une sortie anticipée dans la
  version 29 (prévue environ 7 mois à partir de maintenant). Plus tôt vous testez, plus les
  développeurs de Bitcoin Core auront de temps pour corriger les problèmes avant la sortie de la
  version 29---augmentant la chance qu'ils puissent prévenir les problèmes dans le code publié
  d'affecter votre configuration.

## Nouvelles versions et versions candidates

*Nouvelles version et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à jour vers les nouvelles versions ou d'aider à tester les candidats à la sortie.*

- [BDK 1.0.0-beta.1][] est une version candidate pour cette bibliothèque pour construire des
  portefeuilles et d'autres applications activées par Bitcoin. Le paquet Rust `bdk` original a été
  renommé en `bdk_wallet` et les modules de couche inférieure ont été extraits dans leurs propres
  paquets de codes, y compris `bdk_chain`, `bdk_electrum`, `bdk_esplora`, et `bdk_bitcoind_rpc`. Le paquet
  `bdk_wallet` "est la première version à offrir une API stable 1.0.0."

- [Core Lightning 24.08rc2][] est une version candidate pour la prochaine version majeure de cette
  implémentation populaire de nœud LN.

- [LND v0.18.3-beta.rc1][] est une version candidate pour une sortie de correction de bug mineur
  de cette implémentation populaire de nœud LN.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo],
[Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin
inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #29519][] réinitialise la valeur `pindexLastCommonBlock` après qu'un instantané
  [assumeUTXO][topic assumeutxo] est chargé, de sorte qu'un nœud priorise le téléchargement de blocs
  après le bloc le plus récent dans l'image. Cela corrige un bug où un nœud définirait
  `pindexLastCommonBlock` à partir des pairs existants avant de charger l'image et commencerait à
  télécharger des blocs à partir de ce bloc beaucoup plus ancien. Bien que les blocs plus anciens
  doivent encore être téléchargés pour la validation en arrière-plan d'assumeUTXO, les blocs plus
  récents devraient recevoir la priorité afin que
  les utilisateurs peuvent voir si leurs transactions récentes ont été confirmées.

- [Bitcoin Core #30598][] supprime la hauteur de bloc des métadonnées du fichier snapshot
  [assumeUTXO][topic assumeutxo] car elle n'est pas un identifiant unique dans un fichier non fiable
  pré-assaini par rapport au hash de bloc qui est conservé. Un nœud peut toujours obtenir la hauteur
  de bloc à partir de nombreuses autres sources internes.

- [Bitcoin Core #28280][] optimise la performance du Téléchargement Initial de Bloc (IBD) pour les
  nœuds élagués en ne vidant pas le cache UTXO pendant le processus de vidanges d'élagage. Il le fait en suivant
  séparément les entrées de cache "sales"---les entrées qui ont changé depuis qu'elles ont été écrites
  pour la dernière fois dans la base de données. Cela permet à un nœud d'éviter de scanner inutilement
  tout le cache pendant les vidanges d'élagage et de se concentrer à la place sur les entrées sales.
  L'optimisation résulte en une IBD jusqu'à 32% plus rapide pour les nœuds élagués avec des paramètres
  `dbcache` élevés, et environ 9% d'amélioration avec les paramètres par défaut. Voir le Bulletin
  [#304][news304 cache].

- [Bitcoin Core #28052][] ajoute un encodage [XOR][] aux fichiers `blocksdir *.dat` lors de la
  création comme mécanisme préventif contre la corruption de données accidentelle et involontaire par
  des logiciels anti-virus ou similaires. Cela peut être désactivé optionnellement et ne protège pas
  contre les attaques de corruption de données intentionnelles. Cela a été implémenté pour les
  fichiers `chainstate` dans [Bitcoin Core #6650][] en septembre 2015 et le mempool dans
  [#28207][bitcoin core #28207] en novembre 2023 (voir le [Bulletin #277][news277 bcc28207]).

- [Core Lightning #7528][] ajuste l'estimation du [taux de frais][topic fee estimation] pour les
  balayages de fermetures unilatérales de canaux non sensibles au temps à une échéance absolue de 2016
  blocs (environ 2 semaines). Auparavant, le taux de frais était fixé pour cibler une confirmation
  dans les 300 blocs, ce qui parfois causait le blocage des transactions à la [limite de frais de
  relais minimum][topic default minimum transaction relay feerates], entraînant des retards indéfinis.

- [Core Lightning #7533][] met à jour les notifications de mouvement de pièces internes et le livre
  de comptes des transactions pour comptabiliser correctement la dépense des sorties de financement
  pour les transactions de [splicing][topic splicing]. Auparavant, il n'y avait ni journalisation ni
  suivi de cela.

- [Core Lightning #7517][] introduit `askrene`, un nouveau plugin expérimental et une infrastructure
  API pour la recherche de chemins à coût minimum basée sur le plugin `renepay` (Voir le Bulletin
  [#263][news263 renepay]) pour une mise en œuvre améliorée des Paiements Pickhart. La commande RPC
  `getroutes` permet la spécification de données de capacité de canal persistantes et d'informations
  transitoires telles que les [chemins aveuglés][topic rv routing] ou les indices de route, et
  retourne un ensemble de routes possibles avec leur probabilité estimée de succès. Plusieurs autres
  commandes RPC sont ajoutées pour gérer les données de routage en couches en ajoutant des canaux, en
  manipulant les données des canaux, en excluant des nœuds du routage, en inspectant les données des
  couches, et en gérant les tentatives de paiement en cours.

- [LND #8955][] ajoute un champ `utxo` optionnel sur la commande `sendcoins` (et `Outpoints` pour la
  commande RPC `SendCoinsRequest` correspondante) pour simplifier l'expérience utilisateur de
  [sélection de pièces][topic coin selection] en une seule étape. Auparavant, un utilisateur devait
  passer par un processus de commande en plusieurs étapes qui incluaient
  la sélection de pièces, l'estimation des frais, le financement [PSBT][topic psbt], la complétion de
  PSBT et la diffusion de transactions.

- [LND #8886][] met à jour la fonction `BuildRoute` pour supporter les [frais de transfert
  entrants][topic inbound forwarding fees] en inversant le processus de recherche de
  chemin, travaillant désormais du destinataire vers l'expéditeur, permettant des calculs de frais
  plus précis sur plusieurs sauts. Voir le Bulletin [#297][news297 inboundfees] pour plus
  d'informations sur les frais entrants.

- [LND #8967][] ajoute un nouveau type de message wire `Stfu` (SomeThing Fundamental is Underway)
  conçu pour verrouiller l'état du canal avant d'initier les [mises à niveau du protocole][topic
  channel commitment upgrades]. Le type de message `Stfu` comprend des champs pour l'identifiant du
  canal, un drapeau initiateur et des données supplémentaires pour d'éventuelles extensions futures.
  Cela fait partie de l'implémentation du protocole Quiescence (voir le Bulletin [#309][news309
  quiescence]).

- [LDK #3215][] vérifie qu'une transaction a une longueur d'au moins 65 octets pour se protéger
  contre une [attaque coûteuse et peu probable][spv attack] contre un portefeuille SPV de client léger
  où une preuve SPV valide peut être créée pour une fausse transaction de 64 octets en faisant
  correspondre le hash d'un nœud interne de merkle. Voir les [vulnérabilités de l'arbre de merkle][topic
  merkle tree vulnerabilities].

- [BLIPs #27][] ajoute BLIP04 pour une proposition de protocole expérimental de signalisation
  d'[approbation HTLC][topic htlc endorsement] pour atténuer partiellement les [attaques de blocage de
  canal][topic channel jamming attacks] sur le réseau. Il décrit les valeurs TLV d'approbations
 expérimentales, l'approche de déploiement et la dépréciation éventuelle de la phase expérimentale
  lorsque les approbations HTLC sont intégrés dans les BOLTs.

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29519,30598,28280,28052,7528,7533,7517,8955,8886,8967,3215,1658,27,30454,42,6650,28207" %}
[BDK 1.0.0-beta.1]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.1
[erhardt se]: https://bitcoin.stackexchange.com/a/123700
[erhardt warp]: https://delvingbitcoin.org/t/zawy-s-alternating-timestamp-attack/1062
[zawy comment]: https://github.com/bitcoin/bitcoin/pull/29775#issuecomment-2276135560
[temps réel]: https://en.wikipedia.org/wiki/Elapsed_real_time
[testnet4 rule]: https://github.com/bitcoin/bips/blob/master/bip-0094.mediawiki#time-warp-fix
[news36 warp rule]: /en/newsletters/2019/03/05/#the-time-warp-attack
[zawy testnet risk]: https://delvingbitcoin.org/t/zawy-s-alternating-timestamp-attack/1062/5
[vandam onion]: https://delvingbitcoin.org/t/onion-messaging-dos-threat-mitigations/1058
[bk onion]: https://fc24.ifca.ai/preproceedings/104.pdf
[news207 onion]: /en/newsletters/2022/07/06/#onion-message-rate-limiting
[teinturier auth]: https://delvingbitcoin.org/t/bolt-12-trusted-contacts/1046
[fields cmake]: https://mailing-list.bitcoindevs.xyz/bitcoindev/6cfd5a56-84b4-4cbc-a211-dd34b8942f77n@googlegroups.com/
[Core Lightning 24.08rc2]: https://github.com/ElementsProject/lightning/releases/tag/v24.08rc2
[LND v0.18.3-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.3-beta.rc1
[news304 cache]: /fr/newsletters/2024/05/24/#bitcoin-core-28233
[news263 renepay]: /fr/newsletters/2023/08/09/#core-lightning-6376
[news309 quiescence]: /fr/newsletters/2024/06/28/#bolts-869
[spv attack]: https://web.archive.org/web/20240329003521/https://bitslog.com/2018/06/09/leaf-node-weakness-in-bitcoin-merkle-tree-design/
[news297 inboundfees]: /fr/newsletters/2024/04/10/#lnd-6703
[news277 bcc28207]: /fr/newsletters/2023/11/15/#bitcoin-core-28207
[xor]: https://en.wikipedia.org/wiki/One-time_pad
