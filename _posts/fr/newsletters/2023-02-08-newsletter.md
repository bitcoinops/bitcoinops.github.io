---
title: 'Bulletin Hebdomadaire Bitcoin Optech #237'
permalink: /fr/newsletters/2023/02/08/
name: 2023-02-08-newsletter-fr
slug: 2023-02-08-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume une discussion sur le stockage des
données dans les témoins de transaction et fait référence à une conversation
sur l'atténuation du brouillage LN. Vous trouverez également nos sections
habituelles avec le résumé d'une réunion du Bitcoin Core PR Review Club et
des descriptions de changements notables apportés aux principaux logiciels
d'infrastructure Bitcoin.

## Nouvelles

- **Discussion sur le stockage des données dans la chaîne de blocs :** Les
  utilisateurs d'un nouveau projet ont récemment commencé à stocker de grandes
  quantités de données dans les données des témoins pour les transactions
  contenant des entrées segwit v1 ([taproot][topic taproot]). Robert Dickinson
  a [posté][dickinson ordinal] sur la liste de diffusion Bitcoin-Dev pour
  demander si une limite de taille devrait être imposée pour décourager
  un tel stockage de données.

  Andrew Poelstra [a répondu][poelstra ordinal] qu'il n'existe aucun moyen
  efficace d'empêcher le stockage de données. L'ajout de nouvelles restrictions
  pour empêcher le stockage de données non désirées dans les témoins saperait
  les avantages discutés lors de la conception de taproot (voir [bulletin
  #65][news65 tapscript]) et n'aboutirait probablement qu'à un stockage des
  données par d'autres moyens. Ces autres moyens pourraient augmenter les
  coûts pour ceux qui génèrent les données---mais probablement pas suffisamment
  pour décourager le comportement de manière significative---et les méthodes
  de stockage alternatives pourraient créer de nouveaux problèmes pour les
  utilisateurs traditionnels de Bitcoin.

  Au moment où nous écrivons ces lignes, le sujet fait l'objet d'un débat animé.
  Nous ferons le point dans le bulletin de la semaine prochaine.

- **Résumé de l'appel concernant l'atténuation du brouillage LN :** Carla
  Kirk-Cohen et Clara Shikhelman ont [posté][ckccs jamming] sur la liste de
  diffusion Lightning-Dev un résumé d'une récente conversation vidéo sur les
  tentatives de traitement des [attaques par brouillage de canal][topic channel
  jamming attacks]. Parmi les sujets abordés, citons les compromis entre les
  mécanismes de mise à niveau, une proposition simple de frais initiaux tirée
  d'un article récent (voir [bulletin n°226][news226 jam]), le logiciel
  CircuitBreaker (voir [bulletin n°230][news230 jam]), une mise à jour sur
  les références de réputation (voir [bulletin n°228][news228 jam]) et les
  travaux connexes du groupe de travail sur les spécifications du fournisseur
  de services Lightning (LSP). Consultez le message de la liste de diffusion
  pour obtenir des résumés détaillés et une [transcription][jam xs].

  Les prochaines réunions vidéo sont prévues toutes les deux semaines ;
  surveillez la liste de diffusion Lightning-Dev pour connaître les annonces
  des prochaines réunions.

## Bitcoin Core PR Review Club

*Dans cette section mensuelle, nous résumons une récente réunion du
[Bitcoin Core PR Review Club][] en soulignant certaines des questions
et réponses importantes. Cliquez sur une question ci-dessous pour voir
un résumé de la réponse de la réunion.*

[Suivre les totaux AddrMan par réseau et par table, améliorer la précision
de l'ajout de graines fixes][review club 26847] est un PR de Martin Zumsande,
co-écrit par Amiti Uttarwar, qui permet au client Bitcoin Core de trouver
de manière plus fiable les pairs sortants dans certaines situations.
Il le fait en améliorant `AddrMan`.
(le gestionnaire d'adresses des pairs) pour suivre le nombre d'entrées
d'adresses séparément par réseau et par type "essayé" ou "nouveau", ce
qui permet une meilleure utilisation des graines fixes. Il s'agit de la
première étape d'un effort plus vaste visant à améliorer la sélection
des pairs sortants.

{% include functions/details-list.md
  q0="Quand un réseau est-il considéré comme atteignable ?"
  a0="Un réseau est supposé être accessible à moins que nous soyons
      sûrs de ne pas pouvoir y accéder, ou que notre configuration ait
      spécifié un ou plusieurs _autres_ réseaux en utilisant l'option
      de configuration `-onlynet=` (alors seuls ceux-ci sont considérés
      comme accessibles, même si d'autres types de réseaux sont
      réellement disponibles)."
  a0link="https://bitcoincore.reviews/26847#l-22"

  q1="Comment une adresse reçue sur le réseau P2P est traitée selon que le
      réseau de l'adresse est atteignable ou non -- la stocke-t-on (l'ajoute-t-on
      à `AddrMan`) et/ou la transmet-on aux pairs ?"
  a1="Si son réseau est accessible, nous relayons l'adresse à deux pairs
      choisis au hasard, sinon nous la relayons à 1 ou 2 pairs (que 1 ou 2
      soient choisis au hasard). Nous ne stockons l'adresse que si son
      réseau est joignable."
  a1link="https://bitcoincore.reviews/26847#l-51"

  q2="Comment un noeud peut-il actuellement être coincé avec seulement des
      adresses inaccessibles dans `AddrMan`, ne trouvant aucun pair sortant ?
      Comment ce PR le résout-il ?"
  a2="Si la configuration `-onlynet` change. Par exemple, supposons que le
      noeud a toujours été exécuté avec `-onlynet=onion`, donc son `AddrMan`
      n'a pas d'adresses I2P. Le noeud redémarra alors avec `-onlynet=i2p`.
      Les graines fixes ont quelques adresses I2P, mais sans le PR, le noeud
      ne les utilisera pas puisque le `AddrMan` n'est pas _complètement_ vide
      (il conserve quelques adresses onion). Avec le PR, le code de démarrage
      ajoutera des graines fixes I2P, puisque `AddrMan` ne contient aucune
      adresse de _ce_ type de réseau (maintenant atteignable)."
  a2link="https://bitcoincore.reviews/26847#l-98"

  q3="Lorsqu'une adresse que l'on souhaite ajouter à `AddrMan` entre en
      collision avec une adresse existante, que se passe-t-il ? L'adresse
      existante est-elle toujours abandonnée au profit de la nouvelle adresse ?"
  a3="Non, en général, l'adresse existante est conservée (et non la nouvelle),
      à moins que l'adresse existante soit considérée comme 'terrible'
      (voir `AddrInfo::IsTerrible()`)."
  a3link="https://bitcoincore.reviews/26847#l-100"

  q4="Pourquoi serait-il utile d'avoir une connexion sortante vers chaque
      réseau accessible à tout moment ?"
  a4="Une raison égoïste est qu'il est plus difficile de faire une [attaque
      par éclipse][topic eclipse attacks] du noeud, puisque l'attaquant
      aurait besoin de faire fonctionner des noeuds sur plusieurs réseaux.
      Une raison non égoïste est que cela aide à garder ensemble le réseau
      global, en évitant les divisions de chaîne causées par les partitions
      de réseau. Si la moitié des noeuds, y compris les mineurs,
      fonctionnent avec `-onlynet=x` et l'autre moitié, y compris les
      mineurs, fonctionnent `-onlynet=y`, alors deux chaînes pourraient
      émerger. Même sans le PR, un opérateur de noeud peut ajouter
      manuellement une connexion pour chaque type de réseau disponible en
      utilisant l'option de configuration `-addnode` ou le RPC `addnode`."
  a4link="https://bitcoincore.reviews/26847#l-114"

  q5="Pourquoi la logique actuelle de `ThreadOpenConnections()`, même
      avec le PR, est-elle insuffisante pour garantir que le nœud dispose
      à tout moment d'une connexion sortante vers chaque réseau joignable ?"
  a5="Rien dans le PR ne _garantit_ une distribution particulière des pairs
      parmi les réseaux joignables. Par exemple, si nous avons 10k adresses
      clearnet et seulement 50 adresses I2P dans `AddrMan`, il est très
      probable que tous nos pairs seront clearnet (IPv4 ou IPv6)."
  a5link="https://bitcoincore.reviews/26847#l-123"

  q6="Quelles seraient les prochaines étapes pour atteindre cet objectif
      (voir la question précédente) après cette PR ?"
  a6="Les prochaines étapes prévues consistent à ajouter une logique au
      processus de création de connexions pour tenter d'avoir au moins
      une connexion à chaque réseau accessible. Ce PR y prépare."
  a6link="https://bitcoincore.reviews/26847#l-144"
%}

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], et [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #25880][] rend le délai de décrochage adaptatif pendant
  la synchronisation initiale. Bitcoin Core demande des blocs à plusieurs
  pairs en parallèle. Si un pair est significativement plus lent que les
  autres au point que le nœud reste bloqué dans l'attente du bloc suivant,
  nous déconnectons le pair en difficulté après un délai d'attente. Dans
  certaines situations, cela peut amener un nœud avec une connexion à
  faible bande passante à déconnecter plusieurs pairs d'affilée lorsqu'un
  bloc lourd ne peut être transféré dans le délai imparti. Ce changement
  de code modifie le comportement des nœuds pour adapter dynamiquement
  le délai d'attente : le délai d'attente est incrémenté pour chaque pair
  déconnecté tant qu'aucun bloc n'est reçu, et après que les blocs
  commencent à arriver, le délai d'attente est réduit bloc par bloc.

- [Core Lightning #5679][] fournit un plugin pour exécuter des requêtes
  SQL sur les commandes de liste de CLN. Ce correctif gère également les
  dépréciations de manière plus gracieuse, car il peut ignorer tout ce
  qui a été déprécié avant sa publication, comme cela a été introduit
  dans [Core Lightning #5867][].

- [Core Lightning #5821][] ajoute les RPCs `preapproveinvoice`
  (préapprobation de la facture) et `preapprovekeysend` (préapprobation
  de keysend) qui permettent à l'appelant d'envoyer une facture [BOLT11][]
  ou des détails de paiement [keysend][topic spontaneous payments] au
  module de signature de Core Lightning (`hsmd`) pour vérifier que le
  module est prêt à signer le paiement. Pour certaines applications,
  comme celles où la somme d'argent qui peut être dépensée est limitée,
  demander une approbation préalable pourrait produire moins de problèmes
  que de simplement tenter le paiement et de gérer l'échec.

- [Core Lightning #5849][] apporte des modifications au backend qui
  permettent à un nœud de gérer plus de 100 000 pairs, chacun avec un
  canal. Bien qu'il soit peu probable qu'un tel nœud soit utilisé en
  production dans un avenir proche---il faudrait plus d'une douzaine
  de blocs entiers pour ouvrir autant de canaux---le fait de tester le
  comportement a permis au développeur d'apporter plusieurs améliorations
  de performances.

- [Core Lightning #5892][] met à jour l'implémentation du protocole
  [offres][topic offers] de CLN sur la base de tests de compatibilité
  effectués par un développeur travaillant sur l'implémentation d'Eclair.

- [Eclair #2565][] demande maintenant que les fonds d'un canal fermé soient
  envoyés à une nouvelle adresse onchain, plutôt qu'à une adresse qui a été
  générée lorsque le canal a été financé. Cela peut diminuer le [lien de
  sortie][topic output linking], ce qui contribue à améliorer la
  confidentialité des utilisateurs. Une exception à cette politique est
  lorsque l'utilisateur active l'option de protocole LN `upfront-shutdown-script`,
  qui est une demande envoyée au partenaire du canal au moment du financement
  pour utiliser uniquement l'adresse de fermeture spécifiée à ce moment
  (voir [Bulletin #158][news158 upfront] pour plus de détails).

- [LND #7252][] ajoute le support pour l'utilisation de SQLite comme base
  de données de LND. Ceci n'est actuellement supporté que pour les nouvelles
  installations de LND car il n'y a pas de code pour migrer une base de
  données existante.

- [LND #6527][] ajoute la possibilité de chiffrer la clé TLS du serveur sur
  le disque. LND utilise TLS pour authentifier les connexions distantes à son
  canal de contrôle, c'est-à-dire pour exécuter les API. La clé TLS sera
  chiffrée en utilisant les données du portefeuille du nœud, donc le
  déverrouillage du portefeuille déverrouillera la clé TLS. Le déverrouillage
  du porte-monnaie est déjà nécessaire pour envoyer et accepter des paiements.

{% include references.md %}
{% include linkers/issues.md v=2 issues="25880,5679,5867,5821,5849,5892,2565,7252,6527" %}
[news158 upfront]: /en/newsletters/2021/07/21/#eclair-1846
[dickinson ordinal]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-January/021370.html
[poelstra ordinal]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-January/021372.html
[news65 tapscript]: /en/newsletters/2019/09/25/#tapscript-resource-limits
[ckccs jamming]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-January/003834.html
[news226 jam]: /fr/newsletters/2022/11/16/#document-sur-les-attaques-par-brouillage-de-canaux
[news230 jam]: /fr/newsletters/2022/12/14/#brouillage-local-pour-eviter-le-brouillage-a-distance
[news228 jam]: /fr/newsletters/2022/11/30/#proposition-de-references-de-reputation-pour-attenuer-les-attaques-de-brouillage-ln
[jam xs]: https://github.com/ClaraShk/LNJamming/blob/main/meeting-transcripts/23-01-23-transcript.md
[review club 26847]: https://bitcoincore.reviews/26847
