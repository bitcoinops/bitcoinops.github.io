---
title: 'Bulletin Hebdomadaire Bitcoin Optech #308'
permalink: /fr/newsletters/2024/06/21/
name: 2024-06-21-newsletter-fr
slug: 2024-06-21-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine annonce la divulgation d'une vulnérabilité
affectant d'anciennes versions de LND et résume la discussion continue sur
les PSBT pour les paiements silencieux. Nous incluons également nos sections
régulières décrivant les mises à jour des clients et des services,
les nouvelles versions et les versions candidates, ainsi que les changements
apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Divulgation d'une vulnérabilité affectant d'anciennes versions de LND :** Matt
  Morehouse a [divulgué][morehouse onion] sur Delving Bitcoin une
  vulnérabilité affectant les versions de LND antérieures à 0.17.0. LN relaie
  les instructions de paiement et les [messages en onion][topic onion messages] en utilisant
  des paquets chiffrés en onion qui contiennent plusieurs charges utiles chiffrées.
  Chaque charge utile est précédée de sa longueur, qui [depuis 2019][news58
  variable onions] a été [autorisée][bolt4] à être de n'importe quelle taille jusqu'à 1 300
  octets pour les paiements. Les messages en onion, introduits plus tard, peuvent
  mesurer jusqu'à 32 768 octets. Cependant, le préfixe de taille de la charge utile utilise un type de
  données qui permet d'indiquer une taille jusqu'à 2<sup>64</sup> octets.

  LND acceptait une taille indiquée pour la charge utile jusqu'à 4 gigaoctets et allouerait
  cette quantité de mémoire avant de traiter davantage de charge utile.
  Cela suffit pour épuiser la mémoire de certains nœuds LND, entraînant leur
  crash ou leur terminaison par le système d'exploitation, et cela pourrait être
  utilisé pour faire crasher des nœuds ayant plus de mémoire en envoyant plusieurs
  paquets en onion construits de cette manière. Un nœud LN en crash ne peut pas envoyer
  des transactions sensibles au temps qui peuvent être nécessaires pour protéger ses fonds,
  potentiellement conduisant au vol de fonds.

  La vulnérabilité a été corrigée en réduisant l'allocation mémoire maximale
  à 65 536 octets.

  Toute personne exploitant un nœud LND devrait mettre à niveau vers la version 0.17.0 ou
  supérieure. La mise à niveau vers la dernière version (0.18.0 au moment de
  la rédaction) est toujours recommandée.

- **Discussion continue sur les PSBT pour les paiements silencieux :** plusieurs
  développeurs ont discuté de l'ajout du support pour coordonner l'envoi
  de [paiements silencieux][topic silent payments] en utilisant des [PSBT][topic
  psbt]. Depuis notre [résumé précédent][news304 sp-psbt], la discussion a
  porté sur l'utilisation d'une technique où chaque signataire génère une _partage ECDH_
  et une preuve compacte qu'ils ont généré leur part correctement.
  Celles-ci sont ajoutées à la section d'entrée du PSBT. Lorsque les parts de
  tous les signataires sont reçues, elles sont combinées avec la clé de scan de paiement silencieux du
  destinataire pour produire la clé réelle placée dans le script de sortie
  (ou plusieurs clés avec plusieurs scripts de sortie si plusieurs paiements silencieux sont effectués
  dans la même transaction).

  Une fois que les scripts de sortie de la transaction sont connus, chaque signataire
  re-traite le PSBT pour ajouter leurs signatures. Cela résulte en un
  processus en deux étapes pour la signature complète du PSBT (en plus de tout
  autre tour requis par d'autres protocoles, tels que [MuSig2][topic
  musig]). Cependant, s'il n'y a qu'un seul signataire pour l'ensemble de la transaction,
  (par exemple, le PSBT est envoyé à un seul appareil de signature matériel), le processus
  de signature peut être complété en un seul tour.

  Tous les participants actifs à la discussion au moment de la rédaction semblent globalement d'accord
  sur cette approche, bien que la discussion sur les cas particuliers continue.

## Modifications apportées aux services et aux logiciels clients

