---
title: 'Bulletin Hebdomadaire Bitcoin Optech #414'
permalink: /fr/newsletters/2026/07/17/
name: 2026-07-17-newsletter-fr
slug: 2026-07-17-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit un nouveau projet visant à appliquer la vérification formelle au protocole Bitcoin. Sont également
incluses nos sections régulières annonçant de nouvelles versions et versions candidates, et décrivant les changements notables apportés aux
logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

- **Vérification formelle du protocole Bitcoin** : Keagan McClelland a [posté][verif ml] sur la liste de diffusion Bitcoin-Dev et sur
  [Delving Bitcoin][verif del] à propos de son effort visant à vérifier formellement le protocole Bitcoin. La vérification formelle est une
  pratique de développement logiciel qui vise à prouver la correction d'un système par rapport à une spécification en utilisant les méthodes
  formelles des mathématiques. Cela pourrait aider à résoudre les désaccords factuels concernant les changements proposés aux règles de
  consensus de Bitcoin. Optech a précédemment couvert un projet connexe développant une spécification déclarative exécutable des règles de
  consensus de Bitcoin (voir le [Bulletin #402][news402 hornet]).

  McClelland développe [btc-verified][verif gh], une implémentation en [Lean4][lean lang] du processus de vérification. L'auteur a fourni
  des résultats initiaux démontrant l'approche. En particulier, il s'est concentré sur l'algorithme que Bitcoin utilise pour calculer la
  racine de Merkle, qui contient un défaut connu ([CVE-2012-2459][topic cves]) pouvant amener deux listes de transactions différentes à
  produire la même [racine de Merkle][topic merkle tree vulnerabilities]. La construction de la racine de Merkle dans Bitcoin Core inclut
  une vérification destinée à détecter cette mutation. McClelland a utilisé btc-verified pour prouver formellement que cette vérification
  est correcte et qu'aucune paire de listes de transactions distinctes ne peut la satisfaire tout en produisant la même racine de Merkle,
  sous l'hypothèse que SHA256 résiste aux collisions.

  Enfin, l'auteur a demandé des retours d'autres personnes à la fois sur le dépôt et sur l'approche générale. Il a également fourni quelques
  avertissements, comme l'utilisation importante de l'IA dans le dépôt et l'immaturité actuelle du projet.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires. Veuillez envisager de mettre à niveau vers
les nouvelles versions ou d'aider à tester les versions candidates._

- [Bitcoin Core 30.3][] est une version de maintenance de l'implémentation de nœud complet prédominante. Elle corrige un problème de base de
  données chainstate qui pouvait provoquer des lectures et écritures disque excessives durant le fonctionnement normal, ainsi que des
  corrections pour le portefeuille, les [PSBT][topic psbt], [miniscript][topic miniscript], le réseau, la compilation, les tests et la
  documentation. Consultez les [notes de version][bcc30.3 rn] pour les détails.

- [Bitcoin Core 29.4][] est une version de maintenance de l'implémentation de nœud complet prédominante. Elle corrige le même problème de
  réécriture de la base de données chainstate que 30.3 et inclut certaines corrections de validation, portefeuille, compilation, tests,
  documentation, CI et compatibilité. Consultez les [notes de version][bcc29.4 rn] pour les détails.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning
BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #35295][] accélère la validation des blocs en récupérant en parallèle les coins dépensés par les entrées de transactions
  d'un bloc. Avant que la validation ne commence, Bitcoin Core démarre plusieurs threads de travail qui récupèrent simultanément différents
  outputs précédents, tandis que le thread principal traite le bloc dans l'ordre normal. La nouvelle option `-prevoutfetchthreads` utilise
  huit workers par défaut, en autorise jusqu'à 16 et peut être réglée à zéro pour désactiver l'optimisation. Ce changement empêche que la
  latence de nombreuses lectures disque ne s'accumule séquentiellement. Selon le matériel et la configuration, les benchmarks de l'auteur
  montrent des accélérations de l'initial block download (IBD) allant de 1,18 fois à plus de trois fois plus rapide.

- [Bitcoin Core #34897][] garantit que les index optionnels ne persistent jamais d'état au-delà du dernier flush durable des UTXO du
  chainstate en ignorant un commit d'index à moins que la pointe de l'index ne soit un ancêtre du dernier bloc chainstate vidé sur disque.
  Auparavant, un arrêt non propre pouvait amener Bitcoin Core à redémarrer avec le chainstate sur un bloc antérieur à l'index, créant une
  incohérence entre les deux bases de données. Cela était particulièrement problématique pour `coinstatsindex`, dont l'état roulant
  [MuHash][news131 muhash] est difficile à inverser sans retraiter les blocs correspondants, qui seraient alors indisponibles dans le
  chainstate. Bien que l'index puisse traiter des blocs plus récents en mémoire, il attend désormais que le chainstate le rattrape avant
  d'enregistrer cette progression sur disque.

- [Bitcoin Core #35406][] limite la file de suivi du [diffusion privée][topic transaction origin privacy] à 10 000 transactions (voir le
  [Bulletin #409][news409 privatebroadcast]). Les transactions
  diffusées à l'aide de cette méthode sont suivies jusqu'à ce qu'elles soient observées comme revenant du réseau. Auparavant, la taille de
  la file de suivi était illimitée, de sorte que les transactions qui ne revenaient jamais en raison de différences de politique pouvaient
  s'accumuler indéfiniment et consommer une quantité illimitée de mémoire et de CPU. Une fois la limite atteinte, Bitcoin Core rejette les
  nouvelles soumissions sans supprimer les entrées existantes. Les utilisateurs peuvent inspecter la file avec `getprivatebroadcastinfo` et
  supprimer les transactions bloquées avec `abortprivatebroadcast`.

- [Bitcoin Core #35380][] étend l'API `libbitcoinkernel` (voir le [Bulletin #380][news380 kernel]) afin d'exposer la pile witness et le `scriptSig` de
  chaque entrée de transaction en ajoutant une vue `btck_WitnessStack` et des fonctions pour compter, récupérer et copier ses éléments. Cela
  permet aux applications externes, y compris les scanners de [paiements silencieux][topic silent payments], de récupérer les clés publiques
  stockées dans les données witness segwit ou dans les `scriptSig` P2PKH sans désérialiser séparément les transactions brutes. Ces clés
  publiques d'entrée sont nécessaires pour que les scanners de paiements silencieux puissent déterminer si l'une des sorties de la
  transaction appartient au portefeuille.

- [Bitcoin Core #35568][] réduit le temps de synchronisation et l'utilisation du disque de l'index optionnel `txospenderindex` (voir le
  [Bulletin #394][news394 txospender]) en désactivant ses filtres Bloom LevelDB internes.
  Il s'agit d'optimisations de recherche dans la base de données, sans rapport avec les [filtres Bloom][topic transaction bloom filtering]
  de [BIP37][] historiquement utilisés par les portefeuilles SPV. Les filtres Bloom de LevelDB n'étaient jamais consultés et n'ajoutaient
  qu'une surcharge de traitement et de stockage. Dans le benchmark de l'auteur, une synchronisation complète de l'index est passée de 4
  heures 37 minutes à 3 heures 57 minutes, tandis que l'utilisation du disque est passée de 85,0 GiB à 80,9 GiB. Les index existants restent
  compatibles, mais récupérer l'espace utilisé par les filtres générés précédemment nécessite de reconstruire l'index.

- [Bitcoin Core #34538][] permet à une adresse explicitement configurée avec l'option `externalip` d'être admissible à l'annonce, même si
  l'option `onlynet` exclut son réseau. Ce changement bénéficie aux nœuds qui ouvrent des connexions sortantes automatiques sur un réseau
  tout en acceptant des connexions entrantes sur un autre. Par exemple, considérons un nœud qui établit des connexions sortantes uniquement
  via IPv4 tout en exploitant un service onion [Tor][topic anonymity networks] configuré séparément. Auparavant, Bitcoin Core rejetait les
  adresses onion fournies manuellement parce que l'option `onlynet` marquait Tor comme injoignable.

- [BIPs #2208][] met à jour la justification du [nettoyage du consensus][topic consensus cleanup] de [BIP54][], qui propose d'invalider les
  transactions de 64 octets dépouillées de leur witness afin d'empêcher que leurs hachages soient confondus avec des hachages de nœuds
  internes de Merkle. La PR documente une proposition alternative qui conserve la validité des transactions de 64 octets tout en rejetant
  les nœuds internes de Merkle dont les deux hachages enfants de 32 octets, concaténés, forment une transaction valide de 64 octets (voir le
  [Bulletin #412][news412 merkle64]). En outre, elle corrige l'affirmation précédente de BIP54 selon laquelle les vérificateurs de preuves
  de Merkle n'auraient jamais besoin d'être mis à jour. Les preuves de transactions ordinaires, non longues de 64 octets, sont
  automatiquement protégées, mais un vérificateur qui accepte les preuves de transactions de 64 octets devrait les rejeter après
  l'activation.

- [LND #10962][] empêche que le flux de fermeture coopérative [RBF][topic rbf] (voir le [Bulletin #347][news347 rbf]) soit utilisé pour des
  canaux auxiliaires, tels que les canaux [Taproot Assets][topic client-side validation], dont les outputs de financement s'engagent sur un
  état de protocole supplémentaire. LND sélectionnait auparavant le mécanisme de fermeture RBF à l'aide de bits de fonctionnalité au niveau
  du pair, mais ce mécanisme n'invoque pas les hooks auxiliaires nécessaires pour transporter les actifs dans la transaction de fermeture.
  Il pouvait donc diffuser une transaction Bitcoin valide qui détruirait les engagements d'actifs et laisserait le canal bloqué dans un état
  d'attente de fermeture.

- [LND #10897][] corrige un bug du sweeper qui aurait pu bloquer de façon permanente des entrées provenant de canaux auxiliaires, tels que
  les canaux [Taproot Assets][topic client-side validation]. Ces entrées peuvent ne disposer que d'un faible budget de frais en bitcoins
  parce que la majeure partie de leur valeur est représentée par l'actif superposé, tandis qu'un sweeper auxiliaire contribue un budget
  supplémentaire à la transaction finale de sweep. Initialement, le filtre de LND ne prenait en compte que le budget propre de chaque
  entrée, si bien qu'après qu'un sweep raté augmentait le feerate de départ requis, l'entrée pouvait être exclue de toute tentative future.
  Désormais, le filtre inclut la contribution auxiliaire pour déterminer si une entrée peut payer les frais minimum de relais et le feerate
  de départ.

- [BINANAs #21][] assigne BIN-2025-0003 à [BIP442][], la proposition préliminaire `OP_PAIRCOMMIT` (voir le [Bulletin #395][news395 paircommit]).

{% include snippets/recap-ad.md when="2026-07-21 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="35295,34897,35406,35380,35568,34538,2208,10962,10897,21" %}

[verif ml]: https://groups.google.com/g/bitcoindev/c/OIml9stwbGQ
[verif del]: https://delvingbitcoin.org/t/btc-verified-formalizing-the-bitcoin-protocol/2684
[verif gh]: https://github.com/ProofOfKeags/btc-verified
[lean lang]: https://lean-lang.org/
[news402 hornet]: /fr/newsletters/2026/04/24/#specification-executable-declarative-des-regles-de-consensus-bitcoin-par-hornet-node
[Bitcoin Core 30.3]: https://bitcoincore.org/bin/bitcoin-core-30.3/
[bcc30.3 rn]: https://bitcoincore.org/en/releases/30.3/
[Bitcoin Core 29.4]: https://bitcoincore.org/bin/bitcoin-core-29.4/
[bcc29.4 rn]: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-29.4.md
[news131 muhash]: /en/newsletters/2021/01/13/#bitcoin-core-19055
[news380 kernel]: /fr/newsletters/2025/11/14/#bitcoin-core-30595
[news394 txospender]: /fr/newsletters/2026/02/27/#bitcoin-core-24539
[news409 privatebroadcast]: /fr/newsletters/2026/06/12/#bitcoin-core-35410
[news412 merkle64]: /fr/newsletters/2026/07/03/#interdire-les-preimages-de-noeuds-internes-de-merkle-qui-encodent-des-transactions-minimales-de-64-octets
[news347 rbf]: /fr/newsletters/2025/03/28/#lnd-8453
[news395 paircommit]: /fr/newsletters/2026/03/06/#bips-1699
