---
title: 'Bulletin Hebdomadaire Bitcoin Optech #408'
permalink: /fr/newsletters/2026/06/05/
name: 2026-06-05-newsletter-fr
slug: 2026-06-05-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume des idées pour rendre le chiffrement de transport BIP324 résistant aux ordinateurs quantiques et décrit
une proposition visant à standardiser les charges utiles de signature basées sur des QR codes pour les portefeuilles miniscript. Sont
également incluses nos rubriques habituelles résumant les propositions et discussions sur la modification des règles de consensus de
Bitcoin, annonçant de nouvelles versions et versions candidates, et décrivant des changements notables dans les logiciels d'infrastructure
Bitcoin populaires.

## Nouvelles

- **Une voie post-quantique pour BIP324** : Olaoluwa Osuntokun [a posté][pq bip324 ml] sur la mailing list Bitcoin-Dev ses réflexions sur
  les mises à niveau possibles nécessaires pour rendre [BIP324][] résistant aux ordinateurs quantiques. BIP324 a introduit le [chiffrement
  de transport][topic v2 p2p transport] pour le protocole P2P, permettant aux pairs d'échanger des messages sur le réseau avec une
  confidentialité et une sécurité améliorées, et il est conçu de telle façon que la poignée de main initiale et l'ensemble du trafic
  paraissent complètement aléatoires pour un observateur externe. Selon Osuntokun, modifier le protocole P2P ne nécessite pas un accord
  généralisé comme le fait une modification du consensus, et pourrait constituer une première étape plus facile pour rendre Bitcoin
  résistant aux ordinateurs quantiques.

  Avant de proposer un BIP formel, Osuntokun a invité à discuter de deux principaux points de conception. Le premier concerne le [mécanisme
  d'encapsulation de clé][wiki kem] (KEM) à utiliser, soit une approche hybride, soit une approche purement post-quantique, les deux tirant
  parti d'une nouvelle primitive appelée Module-Lattice-based KEM (ML-KEM). Le second point de conception traite de la question de savoir si
  la poignée de main initiale doit rester indiscernable d'une chaîne d'octets aléatoire ou non.

  Sur le premier point, l'auteur a précisé qu'une approche hybride, combinant l'algorithme ECDH actuel et ML-KEM, pourrait fournir de
  meilleures garanties, puisqu'elle offrirait une protection au cas où l'un des deux algorithmes serait compromis. En effet, bien qu'ECDH
  puisse être cassé par un futur ordinateur quantique cryptographiquement pertinent (CRQC), les algorithmes sûrs face au quantique n'ont pas
  encore été éprouvés au combat et pourraient encore échouer à cause de défauts mathématiques.

  Sur le second point, Osuntokun a proposé des alternatives possibles, au cas où l'exigence d'une poignée de main indiscernable d'une chaîne
  d'octets aléatoire doive être maintenue. La première approche utiliserait d'abord la poignée de main BIP324 actuelle pour ouvrir un canal
  classique qui serait utilisé pour négocier le canal post-quantique. Une autre approche, fondée sur Outer Encrypts Inner Nested Combiner
  (OEINC), utiliserait un KEM externe pour chiffrer un autre KEM interne, obtenant ainsi un canal post-quantique en une seule étape.

- **Discussion sur les charges utiles de signature par QR pour les portefeuilles miniscript** : Pyth [a posté][pyth delving qr] sur Delving
  Bitcoin une proposition visant à standardiser les charges utiles de données échangées entre les coordinateurs de portefeuilles et les
  dispositifs de signature isolés par air via des QR codes lors de l'utilisation de politiques de dépense basées sur [miniscript][topic
  miniscript]. Alors que les protocoles existants basés sur les QR gèrent le multisig standard m-sur-n, les politiques variables de
  miniscript nécessitent des capacités supplémentaires que les schémas actuels ne couvrent pas. Sa proposition définit des types de charges
  utiles pour récupérer des xpubs, enregistrer un [descripteur][topic descriptors], vérifier des adresses et signer. Pyth cherche des
  retours de la part des développeurs de dispositifs de signature et de portefeuilles sur les charges utiles proposées.

