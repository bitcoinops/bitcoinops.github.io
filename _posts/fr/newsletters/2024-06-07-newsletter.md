---
title: 'Bulletin Hebdomadaire Bitcoin Optech #306'
permalink: /fr/newsletters/2024/06/07/
name: 2024-06-07-newsletter-fr
slug: 2024-06-07-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine annonce une divulgation prochaine de
vulnérabilités affectant les anciennes versions de Bitcoin Core, décrit une proposition
de BIP pour une nouvelle version de testnet, résume une proposition pour
des covenants basés sur le chiffrement fonctionnel, examine une mise à jour de
la proposition pour effectuer des opérations arithmétiques 64 bits dans Bitcoin Script, renvoie à un
script pour valider la preuve de travail sur signet avec l'opcode `OP_CAT`, et
examine une proposition de mise à jour de la spécification BIP21 des URI `bitcoin:`.
Sont également incluses nos sections habituelles avec
des annonces de mises à jour et versions candidates, ainsi que les changements
apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Divulgation à venir de vulnérabilités affectant les anciennes versions de Bitcoin Core :**
  plusieurs membres du projet Bitcoin Core ont [discuté][irc disclose]
  sur IRC d'une [politique de divulgation][disclosure policy]
  des vulnérabilités qui ont affecté les anciennes versions de Bitcoin Core. Pour
  les vulnérabilités de faible gravité, les détails seront divulgués environ deux
  semaines après la première version d'un Bitcoin Core qui
  élimine (ou atténue de manière satisfaisante) la vulnérabilité. Pour la plupart
  des autres vulnérabilités, les détails seront divulgués après que la dernière
  version de Bitcoin Core affectée par la vulnérabilité atteigne
  la fin de vie (ce qui est environ un an et demi après sa sortie).
  Pour les vulnérabilités critiques rares, les membres de l'équipe de sécurité de Bitcoin Core
  discuteront en privé du calendrier de divulgation le plus approprié.

  Une fois que ce calendrier sera défini en détail, les
  contributeurs commencerons à divulguer les vulnérabilités affectant
  Bitcoin Core 24.x et précédente. Il est **fortement recommandé** que tous
  les utilisateurs et administrateurs passent à Bitcoin Core 25.0 ou supérieur dans
  les deux prochaines semaines. L'idéal étant d'utiliser la version la plus récente
  possible, soit la dernière version (27.0 au moment de la rédaction) ou
  la dernière version dans une série de versions particulière (par exemple, 25.2 pour la
  série de versions 25.x ou 26.1 pour la série de versions 26.x).

  Comme cela a toujours été notre politique, Optech fournira des résumés de toutes
  les divulgations de sécurité significatives affectant l'un des projets d'infrastructure
  que nous surveillons (ce qui inclut Bitcoin Core).