*Dans cette rubrique mensuelle, nous mettons en évidence les mises à jour
intéressantes des portefeuilles et services Bitcoin.*

- **Casa ajoute le support des descripteurs :**
  Dans un [billet de blog][casa blog], le fournisseur de service de multisig Casa a annoncé le support
  pour les [descripteurs de script de sortie][topic descriptors].

- **Specter-DIY v1.9.0 publié :**
  La version [v1.9.0][specter-diy v1.9.0] ajoute le support pour taproot [miniscript][topic
  miniscript] et une application [BIP85][], entre autres changements.

- **Outil d'analyse en temps constant cargo-checkct annoncé :**
  Un [billet de blog][ledger cargo-checkct blog] de Ledger a annoncé [cargo-checkct][cargo-checkct
  github], un outil qui évalue si les bibliothèques cryptographiques Rust s'exécutent en temps
  constant pour éviter les [attaques par analyse de temps][topic side channels].

- **Jade ajoute le support de miniscript :**
  Le firmware du dispositif de signature matériel Jade [supporte maintenant][jade tweet] miniscript.

- **Annonce de l'implémentation Ark :**
  Ark Labs a [annoncé][ark labs blog] plusieurs initiatives autour du [protocole Ark][topic ark]
  incluant une [implémentation Ark][ark github] et des [ressources pour développeurs][ark developer
  hub].

- **Annonce de la beta de Volt Wallet :**
  [Volt Wallet][volt github] supporte les descripteurs, [taproot][topic taproot], [PSBT][topic psbt],
  et d'autres BIPs, plus Lightning.

- **Joinstr ajoute le support d'electrum :**
  Le logiciel [Coinjoin][topic coinjoin] [joinstr][news214 joinstr] a ajouté un [plugin
  electrum][joinstr blog].

- **Bitkit v1.0.1 publié :**
  Bitkit a [annoncé][bitkit blog] que ses applications mobiles Bitcoin et Lightning en auto-garde sont
  sorties de la beta et sont disponibles sur les magasins d'applications mobiles.

- **Annonce de l'alpha de Civkit :**
  [Civkit][civkit tweet] est un marché de trading P2P construit sur nostr et le Lightning Network.

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets d’infrastructure
Bitcoin. Veuillez envisager de passer aux nouvelles versions ou d’aider à tester
les versions candidates.*

- [Bitcoin Core 26.2rc1][] est un candidat à la sortie pour une version de maintenance de Bitcoin
  Core pour les utilisateurs qui ne peuvent pas mettre à niveau vers la dernière [version 27.1][bcc
  27.1].

## Changements notables dans le code et la documentation

