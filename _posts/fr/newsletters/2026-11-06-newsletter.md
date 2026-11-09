---
title: 'Bulletin Hebdomadaire Bitcoin Optech #430'
permalink: /fr/newsletters/2026/11/06/
name: 2026-11-06-newsletter-fr
slug: 2026-11-06-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume la poursuite des discussions sur l'utilisation du TCP hole punching pour rendre joignables les nœuds
derrière des routeurs domestiques et décrit un projet de BIP pour standardiser les politiques de dépense que les co-signataires appliquent
lorsqu'ils émulent des covenants. Sont également incluses nos rubriques habituelles résumant les propositions et discussions sur la
modification des règles de consensus de Bitcoin, annonçant de nouvelles versions et versions candidates, et décrivant des changements
notables apportés aux logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

- **Poursuite de la discussion sur le TCP hole punching pour les nœuds domestiques :** Suite à notre [résumé][news406 holepunch] de mai du
  fil Delving Bitcoin de 0xB10C sur l'utilisation du hole punching pour permettre aux nœuds derrière des routeurs domestiques d'accepter des
  connexions mutuelles, 0xB10C a [publié][b10c holepunch recap] que le travail a repris sur une spécification et une implémentation
  expérimentale dans Bitcoin Core. Les nœuds domestiques ne peuvent généralement établir que des connexions sortantes, et l'activation par
  défaut du mappage de ports NAT-PMP dans Bitcoin Core 30.0 n'en a pas rendu beaucoup plus joignables comme on l'espérait. Le hole punching,
  dans lequel deux nœuds domestiques ouvrent des connexions l'un vers l'autre au même moment afin que chaque routeur laisse passer le trafic
  de l'autre, constituerait un complément opportuniste à la redirection de port. Davantage de nœuds honnêtes joignables rendraient plus
  difficile pour les attaquants, dont les nœuds sont plus faciles à joindre, de remplir les emplacements de connexions sortantes d'un nœud.

  0xB10C a récapitulé les quatre conceptions discutées jusqu'à présent et a [proposé][b10c holepunch option6] une nouvelle option qui ne
  nécessite aucun coordinateur : un nœud annonce son adresse perforable et une clé publique temporaire dans un nouveau type [addr v2][topic
  addr v2], et chaque paire de nœuds dérive la même liste de candidats et le même moment de perforation à partir de leur secret partagé et
  de chaque nouveau bloc. En réponse à l'objection d'Anthony Towns selon laquelle un attaquant pourrait inonder le mécanisme avec de vraies
  adresses, et après avoir ensuite constaté que les nœuds injoignables reçoivent de telles annonces bien moins fiablement que les nœuds en
  écoute, il a esquissé une alternative de « tableau d'affichage » dans laquelle les nœuds en écoute conservent les adresses vérifiées des
  nœuds domestiques à la recherche d'un pair.

  Towns a remis en question l'utilité même de connexions entrantes aléatoires pour les nœuds domestiques et a [fait valoir][aj holepunch
  goals] que le hole punching facilite pour un attaquant le fait d'atteindre directement des nœuds honnêtes tout en faisant peu pour
  garantir une connexion avec l'un d'eux. Il a estimé qu'un attaquant annonçant environ 10 000 adresses serait une correspondance précoce
  pour la plupart des nœuds honnêtes et a suggéré des connexions de courte durée vers des pairs aléatoires comme alternative à moindre
  risque. Jonathan Harvey-Buschel a cité des données montrant que les nœuds honnêtes sont moins joignables que ceux contrôlés par un
  attaquant et a préféré une coordination via le propre service [Tor][topic anonymity networks] d'un nœud. Towns a ensuite [demandé][aj
  holepunch cves] si les récentes vulnérabilités TCP et de protocole ne rendent pas plus sûre, par défaut pour les utilisateurs domestiques,
  l'absence d'acceptation de connexions entrantes. La discussion se poursuit.