## Modification du consensus

_Une nouvelle section mensuelle résumant les propositions et discussions sur la modification des règles de consensus de Bitcoin._

- **Preuve de concept de coffre-fort uniquement CTV** : Ademan [a annoncé][ademan delving mccv] sur Delving Bitcoin la version 0.1.0 de son
  projet de [vault][topic vaults] [CTV][topic op_checktemplateverify] ([BIP119][]) appelé [MCCV][mccv] (More Complicated CTV Vault). MCCV
  met en œuvre plusieurs idées sur la façon dont des coffres-forts complets (moins simples que le [simple-ctv-vault][jamesob ctv vault] de
  James O'Beirne, voir le [Bulletin #191][news191 simple vault]) peuvent être construits sans opcodes plus complexes comme `OP_VAULT`
  ([BIP345][]) ou [`OP_CHECKCONTRACTVERIFY`][topic matt] ([BIP443][]). Plus précisément, MCCV utilise un graphe orienté acyclique (DAG) de
  transactions CTV pour implémenter un coffre-fort à UTXO unique qui peut exister pendant de nombreuses interactions avant de devenir
  finalement dépensable par les clés de récupération du coffre-fort. En utilisant un arbre de scripts [taproot][topic taproot] de scripts de
  retrait possibles, chacun avec des montants et des [verrous temporels][topic timelocks] différents, MCCV met en œuvre une limitation de
  débit. L'arbre de scripts contient également des hachages CTV de dépôt qui permettent d'ajouter au coffre-fort des fonds supplémentaires
  de divers montants. MCCV évite l'un des problèmes fondamentaux résolus par les BIPs 345 et 443 de combinaison d'entrées mises en coffre en
  utilisant un unique UTXO de coffre-fort qui est étendu et contracté, plutôt qu'un ensemble d'UTXOs de coffre-fort. Comme toutes les
  conceptions de coffre-fort basées sur CTV, les montants qui peuvent être déposés ou retirés doivent être précis et énumérés à la création,
  ce que les BIPs 345 et 443 n'exigent pas. Cependant, la limitation de débit de MCCV n'est pas pleinement possible dans les coffres-forts
  multi-UTXO. MCCV peut aussi être implémenté avec `OP_TEMPLATEHASH` ([BIP446][]).

- **Discussion sur Lightning post-quantique** : Olaoluwa Osuntokun (roasbeef) [a posté][oo delving ln lbl] sur Delving Bitcoin une analyse
  de ce à quoi un réseau Lightning [post-quantique][topic quantum resistance] pourrait ressembler, couche par couche. Osuntokun a esquissé
  le paysage des cryptosystèmes post-quantiques disponibles et les couches du réseau Lightning afin d'associer les cryptosystèmes à chaque
  primitive cryptographique requise. Lightning post-quantique peut conserver sa structure générale, mais devra probablement abandonner la
  clé de nœud unique sur laquelle il repose actuellement. Aucun cryptosystème ou clé post-quantique unique ne peut fournir toutes les
  primitives requises. Osuntokun a constaté que la cryptographie basée sur les réseaux est la mieux adaptée à certaines fonctions du réseau
  Lightning, y compris l'échange de clés. Il note également qu'en raison de la grande taille des éléments cryptographiques post-quantiques,
  il serait probablement pertinent de continuer à utiliser en parallèle la cryptographie à courbes elliptiques afin de fournir une sécurité
  en cas de faiblesse dans les différents schémas post-quantiques.

- **Théorie des jeux d'une attaque quantique** : Jameson Lopp [a posté][jl delving qag] sur Delving Bitcoin son [article de blog][jl qag]
  sur la théorie des jeux d'une attaque quantique. Lopp décrit les incitations et actions potentielles de divers participants du marché si
  un ordinateur quantique est construit qui peut révéler les clés secrètes Bitcoin à partir des clés publiques. Les scénarios potentiels
  qu'il décrit sont imprévisibles, car des attaquants quantiques pourraient rapidement obtenir l'accès à de grandes quantités de bitcoins
  sans la preuve de travail et l'investissement en capital associés aux autres gros détenteurs.

- **Transactions de 64 octets de BIP54 et usages légitimes potentiels** : Jeremy Rubin [a écrit][jr ml 64] sur la mailing list Bitcoin-Dev
  au sujet d'usages légitimes potentiels pour les transactions dépouillées du témoin de 64 octets. La proposition de [nettoyage du
  consensus][topic consensus cleanup] ([BIP54][]) inclut une modification visant à rendre invalides au niveau du consensus les transactions
  dépouillées du témoin de 64 octets. Cette modification vise à rendre impossible une catégorie de [vulnérabilités d'arbre de Merkle][topic
  merkle tree vulnerabilities] et donc à rendre plus sûre l'implémentation des portefeuilles à vérification simplifiée des paiements et des
  schémas similaires de vérification des paiements basés sur les en-têtes. Parce qu'une transaction de 64 octets peut avoir au plus 1 entrée
  et 1 sortie anyone-can-spend, les auteurs de [BIP54][] avaient considéré qu'elles ne valaient pas la peine d'être protégées. Rubin propose
  plusieurs scénarios potentiels où des protocoles présents ou futurs pourraient faire usage de telles transactions.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires. Veuillez envisager de mettre à niveau vers
