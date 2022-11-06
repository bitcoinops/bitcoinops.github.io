---
title: 'Bitcoin Optech Newsletter #224'
permalink: /fr/newsletters/2022/11/02/
name: 2022-11-02-newsletter-fr
slug: 2022-11-02-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin d'information de cette semaine décrit la suite de la discussion
sur l'autorisation facultative aux nœuds d'activer le Full RBF, relaie une
demande de commentaires sur un élément de conception du protocole de transport
chiffré BIP324 version 2, résume une proposition pour attribuer de manière
fiable les défaillances et les retards LN à des nœuds particuliers, et des
liens vers une discussion sur une alternative à l'utilisation des sorties
d'ancrage pour les HTLC LN modernes. Sont également incluses nos sections
régulières avec ne liste des nouvelles versions logicielles et des release
candidate, ainsi que les principaux changements apportés aux logiciels
d'infrastructure Bitcoin.

## Nouvelles

- **Cohérence Mempool :** Anthony Towns a lancé une [discussion][towns
  consistency] ur la liste de diffusion Bitcoin-Dev sur les conséquences
  de la simplification de la configuration des politiques de Bitcoin Core
  pour le relais de transaction et l'acceptation de mempool, comme cela a
  été fait par l'ajout de l'option `mempoolfullrbf` à la branche de
  développement de Bitcoin Core (voir Newsletters [#205][news205 rbf],
  [#208][news208 rbf], [#222][news222 rbf], and [#223][news223 rbf]).
  Il affirme que "cela diffère de ce que le noyau a fait dans le passé,
  en ce sens qu'auparavant, nous avons essayé de nous assurer qu'une nouvelle
  politique est bonne pour tout le monde (ou aussi près que possible), puis
  l'avons activée dès qu'elle est mise en œuvre. Toutes les options qui ont été
  ajoutées ont été soit pour contrôler l'utilisation des ressources de manière
  à ne pas [affecter] de manière significative la propagation des tx, pour
  permettre aux gens de revenir à l'ancien comportement lorsque le nouveau
  comportement est controversé (par exemple, l'option -mempoolreplacement=0 de
  0.12 à 0.18), et pour faciliter le test/débogage de l'implémentation. Donner
  aux gens un nouveau comportement de relais auquel ils peuvent s'inscrire
  lorsque nous ne sommes pas suffisamment confiants pour l'activer par défaut
  ne correspond pas à l'approche que j'ai vue adopter par le passé.»

    Towns se demande alors s'il s'agit d'une nouvelle direction de développement :
    "full [RBF][topic RBF] est controversé depuis des lustres,
    mais largement apprécié par les développeurs [...] alors peut-être que c'est
    juste un cas particulier et non un précédent, et quand les gens proposent
    d'autres fausses options par défaut,il y aura beaucoup plus de résistance
    à leur fusion, malgré toutes les discussions sur les utilisateurs ayant
    des options qui se passent en ce moment. Mais, en supposant qu'il s'agit
    d'une nouvelle direction, il évalue certaines conséquences potentielles
    de cette décision:

    - *Il devrait être plus facile de fusionner les options de relais alternatives désactivées par défaut :*
      si le fait de donner plus d'options aux utilisateurs est considéré comme
      préférable, de nombreux aspects de la stratégie de relais peuvent être
      configurés. Par exemple, Bitcoin Knots fournit une option de script de
      réutilisation de la pubkey (`spkreuse`) pour configurer un nœud afin qu'il
      refuse de relayer toute transaction qui [réutilise une adresse]
      [topic output linking].

    - *Des politiques plus permissives nécessitent une acceptation généralisée ou un meilleur appairage :*
      un nœud Bitcoin Core par défaut relaie les transactions avec huit pairs
      via des connexions sortantes, de sorte qu'au moins 30% du réseau doit
      prendre en charge une politique plus permissive avant qu'un nœud ait 95%
      de chances de trouver au moins un pair sélectionné au hasard qui prend en
      charge la même politique. Moins il y a de nœuds prenant en charge une
      politique, moins il est probable qu'un nœud trouve un homologue prenant en
      charge cette politique.

    - *Un meilleur apparairage implique des compromis :* les nœuds Bitcoin peuvent
      annoncer leurs capacités en utilisant le champ de services des messages P2P
      `addr`, [`addrv2`][topic addr v2], et messages de `version`, permettant aux
      nœuds ayant des intérêts communs de se trouver et de former des sous-réseaux
      (appelés *preferential peering*). Alternativement, les opérateurs de nœuds
      complets ayant des intérêts communs peuvent utiliser d'autres logiciels pour
      former des réseaux de relais indépendants (tels qu'un réseau entre nœuds LN).
      Cela peut rendre le relais efficace même lorsque seuls quelques nœuds mettent
      en œuvre une politique, mais les nœuds mettant en œuvre une politique rare
      sont plus faciles à identifier et à censurer. Cela oblige également les
      mineurs à rejoindre ces sous-réseaux et réseaux alternatifs, ce qui augmente
      la complexité et le coût de l'exploitation minière. Cela augmente la pression
      pour centraliser la sélection des transactions, ce qui facilite également
      la censure.

        De plus, les nœuds mettant en œuvre des politiques différentes de certains
        de leurs pairs ne pourront pas tirer pleinement parti des technologies
        telles que [le relais de bloc compact][topic compact block relay] et
        [erlay][topic erlay] pour minimiser la latence et la bande passante
        lorsque deux pairs disposent déjà de certaines des mêmes informations.

    Le message de Towns a reçu de multiples réponses perspicaces, avec une
    discussion en cours au moment de la rédaction de cet article. Nous fournirons
    une mise à jour dans la newsletter de la semaine prochaine.

- **Identifiants de message BIP324 :** Pieter Wuille [a posté][wuille bip324]
  sur la liste de diffusion Bitcoin-Dev une réponse à la mise à jour du projet
  de spécification [BIP324][bips #1378] pour la  [version 2 du protocole de
  transport chiffré P2P][topic v2 p2p transport] (v2 transport). Pour économiser
  la bande passante, le transport v2 permet de remplacer les noms de message de
  12 octets du protocole existant par des identifiants aussi courts que 1 octet.
  Par exemple, le nom du message `version` , qui est rempli sur 12 octets, peut être
  remplacé par 0x00. Cependant, des noms de message plus courts augmentent le risque
  de conflit entre différentes propositions futures d'ajout de messages au réseau.
  Wuille décrit les compromis entre quatre approches différentes de ce problème et
  demande des avis sur le sujet à la communauté.

- **Attribution de l'échec du routage LN:** les tentatives de paiement LN peuvent
  se solder par un échec pour diverses raisons, du destinataire final refusant de
  libérer la préimage de paiement à l'un des nœuds de routage temporairement hors
  ligne. Les informations sur les nœuds qui ont provoqués l'échec d'un paiement
  seraient extrêmement utiles aux participants pour éviter ces nœuds pour des
  paiements à venir, mais le protocole LN ne fournit aujourd'hui aucune méthode
  authentifiée pour acheminer les nœuds afin de communiquer ces informations à un
  participant.

    Il y a plusieurs années, Joost Jager a proposé une solution (voir [Newsletter
    #51][news51 attrib]), qu'il a maintenant  [mis à jour][jager attrib] avec
    des améliorations et des détails supplémentaires. Le mécanisme assurerait
    l'identification de la paire de nœuds entre lesquels un paiement a échoué
    (ou entre lesquels un message d'échec antérieur a été censuré ou est devenu
    tronqué). Le principal inconvénient de la proposition de Jager est qu'elle
    augmenterait considérablement la taille des messages en oignon LN pour les
    échecs si les autres propriétés LN restaient les mêmes, bien que la taille
    des messages en oignon pour les échecs n'ait pas besoin d'être aussi grande
    si le nombre maximal de saut LN a été diminué.

    Alternativement, Rusty Russell [a suggéré][russell attrib] qu'un participant
    pourrait utiliser un mécanisme similaire aux [paiements spontanés]
    [topic spontaneous payments] où chaque nœud de routage est payé un sat même
    si le paiement final échoue. Le participant pourrait alors identifier à quel
    saut le paiement a échoué en comparant le nombre de satoshis qu'il a envoyé
    au nombre de satoshis qu'il a reçus en retour.

- **Solution de contournement des sorties d'ancrage :** Bastien Teinturier
  [a publié][teinturier fees] sur la liste de diffusion Lightning-Dev une
  [proposition][bolts #1036] d'utilisation des [sorties d'ancrage][topic anchor outputs]
  avec plusieurs versions pré-signées de chaque [HTLC][topic htlc] à différents taux de frais.
  Les sorties d'ancrage ont été introduites avec le développement de la règle
  d'[exclusion CPFP][topic cpfp carve out] permettant d'ajouter des frais à une
  transaction via le mécanisme du [CPFP][topic cpfp] d'une manière qui ne serait pas
  [épinglable][topic transaction pinning] pour le protocole de contrat bipartite de LN.
  However, Teinturier [notes][bolts #845] que l'utilisation de CPFP nécessite que
  chaque nœud LN conserve un pool d'UTXO non-LN prêts à être dépensés à tout moment.
  En comparaison, présigner plusieurs versions de HTLC, chacune avec des frais
  différents, permet de payer ces frais directement à partir de la valeur du HTLC
  --aucune gestion UTXO supplémentaire n'est requise, sauf dans les cas où aucun
  des frais présignés n'était suffisamment élevé.

    Il recherche le soutien d'autres développeurs LN pour l'idée de fournir
    plusieurs HTLC payants. Toutes les discussions à ce jour ont eu lieu sur sa
    propre [PR][bolts #1036].

## Mises à jour et release candidate

*Nouvelles versions et release candidate pour les principaux projets d'infrastructure Bitcoin.
Veuillez envisager de passer aux nouvelles versions ou d'aider à tester les release candidate.*

- [LND 0.15.4-beta][] et [0.14.4-beta][lnd 0.14.4-beta] sont **des versions
  critiques pour la sécurité** releases contenant un correctif de bogue pour un
  problème de traitement des blocs récents.
  Tous les utilisateurs doivent mettre à niveau.

- [Bitcoin Core 24.0 RC2][] est une release candidate pour la
  prochaine version de l'implémentation de nœud complet la plus
  largement utilisée du réseau. Un [guide de test][bcc testing] est disponible.

  **Avertissement :** cette release candidate inclut l'option `mempoolfullrbf`
  de configuration qui, selon plusieurs développeurs de protocoles et
  d'applications, pourrait entraîner des problèmes pour les services marchands,
  comme décrit dans les newsletters[#222][news222 rbf] et [#223][news223 rbf].
  Optech encourage tous les services qui pourraient être affectés à évaluer
  la RC et à participer au débat public.

## Changements principaux dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], et [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #23927][] limite `getblockfrompeer` sur les noeuds partiels
  à des hauteurs inférieures à la progression de la synchronisation actuelle
  du nœud. Cela empêche de se tirer une balle dans le pied résultant de la
  récupération de futurs blocs rendant les fichiers de blocs du nœud inéligibles
  à l'élagage.

  Bitcoin Core stocke les blocs dans des fichiers d'environ 130 Mo, quel que soit
  l'ordre dans lequel il les reçoit. L'élagage supprimera les fichiers de blocs
  entiers, mais ne supprimera aucun fichier contenant un bloc non traité par la
  synchronisation. La combinaison d'une petite allocation de données et d'une
  utilisation répétée du RPC `getblockfrompeer` pourrait rendre plusieurs fichiers
  de blocs inéligibles à l'élagage et faire en sorte qu'un nœud élagué dépasse son
  allocation de données.

- [Bitcoin Core #25957][] améliore les performances des réanalyses pour les
  portefeuilles de descripteurs en utilisant l'[index de filtre de bloc]
  [topic compact block filters] (s'il est activé) pour ignorer les blocs qui ne
  dépensent pas ou ne créent pas d'UTXO pertinents pour le portefeuille.

- [Bitcoin Core #23578][] utilise [HWI][topic hwi] et a récemment fusionné la
  prise en charge du [BIP371][] (voir la [Newsletter #207][news207 bc22558])
  pour permettre la prise en charge de la signature externe pour les dépenses
  de chemin de clé [taproot][topic taproot].

- [Core Lightning #5646][] met à jour la mise en œuvre expérimentale des
  [offres][topic offers] pour supprimer [les clés publiques x-only][news72 xonly]
  (au lieu d'utiliser des [clés publiques compressées][], qui contiennent un octet
  supplémentaire). Il implémente également la transmission des [blinded payments][],
  un autre protocole expérimental. La description du PR avertit qu'elle "n'inclut
  pas la génération et le paiement de factures avec des paiements en aveugle".

- [LND #6517][] ajoute un nouveau RPC et un nouvel événement qui permettent à un
  utilisateur de surveiller le moment où un paiement entrant ([HTLC][topic htlc])
  est entièrement verrouillé par la transaction d'engagement mise à jour pour
  refléter la nouvelle distribution du solde du canal.

- [LND #7001][] ajoute de nouveaux champs à l'historique de transfert un RPC
  (`fwdinghistory`) indiquant quel partenaire de distribution nous a transféré un
  paiement (HTLC) et le partenaire à qui nous avons relayé le paiement.

- [LND #6831][] met à jour l'implémentation de l'intercepteur HTLC (voir la
  [Newsletter #104][news104 intercept]) pour rejeter automatiquement un paiement
  entrant (HTLC) si le client connecté à l'intercepteur n'a pas fini de le traiter
  dans un délai raisonnable. Si un HTLC n'est pas accepté ou rejeté avant son
  expiration, le partenaire de distribution devra forcer la fermeture du canal
  pour protéger ses fonds. La fusion de ce PR de rejet automatique avant
  expiration garantit que le canal reste ouvert. Le participant peut toujours
  essayer d'envoyer à nouveau le paiement.

<!-- The commit below appears to be a direct push to LND's master branch -->
- [LND 609cc8b][] ajoute une [politique de sécurité][lnd secpol], y compris
  des instructions pour signaler les vulnérabilités.

- [Rust Bitcoin #957][] ajoute une API pour signer les [PSBTs][topic psbt].
  Il ne prend pas encore en charge la signature des dépenses [taproot][topic taproot].

- [BDK #779][] ajoute la prise en charge du [meulage low-r][topic low-r grinding]
  des signautres ECDSA, ce qui permet de réduire la taille d'environ la moitié de
  toutes les signatures d'un octet.

{% include references.md %}
{% include linkers/issues.md v=2 issues="23927,25957,5646,6517,7001,6831,957,779,1036,845,1378,23578,22558" %}
[bitcoin core 24.0 rc2]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/24.0-Release-Candidate-Testing-Guide
[lnd 609cc8b]: https://github.com/LightningNetwork/lnd/commit/609cc8b883c7e6186e447e8d7e6349688d78d4fd
[lnd secpol]: https://github.com/lightningnetwork/lnd/security/policy
[towns consistency]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021116.html
[news205 rbf]: /en/newsletters/2022/06/22/#full-replace-by-fee
[news208 rbf]: /en/newsletters/2022/07/13/#bitcoin-core-25353
[news222 rbf]: /fr/newsletters/2022/10/19/#option-de-remplacement-de-transaction
[news223 rbf]: /fr/newsletters/2022/10/26/#poursuite-de-la-discussion-sur-le-full-rbf
[wuille bip324]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021115.html
[news72 xonly]: /en/newsletters/2019/11/13/#x-only-pubkeys
[clés publiques compressées]: https://developer.bitcoin.org/devguide/wallets.html#public-key-formats
[blinded payments]: /en/topics/rendez-vous-routing/
[news104 intercept]: /en/newsletters/2020/07/01/#lnd-4018
[news51 attrib]: /en/newsletters/2019/06/19/#authenticating-messages-about-ln-delays
[jager attrib]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-October/003723.html
[russell attrib]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-October/003727.html
[teinturier fees]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-October/003729.html
[news222 rbf]: /fr/newsletters/2022/10/19/#option-de-remplacement-de-transaction
[news223 rbf]: /fr/newsletters/2022/10/26/#poursuite-de-la-discussion-sur-le-full-rbf
[lnd 0.15.4-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.4-beta
[lnd 0.14.4-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.14.5-beta
[news207 bc22558]: /en/newsletters/2022/07/06/#bitcoin-core-22558