- **Projet de BIP pour des politiques de dépense de co-signataires standardisées :** Luke Carriere a [publié][cosigner pols del] sur Delving
  Bitcoin sa proposition de standardisation des politiques de dépense appliquées par les co-signataires lors de l'émulation de
  [covenants][topic covenants]. Plusieurs conceptions récentes, y compris les [co-signataires aveuglés][news412 blinded cosigners] de Johan
  Halseth et la [délégation par chain code][news364 delegation], définissent chacune leur propre politique, si bien qu'un portefeuille conçu
  pour l'une ne peut pas utiliser un co-signataire ou un oracle conçu pour une autre. Carriere ne demande pas de numéro BIP pour le
  [projet][cosigner pol draft] et a demandé si c'était la bonne couche à standardiser.

  Le projet suit plusieurs principes de conception :

  - Tout ce qui peut être imposé par le script Bitcoin doit l'être à cet endroit, les politiques des co-signataires ne définissant que ce
    que le script ne peut pas faire.

  - Au moins un chemin de dépense ne nécessitant aucun co-signataire doit toujours être disponible.

  - La manière dont un co-signataire vérifie une dépense, et ce qui garantit son honnêteté, sont des profils modulaires choisis pour chaque
    politique.

  - Les co-signataires doivent accepter les attestations d'oracle au format [DLC][topic dlc] afin que les oracles déjà disponibles puissent
    être réutilisés sans aucune modification.

  Une politique comporte cinq parties. La sortie définit le descripteur [taproot][topic taproot] qui détient les fonds, le groupe de
  co-signataires indique quels co-signataires participent et combien doivent signer, les modèles listent les transactions que les
  co-signataires peuvent signer avec leurs sorties exactes, les conditions indiquent ce qui doit être vrai avant qu'un modèle puisse être
  signé, et les profils nomment le mode de vérification, les formats de preuve et tout mécanisme de responsabilité. Certains points restent
  ouverts, tels que l'utilisation de JSON ou de TLV pour la sérialisation, le fait de savoir si la vérification aveuglée doit être spécifiée
  maintenant ou attendre davantage d'expérience d'implémentation, si le format d'attestation d'énoncé doit être spécifié dans la proposition
  ou dans les spécifications DLC, et si le chemin de repli doit être timelocké.

  Dans la discussion qui a suivi, PREDGE a souligné que l'un des profils de preuve, appelé `statement-v0`, ne possède pas d'indicateur de
  finalité, ce qui signifie qu'un co-signataire pourrait agir sur la base d'une attestation provisoire corrigée par la suite. De plus,
  tehiyadu a déclaré que le hachage de la politique devrait engager la sémantique exacte du vérificateur afin d'empêcher différentes
  implémentations d'accepter les mêmes octets tout en appliquant des conditions différentes. Carriere a approuvé ces deux points et a dit
  qu'il ajouterait un indicateur de finalité et préciserait les règles du vérificateur.

## Modification du consensus

_Une nouvelle section mensuelle résumant les propositions et discussions sur la modification des règles de consensus de Bitcoin._