_Changes récents notables dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #29325][] commence à stocker les versions de transaction comme des entiers non
  signés. Depuis la version originale de Bitcoin 0.1, elles étaient stockées comme des entiers signés.
  Le soft fork [BIP68][] a commencé à les traiter comme des entiers non signés, mais au moins une
  réimplémentation de Bitcoin a échoué à reproduire ce comportement, conduisant à un possible échec de
  consensus (voir le [Bulletin #286][news286 btcd]). En stockant et utilisant toujours les versions de
  transaction comme des entiers non signés, on espère que toute future implémentation de Bitcoin basée
  sur la lecture du code de Bitcoin Core utilisera le type correct.

- [Eclair #2867][] définit un nouveau type de `EncodedNodeId` à assigner pour les portefeuilles
  mobiles dans un [chemin aveuglé][topic rv routing]. Cela permet à un fournisseur de portefeuille
  d'être notifié que le nœud suivant est un dispositif mobile, lui permettant de prendre en compte les
  conditions spécifiques aux mobiles.

- [LND #8730][] introduit une commande RPC `lncli wallet estimatefee` qui reçoit une cible de
  confirmation en entrée et retourne une [estimation de frais][topic fee estimation] pour les
  transactions on-chain en sat/kw (satoshis par unité de kilo-poids) et sat/vbyte.

- [LDK #3098][] met à jour le Rapid Gossip Sync (RGS) de LDK vers la v2, qui étend la v1 en ajoutant
  des champs supplémentaires dans la structure sérialisée. Ces nouveaux champs incluent un octet
  indiquant le nombre de fonctionnalités de nœud par défaut, un tableau de fonctionnalités de nœud, et
  des informations supplémentaires de fonctionnalité ou d'adresse de socket suivant chaque clé
  publique de nœud. Cette mise à jour est distincte de la proposition de mise à jour de gossip
  [BOLT7][] également référencée comme gossip v2.

- [LDK #3078][] ajoute le support pour le paiement asynchrone des factures [BOLT12][topic offers] en
  générant un événement `InvoiceReceived` à la réception si l'option de configuration
  `manually_handle_bolt12_invoices` est définie. Une nouvelle commande
  `send_payment_for_bolt12_invoice` est exposée sur `ChannelManager` pour payer la facture. Cela peut
  permettre au code d'évaluer une facture avant de décider de la payer ou de la rejeter.

- [LDK #3082][] introduit le support de la facture statique BOLT12 (demande de paiement
  réutilisable) en ajoutant une interface de codage et d'analyse, et des méthodes de construction pour
  créer une facture statique BOLT12 en réponse à une `InvoiceRequest` d'une [offre][topic offers].

- [LDK #3103][] commence à utiliser un évaluateur de performance dans les benchmarks basé sur des
  [sondages][topic payment probes] fréquents de chemins de paiement réels. L'espoir est que cela
  résulte en des benchmarks plus réalistes.

- [LDK #3037][] commence à fermer de force les canaux si leur taux de frais est obsolète et trop
  bas. LDK suit continuellement le taux de frais acceptable le plus bas que son [estimateur][topic fee
  estimation] a retourné dans la journée précédente. À chaque bloc, LDK fermera tout canal qui paie un
  taux de frais inférieur au minimum de la veille. L'objectif est "de s'assurer que les taux
  de frais des canaux sont toujours suffisants pour faire confirmer notre transaction d'engagement
  on-chain si nous devons fermer de force".

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2867,8730,3098,3078,3082,3103,3037,29325" %}
[news304 sp-psbt]: /fr/newsletters/2024/05/24/#discussion-sur-les-psbt-pour-les-paiements-silencieux
[news58 variable onions]: /en/newsletters/2019/08/07/#bolts-619
[morehouse onion]: https://delvingbitcoin.org/t/dos-disclosure-lnd-onion-bomb/979
[bcc 27.1]: /fr/newsletters/2024/06/14/#bitcoin-core-27-1
[bitcoin core 26.2rc1]: https://bitcoincore.org/bin/bitcoin-core-26.2/
[news286 btcd]: /fr/newsletters/2024/01/24/#divulgation-de-la-defaillance-de-consensus-corrigee-dans-btcd
[casa blog]: https://blog.casa.io/introducing-wallet-descriptors/
[specter-diy v1.9.0]: https://github.com/cryptoadvance/specter-diy/releases/tag/v1.9.0
[cargo-checkct github]: https://github.com/Ledger-Donjon/cargo-checkct
[ledger cargo-checkct blog]: https://www.ledger.com/blog-cargo-checkct-notre-outil-fait-maison-pour-se-prémunir-contre-les-attaques-de-timing-est-maintenant-open-source
[jade tweet]: https://x.com/BlockstreamJade/status/1790587478287814859
[ark labs blog]: https://blog.arklabs.to/introducing-ark-labs-a-new-venture-to-bring-seamless-and-scalable-payments-to-bitcoin-811388c0001b
[ark github]: https://github.com/ark-network/ark/
[ark developer hub]: https://arkdev.info/docs/
[volt github]: https://github.com/Zero-1729/volt
[news214 joinstr]: /en/newsletters/2022/08/24/#proof-of-concept-coinjoin-implementation-joinstr
[joinstr blog]: https://uncensoredtech.substack.com/p/tutorial-electrum-plugin-for-joinstr
[bitkit blog]: https://blog.bitkit.to/synonym-officially-launches-the-bitkit-wallet-on-app-stores-9de547708d4e
[civkit tweet]: https://x.com/gregory_nico/status/1800818359946154471
