---
title: 'Bulletin Hebdomadaire Bitcoin Optech #432'
permalink: /fr/newsletters/2026/11/20/
name: 2026-11-20-newsletter-fr
slug: 2026-11-20-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume une analyse des paiements de pools de minage décentralisés, décrit la divulgation d'une vulnérabilité
corrigée de déni de service dans Eclair, et renvoie à la poursuite de la discussion sur la question de savoir si le relais des pointes
périmées devrait inclure les données de bloc. Sont également incluses nos sections régulières décrivant les changements récents dans les
services et logiciels clients, annonçant de nouvelles versions et versions candidates, et décrivant les changements notables apportés aux
logiciels populaires d'infrastructure Bitcoin.

## Nouvelles

- **Cadre pour les paiements de pools de minage décentralisés :** Le développeur 7d5x9 a [publié][7d5x9 dcpp] sur Delving Bitcoin une
  analyse de la manière dont les [pools de minage][topic pooled mining] décentralisés peuvent payer les mineurs directement à partir des
  transactions coinbase, ce que la publication appelle des protocoles de paiement coinbase décentralisés (DCPPs). Donner à chaque mineur sa
  propre sortie ne passe pas à l'échelle, car le firmware de minage limite la taille de la transaction coinbase et chaque sortie remplace
  des transactions payant des frais. La publication soutient que lorsqu'un pool a plus de mineurs que de sorties, toute règle classant les
  mineurs par travail permet une _attaque par liste des riches_, où un grand mineur répartit son hashrate entre plusieurs identités qui
  surpassent toujours chacune les plus petits mineurs, les excluant ainsi de la transaction coinbase.

  Selon 7d5x9, les conceptions antérieures ne font que déplacer ce problème. Braidpool le déplace de qui reçoit une sortie à qui contrôle la
  clé à seuil du pool (voir le [Bulletin #340][news340 braidpool]). Pour une sortie coinbase unique payant un [joinpool][topic joinpools]
  avec sorties unilatérales, l'obstacle est que les mineurs font varier la transaction coinbase pour disposer d'espace supplémentaire de
  nonce, de sorte que son txid est inconnu et que les transactions de sortie ne peuvent pas être signées avant qu'un bloc ne soit trouvé.
  7d5x9 pense que cela laisse la sortie contrôlée par une seule clé ou un seuil de clés jusqu'à ce qu'un soft fork permette des signatures
  réassignables, comme celles proposées dans [BIP448][] (voir le [Bulletin #397][news397 bip448]). Dans des esquisses fondées sur des
  [statechains][topic statechains] de style Spark et sur [Ark][topic ark], un attaquant conservant une petite revendication par sous-arbre
  peut bloquer un règlement coopératif peu coûteux, augmentant les coûts des mineurs, bien que la publication considère cela comme moins
  grave pour Ark.

  La publication conclut qu'un joinpool ne décide pas quelles sorties entrent dans la transaction coinbase. Elle y voit deux options : un
  tirage aléatoire pondéré par la valeur (une idée attribuée à Matt Corallo) ou des sorties réservées à des opérateurs désignés.

  LearnBitcoin.com, qui exploitait un nœud P2Pool public, a [examiné][lb p2pool] 2 545 transactions coinbase de P2Pool et a soutenu que la
  seule croissance, même sans attaquant, évincait les petits mineurs car P2Pool augmentait la difficulté des shares des mineurs censés
  gagner moins de 0,001 BTC par bloc. Pour son successeur P2Poolv2, jungly a [suggéré][jungly dcpp] une limite de 16 sorties compte tenu du
  firmware actuel. Steven Roose a [répondu][roose dcpp] qu'il ne voyait aucun schéma valant la peine d'être exploré sans [covenants][topic
  covenants], qui permettraient à une sortie coinbase de s'engager de façon déterministe dans un arbre de transactions Ark qui paie chaque
  mineur utilisant le même serveur Ark.

- **Divulgation d'une vulnérabilité DoS dans Eclair :** rorp a [publié][eclair vuln del] sur Delving Bitcoin la [divulgation
  responsable][topic responsible disclosures] d'une vulnérabilité de déni de service (DoS) par épuisement de mémoire affectant Eclair
  version [0.14.0][eclair 0.14.0] et corrigée en juillet 2026 dans la version [0.14.1][eclair 0.14.1]. Tout pair capable de se connecter à
  un nœud vulnérable pouvait le faire planter, même sans avoir de canal avec lui. Le bogue ne donnait à un attaquant aucun accès direct aux
  fonds, mais faire planter un nœud de manière répétée pouvait mettre en danger les fonds de ses canaux. Les utilisateurs exécutant encore
  la version 0.14.0 devraient mettre à niveau.

  Le vecteur d'attaque exploitait une vérification de taille manquante dans Eclair. Selon [BOLT2][], les messages peuvent être envoyés par
  lots afin d'être traités comme une seule mise à jour logique via le message `start_batch`, qui transporte entre autres champs
  `batch_size`. Selon les spécifications, cette taille doit être au plus `20` et strictement supérieure à `1`. Bien qu'Eclair vérifiait la
  borne supérieure, il n'appliquait pas la borne inférieure.

  Un attaquant aurait pu exploiter cette vulnérabilité en envoyant un message `start_batch` avec `batch_size = 0`, suivi de messages
  `commitment_signed`, qui sont envoyés par lots pendant le [splicing][topic splicing]. Comme le code cessait d'ajouter des messages à son
  lot interne seulement une fois que le nombre de messages reçus atteignait `batch_size` (qui était `0`, donc toujours inférieur au nombre
  de messages reçus), la liste ne cessait jamais de croître, conduisant à un épuisement de la mémoire. La vulnérabilité a été corrigée en
  faisant également vérifier par le code la borne inférieure, comme spécifié dans BOLT2.

- **Poursuite de la discussion sur le relais des pointes périmées :** Antoine Poinsot a [répondu][poinsot staletip] au fil de discussion de
  la liste de diffusion Bitcoin-Dev sur le relais des pointes périmées de [BIP332][] (voir les bulletins [#417][news417 staletip] et
  [#423][news423 staletip]) pour suggérer que les nœuds ne relaient initialement que les en-têtes des blocs périmés. Poinsot a soutenu que
  les en-têtes suffisent pour rendre les blocs périmés observables. Relayer également les données des blocs permet aux nœuds de se
  réorganiser plus rapidement vers une chaîne construite sur un bloc périmé, ce qui augmente le revenu attendu d'un mineur qui continue
  brièvement à miner sur son propre bloc après avoir perdu une course au bloc. Poinsot a [estimé][poinsot staletip2] que cet effet est très
  probablement faible, mais ne mérite pas d'être calculé rigoureusement.

  Anthony Towns a [répondu][towns staletip] que tout mineur qui en bénéficierait peut implémenter lui-même à faible coût le relais des blocs
  périmés. Towns a [estimé][towns staletip2] qu'un pool disposant de 20 % du hashrate du réseau gagne déjà environ 16,1 BTC par an en minant
  sur son propre bloc plutôt que sur un bloc concurrent qu'il a vu en premier à la même hauteur, et que réduire le délai de relais de la
  réorganisation en résultant d'un bloc de cinq secondes à une seconde porterait ce gain à 16,36 BTC. Towns a également soutenu que les
  en-têtes périmés peuvent susciter des inquiétudes, comme un possible [minage égoïste][topic selfish mining], mais que seules les données
  du bloc peuvent les trancher. Poinsot a [convenu][poinsot staletip3] que l'estimation semble couvrir l'effet sur les incitations au minage
  honnête et, bien qu'il voie toujours l'essentiel de la valeur dans les en-têtes, ne voulait pas empêcher le relais des blocs complets.

## Changements dans les services et logiciels clients

*Dans cette rubrique mensuelle, nous mettons en lumière des mises à jour intéressantes des portefeuilles et services Bitcoin.*

- **Liana v16.0 publiée :** [Liana v16.0][liana v16.0] écrit ses sauvegardes chiffrées de [descripteur][topic descriptors] au format
  [BIP138][] (voir le [Bulletin #424][news424 bip138]) et fait de [taproot][topic taproot] la valeur par défaut pour les nouveaux
  portefeuilles.

- **Le firmware COLDCARD ajoute les sauvegardes codex32 :** Coinkite a [annoncé][coldcard 5.6.3] les versions 5.6.3 et 1.5.3Q du firmware
  COLDCARD, qui ajoutent la prise en charge de la génération et de l'importation de secrets [codex32][topic codex32] et du fractionnement du
  portefeuille de l'appareil en deux à neuf parts de Shamir pour une récupération ultérieure. Les versions ajoutent également la prise en
  charge des verrouillages temporels par entrée basés sur la hauteur et l'heure dans les transactions [PSBTv2][topic psbt].

- **Wavelength publié sur mainnet :** Lightning Labs a [annoncé][wavelength mainnet] que Wavelength, sa boîte à outils de paiements
  semblable à [Ark][topic ark] (voir le [Bulletin #415][news415 wavelength]), est disponible sur mainnet en version alpha avec des comptes
  limités à 300 000 sats.

- **Bull Bitcoin rend payjoin par défaut pour les ordres de change :** Bull Bitcoin a [annoncé][bull payjoin blog] que les achats et ventes
  onchain effectués sur sa plateforme de change via le portefeuille Bull Bitcoin Mobile utilisent désormais [payjoin][topic payjoin] par
  défaut (voir le [Bulletin #338][news338 bull]). La version [6.14.0][bull 6.14.0] du portefeuille ajoute également une prise en charge
  expérimentale de l'envoi et de la réception de [silent payments][topic silent payments].

- **Breez SDK ajoute l'envoi silent payment :** La version [0.28.0][breez 0.28.0] du Breez SDK fondé sur Spark ajoute la prise en charge de
  l'envoi vers des adresses [silent payment][topic silent payments].

- **Scanner silent payments pour le plugin Electrum :** Ali Sherief a [annoncé][spscand delving] spscand, un scanner [silent payments][topic
  silent payments] watch-only qui fonctionne avec le plugin d'envoi Electrum présenté dans le [Bulletin #419][news419 sp electrum]. Il peut
  scanner les paiements en utilisant le propre nœud Bitcoin Core de l'utilisateur, un serveur BlindBit, ou un serveur BlindBit combiné avec
  des [filtres de blocs compacts][topic compact block filters] provenant de pairs P2P.

- **Versions de Stratum v2 et adoption par les pools :** L'implémentation de référence [Stratum v2][topic pooled mining] a publié [sv2-apps
  v0.9.0][], qui ajoute la prise en charge de Bitcoin Core 32.x, y compris la soumission des blocs trouvés via son interface IPC, et
  renforce son Job Declarator Client (voir le [Bulletin #384][news384 sv2] pour la couverture précédente). Séparément, MARA Foundation a
  [annoncé][mara sv2] que MARA a miné son premier bloc en utilisant Stratum v2, et Foundry a [annoncé][foundry sv2] qu'elle a commencé à
  tester Stratum v2 sur son pool.

- **Coinswap renommé en OpenSwap :** [OpenSwap v0.2.3][] est la première version sous le nouveau nom de l'implémentation du protocole
  [coinswap][topic coinswap] anciennement appelée Coinswap (voir le [Bulletin #415][news415 coinswap]). Elle ajoute une option de backend de
  serveur Electrum, des swaps qui paient une adresse tierce, et, lorsqu'elle est compilée avec la prise en charge Lightning, des swaps entre
  des fonds onchain et LN via LDK Server (voir le [Bulletin #406][news406 ldk server]).

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires. Veuillez envisager de mettre à niveau vers
les nouvelles versions ou d'aider à tester les versions candidates._

- [Core Lightning 26.12rc1][] est une version candidate pour la prochaine version majeure de cette implémentation populaire de nœud LN. Ce
  sera la première version majeure depuis 26.06 et elle couvre deux cycles de publication. Elle ajoute un outil pour récupérer les sorties
  [HTLC][topic htlc] après la perte de l'état du canal (voir Core Lightning
  #9730 ci-dessous), améliore la recherche de chemins de paiement (voir les
  bulletins [#418][news418 impressions] et [#430][news430 xpay]), et ajoute un support expérimental pour un nouveau protocole de fermeture
  coopérative (voir le [Bulletin #413][news413 simpleclose]). Les notes de version annoncent également que `xpay` remplacera `pay` en 27.03.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning
BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #36757][] corrige une fuite de confidentialité dans la découverte d'adresses via [Tor et I2P][topic anonymity networks].
  Précédemment, lorsqu'un nœud se connectait en sortie à un pair Tor ou I2P malveillant, ce pair pouvait prétendre voir le nœud à une
  adresse IP routable arbitraire dans son message `version`. Bitcoin Core pouvait alors réannoncer cette adresse au pair, avec son propre
  port d'écoute clearnet. Un port distinctif pouvait alors aider à corréler la connexion avec un nœud clearnet observé utilisant le même
  port (voir le [Bulletin #52][news52 port] pour une correction antérieure du port d'écoute Tor). Bitcoin Core ignore désormais l'adresse
  que les pairs Tor et I2P déclarent voir pour le nœud.

- [BIPs #2356][] remplace les paramètres génésis de substitution dans [BIP95][] par ceux du bloc génésis miné de [testnet5][topic testnet]
  et marque le BIP comme `Deployed`. La coinbase génésis inclut la date 2026-11-14 et le hash du bloc mainnet 975 744. S'engager sur ce hash
  garantit que le bloc génésis de testnet5 n'a pu être miné qu'après que le mainnet a atteint cette hauteur (voir le [Bulletin #431][news431
  testnet5]).

- [Core Lightning #9730][] ajoute la commande `lightning-hsmtool recoverhtlc` pour récupérer manuellement les sorties [HTLC][topic htlc]
  après une perte locale de l'état du canal. Une fois que le pair publie sa transaction d'engagement la plus récente, le nœud en cours de
  récupération peut déjà récupérer sa sortie principale en utilisant une [sauvegarde statique de canal][topic static channel backups] (voir
  le [Bulletin #421][news421 recovery]). Étant donnés le `hsm_secret` local, les détails du canal et des HTLC, et le point per-commitment du
  pair, la nouvelle commande identifie les sorties HTLC correspondantes. L'outil construit des transactions signées pour récupérer les HTLC
  sortants après un délai d'expiration ou pour réclamer les HTLC entrants avec des préimages connues. Cependant, l'opérateur doit examiner
  et diffuser manuellement les transactions. Un pair CLN coopératif peut exporter le point public en utilisant la commande `dumpcommitments
  --point-only` sans révéler de secrets.

- [LDK #5561][] corrige une perte potentielle de fonds transférés lorsqu'un pair envoie `revoke_and_ack` avant que LDK n'envoie le message
  `commitment_signed` correspondant. Précédemment, LDK pouvait accepter cet accusé de réception prématuré et faire avancer son numéro
  d'engagement interne. Par conséquent, il pouvait signer un engagement différent de celui enregistré par son moniteur onchain. Si le pair
  publiait cet engagement, LDK pouvait ne pas réclamer le HTLC entrant, même après avoir payé le HTLC sortant, bien qu'il connaisse sa
  préimage. LDK rejette désormais l'accusé de réception prématuré et force la fermeture du canal. Le correctif a été publié dans LDK 0.2.8
  (voir le [Bulletin #431][news431 ldk]). Le [Bulletin #426][news426 ldk5057] décrivait un bogue antérieur qui laissait un engagement signé
  sans surveillance pendant une reconnexion.

- [LDK #5562][] et [#5545][ldk #5545] corrigent des collisions d'identifiants de canal qu'un pair malveillant pouvait créer entre ses canaux
  et un nœud LDK. Dans le premier cas, le pair pouvait réutiliser l'identifiant connu d'un canal fermé de force comme identifiant temporaire
  d'un nouveau canal. Cela pouvait empêcher LDK d'enregistrer la préimage d'un paiement transféré dans le moniteur du canal fermé, laissant
  le [HTLC][topic htlc] entrant non réclamé après que le HTLC sortant a été payé. Dans le second cas, le pair pouvait calculer le futur
  identifiant final d'un canal à partir de sa transaction de financement et soumettre une autre demande d'ouverture avec cet identifiant
  temporaire. Si le canal original adoptait son identifiant final avant que l'application n'accepte la nouvelle demande, cette acceptation
  pouvait écraser son état financé. LDK rejette désormais les identifiants en conflit et les revérifie au moment de l'acceptation. Les deux
  correctifs ont également été publiés dans LDK 0.2.8. Voir le [Bulletin #427][news427 channelid] pour des collisions d'identifiants de
  canal liées qui pouvaient provoquer un DoS dans Eclair.

- [LDK #5557][] corrige une vulnérabilité qui permettait à des pairs malveillants de perturber la surveillance des transactions sur les
  nœuds utilisant un backend Electrum. Le pair pouvait proposer un canal dont la sortie de financement revendiquée réutilisait un outpoint
  déjà surveillé, mais avec un script de verrouillage différent. L'enregistrement de cette proposition pouvait écraser le script stocké de
  la surveillance légitime, même si LDK rejetait ensuite le canal. LDK interrogerait alors Electrum pour les transactions associées au
  script factice et pourrait manquer une transaction dépensant la véritable sortie, empêchant une réaction rapide à une fermeture de canal.
  LDK conserve désormais chaque script distinct enregistré pour un outpoint, de sorte qu'un enregistrement factice ne puisse pas supprimer
  la surveillance légitime. Ce correctif a également été publié dans LDK 0.2.8.

- [LDK #5558][] et [#5482][ldk #5482] corrigent deux façons dont des paiements pouvaient dépasser leur budget de frais. La première PR
  traite la gestion d'un paramètre de limite de frais omis pour les [paiements asynchrones][topic async payments] utilisant des factures
  [BOLT12][topic offers] statiques (voir le [Bulletin #321][news321 async]). LDK applique désormais son plafond par défaut de 1 % du montant
  du paiement plus 50 sat lorsque l'application omet ce paramètre. Précédemment, l'omettre supprimait entièrement la limite, permettant à un
  receveur malveillant de fournir un [chemin aveuglé][topic rv routing] avec des frais excessifs. Ce correctif a également été publié dans
  LDK 0.2.8. La seconde PR traite les nouvelles tentatives lorsqu'une route ajoute de la valeur pour satisfaire un minimum de HTLC. LDK
  traitait la valeur supplémentaire comme faisant partie du paiement demandé et restaurait le budget de frais du chemin échoué lors de la
  nouvelle tentative, permettant à la dépense totale de dépasser sa limite. LDK ne retente désormais que le montant restant dû et compte
  tout excédent sur le budget de frais restant.

- [LND #11555][] modifie la manière dont LND signale comme réglées les factures non-[AMP][topic amp]. Bien que les applications puissent
  déjà surveiller quand le règlement des [HTLCs][topic htlc] individuels était verrouillé hors chaîne (voir le [Bulletin #224][news224
  finality]), LND pouvait marquer une facture comme réglée dès que la préimage était publiée. La facture entre désormais dans l'état
  `PENDING_SETTLE` lors de la publication de la préimage. Une fois que chaque HTLC du paiement a une issue finale hors chaîne ou onchain,
  LND marque la facture comme `SETTLED` si toutes les parties ont été encaissées ou `CANCELED` si l'une d'elles a échoué. Une facture
  annulée peut quand même avoir encaissé certaines parties, qui ne sont pas remboursées, de sorte que les applications ne devraient créditer
  que les montants provenant de HTLCs finalisés avec succès. Le drapeau `preimage_released` d'une facture enregistre si LND s'est engagé à
  publier la préimage. Les ensembles de paiements AMP continuent d'être réglés lors de la publication de la préimage.

- [LND #11551][] corrige la validation d'expiration lors de l'achèvement des [paiements multipath][topic multipath payments] et des
  paiements [AMP][topic amp]. Précédemment, LND vérifiait chaque HTLC à son arrivée. Si davantage de blocs étaient minés pendant que le
  receveur attendait les parties restantes, LND pouvait publier des préimages même si un HTLC antérieur ne disposait plus de la [marge
  d'expiration][topic cltv expiry delta] requise pour l'encaissement onchain. Désormais, LND revérifie chaque partie par rapport à la
  hauteur de bloc actuelle lorsque la dernière partie arrive. Si une partie précédemment acceptée est désormais trop proche de l'expiration,
  LND fait échouer cet ensemble et laisse la facture ouverte pour une nouvelle tentative (voir le [Bulletin #424][news424 amp] pour des
  travaux antérieurs sur l'annulation d'ensembles AMP individuels).

- [LND #11472][] et [#10842][lnd #10842] corrigent des cas où des erreurs temporaires du backend ou une entrée problématique pouvaient
  bloquer des balayages par ailleurs valides. La première maintient les entrées disponibles pour une nouvelle tentative après des erreurs
  temporaires ou non classifiées lors des vérifications d'acceptation dans le mempool (voir le [Bulletin #373][news373 sweeper]). Elle a été
  publiée dans LND 0.21.8-beta et 0.20.8-beta (voir le [Bulletin #431][news431 lnd]). La seconde utilise des transactions de diagnostic qui
  ne sont jamais diffusées pour tester des sous-ensembles d'un lot rejeté. Si une entrée invalide ou en conflit peut être identifiée, LND
  l'exclut de la tentative suivante et réessaie avec les entrées restantes.

- [LND #11542][] corrige la récupération des [HTLCs][topic htlc] transférés après des reconnexions de canal. Lors de la relecture des lots
  de transfert stockés, LND pouvait filtrer les HTLCs accusés de réception puis utiliser les nouvelles positions des entrées restantes pour
  rechercher des métadonnées indexées par leurs positions d'origine. Cela pouvait faire ignorer des HTLCs non résolus ou les associer
  incorrectement. De plus, si le gestionnaire HTLC d'un canal s'arrêtait après que LND avait enregistré le lot mais avant de transmettre un
  HTLC, un enregistrement incomplet pouvait être laissé, entraînant le rejet des nouvelles tentatives comme doublons. LND préserve désormais
  les index d'origine du lot et supprime les enregistrements incomplets après un échec de transmission, permettant de relancer les HTLCs non
  résolus. Le correctif a été publié dans LND 0.21.8-beta et 0.20.8-beta (voir le [Bulletin #431][news431 lnd]).

{% include snippets/recap-ad.md when="2026-11-24 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="36757,2356,9730,5561,5562,5545,5557,5558,5482,11555,11551,11472,10842,11542" %}
[7d5x9 dcpp]: https://delvingbitcoin.org/t/decentralized-coinbase-payout-protocols-dcpp-a-framework-for-discussion/3060
[news340 braidpool]: /fr/newsletters/2025/02/07/#demande-pour-une-conception-de-covenant-soutenant-braidpool
[news397 bip448]: /fr/newsletters/2026/03/20/#bips-1974
[lb p2pool]: https://delvingbitcoin.org/t/decentralized-coinbase-payout-protocols-dcpp-a-framework-for-discussion/3060/2
[jungly dcpp]: https://delvingbitcoin.org/t/decentralized-coinbase-payout-protocols-dcpp-a-framework-for-discussion/3060/5
[roose dcpp]: https://delvingbitcoin.org/t/decentralized-coinbase-payout-protocols-dcpp-a-framework-for-discussion/3060/4
[eclair vuln del]: https://delvingbitcoin.org/t/disclosure-memory-exhaustion-dos-in-eclair-0-14-0/3057
[eclair 0.14.0]: https://github.com/ACINQ/eclair/releases/tag/v0.14.0
[eclair 0.14.1]: https://github.com/ACINQ/eclair/releases/tag/v0.14.1
[poinsot staletip]: https://groups.google.com/g/bitcoindev/c/AwOPNxF15mU/m/qJIADCfABgAJ
[news417 staletip]: /fr/newsletters/2026/08/07/#ebauche-de-bip-pour-le-relais-des-pointes-perimees
[news423 staletip]: /fr/newsletters/2026/09/18/#bips-2241
[poinsot staletip2]: https://groups.google.com/g/bitcoindev/c/AwOPNxF15mU/m/ORRffqwZAgAJ
[towns staletip]: https://groups.google.com/g/bitcoindev/c/AwOPNxF15mU/m/NF7UNdJoAQAJ
[towns staletip2]: https://groups.google.com/g/bitcoindev/c/AwOPNxF15mU/m/Kt4orC5bAAAJ
[poinsot staletip3]: https://groups.google.com/g/bitcoindev/c/AwOPNxF15mU/m/NqK6HjiAAQAJ
[liana v16.0]: https://github.com/wizardsardine/liana/releases/tag/v16.0
[news424 bip138]: /fr/newsletters/2026/09/25/#bips-1951
[coldcard 5.6.3]: https://blog.coinkite.com/coldcard-firmware-563-153q/
[wavelength mainnet]: https://lightning.engineering/posts/2026-10-23-wavelength-mainnet-launch/
[news415 wavelength]: /fr/newsletters/2026/07/24/#publication-de-l-alpha-de-wavelength
[bull payjoin blog]: https://www.bullbitcoin.com/blog/payjoin-trading
[news338 bull]: /fr/newsletters/2025/01/24/#bull-bitcoin-mobile-wallet-ajoute-payjoin
[bull 6.14.0]: https://github.com/SatoshiPortal/bullbitcoin-mobile/releases/tag/v6.14.0
[breez 0.28.0]: https://github.com/breez/spark-sdk/releases/tag/v0.28.0
[spscand delving]: https://delvingbitcoin.org/t/silent-payments-for-electrum/3078
[news419 sp electrum]: /fr/newsletters/2026/08/21/#plugin-d-envoi-silent-payments-pour-electrum
[sv2-apps v0.9.0]: https://github.com/stratum-mining/sv2-apps/releases/tag/v0.9.0
[news384 sv2]: /fr/newsletters/2025/12/12/#librairie-python-bip-329-1-0-0-publiee
[mara sv2]: https://x.com/MARAFoundation_/status/2120520367500308580
[foundry sv2]: https://x.com/FoundryServices/status/2121279504475709625
[openswap v0.2.3]: https://github.com/citadel-foss/openswap/releases/tag/v0.2.3
[news415 coinswap]: /fr/newsletters/2026/07/24/#coinswap-v0-2-2-publie
[news406 ldk server]: /fr/newsletters/2026/05/22/#annonce-de-ldk-server
[LDK #5561]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5561
[LDK #5562]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5562
[LDK #5545]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5545
[LDK #5557]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5557
[LDK #5558]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5558
[LDK #5482]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5482
[news52 port]: /en/newsletters/2019/06/26/#bitcoin-core-15651
[news431 testnet5]: /en/newsletters/2026/11/13/#testnet5-genesis-block-to-be-mined
[news421 recovery]: /fr/newsletters/2026/09/04/#core-lightning-9435
[news431 ldk]: /en/newsletters/2026/11/13/#ldk-v0-2-8
[news426 ldk5057]: /fr/newsletters/2026/10/09/#ldk-5057
[news427 channelid]: /fr/newsletters/2026/10/16/#divulgation-de-deux-vulnerabilites-dos-corrigees-dans-eclair-v0-14-1
[news321 async]: /fr/newsletters/2024/09/20/#ldk-3140
[news224 finality]: /fr/newsletters/2022/11/02/#lnd-6517
[news424 amp]: /fr/newsletters/2026/09/25/#lnd-11198
[news373 sweeper]: /fr/newsletters/2025/09/26/#lnd-10189
[news431 lnd]: /en/newsletters/2026/11/13/#lnd-v0-21-8-beta
[news418 impressions]: /fr/newsletters/2026/08/14/#core-lightning-9150
[news430 xpay]: /fr/newsletters/2026/11/06/#core-lightning-9592
[news413 simpleclose]: /fr/newsletters/2026/07/10/#core-lightning-9104
[Core Lightning 26.12rc1]: https://github.com/ElementsProject/lightning/releases/tag/v26.12rc1