- **Poursuite de la discussion sur BIP54** : Antoine Riard a [publié][ar ml bip54] sur la liste de diffusion Bitcoin-Dev son point de vue
  sur l'état du soft fork de [nettoyage du consensus][topic consensus cleanup] ([BIP54][]). L'interdiction des transactions dont la taille
  sans witness est exactement de 64 octets reste la règle la plus contestée. Une implémentation dans Bitcoin Core est en cours de revue et
  de test et constitue l'implémentation de référence liée depuis le BIP ([Bitcoin Core #35793][]). La PR active les nouvelles règles sur
  regtest sans activation sur mainnet. Il a également mentionné un travail d'interopérabilité dans btcd ([btcd #2537][]) et a dit ne
  connaître aucune implémentation dans libbitcoin. Selon lui, il reste à faire davantage de revue et de tests, de la documentation afin que
  les portefeuilles connaissent la limite proposée de 2 500 opérations de signature dans le script pré-segwit ainsi que la règle des 64
  octets, et, seulement plus tard, la logique d'activation. Ne parlant qu'en son nom, il a estimé qu'il pourrait être réaliste de commencer
  à envisager l'activation au second semestre 2027 si la communauté est alors d'accord.

  Pieter Wuille a [mis à jour][pw delving timewarp lean] son fil Delving Bitcoin sur la manière dont les deux règles d'horodatage de BIP54
  bornent la longueur de chaîne (voir le [Bulletin #425][news425 timewarp]). Le message initial inclut désormais la formule exacte pour la
  borne inférieure du travail, et cette formule comme son approximation décimale sont maintenant prouvées dans le code Lean lié.

  Riard a [répondu][ar ml forwardblocks] à une objection soulevée lors de la conception de BIP54 : corriger le bug de [time warp][topic time
  warp] rendrait impossible, pour tout le reste de l'histoire future de Bitcoin, un changement de consensus dans le style des [forward
  blocks][news16 forward] de Mark Friedenbach. Comme le correctif contraint la manipulation des horodatages plutôt que de la supprimer, une
  proposition de forward blocks bien plus limitée pourrait encore être mise en œuvre. Il a estimé que la fenêtre de 7 200 secondes toujours
  autorisée par le correctif pourrait abaisser la difficulté d'environ 0,60 % par période de réajustement, et augmenter le taux de blocs d'à
  peu près autant, ce qui reste très loin de l'augmentation de capacité de la proposition d'origine. Riard a également soutenu que l'idée
  n'est pas solide même avec les anciennes règles : les validateurs traiteraient les transactions une première fois sur la chaîne forward
  puis de nouveau lors de leur synchronisation sur la chaîne de compatibilité, pour les mêmes frais sauf si les utilisateurs payaient deux
  fois, et les nœuds n'ayant pas été mis à niveau devraient quand même télécharger les données supplémentaires. Riard proposera une courte
  note de bas de page à BIP54 exposant cet argument, et demandera à Friedenbach ses contre-arguments.

- **Prototype de protection contre la relecture sur adhésion volontaire :** Sjors Provoost a [donné suite][sj delving replay] au fil Delving
  Bitcoin sur la protection contre la relecture sur adhésion volontaire lors d'une scission de chaîne (voir le [Bulletin #420][news420
  replay]) avec un prototype qui utilise une nouvelle version de witness. Une [annexe][topic annex] dont la charge utile commence par l'octet
  0x01 désigne un bloc par une hauteur sur 4 octets, et chaque signature sur cette entrée engage le hachage du bloc de la chaîne souhaitée.
  Le hachage lui-même n'est pas présent dans la transaction. Il a estimé le coût supplémentaire à 1,75 vbytes. Le bloc désigné doit avoir au
  moins 100 blocs d'ancienneté, soit le même horizon que la maturité des coinbase. Il a dit que si le hashrate était réparti également,
  l'attente avant que les pièces puissent être séparées serait au pire de deux jours, car la règle n'a besoin d'être respectée que d'un seul
  côté. Il a suggéré de livrer la version de witness avec une autre proposition qui en nécessite une, comme [CISA][topic cisa] (BIP460),
  [BIP360][], ou une sortie de style [P2TRv2][news403 pqout] avec un keypath pouvant être désactivé plus tard.

  Anthony Towns a [répondu][aj delving replay] qu'une nouvelle version de witness est inutile, et qu'un nouvel encodage de clé publique pour
  une vérification de signature taproot, dans le style de [BIP118][], suffirait. Provoost a [répondu][sj delving replay keypath] qu'il avait
  envisagé cet encodage et l'avait jugé être un bricolage, et que, d'après sa compréhension, cela ne fonctionnerait pas pour une dépense
  keypath.

  Moonsettler a [mis en question][ms delving replay] l'intérêt d'exiger 100 blocs dans la scission où cette fonctionnalité serait la plus
  utile, et a suggéré de conserver ce délai comme règle de politique pouvant être assouplie. Provoost a [répondu][sj delving replay
  maturity] qu'après le déplacement des pièces sur le côté le plus rapide et l'accumulation de confirmations, le côté le plus lent n'a plus
  besoin de la protection. Provoost a également écrit qu'il s'attend à ce que la règle soit déployée avant un hard fork conflictuel, de
  sorte que les deux camps l'héritent, et qu'aucun des deux camps ne peut facilement l'abandonner : le hachage du bloc n'est présent que
  dans le message de signature, donc supprimer la règle signifie modifier la sérialisation des transactions pour transporter le hachage.

