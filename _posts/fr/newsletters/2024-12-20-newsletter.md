---
title: 'Bulletin Hebdomadaire Bitcoin Optech #334 : Revue Spéciale Année 2024'
permalink: /fr/newsletters/2024/12/20/
name: 2024-12-20-newsletter-fr
slug: 2024-12-20-newsletter-fr
type: newsletter
layout: newsletter
lang: fr

extrait : >
  Le septième numéro spécial annuel de rétrospective de Bitcoin Optech résume
  les développements notables dans Bitcoin durant toute l'année 2024.

---
{{page.excerpt}} C'est la suite de nos résumés de [2018][yirs
2018], [2019][yirs 2019], [2020][yirs 2020], [2021][yirs 2021],
[2022][yirs 2022], et [2023][yirs 2023].

## Sommaire

* Janvier
  * [Verrouillages temporels dépendants des frais](#feetimelocks)
  * [Protocole de sortie de contrat optimisé](#optimizedexits)
  * [Implémentation de preuve de concept LN-Symmetry](#poclnsym)
* Février
  * [Remplacement par taux de frais](#rbfr)
  * [Instructions de paiement lisibles par l'homme](#hrpay)
  * [Génération améliorée d'ASMap](#asmap)
  * [Financement double LN](#dualfunding)
  * [Pari sans confiance sur les futurs taux de frais](#betfeerates)
* Mars
  * [BINANAs et BIPs](#binanabips)
  * [Estimation de taux de frais améliorée](#enhancedfeeestimates)
  * [Parrainage de transaction plus efficace](#efficientsponsors)
* Avril
  * [Nettoyage du consensus](#consensuscleanup)
  * [Réforme du processus BIPs](#bip2reform)
  * [Frais de routage entrant](#inboundrouting)
  * [Blocs faibles](#weakblocks)
  * [Redémarrage de testnet](#testnet)
  * [Arrestations de développeurs](#devarrests)
* Mai
  * [Paiements silencieux](#silentpayments)
  * [BitVMX](#bitvmx)
  * [Jetons d'usage anonyme](#aut)
  * [Mises à niveau de canal LN](#lnup)
  * [Ecash pour les pools de minage](#minecash)
  * [Spécification Miniscript](#miniscript)
  * [Utreexo bêta](#utreexod)
* Juin
  * [Faisabilité de paiement LN et épuisement de canal](#lnfeasibility)
  * [Signature de transaction résistante aux quantiques](#quantumsign)
* Juillet
  * [Chemins aveuglés pour les factures BOLT11](#bolt11blind)
  * [Génération de clé ChillDKG pour les signatures seuils](#chilldkg)
  * [BIPs pour MuSig et signatures de seuils](#musigthresh)
* Août
  * [Simulateur de réseau Hyperion](#hyperion)
  * [RBF complet](#fullrbf)
* Septembre
  * [Tests et ajustements de mitigation de brouillage hybride](#hybridjamming)
  * [CSV blindé](#shieldedcsv)
  * [Paiements LN hors ligne](#lnoff)
* Octobre
  * [Offres BOLT12](#offers)
  * [Interfaces de minage, rétention de blocs et partage des coûts de validation](#pooledmining)
* Novembre
  * [Usines de canaux d'arborescence à délai d'expiration SuperScalar](#superscalar)
  * [Résolution de paiement offchain rapide et économique pour de faibles valeurs](#opr)
* Décembre
* Résumés en vedette *
  * [Divulgations de vulnérabilités](#vulnreports)
  * [Mempool en cluster](#cluster)
  * [Relais de transactions P2P](#p2prelay)
  * [Covenants et mises à jour de script](#covs)
  * [Mises à jour majeures des principaux projets d'infrastructures](#releases)
  * [Bitcoin Optech](#optech)

---

## Janvier

{:#feetimelocks}
John Law a proposé des [timelocks dépendants des frais][news283 feelocks], un soft fork permettant
aux [timelocks][topic timelocks] d'expirer uniquement lorsque les taux de frais médians des blocs
tombent en dessous d'un niveau spécifié par l'utilisateur. Cela empêche les frais élevés près de
l'expiration d'empêcher la confirmation, ce qui peut entraîner une perte de fonds. Au lieu de cela,
le timelock se prolonge jusqu'à ce que les frais tombent à une valeur prédéterminée, répondant aux
préoccupations de longue date concernant les [inondations d'expiration forcées][topic expiration
floods] lors de fermetures massives de canaux. La proposition améliore la sécurité pour les
configurations multi-utilisateurs comme les [usines de canaux][topic channel factories] et les
[joinpools][topic joinpools] tout en incitant les participants à éviter les pics de frais. Les
discussions ont inclus le stockage des paramètres dans l'[annexe][topic annex] taproot, les
engagements de taux de frais pour les clients légers, le support des nœuds élagués, et l'impact des
[frais hors bande][topic out-of-band fees].

{:#optimizedexits}
Salvatore Ingala a proposé une méthode pour [optimiser les sorties][news283 exits] des contrats
multipartite, comme les joinpools ou les usines de canaux, en permettant aux utilisateurs de
coordonner une seule transaction au lieu de diffuser des transactions séparées. Cela réduit la
taille onchain d'au moins 50% et jusqu'à 99% dans des circonstances idéales, ce qui est
crucial lorsque les frais sont élevés. Un mécanisme de caution assure l'exécution honnête : un
participant construit la transaction mais perd la caution s'il est prouvé frauduleux. Ingala suggère
d'implémenter cela avec les fonctionnalités de soft fork [OP_CAT][topic op_cat] et [MATT][topic
acc], avec une efficacité supplémentaire possible en utilisant [OP_CSFS][topic op_checksigfromstack]
et l'arithmétique 64 bits.

{:#poclnsym}
Gregory Sanders a partagé une preuve de concept [d'implémentation][news284 lnsym] de
[LN-Symmetry][topic eltoo] en utilisant un fork de Core Lightning. LN-Symmetry permet des canaux de
paiement bidirectionnels sans transactions de pénalité mais repose sur un soft fork comme
[SIGHASH_ANYPREVOUT][topic sighash_anyprevout] pour permettre aux transactions enfants de dépenser
n'importe quelle version parente. Sanders a souligné sa simplicité par rapport à [LN-Penalty][topic
ln-penalty], la difficulté d'éviter [l'épinglage][topic transaction pinning] (inspirant son travail
sur le [relais de paquets][topic package relay] et les [ancres éphémères][topic ephemeral anchors]),
et le potentiel de paiements plus rapides via l'émulation de [OP_CTV][topic op_checktemplateverify].
Il a confirmé que les pénalités sont inutiles, simplifiant l'implémentation des canaux et évitant
les fonds réservés. Cependant, LN-Symmetry nécessite des [deltas d'expiration CLTV][topic cltv
expiry delta] plus longs pour prévenir les abus.

## Février

{:#rbfr}
Peter Todd a proposé [Remplacement par Taux de Frais][news288 rbfr] (RBFr) pour adresser [l'épinglage de
transaction][topic transaction pinning] lorsque les politiques standard de [RBF][topic rbf]
échouent, avec deux variantes : RBFr pur, permettant des remplacements illimités avec des taux de
frais beaucoup plus élevés (par exemple, 2x), et
one-shot RBF, permettant un remplacement unique avec des frais modérément plus élevés (par exemple,
1,25x) si le remplacement atteint le haut du mempool. Mark Erhardt a identifié un problème initial
et d'autres développeurs ont discuté des complexités d'analyser complètement l'idée avec les outils
disponibles. Todd a publié une mise en œuvre expérimentale et d'autres développeurs ont continué à
travailler sur des solutions alternatives pour aborder le problème d'épinglage de transactions, y
compris le développement des outils nécessaires pour augmenter la confiance dans toute solution
adoptée.

{:#hrpay}
Matt Corallo a proposé un BIP pour des instructions de paiement Bitcoin lisibles par l'homme basées
sur DNS [news290 dns], permettant à une chaîne de type email (par exemple, exemple@exemple.com) de
résoudre vers un enregistrement TXT signé DNSSEC contenant une URI [BIP21][]. Cela prend en charge
les adresses onchain, les [paiements silencieux][topic silent payments], et les [offres][topic
offers] LN---et peut être facilement étendu à d'autres protocoles de paiement. Une
[spécification][news307 bip353] de cela a été ajoutée comme [BIP353][]. Corallo a également rédigé
un [BOLT][news333 dnsbolt] et un [BLIP][news306 dnsblip] pour les nœuds LN, permettant les
enregistrements DNS génériques et la résolution de paiement sécurisée en utilisant des offres. Une
[mise en œuvre][news329 dnsimp] a été fusionnée dans LDK en novembre. Le développement de ce
protocole et des paiements silencieux a conduit Josie Baker à lancer une [discussion][news292 bip21]
sur la révision des URI de paiement [BIP21][], qui a [continué][news306 bip21] plus tard dans
l'année.

{:#asmap}
Fabian Jahr a écrit un logiciel qui permet à plusieurs développeurs de [créer de manière
indépendante des ASMaps équivalents][news290 asmap], ce qui aide Bitcoin Core à diversifier les
connexions entre pairs et à résister aux [attaques par éclipse][topic eclipse attacks]. Si l'outil
de Jahr devient largement accepté, Bitcoin Core pourrait inclure les ASMaps par défaut, améliorant
la protection contre les attaques de parties contrôlant des nœuds sur plusieurs sous-réseaux.

{:#dualfunding}
Le [support][news290 dualfund] pour le [financement double][topic dual funding] a été ajouté à la
spécification LN ainsi que le support pour le protocole de construction de transaction interactive.
La construction interactive permet à deux nœuds d'échanger des préférences et des détails d'UTXO
qu'ils peuvent utiliser pour construire ensemble une transaction de financement. Le financement double
permet à une transaction d'inclure des entrées de l'une ou des deux parties. Par exemple, Alice peut
vouloir ouvrir un canal avec Bob. Avant ce changement de spécification, Alice devait fournir tout le
financement pour le canal. Maintenant, en utilisant une mise en œuvre qui supporte le financement
double, Alice peut ouvrir un canal avec Bob où il fournit tout le financement ou où chacun contribue
des fonds à l'état initial du canal. Cela peut être combiné avec le protocole expérimental des
[annonces de liquidité][topic liquidity advertisements], qui n'a pas encore été ajouté à la
spécification.

{:#betfeerates}
ZmnSCPxj a proposé des scripts sans confiance permettant à deux parties de [parier sur les futurs
taux de frais de bloc][news291 bets]. Un utilisateur souhaitant qu'une transaction soit confirmée
par un futur bloc peut utiliser cela pour compenser le risque que les [taux de frais][topic fee
estimation] soient inhabituellement élevés à ce moment-là. Un mineur s'attendant à miner un bloc
autour du moment où l'utilisateur a besoin que sa transaction soit confirmée peut utiliser ce
contrat pour compenser le risque que les taux de frais soient inhabituellement bas. La conception
empêche la manipulation observée dans les marchés centralisés, car les décisions du mineur reposent
uniquement sur les conditions réelles d'exploitation minière. Le contrat est sans confiance avec un
chemin de dépense coopératif qui minimise les coûts pour les deux parties.

<div markdown="1" class="callout" id="vulnreports">
## Résumé 2024 : Divulgations de vulnérabilités

En 2024, Optech a résumé plus de deux douzaines de divulgations de vulnérabilités. La majorité
étaient d'anciennes divulgations de Bitcoin Core qui étaient publiées pour la première fois cette
année. Les rapports de vulnérabilité donnent aux développeurs et aux utilisateurs l'opportunité
d'apprendre des problèmes passés, et les [divulgations responsables][topic responsible disclosures]
nous permettent à tous de remercier ceux qui rapportent leurs découvertes avec discrétion.

_Note : Optech ne publie les noms des découvreurs de vulnérabilités que si nous pensons qu'ils ont
fait un effort raisonnable pour minimiser le risque de préjudice pour les utilisateurs. Nous
remercions toutes les personnes nommées dans cette section pour leur perspicacité et leur
préoccupation claire pour la sécurité des utilisateurs._

Fin 2023, Niklas Gögge a [divulgué publiquement][news283 lndvuln] deux vulnérabilités qu'il avait
signalées deux ans plus tôt, conduisant à la sortie de versions corrigées de LND. La première, une
vulnérabilité de DoS, aurait pu conduire à LND manquant de mémoire et s'écrasant. La seconde, une
vulnérabilité de censure, pourrait permettre à un attaquant d'empêcher un nœud LND d'apprendre les
mises à jour des canaux ciblés à travers le réseau ; un attaquant pourrait utiliser cela pour
biaiser un nœud vers la sélection de routes spécifiques pour les paiements qu'il envoie, donnant à
l'attaquant plus de frais de transfert et plus d'informations sur les paiements envoyés par le nœud.

En janvier, Matt Morehouse a [annoncé une vulnérabilité][news285 clnvuln] qui affectait les versions
de Core Lightning de 23.02 à 23.05.2. Lors du re-test de nœuds qui avaient implémenté des
corrections pour le financement fictif, qu'il avait précédemment découvert et divulgué, il a pu
déclencher une condition de concurrence qui faisait planter CLN après environ 30 secondes. Si un
nœud LN est arrêté, il ne peut pas défendre un utilisateur contre des contreparties malveillantes ou
défectueuses, ce qui met les fonds de l'utilisateur en danger.

Également en janvier, Gögge est revenu pour [annoncer][news286 btcdvuln] une vulnérabilité de
défaillance de consensus qu'il a trouvée dans le nœud complet btcd. Le code pourrait mal interpréter
un numéro de version de transaction et appliquer les mauvaises règles de consensus à une transaction
utilisant un verrouillage temporel relatif. Cela pourrait empêcher les nœuds complets btcd
d'afficher les mêmes transactions confirmées que Bitcoin Core, mettant les utilisateurs en risque de
perdre de l'argent.

Février a vu Eugene Siegel [publier][news288 bccvuln] un rapport de vulnérabilité de Bitcoin Core
qu'il avait initialement divulgué presque trois ans auparavant. La vulnérabilité pourrait être
utilisée pour empêcher Bitcoin Core de télécharger des blocs récents. Cela pourrait être utilisé
pour empêcher un nœud LN connecté d'apprendre les préimages nécessaires pour résoudre les
[HTLCs][topic htlc], potentiellement conduisant à une perte d'argent.

Morehouse est revenu en juin pour [divulguer][news308 lndvuln] une vulnérabilité permettant de faire
planter des versions de LND avant 0.17.0. Comme mentionné précédemment, un nœud LN arrêté ne peut
pas défendre un utilisateur contre des contreparties malveillantes ou défectueuses, ce qui met les
fonds de l'utilisateur en danger.

Juillet a vu la première des [multiples divulgations][news310 disclosures] de vulnérabilités
affectant des versions passées de Bitcoin Core. Wladimir J. Van Der Laan enquêtait sur une
vulnérabilité découverte par Aleksandar Nikolic dans une bibliothèque utilisée par Bitcoin Core
lorsqu'il a [découvert][news310 wlad] une vulnérabilité séparée permettant l'exécution de code à
distance ; cela était
corrigé en amont, et la correction a été intégrée dans Bitcoin Core. Le développeur Evil-Knievel [a
découvert][news310 ek] une vulnérabilité qui pourrait épuiser la mémoire de nombreux nœuds Bitcoin
Core, les faisant planter, ce qui pourrait être utilisé dans le cadre d'autres attaques pour voler
de l'argent (par exemple, des utilisateurs de LN). John Newbery, citant la co-découverte par Amiti
Uttarwar, [a révélé][news310 jnau] une vulnérabilité qui pourrait être utilisée pour censurer des
transactions non confirmées, ce qui pourrait également être utilisé dans le cadre d'attaques pour
voler de l'argent (encore une fois, un cas d'exemple étant celui des utilisateurs de LN). Une
vulnérabilité a été [signalée][news310 unamed] permettant de consommer une quantité excessive de CPU
et de mémoire, pouvant potentiellement conduire à un crash du nœud. Le développeur practicalswift [a
découvert][news310 ps] une vulnérabilité qui pourrait amener un nœud à ignorer des blocs légitimes
pendant un certain temps, retardant la réaction à des événements sensibles au temps qui pourraient
affecter les protocoles de contrat comme LN. Le développeur sec.eine [a révélé][news310 sec.eine]
une vulnérabilité qui pourrait consommer une quantité excessive de CPU, ce qui pourrait être utilisé
pour empêcher un nœud de traiter de nouveaux blocs et transactions, pouvant potentiellement conduire
à de multiples problèmes pouvant entraîner une perte d'argent. John Newbery a [divulgué][news310
jn1] de manière responsable une autre vulnérabilité qui pourrait épuiser la mémoire de nombreux
nœuds, pouvant potentiellement conduire à des crashs. Cory Fields [a découvert][news310 cf] une
vulnérabilité distincte d'épuisement de la mémoire qui pourrait faire planter Bitcoin Core. John
Newbery [a révélé][news310 jn2] une troisième vulnérabilité qui pourrait gaspiller la bande passante
et limiter le nombre de slots de connexion de pairs d'un utilisateur. Michael Ford [a
signalé][news310 mf] une vulnérabilité d'épuisement de la mémoire affectant quiconque cliquait sur
une URL [BIP72][], ce qui pourrait faire planter un nœud.

D'autres révélations de la part de Bitcoin Core ont suivi dans les mois suivants. Eugene Siegel [a
découvert][news314 es] une méthode pour faire planter Bitcoin Core en utilisant des messages `addr`.
Michael Ford, enquêtant sur un rapport de Ronald Huveneers concernant la bibliothèque miniupnpc, a
découvert une méthode différente pour faire planter Bitcoin Core en utilisant des connexions réseau
locales. David Jaenson, Braydon Fuller et plusieurs développeurs de Bitcoin Core [ont
découvert][news322 checkpoint] une vulnérabilité qui pourrait être utilisée pour empêcher un nœud
complet nouvellement démarré de se synchroniser avec la meilleure chaîne de blocs ; la vulnérabilité
a été éliminée avec un correctif de bug post-fusion par Niklas Gögge. Une autre vulnérabilité de
crash à distance a été [découverte][news324 ng] par Niklas Gögge, exploitant un problème avec la
gestion des messages de blocs compacts. Plusieurs utilisateurs [ont signalé][news324 b10caj] une
consommation excessive de CPU, amenant les développeurs 0xB10C et Anthony Towns à enquêter sur la
cause et à mettre en œuvre une solution. Plusieurs développeurs, dont William Casarin et ghost43,
ont signalé des problèmes avec leurs nœuds, conduisant Suhas Daftuar à [isoler][news324 sd] une
vulnérabilité qui pourrait empêcher Bitcoin Core d'accepter un bloc pendant longtemps. Le dernier
rapport de vulnérabilité de Bitcoin Core [rapporté][news328 multi] cette année décrivait une méthode
pour retarder les blocs de 10 minutes ou plus.

Lloyd Fournier, Nick Farrow et Robin Linus [ont annoncé Dark Skippy][news315 exfil], une méthode
améliorée pour l'exfiltration de clés à partir d'un dispositif de signature Bitcoin qu'ils avaient
précédemment divulguée de manière responsable à environ 15 différents fournisseurs de dispositifs de
signature matérielle.
L'exfiltration survient lorsque le code de signature de transaction crée délibérément ses signatures
de manière à ce qu'elles divulguent des informations sur le matériel clé sous-jacent, tel qu'une clé
privée ou une graine de portefeuille HD BIP32. Une fois qu'un attaquant obtient la graine d'un
utilisateur, il peut voler tous les fonds de l'utilisateur à tout moment (y compris les fonds
dépensés dans la transaction qui résulte en exfiltration, si l'attaquant agit rapidement). Cela a
conduit à une [discussion renouvelée][news317 exfil] sur les [protocoles de signature
anti-exfiltration][topic exfiltration-resistant signing].

L'introduction d'un nouveau testnet a également vu la découverte d'une [nouvelle vulnérabilité de
timewarp][news316 timewarp]. Testnet4 incluait un correctif pour la vulnérabilité originale de
[timewarp][topic time warp], mais le développeur Zawy a découvert en août un nouvel exploit qui
pourrait réduire la difficulté d'environ 94%. Mark "Murch" Erhardt a développé davantage l'attaque
pour permettre de réduire la difficulté à sa valeur minimale. Plusieurs solutions ont été proposées
et les compromis entre elles étaient encore en [discussion][news332 ccsf] en décembre.

![Illustration de la nouvelle vulnérabilité timewarp](/img/posts/2024-time-warp/new-time-warp.png)

En octobre, Antoine Poinsot et Niklas Gögge ont révélé une autre [vulnérabilité de défaillance de
consensus][news324 btcd] affectant le nœud complet btcd. Depuis la version originale de Bitcoin,
elle a contenu une fonction obscure (mais critique) utilisée pour extraire les signatures des
scripts avant de les hacher. L'implémentation dans btcd différait légèrement de la version originale
héritée par Bitcoin Core, permettant à un attaquant de créer des transactions qui seraient acceptées
par un nœud mais rejetées par l'autre, ce qui pourrait être utilisé de diverses manières pour faire
perdre de l'argent aux utilisateurs.

Décembre a vu David Harding [révéler][news333 if] une vulnérabilité affectant Eclair, LDK, et LND
par défaut (et Core Lightning avec des paramètres non par défaut). La partie qui a demandé à ouvrir
un canal (l'initiateur) et qui était responsable du paiement de tous les [frais endogènes][topic fee
sourcing] nécessaires pour fermer le canal pouvait s'engager à payer 98% de la valeur du canal en
frais dans un état, réduire l'engagement à un montant minimal dans un état ultérieur, transférer 99%
de la valeur du canal à l'autre partie, puis fermer le canal dans l'état à 98% de frais. Cela
résulterait dans le fait que l'initiateur perd 1% de la valeur du canal pour avoir utilisé un ancien
état mais l'autre partie perdrait 98% de la valeur du canal. Si l'initiateur minait la transaction
lui-même, il pourrait conserver les 98% de la valeur du canal payés en frais. Cette méthode
permettrait de voler environ 3 000 canaux par bloc.

Une [vulnérabilité][news333 deanon] de déanonymisation affectant Wasabi et les logiciels associés a
été la dernière divulgation résumée par Optech cette année. La vulnérabilité permet à un
coordinateur de [coinjoin][topic coinjoin] du type utilisé par Wasabi et GingerWallet de fournir aux
utilisateurs des identifiants censés être anonymes mais qui peuvent être rendus distincts pour
permettre le suivi. Bien qu'une méthode de rendu des identifiants distincts ait été éliminée, un
problème plus généralisé permettant à un coordinateur de produire des identifiants distincts a été
identifié en 2021 par Yuval Kogman et reste non résolu à ce jour.

<!-- Non résumé ici mais discuté dans la section des améliorations P2P
- https://bitcoinops.org/en/newsletters/2024/03/27/#disclosure-of-free-relay-attack
- https://bitcoinops.org/en/newsletters/2024/07/26/#varied-discussion-of-free-relay-and-fee-bumping-upgrades
-->

</div>

## Mars

{:#binanabips}
Les problèmes continus pour intégrer les BIPs ont conduit à la création en janvier d'un [nouveau
dépôt BINANA][news286 binana] pour les spécifications et autres documentations. Février et mars ont
vu l'éditeur actuel des BIPs demander de l'aide et le début d'un [processus pour ajouter de nouveaux
éditeurs][news292 bips]. Après une discussion publique approfondie culminant en avril, plusieurs
contributeurs de Bitcoin ont été [nommés éditeurs de BIPs][news299 bips].

{:#enhancedfeeestimates}
Abubakar Sadiq Ismail a proposé [d'améliorer l'estimation du taux de frais de Bitcoin Core][news295
fees] en utilisant les données en temps réel du mempool. Actuellement, les estimations se basent sur
les données des transactions confirmées, qui se mettent à jour lentement mais résistent à la
manipulation. Ismail a développé un code préliminaire comparant l'approche actuelle avec un nouvel
algorithme basé sur le mempool. Les discussions ont souligné si les données du mempool devraient
ajuster les estimations à la hausse et à la baisse, ou seulement les diminuer. L'ajustement double
améliore l'utilité, mais limiter les ajustements à la baisse des estimations peut mieux prévenir la
manipulation.

{:#efficientsponsors}
Martin Habovštiak a proposé une méthode pour [augmenter les priorités des transactions non
liées][news295 sponsor] en utilisant l'annexe taproot, réduisant considérablement les besoins en
espace par rapport aux méthodes antérieures de [parrainage de frais][topic fee sponsorship]. David
Harding a suggéré une approche encore plus efficace utilisant des messages d'engagement de
signature, ne nécessitant aucun espace onchain mais dépendant de l'ordre des blocs. Pour les
transactions de parrainage qui se chevauchent, Harding et Anthony Towns ont proposé des alternatives
utilisant aussi peu que 0,5 vbytes par augmentation. Towns a noté que ces méthodes de parrainage
sont compatibles avec le design proposé du [mempool en cluster][topic cluster mempool], bien que les
versions les plus efficaces présentent de légers défis pour la mise en cache de la validité des
transactions en rendant plus difficile pour les nœuds de précalculer et de stocker les informations
de validité. Cette approche de parrainage permet une augmentation dynamique des frais à un coût
minimal, la rendant attrayante pour les protocoles nécessitant des [frais exogènes][topic fee
sourcing], bien que la sous-traitance sans confiance reste un problème. Suhas Daftuar a averti que
le parrainage pourrait créer des problèmes pour les utilisateurs non participants, suggérant qu'il
soit opt-in s'il est adopté pour éviter des impacts non intentionnés.

## Avril

{:#consensuscleanup}
Antoine Poinsot a [réexaminé][news296 ccsf] la proposition de nettoyage du consensus de Matt Corallo
de 2019, abordant des problèmes tels que la vérification lente des blocs, les attaques de
manipulation temporelle permettant le vol, et les [vulnérabilités de transactions factices][topic
merkle tree vulnerabilities] affectant les clients légers et les nœuds complets. Poinsot a également
souligné le problème des [transactions en double][topic duplicate transactions] qui affectera les
nœuds complets au bloc 1,983,702. Tous les problèmes ont des solutions de soft-fork, bien qu'une
solution proposée pour les blocs à vérification lente ait soulevé des préoccupations quant à
l'invalidation potentielle de transactions pré-signées rares. L'une des mises à jour proposées a
reçu une [discussion][news319 merkle] significative en août et septembre examinant des méthodes
alternatives pour atténuer les vulnérabilités des arbres de Merkle qui affectent les clients légers
et même (parfois) les nœuds complets. Bien que Bitcoin Core ait atténué les vulnérabilités autant
que possible, une refactorisation précédente a supprimé des protections essentielles, donc Niklas
Gögge a écrit du code pour Bitcoin Core qui détecte toutes les vulnérabilités actuellement
détectables le plus tôt possible et rejette les blocs invalides. En décembre, la
discussion [s'est orientée][news332 zmwarp] vers l'utilisation du soft fork de nettoyage du
consensus pour corriger la variante Zawy-Murch de la [vulnérabilité du décalage temporel][topic time
warp] qui a été découverte après l'implémentation sur [testnet4][topic testnet] des règles conçues
pour la proposition originale de nettoyage du consensus.

{:#bip2reform}
Un dérivé de la discussion sur l'ajout d'un nouvel éditeur de BIPs a manifesté le désir de [réformer
le BIP2][news297 bips], qui spécifie le processus actuel pour ajouter de nouveaux BIPs et mettre à
jour les BIPs existants. La discussion [a continué][news303 bip2] le mois suivant, et septembre a vu
la publication d'un [brouillon de BIP][news322 newbip2] pour une mise à jour du processus.

{:#inboundrouting}
LND a introduit [le support des frais de routage entrants][news297 inbound], promu par Joost Jager,
qui permet aux nœuds de facturer des frais spécifiques au canal pour les paiements reçus de pairs.
Cela aide les nœuds à gérer la liquidité, comme facturer des frais plus élevés pour les paiements
entrants de nœuds mal gérés. Les frais entrants sont compatibles avec les versions antérieures,
initialement fixés à négatif (par exemple, des réductions) pour fonctionner avec les anciens nœuds.
Bien que proposée il y a des années, d'autres implémentations de LN ont résisté à la fonctionnalité,
citant des préoccupations de conception et des problèmes de compatibilité. La fonctionnalité a vu un
développement continu dans LND tout au long de l'année.

{:#weakblocks}
Greg Sanders a proposé [l'utilisation de blocs faibles][news299 weakblocks]---des blocs avec une
preuve de travail (PoW) insuffisante mais des transactions valides---pour améliorer [le relais de
blocs compacts][topic compact block relay] face à des politiques divergentes de relais de
transactions et de minage. Les mineurs produisent naturellement des blocs faibles
proportionnellement à leur pourcentage de PoW, reflétant les transactions qu'ils tentent de miner.
Les blocs faibles résistent aux abus en raison de coûts de création élevés, permettant aux mempools
et aux caches d'être mis à jour sans permettre un gaspillage excessif de bande passante. Cela
pourrait garantir que le relais de blocs compacts reste efficace même lorsque les mineurs incluent
des transactions non standard dans les blocs. Les blocs faibles pourraient également aborder les
[attaques d'épinglage][topic transaction pinning] et améliorer [l'estimation du taux de frais][topic
fee estimation]. L'implémentation de preuve de concept de Sanders démontre l'idée.

{:#testnet}
Jameson Lopp a commencé une discussion en avril sur les problèmes avec le [testnet][topic testnet]
public actuel de Bitcoin (testnet3) et a suggéré [de le redémarrer][news297 testnet],
potentiellement avec un ensemble différent de règles de consensus spéciales. En mai, Fabian Jahr a
[annoncé][news306 testnet] un brouillon de BIP et une proposition d'implémentation pour testnet4. Le
[BIP][news315 testnet4bip] et l'[implémentation][news315 testnet4imp] de Bitcoin Core ont été
fusionnés en août.

{:#devarrests}
Avril s'est terminé de manière malheureuse avec la nouvelle de l'[arrestation de deux développeurs
de Bitcoin][news300 arrest] axés sur le logiciel de confidentialité, ainsi qu'au moins deux autres
entreprises annonçant leur intention de cesser de servir les clients américains en raison des
risques juridiques.

<div markdown="1" class="callout" id="cluster">
## Résumé 2024 : Cluster mempool

Une idée pour une [refonte du mempool][news251 cluster] de 2023 est devenue un point d'attention
particulier pour plusieurs développeurs de Bitcoin Core tout au long de 2024. Le cluster mempool
rend beaucoup plus facile de raisonner sur l'effet des transactions sur tous les blocs qu'un mineur
créerait s'il possède un
mempool identique à celui du nœud local. Cela peut rendre l'éviction des transactions plus
rationnelle et aider à déterminer si une [transaction de remplacement][topic rbf] (ou un ensemble de
transactions) est meilleure que les transactions qu'elle remplace. Cela peut aider à aborder
diverses limitations du mempool qui sont impliquées dans de multiples problèmes affectant les
protocoles de contrat tels que LN (y compris parfois la mise en danger des fonds).

De plus, comme vu dans un post de janvier par Abubakar Sadiq Ismail, les outils et les insights
issus de la conception du cluster mempool peuvent permettre [d'améliorer l'estimation des frais dans
Bitcoin Core][news283 fees]. Aujourd'hui, Bitcoin Core implémente l'exploitation de la feerate
ancestrale comme une manière compatible avec les incitations pour soutenir le [bumping de frais
CPFP][topic cpfp], mais l'estimation des frais opère sur des transactions individuelles, donc les
bumps de frais CPFP ne sont pas considérés. Le cluster mempool divise les groupes de transactions en
blocs qui peuvent être suivis ensemble dans le mempool puis potentiellement localisés dans des blocs
minés, permettant une meilleure estimation des frais (surtout s'il y a une utilisation accrue de
technologies liées au CPFP comme le [relais de paquets][topic package relay], [P2A][topic ephemeral
anchors], et [la source de frais exogène][topic fee sourcing].

À mesure que le projet de cluster mempool mûrissait, plusieurs explications et aperçus ont été faits
par ses architectes. Suhas Daftuar a donné un [aperçu][news285 cluster] en janvier, qui a révélé
l'un des défis de la proposition : son incompatibilité avec la politique existante de [carve-out
CPFP][topic cpfp carve out]. Une solution au dilemme serait que les utilisateurs existants de
carve-out optent pour les [transactions TRUC][topic v3 transaction relay], qui fournissent un
ensemble de fonctionnalités améliorées. Une autre [description détaillée][news312 cluster] du
cluster mempool a été postée en juillet par Pieter Wuille. Elle décrivait les principes
fondamentaux, les algorithmes proposés, et renvoyait à plusieurs pull requests. [Plusieurs][news314
cluster] de [ces pull requests][news315 cluster] et [d'autres][news331 cluster] ont par la suite été
fusionnés.

Daftuar a poursuivi sa réflexion et sa recherche derrière le cluster mempool et des propositions
connexes comme les transactions TRUC. En février, il a [considéré][news290 incentive] la
compatibilité des incitations d'idées telles que le remplacement par feerate, les incitations
différentes des mineurs avec des quantités disproportionnées de hashrate, et recherché un
comportement compatible avec les incitations qui n'était pas résistant aux DoS. En avril, il a
[recherché][news298 cluster] ce qui se serait passé si le cluster mempool avait été déployé un an
plus tôt, découvrant que cela permettait légèrement plus de transactions dans le mempool,
n'affectait pas significativement le remplacement des transactions dans les données, et pourrait
aider les mineurs à capturer plus de frais à court terme. Pieter Wuille a développé le dernier point
en août en décrivant les principes et un algorithme efficace pour [une sélection de transactions
presque optimale][news314 mine] pour les mineurs construisant des blocs.
</div>

## Mai

{:#silentpayments}
Le travail a continué cette année sur le rendu des [paiements silencieux][topic silent payments]
plus [largement accessibles][news304 sp]. Josie Baker a commencé une discussion sur les extensions
PSBT pour les paiements silencieux (SPs), basée sur un brouillon de spécification par Andrew Toth.
Cette discussion s'est poursuivie en juin avec un examen de [l'utilisation de parts ECDH pour une
coordination sans confiance][news308 sp]. Séparément, Setor Blagogee a posté un brouillon de
spécification pour un protocole visant à [aider les clients légers à recevoir des paiements
silencieux][news305 splite]. Quelques [ajustements][news309 sptweak] ont été apportés à la
spécification de base SP en juin et [deux][news326 sppsbt] projets de [BIPs][news327 sppsbt] pour
les fonctionnalités PSBT proposées ont été publiés.

{:#bitvmx}
Sergio Demian Lerner et plusieurs co-auteurs ont [publié][news303 bitvmx] un article sur une
nouvelle architecture de CPU virtuel basée en partie sur les idées derrière [BitVM][topic acc].
L'objectif de leur projet, BitVMX, est de pouvoir prouver efficacement la bonne exécution de tout
programme qui peut être compilé pour fonctionner sur une architecture CPU établie, telle que RISC-V.
Comme BitVM, BitVMX ne nécessite aucun changement de consensus, mais il exige qu'une ou plusieurs
parties désignées agissent en tant que vérificateur de confiance. Cela signifie que plusieurs
utilisateurs participant de manière interactive à un protocole de contrat peuvent empêcher l'une (ou
plusieurs) des parties de retirer de l'argent du contrat à moins que cette partie n'exécute avec
succès un programme arbitraire spécifié par le contrat.

{:#aut}
Adam Gibson a décrit un schéma de [jeton d'utilisation anonyme][news303 aut] qu'il a développé pour
permettre à quiconque pouvant dépenser un UTXO avec un chemin de clés de prouver qu'il pourrait le
dépenser sans révéler de quel UTXO il s'agit. Une utilisation qu'il met en avant est de permettre
l'annonce de canaux LN sans exiger que les propriétaires identifient les UTXOs spécifiques soutenant
ces canaux, ce qui est nécessaire actuellement pour prévenir les attaques de déni de service qui
gaspillent la bande passante. Gibson a également créé un forum de preuve de concept qui nécessite de
fournir une preuve anonyme pour s'inscrire, créant un environnement où tout le monde est connu pour
être détenteur de bitcoins mais personne n'a besoin de fournir aucune information d'identification
sur eux-mêmes ou leurs bitcoins.
Plus tard dans l'année, Johan Halseth a [annoncé][news321 utxozk] une mise en œuvre de preuve de
concept qui atteint la plupart des mêmes objectifs en utilisant un mécanisme différent.

{:#lnup}
Pendant des années, les développeurs de LN ont discuté de la modification du protocole LN pour
permettre la [mise à niveau][topic channel commitment upgrades] des canaux existants de diverses
manières. En mai, Carla Kirk-Cohen a [examiné][news304 lnup] certains de ces cas et comparé trois
propositions différentes pour les mises à niveau. Un protocole de quiescence a été [ajouté][news309
stfu] à la spécification LN en juin pour aider à soutenir les mises à niveau et d'autres opérations
sensibles. Octobre a vu le [renouvellement du développement][news326 ann1.75] d'une proposition de protocole
de mises à jour des annonces de canal qui supporterait de nouvelles [transactions de financement
basées sur taproot][topic simple taproot channels].

{:#minecash}
Ethan Tuttle a posté sur Delving Bitcoin pour suggérer que les pools de minage pourraient
[récompenser les mineurs avec des jetons ecash][news304 minecash] proportionnellement au nombre de
parts qu'ils ont minées. Les mineurs pourraient alors immédiatement vendre ou transférer les jetons,
ou ils pourraient attendre que le pool mine un bloc, moment auquel le pool échangerait les jetons
contre des satoshis. Cependant, Matt Corallo a soulevé une préoccupation : il n'existe pas de
méthodes de paiement standardisées mises en œuvre par les grands pools qui permettent aux mineurs de
pool de calculer combien ils sont censés être payés sur de courts intervalles. Cela signifie que les
mineurs ne passeront pas rapidement à un autre pool si leur pool principal commence à les tromper
sur les paiements, que ces paiements soient effectués avec ecash ou tout autre mécanisme.

{:#miniscript}
Ava Chow a [proposé][news304 msbip] un BIP pour [miniscript][topic miniscript] en mai,
qui est devenu le [BIP379][] en [juillet][news310 msbip].

{:#utreexod}
Aussi en mai, une version bêta de utreexod a été [publiée][news302
utreexod], permettant aux utilisateurs d'expérimenter
avec cette conception de nœud complet qui minimise les exigences d'espace disque.

## Juin

{:#lnfeasibility}
René Pickhardt a recherché comment estimer la [probabilité de faisabilité d'un paiement LN][news309 feas] en
analysant les distributions de richesse possibles dans les capacités des canaux. Par exemple, si
Alice veut envoyer 1 BTC à Carol via Bob, la probabilité de succès dépend si les canaux Alice-Bob et
Bob-Carol peuvent supporter le transfert. Cette métrique met en lumière les contraintes pratiques de
paiement et pourrait aider les portefeuilles et les logiciels d'entreprise à prendre des décisions
de routage plus intelligentes, améliorant ainsi les taux de succès pour les paiements LN. Plus tard
dans l'année, la recherche de Pickhardt a [fourni][news333 deplete] des aperçus sur la cause et la probabilité de
l'épuisement des canaux---un canal devenant incapable de transférer des fonds dans une direction
particulière. Elle a également indiqué que les protocoles de gestion de canaux multiparty avec k>2,
tels que les [usines à canaux]][topic channel factories], pourraient grandement augmenter le nombre de
paiements réalisables et réduire le taux d'épuisement des canaux.

![Exemple d'épuisement de canal](/img/posts/2024-12-depletion.png)

{:#quantumsign}
Le développeur Hunter Beast a [posté][news307 quant] un "brouillon" de BIP pour attribuer des adresses segwit version
3 à un algorithme de signature [résistant aux quantiques][topic quantum resistance]. Le brouillon de BIP décrit le problème et
renvoie à plusieurs algorithmes potentiels ainsi qu'à leur taille attendue onchain. Le choix
des algorithmes et les détails spécifiques de mise en œuvre ont été laissés pour une discussion
future.

<div markdown="1" class="callout" id="p2prelay">
## Résumé 2024 : Relais de transaction P2P

La gestion des frais a toujours été un défi dans le protocole Bitcoin décentralisé, mais
l'utilisation généralisée de protocoles contractuels tels que LN-Penalty et la recherche continue
sur des protocoles plus nouveaux et plus complexes ont rendu plus important que jamais de s'assurer
que les utilisateurs peuvent payer et augmenter les frais à la demande. Les contributeurs de Bitcoin
Core travaillent sur ce problème depuis des années, et 2024 a vu la publication publique de
plusieurs nouvelles fonctionnalités qui améliorent considérablement la situation.

Janvier a commencé avec une [discussion][news283 trucpin] sur les pires cas de coûts d'épinglage][topic
transaction pinning] pour la proposition [TRUC][topic v3 transaction relay] qui offre
une alternative plus robuste à la politique [CPFP carve-out][topic cpfp
carve out] précédemment déployée. Bien que les pires
cas de coûts soient beaucoup plus bas pour TRUC, les développeurs ont considéré qu'ajuster quelques
paramètres pourrait être en mesure de réduire encore les coûts. Une autre [discussion][news284 exo] en janvier a
examiné le risque théorique que l'utilisation accrue de la [source de frais exogène][topic fee sourcing] rendrait plus
efficace onchain (et donc moins cher) d'utiliser des paiements de [frais hors bande][topic out-of-band fees] aux
mineurs, ce qui met en danger la décentralisation de l'exploitation minière. Peter Todd a suggéré de
répondre à cette préoccupation avec une méthode de gestion des frais alternative : garder les frais
entièrement endogènes en présignant plusieurs variations de chaque transaction de règlement à des
taux de frais variables.Cependant, plusieurs problèmes ont été identifiés avec cette approche.

Une discussion supplémentaire en janvier par Gregory Sanders a [examinée][news285 mev] pour savoir s'il y
avait un risque que le protocole LN insère des valeurs [HTLC écourtées][topic trimmed htlc] dans des
sorties [P2A][topic ephemeral anchors], ce qui pourrait potentiellement permettre une _valeur
extractible par les mineurs_ (MEV) pour les mineurs qui exécutent un logiciel spécial au-delà de ce
qui est nécessaire pour miner les transactions du mempool. Bastien Teinturier a lancé une
[discussion][news286 lntruc] sur les changements nécessaires au protocole LN pour gérer les
transactions d'engagement utilisant TRUC et les sorties P2A ; cela incluait la proposition de HTLC
écourté considérée par Sanders, éliminant les délais d'un bloc désormais inutiles, et une réduction
de la taille des transactions onchain. La discussion a également mené à une proposition [TRUC
enrichi][news286 imtruc] qui appliquerait automatiquement les règles TRUC aux transactions
ressemblant à l'utilisation existante de CPFP carve-out par LN, offrant les avantages de TRUC sans
que le logiciel LN ait besoin d'être mis à jour.

Janvier s'est terminé avec une [proposition][news287 sibrbf] de Gloria Zhao pour le [remplacement par
frais entre frères][topic kindred rbf]. Les règles [RBF][topic rbf] normales s'appliquent uniquement
aux transactions conflictuelles où un nœud accepte juste une version de la transaction dans son
mempool parce qu'une seule version est autorisée à exister dans une blockchain valide. Cependant,
avec TRUC, un nœud accepte seulement un descendant d'une transaction parent non confirmée de version 3,
une situation très similaire à une transaction conflictuelle. Permettre à un descendant de remplacer
un autre descendant de la même transaction---c'est-à-dire _l'éviction entre frères_---améliorerait le
bumping de frais des transactions TRUC et serait particulièrement bénéfique si TRUC enrichi est
adopté.

Février a commencé avec des discussions supplémentaires sur les conséquences du passage du protocole
LN de CPFP carve-out à TRUC. Matt Corallo a trouvé des [défis][news288 truc0c] à adapter les
[ouvertures de canaux zero-conf][topic zero-conf channels] existantes à l'utilisation de TRUC en
raison du fait que la transaction de financement et une transaction de fermeture immédiate
pourraient être non confirmées, empêchant l'utilisation d'une troisième transaction contenant un
bump de frais CPFP en raison de la limite de TRUC de deux transactions non confirmées. Teinturier a
identifié un problème similaire si une chaîne de [splices][topic splicing] était utilisée. La
discussion n'a jamais abouti à une conclusion claire, mais une solution de contournement consistant
à s'assurer que chaque transaction contenait sa propre ancre pour le bumping de frais CPFP (comme
requis avant TRUC) semblait satisfaisante, avec l'espoir que le [mempool en cluster][topic cluster
mempool] pourrait permettre d'assouplir certaines règles TRUC à l'avenir pour permettre un bumping
de frais CPFP plus flexible.

Sur le sujet des changements de politique TRUC alimentés par les avancées du mempool en cluster,
Gregory Sanders a décrit plusieurs idées pour des [changements de politique futurs][news289 pcmtruc]. En
contraste, Suhas Daftuar [a analysé][news289 oldtruc] toutes les transactions reçues par son nœud de
l'année précédente pour voir comment une politique TRUC enrichie aurait affecté l'acceptation de ces
transactions. La plupart des transactions précédemment acceptées sous la politique de CPFP carve-out
auraient également été acceptées sous une politique TRUC enrichie, mais il y avait quelques
exceptions qui pourraient nécessiter des changements de logiciel avant qu'une politique enrichie
puisse être adoptée.

Après la vague de discussions en début d'année, mai et juin ont vu une
Une série de fusions ajoutant le support de nouvelles fonctionnalités de relais à Bitcoin Core. Une
[forme limitée][news301 1p1c] de [relais de paquets][topic package relay] un-parent-un-enfant (1p1c)
ne nécessitant aucun changement au protocole P2P a été ajoutée. Un [merge subséquent][news304 bcc30000] a augmenté la
fiabilité du relais de paquets 1p1c en améliorant la gestion des transactions orphelines par Bitcoin
Core. La [spécification pour TRUC a été fusionnée dans le répertoire BIPs][news306 bip431] comme [BIP431][]. Les
transactions TRUC sont devenues relayables par défaut avec un [autre merge][news307 bcc29496]. Le support a également
été [ajouté][news309 1p1crbf] pour le clusters 1p1c de [RBF][topic rbf]  (incluant les paquets TRUC).

Deux développeurs de longue date ont écrit des [critiques approfondies][news313 crittruc] de TRUC en juillet, bien que
d'autres développeurs aient répondu à leurs préoccupations. Une [critique supplémentaire][news315 crittruc] par les
mêmes deux développeurs a été publiée en août.

Les développeurs de Bitcoin Core ont continué à travailler sur des améliorations de relais, en
fusionnant le [support][news315 p2a] pour les paiements vers des [ancres éphémères][topic ephemeral anchors] (P2A) en août et en lançant
Bitcoin Core 28.0 en octobre avec le support pour le relais de paquets 1p1c, le relais de
transactions TRUC, le RBF de paquets et le remplacement de frères et sœurs, et un type de script de
sortie P2A standard. Gregory Sanders, qui a contribué au développement de toutes ces
fonctionnalités, a [décrit][news324 guide] comment les développeurs de portefeuilles et d'autres logiciels utilisant
Bitcoin Core pour créer ou diffuser des transactions peuvent tirer parti des nouvelles capacités.

Plus tard dans l'année, le support pour les [sorties de poussière éphémère][topic ephemeral anchors] utilisant P2A a été
standardisé dans un [merge][news330 dust]. Cela permet à une transaction ne payant aucune frais d'être augmentée
par une transaction enfant payant tous les frais pertinents---un type purement exogène de [source de
frais][topic fee sourcing].

La dernière newsletter régulière de l'année d'Optech a résumé une [réunion][news333 prclub] du Bitcoin Core Pull
Request Review Club qui a discuté d'améliorations supplémentaires pour le relais de paquets 1p1c.
</div>

## Juillet

{:#bolt11blind}
Elle Mouton a proposé un BLIP pour ajouter un [champ de chemin aveuglé aux factures BOLT11][news310 path],
permettant aux destinataires de paiement de cacher leur identité de nœud et les pairs de canal. Par
exemple, Bob pourrait ajouter un chemin aveuglé à sa facture, permettant à Alice de payer de manière
privée si son logiciel le supporte ; sinon, elle recevrait une erreur. Mouton voit cela comme une
solution temporaire jusqu'à ce que les [offres][topic offers], qui supportent nativement les chemins aveuglés,
soient largement adoptées. La proposition est devenue [BLIP39][] en [août][news317 blip39].

{:#chilldkg}
Tim Ruffing et Jonas Nick ont proposé ChillDKG, un brouillon de BIP et une implémentation de
référence pour [générer de manière sécurisée des clés pour des signatures seuil sans script de style
FROST][news312 chilldkg] compatibles avec les [signatures schnorr][topic schnorr signatures] de Bitcoin.
ChillDKG combine un algorithme de
génération de clés bien connu pour FROST avec des primitives cryptographiques modernes pour partager
de manière sécurisée des composants de clé aléatoires parmi les participants tout en assurant
l'intégrité et la non-censure. Il utilise l'échange de clés Diffie-Hellman sur courbe elliptique
(ECDH) pour le chiffrement et la diffusion de l'authentification pour vérifier les transcriptions
de sessions signées. Les participants confirment
l'intégrité de la session avant d'accepter la clé publique finale. Ce protocole simplifie la gestion
des clés, nécessitant que les utilisateurs sauvegardent uniquement leur graine privée et certaines
données de récupération non sensibles. Les plans visant à chiffrer les données de récupération en
utilisant la graine visent à améliorer la confidentialité et à simplifier davantage les sauvegardes
des utilisateurs.

{:#musigthresh}
Juillet a vu la [fusion][news310 musig] de plusieurs BIPs qui aideront différents logiciels à interagir pour créer
des signatures [MuSig2][topic musig]. Plus tard dans le mois, Sivaram Dhakshinamoorthy a [annoncé][news315
threshsig] une proposition de BIP pour créer des [signatures seuil][topic threshold signature] sans script pour
l'implémentation de Bitcoin des [signatures schnorr][topic schnorr signatures]. Cela permet à un
ensemble de signataires ayant déjà effectué une procédure de configuration (par exemple, en
utilisant ChillDKG) de créer de manière sécurisée des signatures qui ne nécessitent l'interaction
que d'un sous-ensemble dynamique de ces signataires. Les signatures sont indiscernables
onchain des signatures schnorr créées par des utilisateurs single-sig et des utilisateurs de
multisignature sans script, améliorant la confidentialité et la fongibilité.

## Août

{:#hyperion}
Sergi Delgado a [publié][news314 hyperion] Hyperion, un simulateur de réseau qui suit comment les données se propagent à
travers un réseau Bitcoin simulé. Le travail est initialement motivé par le désir de comparer la
méthode actuelle de Bitcoin pour relayer les annonces de transactions avec la proposition de méthode [Erlay][topic erlay].

{:#fullrbf}
Le développeur 0xB10C a [enquêté][news315 cb] sur la fiabilité récente de la reconstruction de [bloc
compact][topic compact block relay]. Parfois, de nouveaux blocs incluent des transactions qu'un nœud
n'a pas vues auparavant. Dans ce cas, le nœud recevant un bloc compact a généralement besoin de
demander ces transactions au pair émetteur puis d'attendre que le pair réponde. Cela ralentit la
propagation du bloc. La recherche a aidé à motiver la prise en compte d'une demande de PR pour
activer [mempoolfullrbf][topic rbf] par défaut dans Bitcoin Core, qui a été plus tard [fusionnée][news315 rbfdefault].

<div markdown="1" class="callout" id="covs">
## Résumé 2024 : Covenants et mises à jour de script

Plusieurs développeurs ont consacré une grande partie de leur temps en 2024 à faire avancer les
propositions pour les [covenants][topic covenants], les mises à jour de script et d'autres
changements qui soutiendraient des protocoles de contrat avancés tels que [joinpools][topic
joinpools] et les [usines à canaux][topic channel factories].

Fin décembre 2023, Johan Torås Halseth a [annoncé][news283 elftrace] un programme de preuve de concept qui peut utiliser
l'opcode `OP_CHECKCONTRACTVERIFY` de la proposition de soft fork [MATT][topic acc] pour permettre à
une partie dans un protocole de contrat de réclamer de l'argent si un programme arbitraire s'est
exécuté avec succès. C'est similaire en concept à [BitVM][topic acc] mais plus simple dans son
implémentation Bitcoin en utilisant un opcode spécifiquement conçu pour la vérification de
l'exécution du programme. Elftrace fonctionne avec des programmes compilés pour l'architecture
RISC-V en utilisant le format ELF de Linux ; presque tous les programmeurs peuvent facilement créer
des programmes pour cette cible, rendant l'utilisation d'elftrace très accessible. Halseth a fourni
une mise à jour sur Elftrace en août lorsqu'il a acquis la [capacité][news315 elftracezk] de vérifier les preuves à
connaissance nulle en combinaison avec l'opcode [OP_CAT][topic op_cat].

Janvier a vu l'[annonce][news285 lnhance] de la proposition de soft fork combiné LNHANCE qui inclut
les propositions précédentes pour [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV) et
[OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] (CSFS) ainsi qu'une nouvelle proposition pour un
`OP_INTERNALKEY` qui place la clé interne taproot sur la pile. Plus tard dans l'année, la
proposition serait [mise à jour][news330 paircommit] pour inclure également un opcode
`OP_PAIRCOMMIT` qui fournit une capacité similaire à `OP_CAT` mais délibérément limitée dans sa
composabilité. La proposition vise à permettre le déploiement de [LN-Symmetry][topic eltoo], des
joinpools de style [Ark][topic ark], des [DLCs][topic dlc] à signature réduite, et des
[coffre-forts][topic vaults], parmi d'autres avantages décrits des propositions sous-jacentes, telles que
le contrôle de congestion de style CTV et la délégation de signature de style CSFS.

Chris Stewart a [publié][news285 64bit] un projet de BIP pour activer les opérations arithmétiques
64 bits dans Bitcoin Script lors d'un futur soft fork. Bitcoin permet actuellement uniquement des
opérations 32 bits (en utilisant des entiers signés, donc les nombres supérieurs à environ 2
milliards ne peuvent pas être utilisés). Le support pour les valeurs 64 bits serait particulièrement
utile dans toute construction qui doit opérer sur le nombre de satoshis payés dans une sortie, car
cela est spécifié en utilisant un entier 64 bits. La proposition a reçu des discussions
supplémentaires à la fois en [février][news290 64bit] et en [juin][news306 64bit].

Également en février, le développeur Rijndael a créé une [implémentation de preuve de
concept][news291 catvault] pour un [coffre-fort][topic vaults] qui dépend uniquement des règles de
consensus actuelles plus la proposition d'opcode [OP_CAT][topic op_cat]. Optech a comparé le coffre-fort `OP_CAT`
aux coffre-forts possibles aujourd'hui avec des transactions pré-signées et aux coffre-forts possibles si
[BIP345][] `OP_VAULT` était ajouté à Bitcoin.

<table>
  <tr>
    <th></th>
    <th>Pré-signé</th>
    <th markdown="span">

    BIP345 `OP_VAULT`

    </th>
    <th markdown="span">

    `OP_CAT` avec schnorr

    </th>
  </tr>

  <tr>
    <th>Disponibilité</th>
    <td markdown="span">

    **Maintenant**

    </td>
    <td markdown="span">

    Nécessite un soft fork de `OP_VAULT` et [OP_CTV][topic op_checktemplateverify]

    </td>
    <td markdown="span">

    Nécessite un soft fork de `OP_CAT`

    </td>
  </tr>

  <tr>
    <th markdown="span">Attaque de remplacement d'adresse de dernière minute</th>
    <td markdown="span">Vulnérable</td>
    <td markdown="span">

    **Non vulnérable**

    </td>
    <td markdown="span">

    **Non vulnérable**

    </td>
  </tr>

  <tr>
    <th markdown="span">Retraits de montants partiels</th>
    <td markdown="span">Seulement si pré-arrangé</td>
    <td markdown="span">

    **Oui**

    </td>
    <td markdown="span">Non</td>
  </tr>

  <tr>
    <th markdown="span">Adresses de dépôt statiques et calculables de manière non interactive</th>
<td markdown="span">Non</td>    <td markdown="span">

    **Oui**

    </td>
    <td markdown="span">

    **Oui**

    </td>
  </tr>

  <tr>
<th markdown="span">Regroupement pour la mise en quarantaine ou le re-vaulting afin d'économiser sur
les frais</th>
    <td markdown="span">Non</td>
    <td markdown="span">

    **Oui**

    </td>
    <td markdown="span">Non</td>
  </tr>

  <tr>
    <th markdown="span">

    Efficacité opérationnelle dans le meilleur cas, c'est-à-dire uniquement pour les dépenses
    légitimes<br>*(estimé très approximativement par Optech)*

    </th>
    <td markdown="span">

    **2x la taille d'un single-sig régulier**

    </td>
    <td markdown="span">3x la taille d'un single-sig régulier</td>
    <td markdown="span">4x la taille d'un single-sig régulier</td>
  </tr>
</table>

En mars, le développeur ZmnSCPxj [a décrit][news293 forkbet] un protocole permettant de donner le
contrôle d'un UTXO à une partie qui prédit correctement si un soft fork particulier sera activé ou
non. D'autres ont proposé cette idée de base auparavant, mais la version de ZmnSCPxj traite des
spécificités attendues pour au moins un futur soft fork potentiel, [OP_CHECKTEMPLATEVERIFY][topic
op_checktemplateverify].

Mars a également vu Anthony Towns commencer à travailler sur un langage de script alternatif pour
Bitcoin basé sur le langage Lisp. Il a fourni un [aperçu][news293 chialisp] du langage de style Lisp
déjà utilisé par l'altcoin Chia et [a proposé][news294 btclisp] un langage BTC Lisp. Plus tard dans
l'année, inspiré par la relation entre Bitcoin Script et [miniscript][topic miniscript], il a
[divisé][news331 bll] son projet Lisp en deux parties : un langage bitcoin lisp de bas niveau (bll)
qui pourrait être ajouté à Bitcoin dans un soft fork et un langage de haut niveau symbll (symbll)
qui est converti en bll. Il a également [décrit][news331 earmarks] une construction générique
compatible avec symbll (et probablement [Simplicity][topic simplicity]) qui permet de partitionner
un UTXO en montants spécifiques et conditions de dépense. Il a montré comment ces _marques de
monnaie flexibles_ peuvent être utilisées, y compris des améliorations dans la sécurité et
l'usabilité des canaux LN (y compris les canaux basés sur [LN-Symmetry][topic eltoo]), une
alternative à la version [BIP345][] des coffres-forts, et un design de [pool de paiement][topic
joinpools].

Jeremy Rubin a proposé [deux mises à jour][news302 ctvext] au design de `OP_CHECKTEMPLATEVERIFY` en
mai : un support optionnel pour un digest de hash plus court et un support pour des engagements
supplémentaires. Cela a aidé à optimiser CTV pour une utilisation dans des schémas de publication de
données qui pourraient être utiles pour récupérer des données critiques dans [LN-Symmetry][topic
eltoo] et des protocoles similaires.

Pierre Rochard [a demandé][news305 overlap] si les propositions de soft qui peuvent fournir beaucoup
des mêmes fonctionnalités à un coût similaire devraient être considérés comme mutuellement
exclusives, ou s'il serait logique d'activer plusieurs propositions et de laisser les développeurs
utiliser l'alternative qu'ils préfèrent.

Jeremy Rubin [a publié][news306 fecov] un document théorisant l'utilisation du chiffrement
fonctionnel pour ajouter une gamme complète de comportements de covenant à
Bitcoin sans recourir à des changements de consensus. En essence, le chiffrement fonctionnel permettrait la
création d'une clé publique qui correspondrait à un programme particulier. Une partie qui pourrait
satisfaire le programme serait capable de créer une signature qui correspondrait à la clé publique
(sans jamais apprendre une clé privée correspondante). Cela est toujours plus privé et économisera
souvent de l'espace par rapport aux covenants précédemment proposés. Malheureusement, un
inconvénient majeur du chiffrement fonctionnel, selon Rubin, est qu'il s'agit d'une "cryptographie
sous-développée qui la rend impraticable à utiliser actuellement".

Anthony Towns a posté un [script][news306 catfaucet] pour [signet][topic signet] qui utilise
[OP_CAT][topic op_cat] pour permettre à quiconque de dépenser des pièces envoyées au script en
utilisant la preuve de travail (PoW). Cela peut être utilisé comme un faucet de signet-bitcoin
décentralisé : quand un mineur ou un utilisateur obtient des signet bitcoins en excès, ils les
envoient au script. Lorsqu'un utilisateur veut plus de signet bitcoins, il cherche dans l'ensemble
UTXO les paiements au script, génère du PoW, et crée une transaction qui utilise son PoW pour
réclamer les pièces.

Victor Kolobov [a annoncé][news319 catmillion] un fonds de 1 million de dollars pour la recherche
sur une proposition de soft fork pour ajouter un opcode `OP_CAT`. Les soumissions doivent être
reçues avant le 1er janvier 2025.

En novembre, Towns [a résumé][news330 sigactivity] l'activité sur le signet par défaut liée aux
propositions de soft forks disponibles via Bitcoin Inquisition. Vojtěch Strnad, inspiré par le post de Towns, a
créé un site web qui liste "chaque transaction faite sur le signet Bitcoin qui utilise l'un des soft
forks déployés."

Ethan Heilman [a posté][news330 covgrind] un papier qu'il a coécrit avec Victor Kolobov, Avihu Levy,
et Andrew Poelstra sur la manière dont les covenants peuvent être créés facilement sans changements
de consensus, bien que dépenser de ces covenants nécessiterait des transactions non standard et des
millions (ou milliards) de dollars en matériel spécialisé et en électricité. Heilman note qu'une
application de ce travail permettrait aux utilisateurs aujourd'hui d'inclure facilement un chemin de
dépense taproot de secours qui pourrait être utilisé de manière sécurisée si une résistance
quantique était soudainement nécessaire et que les opérations de signature de courbe elliptique sur
Bitcoin étaient désactivées. Le travail semblait être inspiré en partie par plusieurs des recherches
[précédentes][news301 lamport] des auteurs sur les signatures de Lamport pour Bitcoin.

Décembre s'est conclu avec un [sondage sur les opinions des développeurs][news333 covpoll]
concernant des propositions de covenant sélectionnées.

_À partir de janvier 2025, Optech commencera à résumer les recherches et développements notables
liés aux covenants, mises à jour de script, et changements connexes dans une section spéciale
publiée dans la première newsletter de chaque mois. Nous encourageons tous ceux qui travaillent sur
ces propositions à publier tout ce qui pourrait intéresser nos [sources habituelles][optech sources]
afin que nous puissions en parler._

</div>

## Septembre

{:#hybridjamming}
Carla Kirk-Cohen a décrit les tests et ajustements d'une [mitigation de brouillage de canal
hybride][news322 jam] initialement proposée par Clara Shikhelman et Sergei Tikhomirov. Les
tentatives de brouillage d'un canal pendant une heure ont principalement échoué, les attaquants
dépensant soit plus que lors d'attaques connues, soit augmentant involontairement les revenus de la
cible. Cependant, une _attaque de trou nooir_ a effectivement sapé la réputation d'un nœud en sabotant
les paiements à travers des routes plus courtes. Pour contrer cela, une réputation bidirectionnelle a été ajoutée
à [l'aval du HTLC][topic htlc endorsement], rapprochant la proposition d'une idée initialement
proposée en 2018 par Jim Posen. Les nœuds évaluent désormais la fiabilité tant de l'expéditeur que
du destinataire lorsqu'ils décident de faire suivre les paiements. Les nœuds fiables reçoivent des
HTLCs avalisés, tandis que les expéditeurs ou destinataires moins fiables font face à un rejet ou à
un transfert non avalisé. Ces tests ont suivi une [spécification de l'aval de HTLC][news316 htlce]
et une [implémentation dans Eclair][news315 htlce]. Une [implémentation pour LND][news332 htlce] a
également été ajoutée peu avant la fin de l'année.

{:#shieldedcsv}
Jonas Nick, Liam Eagen et Robin Linus ont introduit un nouveau protocole de [validation côté
client][topic client-side validation] (CSV), [Shielded CSV][news322 csv], qui permet les transferts
de jetons sécurisés par la preuve de travail de Bitcoin sans révéler les détails des jetons ou les
historiques de transfert. Contrairement aux protocoles existants, où les clients doivent valider
d'extensives historiques de jetons, Shielded CSV utilise des preuves à divulgation nulle de
connaissance pour garantir que la vérification nécessite des ressources fixes tout en préservant la
vie privée. De plus, Shielded CSV réduit les exigences de données onchain en regroupant des
milliers de transferts de jetons dans une seule mise à jour de 64 octets par transaction Bitcoin,
améliorant ainsi l'évolutivité. Le document explore le pontage sans confiance de Bitcoin vers CSV
via [BitVM][topic acc], les structures basées sur des comptes, la gestion des réorganisations de la
blockchain, les transactions non confirmées et les extensions potentielles. Ce protocole promet des
améliorations significatives en termes d'efficacité et de confidentialité par rapport à d'autres
systèmes de jetons.

{:#lnoff}
Andy Schroder a décrit un processus pour [activer les paiements LN hors ligne][news321 lnoff] en
générant des jetons d'authentification en ligne, permettant au portefeuille du dépensier d'autoriser
les paiements via leur nœud toujours en ligne ou LSP lorsqu'ils sont hors ligne. Les jetons peuvent
être transférés au destinataire via NFC ou d'autres protocoles simples, permettant les paiements
sans accès à Internet. Le développeur ZmnSCPxj a proposé une alternative, et Bastien Teinturier a
fait référence à sa méthode de contrôle de nœud à distance pour des cas d'utilisation similaires,
améliorant les solutions de paiement hors ligne pour les appareils à ressources limitées comme les
cartes intelligentes.

## Octobre

{:#offers}
La spécification [BOLT12][] des [offres][topic offers] a été [fusionnée][news323 offers].
[Initialement proposée][news72 offers] en 2019, les offres permettent à deux nœuds de négocier des
factures et des paiements sur LN en utilisant [des messages en oignon][topic onion messages]. Les
messages en oignon et les paiements compatibles avec les offres peuvent utiliser [des chemins
aveuglés][topic rv routing] pour empêcher le dépensier de connaître l'identité du nœud du
destinataire.

{:#pooledmining}
Une [nouvelle interface de minage][news325 mining] pour Bitcoin Core a vu le jour avec pour objectif
de soutenir les mineurs utilisant le protocole [Stratum v2][topic pooled mining] qui peut être
configuré pour permettre à chaque mineur de sélectionner ses propres transactions. Cependant,
Anthony Towns a noté plus tôt dans l'année que la sélection indépendante des transactions pourrait
[augmenter les coûts de validation des parts][news315 shares] pour les pools de minage. Si ces pools
répondaient en limitant la validation, cela pourrait permettre une attaque par parts invalides
similaire à la bien connue [attaque par retenue de bloc][topic block withholding]. Une solution
proposée en 2011 aux attaques par retenue était discutée, bien qu'elle nécessiterait un changement
de consensus difficile.

<div markdown="1" class="callout" id="releases">
## Résumé 2024 : Principales sorties de projets d'infrastructure populaires

- [LDK 0.0.119][] a ajouté le support pour recevoir des paiements via des [chemins aveuglés][topic
  rv routing] multi-sauts.

- [HWI 2.4.0][] a ajouté le support pour Trezor Safe 3.

- [Core Lightning 24.02][] a inclus des améliorations au plugin `recover` qui "rendent les
  récupérations d'urgence moins stressantes", des améliorations aux [canaux d'ancrage][topic anchor
  outputs], une synchronisation de la chaîne de blocs 50% plus rapide, et un correctif de bug pour
  l'analyse d'une grande transaction trouvée sur le testnet.

- [Eclair v0.10.0][] "a ajouté un support officiel pour la [fonction de financement double][topic dual
  funding], une mise en œuvre à jour des [offres][topic offers] BOLT12, et un prototype de
  [splicing][topic splicing] pleinement fonctionnel".

- [Bitcoin Core 27.0][] a déprécié libbitcoinconsensus, activé par défaut le [transport P2P crypté
  v2][topic v2 p2p transport], a autorisé l'utilisation de la politique de transaction opt-in
  topologiquement restreinte jusqu'à confirmation [TRUC][topic v3 transaction relay] sur les réseaux de test,
  et ajouté une nouvelle stratégie de [sélection de pièces][topic coin selection] à utiliser pendant
  les périodes de frais élevés.

- [BTCPay Server 1.13.1][] (et les versions précédentes) ont rendus les webhooks plus extensibles,
  ajouté le support pour l'importation de portefeuilles multisig [BIP129][], amélioré la flexibilité
  des plugins et commencé la migration de tout le support d'altcoin vers des plugins, et ajouté le
  support pour les [PSBTs][topic psbt] encodés BBQr.

- [Bitcoin Inquisition 25.2][] a ajouté le support pour [OP_CAT][topic op_cat] sur signet.

- [Libsecp256k1 v0.5.0][] a accéléré la génération de clés et la signature et réduit la taille
  compilée "ce que [ses développeurs] s'attendent à bénéficier particulièrement aux utilisateurs
  embarqués."

- [LDK v0.0.123][] a inclus une mise à jour de ses paramètres pour les [HTLCs coupés][topic trimmed
  htlc] et des améliorations au support des [offres][topic offers].

- [Bitcoin Inquisition 27.0][] a ajouté l'application de [OP_CAT][] sur signet comme spécifié dans
  [BIN24-1][] et [BIP347][]. Il a également inclus "une nouvelle sous-commande `evalscript` pour
  `bitcoin-util` qui peut être utilisée pour tester le comportement des opcodes de script". Le support
  a été supprimé pour `annexdatacarrier` et les pseudo [ancres éphémères][topic ephemeral anchors].

- [LND v0.18.0-beta][] a ajouté un support expérimental pour les _frais de routage entrants_, la
  recherche de chemin pour les [chemins aveuglés][topic rv routing], les [watchtowers][topic
  watchtowers] pour les [canaux taproot simples][topic simple taproot channels], et a simplifié
  l'envoi d'informations de débogage cryptées.

- [Core Lightning 24.05][] a amélioré la compatibilité avec les nœuds complets élagués, permet au
  RPC `check` de fonctionner avec des plugins, permet une livraison plus robuste des factures
  d'[offre][topic offers], et a corrigé un problème de surpaiement de frais lorsque l'option de
  configuration `ignore_fee_limits` est utilisée.

- [HWI 3.1.0][] a ajouté le support pour Trezor Safe 5.

- [Bitcoin Core 28.0][] a ajouté le support pour [testnet4][topic testnet],
  l'opportunisme un-parent-un-enfant (1p1c) des [relais de paquets][topic package relay], relais par
  défaut des transactions opt-in topologiquement restreintes jusqu'à confirmation ([TRUC][topic v3
  transaction relay]), relais par défaut des transactions [pay-to-anchor][topic ephemeral anchors],
  relais limité de paquets [RBF][topic rbf], et [full-RBF][topic rbf] par défaut. Les paramètres par
  défaut pour [assumeUTXO][topic assumeutxo] ont été ajoutés, permettant l'utilisation de la RPC
  `loadtxoutset` avec un ensemble UTXO téléchargé en dehors du réseau Bitcoin (par exemple, via un
  torrent).

- [BTCPay Server 2.0.0][] a ajouté "une meilleure localisation, une navigation latérale, un flux
  d'intégration amélioré, des options de personnalisation améliorées, [et] un support pour des
  fournisseurs de taux plugables." La mise à niveau comprend quelques changements majeurs et des
  migrations de base de données.

- [Libsecp256k1 0.6.0][] "a ajouté un module [MuSig2][topic musig], une méthode significativement
  plus robuste pour effacer les secrets de la pile, et a supprimé les fonctions
  `secp256k1_scratch_space` inutilisées."

- [BDK 0.30.0][] est préparé pour la mise à niveau anticipée à la version 1.0 de la bibliothèque.

- [Eclair v0.11.0][] "a ajouté un support officiel pour les [offres][topic offers] BOLT12 et a
  progressé sur les fonctionnalités de gestion de liquidité ([splicing][topic splicing], [publicités
  de liquidité][topic liquidity advertisements], et [financement à la volée][topic jit channels])." La
  version a également cessé d'accepter de nouveaux [canaux non-ancré][topic anchor outputs].

- [Core Lightning 24.11][] contenait un nouveau plugin expérimental pour effectuer des paiements
  utilisant une sélection de route avancée ; payer et recevoir des paiements vers les [offres][topic
  offers] était activé par défaut ; et plusieurs améliorations au [splicing][topic splicing] ont été
  ajoutées.
</div>

## Novembre

{:#superscalar}
ZmnSCPxj a proposé la conception [SuperScalar][news327 superscalar] pour une [usine de canaux][topic
channel factories] utilisant des [arborescences à délai d'expiration][topic timeout trees] afin de permettre aux
utilisateurs de LN d'ouvrir des canaux et d'accéder à la liquidité de manière plus abordable tout en
maintenant l'absence de confiance. La conception utilise une arborescence à délai d'expiration superposé qui exige que
le fournisseur de services paie tous les coûts de mise de l'arborescence onchain ou perde tous les
fonds restants dans l'arborescence. Cela encourage le fournisseur de services à inciter les utilisateurs à
fermer leurs canaux de manière coopérative pour éviter le besoin d'aller onchain. La
conception utilise à la fois des [canaux de micropaiement duplex][topic duplex micropayment
channels] et des canaux de paiement [LN-Penalty][topic ln-penalty], tous deux possibles sans aucun
changement de consensus. Malgré sa complexité---combinant plusieurs types de canaux et gérant l'état
offchain---la conception peut être mise en œuvre par un seul vendeur sans nécessiter de grands
changements de protocole. Pour soutenir la conception, ZmnSCPxj a plus tard proposé un [ajustement
d'usine de canaux pluggable][news330 plug] à la spécification LN.

{:#opr}
John Law a [proposé][news329 opr] un protocole de micropaiement de résolution de paiement offchain (OPR)
qui exige que les deux participants contribuent à un fonds pouvant être effectivement
détruit à tout moment par l'un ou l'autre participant. Cela crée une incitation pour les deux
parties à apaiser l'autre ou risquer une destruction mutuelle assurée (MAD) des fonds liés. Le protocole n'est pas sans
confiance, mais il est plus évolutif que les alternatives, offre une résolution rapide et n'oblige
pas les parties à publier des données onchain avant l'expiration des verrous temporels. Cela
peut rendre OPR beaucoup plus efficace à l'intérieur d'une [usine de canaux][topic channel
factories], d'[arborescence à délai d'expiration][topic timeout trees], ou autre structure imbriquée qui idéalement
garderait les portions imbriquées offchain.

<div markdown="1" class="callout" id="optech">
## Résumé 2024 : Bitcoin Optech

Pour la septième année d'Optech, nous avons publié 51 bulletins d'information hebdomadaires et
ajouté 35 nouvelles pages à notre [index des sujets][]. En tout, Optech a publié plus de 120 000
mots en anglais sur la recherche et le développement logiciel Bitcoin cette année, l'équivalent
approximatif d'un livre de 350 pages.

Chaque bulletin et article de blog a été traduit en chinois, tchèque, français et japonais,
totalisant plus de 200 traductions en 2024.

De plus, chaque bulletin de cette année a été accompagné d'un épisode de [podcast][], totalisant
plus de 59 heures sous forme audio et 488 000 mots sous forme de transcript. De nombreux
contributeurs de premier plan de Bitcoin ont été invités à l'émission - certains à plus d'un épisode
- avec un total de 75 invités uniques différents en 2024 :

- Abubakar Sadiq Ismail (x2)
- Adam Gibson
- Alex Bosworth
- Andrew Toth (x3)
- Andy Schroder
- Anthony Towns (x5)
- Antoine Poinsot (x5)
- Antoine Riard (x2)
- Armin Sabouri
- Bastien Teinturier (x4)
- Bob McElrath
- Brandon Black (x3)
- Bruno Garcia
- callebtc
- Calvin Kim
- Chris Stewart (x3)
- Christian Decker
- Dave Harding (x3)
- David Gumberg
- /dev/fd0
- Dusty Daemon
- Elle Mouton (x2)
- Eric Voskuil
- Ethan Heilman (x2)
- Eugene Siegel
- Fabian Jahr (x5)
- Filippo Merli
- Gloria Zhao (x10)
- Gregory Sanders (x7)
- Hennadii Stepanov
- Hunter Beast
- Jameson Lopp (x2)
- Jason Hughes
- Jay Beddict
- Jeffrey Czyz
- Johan Torås Halseth
- Jonas Nick (x2)
- Joost Jager
- Josie Baker
- Kulpreet Singh
- Lorenzo Bonazzi
- Luke Dashjr
- Matt Corallo (x3)
- Moonsettler (x2)
- Nicholas Gregory
- Niklas Gögge (x2)
- Oghenovo Usiwoma
- Olaoluwa Osuntokun
- Oliver Gugger
- Peter Todd
- Pierre Corbin
- Pierre Rochard
- Pieter Wuille
- René Pickhardt (x2)
- Richard Myers
- Rijndael
- rkrux
- Russell O’Connor
- Salvatore Ingala (x2)
- Sebastian Falbesoner
- SeedHammer Team
- Sergi Delgado
- Setor Blagogee
- Shehzan Maredia
- Sivaram Dhakshinamoorthy
- Stéphan Vuylsteke
- Steven Roose
- Tadge Dryja
- TheCharlatan
- Tom Trevethan- Tony Klausing
- Valentine Wallace
- Virtu
- Vojtěch Strnad (x2)
- ZmnSCPxj (x3)

Optech a eu la chance et est reconnaissant d'avoir reçu une contribution de 20 000 USD de la part de
la [Fondation pour les Droits de l'Homme][]. Ces fonds seront utilisés pour payer l'hébergement web,
les services de messagerie, les transcriptions de podcasts et d'autres dépenses qui nous permettent
de continuer et d'améliorer notre diffusion de contenu technique à la communauté Bitcoin.

</div>

## Décembre

Décembre a vu la continuation de plusieurs discussions et l'annonce de multiples vulnérabilités,
toutes résumées plus tôt dans ce bulletin.

*Nous remercions tous les contributeurs Bitcoin nommés ci-dessus, ainsi que les nombreux autres dont
le travail était tout aussi important, pour une autre année incroyable de développement Bitcoin. Le
bulletin hebdomadaire Optech reprendra son calendrier de publication régulier le vendredi 3 janvier.*

<style>
#optech ul {
  max-width: 800px;
  display: flex;
  flex-wrap: wrap;
  list-style: none;
  padding: 0;
  margin: 0;
  justify-content: center;
}

#optech li {
  flex: 1 0 220px;
  max-width: 220px;
  box-sizing: border-box;
  padding: 5px;
  margin: 5px;
}

@media (max-width: 720px) {
  #optech li {
    flex-basis: calc(50% - 10px);
  }
}

@media (max-width: 360px) {
  #optech li {
    flex-basis: calc(100% - 10px);
  }
}
</style>

{% include snippets/recap-ad.md when="2024-12-23 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="" %}
[index des sujets]: /en/topics/
[yirs 2018]: /en/newsletters/2018/12/28/
[yirs 2019]: /en/newsletters/2019/12/28/
[yirs 2020]: /fr/newsletters/2020/12/23/
[yirs 2021]: /fr/newsletters/2021/12/22/
[yirs 2022]: /fr/newsletters/2022/12/21/
[yirs 2023]: /fr/newsletters/2023/12/20/
[news283 feelocks]: /fr/newsletters/2024/01/03/#timelocks-dependant-des-frais
[news283 exits]: /fr/newsletters/2024/01/03/#regroupement-des-paiements-de-sortie-de-pool-avec-delegation-a-l-aide-de-preuves-de-fraude
[news284 lnsym]: /fr/newsletters/2024/01/10/#implementation-de-recherche-ln-symmetry
[news288 rbfr]: /fr/newsletters/2024/02/07/#proposition-de-remplacement-par-feerate-pour-echapper-au-pinning
[news290 dns]: /fr/newsletters/2024/02/21/#instructions-de-paiement-bitcoin-lisibles-par-l-homme-basees-sur-dns
[news290 asmap]: /fr/newsletters/2024/02/21/#amelioration-du-processus-de-creation-de-asmap-reproductible
[news290 dualfund]: /fr/newsletters/2024/02/21/#bolts-851
[news291 bets]: /fr/newsletters/2024/02/28/#contrat-sans-confiance-pour-les-futures-sur-les-frais-de-transaction-des-mineurs
[news295 fees]: /fr/newsletters/2024/03/27/#estimation-du-taux-de-frais-basee-sur-le-mempool
[news295 sponsor]: /fr/newsletters/2024/03/27/#ameliorations-du-parrainage-des-frais-de-transaction
[news286 binana]: /fr/newsletters/2024/01/24/#nouveau-referentiel-de-documentation
[news292 bips]: /fr/newsletters/2024/03/06/#discussion-sur-l-ajout-de-plus-d-editeurs-bip
[news296 ccsf]: /fr/newsletters/2024/04/03/#revisiter-le-nettoyage-du-consensus
[news299 bips]: /fr/newsletters/2024/04/24/#mise-a-jour-des-editeurs-bip
[news297 bips]: /fr/newsletters/2024/04/10/#mise-a-jour-de-bip2
[news297 inbound]: /fr/newsletters/2024/04/10/#lnd-6703
[news299 weakblocks]: /fr/newsletters/2024/04/24/#implementation-de-preuve-de-concept-pour-les-blocs-faibles
[news297 testnet]: /fr/newsletters/2024/04/10/#discussion-sur-la-reinitialisation-et-la-modification-du-testnet
[news300 arrest]: /fr/newsletters/2024/05/01/#arrestations-de-developpeurs-bitcoin
[news308 sp]: /fr/newsletters/2024/06/21/#discussion-continue-sur-les-psbt-pour-les-paiements-silencieux
[news304 sp]: /fr/newsletters/2024/05/24/#discussion-sur-les-psbt-pour-les-paiements-silencieux
[news305 splite]: /fr/newsletters/2024/05/31/#protocole-client-leger-pour-les-paiements-silencieux
[news309 feas]: /fr/newsletters/2024/06/28/#estimation-de-la-probabilite-qu-un-paiement-ln-soit-realisable
[news310 path]: /fr/newsletters/2024/07/05/#ajout-d-un-champ-de-facture-bolt11-pour-les-chemins-aveugles
[news312 chilldkg]: /fr/newsletters/2024/07/19/#protocole-de-generation-de-cles-distribue-pour-frost
[news315 htlce]: /fr/newsletters/2024/08/09/#eclair-2884
[news316 htlce]: /fr/newsletters/2024/08/16/#blips-27
[news322 jam]: /fr/newsletters/2024/09/27/#tests-et-changements-de-mitigation-du-brouillage-hybride
[news332 htlce]: /fr/newsletters/2024/12/06/#lnd-8390
[news322 csv]: /fr/newsletters/2024/09/27/#validation-cote-client-protegee-csv
[news321 lnoff]: /fr/newsletters/2024/09/20/#paiements-ln-hors-ligne
[news323 offers]: /fr/newsletters/2024/10/04/#bolts-798
[news72 offers]: /en/newsletters/2019/11/13/#proposed-bolt-for-ln-offers
[news324 guide]: /fr/newsletters/2024/10/11/#guide-pour-les-portefeuilles-utilisant-bitcoin-core-28-0
[news315 shares]: /fr/newsletters/2024/08/09/#attaques-de-retention-de-blocs-et-solutions-potentielles
[news327 superscalar]: /fr/newsletters/2024/11/01/#fabriques-de-canaux-avec-arbre-de-timeout
[news330 plug]: /fr/newsletters/2024/11/22/#channel-factories-modulables
[news283 lndvuln]: /fr/newsletters/2024/01/03/#divulgation-de-vulnerabilites-passees-dans-lnd
[news285 clnvuln]: /fr/newsletters/2024/01/17/#divulgation-d-une-vulnerabilite-passee-dans-core-lightning
[news286 btcdvuln]: /fr/newsletters/2024/01/24/#divulgation-de-la-defaillance-de-consensus-corrigee-dans-btcd
[news288 bccvuln]: /fr/newsletters/2024/02/07/#divulgation-publique-d-un-bug-de-blocage-dans-bitcoin-core-affectant-ln
[news308 lndvuln]: /fr/newsletters/2024/06/21/#divulgation-d-une-vulnerabilite-affectant-d-anciennes-versions-de-lnd
[news310 wlad]: /fr/newsletters/2024/07/05/#execution-de-code-a-distance-due-a-un-bug-dans-miniupnpc
[news310 ek]: /fr/newsletters/2024/07/05/#crash-du-noeud-dos-de-plusieurs-pairs-avec-de-grands-messages
[news310 jnau]: /fr/newsletters/2024/07/05/#censure-des-transactions-non-confirmees
[news310 unamed]: /fr/newsletters/2024/07/05/#liste-d-interdiction-non-limitee-cpu-memoire-dos
[news310 ps]: /fr/newsletters/2024/07/05/#separation-de-reseau-due-a-un-ajustement-excessif-du-temps
[news310 sec.eine]: /fr/newsletters/2024/07/05/#cpu-dos-et-blocage-du-noeud-du-au-traitement-des-orphelins
[news310 jn1]: /fr/newsletters/2024/07/05/#dos-memoire-a-partir-de-grands-messages-inv
[news310 cf]: /fr/newsletters/2024/07/05/#dos-memoire-utilisant-des-en-tetes-de-faible-difficulte
[news310 jn2]: /fr/newsletters/2024/07/05/#dos-gaspillant-du-cpu-en-raison-de-demandes-malformees
[news310 mf]: /fr/newsletters/2024/07/05/#crash-lie-a-la-memoire-lors-des-tentatives-de-parse-des-uri-bip72
[news310 disclosures]: /fr/newsletters/2024/07/05/#divulgation-de-vulnerabilites-affectant-les-versions-de-bitcoin-core-anterieures-a-0-21-0
[news314 es]: /fr/newsletters/2024/08/02/#crash-a-distance-en-envoyant-des-messages-addr-excessifs
[news314 mf]: /fr/newsletters/2024/08/02/#crash-a-distance-sur-le-reseau-local-lorsque-upnp-est-active
[news322 checkpoint]: /fr/newsletters/2024/09/27/#divulgation-d-une-vulnerabilite-affectant-les-versions-de-bitcoin-core-anterieures-a-24-0-1
[news324 ng]: /fr/newsletters/2024/10/11/#cve-2024-35202-vulnerabilite-de-crash-a-distance
[news324 b10caj]: /fr/newsletters/2024/10/11/#dos-par-ensembles-d-inventaire-importants
[news324 sd]: /fr/newsletters/2024/10/11/#attaque-de-propagation-lente-de-bloc
[news328 multi]: /fr/newsletters/2024/11/08/#divulgation-d-une-vulnerabilite-affectant-les-versions-de-bitcoin-core-anterieures-a-25-1
[news317 exfil]: /fr/newsletters/2024/08/23/#protocole-anti-exfiltration-simple-mais-imparfait
[news315 exfil]: /fr/newsletters/2024/08/09/#attaque-d-exfiltration-de-seed-plus-rapide
[news332 ccsf]: /fr/newsletters/2024/12/06/#discussion-continue-sur-la-proposition-de-soft-fork-de-nettoyage-du-consensus
[news316 timewarp]: /fr/newsletters/2024/08/16/#nouvelle-vulnerabilite-de-manipulation-temporelle-dans-testnet4
[news324 btcd]: /fr/newsletters/2024/10/11/#cve-2024-38365-echec-de-consensus-btcd
[news333 if]: /fr/newsletters/2024/12/13/#vulnerabilite-permettant-le-vol-dans-les-canaux-ln-avec-l-aide-d-un-mineur
[news333 deanon]: /fr/newsletters/2024/12/13/#vulnerabilite-de-desanonymisation-affectant-wasabi-et-les-logiciels-associes
[news251 cluster]: /fr/newsletters/2023/05/17/#mempool-clustering
[news283 fees]: /fr/newsletters/2024/01/03/#estimation-des-frais-de-cluster
[news285 cluster]: /fr/newsletters/2024/01/17/#apercu-de-la-proposition-de-mempool-en-cluster
[news312 cluster]: /fr/newsletters/2024/07/19/#introduction-a-la-linearisation-des-clusters
[news314 cluster]: /fr/newsletters/2024/08/02/#bitcoin-core-30126
[news315 cluster]: /fr/newsletters/2024/08/09/#bitcoin-core-30285
[news314 mine]: /fr/newsletters/2024/08/02/#optimisation-de-la-construction-de-blocs-avec-le-cluster-de-mempool
[news331 cluster]: /fr/newsletters/2024/11/29/#bitcoin-core-31122
[news290 incentive]: /fr/newsletters/2024/02/21/#reflexion-sur-la-compatibilite-des-incitations-du-mempool
[news298 cluster]: /fr/newsletters/2024/04/17/#que-se-serait-il-passe-si-le-mempool-en-cluster-avait-ete-deploye-il-y-a-un-an
[news283 trucpin]: /fr/newsletters/2024/01/03/#couts-d-epinglage-des-transactions-v3
[news284 exo]: /fr/newsletters/2024/01/10/#discussion-sur-les-ancres-ln-et-la-proposition-de-relais-de-transaction-v3
[news285 mev]: /fr/newsletters/2024/01/17/#discussion-sur-la-valeur-extractible-par-les-mineurs-mev-dans-les-ancres-ephemeres-non-nulles
[news286 lntruc]: /fr/newsletters/2024/01/24/#changements-proposes-a-ln-pour-le-relais-v3-et-les-ancres-ephemeres
[news286 imtruc]: /fr/newsletters/2024/01/24/#logique-imbriquee-v3
[news287 sibrbf]: /fr/newsletters/2024/01/31/#remplacement-par-frais-de-parente
[news288 truc0c]: /fr/newsletters/2024/02/07/#ouverture-securisee-de-canaux-sans-confirmation-avec-des-transactions-v3
[news289 pcmtruc]: /fr/newsletters/2024/02/14/#idees-d-amelioration-du-relais-apres-le-deploiement-du-mempool-en-cluster
[news289 oldtruc]: /fr/newsletters/2024/02/14/#que-se-serait-il-passe-si-les-regles-v3-avaient-ete-appliquees-aux-sorties-d-ancrage-il-y-a-un-an
[news301 1p1c]: /fr/newsletters/2024/05/08/#bitcoin-core-28970
[news304 bcc30000]: /fr/newsletters/2024/05/24/#bitcoin-core-30000
[news306 bip431]: /fr/newsletters/2024/06/07/#bips-1541
[news29496]: /fr/newsletters/2024/06/14/#bitcoin-core-29496
[news309 1p1crbf]: /fr/newsletters/2024/06/28/#bitcoin-core-28984
[news313 crittruc]: /fr/newsletters/2024/07/26/#discussion-variee-sur-le-relai-gratuit-et-les-ameliorations-du-bumping-de-frais
[news315 crittruc]: /fr/newsletters/2024/08/09/#attaque-par-cycle-de-remplacement-contre-pay-to-anchor
[news315 p2a]: /fr/newsletters/2024/08/09/#bitcoin-core-30352
[news330 dust]: /fr/newsletters/2024/11/22/#bitcoin-core-30239
[news333 prclub]: /fr/newsletters/2024/12/13/#bitcoin-core-pr-review-club
[news283 elftrace]: /fr/newsletters/2024/01/03/#verification-de-programmes-arbitraires-a-l-aide-d-une-opcode-proposee-par-matt
[news285 lnhance]: /fr/newsletters/2024/01/17/#nouvelle-proposition-de-soft-fork-combinant-lnhance
[news285 64bit]: /fr/newsletters/2024/01/17/#proposition-de-soft-fork-pour-l-arithmetique-sur-64-bits
[news290 64bit]: /fr/newsletters/2024/02/21/#discussion-continue-sur-l-arithmetique-64-bits-et-l-opcode-op-inout-amount
[news306 64bit]: /fr/newsletters/2024/06/07/#mises-a-jour-de-la-proposition-de-soft-fork-pour-l-arithmetique-64-bits
[news291 catvault]: /fr/newsletters/2024/02/28/#prototype-simple-de-coffre-fort-utilisant-op-cat
[news293 forkbet]: /fr/newsletters/2024/03/13/#paris-sans-confiance-sur-la-blockchain-pour-les-potentiels-soft-forks
[news294 btclisp]: /fr/newsletters/2024/03/20/#apercu-de-btc-lisp
[news293 chialisp]: /fr/newsletters/2024/03/13/#apercu-de-chia-lisp-pour-les-bitcoiners
[news331 bll]: /fr/newsletters/2024/11/29/#langage-lisp-pour-le-scripting-bitcoin
[news331 earmarks]: /fr/newsletters/2024/11/29/#marquages-flexibles-de-pieces
[news302 ctvext]: /fr/newsletters/2024/05/15/#extensions-bip119-pour-des-hachages-plus-petits-et-des-engagements-de-donnees-arbitraires
[news305 overlap]: /fr/newsletters/2024/05/31/#les-propositions-de-soft-fork-qui-se-chevauchent-doivent-elles-etre-considerees-comme-mutuellement-exclusives
[news306 fecov]: /fr/newsletters/2024/06/07/#covenants-de-chiffrement-fonctionnel
[newsletters]: /fr/newsletters/
[news306 catfaucet]: /fr/newsletters/2024/06/07/#script-op-cat-pour-valider-la-preuve-de-travail
[topics index]: /en/topics/
[news315 elftracezk]: /fr/newsletters/2024/08/09/#verification-optimiste-des-preuves-a-connaissance-nulle-en-utilisant-cat-matt-et-elftrace
[news319 catmillion]: /fr/newsletters/2024/09/06/#fonds-de-recherche-op-cat
[news330 sigactivity]: /fr/newsletters/2024/11/22/#rapport-d-activite-signet
[news330 paircommit]: /fr/newsletters/2024/11/22/#mise-a-jour-de-la-proposition-lnhance
[news330 covgrind]: /fr/newsletters/2024/11/22/#covenants-bases-sur-la-rectification-plutot-que-sur-des-changements-de-consensus
[news333 covpoll]: /fr/newsletters/2024/12/13/#sondage-d-opinions-sur-les-propositions-de-covenant
[news307 bcc29496]: /fr/newsletters/2024/06/14/#bitcoin-core-29496
[news325 mining]: /fr/newsletters/2024/10/18/#bitcoin-core-30955
[news315 shares]: /fr/newsletters/2024/08/09/#attaques-de-retention-de-blocs-et-solutions-potentielles
[news333 dnsbolt]: /fr/newsletters/2024/12/13/#bolts-1180
[news306 dnsblip]: /fr/newsletters/2024/06/07/#blips-32
[news292 bip21]: /fr/newsletters/2024/03/06/#mise-a-jour-des-uri-bitcoin-de-bip21
[news307 bip353]: /fr/newsletters/2024/06/14/#bips-1551
[news306 bip21]: /fr/newsletters/2024/06/07/#mise-a-jour-proposee-pour-le-bip21
[news329 dnsimp]: /fr/newsletters/2024/11/15/#ldk-3283
[news303 bip2]: /fr/newsletters/2024/05/17/#discussion-continue-sur-la-mise-a-jour-de-bip2
[news322 newbip2]: /fr/newsletters/2024/09/27/#brouillon-de-processus-bip-mis-a-jour
[news306 testnet]: /fr/newsletters/2024/06/07/#bip-et-mise-en-oeuvre-experimentale-de-testnet4
[news315 testnet4imp]: /fr/newsletters/2024/08/09/#bitcoin-core-29775
[news315 testnet4bip]: /fr/newsletters/2024/08/09/#bips-1601
[news309 sptweak]: /fr/newsletters/2024/06/28/#bips-1620
[news326 sppsbt]: /fr/newsletters/2024/10/25/#proposition-de-bip-pour-envoyer-des-paiements-silencieux-avec-des-psbts
[news327 sppsbt]: /fr/newsletters/2024/11/01/#brouillon-de-bip-pour-les-preuves-dleq
[news303 bitvmx]: /fr/newsletters/2024/05/17/#alternative-a-bitvm
[news303 aut]: /fr/newsletters/2024/05/17/#jetons-d-utilisation-anonymes
[news321 utxozk]: /fr/newsletters/2024/09/20/#prouver-l-inclusion-dans-l-ensemble-utxo-en-connaissance-nulle
[news304 lnup]: /fr/newsletters/2024/05/24/#amelioration-des-canaux-ln-existants
[news309 stfu]: /fr/newsletters/2024/06/28/#bolts-869
[news326 ann1.75]: /fr/newsletters/2024/10/25/#mises-a-jour-de-la-proposition-d-annonces-de-canal-version-1-75
[news304 minecash]: /fr/newsletters/2024/05/24/#defis-dans-la-recompense-des-mineurs-de-pool
[news310 msbip]: /fr/newsletters/2024/07/05/#bips-1610
[news304 msbip]: /fr/newsletters/2024/05/24/#proposition-de-bip-miniscript
[news333 deplete]: /fr/newsletters/2024/12/13/#apercus-sur-l-epuisement-des-canaux
[news307 quant]: /fr/newsletters/2024/06/14/#proposition-de-bip-pour-un-format-d-adresse-resistant-aux-quantiques
[news317 blip39]: /fr/newsletters/2024/08/23/#blips-39
[news319 merkle]: /fr/newsletters/2024/09/06/#attenuation-des-vulnerabilites-des-arbres-de-merkle
[news292 merkle]: /fr/newsletters/2024/03/06/#bitcoin-core-29412
[news332 zmwarp]: /fr/newsletters/2024/12/06/#discussion-continue-sur-la-proposition-de-soft-fork-de-nettoyage-du-consensus
[news302 utreexod]: /fr/newsletters/2024/05/15/#sortie-de-la-beta-de-utreexod
[news301 lamport]: /fr/newsletters/2024/05/08/#signatures-lamport-appliquees-par-consensus-en-plus-des-signatures-ecdsa
[news314 hyperion]: /fr/newsletters/2024/08/02/#simulateur-d-evenements-reseau-hyperion-pour-le-reseau-p2p-bitcoin
[news315 cb]: /fr/newsletters/2024/08/09/#statistiques-sur-la-reconstruction-de-blocs-compacts
[news315 rbfdefault]: /fr/newsletters/2024/08/09/#bitcoin-core-30493
[news329 opr]: /fr/newsletters/2024/11/15/#protocole-de-resolution-de-paiement-offchain-base-sur-mad-opr
[news315 threshsig]: /fr/newsletters/2024/08/09/#proposition-de-bip-pour-les-signatures-a-seuil-sans-script
[news310 musig]: /fr/newsletters/2024/07/05/#bips-1540
[LDK 0.0.119]: /fr/newsletters/2024/01/17/#ldk-0-0-119
[HWI 2.4.0]: /fr/newsletters/2024/01/31/#hwi-2-4-0
[Core Lightning 24.02]: /fr/newsletters/2024/02/28/#core-lightning-24-02
[Eclair v0.10.0]: /fr/newsletters/2024/03/06/#eclair-v0-10-0
[Bitcoin Core 27.0]: /fr/newsletters/2024/04/17/#bitcoin-core-27-0
[BTCPay Server 1.13.1]: /fr/newsletters/2024/04/17/#btcpay-server-1-13-1
[Bitcoin Inquisition 25.2]: /fr/newsletters/2024/05/01/#bitcoin-inquisition-25-2
[Libsecp256k1 v0.5.0]: /fr/newsletters/2024/05/08/#libsecp256k1-v0-5-0
[LDK v0.0.123]: /fr/newsletters/2024/05/15/#ldk-v0-0-123
[Bitcoin Inquisition 27.0]: /fr/newsletters/2024/05/24/#bitcoin-inquisition-27-0
[LND v0.18.0-beta]: /fr/newsletters/2024/05/31/#lnd-v0-18-0-beta
[Core Lightning 24.05]: /fr/newsletters/2024/06/14/#core-lightning-24-05
[HWI 3.1.0]: /fr/newsletters/2024/09/20/#hwi-3-1-0
[Bitcoin Core 28.0]: /fr/newsletters/2024/10/04/#bitcoin-core-28-0
[BTCPay Server 2.0.0]: /fr/newsletters/2024/11/01/#btcpay-server-2-0-0
[Libsecp256k1 0.6.0]: /fr/newsletters/2024/11/08/#libsecp256k1-0-6-0
[BDK 0.30.0]: /fr/newsletters/2024/11/29/#bdk-0-30-0
[Eclair v0.11.0]: /fr/newsletters/2024/12/06/#eclair-v0-11-0
[Core Lightning 24.11]: /fr/newsletters/2024/12/13/#core-lightning-24-11
[Fondation pour les Droits de l'Homme]: https://hrf.org