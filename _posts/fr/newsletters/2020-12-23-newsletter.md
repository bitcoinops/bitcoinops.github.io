---
title: 'Bulletin Bitcoin Optech #129: Revue spéciale Année 2020'
permalink: /fr/newsletters/2020/12/23/
name: 2020-12-23-newsletter-fr
slug: 2020-12-23-newsletter-fr
type: newsletter
layout: newsletter
lang: fr

excerpt: >
  Cette édition spéciale de la Newsletter Optech résume les
   développements de Bitcoin pendant toute l'année 2020.
---
{{page.excerpt}} C'est la suite de nos résumés de [2018][2018
summary] et [2019][2019 summary].

Comme nous l'avons fait dans nos précédents résumés annuels, nous devons faire précéder
ce que vous êtes sur le point de lire par des excuses. Beaucoup plus de personnes ont
travaillées à la fois sur le maintien et l'amélioration de la technologie Bitcoin que
nous ne pourrions jamais écrire. Leurs recherches fondamentales, la révision du code,
les corrections de bogues, la rédaction de tests, le travail administratif et d'autres
activités ingrates ne peuvent pas être décrites ici---mais elles ne sont pas ignorées.
Si vous avez contribué à Bitcoin en 2020, veuillez accepter nos plus sincères remerciements.

## Sommaire