- **QSAVE pour les pièces non migrées** : James Tagg a [publié][jt ml qsave] sur la liste de diffusion Bitcoin-Dev [cinq projets de
  BIP][qsave drafts] pour QSAVE (Quantum Secure Asset Verification and Escrow), une transition [post-quantique][topic quantum resistance]
  qui ne brûle pas les pièces. Il les a décrits comme une alternative à [BIP361][] et à [Hourglass][news395 hourglass]. À partir d'une
  hauteur d'application, qui pourrait être activée à tout moment par un soft fork, toute entrée qui ne se trouve pas dans un registre de
  types post-quantiques connus serait traitée comme non migrée, y compris les types de script inconnus et futurs. Une entrée non migrée
  devrait toujours satisfaire son script de verrouillage, ainsi qu'un second facteur : soit une preuve à divulgation nulle de connaissance
  qu'une même graine dérive à la fois le script dépensé et une clé post-quantique, soit un lien post-quantique engagé avant une date limite.
  Si une entrée non migrée dans une transaction manque de ce second facteur, chaque sortie dépensable doit être une sortie de récupération.
  Dans QSAVE, il n'y a pas de date d'expiration, donc l'absence du second facteur ne détruit pas la pièce. Une preuve onchain peut toujours
  la dépenser directement, sans tiers. Sinon, il a décrit un processus hors chaîne pour biens perdus, dont il a placé le traitement
  juridique et économique en dehors du consensus, dans lequel un ensemble de dépositaires décentralisés détiendrait les sorties de
  récupération, avec un dépositaire de secours et un contrôleur de veto, et les fonds pourraient rapporter un rendement prudent de 0,5 %
  dirigé vers une œuvre caritative. Les projets spécifient également des filigranes pré-date-limite, une clé ML-DSA-87 optionnelle qu'il a
  appelée QD5, et une feuille de dépense zk-STARK pour les sorties [BIP360][] ([P2MR][news393 p2mr]).

- **Proof-of-decay pour les sorties non migrées** : bitKingAE a [publié][bk delving decay] sur Delving Bitcoin une esquisse visant à réduire
  les sorties exposées au [post-quantique][topic quantum resistance], telles que les premières pièces P2PK, qui ne sont pas déplacées
  pendant une période de grâce. Après expiration de cette période de grâce, la valeur de la sortie diminuerait selon un calendrier basé sur
  la hauteur de bloc. Les satoshis perdus seraient brûlés ou distribués comme récompenses de minage plutôt que les pièces soient gelées ou
  laissées à quiconque peut produire une signature. L'exemple du message était un faible pourcentage du solde tous les 50 000 blocs.
  Vinicius Cestari a [répondu][vc delving decay] avec trois objections : un attaquant quantique peut attendre la fin de la période de grâce
  et balayer les sorties exposées avant que la décroissance n'ait eu un effet significatif ; une amélioration soudaine des attaques
  quantiques peut les drainer encore plus tôt ; et le calendrier réduit le solde d'un propriétaire passif, y compris d'un propriétaire dont
  les clés avaient déjà été volées.

- **Censure des bundles BIP300** : Ori Newman a [soutenu][on ml bip300] sur la liste de diffusion Bitcoin-Dev qu'un mineur disposant de 26 %
  du hashrate peut censurer indéfiniment un bundle de retrait valide dans la proposition [drivechains][topic sidechains] ([BIP300][]). Il a
  écrit que si le mineur à 26 % envoie un ALARM dans chaque bloc qu'il mine, chacun de ces blocs abaisse de 1 le score de chaque bundle en
  attente. Si les autres 74 % du hashrate votent positivement pour un bundle dans chaque bloc, son score attendu serait de 12 624 à la fin
  de la fenêtre de 26 300 blocs, en deçà des 13 150 requis. Il a suggéré d'interdire ALARM et tout autre vote négatif, ce qui rétablirait
  une hypothèse de majorité honnête : un bundle soutenu par 51 % du hashrate passerait presque certainement, et un bundle soutenu par 49 %
  échouerait presque certainement. Si la règle actuelle est intentionnelle, il a demandé que le BIP indique plutôt une hypothèse de majorité
  honnête de 75 %. Il a qualifié cela d'écart important par rapport au modèle de sécurité de Bitcoin, et a dit qu'un argument en sa faveur
  est qu'il serait plus difficile pour un attaquant disposant de moins de 75 % du hashrate de voler des fonds.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires. Veuillez envisager de mettre à niveau vers
les nouvelles versions ou d'aider à tester les versions candidates._

- [LND v0.21.6-beta][] et [v0.20.7-beta][lnd v0.20.7-beta] sont des versions de sécurité pour les branches 0.21 et 0.20 de cette populaire
  implémentation de nœud LN. Les deux incluent l'atténuation de la vulnérabilité du noyau Linux CVE-2026-98432 décrite sous [LND #11456][]
  ci-dessous. Les opérateurs Linux devraient mettre à niveau, désactiver MPTCP sur l'hôte pour protéger les autres services, et installer un
  noyau corrigé, car l'atténuation de LND ne corrige pas la vulnérabilité sous-jacente.

