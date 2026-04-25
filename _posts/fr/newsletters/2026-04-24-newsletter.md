---
title: 'Bulletin Hebdomadaire Bitcoin Optech #402'
permalink: /fr/newsletters/2026/04/24/
name: 2026-04-24-newsletter-fr
slug: 2026-04-24-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit le travail de Hornet Node sur une spécification exécutable déclarative des règles de consensus et résume
une discussion à propos du brouillage par saturation des messages onion dans le réseau Lightning. Sont également incluses nos rubriques
habituelles avec des questions et réponses sélectionnées de Bitcoin Stack Exchange, des annonces de nouvelles versions et versions
candidates, et des descriptions de changements notables apportés aux logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

- **Spécification exécutable déclarative des règles de consensus Bitcoin par Hornet Node** : Toby Sharp a [publié][topic hornet update] sur
  Delving Bitcoin et la [liste de diffusion][hornet ml post] Bitcoin-Dev une mise à jour sur le projet de nœud Hornet. Sharp avait
  [précédemment][topic hornet] décrit une nouvelle implémentation de nœud, Hornet, qui réduisait les temps de téléchargement initial de la
  chaîne de 167 minutes à 15 minutes. Dans cette mise à jour, il indique avoir achevé une spécification déclarative des règles de validation
  de bloc hors-script, composée de 34 invariants sémantiques assemblés à l'aide d'une algèbre simple.

  Sharp présente également les travaux futurs, notamment l'extension de la spécification à la validation des scripts, et discute de
  comparaisons potentielles avec d'autres implémentations telles que libbitcoin en réponse aux retours d'Eric Voskuil.

- **Brouillage par saturation des messages onion dans le réseau Lightning** : Erick Cestari a [publié][onion del] sur Delving Bitcoin à
  propos du problème de brouillage par saturation des [messages onion][topic onion messages] affectant le réseau Lightning. BOLT4 reconnaît
  que les messages onion sont peu fiables, recommandant d'appliquer des techniques de limitation de débit. Selon Cestari, ces techniques
  sont ce qui rend possible le brouillage des messages. Des attaquants peuvent lancer des nœuds malveillants et inonder le réseau de
  messages indésirables déclenchant les limites de débit des pairs, les forçant à abandonner des messages légitimes. De plus, BOLT4 n'impose
  pas de longueur maximale de message, permettant aux attaquants de maximiser la portée d'un seul message.

  Cestari a examiné plusieurs mesures d'atténuation contre le brouillage par saturation des messages onion et a fourni une vue d'ensemble
  complète des techniques qu'il jugeait les plus appropriées :

  - *Frais initiaux*: Cette technique a été proposée pour la première fois par Carla Kirk-Cohen dans [BOLTs #1052][] comme solution au
    brouillage des canaux, mais peut être facilement étendue. Les nœuds annonceraient des frais fixes par message, à inclure dans la charge
    utile onion et à déduire à chaque saut. Dans le cas où les frais ne sont pas payés, le message serait simplement abandonné par le nœud.
    Cette méthode présente certaines limites, comme la possibilité de ne transférer des messages qu'aux pairs de canal et une surcharge p2p
    accrue.

  - *Limite de sauts et preuve d'enjeu fondée sur les soldes des canaux*: Cette technique a été [proposée][mitig2 onion] par Bashiri et
    Khabbazian à l'Université de l'Alberta et comporte deux composantes différentes :

    - Encadrement strict du nombre de sauts : soit fixer une limite dure au nombre maximal de sauts qu'un message peut effectuer (par ex. 3
      sauts), soit demander à l'expéditeur de résoudre une énigme de preuve de travail, dont la difficulté augmente exponentiellement avec
      le nombre de sauts.

    - Règle de transfert par preuve d'enjeu : chaque nœud fixe des limites de débit par pair selon le solde agrégé des canaux du pair,
      accordant aux nœuds bien financés une plus grande capacité de transfert.

    Les compromis de cette approche sont liés à la pression à la centralisation, puisque les nœuds plus importants sont avantagés, tandis
    que la limite dure à 3 sauts pourrait réduire l'ensemble d'anonymat.

  - *Paiement mesuré par bande passante*: [Proposée][mitig3 onion] par Olaoluwa Osuntokun, cette technique a un objectif similaire à celui
    des frais initiaux, mais ajoute un état par session et règle via des [paiements AMP][topic amp]. Un expéditeur enverrait d'abord le
    paiement AMP, déposant des frais à chaque étape intermédiaire et fournissant un identifiant pour la session. L'expéditeur inclurait
    ensuite cet identifiant dans le message onion. Les limites connues de cette approche sont liées à la capacité de ne transférer des
    messages qu'aux pairs de canal et à la possibilité de relier tous les messages appartenant à la même session.

  - *Limitation de débit fondée sur la rétropropagation*: Cette approche, [proposée][mitig4 onion] par Bastien Teinturier, utilise un
    mécanisme de contre-pression capable statistiquement de remonter le spam jusqu'à sa source. Lorsque la limitation de débit par pair est
    atteinte, le nœud renvoie un message d'abandon à l'expéditeur, qui à son tour le relaie au dernier pair ayant transféré le message
    d'origine en divisant par deux sa limite de débit. Bien que le bon expéditeur soit identifié statistiquement, le mauvais pair pourrait
    être pénalisé. De plus, un attaquant pourrait falsifier le message d'abandon, abaissant les limites de débit des nœuds honnêtes.

  Enfin, Cestari a invité les développeurs LN à rejoindre la discussion, déclarant qu'une fenêtre reste disponible pour atténuer le problème
  avant que des attaques DDoS prolongées ne frappent le réseau, comme cela [est récemment arrivé à Tor][tor issue].

