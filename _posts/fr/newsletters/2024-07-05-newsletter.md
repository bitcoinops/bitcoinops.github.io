---
title: 'Bulletin Hebdomadaire Bitcoin Optech #310'
permalink: /fr/newsletters/2024/07/05/
name: 2024-07-05-newsletter-fr
slug: 2024-07-05-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume la divulgation de 10 vulnérabilités affectant d'anciennes
versions de Bitcoin Core et décrit une proposition permettant aux factures BOLT11 d'inclure des
chemins aveuglés. Sont également incluses nos sections habituelles avec
des annonces de mises à jour et versions candidates, ainsi que les changements
apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Divulgation de vulnérabilités affectant les versions de Bitcoin Core antérieures à 0.21.0 :**
  Antoine Poinsot a [publié][poinsot disclose] sur la liste de diffusion Bitcoin-Dev un lien vers une
  [annonce][bcco announce] de 10 vulnérabilités affectant des versions de Bitcoin Core qui sont hors
  service depuis presque deux ans<!-- 0.21.x EOL 2022-10-01 per https://bitcoincore.org/en/lifecycle/
  -->. Nous résumons ci-dessous les divulgations :

  - [Exécution de code à distance due à un bug dans miniupnpc][] : avant Bitcoin Core 0.11.1 (sorti en
    octobre 2015), les nœuds avaient [UPnP][] activé par défaut pour leur permettre de recevoir des
    connexions entrantes via [NAT][]. Cela était réalisé en utilisant la [bibliothèque miniupnpc][],
    qu'Aleksandar Nikolic a découvert être vulnérable à diverses attaques à distance
    ([CVE-2015-6031][]). Cela a été corrigé dans la bibliothèque amont, la correction intégrée dans
    Bitcoin Core, et une mise à jour a été faite pour désactiver UPnP par défaut. En enquêtant sur le
    bug, le développeur Bitcoin Wladimir J. Van Der Laan a découvert une autre vulnérabilité d'exécution
    de code à distance dans la même bibliothèque. Cela a été [divulgué de manière responsable][topic
    responsible disclosures], corrigé dans la bibliothèque amont, et intégré dans Bitcoin Core 0.12
    (sorti en février 2016).

  - [Crash du nœud DoS de plusieurs pairs avec de grands messages][] : avant Bitcoin Core 0.10.1, les
    nœuds acceptaient des messages P2P jusqu'à environ 32 mégaoctets. Les nœuds, alors et maintenant,
    permettaient également jusqu'à environ 130 connexions par défaut<!-- 125 entrantes + 8 sortantes sur
    les vieux nœuds ; plus sur les nœuds récents -->. Si chaque pair envoyait un message de taille
    maximale à peu près en même temps, cela forcerait un nœud à allouer environ 4 gigaoctets de mémoire
    en plus des autres besoins du nœud, ce qui était plus que ce que de nombreux nœuds disposaient.
    La vulnérabilité a été divulguée de manière responsable par l'utilisateur de
    BitcoinTalk.org Evil-Knievel, assignée [CVE-2015-3641][], et corrigée dans Bitcoin Core 0.10.1 en
    limitant la taille maximale du message à environ 2 mégaoctets (plus tard augmentée à environ 4
    mégaoctets pour segwit).

  - [Censure des transactions non confirmées][] : les nouvelles transactions sont typiquement
    annoncées par un pair informant un nœud de l'identifiant de transaction txid ou wtxid. La première
    fois qu'un nœud voit un txid ou wtxid, il demande la transaction complète au premier pair qui l'a
    annoncé. Alors que le nœud attend que ce pair réponde, il garde une trace
    d'autres pairs qui annoncent le même txid ou wtxid. Si le premier pair ne répond pas avec la
    transaction avant un délai d'attente, le nœud la demande au second pair (et, si cette demande expire
    également, au troisième pair, et ainsi de suite).

    Avant Bitcoin Core 0.21.0, un nœud ne gardait la trace que de 50 000 demandes. Cela permettait au
    premier pair d'annoncer un txid, de retarder sa réponse à la demande du nœud pour la transaction
    complète, d'attendre que tous les autres pairs du nœud annoncent la transaction, et d'envoyer 50 000
    annonces d'autres txids (peut-être tous fictifs). De cette manière, lorsque la demande originale du
    nœud au premier pair expirait, il ne la demandait à aucun autre pair. L'attaquant (le premier pair)
    pouvait répéter cette attaque indéfiniment pour empêcher de manière permanente le nœud de jamais
    recevoir la transaction. Notez que la censure des transactions non confirmées peut empêcher la
    confirmation rapide de la transaction, ce qui peut conduire à la perte de fonds dans des protocoles
    contractuels tels que LN. John Newbery, citant la co-découverte par Amiti Uttarwar, a divulgué de
    manière responsable la vulnérabilité et un correctif a été publié dans Bitcoin Core 0.21.0.

  - [Liste d'interdiction non limitée CPU/mémoire DoS][] : Bitcoin Core [PR #15617][bitcoin Core
    #15617] (inclus pour la première fois dans la version 0.19.0) a ajouté un code qui vérifiait chaque
    adresse IP interdite par le nœud local jusqu'à 2 500 fois chaque fois qu'un message P2P `getaddr`
    était reçu. La longueur de la liste d'interdiction d'un nœud était illimitée et elle pouvait
    atteindre une taille immense si un attaquant contrôlait un grand nombre d'adresses IP (par exemple,
    des adresses IPv6 faciles à obtenir). Lorsque la liste était longue, chaque demande `getaddr`
    pouvait consommer une quantité excessive de CPU et de mémoire, rendant potentiellement le nœud
    inutilisable ou conduisant à un crash. La vulnérabilité a été attribuée à [CVE-2020-14198][] et
    corrigée dans Bitcoin Core 0.20.1. <!-- FYI: pas divulguée de manière responsable -->

  - [Séparation de réseau due à un ajustement excessif du temps][] : les versions antérieures de
    Bitcoin Core permettaient à leurs horloges d'être décalées en moyenne par le temps rapporté par les
    200 premiers pairs auxquels ils se connectaient. Le code visait à permettre un décalage maximal de
    70 minutes. Toutes les versions de Bitcoin Core ignorent temporairement tous les blocs dont
    l'horodatage est de plus de deux heures dans le futur. Une combinaison de deux bugs pourrait
    permettre à un attaquant de décaler l'horloge des victimes de plus de deux heures dans le passé, les
    amenant potentiellement à ignorer les blocs avec des horodatages précis. La vulnérabilité a été
    divulguée de manière responsable par le développeur practicalswift et corrigée dans Bitcoin Core
    0.21.0.

  - [CPU DoS et blocage du nœud dû au traitement des orphelins][] : les nœuds Bitcoin Core conservent
    un cache de jusqu'à 100 transactions, appelées _transactions orphelines_, pour lesquelles le nœud
    n'a pas les détails de la transaction parente nécessaire dans son mempool ou son ensemble UTXO.
    Après qu'une nouvelle transaction soit validée, le nœud vérifie si l'une des transactions orphelines
    peut maintenant être traitée. Avant Bitcoin Core 0.18.0, chaque fois que le cache des orphelins
    était vérifié, le nœud tentait de valider chacune des transactions orphelines en utilisant les
    derniers état du mempool et UTXO. Si les 100 transactions orphelines mises en cache étaient conçues pour
    nécessiter un excès de CPU pour être validées, le nœud gaspillerait une quantité excessive de CPU et
    ne serait pas capable de traiter de nouveaux blocs et transactions pendant plusieurs heures. Cette
    attaque était essentiellement gratuite à réaliser : les transactions orphelines sont gratuites à
    créer car elles peuvent référencer des transactions parents inexistantes. Un nœud bloqué serait
    incapable de générer des modèles de blocs, empêchant potentiellement un mineur de gagner des
    revenus, et pourrait être utilisé pour empêcher la confirmation de transactions, entraînant
    potentiellement des pertes financières pour les utilisateurs de protocoles de contrat (tels que LN).
    Le développeur sec.eine a divulgué de façon responsable la vulnérabilité et elle a été corrigée dans
    Bitcoin Core 0.18.0.

  - [DoS mémoire à partir de grands messages `inv`][] : un message P2P `inv` peut contenir une liste
    de jusqu'à 50 000 hashes d'en-têtes de blocs. Les nœuds Bitcoin Core modernes avant la version
    0.20.0 répondaient à ce message avec un message P2P `getheaders` séparé pour chaque hash qu'il ne
    reconnaissait pas, chaque message étant d'environ 1 kilo-octet. Cela résultait en ce que le nœud
    stockait environ 50 mégaoctets de messages en mémoire en attendant que son pair les accepte. Cela
    pourrait être réalisé par tous les pairs d'un nœud (jusqu'à environ 130 par défaut) pour utiliser
    plus de 6,5 gigaoctets de mémoire en plus des besoins réguliers en mémoire du nœud, suffisamment
    pour faire crasher de nombreux nœuds. Les nœuds crashés pourraient être incapables de traiter les
    transactions en temps opportun pour les utilisateurs de protocoles de contrat, entraînant
    potentiellement des pertes d'argent. John Newbery a divulgué de façon responsable la vulnérabilité et a
    fourni une correction qui répondait à n'importe quel nombre de hashes dans un message `inv` avec un
    seul message `getheaders`; la correction a été incluse dans Bitcoin Core 0.20.0.

  - [DoS mémoire utilisant des en-têtes de faible difficulté][] : depuis Bitcoin Core 0.10, un nœud
    demande à chacun de ses pairs de lui envoyer les en-têtes de blocs de leur _meilleure blockchain_
    (blockchain valide avec le plus de preuve-de-travail). Un problème connu avec cette approche est
    qu'un pair malveillant pourrait spammer le nœud avec un grand nombre d'en-têtes bidon appartenant à
    des blocs de faible difficulté (par exemple, difficulté-1), qui sont triviaux à créer avec
    l'équipement moderne d'exploitation ASIC. Bitcoin Core a initialement abordé ce problème en
    n'acceptant que les en-têtes sur une chaîne qui correspondait aux _points de contrôle_ codés en dur
    dans Bitcoin Core. Le dernier point de contrôle, bien que datant de 2014,<!-- block 295,000 -->
    avait une difficulté modérément élevée selon les normes modernes, donc il aurait nécessité un effort
    significatif pour créer des en-têtes bidon à partir de celui-ci. Cependant, un changement de code
    incorporé dans Bitcoin Core 0.12 a permis au nœud de commencer à accepter les en-têtes de faible
    difficulté en mémoire, permettant potentiellement à un attaquant de remplir la mémoire avec des
    en-têtes bidon. Cela pourrait conduire au crash du nœud, ce qui pourrait entraîner la perte de fonds
    pour les utilisateurs de protocoles de contrat (tels que LN). Cory Fields a divulgué de façon responsable
    la vulnérabilité et elle a été corrigée dans la version 0.15.0.

  - [DoS gaspillant du CPU en raison de demandes malformées][] : avant Bitcoin Core 0.20.0, un
    attaquant ou un pair bogué pouvait envoyer un message P2P
    `getdata` qui pourrait entraîner une consommation de 100 % du CPU par le thread de
    traitement des messages. Le nœud ne serait également plus capable de recevoir des messages de
    l'attaquant pendant la durée de sa connexion, bien qu'il puisse toujours recevoir des messages de
    pairs honnêtes. Cela pourrait poser problème pour les nœuds sur des ordinateurs avec un petit nombre
    de cœurs CPU mais n'était autrement qu'un désagrément. John Newbery a divulgué de manière responsable la
    vulnérabilité et a fourni un correctif, qui a été incorporé dans Bitcoin Core 0.20.0.

  - [Crash lié à la mémoire lors des tentatives de parse des URI BIP72][] : Bitcoin Core avant 0.20.0
    prenait en charge le [protocole de paiement BIP70][topic bip70 payment protocol] qui étendait les
    URI `bitcoin:` de [BIP21][] avec un paramètre `r` défini dans [BIP72][] qui référence une URL
    HTTP(S). Bitcoin Core tentait de télécharger le fichier à l'URL et de le stocker en mémoire pour le
    parser, mais si le fichier était plus grand que la mémoire disponible, Bitcoin Core finirait par
    se fermer. Comme le téléchargement tenté se produit en arrière-plan, un utilisateur pourrait
    s'éloigner du nœud avant que le crash ne se produise, l'empêchant de remarquer le crash et de
    redémarrer rapidement ce qui pourrait être un service crucial. La vulnérabilité a été divulguée de
    manière responsable par Michael Ford et corrigée en supprimant le support de BIP70 dans Bitcoin Core
    0.20.0 (voir le [Bulletin #70][news70 bip70]).

  L'annonce de Poinsot a indiqué que des vulnérabilités supplémentaires corrigées dans Bitcoin Core
  22.0 seraient annoncées plus tard ce mois-ci, et les vulnérabilités corrigées dans 23.0 suivraient
  le mois prochain. Les vulnérabilités corrigées dans les versions ultérieures seront divulguées
  conformément à la [nouvelle politique de divulgation][] de Bitcoin Core comme précédemment discuté
  (voir le [Bulletin #306][news306 disclosure]).

- **Ajout d'un champ de facture BOLT11 pour les chemins aveuglés :** Elle Mouton [a posté][mouton
  b11b] sur Delving Bitcoin une proposition de spécification BLIP pour un champ optionnel qui pourrait
  être ajouté aux factures BOLT11 pour communiquer un [chemin aveuglé][topic rv routing] pour payer le
  nœud du destinataire. Par exemple, le commerçant Bob souhaite recevoir un paiement de la cliente
  Alice mais ne veut pas divulguer l'identité de son nœud ou des pairs avec lesquels il partage des
  canaux. Il génère un chemin aveuglé commençant à quelques sauts de son nœud et l'ajoute à une
  facture BOLT11 par ailleurs standard qu'il donne à Alice. Si Alice utilise un logiciel capable de
  parser cette facture et de router un paiement en utilisant des chemins aveuglés, elle peut payer
  Bob.

  Si Alice utilise un logiciel qui ne prend pas en charge le BLIP, elle sera incapable de payer la
  facture et recevra un message d'erreur.

  Mouton note dans le BLIP que l'utilisation de chemins aveuglés dans BOLT11 est seulement destinée à
  être utilisée jusqu'à ce que le protocole [offres][topic offers] ait été largement déployé pour
  communiquer les factures, car celui-ci utilise nativement des chemins aveuglés et présente d'autres
  avantages par rapport aux factures BOLT11.

  Bastien Teinturier [a argumenté][teinturier b11b] contre l'idée et l'idée connexe d'exposer le
  format de facture des offres. Il préfère se concentrer sur le déploiement complet des offres,
  croyant que cela amènera le système vers son état ultime plus rapidement ainsi qu'éliminera
  le fardeau de soutenir des états intermédiaires pour une durée indéfinie. Il pense que les
  utilisateurs recevant des codes d'erreur lorsqu'ils tentent de payer des factures BOLT11 avec des
  chemins masqués demanderont aux développeurs d'ajouter le support de cette fonctionnalité, les
  distrayant ainsi de travailler sur les offres.

  Olaoluwa Osuntokun [a répondu][osuntokun b11b] qu'il préfère travailler sur les chemins masqués
  séparément des autres dépendances des offres pour s'assurer que cela fonctionne aussi bien que
  possible. Il imagine des factures BOLT11 avec des chemins masqués utilisées dans des protocoles tels
  que [L402][] où les clients communiquent déjà directement avec les serveurs, leur offrant ainsi de
  nombreux avantages des offres, ils ont donc seulement besoin de cette petite mise à niveau pour
  utiliser les chemins masqués afin d'obtenir la même confidentialité que les offres fourniraient.

  Au moment de la rédaction de cette newsletter, la discussion ne semblait pas close. Les BLIPs sont des
  spécifications optionnelles et il ressort de la discussion que ce BLIP pourrait être implémenté
  dans LND mais pas dans Eclair ou lightning-kmp (la base pour le portefeuille Phoenix) ; les plans
  pour d'autres implémentations n'ont pas été discutés.

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets
d'infrastructure Bitcoin. Veuillez envisager de passer aux nouvelles
versions ou d'aider à tester les versions candidates.*

- [Bitcoin Core 26.2rc1][] est un candidat à la sortie pour une version de maintenance de la série
  de sorties plus ancienne de Bitcoin Core.

### Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core
lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust
Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Propositions
d'Amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips
repo], [Inquisition Bitcoin][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #28167][] introduit `-rpccookieperms` comme une nouvelle option de démarrage de
  `bitcoind`, permettant aux utilisateurs de définir les permissions de lecture de fichier pour le
  cookie d'authentification RPC en choisissant entre propriétaire (par défaut), groupe, ou tous les
  utilisateurs.

- [Bitcoin Core #30007][] ajoute le DNS seeder d'Ava Chow (achow101) à `chainparams` pour fournir
  une source supplémentaire de confiance pour la découverte de pairs. Il utilise
  [Dnsseedrs][dnsseedrs], un nouveau seeder DNS bitcoin open source écrit en Rust qui explore les
  adresses de nœuds sur les réseaux IPv4, IPv6, Tor v3, I2P, et CJDNS.

- [Bitcoin Core #30200][] introduit une nouvelle interface `Mining`. Les RPCs existants comme
  `getblocktemplate` et `generateblock` commencent immédiatement à utiliser l'interface. Les travaux
  futurs comme une interface [Stratum V2][topic pooled mining] qui utilise Bitcoin Core comme
  fournisseur de modèle vont utiliser la nouvelle interface de minage.

- [Core Lightning #7342][] corrige le traitement d'un cas limite au démarrage où
  le service s'arrête parce qu'il détecte que `bitcoind` a reculé dans
  sa hauteur de bloc, ce qui peut arriver pendant une réorganisation de la blockchain.
  Il attendra désormais que la hauteur de l'en-tête de bloc atteigne le niveau précédent
  et commence à scanner les blocs nouvellement reçus (réorganisés).

- [LND #8796][] assouplit les restrictions sur les paramètres d'ouverture de canal en permettant
  désormais aux pairs d'initier des canaux non-[zero-conf][topic zero-conf channels]
  avec une `min_depth` de zéro. Néanmoins, LND attendra toujours au moins une
  confirmation avant de considérer le canal comme utilisable. Ce changement améliore
  l'interopérabilité avec d'autres implémentations de Lightning qui supportent cela,
  comme LDK, et s'aligne sur la spécification [BOLT2][].

- [LDK #3125][] introduit le support pour l'encodage et l'analyse des messages `HeldHtlcAvailable`
  et `ReleaseHeldHtlc` requis par la mise en œuvre à venir du protocole de
  [paiements asynchrones][topic async payments]. Il ajoute également des charges utiles de [message
  onion][topic onion messages] à ces messages, et un trait `AsyncPaymentsMessageHandler` pour
  `OnionMessenger`.

- [BIPs #1610][] ajoute [BIP379][BIP379 md] avec une spécification pour [Miniscript][topic
  miniscript], un langage qui se compile en Bitcoin Script mais qui permet
  la composition, le templating, et une analyse définitive. Voir le [Bulletin #304][news304
  miniscript] pour une référence antérieure à ce BIP.

- [BIPs #1540][] ajoute les BIPs [328][bip328], [390][bip390], et [373][bip373] avec une
  spécification pour un schéma de dérivation [MuSig2][topic musig] pour les clés agrégées (328), les
  [descripteurrs][topic descriptors] de script de sortie  (390), et les champs [PSBT][topic psbt]
  pour permettre l'inclusion des données MuSig2 dans un PSBT de n'importe quelle version (373). MuSig2
  est un protocole pour l'agrégation de clés publiques et de signatures pour l'algorithme de [signature
  numérique schnorr][topic schnorr signatures] qui nécessite seulement deux tours
  de communication (MuSig1 en nécessite trois) pour fournir une expérience de signature
  qui ne diffère pas excessivement de la multisig basée sur des scripts. Le schéma de dérivation
  permet de construire des clés publiques étendues de style [BIP32][topic bip32] à partir d'une clé publique
  agrégée MuSig2 [BIP327][].

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28167,30007,30200,7342,8796,3125,1610,1540,15617" %}
[bitcoin core 26.2rc1]: https://bitcoincore.org/bin/bitcoin-core-26.2/
[mouton b11b]: https://delvingbitcoin.org/t/blip-bolt-11-invoice-blinded-path-tagged-field/991
[teinturier b11b]: https://delvingbitcoin.org/t/blip-bolt-11-invoice-blinded-path-tagged-field/991/5
[osuntokun b11b]: https://delvingbitcoin.org/t/blip-bolt-11-invoice-blinded-path-tagged-field/991/6
[l402]: https://github.com/lightninglabs/L402
[exécution de code à distance due à un bug dans miniupnpc]: https://bitcoincore.org/en/2024/07/03/disclose_upnp_rce/
[cve-2015-6031]: https://nvd.nist.gov/vuln/detail/CVE-2015-6031
[Crash du nœud DoS de plusieurs pairs avec de grands messages]: https://bitcoincore.org/en/2024/07/03/disclose_receive_buffer_oom/
[censure des transactions non confirmées]: https://bitcoincore.org/en/2024/07/03/disclose_already_asked_for/
[Liste d'interdiction non limitée CPU/mémoire DoS]: https://bitcoincore.org/en/2024/07/03/disclose-unbounded-banlist/
[Séparation de réseau due à un ajustement excessif du temps]: https://bitcoincore.org/en/2024/07/03/disclose-timestamp-overflow/
[CPU DoS et blocage du nœud dû au traitement des orphelins]: https://bitcoincore.org/en/2024/07/03/disclose-orphan-dos/
[DoS mémoire à partir de grands messages `inv`]: https://bitcoincore.org/en/2024/07/03/disclose-inv-buffer-blowup/
[DoS mémoire utilisant des en-têtes de faible difficulté]: https://bitcoincore.org/en/2024/07/03/disclose-header-spam/
[DoS gaspillant du CPU en raison de demandes malformées]: https://bitcoincore.org/en/2024/07/03/disclose-getdata-cpu/
[news70 bip70]: /en/newsletters/2019/10/30/#bitcoin-core-17165
[Crash lié à la mémoire lors des tentatives de parse des URI BIP72]: https://bitcoincore.org/en/2024/07/03/disclose-bip70-crash/
[cve-2020-14198]: https://nvd.nist.gov/vuln/detail/CVE-2020-14198
[news306 disclosure]: /fr/newsletters/2024/06/07/#divulgation-a-venir-de-vulnerabilites-affectant-les-anciennes-versions-de-bitcoin-core
[upnp]: https://en.wikipedia.org/wiki/Universal_Plug_and_Play
[nat]: https://en.wikipedia.org/wiki/Network_address_translation
[bibliothèque miniupnpc]: https://miniupnp.tuxfamily.org/
[poinsot disclose]: https://mailing-list.bitcoindevs.xyz/bitcoindev/xsylfaVvODFtrvkaPyXh0mIc64DWMCchxiVdTApFqJ_0Q5v0bOoDpS_36HwDKmzdDO9U2RKMzESEiVaq47FTamegi2kCNtVZeDAjSR4G7Ic=@protonmail.com/
[bcco announce]: https://bitcoincore.org/en/security-advisories/
[nouvelle politique de divulgation]: https://mailing-list.bitcoindevs.xyz/bitcoindev/rALfxJ5b5hyubGwdVW3F4jtugxnXRvc-tjD_qwW7z73rd5j7lXGNdEHWikmSdmNG3vkSOIwEryZzOZr_DgmVDDmt9qsX0gpRAcpY9CfwSk4=@protonmail.com/T/#u
[CVE-2015-3641]: https://nvd.nist.gov/vuln/detail/CVE-2015-3641
[dnsseedrs]: https://github.com/achow101/dnsseedrs
[news304 miniscript]: /fr/newsletters/2024/05/24/#proposition-de-bip-miniscript
[BIP379 md]: https://github.com/bitcoin/bips/blob/master/bip-0379.md