les nouvelles versions ou d'aider à tester les versions candidates._

- [Core Lightning 26.06][] est une version majeure de cette implémentation populaire de nœud LN. Elle ajoute de nouvelles RPC `graceful`,
  `sendamount` et `xkeysend`, commence le cycle de dépréciation de `pay` en faveur de `xpay`, et ajoute un support expérimental des preuves
  de paiement [BOLT12][topic offers]. Voir le [journal des modifications][cln 26.06 changelog] pour des détails supplémentaires.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning
BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #35269][] corrige la signature [PSBT][topic psbt] [MuSig2][topic musig] en incluant le nonce public de chaque participant
  dans l'identifiant interne de session de signature MuSig2 de Bitcoin Core. Auparavant, appeler `walletprocesspsbt` plus d'une fois sur le
  même PSBT sans nonce pouvait générer un nouveau nonce public mais le même ID de session interne, déclenchant une assertion destinée à
  empêcher la réutilisation de nonce. Le nouvel identifiant de session distingue les sessions de signature avec des nonces publics
  différents, mais plante toujours si le même nonce semble être réutilisé afin d'empêcher une fuite de clé privée.

- [Bitcoin Core #34644][] ajoute une méthode `submitBlock` à l'interface IPC de minage (voir les Bulletins [#310][news310 mining] et
  [#323][news323 mining]), permettant aux clients [Stratum v2][topic pooled mining] de soumettre un bloc entièrement assemblé pour
  validation et traitement. Cela est utile lorsqu'un déclarateur de tâches Stratum v2 reçoit un bloc résolu pour lequel Bitcoin Core ne
  possède pas d'objet `BlockTemplate` correspondant, ce qui rend la méthode existante `submitSolution` insuffisante (voir le [Bulletin
  #325][news325 ipc]). La nouvelle méthode est similaire à la RPC `submitblock`, mais elle renvoie un résultat booléen et des détails de
  rejet pour les blocs dupliqués, non concluants ou invalides. Contrairement à la RPC, les appelants IPC doivent soumettre un bloc complet,
  y compris le témoin coinbase lorsqu'un engagement de témoin est présent.

- [Bitcoin Core #34198][] corrige un échec de migration affectant de très anciens portefeuilles legacy créés avant l'ajout des
  enregistrements du meilleur bloc du portefeuille en 2011. Il est désormais possible de migrer un portefeuille avec un localisateur de
  meilleur bloc vide vers un portefeuille à [descripteurs][topic descriptors], mais une réanalyse complète de la chaîne est requise avant
  que la migration soit terminée.

- [LND #10813][] supprime le support de la production de services onion [Tor][topic anonymity networks] v2, qui ont été dépréciés dans LND
  0.20 (voir le Bulletin [#375][news375 tor]). L'option dépréciée `tor.v2` est supprimée, mais les adresses v2 sont toujours conservées dans
  les annonces de pairs afin que les messages de gossip existants puissent encore être vérifiés et rediffusés. Les services onion Tor v2
  sont obsolètes depuis octobre 2021 ; les utilisateurs devraient utiliser Tor v3 à la place.

- [Rust Bitcoin #6250][] commence à valider que l'entrée coinbase contient une valeur réservée de témoin de 32 octets chaque fois que la
  transaction coinbase inclut un engagement de témoin, alignant la validation des blocs de rust-bitcoin avec [BIP141][]. Auparavant,
  rust-bitcoin n'effectuait cette vérification que lorsque le bloc contenait d'autres transactions [segwit][topic segwit], de sorte qu'il
  pouvait accepter un bloc avec un engagement de témoin coinbase mais sans valeur réservée de témoin coinbase.

- [BOLTs #1338][] met à jour [BOLT2][] pour exiger des nœuds qu'ils attendent au moins 100 blocs avant d'envoyer `channel_ready` si la
  transaction de financement du canal est une transaction coinbase, empêchant un mineur d'utiliser immédiatement une sortie coinbase
  immature pour ouvrir un canal.

- [BOLTs #1326][] met à jour [BOLT4][] pour permettre aux nœuds finaux, et pas seulement aux nœuds de transfert, de renvoyer les erreurs
  `invalid_onion_version`, `invalid_onion_hmac` ou `invalid_onion_key`. Auparavant, ces erreurs étaient incorrectement placées sous une
  règle que les nœuds finaux ne doivent pas utiliser. La PR clarifie également que les nœuds de transfert ne doivent pas traiter les
  hachages de paiement déjà payés comme le font les destinataires finaux.

{% include snippets/recap-ad.md when="2026-06-09 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="35269,34644,34198,10813,6250,1338,1326" %}

[ademan delving mccv]: https://delvingbitcoin.org/t/ctv-only-vault-concept-v0-1-0-release/2539
[jamesob ctv vault]: https://github.com/jamesob/simple-ctv-vault
[news191 simple vault]: /en/newsletters/2022/03/16/#continued-ctv-discussion
[mccv]: https://github.com/LNHANCE-Expedition/mccv
[oo delving ln lbl]: https://delvingbitcoin.org/t/post-quantum-lightning-layer-by-layer/2479
[jl delving qag]: https://delvingbitcoin.org/t/quantum-attack-game-theory/2524
[jl qag]: https://blog.lopp.net/quantum-attack-game-theory/
[jr ml 64]: https://groups.google.com/g/bitcoindev/c/iCuq6bFKt5Y/m/MCATyQ4zAAAJ
[pq bip324 ml]: https://groups.google.com/g/bitcoindev/c/n_5WuKVYqwI/m/lBooLis3AQAJ
[wiki kem]: https://en.wikipedia.org/wiki/Key_encapsulation_mechanism
[pyth delving qr]: https://delvingbitcoin.org/t/qr-based-signing-flow-payloads-in-miniscript-context/2464
[Core Lightning 26.06]: https://github.com/ElementsProject/lightning/releases/tag/v26.06
[cln 26.06 changelog]: https://github.com/ElementsProject/lightning/blob/v26.06/CHANGELOG.md
[news310 mining]: /fr/newsletters/2024/07/05/#bitcoin-core-30200
[news323 mining]: /fr/newsletters/2024/10/04/#bitcoin-core-30510
[news325 ipc]: /fr/newsletters/2024/10/18/#bitcoin-core-30955
[news375 tor]: /fr/newsletters/2025/10/10/#lnd-10254
