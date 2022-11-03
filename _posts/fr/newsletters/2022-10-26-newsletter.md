---
title: 'Bitcoin Optech Newsletter #223'
permalink: /fr/newsletters/2022/10/26/
name: 2022-10-26-newsletter-fr
slug: 2022-10-26-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
La newsletter de cette semaine résume la suite de discussions sur l'activation
de full RBF, fournit des aperçus de plusieurs transcriptions de discussions
lors d'une réunion CoreDev.tech, et décrit une proposition de sorties d'ancrage
éphémères conçues pour les protocoles de contrat comme LN. Vous trouverez
également nos sections habituelles avec des résumés des principales questions
et réponses du Bitcoin Stack Exchange, une liste des nouvelles versions logicielles
et des release candidate, ainsi que les principaux changements apportés aux
logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Poursuite de la discussion sur le full RBF :** durant [la newsletter
  de la semaine dernière][news222 rbf], nous avons résumé une discussion
  sur la liste de diffusion Bitcoin-Dev concernant l'inclusion d'une
  nouvelle option `mempoolfullrbf` qui pourrait créer des problèmes pour
  plusieurs entreprises qui acceptent des transactions avec zéro confirmation
  ("zero conf") comme paiement final.  La discussion a continué cette semaine
  à la fois sur la liste de diffusion et dans la salle IRC #bitcoin-core-dev.
  Voici quelques points saillants de la discussion :

    - *Problème d'option gratuite :* Sergej Kotliar [averti][kotliar free
      option] qu'il pense que le plus grand problème de tout type de
      remplacement de transaction est qu'il crée un option de style Option
      Américaine gratuite. Par exemple, le client Alice demande à acheter
      des gadgets au marchand Bob. Bob donne à Alice une facture pour
      1 BTC au prix actuel de 20 000 USD/BTC. Alice envoie à Bob les 1 BTC
      dans une transaction avec un faible taux de frais. La transaction
      n'est pas confirmée lorsque le taux de change passe à 25 000 USD/BTC,
      ce qui signifie qu'Alice paie maintenant 5 000 dollars de plus.
      À ce stade, elle choisit très rationnellement de remplacer sa transaction
      par une transaction dans laquelle elle se rembourse les BTC, annulant
      ainsi la transaction. Cependant, si le taux de change avait évolué en
      faveur d'Alice (par exemple 15 000 USD/BTC), Bob ne pourrait pas annuler
      le paiement d'Alice et n'aurait donc aucun moyen, dans le flux normal
      des transactions Bitcoin onchain, de profiter de la même option, créant ainsi
      un risque de change asymétrique. En comparaison, lorsque le remplacement
      de la transaction n'est pas possible, Alice et Bob partagent le même
      risque de taux de change.

        Kotliar note que le problème existe aujourd'hui avec la
        disponibilité de [RBF][topic rbf] du [BIP125][], mais il
        estime que le full-RBF pourrait accentuer le problème.

        Greg Sanders et Jeremy Rubin [notent][sanders cpfp]
        [séparement][rubin cpfp] que le commerçant Bob
        pourrait inciter les mineurs à confirmer la transaction
        originale du client Alice en utilisant [CPFP][topic cpfp],
        particuliérement si [package relay][topic package relay]
        était activé.

        Antoine Riard [note][riard free option] que le même risque
        existe avec LN, car Alice pourrait attendre de payer la facture
        du commerçant Bob jusqu'à peu avant son expiration, ce qui lui
        laisserait le temps d'attendre que le taux de change change.
        Cependant, dans ce cas, si Bob remarque que le taux de change
        a changé de manière significative, il peut demander à son nœud
        de ne pas accepter le paiement et rendre l'argent à Alice.

    - *Bitcoin Core n'est pas en charge du réseau :* Gloria Zhao [a écrit][zhao
      no control] dans la discusion IRC, "Je pense que, quelle que soit l'option
      choisie, il doit être clair pour les utilisateurs que le Core ne contrôle
      pas si le full RBF se produit ou non. Nous pourrions revenir en arrière
      [25353][bitcoin core #25353] et cela pourrait encore arriver. [...]"

        Après la réunion, Zhao a aussi posté une [vue détaillée][zhao
        overview] de la situation.

    - *L'absence de retrait signifie que le problème peut se produire :*
      dans la discussion sur IRC, Anthony Towns [a rappelé][towns uncoordinated]
      ses points de la semaine dernière, "si nous ne supprimons pas l'option
      `mempoolfullrbf` de la 24.0, nous allons vers un déploiement non coordonné."

        Greg Sanders était [circonspect][sanders doubt], "la question est:
        Est-ce que 5 %+s constitueront une variable ? Je ne pense pas."
        Ce à quoi Towns [a répondu][towns uasf]: "[UASF][topic soft fork activation]
        `uacomment` a démontré qu'il était facile d'obtenir ~11% d'une
        variable en seulement  quelques semaines".

    - *Devrait être une option :* Martin Zumsande [a dit][zumsande option]
      dans la discussion IRC, "Je pense que si un nombre significatif
      d'opérateurs de nœuds et de mineurs veulent une politique spécifique,
      cela ne devrait pas être aux devs de leur dire 'vous ne pouvez pas
      avoir cela maintenant'. Les devs peuvent et doivent donner une
      recommandation (en choisissant  l'option par défaut), mais fournir des options
      aux utilisateurs informés ne devraient jamais être un problème."

    Au moment où nous écrivons ces lignes, aucune résolution claire n'a
    été trouvée. L'option `mempoolfullrbf` est toujours incluse dans les
    release candidate de la prochaine version de Bitcoin Core 24.0 et
    Optech recommande que tout service dépendant des transactions zero conf
    évalue soigneusement les risques, en commençant peut-être par lire
    les courriels dont le lien figure à l'adresse suivante
    [de la newsletter de la semaine dernière][news222 rbf].

- **CoreDev.tech transcription :** Avant la conférence Atlanta Bitcoin
  (TabConf), 40 développeurs environ ont participé à un événement
  CoreDev.tech. [Les transcriptions][coredev xs] d'environ la moitié
  des réunions de l'événement ont été fournies par Bryan Bishop.
  Les principales discussions portaient sur :

    - [le chiffrement du transport][p2p encryption]: une conversation sur
      la récente mise à jour de la proposition de [protocole de transport
      chiffré version 2] [topic v2 p2p transport] (voir la [Newsletter #222]
      [news222 bip324]). Ce protocole rendrait plus difficile pour les
      espions du réseau de savoir quelle adresse IP est à l'origine d'une
      transaction et améliorerait la capacité à détecter et à résister aux
      attaques de type "man-in-the-middle" entre des nœuds honnêtes.

        La discussion couvre plusieurs des considérations relatives à la
        conception du protocole et est une lecture recommandée pour tous ceux
        qui se demandent pourquoi les auteurs du protocole ont pris certaines
        décisions. Elle examine également la relation avec le protocole
        d'authentification antérieur [countersign][topic countersign].

    - [les frais][fee chat]: une large discussion sur les frais de transaction
    dans le passé, le présent et l'avenir. Parmi les sujets abordés, citons
    les questions sur la raison pour laquelle les blocs sont apparemment toujours
    presque pleins alors que le mempool ne l'est pas, le débat sur le temps dont
    nous disposons pour qu'un marché de frais significatif se développe avant que
    nous devions [nous inquiéter][topic fee sniping] de la stabilité à long terme
    de Bitcoin, et les solutions que nous pourrions déployer si nous pensions
    qu'un problème existait.

    - [FROST][]: une présentation sur le schéma de signature à seuil FROST.
    La transcription documente plusieurs excellentes questions techniques sur
    les choix cryptographiques dans la conception et peut être une lecture
    utile pour toute personne intéressée à en savoir plus sur FROST en
    particulier ou sur la conception de protocoles cryptographiques en général.
    Voir aussi la transcription de TabConf sur [ROAST][], un autre schéma
    de signature à seuil pour Bitcoin.

    - [GitHub][github chat]: une discussion sur le transfert de l'hébergement git
    du projet Bitcoin Core de GitHub vers une autre solution de gestion des
    problèmes et des relations publiques, ainsi que sur les avantages de continuer
    à utiliser GitHub.

    - [les spécifications prévisibles dans les BIP][hacspec chat]: dans le cadre
    d'une discussion sur l'utilisation du langage de spécification [hacspec][]
    dans les BIPs pour fournir des spécifications qui sont prouvées correctes.
    Voir aussi la [transcript][hacspec preso] pour un exposé connexe pendant
    la TabConf.

    - [les relais de transactions en paquet v3][package relay chat]: la
    transcription d'une présentation sur les propositions visant à activer
    le [relais de transactions en paquet][topic package relay] et à utiliser de
    nouvelles règles de relais de transaction pour éliminer les
    [attaques de pinning][topic transaction pinning] dans certains cas.

    - [Stratum v2][stratum v2 chat]: une discussion qui a commencée avec l'annonce
    d'un nouveau projet open-source mettant en œuvre le protocole de minage groupé
    Stratum version 2. Les améliorations apportées par Stratum v2 comprennent des
    connexions authentifiées et la possibilité pour les mineurs individuels (ceux
    qui disposent d'un équipement minier local) de choisir les transactions à
    exploiter (plutôt que le pool qui choisit les transactions). En plus de nombreux
    autres avantages, il a été mentionné dans la discussion que le fait de permettre
    aux mineurs individuels de choisir leur propre modèle de bloc pourrait devenir
    très souhaitable pour les pools qui s'inquiètent de voir les gouvernements imposer
    les transactions à extraire, comme dans la controverse de [Tornado Cash][]. La
    plupart des discussions se sont concentrées sur les changements qui devraient être
    apportés à Bitcoin Core pour permettre le support natif de Stratum v2. Voir
    également la transcription de la TabConf sur [Braidpool][braidpool chat], un
    protocole de minage en pool décentralisé.

    - [Merging][merging chat] est une discussion sur les stratégies permettant d'obtenir
    une révision du code dans le cadre du projet Bitcoin Core, bien que de nombreuses
    suggestions s'appliquent également à d'autres projets. Idées incluses :

        - Diviser les grands changements en plusieurs petites PR

        - Faire en sorte que les évaluateurs comprennent facilement l'objectif final.
        Pour chaque PR, cela signifie rédiger une description motivante de la PR.
        Pour les changements qui sont effectués de manière incrémentielle, utilisez les
        suivis de problèmes, les tableaux de projet et motivez les remaniements en ouvrant
        également les PR qui utiliseront le code remanié pour atteindre un objectif
        souhaitable.

        - Produire des explications de haut niveau pour des projets de longue haleine
        décrivant l'état antérieur du projet, l'état d'avancement actuel, ce qu'il faudra
        faire pour atteindre le résultat et les avantages qu'en tireront les utilisateurs.

        - Former des groupes de travail avec ceux qui sont intéressés par les mêmes
        projets ou sous-systèmes de codes

- **Ephemeral anchors:** Greg Sanders a poursuivi la discussion précédente
sur le relais des transactions v3 (voir [Newsletter #220][news220 ephemeral])
avec un [article][sanders ephemeral] sur le serveur Bitcoin-Dev contenant une
proposition pour un nouveau type de [anchor output][topic anchor outputs]. Une
transaction v3 pourrait payer zéro frais mais contenir une sortie payant le
script `OP_TRUE`, permettant à quiconque de la dépenser selon les règles du
consensus dans une transaction enfant. La transaction parentale non confirmée
à frais nuls ne serait relayée et exploitée par Bitcoin Core que si elle faisait
partie d'un paquet de transactions contenant également la transaction enfant
dépensant la sortie OP_TRUE.  Cela n'affecterait que la politique de Bitcoin Core;
aucune règle de consensus ne serait modifiée.

    Les avantages décrits dans cette proposition sont qu'elle élimine le besoin
    d'utiliser des timelocks relatifs d'un seul bloc (appelés `1 OP_CSV` d'après
    le code utilisé pour les activer) pour empêcher l'[épinglage de la transaction]
    [topic transaction pinning] et permet à quiconque de faire payer la transaction
    parente (similaire à une proposition antérieure de [parrainage de la transaction]
    [topic fee sponsorship]).

    Jeremy Rubin [a soutenu][rubin ephemeral] a soutenu la proposition mais a noté
    qu'elle ne fonctionne pas pour les contrats qui ne peuvent pas utiliser les
    transactions v3. Plusieurs autres développeurs ont également discuté du concept,
    tous semblent le trouver attrayant au moment de la rédaction de cet article.

## Selection de Q&R du Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est une des principales places pour les
contributeurs d'Optech pour trouver les réponses à leurs questions---ou lorsque nous
avons quelques instants pour aider les utilisateurs curieux ou confus. Dans cette
chronique mensuelle, nous mettons en avant certaines des questions et réponses les
plus postées depuis notre dernière édition.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Pourquoi quelqu'un utiliserait-il un1-of-1 multisig?]({{bse}}115443)
  Vojtěch Strnad demande pourquoi quelqu'un choisirait d'utiliser 1-of-1 multisig
  plutôt que P2WPKH étant donné que P2WPKH est moins cher et a un plus grand ensemble
  d'anonymat. Murch énumère une variété de ressources montrant qu'au moins une entité
  a dépensé des millions de 1-of-1 UTXOs au fil des ans, bien que les motivations
  restent floues.

- [pourquoi une transaction aurait-elle un locktime en 1987?]({{bse}}115549)
  1440000bytes pointe vers un commentaire de Christian Decker faisant référence à
  [une section][bolt 3 commitment] de la spécification Lightning BOLT 3 qui attribue
  le champ locktime comme "les 8 bits supérieurs sont 0x20, les 24 bits inférieurs sont
  les 24 bits inférieurs du numéro de transaction d'engagement masqué".

- [Quelle est la taille limite d'un ensemble d'UTXO, le cas échéant ?]({{bse}}115439)
  Pieter Wuille répond qu'il n'y a pas de limite consensuelle à la taille de l'ensemble
  des UTXO et que le taux de croissance des UTXO est limité par la taille du bloc qui
  limite le nombre d'UTXO qui peuvent être créés dans un bloc donné. Dans une
  [réponse connexe][se murch utxo calcs], Murch estime qu'il faudrait environ 11 ans
  pour créer un UTXO pour chaque personne sur Terre.

- [Pourquoi est-ce que `-blockmaxweight` est réglé à 3996000 par defaut?]({{bse}}115499)
  Vojtěch Strnad souligne que le paramètre par défaut de `-blockmaxweight` dans Bitcoin Core
  est de 3 996 000, ce qui est inférieur à la limite segwit de 4 000 000 d'unités de poids (vbytes).
  Pieter Wuille explique que cette différence permet à un mineur de disposer d'un espace tampon
  pour ajouter une transaction coinbase plus importante avec des sorties supplémentaires au-delà
  de la transaction coinbase par défaut créée par le modèle de bloc.

- [Un mineur peut-il ouvrir un canal Lightning avec une sortie Coinbase ?]({{bse}}115588)
  Murch souligne les difficultés rencontrées par un mineur qui crée un canal Lightning en utilisant
  une sortie de sa transaction coinbase, notamment les retards dans la fermeture du canal compte tenu
  de la période de maturation d'une coinbase, ainsi que la nécessité de renégocier en permanence
  l'ouverture du canal pendant le hachage en raison du hachage de la transaction coinbase qui change
  constamment pendant le minage.

- [Quel est l'historique de la manière dont les soft forks précédents ont été testées avant d'être considérées pour l'activation ?]({{bse}}115434)
  Michael Folkson cite un [récent message de la liste de diffusion] [aj soft fork testing]
  d'Anthony Towns qui décrit les tests autour des propositions P2SH, CLTV, CSV, segwit,
  [taproot] [topic taproot], CTV, et [Drivechain] [topic sidechains].

## Mises à jour et release candidate

*Nouvelles mises à jour et release candidates des principaux logiciels d'infrastructure Bitcoin.
Prévoyez s'il vous plait de vous mettre à jour à la nouvelle version ou d'aider à tester les pré-versions.*

- [LDK 0.0.112][] est une version de cette bibliothèque permettant de construire
  des application basé sur LN

- [Bitcoin Core 24.0 RC2][] est une release candidate pour la prochaine
  version de l'implémentation de nœuds complets la plus largement utilisée
  sur le réseau. Un [guide de test] [bcc testing] est disponible.

  **Attention :** cette release candidate inclut l'option de configuration
  `mempoolfullrbf` qui, selon plusieurs développeurs de protocoles et d'applications,
  pourrait entraîner des problèmes pour les services marchands, comme décrit
  dans les bulletins de cette semaine et de la semaine dernière. Optech encourage
  tous les services qui pourraient être affectés à évaluer la RC et à participer
  à la discussion publique.

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], et [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #23443][] ajoute un nouveau message de protocole P2P,
  `sendtxrcncl` (envoyer la réconciliation des transactions), qui permet
  à un nœud de signaler à un pair qu'il supporte [erlay][topic erlay].
  Ce PR n'ajoute que la première partie du protocole erlay---d'autres parties
  sont nécessaires pour pouvoir l'utiliser.

- [Eclair #2463][] et [#2461][eclair #2461] Mise à jour de l'implémentation
  d'Éclair des [protocoles de financement interactif et double] [topic dual funding]
  pour exiger que chaque entrée de financement opte pour [RBF][topic rbf] et soit
  également confirmée (c'est-à-dire qu'elle dépense une sortie qui est déjà dans la
  chaîne de blocs). Ces changements garantissent que RBF peut être utilisé et
  qu'aucun des frais apportés par un utilisateur d'Eclair ne sera utilisé pour
  aider à confirmer les transactions précédentes de son pair.

{% include references.md %}
{% include linkers/issues.md v=2 issues="23443,2463,2461,25353" %}
[bitcoin core 24.0 rc2]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[ldk 0.0.112]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.112
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/24.0-Release-Candidate-Testing-Guide
[news222 rbf]: /fr/newsletters/2022/10/19/#option-de-remplacement-de-transaction
[kotliar free option]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021056.html
[sanders cpfp]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021060.html
[rubin cpfp]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021059.html
[riard free option]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021067.html
[zhao no control]: https://www.erisian.com.au/bitcoin-core-dev/log-2022-10-20.html#l-440
[towns uncoordinated]: https://www.erisian.com.au/bitcoin-core-dev/log-2022-10-20.html#l-488
[sanders doubt]: https://www.erisian.com.au/bitcoin-core-dev/log-2022-10-20.html#l-490
[towns uasf]: https://www.erisian.com.au/bitcoin-core-dev/log-2022-10-20.html#l-492
[zumsande option]: https://www.erisian.com.au/bitcoin-core-dev/log-2022-10-20.html#l-493
[coredev xs]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/
[p2p encryption]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-10-p2p-encryption/
[news222 bip324]: /fr/newsletters/2022/10/19/#mise-a-jour-bip324
[fee chat]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-11-fee-market/
[frost]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-11-frost/
[roast]: https://diyhpl.us/wiki/transcripts/tabconf/2022/roast/
[github chat]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-11-github/
[hacspec chat]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-11-hac-spec/
[hacspec]: https://hacspec.github.io/
[hacspec preso]: https://diyhpl.us/wiki/transcripts/tabconf/2022/hac-spec/
[package relay chat]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-11-package-relay/
[stratum v2 chat]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-11-stratum-v2/
[tornado cash]: https://www.coincenter.org/analysis-what-is-and-what-is-not-a-sanctionable-entity-in-the-tornado-cash-case/
[braidpool chat]: https://diyhpl.us/wiki/transcripts/tabconf/2022/braidpool/
[merging chat]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-12-merging/
[news220 ephemeral]: /fr/newsletters/2022/10/05/#ephemeral-dust
[sanders ephemeral]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021036.html
[rubin ephemeral]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021041.html
[zhao overview]: https://github.com/glozow/bitcoin-notes/blob/full-rbf/full-rbf.md
[bolt 3 commitment]: https://github.com/lightning/bolts/blob/316882fcc5c8b4cf9d798dfc73049075aa89d3e9/03-transactions.md#commitment-transaction
[se murch utxo calcs]: https://bitcoin.stackexchange.com/questions/111234/how-many-useable-utxos-are-possible-with-btc-inside-them/115451#115451
[aj soft fork testing]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/020964.html