* Janvier
  * [Spécification, implémentations et utilisation du DLC](#dlc)
* Février
  * [Grands canaux LN](#large-channels)
  * [Double financement LN et financement interactif](#dual-interactive-funding)
  * [Chemins aveugles LN](#blinded-paths)
* Mars
  * [Signature résistante à l'exfiltration](#exfiltration-resistance)
* Avril
  * [Payjoin](#payjoin)
  * [PTLC LN et autres améliorations cryptographiques](#ptlcs)
  * [Porte-clés BIP85](#bip85)
  * [Coffre-forts](#vaults)
* Mai
  * [Confidentialité de l'origine de la transaction](#transaction-origin-privacy)
  * [Échanges atomiques succincts](#succinct-atomic-swaps-sas)
  * [Implémentation de l'échange de pièces](#coinswap-implementation)
  * [Filtres à bloc compacts](#compact-block-filters)
* Juin
  * [Attaque de paiement excessif sur les transactions segwit à entrées multiples](#overpayment-attack-on-multi-input-segwit-transactions)
  * [Attaque d'atomicité de paiement LN](#ln-payment-atomicity-attack)
  * [Attaques rapides d'éclipse LN](#fast-ln-eclipse-attacks)
  * [Rançon des frais LN](#ln-fee-ransom)
  * [Incitations minières HTLC](#concern-about-htlc-mining-incentives)
  * [Inventaire d'attaque par déni de service en mémoire insuffisante](#inventory-out-of-memory-denial-of-service-attack-invdos)
  * WabiSabi coordonne l'échange de pièces avec des quantités de sortie arbitraires](#wabisabi)
* Juillet
  * [Annonces de transaction WTXID](#wtxid-announcements)
* Août
  * [Signet](#signet)
  * [Sorties d'ancrage LN](#anchor-outputs)
* Septembre
  * [Vérification de signature plus rapide](#glv-endomorphism)
  * [Alliance des brevets](#patent-alliance)
* Octobre
  * [Attaques par brouillage LN](#jamming)
  * [Divulgations de sécurité LND](#lnd-disclosures)
  * [Message de signature générique](#generic-signmessage)
  * [MuSig2](#musig2)
  * [Messages d'adresse version 2](#addrv2)
* Novembre
  * [Place de marché des canaux entrants Lightning Pool](#lightning-pool)
* Decembre
  * [Offres LN](#ln-offers)
* Résumés en vedette
    * [Taproot, tapscript, et signatures schnorr](#taproot)
    * [Mises à jour majeures des principaux projets d'infrastructures](#releases)
    * [Bitcoin Optech](#optech)

## Janvier

{:#dlc}
Plusieurs développeurs ont commencé à [travailler][news81 dlc] sur une
[spécification][dlc spec] pour l'utilisation de [contrats logiques discrets][] (DLC)
entre différents logiciels. Les DLC sont un protocole de contrat dans lequel
deux parties ou plus acceptent d'échanger de l'argent en fonction du résultat
d'un certain événement déterminé par un oracle (ou plusieurs oracles). Après
l'événement, l'oracle publie un engagement sur l'issue de l'événement que la
partie gagnante peut utiliser pour réclamer ses fonds. L'oracle n'a pas besoin
de connaître les termes du contrat (ni même de savoir qu'il existe un contrat).
Le contrat peut être rendu indiscernable de nombreuses autres transactions Bitcoin
ou il peut être exécuté dans un canal LN. Cela rend les DLC plus privés et plus
efficaces que les autres méthodes de contrat connues basées sur un oracle, et
on peut dire qu'ils sont plus sûrs car un oracle qui s'engage sur un faux résultat
génère des preuves évidentes de fraude. D'ici la fin de l'année, il y aura quatre
implémentations compatibles des DLC, une [application][crypto garage p2p deriv] pour
offrir et accepter des dérivés peer-to-peer basés sur les DLC, et plusieurs
utilisateurs [rapportant][dlc election bet] qu'ils ont utilisé les DLC dans
des transactions sur le réseau principal.

## Février

{:#large-channels}
Cinq ans après la [première présentation publique sur LN][dryja poon sf devs],
plusieurs décisions précoces du protocole censées être temporaires ont
été revues. Le changement le plus immédiat a été la [mise à jour][news86 bolts596]
en février de la spécification LN qui a permis aux utilisateurs de se
soustraire aux limites de [valeur maximale des canaux et des paiements][topic large channels]
promulguées en 2016.

{:#dual-interactive-funding}
Une autre décision prise au début et qui a été reconsidérée était de garder
le protocole simple en ouvrant tous les canaux avec un seul financeur. Cela
minimise la complexité du protocole mais empêche les bailleurs de fonds des
canaux de recevoir des paiements avant d'avoir dépensé une partie de leurs
fonds---une position qui crée des obstacles aux commerçants qui rejoignent LN.
Une proposition visant à éliminer ce problème est celle des canaux à double
financement, où l'ouvreur du canal et sa contrepartie s'engagent à verser une
certaine somme d'argent au canal. Lisa Neigut a développé un [protocole][bolts #524]
pour le double financement, mais (comme prévu) c'est complexe. En février,
elle a lancé une [discussion] [news83 interactive funding] sur une amélioration
progressive de la norme actuelle de financement unique qui permettrait la
construction interactive de la transaction de financement. Au lieu du cas
actuel où une partie propose l'ouverture d'un canal et l'autre partie l'accepte
ou le rejette, les nœuds appartenant aux deux parties pourraient échanger des
informations sur leurs préférences et négocier l'ouverture d'un canal
qu'elles trouveraient toutes deux souhaitable.

{:#blinded-paths}
De nouvelles avancées ont également été réalisées sur les plans souvent
discutés visant à autoriser le routage par rendez-vous pour le LN, qui a
été qualifié de priorité lors de la [réunion de spécification LN 2018][rv routing].
Bastien Teinturier a [décrit][news85 blinded paths] en février une nouvelle
méthode permettant d'obtenir une confidentialité équivalente, basée sur une
amélioration de la confidentialité qu'il avait déjà proposée. Cette nouvelle
méthode, appelée *chemins aveugles*, a ensuite été mise en œuvre en tant que
fonctionnalité expérimentale dans [C-Lightning][news92 cl3600].

## Mars

{:#exfiltration-resistance}
Une méthode que les portefeuilles matériels pourraient utiliser pour voler
des bitcoins à leurs utilisateurs est la fuite d'informations sur les clés
privées du portefeuille via les signatures de transaction qu'il crée. En mars,
[Stepan Snigirev][news87 exfiltration], [Pieter Wuille][news88 exfiltration]
et plusieurs autres personnes ont discutés des solutions possibles à ce
problème pour le système de signature ECDSA actuel de Bitcoin et le système
proposé de [signature schnorr][topic schnorr signatures].

<div markdown="1" class="callout" id="taproot">
### Sommaire 2020<br>Taproot, tapscript, et signatures schnorr

Presque tous les mois de l'année 2020 ont été marqués par un développement
principalement lié à l'embranchement convergent de la proposition [taproot][topic taproot]
([BIP341][]) qui ajoute également la prise en charge des [sigantures schnorr][topic schnorr signatures]
([BIP340][]) et [tapscript][topic tapscript] ([BIP342][]). Ensemble, ces
améliorations permettront aux utilisateurs de scripts à une seule signature,
de scripts à plusieurs signatures et de contrats complexes d'utiliser des
engagements d'apparence identique qui renforcent leur confidentialité et
la fongibilité de tous les bitcoins. Les opérateurs bénéficieront de frais
moins élevés et de la possibilité de résoudre de nombreux scripts multisignature
et contrats complexes avec la même efficacité, des frais peu élevés et un
large éventail d'anonymat que les utilisateurs de scripts à signature unique.
Taproot et schnorr jettent également les bases de futures mises à jour
potentielles qui pourraient améliorer encore l'efficacité, la confidentialité
et la fongibilité, telles que l'agrégation de signatures, [SIGHASH_ANYPREVOUT][topic sighash_anyprevout],
et de [changements de langage de script][topic simplicity].

Cette section spéciale concentre les synthèses de ces développements
en un seul récit qui, nous l'espérons, sera plus facile à suivre que
la description de chaque événement séparément dans le mois où il s'est produit.

{:#activation-mechanisms}
Le mois de janvier a commencé par une discussion sur les mécanismes
d'activation de l'embranchement convergent, Matt Corallo [proposant][news80 msfa]
une approche prudente et patiente pour régler les désaccords entre les
différents ensembles de parties prenantes. D'autres développeurs se sont
concentrés sur la proposition [BIP8][] afin de pouvoir contourner
rapidement le type de problème procédural qui a retardé l'activation
de segwit en 2016 et 2017. La discussion sur le mécanisme d'activation
précis à utiliser se poursuivra toute l'année, dans un [canal IRC dédié][##taproot-activation]
et ailleurs, avec à la fois un [sondage des développeurs][news122 devsurvey]
sur la conception du mécanisme et un [sondage des mineurs][news125 miner survey]
sur leur soutien à taproot.

Le mois de février a vu la première des nombreuses mises à jour apportées
au cours de l'année aux algorithmes utilisés pour dériver les clés publiques
et les signatures dans la spécification BIP340 des signatures schnorr.
La [plupart][news83 alt tiebreaker] de ces [modifications][news87 bip340 update]
étaient de [petites][news111 uniform tiebreaker] optimisations [découvertes][news96 bip340 update]
à partir de [l'expérience][news113 bip340 update] de la mise en œuvre et
du test de la proposition dans [libsecp256k1][] et de sa branche expérimentale
[libsecp256k1-zkp][]. En février également, Lloyd Fournier a [étendu][news87 taproot generic group]
la preuve de sécurité précédente d'Andrew Poelstra pour taproot.

En mars, Bitcoin Core a soigneusement [modifié][news89 op_if] son code de
consensus---sans introduire de fork---pour supprimer une inefficacité dans
l'analyse de `OP_IF` et des opcodes de contrôle de flux associés. Actuellement,
cette inefficacité ne peut pas être exploitée pour causer des problèmes,
mais les capacités étendues proposées pour tapscript auraient permis à
un attaquant d'utiliser cette inefficacité pour créer des blocs dont la
vérification pourrait nécessiter une grande quantité de calculs.

Bien qu'une grande partie de l'attention publique sur taproot se concentre
sur son changement des règles de consensus de Bitcoin, taproot ne sera pas
une contribution positive à moins que les développeurs de portefeuilles
puissent l'utiliser en toute sécurité. En avril, et tout au long de l'année,
[plusieurs][news87 bip340 update1] mises à jour de BIP340 [ont modifiées][news87 bip340 update]
les [recommandations][news91 bip340 powerdiff] sur la [manière][news96 bip340 nonce update]
dont les développeurs doivent générer les clés publiques et le nonce de
signature. Ces changements n'intéressent probablement directement que les
cryptographes, mais l'histoire du bitcoin comporte de nombreux exemples
de personnes ayant perdu de l'argent parce qu'un développeur de portefeuille
n'avait pas bien compris le protocole cryptographique qu'il avait mis en œuvre.
Espérons que les recommandations de cryptographes expérimentés dans le BIP340
permettront d'éviter certains de ces types de problèmes à l'avenir.

En mai, il y a eu une [nouvelle discussion][news97 additional commitment] sur
l'attaque de la propriété aveugle qui rend dangereux la signature automatique
des transactions avec un porte-monnaie matériel. Idéalement, les porte-monnaies
matériels pourraient fournir un mode dans lequel ils signeraient automatiquement
des transactions garanties pour augmenter le solde du porte-monnaie, comme les
créateurs de coinjoins et les [jointement LN][topic splicing]. Malheureusement,
la signature d'une transaction n'est sûre que si vous êtes certain que les entrées
sont les vôtres---autrement, un attaquant peut vous faire signer une transaction
qui semble ne comporter qu'une seule de vos entrées, puis vous faire signer une
autre version de la même transaction qui semble également ne comporter qu'une seule
de vos entrées (une entrée différente de la première version), et enfin combiner
les signatures des deux entrées différentes dans la transaction réelle qui verse
votre argent à l'attaquant. Ce n'est normalement pas un risque parce que la plupart
des gens n'utilisent aujourd'hui que des portefeuilles matériels pour signer des
transactions où ils possèdent 100% des entrées, mais pour les coinjoins, les joints
LN et d'autres protocoles, il est prévu que d'autres utilisateurs puissent contrôler
partiellement ou totalement certaines des entrées. Il a été proposé que taproot
fournisse un moyen supplémentaire de s'engager sur les entrées qui peut être utilisé
conjointement avec les données fournies dans un [PSBT][topic psbt] pour garantir
qu'un portefeuille matériel ne génère une signature valide que lorsqu'il dispose
de suffisamment de données pour identifier toutes ses entrées. Cette proposition
a ensuite été [acceptée][news101 additional commitment] dans le BIP341.

![Illustration of using a fake coinjoin to trick a hardware wallet into losing funds](/img/posts/2020-05-fake-coinjoin-trick-hardware-wallet.dot.png)

En juillet, une autre discussion a repris à propos d'un problème précédemment
connu---le [format d'adresse bech32][topic bech32] étant moins efficace que
prévu pour empêcher les utilisateurs d'envoyer de l'argent à des adresses
non utilisables. Cela n'affecte pas concrètement les utilisateurs actuels de
l'adresse bech32, mais cela pourrait être un problème pour les adresses taproot
prévues où l'ajout ou la suppression d'un petit nombre de caractères pourrait
entraîner la perte de fonds. L'année dernière, il a été proposé de simplement
étendre la protection dont bénéficient actuellement les adresses segwit v0 aux
adresses segwit v1 (taproot), mais cela réduirait la flexibilité des mises à jour
futures. [Cette année][news107 bech32 fives], après plus de [recherche][news127 bech32m research]
et de [débat][news119 bech32 discussion], il semble y avoir un accord entre les
développeurs sur le fait que taproot et les futures mises à jour de scripts basés
sur segwit devraient utiliser un nouveau format d'adresse qui est une légère
modification des adresses originales [BIP173][] bech32. Le nouveau format
résoudra le problème et fournira d'autres propriétés intéressantes.

En septembre, le code implémentant la vérification de la signature schnorr et
les fonctions de signature unique de [BIP340][] a été [fusionné][news115 bip340 merge]
dans libsecp256k1 et a rapidement fait partie de Bitcoin Core. Cela a permis
la [fusion][news120 taproot merge] ultérieure du code de vérification pour taproot,
schnorr et tapscript. Le code consiste en environ 700 lignes de modifications liées
au consensus (500 sans les commentaires et les espaces blancs) et 2 100 lignes de tests.
Plus de 30 personnes ont directement révisé ce PR et les changements associés, et
beaucoup d'autres ont participés au développement et à la révision de la recherche
sous-jacente, des BIPs, du code associé dans libsecp256k1, et d'autres parties
du système. Les nouvelles règles d'embranchement convergent ne sont actuellement
utilisées que dans [signet][topic signet] et dans le mode de test privé de Bitcoin
Core ("regtest") ; elles doivent être activées avant de pouvoir être utilisées
sur le réseau principal de Bitcoin.

De nombreux contributeurs de taproot ont passés le reste de l'année à se concentrer
sur la version 0.21.0 de Bitcoin Core, avec l'intention qu'une version mineure
ultérieure, peut-être 0.21.1, contienne un code permettant de commencer à appliquer
les règles de taproot lorsqu'un signal d'activation approprié est reçu.

</div>

## Avril

{:#payjoin}
Le protocole [payjoin][topic payjoin] basé sur la [proposition Pay-to-EndPoint][news8 p2ep]
de 2018 a reçu une impulsion majeure en avril lorsqu'une version de celui-ci
a été [ajoutée][news94 btcpay payjoin] au système de traitement des paiements
auto-hébergés BTCPay. Payjoin offre aux utilisateurs un moyen pratique
d'accroître leur confidentialité et celle des autres utilisateurs du réseau
en créant des transactions qui remettent en cause l'[hypothèse][common ownership heuristic]
selon laquelle la même personne possède tous les éléments d'une transaction.
La version BTCPay de payjoin sera bientôt [spécifiée][news104 bips923] comme
[BIP78][] et son support a été ajouté à [d'autres programmes][news116 payjoin joinmarket].

{:#ptlcs}
Une amélioration largement souhaitée de LN est le passage du mécanisme de
sécurité des paiements des contrats à temps de hachage ([HTLCs] [topic htlc])
aux contrats à temps de point ([PTLCs] [topic ptlc]) qui améliorent la
confidentialité des dépensiers et des receveurs contre une variété de méthodes
de surveillance. Une complication est que la construction idéale d'un PTLC
multipartite est difficile à mettre en œuvre avec le [schéma de signature ECDSA][ecdsa]
existant de Bitcoin (bien que cela soit plus facile avec les
[signatures schnorr][topic schnorr signatures]). Au début de l'année, Lloyd
Fournier a fait circuler un [article][fournier otves] analysant les
[adaptateurs de signature][topic adaptor signatures] en dissociant leurs
propriétés fondamentales de verrouillage et d'échange d'informations de leur
utilisation de signatures multipartites, décrivant un moyen facile d'utiliser
le multisig basé sur Bitcoin Script. Lors d'un hackathon en avril, plusieurs
développeurs ont [produit][news92 ecdsa adaptor] une mise en œuvre approximative
de ce protocole pour un dérivation de la célèbre bibliothèque libsecp256k1.
Plus tard, en septembre, Fournier a fait progresser l'aspect pratique des PTLC
sans avoir besoin d'attendre les changements apportés à Bitcoin en proposant une
[manière différente][news113 witasym] de [construire][news119 witasym update] des
transactions d'engagement LN. En décembre, il proposait [deux nouvelles façons][news128 fancy static]
d'améliorer la robustesse des sauvegardes LN, offrant à nouveau des solutions
pratiques aux problèmes des utilisateurs grâce à l'utilisation intelligente
de la cryptographie.

{:#bip85}
En avril, Ethan Kosakovsky a [posté][news93 super keychain] une proposition
à la liste de diffusion Bitcoin-Dev pour utiliser un  trousseau de clés
déterministe hiérarchique (HD) [BIP32][] pour créer des graines pour des
trousseaux de clés HD enfants qui peuvent être utilisés dans différents
contextes. Cela pourrait résoudre le problème que de nombreux portefeuilles
ne permettent pas d'importer des clés privées étendues (xprvs)---ils ne
permettent d'importer qu'une graine HD ou des données précurseurs qui sont
transformées en graine (par exemple des mots de graine [BIP39][] ou SLIP39).
La proposition permet à un utilisateur possédant plusieurs portefeuilles
de les sauvegarder tous en utilisant uniquement la graine du super-keychain.
Cette proposition deviendrait [plus tard][news102 bip85] [BIP85][] et serait
mise en œuvre dans les versions récentes du porte-monnaie matériel ColdCard.

{:#vaults}
Deux annonces concernant les [coffres-forts][topic vaults] ont été faites
en avril. Les coffres sont un type de contrat connu sous le nom de
[condition de dépense][topic covenants] qui émet un avertissement lorsque
quelqu'un tente de dépenser les fonds du contrat, donnant ainsi au propriétaire
du contrat le temps de bloquer une dépense qu'il n'a pas autorisée. Bryan
Bishop a annoncé un [prototype de chambre forte][news94 bishop vault] basé
sur sa [proposition][news59 bishop idea] de l'année dernière. Kevin Loaec
et Antoine Poinsot ont annoncé leur propre projet, [Revault][news95 revault],
qui [se concentre][news100 revault arch] sur l'utilisation du modèle de
coffre-fort pour stocker des fonds partagés entre plusieurs utilisateurs
avec une sécurité multisig. Jeremy Rubin a également annoncé un
[nouveau langage de programmation de haut niveau][news109 sapio] conçu pour la
création de contrats intelligents avec l'opcode [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify],
qui pourrait faciliter la création et la gestion des coffres-forts.

## Mai

{:#transaction-origin-privacy}
Le projet Bitcoin Core a fusionné plusieurs PR en mai et au cours des mois
suivants qui ont amélioré la [confidentialité de l'origine de la transaction][tx origin wiki],
à la fois pour les utilisateurs du porte-monnaie Bitcoin Core et pour les
utilisateurs d'autres systèmes. [Bitcoin Core #18038][] a commencé à [suivre][news96 bcc18038]
si au moins un pair avait accepté une transaction générée localement, ce qui
a permis au portefeuille de réduire considérablement la fréquence à laquelle
Bitcoin Core rediffusait ses propres transactions et a rendu plus difficile
pour les nœuds de surveillance d'identifier le nœud à l'origine de la transaction.
Les PR [#18861][Bitcoin Core #18861] et [#19109][Bitcoin Core #19109] ont pu
[bloquer un type de balayage actif][news99 bcc18861] par les nœuds de surveillance
en [ne répondant qu'aux demandes][news107 bcc19109] de transaction des pairs
auxquels le nœud a parlé de la transaction, ce qui réduit encore la capacité
des tiers à déterminer quel nœud a diffusé une transaction en premier. Les PR
[#14582][Bitcoin Core #14582] et [#19743][Bitcoin Core #19743] permettent au
porte-monnaie d'[essayer automatiquement][news112 bcc14582] d'éliminer les liens
de [réutilisation d'adresse][topic output linking] lorsque cela ne coûte pas
de frais supplémentaires à l'utilisateur (ou, alternativement, de permettre
à l'utilisateur de spécifier le supplément maximum qu'il est prêt à dépenser
pour éliminer de tels liens).

La fin du mois de mai et le début du mois de juin ont vu deux développements
importants dans le domaine des échanges de pièces. Coinswap est un protocole
sans confiance qui permet à deux utilisateurs ou plus de créer des transactions
qui ressemblent à des paiements ordinaires mais qui, en réalité, échangent
leurs pièces l'une contre l'autre. Cela améliore la confidentialité non seulement
des utilisateurs de coinswaps mais aussi de tous les utilisateurs de bitcoins,
car tout ce qui ressemble à un paiement pourrait être un échange de pièces.

- **Succinct Atomic Swaps (SAS):** Ruben Somsen wrote a post and created
  a video describing a [procedure][news98 sas] for a trustless exchange
  of coins using only two transactions.  The protocol has several
  advantages over earlier coinswap designs: it requires less block space, it
  saves on transaction fees, it only requires consensus-enforced
  timelocks on one of the chains in a cross-chain swap, and it doesn't
  depend on any new security assumptions or Bitcoin consensus changes.
  If taproot is adopted, swaps can be made even more privately and
  efficiently.

- **Coinswap implementation:** Chris Belcher [posted][belcher coinswap1]
  a design for a full-featured coinswap implementation.  His [initial
  post][coinswap design] included the history of the coinswap idea,
  suggested ways the multisig conditions needed for coinswap could be
  disguised as more common transaction types, proposed using a market
  for liquidity (like JoinMarket already does), described splitting and
  routing techniques to reduce privacy losses from amount correlation or
  spying participants, suggested combining coinswap with [payjoin][topic
  payjoin], and discussed some of the backend requirements for the
  system.  Additionally, he compared coinswap to other privacy
  techniques such as using LN, [coinjoin][topic coinjoin], payjoin, and
  payswap.  The proposal received a [significant amount][belcher
  coinswap2] of [expert discussion][belcher coinswap3] and a number of
  suggestions were integrated into the protocol.  By December, Belcher's
  prototype software was [creating coinswaps][belcher dec8 tweet] on
  testnet that demonstrated their strong lack of linkability.

{:#compact-block-filters}
Since Bitcoin's early days, one of the challenges of developing
lightweight clients with SPV security has been finding a way for the
client to download transactions affecting its wallet without giving the
third party server providing the transactions the ability to track the
wallet's receiving and spending history.  An initial attempt at this was
[BIP37][]-style [bloom filters][topic transaction bloom filtering], but
the way wallets used them ended up providing only [minimal privacy][nick
filter privacy] and created [denial of service risks][bitcoin core
#16152] for the full nodes that served them.  An anonymous developer
posted to the Bitcoin-Dev mailing list in May 2016 suggesting an
alternative construction of a [single bloom filter per block][bfd post]
that all wallets could use.  The idea was quickly [refined][maxwell
gcs], [implemented][neutrino], and [specified][bip157 spec discussion],
becoming the [BIP157][] and [BIP158][] specifications of [compact block
filters][topic compact block filters].  This can significantly improve
the privacy of lightweight clients, although it does increase their
bandwidth, CPU, and memory requirements compared to current popular
methods.  For full nodes, it reduces the DoS risk to that of a simple
bandwidth exhaustion attack, which nodes can already address with
bandwidth throttling options.  Although merged on the server side in
[btcd][btcd #1180] in 2018 and proposed for Bitcoin Core around the same
time, 2020 saw the P2P part of the protocol merged [piecewise][news98
bcc18877] into Bitcoin Core in [May][news100 bcc19010] through
[August][news111 bcc19070], culminating with the ability for a node
operator to opt in to creating and serving compact block filters by
enabling just two configuration options.

<div markdown="1" class="callout" id="releases">
### 2020 summary<br>Major releases of popular infrastructure projects

- [LND 0.9.0-beta][] released in January improved the access control list
  mechanism (“macaroons”), added support for receiving [multipath
  payments][topic multipath payments], added the ability to send
  additional data in an encrypted onion message, and allowed requesting
  channel close outputs pay a specified address (e.g. your hardware
  wallet).

- [LND 0.10.0-beta][] released in May added support for sending
  multipath payments, allowed funding channels using an external wallet
  via [PSBTs][topic psbt], and began supporting the creation of invoices
  [larger][topic large channels] than 0.043 BTC.

- [Eclair 0.4][] released in May added compatibility with the
  latest version of Bitcoin Core and deprecated the Eclair Node GUI
  (referring users to instead to Phoenix or Eclair Mobile).

- [Bitcoin Core 0.20.0][] released in June began defaulting to bech32
  addresses for RPC users, allowed configuring RPC permissions for
  different users and applications, and added some basic support for
  generating PSBTs in the GUI.

- [C-Lightning 0.9.0][] released in August provided an updated `pay`
  command and an RPC for sending messages over LN.

- [LND 0.11.0-beta][] released in August allowed accepting [large
  channels][topic large channels].

</div>

## June

June was an especially active month for the discovery and discussion of
vulnerabilities, although many problems were discovered earlier or fully
disclosed later.  The notable vulnerabilities included:

- [Overpayment attack on multi-input segwit transactions:][attack overpay segwit]
  in June, Trezor announced Saleem Rashid had discovered a weakness in
  segwit's ability to prevent fee overpayment attacks.  Fee overpayment
  attacks are a well known weakness in Bitcoin's original transaction
  format where signatures don't commit to the value of an input,
  allowing an attacker to trick a dedicated signing device (such as a
  hardware wallet) into spending more money than expected.  Segwit tried
  to eliminate this issue by having each signature commit to the amount
  of the input it spent.  However, Rashid re-discovered a problem
  previously discovered and reported by Gregory Sanders in 2017 where a specially
  constructed transaction with at least two inputs can get around this
  limitation if the user can be tricked into signing two or more
  seemingly identical variations of the same transaction.  Several
  developers felt this was a minor issue---if you can get a user to sign
  twice, you can get them to pay the receiver twice, which also loses
  their money.  Despite that, several hardware wallet manufacturers
  released new firmware that implemented the same protection for segwit
  transactions that they've successfully used to prevent fee
  overpayments in legacy transactions.  In some cases, such as in the
  ColdCard wallet, this security improvement was implemented
  non-disruptively.  In other hardware wallets, the implementation broke
  support with existing workflows, forcing updates to the [BIP174][]
  specification of PSBT and software such as Electrum, Bitcoin Core, and
  HWI.

    ![Fee overpayment attack illustration](/img/posts/2020-06-fee-overpayment-attack.dot.png)

- [LN payment atomicity attack:][attack ln atomicity] as LN developers
  worked to implement the [anchor outputs][topic anchor outputs]
  protocol to eliminate risks related to rapid rises in transaction
  feerates, one of the key contributors to that protocol---Matt
  Corallo---discovered it would enable a new vulnerability.  A malicious
  counterparty could attempt to settle an LN payment ([HTLC][topic
  htlc]) using a low feerate and a [transaction pinning][topic
  transaction pinning] technique that prevents the transaction or a fee
  bump of it from being confirmed quickly.  The delayed confirmation
  causes the HTLC's timeout to expire, allowing the attacker to steal
  back funds they paid to the honest counterparty.  Several solutions
  were [proposed][atomicity attack discussion], from changes to the LN
  protocol, to third-party markets, to [soft fork consensus
  changes][rubin fee sponsorship], but no solution has yet gained any
  significant traction.

- [Fast LN eclipse attacks:][attack time dilation] although Bitcoin
  protocol experts from Satoshi Nakamoto to present have been aware that
  a node isolated from any honest peer can be deceived into accepting
  unspendable bitcoins, a category of problems sometimes called [eclipse
  attacks][topic eclipse attacks], Gleb Naumenko and Antoine Riard
  published a paper in June showing that eclipse attacks could steal
  from LN nodes in as little as two hours---although it would take
  longer to steal from LN nodes that were connected to their own full
  verification nodes.
  The authors suggest the implementation of more methods for avoiding
  eclipse attacks, which did see several positive developments in the
  Bitcoin Core project this year.

- [LN fee ransom:][attack ln fee ransom] René Pickhardt publicly
  disclosed a vulnerability to the Lightning-Dev mailing list that he
  had previously privately reported to LN implementation maintainers
  almost a year earlier.  A malicious channel counterparty can initiate
  up to 483 payments (HTLCs) in an LN channel and then close the
  channel, producing an onchain transaction whose size is about 2% of an
  entire block and which needs to have its transaction fee paid by the
  honest node.  Simple mitigations for this attack were implemented in
  several LN nodes and the use of [anchor outputs][topic anchor outputs]
  is also expected to help, but no comprehensive solution has yet been
  proposed.

- [Concern about HTLC mining incentives:][attack htlc incentives] two
  papers about out-of-band HTLC bribes were discussed in late June and
  early July.  [HTLCs][topic htlc] are contracts used to secure LN
  payments, cross-chain atomic swaps, and several other trustless
  exchange protocols.  They work by giving a receiving user a period of
  time where they have the exclusive ability to claim a payment by
  releasing a secret data string; after the time expires, the spending
  user can take back the payment.  The papers examined the risk that
  the spending user could bribe miners to release the secret data but
  not confirm the transaction containing it, allowing the timelock to
  expire so that the spender would get their money back but still learn
  the secret.  Developer ZmnSCPxj reminded the researchers of a
  well known mechanism that should prevent such problems, a mechanism he
  helped [implement][cl3870] in C-Lightning.  Although the idea
  works in theory, using it will cost users money, so research into
  better solutions is still encouraged.

- [Inventory out-of-memory Denial-of-Service attack (InvDoS):][attack invdos]
  an attack originally discovered in 2018 that affected the Bcoin and
  Bitcoin Core full nodes, which was responsibly disclosed
  and fixed at that time, was reevaluated in June 2020 and found to also
  apply to the Btcd full node.  An attacker could flood a victim's node
  with an excessive number of new transaction announcements (`inv`
  messages), each containing nearly the maximum allowed number of
  transaction hashes. When too many of these announcements were queued,
  the victim's node would run out of memory and crash.  After Btcd fixed
  the problem and users were given time to upgrade, the vulnerability
  was publicly disclosed.

{:#wabisabi}
June also had some good news, with a team of researchers working on the
Wasabi coinjoin implementation [announcing][news102 wasabi] a protocol
named WabiSabi that should allow
trustless server-coordinated coinjoins with arbitrary output values.
This makes it easier to use coordinated coinjoins to send payments,
either between participants in the coinjoin or to non-participants.
Wasabi developers worked on implementing the protocol during the
remainder of the year.

## July

{:#wtxid-announcements}
July saw the [merge][bips933] of the [BIP339][] specification for wtxid
transaction announcements.  Nodes have historically announced the
availability of new unconfirmed transactions for relay using the
transaction's hash-based identifier (txid), but when the proposed segwit
code was being reviewed in 2016, Peter Todd [discovered][todd segwit
review] that a malicious node could get other nodes on the network to
ignore an innocent user's transaction by invalidating witness data in the transaction
that is not part of its txid.  A [quick
fix][Bitcoin Core #8312] was implemented at the time, but it had some
minor downsides and developers knew that the best solution---despite its
[complexities][bcc19569]---was to announce new transactions using their
witness txid (wtxid).  Within a month of BIP339 being added to the BIPs
repository, wtxid announcements were [merged][bcc18044] into Bitcoin
Core.  Although seemingly a minor concern without any obvious effect on
users, wtxid announcements simplify the development of
hoped-for upgrades, such as [package relay][topic package relay].

## August

{:#signet}
After [over][bips900] a [year][bips983] of [development][default signet
discussion], including multiple feedback-driven changes, the [last
major revision][bips947] to the [BIP325][] specification of
[signet][topic signet] was merged in early August.  Signet is a protocol
that allows developers to create public test networks and also the name
of the primary public signet.  Unlike Bitcoin's existing public test
network (testnet), signet blocks must be signed by a trusted party.
This prevents vandalism and other problems that occur because testnet
uses Bitcoin's economic-based consensus convergence mechanism (proof of
work) even though testnet coins have no value.  The ability to
optionally enable signet was finally [added][bcc18267] to Bitcoin Core
in September.

{:#anchor-outputs}
Almost two years after Matt Corallo [first proposed][news24 cpfp carve
out] the [CPFP carve-out mechanism][topic cpfp carve out], the LN
specification was [updated][news112 bolts688] to allow the creation of
[anchor outputs][topic anchor outputs] that use carve outs for security.
Anchor outputs allow a multiparty transaction to be fee bumped even if
one of the parties attempts to use a [transaction pinning][topic
transaction pinning] attack to prevent fee bumps.  The ability to fee
bump transactions even under adversarial conditions allows LN nodes to
accept offchain transactions without worrying about feerates increasing in
the future.  If it later becomes necessary to broadcast that offchain
transaction, the node can choose an appropriate feerate for it at
broadcast time.  This simplifies the LN protocol and improves several
aspects of its security.

<div markdown="1" class="callout" id="optech">
### 2020 summary<br>Bitcoin Optech

In Optech's third year, 10 new member companies joined<!-- Veriphi,
SwanBitcoin, YellowCardIO, Xbtogroup, Bitonic, Fidelity Center for
Applied Technology, AndgoInc, BTSEcom, EdgeWallet, Bitbank_inc -->, we
held a [taproot workshop][] in London,
published 51 weekly newsletters<!-- 78 to 129 -->, added 20 new pages to
our [topics index][], added several new wallets and services to our
[compatibility index][], and published several contributed [blog
posts][optech blog posts] about Bitcoin scaling technology.
</div>

## September

{:#glv-endomorphism}
In a [2011 forum post][finney glv], early Bitcoin contributor Hal Finney
described a method by Gallant, Lambert, and Vanstone (GLV) to reduce the
number of expensive computations needed to verify Bitcoin transaction
signatures. Finney wrote a proof-of-concept implementation, which he
claimed sped up signature verification by around 25%.  Unfortunately,
the algorithm was encumbered by [U.S.  Patent 7,110,538][] and so
neither Finney's implementation nor a later implementation by Pieter
Wuille was distributed to users.  On September 25th, [that patent
expired][news117 patent].  Within a month, the code was [merged][news120
glv] into Bitcoin Core.  For users with the default settings, the speed
improvement will be most apparent during the final part of syncing a new
node or when verifying blocks after a node has been offline for a while.
Finney died in 2014, but we remain grateful for his two decades of work
on making cryptographic technology widely accessible.

{:#patent-alliance}
Square [announced][copa announced] the formation of the Cryptocurrency Open Patent Alliance (COPA) to
coordinate the pooling of patents related to cryptocurrency technology.
Members allow anyone to use their patents freely and, in exchange,
receive the ability to use patents in the pool in defense against patent
aggressors.  As of this writing, the alliance had [18 members][copa
membership]: ARK.io, Bithyve, Blockchain Commons, Blockstack,
Blockstream, Carnes Validadas, Cloudeya Ltd., Coinbase, Foundation
Devices, Horizontal Systems, Kraken, Mercury Cash, Protocol Labs,
Request Network, SatoshiLabs, Square, Transparent Systems, and
VerifyChain.

## October

{:#jamming}
October saw a significant increase in discussion among LN developers
about solving the jamming problem [first described in 2015][russell loop], as well
as related problems.  An LN node can route a payment to itself across a
path of 20 or more hops.  This allows an attacker with 1 BTC to
temporarily lock up 20 BTC or more belonging to other users.  After
several hours of locking other users' money, the attacker can cancel the
payment and receive a complete refund on their fees, making the attack
essentially free.  A related problem is an attacker sending 483 small
payments through a series of channels, where 483 is the maximum number
of pending payments a channel may contain.  In this case, an attacker
with two channels, each with 483 slots, can jam over 10,000 honest
connection slots---again without paying any fees.  A [variety][news120
upfront] of possible solutions were discussed, including *forward upfront
fees* paid from the spender to each node along the path, [backwards
upfront fees][news86 backwards upfront] paid from each payment hop to
the previous hop, a [combination][news122 bidir fees] of both forward
and backwards fees, [nested incremental routing][news119 nested
routing], and [fidelity bonds][news126 routing fibonds].  Unfortunately,
none of the methods discussed received widespread acceptance and so the
problem remains unsolved.

{:.center}
![Illustration of LN liquidity and HTLC jamming attacks](/img/posts/2020-12-ln-jamming-attacks.png)

{:#lnd-disclosures}
Two money-stealing attacks against LND that were discovered and reported
by Antoine Riard in April were [fully disclosed][news121 riard
disclosures] in October.  In one case, LND could be tricked into
accepting invalid data; in the other case, it could be tricked into
disclosing secret data.  Thanks to Riard's responsible disclosure and
the LND team's response, we are unaware of any users who lost funds.
The LN specification was [updated][news123 high-s] for [both][news124
htlc release] problems to help new implementations avoid them.

{:#generic-signmessage}
Over five years after the introduction of the initial segwit proposal,
and three years after its activation, there remains no universal way to
create and verify plain text messages signed using the keys that
correspond to a P2WPKH or P2SH-P2WPKH address.  The problem exists more
generically as well: there's no widely supported way to handle messages
for P2SH, P2WSH, and P2SH-P2WSH addresses either---nor a forward
compatible way that will work for taproot addresses.  The [BIP322][]
proposal for a [generic signmessage][topic generic signmessage] function
is an attempt to fix all of these issues, but it's failed to gain much
traction.  This year saw an additional [request for feedback][news88
signmessage rfh] from its champion, a [simplification][news91
signmessage simplification], and (in October) a nearly [complete
replacement][news118 signmessage update proposal] of its core mechanism.
The [new mechanism][news121 signmessage update bip] makes message
signing potentially compatible with a large amount of existing software
and hardware wallets, as well as the [PSBT][topic psbt] data format, by
allowing the signing of *virtual transactions* that look like real
transactions but which can be safely signed because they aren't valid
according to Bitcoin's consensus rules.  Hopefully, this improvement will
allow generic signmessage to start to receive adoption.

{:#musig2}
Jonas Nick, Tim Ruffing, and Yannick Seurin [published][news120 musig2]
the MuSig2 paper in October describing a new variant of the
[MuSig][topic musig] signature scheme with a two round signing protocol
and no need for a zero-knowledge proof. What's more, the first round
(nonce exchange) can be done at key setup time with a non-interactive
signing variant that could be particularly useful for cold storage and
offchain contract protocols such as LN.

{:#addrv2}
Also in October, Bitcoin Core became the first project to
[merge][bcc19954] an implementation of the [version 2 `addr`
message][topic addr v2].  The `addr` message advertises the network
addresses of potential peers, allowing full nodes to discover new peers
without any centralized coordination.  The original Bitcoin `addr`
message was designed to hold 128-bit IPv6 addresses, which also allowed
it to contain encoded IPv4 addresses and version 2 Tor onion addresses.
After almost 15 years in production, the Tor project deprecated version
2 onion services and will stop supporting them in July 2021.  Newer
version 3 onion addresses are 256 bits, so they're not usable with the
original `addr` messages.  The [BIP155][] upgrade of the `addr` message
provides more capacity for Tor addresses and also makes it possible to use
other anonymity networks that require larger addresses.

## November

{:#lightning-pool}
As mentioned in the February section, one challenge faced in the current
LN network is that users and merchants need channels with incoming
capacity in order to receive funds over LN.  A fully
decentralized solution to that problem could be the dual-funded channels
described earlier.  However, in November, Lightning Labs took a
different track and [announced][news123 lightning pool] a new Lightning
Pool marketplace for buying incoming LN channels.  Some existing node
operators already provide incoming channels, either for free or as a
paid service, but Lightning Pool may be able to use its centrally
coordinated marketplace to make this service more standardized and
competitive.  It's possible this could also be upgraded to work with
dual funded channels when they become available.

## December

{:#ln-offers}
Last year, Rusty Russell published a first draft of a [proposed
specification][bolt12 draft] for LN *offers*, the ability for a spending
node to request an invoice from a receiving node over the onion-routed
LN network.  Although the existing [BOLT11][] provides an invoice
protocol, it doesn't allow for any protocol-level negotiation between
the spender and receiver nodes.  Offers would make it possible for the
nodes to communicate additional information and automate payment steps
that currently require manual intervention or additional tools.  For
example, offers could allow LN nodes to manage recurring payments or
donations by having a spender node request a new invoice each month from
a receiver node.  In December 2020, the first in a series of commits by
Russell to C-Lightning for implementing offers was [merged][news128
offers].

## Conclusion

One of the things we love about summarizing the past year's events is
that every bit of progress is fully realized.  The summary above does
not contain promises about what Bitcoin will do in the future---it lists
only actual accomplishments achieved in the past 12 months.  Bitcoin
contributors have a lot to be proud of in 2020.  We can't wait to see
what they have in store for us in 2021.

*The Optech newsletter will return to its regular Wednesday publication
schedule on January 6th.*

{% include references.md %}
{% include linkers/issues.md issues="8312,524,18038,18861,19109,14582,19743,16152" %}
[2018 summary]: /en/newsletters/2018/12/28/
[2019 summary]: /en/newsletters/2019/12/28/
[`addr` message]: https://btcinformation.org/en/developer-reference#addr
[atomicity attack discussion]: /en/newsletters/2020/06/24/#continued-discussion-about-ln-atomicity-attack
[attack htlc incentives]: /en/newsletters/2020/07/01/#discussion-of-htlc-mining-incentives
[attack invdos]: /en/newsletters/2020/09/16/#inventory-out-of-memory-denial-of-service-attack-invdos
[attack ln atomicity]: /en/newsletters/2020/04/29/#new-attack-against-ln-payment-atomicity
[attack ln fee ransom]: /en/newsletters/2020/06/24/#ln-fee-ransom-attack
[attack overpay segwit]: /en/newsletters/2020/06/10/#fee-overpayment-attack-on-multi-input-segwit-transactions
[attack time dilation]: /en/newsletters/2020/06/10/#time-dilation-attacks-against-ln
[bcc18044]: /en/newsletters/2020/07/29/#bitcoin-core-18044
[bcc18267]: /en/newsletters/2020/09/30/#bitcoin-core-18267
[bcc19569]: /en/newsletters/2020/08/05/#bitcoin-core-19569
[bcc19954]: /en/newsletters/2020/10/14/#bitcoin-core-19954
[belcher coinswap1]: /en/newsletters/2020/06/03/#design-for-a-coinswap-implementation
[belcher coinswap2]: /en/newsletters/2020/08/26/#discussion-about-routed-coinswaps
[belcher coinswap3]: /en/newsletters/2020/09/09/#continued-coinswap-discussion
[belcher dec8 tweet]: https://twitter.com/chris_belcher_/status/1336322923800322049
[bfd post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2016-May/012636.html
[bip157 spec discussion]: /en/newsletters/2018/06/08/#bip157-bip157-bip158-bip158-lightweight-client-filters
[bips900]: /en/newsletters/2020/05/06/#bips-900
[bips933]: /en/newsletters/2020/07/01/#bips-933
[bips947]: /en/newsletters/2020/08/05/#bips-947
[bips983]: /en/newsletters/2020/09/09/#bips-983
[bitcoin core 0.20.0]: /en/newsletters/2020/06/10/#bitcoin-core-0-20-0
[bolt12 draft]: https://github.com/rustyrussell/lightning-rfc/blob/guilt/offers/12-offer-encoding.md
[btcd #1180]: https://github.com/btcsuite/btcd/pull/1180
[cl3870]: /en/newsletters/2020/09/16/#c-lightning-3870
[cl4068]: /en/newsletters/2020/09/30/#c-lightning-4068
[c-lightning 0.9.0]: /en/newsletters/2020/08/05/#c-lightning-0-9-0
[coinswap design]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-May/017898.html
[common ownership heuristic]: https://en.bitcoin.it/wiki/Common-input-ownership_heuristic
[compatibility index]: /en/compatibility/
[copa announced]: /en/newsletters/2020/09/16/#crypto-open-patent-alliance
[copa membership]: /en/newsletters/2020/12/09/#cryptocurrency-open-patent-alliance-copa-gains-new-members
[crypto garage p2p deriv]: /en/newsletters/2020/08/19/#crypto-garage-announces-p2p-derivatives-beta-application-on-bitcoin
[default signet discussion]: /en/newsletters/2020/09/02/#default-signet-discussion
[discreet log contracts]: https://adiabat.github.io/dlc.pdf
[dlc election bet]: https://suredbits.com/settlement-of-election-dlc/
[dlc spec]: https://github.com/discreetlogcontracts/dlcspecs/
[dryja poon sf devs]: https://lightning.network/lightning-network.pdf
[ecdsa]: https://en.wikipedia.org/wiki/Elliptic_Curve_Digital_Signature_Algorithm
[eclair 0.4]: /en/newsletters/2020/05/13/#eclair-0-4
[finney glv]: https://bitcointalk.org/index.php?topic=3238.msg45565#msg45565
[fournier otves]: https://github.com/LLFourn/one-time-VES/blob/master/main.pdf
[joinmarket]: https://github.com/JoinMarket-Org/joinmarket-clientserver
[libsecp256k1]: https://github.com/bitcoin-core/secp256k1
[libsecp256k1-zkp]: https://github.com/ElementsProject/secp256k1-zkp
[lnd 0.10.0-beta]: /en/newsletters/2020/05/06/#lnd-0-10-0-beta
[lnd 0.11.0-beta]: /en/newsletters/2020/08/26/#lnd-0-11-0-beta
[lnd 0.9.0-beta]: /en/newsletters/2020/01/29/#upgrade-to-lnd-0-9-0-beta
[maxwell gcs]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2016-May/012637.html
[musig2 paper]: /en/newsletters/2020/10/21/#musig2-paper-published
[neutrino]: https://github.com/lightninglabs/neutrino
[news100 bcc19010]: /en/newsletters/2020/06/03/#bitcoin-core-19010
[news100 revault arch]: /en/newsletters/2020/06/03/#the-revault-multiparty-vault-architecture
[news101 additional commitment]: /en/newsletters/2020/06/10/#bips-920
[news102 bip85]: /en/newsletters/2020/06/17/#bips-910
[news102 wasabi]: /en/newsletters/2020/06/17/#wabisabi-coordinated-coinjoins-with-arbitrary-output-values
[news104 bips923]: /en/newsletters/2020/07/01/#bips-923
[news107 bcc19109]: /en/newsletters/2020/07/22/#bitcoin-core-19109
[news107 bech32 fives]: /en/newsletters/2020/07/22/#bech32-address-updates
[news109 sapio]: /en/newsletters/2020/08/05/#sapio
[news111 bcc19070]: /en/newsletters/2020/08/19/#bitcoin-core-19070
[news111 uniform tiebreaker]: /en/newsletters/2020/08/19/#proposed-uniform-tiebreaker-in-schnorr-signatures
[news112 bcc14582]: /en/newsletters/2020/08/26/#bitcoin-core-14582
[news112 bolts688]: /en/newsletters/2020/08/26/#bolts-688
[news113 bip340 update]: /en/newsletters/2020/09/02/#bips-982
[news113 witasym]: /en/newsletters/2020/09/02/#witness-asymmetric-payment-channels
[news115 bip340 merge]: /en/newsletters/2020/09/16/#libsecp256k1-558
[news116 payjoin joinmarket]: /en/newsletters/2020/09/23/#joinmarket-0-7-0-adds-bip78-psbt
[news117 patent]: /en/newsletters/2020/09/30/#us-patent-7-110-538-has-expired
[news118 signmessage update proposal]: /en/newsletters/2020/10/07/#alternative-to-bip322-generic-signmessage
[news119 bech32 discussion]: /en/newsletters/2020/10/14/#bech32-addresses-for-taproot
[news119 nested routing]: /en/newsletters/2020/10/14/#incremental-routing
[news119 witasym update]: /en/newsletters/2020/10/14/#updated-witness-asymmetric-payment-channel-proposal
[news120 glv]: /en/newsletters/2020/10/21/#libsecp256k1-830
[news120 musig2]: /en/newsletters/2020/10/21/#musig2-paper-published
[news120 taproot merge]: /en/newsletters/2020/10/21/#bitcoin-core-19953
[news120 upfront]: /en/newsletters/2020/10/21/#more-ln-upfront-fees-discussion
[news121 riard disclosures]: /en/newsletters/2020/10/28/#full-disclosures-of-recent-lnd-vulnerabilities
[news121 signmessage update bip]: /en/newsletters/2020/10/28/#bips-1003
[news122 bidir fees]: /en/newsletters/2020/11/04/#bi-directional-upfront-fees-for-ln
[news122 devsurvey]: /en/newsletters/2020/11/04/#taproot-activation-survey-results
[news123 high-s]: /en/newsletters/2020/11/11/#bolts-807
[news123 lightning pool]: /en/newsletters/2020/11/11/#incoming-channel-marketplace
[news124 htlc release]: /en/newsletters/2020/11/18/#bolts-808
[news125 miner survey]: /en/newsletters/2020/11/25/#website-listing-miner-support-for-taproot-activation
[news126 routing fibonds]: /en/newsletters/2020/12/02/#fidelity-bonds-for-ln-routing
[news127 bech32m research]: /en/newsletters/2020/12/09/#bech32-addresses-for-taproot-and-beyond
[news128 fancy static]: /en/newsletters/2020/12/16/#proposed-improvements-to-static-ln-backups
[news128 offers]: /en/newsletters/2020/12/16/#c-lightning-4255
[news24 cpfp carve out]: /en/newsletters/2018/12/04/#cpfp-carve-out
[news59 bishop idea]: /en/newsletters/2019/08/14/#bitcoin-vaults-without-covenants
[news80 msfa]: /en/newsletters/2020/01/15/#discussion-of-soft-fork-activation-mechanisms
[news81 dlc]: /en/newsletters/2020/01/22/#protocol-specification-for-discreet-log-contracts-dlcs
[news83 alt tiebreaker]: /en/newsletters/2020/02/05/#alternative-x-only-pubkey-tiebreaker
[news83 interactive funding]: /en/newsletters/2020/02/05/#interactive-construction-of-ln-funding-transactions
[news85 blinded paths]: /en/newsletters/2020/02/19/#decoy-nodes-and-lightweight-rendez-vous-routing
[news86 backwards upfront]: /en/newsletters/2020/02/26/#reverse-up-front-payments
[news86 bolts596]: /en/newsletters/2020/02/26/#bolts-596
[news86 large channels]: /en/newsletters/2020/02/26/#bolts-596
[news87 bip340 update1]: /en/newsletters/2020/03/04/#bips-886
[news87 bip340 update]: /en/newsletters/2020/03/04/#updates-to-bip340-schnorr-keys-and-signatures
[news87 exfiltration]: /en/newsletters/2020/03/04/#proposal-to-standardize-an-exfiltration-resistant-nonce-protocol
[news87 taproot generic group]: /en/newsletters/2020/03/04/#taproot-in-the-generic-group-model
[news88 exfiltration]: /en/newsletters/2020/03/11/#exfiltration-resistant-nonce-protocols
[news88 signmessage rfh]: /en/newsletters/2020/03/11/#bip322-generic-signmessage-progress-or-perish
[news89 op_if]: /en/newsletters/2020/03/18/#bitcoin-core-16902
[news8 p2ep]: /en/newsletters/2018/08/14/#pay-to-end-point-p2ep-idea-proposed
[news91 bip340 powerdiff]: /en/newsletters/2020/04/01/#mitigating-differential-power-analysis-in-schnorr-signatures
[news91 signmessage simplification]: /en/newsletters/2020/04/01/#proposed-update-to-bip322-generic-signmessage
[news92 cl3600]: /en/newsletters/2020/04/08/#c-lightning-3600
[news92 ecdsa adaptor]: /en/newsletters/2020/04/08/#work-on-ptlcs-for-ln-using-simplified-ecdsa-adaptor-signatures
[news93 super keychain]: /en/newsletters/2020/04/15/#proposal-for-using-one-bip32-keychain-to-seed-multiple-child-keychains
[news94 bishop vault]: /en/newsletters/2020/04/22/#vaults-prototype
[news94 btcpay payjoin]: /en/newsletters/2020/04/22/#btcpay-adds-support-for-sending-and-receiving-payjoined-payments
[news95 revault]: /en/newsletters/2020/04/29/#multiparty-vault-architecture
[news96 bcc18038]: /en/newsletters/2020/05/06/#bitcoin-core-18038
[news96 bip340 nonce update]: /en/newsletters/2020/05/06/#bips-893
[news96 bip340 update]: /en/newsletters/2020/05/06/#bips-893
[news97 additional commitment]: /en/newsletters/2020/05/13/#request-for-an-additional-taproot-signature-commitment
[news98 bcc18877]: /en/newsletters/2020/05/20/#bitcoin-core-18877
[news98 sas]: /en/newsletters/2020/05/20/#two-transaction-cross-chain-atomic-swap-or-same-chain-coinswap
[news99 bcc18861]: /en/newsletters/2020/05/27/#bitcoin-core-18861
[nick filter privacy]: https://jonasnick.github.io/blog/2015/02/12/privacy-in-bitcoinj/
[optech blog posts]: /en/blog/
[rubin fee sponsorship]: /en/newsletters/2020/09/23/#transaction-fee-sponsorship
[russell loop]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2015-August/000135.html
[rv routing]: /en/newsletters/2018/11/20/#hidden-destinations
[somsen sas post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-May/017846.html
[somsen sas video]: https://www.youtube.com/watch?v=TlCxpdNScCA
[##taproot-activation]: /en/newsletters/2020/07/22/#taproot-activation-discussions
[taproot workshop]: /workshops/#taproot-workshop
[todd segwit review]: https://petertodd.org/2016/segwit-consensus-critical-code-review#peer-to-peer-networking
[topics index]: /en/topics/
[tx origin wiki]: https://en.bitcoin.it/wiki/Privacy#Traffic_analysis
[u.s. patent 7,110,538]: https://patents.google.com/patent/US7110538B2/en