## Questions et réponses sélectionnées de Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech cherchent des réponses à leurs
questions---ou quand nous avons quelques moments libres pour aider les utilisateurs curieux ou confus. Dans cette rubrique mensuelle, nous
mettons en lumière certaines des questions et réponses les mieux votées postées depuis notre dernière mise à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Pourquoi BIP342 a-t-il remplacé CHECKMULTISIG par un nouvel opcode, au lieu de simplement en retirer FindAndDelete ?]({{bse}}130665)
  Pieter Wuille explique que le remplacement de `OP_CHECKMULTISIG` par `OP_CHECKSIGADD` dans [tapscript][topic tapscript] était nécessaire
  pour permettre la vérification par lots des signatures [schnorr][topic schnorr signatures] (voir le [Bulletin #46][news46 batch]) dans le
  cadre d'une potentielle future modification du protocole.

- [SIGHASH_ANYPREVOUT s'engage-t-il sur le hachage du tapleaf ou sur le chemin merkle taproot complet ?]({{bse}}130637) Antoine Poinsot
  confirme que les signatures [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] s'engagent actuellement uniquement sur le hachage du tapleaf,
  et non sur le chemin merkle complet dans l'arbre [taproot][topic taproot]. Toutefois, cette conception est en discussion car l'un des
  coauteurs du BIP a suggéré de s'engager plutôt sur le chemin merkle complet.

- [Que garantit l'ajustement BIP86 dans un canal Lightning MuSig2, au-delà du format d'adresse ?]({{bse}}130652) Ava Chow souligne que
  l'ajustement empêche l'utilisation de chemins de script cachés parce que le protocole de signature de [MuSig2][topic musig] exige que tous
  les participants appliquent le même ajustement [BIP86][] pour que l'agrégation des signatures réussisse. Si une partie tente d'utiliser un
  ajustement différent, tel qu'un ajustement dérivé d'un arbre de scripts caché, sa signature partielle ne pourra pas être agrégée en une
  signature finale valide.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires. Veuillez envisager de mettre à niveau vers
les nouvelles versions ou d'aider à tester les versions candidates._

- [Bitcoin Core 31.0][] est la dernière version majeure de l'implémentation de nœud complet prédominante du réseau. Les [notes de
  version][notes31] décrivent plusieurs améliorations importantes, dont l'implémentation de la conception du [cluster mempool][topic cluster
  mempool], une nouvelle option `-privatebroadcast` pour `sendrawtransaction` (voir le [Bulletin #388][news388 private]), des données `asmap`
  intégrées de manière optionnelle dans le binaire pour la protection contre les [attaques par eclipse][topic eclipse attacks], et une
  augmentation du `-dbcache` par défaut à 1024 Mio sur les systèmes disposant d'au moins 4096 Mio de RAM, parmi de nombreuses autres mises à
  jour.

- [Core Lightning 26.04][] est une version majeure de cette implémentation populaire de nœud LN. Elle active le [splicing][topic splicing]
  par défaut, ajoute de nouvelles commandes `splicein` et `spliceout`, incluant un mode `cross-splice` qui cible un second canal comme
  destination d'un splice-out, repense `bkpr-report` pour les résumés de revenus, ajoute la recherche de chemins en parallèle et plusieurs
  corrections de bogues dans `askrene`, ajoute une option `fronting_nodes` à la RPC `offer` ainsi qu'une configuration
  `payment-fronting-node`, et supprime la prise en charge de l'ancien format onion. Consultez les [notes de version][notes cln] pour
  davantage de détails.

- [LND 0.21.0-beta.rc1][] est la première version candidate de la prochaine version majeure de ce nœud LN populaire. Les utilisateurs
  exploitant des nœuds avec l'option `--db.use-native-sql` sur un backend SQLite ou PostgreSQL doivent noter que cette version migre le
  magasin de paiements du format clé-valeur (KV) vers SQL natif, avec une possibilité de désactivation via `--db.skip-native-sql-migration`.
  Consultez les [notes de version][notes lnd].

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning
BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #33477][] met à jour la manière dont le mode `rollback` de la RPC `dumptxoutset` (voir le [Bulletin #72][news72 dump])
  construit des vidages historiques de l'ensemble UTXO utilisés pour les instantanés [assumeUTXO][topic assumeutxo]. Au lieu de faire
  revenir en arrière le chainstate principal en invalidant des blocs, Bitcoin Core crée une base de données UTXO temporaire, la fait revenir
  à la hauteur demandée, puis écrit l'instantané depuis cette base temporaire. Cela préserve le chainstate principal, éliminant la nécessité
  de suspendre l'activité réseau et le risque d'interférences liées à une bifurcation avec le rollback, au prix d'un espace disque
  temporaire supplémentaire et de vidages plus lents. Une nouvelle option `in_memory` conserve l'intégralité de la base de données UTXO
  temporaire en RAM, permettant des rollbacks plus rapides mais nécessitant plus de 10 Go de mémoire libre sur le réseau principal. Pour des
  rollbacks profonds, il est recommandé de ne pas utiliser de délai d'expiration RPC (`bitcoin-cli -rpcclienttimeout=0`) car cela peut
  prendre plusieurs minutes.

- [Bitcoin Core #35006][] ajoute une option `-rpcid` à `bitcoin-cli` pour définir une chaîne personnalisée comme `id` de requête JSON-RPC au
  lieu de la valeur codée en dur par défaut de `1`. Cela permet de corréler les requêtes et les réponses lorsque plusieurs clients
  effectuent des appels concurrents. L'identifiant est également inclus dans le journal de débogage RPC côté serveur.

- [BIPs #1895][] publie [BIP361][], une proposition abstraite pour la migration [post-quantique][topic quantum resistance] et l'extinction
  progressive des signatures historiques. En supposant qu'un schéma de signature post-quantique (PQ) distinct soit standardisé et déployé,
  elle décrit une migration par étapes s'éloignant des schémas de signature ECDSA/[schnorr][topic schnorr signatures]. La version actuelle
  de la proposition est divisée en deux phases. La phase A interdit l'envoi de fonds vers des adresses vulnérables au quantique, accélérant
  ainsi l'adoption de types d'adresses PQ. La phase B restreint les dépenses ECDSA/schnorr et inclut un protocole de sauvetage résistant au
  quantique pour empêcher le vol d'UTXO vulnérables au quantique.

- [BIPs #2142][] met à jour [BIP352][], la proposition de BIP sur les [silent payments][topic silent payments], en ajoutant un vecteur de
  test d'envoi/réception pour un cas limite où la somme courante des clés d'entrée atteint zéro après deux entrées mais où la somme finale
  sur toutes les entrées n'est pas nulle. Cela détecte les implémentations qui rejettent trop tôt pendant la sommation incrémentale au lieu
  de sommer d'abord toutes les entrées.

- [LDK #4555][] corrige la manière dont les nœuds de transfert appliquent [`max_cltv_expiry`][topic cltv expiry delta] pour les [chemins de
  paiement aveuglés][topic rv routing]. Ce champ est destiné à garantir qu'une route aveuglée expirée soit rejetée au saut d'introduction
  plutôt que d'être transférée à travers le segment aveuglé puis d'échouer plus près du destinataire. Auparavant, LDK comparait la
  contrainte à la valeur CLTV sortante du saut ; il vérifie désormais comme prévu l'expiration CLTV entrante.

- [LND #10713][] ajoute des limites de débit par pair et globales de type token-bucket pour les [messages onion][topic onion messages]
  entrants, abandonnant le trafic excédentaire à l'entrée avant qu'il n'atteigne le gestionnaire onion. Cela renforce la prise en charge
  récemment ajoutée par LND du transfert de messages onion (voir le [Bulletin #396][news396 lnd onion]) contre les abus à fort volume provenant
  de pairs rapides. La séparation entre limite par pair et limite globale reflète les anciennes limites de bande passante du gossip dans LND
  (voir le [Bulletin #370][news370 lnd gossip]).

- [LND #10754][] cesse de transférer un [message onion][topic onion messages] lorsque le prochain saut choisi est le même pair que celui qui
  l'a livré, évitant un rebond immédiat sur la même connexion.

{% include snippets/recap-ad.md when="2026-04-28 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1052,33477,35006,4555,10713,10754,1895,2142" %}
[news46 batch]: /en/newsletters/2019/05/14/#new-script-based-multisig-semantics
[topic hornet update]: https://delvingbitcoin.org/t/hornet-update-a-declarative-executable-specification-of-consensus-rules/2420
[hornet ml post]: https://groups.google.com/g/bitcoindev/c/M7jyQzHr2g4
[topic hornet]: /fr/newsletters/2026/02/06/#une-base-de-donnees-utxo-parallelisee-en-temps-constant
[onion del]: https://delvingbitcoin.org/t/onion-message-jamming-in-the-lightning-network/2414
[mitig2 onion]: https://ualberta.scholaris.ca/items/245a6a68-e1a6-481d-b219-ba8d0e640b5d
[mitig3 onion]: https://diyhpl.us/~bryan/irc/bitcoin/bitcoin-dev/linuxfoundation-pipermail/lightning-dev/2022-February/003498.txt
[mitig4 onion]: https://diyhpl.us/~bryan/irc/bitcoin/bitcoin-dev/linuxfoundation-pipermail/lightning-dev/2022-June/003623.txt
[tor issue]: https://blog.torproject.org/tor-network-ddos-attack/
[Bitcoin Core 31.0]: https://bitcoincore.org/bin/bitcoin-core-31.0/
[notes31]: https://bitcoincore.org/en/releases/31.0/
[news388 private]: /fr/newsletters/2026/01/16/#bitcoin-core-29415
[Core Lightning 26.04]: https://github.com/ElementsProject/lightning/releases/tag/v26.04
[notes cln]: https://github.com/ElementsProject/lightning/releases/tag/v26.04
[LND 0.21.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.21.0-beta.rc1
[notes lnd]: https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/release-notes-0.21.0.md
[news72 dump]: /en/newsletters/2019/11/13/#bitcoin-core-16899
[news396 lnd onion]: /fr/newsletters/2026/03/13/#lnd-10089
[news370 lnd gossip]: /fr/newsletters/2025/09/05/#lnd-10103
