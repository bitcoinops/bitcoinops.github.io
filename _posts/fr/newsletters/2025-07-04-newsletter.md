---
title: 'Bulletin Hebdomadaire Bitcoin Optech #361'
permalink: /fr/newsletters/2025/07/04/
name: 2025-07-04-newsletter-fr
slug: 2025-07-04-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit une proposition visant à séparer les connexions réseau et la
gestion des pairs utilisées pour la transmission de messages onion de celles utilisées pour la
transmission de HTLC dans LN. Sont également incluses nos sections régulières résumant les
discussions sur la modification du consensus de Bitcoin et listant les changements récents apportés
aux logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

- **Séparation de la transmission de messages onion de la transmission de HTLC :** Olaluwa Osuntokun
  a [posté][osuntokun onion] sur Delving Bitcoin concernant la possibilité pour les nœuds d'utiliser
  des connexions séparées pour relayer les [messages onion][topic onion messages] de celles qu'ils
  utilisent pour relayer les [HTLC][topic htlc]. Bien que des connexions séparées soient actuellement
  possibles, comme dans le cas du relais direct (voir les bulletins [#283][news283 oniondirect] et
  [#304][news304 onionreply]), Osuntokun suggère que des connexions séparées devraient toujours être
  une option, permettant aux nœuds d'avoir un ensemble différent de pairs pour les messages onion de
  l'ensemble des pairs qu'ils utilisent pour relayer les paiements. Il avance plusieurs arguments en
  faveur de cette approche alternative : cela sépare plus clairement les préoccupations, les nœuds
  peuvent soutenir à moindre coût une plus grande densité de pairs pour les messages onion que pour
  les pairs de canaux (car les canaux coûtent de l'argent à créer), la séparation peut permettre le
  déploiement d'une rotation de clés améliorant la confidentialité, et la séparation peut permettre
  une livraison plus rapide des messages onion car ils ne seraient pas bloqués par le protocole de
  communication d'engagement HTLC. Osuntokun fournit des détails spécifiques sur le protocole proposé.

  Une préoccupation de plusieurs développeurs ayant répondu était la manière dont le réseau pour les
  messages onion pourrait permettre aux nœuds d'être inondés par un nombre excessif de pairs. Dans les
  implémentations actuelles de messages onion, chaque nœud ne maintient généralement des connexions
  qu'avec ses partenaires de canal. Créer l'UTXO pour financer un canal coûte de l'argent (frais
  onchain et coût d'opportunité) et est unique au nœud et au partenaire de canal ; en bref, c'est
  une-UTXO-une-connexion. Même si les connexions de messages onion devaient être soutenues par des
  fonds onchain, une seule UTXO pourrait être utilisé pour ouvrir des connexions avec chaque nœud LN
  public : une-UTXO-des milliers-de-connexions.

  Bien qu'au moins un répondant ait soutenu la proposition d'Osuntokun, plusieurs répondants ont
  jusqu'à présent exprimé leur préoccupation concernant le risque de déni de service. La discussion
  était en cours au moment de la rédaction.

## Modification du consensus

_Une nouvelle section mensuelle résumant les propositions et discussions sur la modification des
règles de consensus de Bitcoin._

- **Avantages de CTV+CSFS pour les PTLC :** les développeurs ont poursuivi une discussion précédente
  (voir le [Bulletin #348][news348 ctvstep]) sur les avantages de [OP_CHECKTEMPLATEVERIFY][topic
  op_checktemplateverify] (CTV), [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] (CSFS), ou les
  deux ensemble pour divers protocoles déployés et imaginés. D'un intérêt particulier, Gregory Sanders
  a [écrit][sanders ptlc] que CTV+CSFS "accélérerait la mise à jour de [LN] vers [PTLCs][topic ptlc],
  même si [LN-Symmetry][topic eltoo] en soi
  n'est jamais adopté. Les signatures réaffectables rendent la vie tellement moins compliquée
  lorsqu'on empile des protocoles." Sjors Provoost a [demandé][provoost ptlc] des détails et Sanders a
  [répondu][sanders ptlc2] avec un [lien][sanders gist] vers ses recherches précédentes sur les
  changements de messagerie LN pour les PTLCs (voir le [Bulletin #268][news268 ptlc]), ajoutant que
  "les PTLCs sur les protocoles actuels ne sont pas du tout impossibles, mais avec des signatures
  réaffectables, cela devient significativement plus simple."

  Anthony Towns a également [mentionné][towns ptlc] qu'"il y a aussi un manque
  d'outils/standardisation pour réaliser une révélation PTLC en combinaison avec un [musig][topic
  musig] 2-de-2 (ce qui serait efficace onchain), ou même des signatures de transactions
  générales (ie `x CHECKSIGVERIFY y CHECKSIG`). [...] Cela nécessiterait un support de [signature
  adaptative][topic adaptor signatures] pour musig2, et cela ne fait pas partie des spécifications et
  a été [retiré][libsecp256k1 #1479] de l'implémentation secp256k1. Le faire moins efficacement comme
  une signature adaptative séparée fonctionnerait aussi, mais même les signatures adaptatives simples
  pour les [signatures schnorr][topic schnorr signatures] ne sont également pas disponibles dans
  secp256k1. Elles ne sont même pas incluses dans le projet secp256k1-zkp plus expérimental. [...] Si
  les outils étaient prêts, je pourrais voir le support PTLC être ajouté [...] mais je ne pense pas
  que quiconque considère cela comme une priorité suffisamment élevée pour effectuer le travail
  nécessaire pour standardiser et polir les aspects cryptographiques. [...] Avoir [CAT][topic
  op_cat]+CSFS disponible éviterait le problème d'outils, au prix d'une efficacité onchain.
  [...] Je pense qu'avec seulement CSFS disponible, vous continuez à avoir des problèmes d'outils
  similaires, parce que vous devez utiliser des signatures adaptatives pour empêcher votre
  contrepartie de choisir une valeur R différente pour la signature. Ces problèmes sont indépendants
  de la complexité de la mise à jour et des mises à jour du protocole pair que Gregory Sanders décrit
  ci-dessus."

- **Descripteur de script de sortie de coffre :** Sjors Provoost a [posté][provoost ctvdesc] sur
  Delving Bitcoin pour discuter de la manière dont les informations de récupération pour un
  portefeuille utilisant des [coffres][topic vaults] pourraient être spécifiées à l'aide d'un
  [descripteur de script de sortie][topic descriptors]. En particulier, il s'est concentré sur les
  coffres basés sur [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV), tels que ceux
  fournis par la mise en œuvre de preuve de concept [simple-ctv-vault][] de James O'Beirne (voir
  le [Bulletin #191][news191 simple-ctv-vault]).

  Provoost a cité un [commentaire][ingala vaultdesc] d'une discussion précédente par Salvatore Ingala
  qui disait, "mon avis général est que les descripteurs ne sont pas l'outil approprié pour ce
  but"---un sentiment avec lequel Sanket Kanjalkar [était d'accord][kanjalkar vaultdesc1] dans le fil
  actuel mais [a trouvé][kanjalkar vaultdesc2] une solution potentielle. Kanjalkar a décrit une
  variante de coffre basée sur CTV où les fonds sont déposés dans un descripteur plus typique et, de
  là, sont déplacés
  dans un coffre CTV. Cela évite une situation qui pourrait conduire les utilisateurs naïfs à perdre
  de l'argent et permet également la création d'un descripteur qui suppose que tous les fonds versés
  au descripteur typique sont déplacés dans un coffre en utilisant les mêmes paramètres à chaque fois.
  Cela permettrait au descripteur du coffre CTV d'être succinct et complet sans aucune contorsion à la
  langue des descripteurs.

- **Discussion continue sur les avantages de CTV+CSFS pour BitVM :** les développeurs ont poursuivi
  la discussion précédente (voir le [Bulletin #354][news354 bitvm]) sur la manière dont la
  disponibilité des opcodes [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV) et
  [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] (CSFS) pourrait "réduire les tailles de
  transaction [BitVM] d'environ 10x" et permettre des peg-ins non interactifs. Anthony Towns a
  [identifié][towns ctvbitvm] une vulnérabilité dans le contrat original proposé ; lui et plusieurs
  autres développeurs ont décrit des solutions de contournement. Des discussions supplémentaires ont
  examiné les avantages de l'utilisation du opcode [OP_TXHASH][] proposé plutôt que CTV. Chris Stewart
  a [implémenté][stewart ctvimp] certaines des idées discutées en utilisant le logiciel de test de
  Bitcoin Core, validant ces parties de la discussion et fournissant des exemples concrets pour les
  examinateurs.

- **Lettre ouverte à propos de CTV et CSFS :** James O'Beirne a [posté][obeirne letter] une lettre
  ouverte à la mailing list Bitcoin-Dev signée par 66 individus (au moment de la rédaction), beaucoup
  d'entre eux contributeurs à des projets liés à Bitcoin. La lettre "demande aux contributeurs de
  Bitcoin Core de prioriser la revue et l'intégration de [OP_CHECKTEMPLATEVERIFY][topic
  op_checktemplateverify] (CTV) et [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] (CSFS) dans les
  six prochains mois." Le fil contient plus de 60 réponses. Quelques points techniques saillants
  incluent :

  - *Préoccupations et alternatives au support legacy :* [BIP119][] spécifie CTV pour les scripts
    témoins v1 ([tapscript][topic tapscript]) et le script legacy. Gregory Sanders [écrit][sanders
    legacy] que "le support du script legacy [...] augmente considérablement la surface de révision sans
    gain de capacité connu et sans économies connues pour les protocoles." O'Beirne [a répondu][obeirne
    legacy] que le support du script legacy pourrait économiser environ 8 vbytes dans certains cas, mais
    Sanders a [lié][sanders p2ctv] à sa proposition précédente de pay-to-CTV (P2CTV) et à
    l'implémentation de preuve de concept qui rend cette économie disponible dans le script témoin.

  - *Limites du support uniquement par CTV des coffres :* le signataire Jameson Lopp a [noté][lopp
    ctvvaults] qu'il est "le plus intéressé par [les coffres][topic vaults]," lançant une discussion sur
    l'ensemble des propriétés que les coffres CTV fourniraient, comment ils se comparent aux coffres
    déployables aujourd'hui en utilisant des transactions pré-signées, et s'ils fournissent une
    amélioration significative de la sécurité (surtout comparés aux coffres plus avancés qui
    nécessiteraient des changements de consensus supplémentaires). Les points clés de cette discussion
    incluaient :

    - *Danger de la réutilisation d'adresse :* les coffres pré-signés et CTV doivent empêcher les
      utilisateurs de réutiliser les adresses de coffrage ou les fonds risquent d'être perdus. Une manière
      d'accomplir cela peut être réalisée par un processus de coffrage en deux étapes.
      procédure nécessitant deux transactions onchain pour déposer des fonds dans le coffre. Les coffres
      plus avancés nécessitant des changements de consensus supplémentaires n'auraient pas ce problème,
      permettant des dépôts même à une adresse réutilisée (bien que cela réduirait, bien sûr, la
      [confidentialité][topic output linking]).

    - *Vol de fonds en attente :* les coffres avec signatures anticipées et CTV permettent le vol de
      retraits autorisés. Par exemple, l'utilisateur du coffre, Bob, veut payer 1 BTC à Alice. Avec les
      coffres à signatures anticipées et CTV, Bob suit la procédure suivante :

      - Retire 1 BTC (plus éventuellement les frais) de son coffre vers une adresse de mise en scène.

      - Attend le temps défini par le coffre.

      - Transfère 1 BTC à Alice.

      Si Mallory a volé la clé de mise en scène de Bob, elle peut voler le 1 BTC après que le retrait soit
      complet mais avant que la transaction à Alice ne soit confirmée. Cependant, même si Mallory
      compromet également la clé de retrait, elle ne peut pas voler de fonds restants dans le coffre parce
      que Bob peut interrompre tout retrait en attente et rediriger les fonds vers une _adresse sûre_
      protégée par une clé ultra-sécurisée (ou des clés).

      Les coffres plus avancés ne nécessitent pas l'étape de mise en scène : le retrait de Bob ne pourrait
      aller qu'à Alice ou à l'adresse sûre. Cela empêche Mallory de pouvoir voler des fonds entre les
      étapes de retrait et de dépense.

    - *Suppression de clé :* un avantage des coffres basés sur CTV par rapport aux coffres à signatures
      anticipées est qu'ils ne nécessitent pas de supprimer des clés privées pour garantir que l'ensemble
      des transactions signées à l'avance sont les seules options de dépense disponibles. Cependant,
      Gregory Maxwell [a noté][maxwell autodelete] qu'il est simple de concevoir un logiciel pour
      supprimer une clé immédiatement après avoir signé les transactions sans jamais exposer la clé privée
      aux utilisateurs. Aucun dispositif de signature matérielle n'est connu pour supporter cela
      directement à l'heure actuelle, bien qu'au moins un dispositif le supporte via une intervention
      manuelle de l'utilisateur---mais c'est aussi le cas qu'aucun matériel ne supporte CTV même pour les
      tests à l'heure actuelle (à notre connaissance). Les coffres plus avancés partageraient l'avantage
      sans clé de CTV mais nécessiteraient également une intégration dans le logiciel et le matériel.

    - *État statique :* un avantage revendiqué des coffres basés sur CTV par rapport aux coffres à
      signatures anticipées est qu'il pourrait être possible de calculer toutes les informations
      nécessaires pour récupérer le portefeuille à partir d'une sauvegarde statique, telle qu'un
      [descripteur de script de sortie][topic descriptors]. Cependant, il y a déjà eu des travaux sur les
      coffres à signatures anticipées qui permettent également des sauvegardes statiques en stockant les
      parties non déterministes de l'état signé à l'avance dans les transactions onchain elles-mêmes (voir
      le [Bulletin #255][news255 presig vault state]). Optech croit que les coffres plus avancés pourraient
      également être récupérés à partir d'un état statique, mais nous n'avions pas vérifié cela avant la
      publication.

  - *Réponses des contributeurs de Bitcoin Core :* à l'heure où nous écrivons ces lignes, quatre
    individus qu'Optech reconnaît comme contributeurs actifs de Bitcoin Core ont répondu à la lettre sur
    la liste de diffusion. Ils ont dit :

    - [Gregory Sanders][sanders ctvcom] : "Cette lettre demande des retours de la communauté technique
      et voici mon retour. Les BIP non déployés qui n'ont pas reçu de mises à jour depuis des années ne
      sont généralement pas un signe de
      la santé de la proposition, et certainement pas une base pour rejeter les conseils techniques de
      quelqu'un qui a prêté une attention particulière. Je rejette cette interprétation, l'élévation du
      niveau des changements à cette proposition pour ne concerner que les ruptures flagrantes, et je
      rejette évidemment un ultimatum basé sur le temps pour BIP119 tel quel. Je pense toujours que CTV
      (encore dans le sens de la capacité) + CSFS méritent d'être considérés, mais c'est une manière
      infaillible de le couler."

    - [Anthony Towns][towns ctvcom]: "De mon point de vue, la discussion sur CTV a manqué des étapes
      importantes, et au lieu que ces étapes soient franchies, les défenseurs ont tenté d'utiliser la
      pression publique pour forcer l'adoption selon un 'calendrier accéléré' pratiquement sans
      interruption depuis au moins trois ans maintenant. J'ai essayé d'aider les défenseurs de CTV à
      franchir les étapes que je crois qu'ils ont manquées, mais cela a principalement abouti à du silence
      ou des insultes plutôt qu'à quelque chose de constructif. Au moins de là où je me trouve, cela crée
      juste des problèmes d'incitation, sans les résoudre."

    - [Antoine Poinsot][poinsot ctvcom]: "L'effet de cette lettre a été, comme on aurait pu s'y
      attendre, un recul majeur dans la progression de cette proposition (ou plus largement de ce faisceau
      de capacités). Je ne suis pas sûr de la manière dont nous pouvons rebondir après cela, mais cela
      implique nécessairement que quelqu'un se lève et fasse réellement le travail d'adresser le retour
      technique de la communauté et de démontrer (de vrais) cas d'utilisation. La voie à suivre doit être
      de construire un consensus sur la base d'arguments techniques objectifs et solides. Pas avec un
      groupe de personnes exprimant leur intérêt et personne ne passant à l'action et aidant la
      proposition à avancer."

    - [Sjors Provoost][provoost ctvcom]: "Permettez-moi également de parler un peu de ma propre
      motivation. Les coffres-forts semblent être la seule fonctionnalité activée par la proposition que
      je trouve personnellement assez importante pour travailler dessus. [...] Jusqu'à tout récemment, il
      me semblait que l'élan pour les coffres-forts était dans OP_VAULT, qui à son tour nécessiterait
      OP_CTV. Mais un code opérationnel à usage unique n'est pas idéal, donc ce projet ne semblait pas
      aller quelque part. [...] Inversement, je ne m'oppose pas à CTV + CSFS ; je n'ai vu aucun argument
      indiquant qu'ils sont nuisibles. Puisqu'il y a peu de potentiel MeVil, je pourrais aussi imaginer
      d'autres développeurs développer et déployer ces changements avec prudence. Je garderais juste un
      œil sur le processus. Ce que j'_opposerais_ serait une implémentation alternative basée sur Python
      et un client d'activation comme Paul Sztorc a proposé."

  - *Déclarations des signataires :* les signataires de la lettre ont également clarifié leurs
    intentions dans des déclarations ultérieures :

    - [James O'Beirne][obeirne ctvcom]: "tous ceux qui ont signé veulent explicitement voir la revue
      imminente, l'intégration et la planification de l'activation pour CTV+CSFS spécifiquement."

    - [Andrew Poelstra][poelstra ctvcom]: "Les premières ébauches de la lettre demandaient effectivement
      l'intégration et même l'activation, mais je n'ai signé aucune de ces premières ébauches. Ce n'est
      que lorsque le langage a été atténué pour parler de priorités et de planification (et pour être une
      "demande respectueuse" plutôt qu'une sorte d'exigence) que j'ai signé."

    - [Steven Roose][roose ctvcom] : "[La lettre] demande simplement aux contributeurs principaux de
      mettre cette proposition à l'ordre du jour avec une certaine urgence. Pas de menaces, pas de mots
      durs. Étant donné que seulement quelques contributeurs principaux avaient jusqu'à présent participé
      à la conversation sur la proposition ailleurs, il semblait être une étape appropriée de communiquer
      que nous voulons que les contributeurs principaux fournissent leur position dans cette conversation.
      Je suis fermement opposé à une approche impliquant des clients d'activation indépendants et je pense
      que le sentiment de cet e-mail s'aligne sur la préférence d'avoir Core impliqué dans tout
      déploiement de mises à niveau de protocole."

    - [Harsha Goli][goli ctvcom] : "La plupart des gens ont signé parce qu'ils n'avaient vraiment aucune
      idée de quelle devrait être la prochaine étape, et la pression pour les engagements de transaction
      était telle qu'une mauvaise option (accumulation d'une lettre de signature) était plus optimale que
      l'inaction. Dans les conversations avant l'envoi de la lettre (facilitées par mon enquête dans
      l'industrie), je n'ai reçu que des réprimandes de la lettre de la part de nombreux signataires. Je
      ne connais en fait pas une seule personne qui l'a considérée comme une bonne idée explicitement. Et
      pourtant, ils ont signé. Il y a un signal dans cela."

- **OP_CAT permet les signatures Winternitz :** le développeur Conduition a [posté][conduition
  winternitz] sur la liste de diffusion Bitcoin-Dev un [prototypr d'implémentation][conduition impl]
  qui utilise le code d'opération proposé [OP_CAT][topic op_cat] et d'autres instructions Script pour
  permettre aux signatures [résistantes aux quantiques][topic quantum resistance] utilisant le
  protocole Winternitz d'être vérifiées par la logique de consensus. L'implémentation de Conduition
  nécessite presque 8 000 octets pour la clé, la signature et le script (dont la plupart est soumis à
  la réduction de poids du témoin, réduisant le poids onchain à environ 2 000 vbytes). Cela représente
  environ 8 000 vbytes de moins qu'un autre schéma de [signature Lamport][lamport signature] basé sur `OP_CAT` et
  [précédemment proposé][rubin lamport] par Jeremy Rubin.

- **Fonction de commit/reveal pour la récupération post-quantique :** Tadge Dryja a [posté][dryja
  fawkes] sur la liste de diffusion Bitcoin-Dev une méthode permettant aux individus de dépenser des
  UTXOs en utilisant des algorithmes de signature [vulnérables aux quantiques][topic quantum
  resistance] même si des ordinateurs quantiques rapides permettraient autrement de rediriger (voler)
  le résultat de toute tentative de dépense. Cela nécessiterait un soft fork et est une variation
  d'une proposition précédente de Tim Ruffing (voir le [Bulletin #348][news348 fawkes]).

  Pour dépenser une sortie dans le schéma de Dryja, le dépensier crée un engagement envers trois
  pièces d'informations :

  1. Un hash de la clé publique correspondant à la clé privée qui contrôle les fonds, `h(pubkey)`.
      Cela s'appelle l'_identifiant d'adresse_.

  2. Un hash de la clé publique et du txid de la transaction que le dépensier souhaite éventuellement
      diffuser, `h(pubkey, txid)`. Cela s'appelle la _preuve dépendante de la séquence_.

  3. Le txid de la transaction éventuelle. Cela s'appelle le _txid d'engagement_.

  Aucune de ces informations ne révèle la clé publique sous-jacente, qui dans
  ce schéma est supposé être connu uniquement de la personne contrôlant le UTXO.

  Le triple engagement est diffusé dans une transaction en utilisant un algorithme sécurisé contre les
  attaques quantiques, par exemple comme une sortie `OP_RETURN`. À ce moment, un attaquant pourrait
  tenter de diffuser son propre engagement en utilisant le même identifiant d'adresse mais un txid
  d'engagement différent qui dépense les fonds vers le portefeuille de l'attaquant. Cependant, il n'y
  a aucun moyen pour l'attaquant de générer une preuve séquentielle valide étant donné qu'il ne
  connaît pas la clé publique sous-jacente. Cela ne sera pas immédiatement évident pour les nœuds de
  vérification complète, mais ils seront capables de rejeter l'engagement de l'attaquant après que le
  propriétaire de l'UTXO révèle la clé publique.

  Après que l'engagement se confirme à une profondeur appropriée, le dépensier révèle la transaction
  complète correspondant au txid d'engagement. Les nœuds complets vérifient que la clé publique
  correspond à l'identifiant d'adresse et que, en combinaison avec le txid, elle correspond à la
  preuve dépendante de la séquence. À ce moment, les nœuds complets purgent tous les engagements sauf
  le plus ancien (le plus profondément confirmé) pour cet identifiant d'adresse. Seul le premier txid
  confirmé pour cet identifiant d'adresse avec une preuve dépendante de la séquence valide peut être
  résolu en une transaction confirmée.

  Dryja donne des détails supplémentaires sur la manière dont ce schéma pourrait être déployé comme un
  soft fork, comment l'octet d'engagement pourrait être réduit de moitié, et ce que les utilisateurs
  et les logiciels d'aujourd'hui peuvent faire pour se préparer à utiliser ce schéma---ainsi que les
  limitations de ce schéma pour les utilisateurs des [multisignatures scriptées][topic multisignature].

- **Variante OP_TXHASH avec support pour le parrainage de transaction :** Steven Roose a
  [posté][roose txsighash] sur Delving Bitcoin à propos d'une variation sur `OP_TXHASH` appelée
  `TXSIGHASH` qui étend les signatures [schnorr][topic schnorr signatures] de 64 octets avec des
  octets supplémentaires pour indiquer à quels champs dans la transaction (ou transactions liées) la
  signature s'engage. En plus des champs d'engagement proposés précédemment pour `OP_TXHASH`, Roose
  note que la signature pourrait s'engager sur une transaction antérieure dans le bloc en utilisant
  une forme efficace de [parrainage de transaction][topic fee sponsorship] (voir le [Bulletin
  #295][news295 sponsor]). Il analyse ensuite les coûts onchain de ce mécanisme par rapport au
  [CPFP][topic cpfp] existant et une proposition de parrainage précédente, concluant : "Avec
  l'empilement [`TXSIGHASH`], le coût en octets virtuels de chaque transaction empilée peut même être
  inférieur à leur coût original sans sponsor inclus [...] De plus, toutes les entrées sont des
  dépenses de clé « simples », ce qui signifie qu'elles pourraient être agrégées si [CISA][topic cisa]
  était déployé."

  À l'heure de la rédaction, le post n'avait reçu aucune réponse publique.

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement]
Propositions (BIPs)][bips repo], [Lightning BOLTs][bolts repo],[Lightning BLIPs][blips repo],
[Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #32540][] introduit le point de terminaison REST `/rest/spenttxouts/BLOCKHASH`, qui
  retourne une liste des sorties de transactions dépensées (prevouts) pour un bloc spécifié,
  principalement dans un format binaire compact (.bin) mais aussi en variantes .json et .hex. Bien
  qu'il était précédemment possible de faire cela avec le point de terminaison
  `/rest/block/BLOCKHASH.json`, le nouveau point de terminaison améliore la performance des indexeurs
  externes en éliminant la surcharge de la sérialisation JSON.

- [Bitcoin Core #32638][] ajoute une validation pour s'assurer que tout bloc lu depuis le disque
  correspond au hash de bloc attendu, détectant ainsi la corruption de données et les confusions
  d'index qui auraient pu passer inaperçues auparavant. Grâce au cache de hash d'en-tête introduit
  dans [Bitcoin Core #32487][], cette vérification supplémentaire est pratiquement sans surcoût.

- [Bitcoin Core #32819][] et [#32530][Bitcoin Core #32530] fixent les valeurs maximales pour les
  paramètres de démarrage `-maxmempool` et `-dbcache` à 500 Mo et 1 Go respectivement, sur les
  systèmes 32 bits. Étant donné que cette architecture a une limite totale de RAM de 4 Go, des valeurs
  supérieures aux nouvelles limites pourraient provoquer des incidents de manque de mémoire (OOM).

- [LDK #3618][] implémente la logique côté client pour les [paiements asynchrones][topic async
  payments], permettant à un nœud destinataire hors ligne de préarranger des [offres BOLT12][topic
  offers] et des factures statiques avec un nœud LSP toujours en ligne. La PR introduit un cache
  d'offres de réception asynchrone à l'intérieur de `ChannelManager` qui construit, stocke et fait persister
  les offres et les factures. Elle définit également les nouveaux messages onion et les hook
  nécessaires pour communiquer avec le LSP et intègre la machine à états dans le `OffersMessageFlow`.

{% include snippets/recap-ad.md when="2025-07-08 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32540,32638,32819,3618,1479,32487,32530" %}
[news255 presig vault state]: /fr/newsletters/2023/06/14/#discussion-sur-les-annexes-a-taproot
[news348 ctvstep]: /fr/newsletters/2025/04/04/#avantages-ctv-csfs
[news268 ptlc]: /fr/newsletters/2023/09/13/#changements-de-messagerie-ln-pour-les-ptlc
[news191 simple-ctv-vault]: /en/newsletters/2022/03/16/#continued-ctv-discussion
[news354 bitvm]: /fr/newsletters/2025/05/16/#description-des-avantages-pour-bitvm-de-op-ctv-et-op-csfs
[rubin lamport]: https://gnusha.org/pi/bitcoindev/CAD5xwhgzR8e5r1e4H-5EH2mSsE1V39dd06+TgYniFnXFSBqLxw@mail.gmail.com/
[osuntokun onion]: https://delvingbitcoin.org/t/reimagining-onion-messages-as-an-overlay-layer/1799/
[news283 oniondirect]: /fr/newsletters/2024/01/03/#ldk-2723
[news304 onionreply]: /fr/newsletters/2024/05/24/#core-lightning-7304
[sanders ptlc]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/7
[provoost ptlc]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/80
[sanders ptlc2]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/81
[sanders gist]: https://gist.github.com/instagibbs/1d02d0251640c250ceea1c66665ec163
[towns ptlc]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/82
[provoost ctvdesc]: https://delvingbitcoin.org/t/ctv-vault-output-descriptor/1766/
[simple-ctv-vault]: https://github.com/jamesob/simple-ctv-vault
[ingala vaultdesc]: https://github.com/bitcoin/bips/pull/1793#issuecomment-2749295131
[kanjalkar vaultdesc1]: https://delvingbitcoin.org/t/ctv-vault-output-descriptor/1766/3
[kanjalkar vaultdesc2]: https://delvingbitcoin.org/t/ctv-vault-output-descriptor/1766/9
[towns ctvbitvm]: https://delvingbitcoin.org/t/how-ctv-csfs-improves-bitvm-bridges/1591/8
[op_txhash]: /en/newsletters/2022/02/02/#composable-alternatives-to-ctv-and-apo
[stewart ctvimp]: https://delvingbitcoin.org/t/how-ctv-csfs-improves-bitvm-bridges/1591/25
[obeirne letter]: https://mailing-list.bitcoindevs.xyz/bitcoindev/a86c2737-db79-4f54-9c1d-51beeb765163n@googlegroups.com/
[sanders legacy]: https://mailing-list.bitcoindevs.xyz/bitcoindev/b17d0544-d292-4b4d-98c6-fa8dc4ef573cn@googlegroups.com/
[obeirne legacy]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAPfvXfKEgA0RCvxR=mP70sfvpzTphTZGidy=JuSK8f1WnM9xYA@mail.gmail.com/
[sanders p2ctv]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/72?u=harding
[lopp ctvvaults]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CADL_X_fxwKLdst9tYQqabUsJgu47xhCbwpmyq97ZB-SLWQC9Xw@mail.gmail.com/
[maxwell autodelete]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAAS2fgSmmDmEhi3y39MgQj+pKCbksMoVmV_SgQmqMOqfWY_QLg@mail.gmail.com/
[sanders ctvcom]: https://groups.google.com/g/bitcoindev/c/KJF6A55DPJ8/m/XVhyLCJiBQAJ
[towns ctvcom]: https://mailing-list.bitcoindevs.xyz/bitcoindev/aEu8CqGH0lX5cBRD@erisian.com.au/
[poinsot ctvcom]: https://mailing-list.bitcoindevs.xyz/bitcoindev/GLGZ3rEDfqaW8jAfIA6ac78uQzjEdYQaJf3ER9gd4e-wBXsiS2NK0wAj8LWK8VHf7w6Zru3IKbtDU5NM102jD8wMjjw8y7FmiDtQIy9U7Y4=@protonmail.com/
[provoost ctvcom]: https://mailing-list.bitcoindevs.xyz/bitcoindev/0B7CEBEE-FB2B-41CF-9347-B9C1C246B94D@sprovoost.nl/
[obeirne ctvcom]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAPfvXfLc5-=UVpcvYrC=VP7rLRroFviLTjPQfeqMQesjziL=CQ@mail.gmail.com/
[poelstra ctvcom]: https://mailing-list.bitcoindevs.xyz/bitcoindev/aEsvtpiLWoDsfZrN@mail.wpsoftware.net/
[roose ctvcom]: https://mailing-list.bitcoindevs.xyz/bitcoindev/035f8b9c-9711-4edb-9d01-bef4a96320e1@roose.io/
[goli ctvcom]: https://mailing-list.bitcoindevs.xyz/bitcoindev/mc0q6r14.59407778-1eb1-4e57-bcf2-c781d6f70b01@we.are.superhuman.com/
[conduition winternitz]: https://mailing-list.bitcoindevs.xyz/bitcoindev/uCSokD_EM3XBQBiVIEeju5mPOy2OU-TTAQaavyo0Zs8s2GhAdokhJXLFpcBpG9cKF03dNZfq2kqO-PpxXouSIHsDosjYhdBGkFArC5yIHU0=@proton.me/
[conduition impl]: https://gist.github.com/conduition/c6fd78e90c21f669fad7e3b5fe113182
[lamport signature]: https://en.wikipedia.org/wiki/Lamport_signature
[dryja fawkes]: https://mailing-list.bitcoindevs.xyz/bitcoindev/cc2f8908-f6fa-45aa-93d7-6f926f9ba627n@googlegroups.com/
[news348 fawkes]: /fr/newsletters/2025/04/04/#prouver-de-maniere-securisee-la-propriete-d-une-utxo-en-revelant-une-preimage-sha256
[roose txsighash]: https://delvingbitcoin.org/t/jit-fees-with-txhash-comparing-options-for-sponsorring-and-stacking/1760
[news295 sponsor]: /fr/newsletters/2024/03/27/#ameliorations-du-parrainage-des-frais-de-transaction