- [Core Lightning 26.06.10][] est une version de sécurité de cette populaire implémentation de nœud LN. Elle corrige des vulnérabilités dans
  le [dual funding][topic dual funding], le [splicing][topic splicing], la résolution onchain des [HTLC][topic htlc], les contrôles d'accès
  et d'autres composants. Le code source des correctifs de sécurité est disponible, tandis que les tests associés sont temporairement
  retenus afin de donner davantage de temps aux utilisateurs pour mettre à niveau. Le projet recommande fortement la mise à niveau.

- [BTCPay Server 2.4.7][] est une version de sécurité de ce processeur de paiement auto-hébergé. Elle corrige 85 problèmes de sécurité
  signalés par le [programme OSS Scanner][anthropic oss scanner] d'Anthropic, y compris des problèmes affectant les limites de paiement,
  l'accès aux données d'autres boutiques, l'authentification et l'épuisement des ressources. Elle corrige également des problèmes de
  comptabilité des paiements et de fiabilité. La mise à jour est fortement recommandée, en particulier pour les serveurs partagés par
  plusieurs commerçants.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning
BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #36539][] rétablit le format PSBTv0 pour les transactions non signées et les augmentations de frais exportées depuis
  l'interface graphique. Bitcoin Core 32.1 exportait ces [PSBT][topic psbt] en version 2, empêchant les utilisateurs de les signer avec des
  outils qui ne prennent en charge que la version 0. Le flux de travail séparé de signataire externe configuré avec `-signer` (voir le
  [Bulletin #138][news138 signer]) continue d'utiliser PSBTv2, de sorte que ces utilisateurs ont besoin d'un signataire externe qui le prend
  en charge, tel que HWI 2.1.0 ou ultérieur.

- [Bitcoin Core #35714][] corrige un bug où le nœud pouvait mettre à jour son index de blocs et sa base de données UTXO après avoir échoué à
  vider sur disque des données de bloc ou d'annulation. Bien que l'échec signalât au nœud de s'arrêter, le code gérant ces écritures pouvait
  encore mettre à jour les bases de données avant l'arrêt du nœud. Si ces mises à jour réussissaient, les bases de données pouvaient
  enregistrer un état pour lequel les données de bloc ou d'annulation associées n'avaient pas encore été sauvegardées en toute sécurité.
  Cela pouvait laisser l'état local du nœud incohérent et compliquer la récupération. Le code saute désormais ces écritures en base de
  données pendant la tentative de vidage défaillante. Cela complète les protections antérieures sur l'ordre de vidage pour les index
  optionnels abordées dans le [Bulletin #414][news414 flush].

- [Bitcoin Core #35492][] corrige un bug où `bitcoin-wallet dump` (voir Le [Bulletin #130][news130 dump]) pouvait signaler un succès après
  avoir écrit une exportation incomplète du portefeuille. Auparavant, la commande vérifiait si elle pouvait ouvrir le fichier de destination
  mais ne détectait pas les échecs d'écriture ultérieurs, comme un manque d'espace disque. Par conséquent, les utilisateurs pouvaient croire
  à tort que l'exportation était complète, pour ne découvrir des données manquantes qu'en essayant de restaurer le portefeuille. Désormais,
  la commande vérifie l'écriture, le flush et la fermeture du fichier. Elle signale les échecs et supprime les fichiers de dump incomplets.

- [BIPs #2205][], [#2210][bips #2210], et [#2212][bips #2212] ajoutent trois projets de spécifications pour l'[agrégation inter-entrées de
  signatures][topic cisa]. [BIP458][] spécifie une demi-agrégation non interactive, combinant `n` signatures [BIP340][] existantes en `32 ×
  (n + 1)` octets au lieu de `64 × n` octets. [BIP459][] spécifie DahLIAS, un protocole interactif qui produit une unique signature agrégée
  de 64 octets pour plusieurs clés et messages. [BIP460][] propose d'utiliser ces schémas pour les dépenses keypath de nouvelles sorties en
  witness version 2, tout en conservant des signatures individuelles pour les dépenses scriptpath et en permettant aux entrées keypath de se
  désinscrire. Depuis que la proposition a été couverte dans le [Bulletin #417][news417 cisa], les entrées désinscrites ont été modifiées
  pour utiliser des signatures [BIP341][] ordinaires sans marqueur spécial, permettant aux portefeuilles d'adopter le nouveau type de sortie
  tout en réutilisant leur logique de signature existante. Cela réduirait le poids des transactions et les frais pour les transactions
  comportant plusieurs entrées participantes, y compris les [coinjoins][topic coinjoin] et les [payjoins][topic payjoin]. Le déploiement de
  l'agrégation de transactions proposée nécessiterait un soft fork. BIP460 laisse non spécifiés le mécanisme d'activation et ses paramètres.

- [Core Lightning #9419][] ajoute un champ optionnel `failure_reason` à la RPC `listforwards` et aux notifications `forward_event` pour les
  tentatives de transfert échouées localement. Auparavant, plusieurs problèmes distincts partageaient le même code d'échec du protocole, ce
  qui rendait difficile pour les opérateurs de déterminer pourquoi le transfert avait échoué. Le nouveau champ distingue des causes telles
  qu'une liquidité sortante insuffisante, un pair sortant hors ligne, et des limites sur le nombre ou la valeur totale des [HTLC][topic
  htlc] en attente.

- [Core Lightning #9592][] met à jour `xpay` (voir le [Bulletin #330][news330 xpay]) pour éviter un nœud de transfert pour le reste d'un
  paiement après qu'il a renvoyé deux fois `unknown_next_peer`. Auparavant, chaque échec n'excluait que le canal signalé, de sorte que des
  tentatives successives pouvaient continuer à sélectionner d'autres canaux via le même nœud jusqu'à expiration du temps de nouvelle
  tentative du paiement. Désormais, après le deuxième échec du même nœud, `xpay` l'exclut via la couche de routage privée `askrene` du
  paiement. Cette heuristique peut exclure des canaux utilisables, mais elle limite les tentatives répétées via le même nœud.

- [LDK #5089][] met à jour l'augmentation des frais lors des fermetures forcées de canaux avec [anchor outputs][topic anchor outputs]. Si
  LDK ne peut pas obtenir les fonds nécessaires pour une transaction enfant [CPFP][topic cpfp] qui dépense un anchor output, il diffuse
  désormais la transaction d'engagement seule. Auparavant, cet échec pouvait laisser les deux transactions non diffusées, retardant la
  récupération des fonds du canal. L'engagement inclut déjà des frais, qui peuvent encore être suffisants pour la confirmation si
  l'estimation des frais était prudente ou si la demande réseau baisse. Cependant, cette solution de repli exclut les [transactions
  d'engagement à frais nuls][topic v3 commitments], qui nécessitent une transaction enfant payant des frais pour le relais. Le problème a
  été signalé par Project Loupe.

- [LND #11456][] désactive par défaut les écouteurs Multipath TCP (MPTCP) afin d'atténuer [CVE-2026-98432][mptcp advisory], une
  vulnérabilité du noyau Linux pour laquelle une exécution de code à distance a été démontrée à l'aide de MPTCP. Go 1.24 et les versions
  ultérieures activent ces écouteurs par défaut sur les systèmes Linux pris en charge, ce qui pourrait exposer les opérateurs LND même s'ils
  ne configurent pas explicitement MPTCP. Le changement définit `multipathtcp=0` dans les valeurs par défaut Go de LND. Cela bloque le
  chemin d'exploitation démontré via les écouteurs de LND, mais ne corrige pas le bug sous-jacent du noyau. Les systèmes affectés
  nécessitent toujours un noyau corrigé. Les opérateurs utilisant des binaires existants peuvent appliquer la même atténuation en
  redémarrant LND avec la variable d'environnement `GODEBUG=multipathtcp=0`.

- [LND #11357][] renforce la validation des factures [BOLT11][] suite à [BOLTs #1357][] (voir le [Bulletin #428][news428 bolts11]). Au lieu
  d'utiliser le premier champ et d'ignorer les autres, il rejette désormais les champs secrets de paiement dupliqués, empêchant toute
  ambiguïté entre des parseurs qui sélectionnent des occurrences différentes. Cela s'appuie sur le rejet antérieur des hachages de paiement
  dupliqués (voir le [Bulletin
  #425][news425 lnd]). Les tests ajoutés par la mise à jour de la
  spécification ont également révélé que des exigences existantes n'étaient pas appliquées. Le décodeur rejette désormais des longueurs
  incorrectes lors de l'analyse du hachage de paiement, du hachage de description, du secret de paiement, et de la clé publique du
  destinataire, au lieu de traiter ces champs comme absents. Auparavant, un champ de clé publique du destinataire de taille incorrecte
  pouvait amener LND à revenir à la récupération de la clé à partir de la signature. Pour les factures contenant une clé publique explicite
  du destinataire, une signature ECDSA low-S est également requise. Cependant, cette restriction ne s'applique pas lorsque la clé publique
  est récupérée à partir de la signature (voir le [Bulletin #381][news381 low-s]).

- [LND #11413][] accélère le nettoyage au démarrage des résultats stockés des paiements sortants sur les nœuds utilisant SQLite ou
  PostgreSQL. Pendant le fonctionnement normal, le nœud accumule un résultat pour chaque tentative de [HTLC][topic htlc] résolue et initiée
  localement. Au démarrage, il supprime les résultats qui ne sont plus nécessaires. Auparavant, la lecture et la suppression des entrées
  individuellement nécessitaient des allers-retours répétés vers la base de données, ce qui pouvait faire durer le nettoyage pendant des
  heures sur un nœud chargé utilisant un PostgreSQL distant. Désormais, le nettoyage regroupe les opérations de base de données tout en
  préservant les résultats nécessaires pour reprendre les paiements en attente.

- [LND #11151][] ajoute des vérifications concernant des feerates de commitment excessifs et des soldes initiaux inadéquats lors de
  l'acceptation de canaux entrants. LND rejette désormais un feerate proposé supérieur au plus grand entre dix fois son [estimation sur
  trois blocs][topic fee estimation] et 100 sat/vbyte. Il applique aussi la règle de réserve initiale de [BOLT2][] et rejette séparément les
  canaux où le solde initial d'aucune des deux parties ne dépasse la réserve que cette partie doit maintenir. Bien que l'initiateur paie les
  frais de commitment, des frais excessifs peuvent consommer son solde utilisable, gaspillant la capacité de canal en attente du récepteur
  pendant l'ouverture et laissant derrière eux un canal inutilisable une fois la transaction de financement confirmée. Cela complète les
  vérifications de feerate minimal couvertes dans le [Bulletin #429][news429 lnd fees].

- [Rust Bitcoin #7067][] étend les assistants de hachage de signature (sighash) [taproot][topic taproot] afin d'accepter un [annex][topic
  annex] optionnel et, pour les dépenses scriptpath, la position d'opcode du dernier [OP_CODESEPARATOR][topic OP_CODESEPARATOR] exécuté
  avant la vérification de signature. Les deux affectent le message auquel une signature s'engage. Auparavant, ces fonctions utilitaires
  supposaient l'absence d'annex et l'absence de `OP_CODESEPARATOR` exécuté, de sorte que les appelants gérant de telles dépenses devaient
  utiliser la fonction sighash plus générale pour éviter de produire un condensé incorrect. Les assistants acceptent désormais directement
  ces valeurs, bien que les appelants doivent toujours déterminer la position du séparateur. Les appelants gérant des dépenses sans annex ou
  sans `OP_CODESEPARATOR` exécuté peuvent passer `None` pour les nouveaux arguments afin de conserver le comportement précédent. Voir Le
  [Bulletin #427][news427 rust bitcoin] pour des changements connexes de l'API sighash pour les dépenses legacy et segwit v0.

{% include snippets/recap-ad.md when="2026-11-10 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="35793,11456,36539,35714,35492,2205,2210,2212,9419,9592,5089,11357,1357,11413,11151,7067" %}

[news406 holepunch]: /fr/newsletters/2026/05/22/#perforage-de-trous-tcp-pour-les-noeuds-bitcoin-derriere-des-nat
[b10c holepunch recap]: https://delvingbitcoin.org/t/tcp-hole-punching-for-bitcoin-nodes-behind-home-nats/2497/18
[b10c holepunch option6]: https://delvingbitcoin.org/t/tcp-hole-punching-for-bitcoin-nodes-behind-home-nats/2497/22
[aj holepunch goals]: https://delvingbitcoin.org/t/tcp-hole-punching-for-bitcoin-nodes-behind-home-nats/2497/25
[aj holepunch cves]: https://delvingbitcoin.org/t/tcp-hole-punching-for-bitcoin-nodes-behind-home-nats/2497/35
[cosigner pols del]: https://delvingbitcoin.org/t/bip-draft-co-signer-spending-policies/2955
[news412 blinded cosigners]: /fr/newsletters/2026/01/02/#construire-un-coffre-fort-en-utilisant-des-co-signataires-aveugles
[news364 delegation]: /fr/newsletters/2025/07/25/#retention-du-code-de-chaine-pour-les-scripts-multisig
[cosigner pol draft]: https://github.com/lukecarriere/bip-cosigner-spending-policies/blob/468fdd1b75647432ed56c3a2b5579cbcfedaec74/bip-cosigner-spending-policies.md
[ar ml bip54]: https://groups.google.com/g/bitcoindev/c/TBBakeBK8_E
[btcd #2537]: https://github.com/btcsuite/btcd/pull/2537
[pw delving timewarp lean]: https://delvingbitcoin.org/t/bounds-on-chain-length-with-bip-54-timewarp-fixes/2899/29
[news425 timewarp]: /fr/newsletters/2026/10/02/#bornes-sur-la-longueur-de-chaine-avec-les-correctifs-de-time-warp-de-bip54
[ar ml forwardblocks]: https://groups.google.com/g/bitcoindev/c/T9s8nflvlK0
[news16 forward]: /fr/newsletters/2018/10/09/#forward-blocks--augmentations-de-capacité-on-chain-sans-hard-fork
[sj delving replay]: https://delvingbitcoin.org/t/universal-opt-in-replay-protection/2792/11
[news403 pqout]: /fr/newsletters/2026/05/01/#discussion-d-un-type-de-sortie-post-quantique
[news420 replay]: /fr/newsletters/2026/08/28/#discussion-sur-une-protection-universelle-contre-la-relecture-par-adhesion-volontaire
[aj delving replay]: https://delvingbitcoin.org/t/universal-opt-in-replay-protection/2792/12
[sj delving replay keypath]: https://delvingbitcoin.org/t/universal-opt-in-replay-protection/2792/13
[ms delving replay]: https://delvingbitcoin.org/t/universal-opt-in-replay-protection/2792/14
[sj delving replay maturity]: https://delvingbitcoin.org/t/universal-opt-in-replay-protection/2792/15
[jt ml qsave]: https://groups.google.com/g/bitcoindev/c/5G38b3JL9fA
[qsave drafts]: https://www.qsave.org/legal/bip-suite
[news395 hourglass]: /fr/newsletters/2026/03/06/#mise-a-jour-hourglass-v2
[news393 p2mr]: /fr/newsletters/2026/02/20/#bips-1670
[on ml bip300]: https://groups.google.com/g/bitcoindev/c/7P0_BHRAYQI
[bk delving decay]: https://delvingbitcoin.org/t/a-novel-post-quantum-approach-proof-of-decay-cryptographic-half-life-for-unmigrated-dormant-utxos/2970
[vc delving decay]: https://delvingbitcoin.org/t/a-novel-post-quantum-approach-proof-of-decay-cryptographic-half-life-for-unmigrated-dormant-utxos/2970/2

[LND v0.21.6-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.21.6-beta
[lnd v0.20.7-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.7-beta
[Core Lightning 26.06.10]: https://github.com/ElementsProject/lightning/releases/tag/v26.06.10
[BTCPay Server 2.4.7]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.4.7
[anthropic oss scanner]: https://github.com/anthropics/oss-scanner
[mptcp advisory]: https://www.openwall.com/lists/oss-security/2026/10/30/1
[LDK #5089]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5089
[news138 signer]: /en/newsletters/2021/03/03/#bitcoin-core-16546
[news414 flush]: /fr/newsletters/2026/07/17/#bitcoin-core-34897
[news130 dump]: /en/newsletters/2021/01/06/#bitcoin-core-19137
[news417 cisa]: /fr/newsletters/2026/08/07/#cisa-pour-les-depenses-keypath-taproot-bip460
[news330 xpay]: /fr/newsletters/2024/11/22/#core-lightning-7799
[news428 bolts11]: /fr/newsletters/2026/10/23/#bolts-1357
[news425 lnd]: /fr/newsletters/2026/10/02/#lnd-11190
[news381 low-s]: /fr/newsletters/2025/11/21/#bolts-1284
[news429 lnd fees]: /fr/newsletters/2026/10/30/#lnd-11373
[news427 rust bitcoin]: /fr/newsletters/2026/10/16/#rust-bitcoin-6956