- **BIP et mise en œuvre expérimentale de testnet4 :** Fabian Jahr
  a [posté][jahr testnet4] sur la liste de diffusion Bitcoin-Dev pour annoncer une
  [proposition de BIP][bips #1601] pour testnet4, une nouvelle version de [testnet][topic
  testnet] conçue pour éliminer certains problèmes avec le testnet3 existant (voir le [Bulletin
  #297][news297 testnet]). Jahr renvoie également à
  une [pull request][bitcoin Core #29775] de Bitcoin Core avec une proposition de mise en œuvre. Testnet4 a
  deux différences notables par rapport à testnet3 :

  - *Moins de retours à la difficulté-1 :* il était facile (accidentellement ou
    délibérément) de réduire une période entière de 2 016 blocs à la
    difficulté minimale (difficulté-1) en minant le dernier bloc d'une
    période avec un horodatage de plus de 20 minutes après l'avant-dernier
    bloc. Désormais, la difficulté d'une période ne peut être ajustée qu'à la baisse, bien qu'il soit
    toujours possible d'exploiter tous les blocs individuels, à l'exception du premier bloc d'une
    nouvelle période, en difficulté-1 s'ils ont un horodatage plus de 20 minutes après le bloc précédent.

  - *Correction du time warp :* il était possible sur testnet3 (et également sur mainnet) de produire
    des blocs significativement plus rapidement qu'une fois toutes les 10 minutes sans augmenter la
    difficulté en exploitant l'[attaque time warp][topic time warp]. Testnet4 implémente maintenant la
    solution au time warp qui a été proposée dans le cadre du soft fork de [nettoyage du
    consensus][topic consensus cleanup] pour mainnet.

  Le BIP draft mentionne également quelques idées supplémentaires et alternatives pour testnet4 qui
  ont été discutées mais non utilisées.

- **Covenants de chiffrement fonctionnel :** Jeremy Rubin a [publié][rubin fe post] sur Delving
  Bitcoin son [papier][rubin fe paper] concernant l'utilisation théorique du [chiffrement fonctionnel][] pour
  ajouter une gamme complète de comportements de [covenant][topic covenants] à Bitcoin sans
  besoin de changements de consensus. Fondamentalement, cela nécessiterait que les utilisateurs des
  covenants fassent confiance à un tiers, bien que cette confiance puisse être distribuée entre
  plusieurs parties où une seule d'entre elles aurait besoin d'avoir agi honnêtement à un moment
  donné.

  Le chiffrement fonctionnel permettrait essentiellement la création d'une clé publique qui correspondrait
  à un programme particulier. Une partie qui pourrait satisfaire le programme serait capable de créer
  une signature qui correspondrait à la clé publique (sans jamais découvrir une clé privée
  correspondante).

  Rubin note que cela a un avantage sur les propositions de covenant existantes en ce que toutes les
  opérations (à l'exception de la vérification de la signature résultante) se produisent off-chain
  et aucune donnée (à l'exception de la clé publique et de la signature) n'a besoin d'être publiée on-chain
  C'est toujours plus privé et économisera souvent de l'espace. Plusieurs programmes de
  covenant peuvent être utilisés dans le même script en effectuant plusieurs vérifications de
  signature.

  Outre le besoin d'une configuration de confiance, Rubin décrit l'autre inconvénient majeur du
  chiffrement fonctionnel comme étant une "cryptographie sous-développée qui
  rend son utilisation actuellement peu pratique".

- **Mises à jour de la proposition de soft fork pour l'arithmétique 64 bits :** Chris Stewart a
  [publié][stewart 64bit] sur Delving Bitcoin pour annoncer une mise à jour de sa proposition
  précédente d'ajouter la capacité de travailler avec des nombres 64 bits dans Bitcoin Script (voir
  les Bulletins [#285][news285 64bit] et [#290][news290 64bit]). Les principaux changements sont :

  - *Mise à jour des opcodes existants :* au lieu d'ajouter de nouveaux opcodes comme `OP_ADD64`, les
    opcodes existants (par exemple, `OP_ADD`) sont mis à jour pour fonctionner avec des nombres 64 bits.
    Étant donné que l'encodage pour les grands nombres est différent de celui actuellement utilisé pour
    les petits nombres, les fragments de script qui sont mis à niveau pour utiliser de grands nombres
    peuvent nécessiter d'être révisés ; Stewart donne l'exemple de `OP_CHECKLOCKTIMEVERIFY` qui doit
    maintenant prendre un paramètre de 8 octets plutôt qu'un paramètre de 5 octets.

  - *Le résultat inclut un booléen :* une opération réussie place non seulement le résultat sur la
    pile, mais aussi un booléen sur la pile qui indique que l'opération a été réussie. Une raison
    courante pour laquelle une opération pourrait échouer est parce que le résultat est plus grand que
    64 bits, dépassant la taille du champ. Le code peut utiliser `OP_VERIFY` pour s'assurer que
    l'opération a été réussie.

    Anthony Towns [a répondu][towns 64bit] en plaidant pour une approche alternative
    où les opcodes par défaut échouent en cas de dépassement de capacité,
    plutôt que de nécessiter que les scripts vérifient en plus que les opérations ont été réussies.
    Pour les cas où il pourrait être utile de tester si une opération pourrait
    entraîner un dépassement de capacité, de nouveaux opcodes comme `ADD_OF` seraient disponibles.

- **Script `OP_CAT` pour valider la preuve de travail :** Anthony Towns
  [a posté][towns powcat] sur Delving Bitcoin à propos d'un script pour
  [signet][topic signet] qui utilise [OP_CAT][topic op_cat] pour permettre
  à quiconque de dépenser des pièces envoyées au script en utilisant la preuve de travail (PoW).
  Cela peut être utilisé comme un faucet de signet-bitcoin décentralisé : quand un
  mineur ou un utilisateur obtient des bitcoins signet en excès, ils les envoient au script.
  Lorsqu'un utilisateur souhaite obtenir plus de bitcoins signet, il recherche dans l'ensemble UTXO
  les paiements au script, génère une PoW, et crée une transaction
  qui utilise leur PoW pour réclamer les pièces.

  Le post de Towns décrit le script et la motivation de plusieurs
  choix de conception.

- **Mise à jour proposée pour le BIP21 :** Matt Corallo [a posté][corallo bip21] sur
  la liste de diffusion Bitcoin-Dev à propos de la mise à jour de la spécification [BIP21][]
  pour l'URI `bitcoin:`. Comme discuté précédemment (voir
  le [Bulletin #292][news292 bip21]), presque tous les portefeuilles Bitcoin utilisent le schéma URI
  différemment de ce qui était spécifié, et des changements supplémentaires dans les protocoles de
  facturation entraîneront probablement des changements supplémentaires dans
  l'utilisation du BIP21. Les principaux changements dans la [proposition][bips #1555]
  incluent :

  - *Plus que base58check :* BIP21 s'attend à ce que chaque adresse Bitcoin utilise
    l'encodage base58check, mais cela n'est utilisé que pour les adresses héritées pour
    les sorties P2PKH et P2SH. Les sorties modernes utilisent [bech32][topic bech32]
    et bech32m. Les paiements futurs seront reçus aux adresses de [paiement silencieux][topic silent
    payments] et le protocole [offres][topic offers] de LN, qui seront très certainement utilisés comme
    charge utile de BIP21.

  - *Corps vide :* BIP21 exige actuellement qu'une adresse Bitcoin soit fournie dans
    la partie corps de la charge utile, avec des paramètres de requête fournissant
    des informations supplémentaires (telles qu'un montant à payer). Les nouveaux protocoles de
    paiement, comme le [protocole de paiement BIP70][topic bip70 payment protocol], ont spécifié de
    nouveaux paramètres de requête à utiliser (voir
    [BIP72][]), mais les clients qui ne comprenaient pas le paramètre
    se contentaient d'utiliser l'adresse dans le corps. Dans certains cas,
    les destinataires peuvent ne pas vouloir revenir à l'un des types d'adresses de base
    (base58check, bech32 ou bech32m), comme les utilisateurs soucieux de leur vie privée utilisant des
    paiements silencieux. La mise à jour proposée permet au champ du corps d'être vide.

  - *Nouveaux paramètres de requête :* la mise à jour décrit trois nouvelles clés :
    `lightning` pour les factures [BOLT11][] (actuellement utilisées), `lno` pour les offres LN
    (proposées), et `sp` pour les paiements silencieux (proposés). Elle décrit également comment les
    clés pour les futurs paramètres devraient être nommées.

  Corallo note dans son post que les changements sont sûrs pour tous les cas connus
  Les logiciels déployés comme portefeuilles ignoreront ou rejetteront tout URI `bitcoin:` qu'ils ne
  peuvent pas analyser avec succès.

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets
d'infrastructure Bitcoin. Veuillez envisager de passer aux nouvelles
versions ou d'aider à tester les versions candidates.*

- [Core Lightning 24.05rc2][] est un candidat à la version pour la prochaine version majeure de
  cette populaire implémentation de nœud LN.

- [Bitcoin Core 27.1rc1][] est un candidat à la version pour une version de maintenance de
  l'implémentation de nœud complet prédominante.

### Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core
lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust
Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo], [Propositions
d'Amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips
repo], [Inquisition Bitcoin][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Core Lightning #7252][] change le comportement de `lightningd` pour ignorer le paramètre
  `ignore_fee_limits` lors d'une fermeture de canal coopérative. Cela corrige un problème où un nœud
  qui ouvre des canaux Core Lightning (CLN) paie trop de frais lorsque la contrepartie est un nœud LDK.
  Dans ce scénario, lorsque le nœud non-ouvreur LDK (Alice) initie une fermeture de canal coopérative
  et commence la négociation des frais, le nœud ouvreur CLN (Bob) répond que les frais peuvent être
  n'importe quoi entre `min_sats` et `max_channel_size` en raison du paramètre `ignore_fee_limits`.
  LDK [choisira][ldk #1101] "toujours le montant le plus élevé autorisé" (contrairement à la
  spécification des BOLTs), donc Bob choisit la limite supérieure, et Alice accepte, ce qui amènera
  Alice à diffuser une transaction avec des frais considérablement surévalués.

- [LDK #2931][] améliore les journaux lors de la recherche de chemin pour inclure des données
  supplémentaires sur les canaux directs, par exemple, s'ils sont manquants, leur montant minimum
  [HTLC][topic htlc], et leur montant maximum HTLC. L'ajout de journaux vise à mieux dépanner les
  problèmes de routage en fournissant une visibilité sur la liquidité disponible et les limitations de
  chaque canal.

- [Rust Bitcoin #2644][] ajoute HKDF (HMAC (Hash-based Message Authentication Code)
  Extract-and-Expand Key Derivation Function) au composant `bitcoin_hashes` pour implémenter
  [BIP324][] dans Rust Bitcoin. HKDF est utilisé pour dériver des clés cryptographiques à partir d'une
  source de matériel de clé de manière sécurisée et standardisée. BIP324 (également connu sous le nom
  de [transport P2P v2][topic v2 p2p transport]) est une méthode permettant aux nœuds Bitcoin de
  communiquer les uns avec les autres sur des connexions cryptées (activées par défaut dans Bitcoin
  Core).

- [BIPs #1541][] ajoute [BIP431][] avec une spécification des transactions Topologically Restricted
  Until Confirmation ([TRUC][topic v3 transaction relay]) (transactions v3) qui sont un sous-ensemble
  de transactions standard avec des règles supplémentaires conçues pour permettre le
  [remplacement de transaction][topic rbf] tout en minimisant le coût pour surmonter les attaques de
  [transaction-pinning][topic transaction pinning].

- [BIPs #1556][] ajoute [BIP337][] avec une spécification des _transactions compressées_, un
  protocole de sérialisation pour compresser les transactions bitcoin afin de réduire leur taille
  jusqu'à 50%. Elles sont pratiques pour la transmission à faible bande passante comme par satellite,
  radio HAM, ou à travers la stéganographie. Deux commandes RPC sont proposées :
  `compressrawtransaction` et `decompressrawtransaction`. Voir le Bulletin [#267][news267 bip337]
  pour une explication plus détaillée du BIP337.

- [BLIPs #32][] ajoute [BLIP32][] décrivant comment les instructions de paiement Bitcoin lisibles
  par l'homme basées sur une proposition DNS (voir le [Bulletin #290][news290 omdns]) peuvent être utilisées
  avec [les messages en onion][topic onion messages] pour permettre l'envoi de paiements à une adresse
  telle que `bob@example.com`. Par exemple, Alice donne instruction à son client LN de payer Bob. Son
  client peut ne pas être capable de résoudre de manière sécurisée les adresses DNS directement, mais
  il peut utiliser un message en onion pour contacter l'un de ses pairs qui annonce un service de
  résolution DNS. Le pair récupère l'enregistrement DNS TXT pour l'entrée `bob` à `example.com` et
  place les résultats ainsi qu'une signature [DNSSEC][] dans une réponse de message en onion à Alice.
  Alice vérifie l'information et l'utilise pour demander une facture à Bob en utilisant le protocole
  [offres][topic offers].

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30"
%}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="7252,2931,2644,1541,1556,32,1601,29775,1555,1101" %}
[rubin fe paper]: https://rubin.io/public/pdfs/fedcov.pdf
[core lightning 24.05rc2]: https://github.com/ElementsProject/lightning/releases/tag/v24.05rc2
[news290 omdns]: /fr/newsletters/2024/02/21/#instructions-de-paiement-bitcoin-lisibles-par-l-homme-basees-sur-dns
[dnssec]: https://en.wikipedia.org/wiki/Domain_Name_System_Security_Extensions
[jahr testnet4]: https://mailing-list.bitcoindevs.xyz/bitcoindev/a6e3VPsXJf9p3gt_FmNF_Up-wrFuNMKTN30-xCSDHBKXzXnSpVflIZIj2NQ8Wos4PhQCzI2mWEMvIms_FAEs7rQdL15MpC_Phmu_fnR9iTg=@protonmail.com/
[news297 testnet]: /fr/newsletters/2024/04/10/#discussion-sur-la-reinitialisation-et-la-modification-du-testnet
[rubin fe post]: https://delvingbitcoin.org/t/fed-up-covenants/929
[chiffrement fonctionnel]: https://en.wikipedia.org/wiki/Functional_encryption
[stewart 64bit]: https://delvingbitcoin.org/t/64-bit-arithmetic-soft-fork/397/49
[towns 64bit]: https://delvingbitcoin.org/t/64-bit-arithmetic-soft-fork/397/50
[news285 64bit]: /fr/newsletters/2024/01/17/#proposition-de-soft-fork-pour-l-arithmetique-sur-64-bits
[news290 64bit]: /fr/newsletters/2024/02/21/#discussion-continue-sur-l-arithmetique-64-bits-et-l-opcode-op-inout-amount
[towns powcat]: https://delvingbitcoin.org/t/proof-of-work-based-signet-faucet/937
[corallo bip21]: https://mailing-list.bitcoindevs.xyz/bitcoindev/93c14d4f-10f3-48af-9756-7e39d61ba3d4@mattcorallo.com/
[news292 bip21]: /fr/newsletters/2024/03/06/#mise-a-jour-des-uri-bitcoin-de-bip21
[irc disclose]: https://bitcoin-irc.chaincode.com/bitcoin-core-dev/2024-06-06#1031717;
[disclosure policy]: https://gist.github.com/darosior/eb71638f20968f0dc896c4261a127be6
[Bitcoin Core 27.1rc1]: https://bitcoincore.org/bin/bitcoin-core-27.1/
[news289 v3]: /fr/newsletters/2024/02/14/#bitcoin-core-28948
[news296 v3]: /fr/newsletters/2024/04/03/#bitcoin-core-29242
[news305 v3]: /fr/newsletters/2024/05/31/#bitcoin-core-29873
[news267 bip337]: /fr/newsletters/2023/09/06/#compression-des-transactions-bitcoin
