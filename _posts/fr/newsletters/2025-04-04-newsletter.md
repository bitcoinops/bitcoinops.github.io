---
title: 'Bulletin Hebdomadaire Bitcoin Optech #348'
permalink: /fr/newsletters/2025/04/04/
name: 2025-04-04-newsletter-fr
slug: 2025-04-04-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine contient un lien vers une implémentation éducative de la
cryptographie sur courbe elliptique pour la courbe secp256k1 de Bitcoin. Sont également incluses
nos sections régulières résumant les discussions sur la modification des règles de consensus de
Bitcoin, annonçant de nouvelles versions et versions candidates, et décrivant les changements
notables apportés aux logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

- **Implémentation éducative et expérimentale de secp256k1 :**
  Sebastian Falbesoner, Jonas Nick et Tim Ruffing ont [publié][fnr secp] sur la liste de diffusion
  Bitcoin-Dev pour annoncer une [implémentation][secp256k1lab] en Python de diverses fonctions liées à
  la cryptographie utilisée dans Bitcoin. Ils avertissent que l'implémentation est "INSECURE" (en
  majuscules dans l'original) et "destinée àu prototypage, l'expérimentation et l'éducation."

  Ils notent également que le code de référence et de test pour plusieurs BIPs ([340][bip340],
  [324][bip324], [327][bip327], et [352][bip352]) inclut déjà "des implémentations personnalisées et
  parfois subtilement divergentes de secp256k1." Ils espèrent améliorer cette situation à l'avenir,
  peut-être en commençant par un BIP à venir pour ChillDKG (voir le [Bulletin #312][news312 chilldkg]).

## Modification du consensus

_Une nouvelle section mensuelle résumant les propositions et discussions sur la modification des
règles de consensus de Bitcoin._

- **Plusieurs discussions sur le vol par ordinateur quantique et la résistance :**
  plusieurs conversations ont examiné comment les Bitcoiners pourraient répondre à l'émergence
  d'ordinateurs quantiques assez puissants pour permettre le vol de bitcoins.

  - *Faut-il détruire les bitcoins vulnérables ?* Jameson Lopp a [posté][lopp destroy] sur la liste de
    diffusion Bitcoin-Dev plusieurs arguments en faveur de la destruction des bitcoins vulnérables au
    vol quantique après qu'une voie de mise à niveau vers la [résistance quantique][topic quantum
    resistance] ait été adoptée et que les utilisateurs aient eu le temps d'adopter la solution.

    Certains arguments incluent :

    - *Argument de la préférence commune :* il croit que la plupart des gens préféreraient que leurs
      fonds soient détruits plutôt que volés par quelqu'un avec un ordinateur quantique rapide. Surtout,
      dit-il, puisque le voleur sera parmi "les quelques privilégiés qui accèdent tôt aux ordinateurs
      quantiques".

    - *Argument du dommage commun :* beaucoup des bitcoins volés seront soit des pièces perdues, soit
      celles qui étaient prévues pour être conservées à long terme. En contraste, les voleurs pourraient
      rapidement dépenser leurs bitcoins volés, ce qui réduit le pouvoir d'achat des autres bitcoins
      (similaire à l'inflation de l'offre monétaire). Il note que le pouvoir d'achat dimuinué des bitcoins,
      réduit les revenus des mineurs, ainsi que la sécurité du réseau, et (selon son observation) résulte
      en une acceptation moindre des bitcoins par les commerçants.

    - *Argument du bénéfice minimal :* bien que permettre le vol pourrait être utilisé pour financer le
      développement de l'informatique quantique, voler des pièces ne procure aucun bénéfice direct aux
      participants honnêtes du protocole Bitcoin.

    - *Argument des échéances claires :* personne ne peut connaître longtemps à l'avance la date à
      laquelle quelqu'un avec un ordinateur quantique peut commencer à voler des bitcoins, mais une date
      spécifique à laquelle les pièces vulnérables au quantique seront détruites peut être annoncée
      longtemps à l'avance. Cette échéance claire fournira plus d'incitation pour les utilisateurs à
      sécuriser à nouveau leurs bitcoins à temps, assurant ainsi qu'un nombre moins important de pièces
      soit perdu.

    - *Argument basé sur les incitations des mineurs :* comme mentionné précédemment, le vol quantique
      réduirait probablement les revenus des mineurs. Une majorité persistante de hashrate peut censurer
      les dépenses de bitcoins vulnérables au quantique, ce qu'ils pourraient faire même si le reste des
      Bitcoiners préfère un résultat différent.

    Lopp fournit également plusieurs arguments contre la destruction des bitcoins vulnérables, mais il
    conclut en faveur de la destruction.

    Nagaev Boris [demande][boris timelock] si les UTXOs qui sont [verrouillés temporellement][topic
    timelocks] au-delà de la date limite de mise à niveau devraient également être détruits. Lopp note
    les pièges existants des longs verrouillages temporels et dit qu'il devient personnellement "un peu
    nerveux à l'idée de verrouiller des fonds pour plus d'un an ou deux."

  - *Prouver de manière sécurisée la propriété d'une UTXO en révélant une préimage SHA256 :* Martin
    Habovštiak [a posté][habovstiak gfsig] sur la liste de diffusion Bitcoin-Dev une idée qui pourrait
    permettre à quelqu'un de prouver qu'il contrôlait une UTXO même si les signatures ECDSA et
    [schnorr][topic schnorr signatures] étaient insécurisées (par exemple, après l'existence de
    calculateurs quantiques rapides). Si l'UTXO contenait un engagement SHA256 (ou un autre engagement
    résistant au quantique) envers une préimage qui n'avait jamais été révélée auparavant, alors un
    protocole en plusieurs étapes pour révéler cette préimage pourrait être combiné avec un changement
    de consensus pour prévenir le vol quantique. C'est fondamentalement la même chose qu'une
    [proposition précédente][ruffing gfsig] de Tim Ruffing (voir le [Bulletin #141][news141 gfsig]),
    qu'il a appris être généralement connue sous le nom de [schéma de signature de Guy Fawkes][]. C'est
    aussi une variante d'un [schéma][back crsig] inventé par Adam Back en 2013 pour améliorer la
    résistance contre la censure des mineurs. En bref, le protocole pourrait fonctionner comme ceci :

    1. Alice reçoit des fonds sur une sortie qui, d'une manière ou d'une autre, fait un engagement
       SHA256. Cela peut être une sortie directement hachée, telle que P2PKH, P2SH, P2WPKH, ou P2WSH---ou
       cela peut être une sortie [P2TR][topic taproot] avec un chemin de script.

    2. Si Alice reçoit plusieurs paiements sur le même script de sortie, elle doit soit ne dépenser
       aucun d'entre eux jusqu'à ce qu'elle soit prête à tous les dépenser (certainement requis pour P2PKH
       et P2WPKH ; probablement aussi pratiquement requis pour P2SH et P2WSH), soit elle doit être très
       prudente pour s'assurer qu'au moins une préimage reste non révélée par ses dépenses (facilement
       possible avec des dépenses de chemin de clé P2TR versus chemin de script).

    3. Lorsque Alice est prête à dépenser, elle crée en privé sa transaction de dépense normalement
       mais ne la diffuse pas. Elle obtient également des bitcoins sécurisés par un algorithme de signature
       sécurisé quantique afin de pouvoir payer les frais de transaction.

    4. Dans une transaction dépensant certains des bitcoins sécurisés quantiquement, elle s'engage sur
       les bitcoins non sécurisé (quantiquement) qu'elle veut dépenser et s'engage également sur la
       transaction de dépense privée (sans la révéler). Elle attend que cette transaction soit profondément
       confirmée.

    5. Après s'être assurée que sa transaction précédente ne peut
       pratiquement pas être réorganisée, elle révèle sa préimage précédemment privée
       et sa dépense non sécurisée face aux quantiques.

    6. Les nœuds sur le réseau cherchent dans la blockchain la première
       transaction qui s'engage sur la préimage. Si cette transaction
       s'engage sur la dépense non sécurisée face aux quantiques d'Alice, alors ils exécutent sa
       dépense. Sinon, ils ne font rien.

    Cela garantit qu'Alice n'a pas à révéler des informations vulnérables aux [attaques] quantiques
    après s'être déjà assurée que sa version de la transaction de dépense
    aura la priorité sur toute tentative de dépense par l'opérateur d'un ordinateur quantique. Pour une
    description plus précise du protocole, veuillez voir le post de [Ruffing en 2018][ruffing gfsig].
    Bien que non discuté dans le fil, nous pensons que le protocole ci-dessus pourrait être déployé comme un soft fork.

    Habovštiak soutient que les bitcoins qui peuvent être dépensés de manière sécurisée en utilisant
    ce protocole (par exemple, leur préimage n'a pas déjà été révélée)
    ne devraient pas être détruits même si la communauté décide qu'elle veut détruire les bitcoins
    vulnérables aux [attaques] quantiques en général. Il soutient également que
    la capacité de dépenser de manière sécurisée certains bitcoins en cas d'urgence
    réduit l'urgence de déployer un schéma résistant aux [attaques] quantiques à court terme.

    Lloyd Fournier [dit][fournier gfsig], "si cette approche est acceptée, je pense que l'action
    immédiate principale que les utilisateurs peuvent prendre est de
    passer à un portefeuille taproot" en raison de sa capacité à permettre le dépense par chemin de clé
    sous les règles de consensus actuelles, y compris dans le cas de
    [réutilisation d'adresse][topic output linking], mais aussi résistance au
    vol quantique si la dépense par chemin de clé est plus tard désactivée.

    Dans un fil séparé (voir l'élément suivant), Pieter Wuille [note][wuille
    nonpublic] que les UTXOs vulnérables au vol quantique incluent également les clés
    qui n'ont pas été utilisées publiquement mais qui sont connues de plusieurs
    parties, comme dans diverses formes de multisig (y compris LN,
    [DLCs][topic dlc], et les services d'escrow).

  - *Brouillon de BIP pour détruire les bitcoins non sécurisés face aux quantiques :* Agustin Cruz
    [a posté][cruz qramp] sur la mailing list Bitcoin-Dev un [brouillon de BIP][cruz
    bip] qui décrit plusieurs options pour un processus général de
    destruction des bitcoins vulnérables au vol quantique (si
    cela devient un risque attendu). Cruz soutient, "en imposant une
    date limite pour la migration, nous offrons aux propriétaires légitimes une opportunité claire,
    non négociable de sécuriser leurs fonds [...] une migration forcée, avec un préavis suffisant et des
    protections robustes, est à la fois réaliste et nécessaire pour protéger la sécurité à long terme de
    Bitcoin."

    Très peu de discussions sur le fil se sont concentrées sur le brouillon
    du BIP. La plupart portaient sur la question de savoir si détruire
    les bitcoins vulnérables aux [attaques] quantiques était une bonne idée, similaire au fil plus tard
    commencé par Jameson Lopp (décrit dans un sous-élément précédent).

- **Plusieurs discussions sur un soft fork CTV+CSFS :** plusieurs
  conversations ont examiné divers aspects du soft forking dans les
  opcodes [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV) et
  [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] (CSFS).

  - *Critique de la motivation de CTV :* Anthony Towns [a posté][towns ctvmot]
    une critique de la motivation décrite pour CTV dans [BIP119][], une motivation que l'on a argumenté
    serait compromise par l'ajout simultané de CTV et de CSFS à Bitcoin. Plusieurs jours après le début
    de la discussion, BIP119 a été mis à jour par son auteur pour retirer la plupart (et possiblement la
    totalité) du langage controversé ; voir le [Bulletin #347][news347 bip119] pour notre résumé du
    changement et la [version antérieure][bip119 prechange] de BIP119 pour référence. Certains des
    sujets discutés incluaient :

    - *CTV+CSFS permet la création d'un covenant perpétuel :* La motivation de CTV disait, "Les
      covenants ont historiquement été largement considérés comme inadaptés pour Bitcoin car ils sont trop
      complexes à implémenter et risquent de réduire la fongibilité des pièces liées par eux. Ce BIP
      introduit un covenant simple appelé un *modèle* qui permet un ensemble limité de cas d'utilisation
      très précieux sans risque significatif. Les modèles BIP119 permettent des covenants
      **non-récursifs** entièrement énumérés sans état dynamique" (emphase dans l'original).

      Towns décrit un script utilisant à la fois CTV et CSFS, et renvoie à une [transaction][mn recursive]
      l'utilisant sur le signet MutinyNet [signet][topic signet], qui ne peut être dépensée qu'en
      renvoyant le même montant de fonds au script lui-même. Bien qu'il y ait eu un débat sur les
      définitions, l'auteur de CTV a [précédemment décrit][rubin recurse] une construction
      fonctionnellement identique comme un covenant récursif et Optech a suivi cette convention dans son
      résumé de cette conversation (voir le [Bulletin #190][news190 recursive]).

      Olaoluwa Osuntokun [a défendu][osuntokun enum] la motivation de CTV liée au fait que les scripts
      l'utilisant restent "entièrement énumérés" et "sans état dynamique". Cela semble être similaire à un
      [argument][rubin enumeration] que l'auteur de CTV (Jeremy Rubin) a fait en 2022, où il a qualifié le
      type de covenant pay-to-self que Towns a conçu de "récursif mais entièrement énuméré". Towns [a
      répliqué][towns enum] que l'ajout de CSFS compromet l'avantage revendiqué de l'énumération complète.
      Il a demandé à ce que les BIP de CTV ou de CSFS soient mis à jour pour décrire des "cas
      d'utilisation qui sont à la fois effrayants et encore empêchés par la combinaison de CTV et CSFS".
      Cela a peut-être été [fait][ctv spookchain] dans la mise à jour récente de BIP119, qui décrit un
      "automatisme auto-reproducteur (appelée familièrement SpookChains)" qui serait possible en utilisant
      [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] mais qui n'est pas possible en utilisant CTV+CSFS.

    - *Outils pour CTV et CSFS :* Towns [a noté][towns ctvmot] qu'il trouvait difficile d'utiliser les
      outils existants pour développer son script récursif décrit ci-dessus, indiquant un manque de
      préparation pour le déploiement. Osuntokun [a dit][osuntokun enum] que les outils qu'il utilise sont
      "assez simples". Ni Towns ni Osuntokun n'ont mentionné quels outils ils utilisaient. Nadav Ivgi [a
      fourni][ivgi minsc]
      un exemple utilisant son langage [Minsc][] et a dit qu'il a "travaillé à améliorer Minsc pour rendre
      ce genre de choses plus facile. Il prend en charge Taproot, CTV, PSBT, Descriptors, Miniscript, raw
      Script, BIP32, et plus." Bien qu'il admette que "beaucoup reste encore non documenté".

    - *Alternatives :* Towns compare CTV+CSFS à la fois à son Basic Bitcoin Lisp Language ([bll][topic
      bll]) et à [Simplicity][topic simplicity], qui offrirait un langage de script alternatif. Antoine
      Poinsot [suggère][poinsot alt] qu'un langage alternatif facile à comprendre pourrait être moins
      risqué qu'un petit changement au système actuel, difficile à appréhender. Le développeur Moonsettler
      [argumente][moonsettler express] que l'introduction progressive de nouvelles fonctionnalités au
      script Bitcoin le rend plus sûr pour ajouter d'autres fonctionnalités plus tard, car chaque
      augmentation de l'expressivité rend moins probable que nous rencontrions une surprise.

      Osuntokun et James O'Beirne [critiquent][osuntokun enum] la [préparation][obeirne readiness] de bll
      et Simplicity par rapport à CTV et CSFS.

  - *Avantages CTV+CSFS :* Steven Roose [a posté][roose ctvcsfs] sur Delving Bitcoin pour suggérer
    d'ajouter CTV et CSFS à Bitcoin comme première étape vers d'autres changements qui augmenteraient
    encore plus l'expressivité. La plupart de la discussion s'est concentrée sur la qualification des
    avantages possibles de CTV, CSFS, ou des deux ensemble. Cela incluait :

    - *DLCs :* CTV et CSFS, individuellement, peuvent réduire le nombre de signatures nécessaires pour
      créer des [DLCs][topic dlc], en particulier des DLCs pour signer un grand nombre de variantes d'un
      contrat (par exemple, un contrat de prix BTC-USD dénommé par incréments d'un dollar). Antoine
      Poinsot [a lié][poinsot ctvcsfs1] à une récente [annonce][10101 shutdown] d'un fournisseur de
      services DLC fermant ses portes comme preuve que les utilisateurs de Bitcoin ne semblent pas trop
      intéressés par les DLCs et a lié à un [post][nick dlc] il y a quelques mois de Jonas Nick qui
      disait, "Les DLCs n'ont pas atteint une adoption significative sur Bitcoin, et leur utilisation
      limitée ne semble pas provenir de limitations de performance." Les réponses ont lié à d'autres
      fournisseurs de services DLC encore fonctionnels, dont un qui [prétend][lava 30m] avoir levé "30M$
      en financement".

    - *Vaults :* CTV simplifie la mise en œuvre de [coffre-forts][topic vaults] qui sont possibles aujourd'hui
      sur Bitcoin en utilisant des transactions pré-signées et (optionnellement) la suppression de clé
      privée. Anthony Towns [argumente][towns vaults] que ce type de coffre-fort n'est pas très intéressant.
      James O'Beirne [contre-argumente][obeirne ctv-vaults] que CTV, ou quelque chose de similaire, est
      une condition préalable pour construire des types de coffre-forts plus avancés, tels que ses coffre-forts
      `OP_VAULT` [BIP345][].

    - *Contrats de calcul responsables :* CSFS peut éliminer de nombreuses étapes dans les [contrats de
      calcul responsables][topic acc] tels que BitVM en
      remplaçant leur besoin actuel d'effectuer des signatures basées sur des scripts Lamport. CTV
      pourrait être en mesure de réduire certaines opérations de signature supplémentaires. Poinsot
      demande à nouveau [poinsot ctvcsfs1] s'il existe une demande significative pour BitVM. Gregory
      Sanders [répond][sanders bitvm] qu'il trouverait cela intéressant pour le pontage bidirectionnel de
      jetons dans le cadre de la [validation côté client][topic client-side validation] protégée (voir
      le [Bulletin #322][news322 csv-bitvm]). Cependant, il note également que ni CTV ni CSFS n'améliorent
      significativement le modèle de confiance de BitVM, tandis que d'autres changements pourraient être
      en mesure de réduire la confiance ou de réduire le nombre d'opérations coûteuses de différentes
      manières.

    - *Amélioration dans le script de verrouillage temporel de Liquid :* James O'Beirne [a
      relayé][obeirne liquid] des commentaires de deux ingénieurs de Blockstream selon lesquels CTV
      pourrait, selon ses mots, "améliorer considérablement le script de secours de verrouillage temporel
      [Blockstream] Liquid qui nécessite que les pièces soient [déplacées] sur une base périodique." Après
      des demandes de clarification, l'ancien ingénieur de Blockstream Sanket Kanjalkar [a
      expliqué][kanjalkar liquid] que l'avantage pourrait être une économie significative sur les frais de
      transaction onchain. O'Beirne a également [partagé][poelstra liquid] des détails supplémentaires
      d'Andrew Poelstra, directeur de la recherche chez Blockstream.

    - *LN-Symmetry :* CTV et CSFS ensemble peuvent être utilisés pour implémenter une forme de
      [LN-Symmetry][topic eltoo], qui élimine certains des inconvénients des canaux [LN-Penalty][topic
      ln-penalty] actuellement utilisés dans LN et peut permettre la création de canaux avec plus de deux
      parties, ce qui pourrait améliorer la gestion de la liquidité et l'efficacité onchain. Gregory
      Sanders, qui a mis en œuvre une version expérimentale de LN-Symmetry (voir le [Bulletin #284][news284
      lnsym]) utilisant [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] (APO), [note][sanders versus] que
      la version CTV+CSFS de LN-Symmetry n'est pas aussi riche en fonctionnalités que la version APO et
      nécessite de faire des compromis. Anthony Towns [ajoute][towns nonrepo] que personne n'est connu
      pour avoir mis à jour le code expérimental de Sanders pour APO afin de fonctionner sur des logiciels
      modernes et d'utiliser des fonctionnalités de relais récemment introduites telles que [TRUC][topic
      v3 transaction relay] et les [ancres éphémères][topic ephemeral anchors], encore moins quelqu'un a porté
      le code pour utiliser CTV+CSFS, limitant notre capacité à évaluer cette combinaison pour LN-Symmetry.

      Poinsot [demande][poinsot ctvcsfs1] si l'implémentation de LN-Symmetry serait une priorité pour les
      développeurs de LN si un soft fork le rendait possible. Des citations de deux développeurs de Core
      Lightning (également co-auteurs du papier introduisant ce que nous appelons maintenant LN-Symmetry)
      ont indiqué que c'était une priorité pour eux. En comparaison, le développeur principal de LDK, Matt
      Corallo [a dit précédemment][corallo eltoo], "Je ne trouve pas [LN-Symmetry] si intéressant en
      termes de 'nous devons le faire'".

    - *Ark :* Roose est le PDG d'une entreprise qui développe une implémentation d'[Ark][topic ark]. Il
      dit : "CTV est un changement de jeu pour Ark [...] les avantages de CTV pour l'expérience
      utilisateur sont indéniables, et il ne fait aucun doute que les deux implémentations d'[Ark] utiliseront
      CTV dès qu'il sera disponible." Towns [a noté][towns nonrepo] que personne n'a implémenté Ark avec
      APO ou CTV pour les tests ; Roose a écrit [du code][roose ctv-ark] faisant cela peu après, le
      qualifiant de "remarquablement simple" et disant qu'il a passé les tests d'intégration de
      l'implémentation existante. Il a quantifié certaines des améliorations : si nous passions à CTV,
      "nous pourrions supprimer environ 900 lignes de code [...] et réduire notre propre protocole de tour
      à [deux] au lieu de trois, [plus] l'amélioration de la bande passante pour ne pas avoir à
      transmettre des nonces de signature et des signatures partielles."

      Roose commencerait plus tard un fil séparé pour discuter des avantages de CTV pour les utilisateurs
      d'Ark (voir notre résumé ci-dessous).

  - *Avantage de CTV pour les utilisateurs d'Ark :* Steven Roose [a posté][roose ctv-for-ark] sur
    Delving Bitcoin une courte description du protocole [Ark][topic ark] actuellement déployé sur
    [signet][topic signet], appelé [coventless Ark][clark doc] (clArk), et comment la disponibilité de
    l'opcode [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV) pourrait rendre une version du
    protocole utilisant un [covenant][topic covenants] plus attrayante pour les utilisateurs lorsqu'elle
    sera finalement déployée sur le mainnet.

    Un objectif de conception pour Ark est de permettre des [paiements asynchrones][topic async
    payments] : des paiements effectués lorsque le destinataire est hors ligne. Dans clArk, cela est
    réalisé par l'envoyeur plus un serveur Ark étendant la chaîne existante de transactions
    pré-signées de l'envoyeur, permettant au destinataire de prendre finalement le contrôle exclusif sur
    les fonds. Le paiement est appelé un paiement Ark [hors-tour][oor doc] (_arkoor_). Lorsque le
    destinataire se connecte, il peut choisir ce qu'il veut faire :

    - *Sortir, après un délai :* diffuser toute la chaîne de transactions pré-signées, sortant du
      [joinpool][topic joinpools] (appelé un _Ark_). Cela nécessite d'attendre l'expiration d'un
      verrouillage temporel convenu par l'envoyeur. Lorsque les transactions pré-signées sont confirmées
      à une profondeur appropriée, le destinataire peut être certain d'avoir un contrôle sans confiance
      sur les fonds. Cependant, ils perdent les avantages de faire partie d'une joinpool, tels que le
      règlement rapide et des frais plus bas découlant du partage d'UTXO. Ils peuvent également devoir
      payer des frais de transaction pour confirmer la chaîne de transactions.

    - *Rien :* dans le cas normal, une transaction pré-signée dans la chaîne de transactions expirera
      éventuellement et permettra au serveur de réclamer les fonds. Ce n'est pas un vol, c'est une partie
      attendue du protocole, et le serveur peut choisir de retourner tout ou partie des fonds réclamés à
      l'utilisateur d'une manière ou d'une autre. Jusqu'à ce que l'expiration approche, le destinataire
      peut juste attendre.

      Dans le cas pathologique, le serveur et l'envoyeur peuvent (à tout moment) conspirer pour signer
      une chaîne alternative de transactions pour voler les
      fonds envoyés au destinataire. Note : Les propriétés de confidentialité de Bitcoin permettent au
      serveur et à l'envoyeur d'être la même personne, donc la collusion pourrait ne même pas être
      nécessaire. Cependant, si le destinataire conserve une copie de la chaîne de transactions cosignée
      par le serveur, il peut prouver que le serveur a volé des fonds, ce qui pourrait être suffisant pour
      dissuader d'autres personnes d'utiliser ce serveur.

    - *Rafraîchissement :* avec la coopération du serveur, le destinataire peut transférer de manière
      atomique la propriété des fonds dans la transaction cosignée par l'envoyeur pour une autre
      transaction présignée avec le destinataire en tant que cosignataire. Cela prolonge la date
      d'expiration et élimine la capacité pour le serveur et l'envoyeur précédent de conspirer pour
      voler les fonds précédemment envoyés. Cependant, le rafraîchissement exige que le serveur conserve
      les fonds rafraîchis jusqu'à leur expiration, réduisant la liquidité du serveur, donc le serveur
      facture au destinataire un taux d'intérêt jusqu'à l'expiration (payé à l'avance puisque le temps
      d'expiration est fixé).

    Un autre objectif de conception pour Ark est de permettre aux participants de recevoir des paiements
    LN. Dans son post original et une [réponse][roose ctv-ark-ln], Roose décrit que les participants
    existants qui ont déjà des fonds dans la joinpool peuvent être pénalisés jusqu'au coût d'une
    transaction onchain s'ils échouent à effectuer l'interactivité requise pour recevoir un paiement LN.
    Cependant, ceux qui n'ont pas déjà des fonds dans la joinpool ne peuvent pas être pénalisés, donc ils
    peuvent refuser d'effectuer les étapes interactives et créer des problèmes sans coût pour les
    participants honnêtes. Cela semble effectivement empêcher les utilisateurs d'Ark de recevoir des
    paiements LN à moins qu'ils n'aient déjà une quantité modérée de fonds déposés avec le serveur Ark
    qu'ils souhaitent utiliser.

    Roose décrit ensuite comment la disponibilité de CTV permettrait d'améliorer le protocole. Le
    principal changement concerne la manière dont les tours Ark sont créés. Une _tour Ark_ consiste en
    une petite transaction onchain qui s'engage sur un arbre de transactions offchain. Ce sont des
    transactions présignées dans le cas de clArk, nécessitant que tous les envoyeurs de ce tour soient
    disponibles pour signer. Si CTV était disponible, chaque branche dans l'arbre de transactions peut
    s'engager sur ses descendants en utilisant CTV sans nécessité de signature. Cela permet la création
    de transactions même pour les participants qui ne sont pas disponibles au moment où le tour est
    créé, avec les avantages suivants :

    - *Paiements non interactifs en tour :* au lieu des paiements Ark hors tour (arkoor), un envoyeur
      qui est prêt à attendre le prochain tour peut payer le destinataire en tour. Pour le destinataire,
      cela a un avantage majeur : dès que le tour est confirmé à une profondeur appropriée, ils reçoivent
      un contrôle sans confiance sur leurs fonds reçus (jusqu'à ce que l'expiration approche, à ce moment
      ils peuvent soit sortir soit rafraîchir à moindre coût). Au lieu d'attendre plusieurs confirmations,
      le destinataire peut choisir de faire immédiatement confiance aux incitations créées par le
      protocole Ark pour que le serveur opère honnêtement (voir le [Bulletin #253][news253 ark 0conf]).
      Dans un point séparé, Roose note que ces paiements non interactifs peuvent également être
      [regroupés][topic payment batching] pour payer plusieurs destinataires à la fois.

    - *Acceptation en tour des paiements LN :* un utilisateur pourrait demander qu'un paiement LN
      ([HTLC][topic htlc]) soit envoyé à un serveur Ark, le serveur
      retiendrait alors le paiement jusqu'à son prochain cycle, et utiliserait CTV pour inclure un
      paiement verrouillé par HTLC à l'utilisateur dans le cycle---après quoi l'utilisateur pourrait
      révéler la préimage HTLC pour réclamer le paiement. Cependant, Roose a noté que cela nécessiterait
      toujours l'utilisation de "diverses mesures anti-abus" (nous pensons que cela est dû au risque que
      le destinataire ne divulgue pas la préimage, conduisant à ce que les fonds du serveur restent
      verrouillés jusqu'à la fin du cycle Ark, qui pourrait s'étendre sur deux mois ou plus).

      David Harding a répondu à Roose en demandant des détails supplémentaires et en comparant la
      situation aux canaux LN [JIT][topic jit channels], qui ont un problème similaire avec la
      non-révélation des préimages HTLC créant des problèmes pour les Fournisseurs de Services Lightning
      (LSPs). Les LSPs abordent actuellement ce problème par l'introduction de mécanismes basés sur la
      confiance (voir le [Bulletin #256][news256 ln-jit]). Si les mêmes solutions étaient prévues pour être
      utilisées avec CTV-Ark, ces solutions permettraient également d'accepter en toute sécurité les
      paiements LN pendant le cycle clArk.

    - *Moins de cycles, moins de signatures et moins de stockage :* clArk utilise [MuSig2][topic musig],
      et chaque partie doit participer à plusieurs cycles, générer plusieurs signatures partielles et
      stocker les signatures complètes. Avec CTV, moins de données devraient être générées et stockées et
      moins d'interactions seraient nécessaires.

- **Sémantique de OP_CHECKCONTRACTVERIFY :** Salvatore Ingala a [posté][ingala ccv] sur Delving
  Bitcoin pour décrire la sémantique du code opérationnel proposé [OP_CHECKCONTRACTVERIFY][topic matt]
  (CCV), lier à un [premier projet de BIP][ccv bip], et lier à un [projet d'implémentation][bitcoin
  core #32080] pour Bitcoin Core. Sa description commence par un aperçu du comportement de CCV : il
  permet de vérifier qu'une clé publique s'engage sur un morceau de données arbitraire. Il peut
  vérifier à la fois la clé publique de la sortie [taproot][topic taproot] dépensée ou la clé publique
  d'une sortie taproot en cours de création. Cela peut être utilisé pour s'assurer que les données de
  la sortie dépensée sont transférées à la sortie créée. Dans taproot, une modification de la sortie
  peut s'engager sur des tapleaves tels que [tapscripts][topic tapscript]. Si la modification s'engage
  sur un ou plusieurs tapscripts, elle place une _entrave_ (condition de dépense) sur la sortie,
  permettant de transférer les conditions placées sur la sortie dépensée à la sortie
  créée---communément (mais [controversé][towns anticov]) appelé un [covenant][topic covenants] dans
  le jargon Bitcoin. Le covenant peut permettre la satisfaction ou la modification de l'entrave, ce
  qui terminerait (respectivement) le covenant ou modifierait ses termes pour les itérations futures.
  Ingala décrit certains des avantages et inconvénients de cette approche :

  - *Avantages :* natif à taproot, n'augmente pas la taille des entrées taproot dans l'ensemble UTXO,
    et les chemins de dépense qui ne nécessitent pas les données supplémentaires n'ont pas besoin de les
    inclure dans leur pile de témoins (donc il n'y a pas de coût supplémentaire dans ce cas).

  - *Inconvénients :* fonctionne uniquement avec taproot et la vérification des ajustements nécessite
    des opérations sur courbes elliptiques qui sont plus coûteuses que (par exemple) les opérations SHA256.

  Transférer uniquement les conditions de dépense de la sortie dépensée vers une sortie en cours de
  création peut être utile, mais de nombreux covenants voudront s'assurer que certains ou tous les
  bitcoins de la sortie dépensée sont transférés vers la sortie créée. Ingala décrit les trois options
  de CCV pour gérer les valeurs.

  - *Ignorer :* ne pas vérifier les montants.

  - *Déduire :* le montant d'une sortie créée à un index particulier (par exemple, la troisième
    sortie) est déduit du montant de la sortie dépensée au même index et la valeur résiduelle est
    suivie. Par exemple, si la sortie dépensée à l'index trois vaut 100 BTC et la sortie créée à l'index
    trois vaut 70 BTC, alors le code garde une trace des 30 BTC résiduels. La transaction est marquée
    comme invalide si la sortie créée est supérieure à la sortie dépensée (car cela réduirait la valeur
    résiduelle, peut-être en dessous de zéro).

  - *Par défaut :* marquer la transaction comme invalide à moins que le montant de la sortie créée à
    un index particulier ne soit supérieur au montant de la sortie dépensée plus la somme de tous les
    résiduels précédents qui n'ont pas encore été utilisés avec une vérification _par défaut_.

  Une transaction est valide si une sortie est vérifiée plus d'une fois avec _déduire_ ou si _déduire_
  et _par défaut_ sont utilisés sur la même sortie.

  Ingala fournit plusieurs exemples visuels de combinaisons des opérations ci-dessus. Voici notre
  description textuelle de son exemple "envoyer un montant partiel", qui pourrait être utile pour un
  [coffre-fort][topic vaults] : une transaction a une entrée (dépensant une sortie) valant 100 BTC et deux
  sorties, une pour 70 BTC et l'autre pour 30 BTC. CCV est exécuté deux fois lors de la validation de
  la transaction :

  1. CCV avec _déduire_ opère à l'index 0 pour 100 BTC dépensés pour 70 BTC créés, donnant un résiduel
     de 30. Dans un coffre-fort de style [BIP345][], CCV retournerait ces 70 BTC au même script par lequel ils
     étaient précédemment sécurisés.

  2. La deuxième fois, il utilise _par défaut_ à l'index 1. Bien qu'il y ait une sortie créée à
     l'index 1 dans cette transaction, il n'y a pas de sortie correspondante dépensée à l'index 1, donc
     le montant implicite `0` est utilisé. À ce zéro est ajouté le résiduel de 30 BTC de l'appel
     _déduire_ à l'index 0, exigeant que cette sortie créée soit égale ou supérieure à 30 BTC. Dans un
     coffre-fort de style BIP345, CCV modifierait le script de sortie pour permettre de dépenser cette valeur à
     une adresse arbitraire après l'expiration d'un [timelock][topic timelocks] ou de la retourner à
     l'adresse principale du coffre-fort de l'utilisateur à tout moment.

  Plusieurs approches alternatives qu'Ingala a considérées et écartées sont discutées à la fois dans
  son post et les réponses. Il écrit : "Je pense que les deux comportements de montant (par défaut et
  déduire) sont très ergonomiques et couvrent la grande majorité des vérifications de montant
  souhaitables en pratique."

  Il note également qu'il a "implémenté des coffres entièrement fonctionnels en utilisant `OP_CCV`
  plus [OP_CTV][topic op_checktemplateverify] qui sont approximativement équivalents à
  [...[BIP345][]...]. De plus, une version à fonctionnalité réduite utilisant juste `OP_CCV` est
  implémentée comme un test fonctionnel dans l'implémentation Bitcoin Core de `OP_CCV`."

- **Brouillon de BIP publié pour le nettoyage du consensus :** Antoine Poinsot a [posté][poinsot
  cleanup] sur la liste de diffusion Bitcoin-Dev un lien vers un [brouillon de BIP][cleanup bip] qu'il
  a écrit pour la proposition de soft fork de [nettoyage du consensus][topic consensus cleanup]. Il
  inclut plusieurs corrections :

  - Corrections pour deux différentes attaques de [déformation temporelle][topic time warp] qui
    pourraient être utilisées par une majorité de hashrate pour produire des blocs à un rythme accéléré.

  - Une limite d'exécution des opérations de signature (sigops) sur les transactions héritées pour
    éviter la création de blocs excessivement lents à valider.

  - Une correction pour l'unicité des transactions coinbase de [BIP34][] qui devrait empêcher
    totalement les [transactions dupliquées][topic duplicate transactions].

  - Invalidité des futures transactions de 64 octets (calculées en utilisant la taille nette) pour
    prévenir un type de [vulnérabilité de l'arbre de Merkle][topic merkle tree vulnerabilities].

  Les réponses techniques étaient favorables pour toutes les parties de la proposition, sauf deux. La
  première objection, faite dans plusieurs réponses, concernait l'invalidation des transactions de 64
  octets. Les réponses réitéraient une critique précédente (voir le [Bulletin #319][news319 64byte]).
  Une méthode alternative pour aborder les vulnérabilités de l'arbre de Merkle existe. Cette méthode
  est relativement facile à utiliser pour les portefeuilles légers (SPV) mais pourrait présenter des
  défis pour la validation SPV dans les contrats intelligents, tels que les _ponts_ entre Bitcoin et
  d'autres systèmes. Sjors Provoost a [suggéré][provoost bridge] que quelqu'un mettant en œuvre un
  pont exécutable onchain fournisse du code illustrant la différence entre pouvoir supposer que
  les transactions de 64 octets n'existent pas et devoir utiliser la méthode alternative pour prévenir
  les vulnérabilités de l'arbre de Merkle.

  La seconde objection concernait un changement tardif des idées incluses dans le BIP, qui a été
  décrit dans un [post][poinsot nsequence] sur Delving Bitcoin par Poinsot. Le changement exige que
  les blocs créés après l'activation du nettoyage du consensus définissent le drapeau rendant
  exécutoire le verrouillage temporel de leur transaction coinbase. Comme précédemment proposé, les
  transactions coinbase dans les blocs post-activation fixeront leur verrouillage temporel à la
  hauteur de leur bloc (moins 1). Ce changement signifie qu'aucun mineur ne peut produire un bloc
  Bitcoin alternatif précoce qui utilise à la fois le verrouillage temporel post-activation et définit
  le drapeau d'exécution (car, s'ils le faisaient, leur transaction coinbase ne serait pas valide dans
  le bloc qui l'incluait en raison de son utilisation d'un verrouillage temporel trop éloigné dans le
  futur). L'impossibilité d'utiliser exactement les mêmes valeurs dans une transaction coinbase passée
  que celles qui seront utilisées dans une future transaction coinbase empêche la vulnérabilité des
  transactions dupliquées. L'objection à cette proposition était qu'il n'était pas clair si tous les
  mineurs sont capables de définir le drapeau d'exécution du verrouillage temporel.

## Mises à jour et versions candidates

_Nouvelles mises à jour et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de passer aux nouvelles versions ou d'aider à tester
les versions candidates._

- [BDK wallet 1.2.0][] ajoute de la flexibilité pour envoyer des paiements à des scripts
  personnalisés, corrige un cas limite lié aux transactions coinbase, et inclut plusieurs autres
  fonctionnalités et corrections de bugs.

- [LDK v0.1.2][] est une version de cette bibliothèque pour la construction d'applications
  compatibles LN. Elle contient plusieurs améliorations de performance et corrections de bugs.

- [Bitcoin Core 29.0rc3][] est un candidat à la version pour la prochaine version majeure du nœud
  complet prédominant du réseau. Veuillez consulter le [guide de test de la version 29][bcc29 testing
  guide].

- [LND 0.19.0-beta.rc1][] est un candidat à la version pour ce nœud LN populaire. L'une des
  principales améliorations qui pourrait probablement nécessiter des tests est le nouveau bumping de
  frais basé sur RBF pour les fermetures coopératives.

## Changements de code et de documentation notables

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration de Bitcoin (BIPs)][bips
repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin
inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #31363][] introduit la classe `TxGraph` (voir le [Bulletin #341][news341 pr review]),
  un modèle léger en mémoire des transactions du mempool qui suit uniquement les taux de frais et les
  dépendances entre transactions. Il inclut des fonctions de mutation telles que `AddTransaction`,
  `RemoveTransaction`, et `AddDependency`, et des fonctions d'inspection telles que `GetAncestors`,
  `GetCluster`, et `CountDistinctClusters`. `TxGraph` supporte également la mise en scène des
  changements avec des fonctionnalités de validation et d'abandon. Cela fait partie du projet [cluster
  de mempool][topic cluster mempool] et prépare pour de futures améliorations sur l'éviction du mempool,
  le traitement de la réorganisation, et la logique de minage consciente des clusters.

- [Bitcoin Core #31278][] déprécie la commande RPC `settxfee` et l'option de démarrage `-paytxfee`,
  qui permettent aux utilisateurs de définir un taux de frais statique pour toutes les transactions.
  Les utilisateurs devraient plutôt se fier à [l'estimation des frais][topic fee estimation] ou
  définir un taux de frais par transaction. Ils sont marqués pour suppression dans Bitcoin Core 31.0.

- [Eclair #3050][] met à jour la manière dont les échecs de paiement [BOLT12][topic offers] sont
  relayés lorsque le destinataire est un nœud directement connecté, pour toujours transmettre le
  message d'échec au lieu de le remplacer par un échec `invalidOnionBlinding` illisible. Si l'échec
  inclut une `channel_update`, Eclair le remplace par `TemporaryNodeFailure` pour éviter de révéler
  des détails sur [les canaux non annoncés][topic unannounced channels]. Pour [les routes
  aveuglées][topic rv routing] impliquant d'autres nœuds, Eclair continue de remplacer les échecs par
  `invalidOnionBlinding`. Tous les messages d'échec sont cryptés en utilisant l'`blinded_node_id` du
  portefeuille.

- [Eclair #2963][] implémente le relais de paquets un-parent-un-enfant (1p1c) [package relay][topic
  package relay] en appelant la commande RPC `submitpackage` de Bitcoin Core lors des fermetures
  forcées de canaux pour diffuser à la fois la transaction d'engagement et son ancre ensemble. Cela
  permet aux transactions d'engagement de se propager même si leur taux de frais est inférieur au
  minimum du mempool, mais nécessite de se connecter à des pairs exécutant Bitcoin Core 28.0 ou
  ultérieur. Ce changement élimine le besoin de définir dynamiquement le taux de frais des
  transactions d'engagement et assure que les fermetures forcées ne restent pas bloquées lorsque les
  nœuds ne sont pas d'accord sur le taux de frais actuel.

- [Eclair #3045][] rend le champ `payment_secret` dans la charge utile externe de l'oignon optionnel
  pour les [paiements trampoline][topic trampoline payments] à partie unique. Auparavant, chaque
  paiement trampoline incluait un `payment_secret`, même si un [multipath payment][topic multipath
  payments] (MPP) n'était pas utilisé. Étant donné que les secrets de paiement peuvent être requis
  lors du traitement des factures [BOLT11][] modernes, Eclair insère un faux en cas de déchiffrement
  si aucun n'est fourni.

- [LDK #3670][] ajoute la prise en charge pour gérer et recevoir des [paiements trampoline][topic
  trampoline payments], mais n'implémente pas encore la fourniture d'un service de routage trampoline.
  C'est une condition préalable pour un type de [paiement asynchrone][topic async payments] que LDK
  prévoit de déployer.

- [LND #9620][] ajoute le support de [testnet4][topic testnet] en ajoutant les paramètres
  nécessaires et les constantes de la blockchain telles que son hash de genèse.

{% include snippets/recap-ad.md when="2025-04-08 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31363,31278,3050,2963,3045,3670,9620,32080" %}
[bitcoin core 29.0rc3]: https://bitcoincore.org/bin/bitcoin-core-29.0/
[bcc29 testing guide]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/29.0-Release-Candidate-Testing-Guide
[lnd 0.19.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc1
[back crsig]: https://bitcointalk.org/index.php?topic=206303.msg2162962#msg2162962
[bip119 prechange]: https://github.com/bitcoin/bips/blob/9573e060e32f10446b6a2064a38bdc2047171d9c/bip-0119.mediawiki
[news75 ctv]: /en/newsletters/2019/12/04/#op-checktemplateverify-ctv
[news190 recursive]: /en/newsletters/2022/03/09/#limiting-script-language-expressiveness
[modern ctv]: /en/newsletters/2019/12/18/#proposed-changes-to-bip-ctv
[rubin enumeration]: https://gnusha.org/pi/bitcoindev/CAD5xwhjj3JAXwnrgVe_7RKx0AVDDy4X-L9oOnwhswXAQFoJ7Bw@mail.gmail.com/
[towns ctvmot]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Z8eUQCfCWjdivIzn@erisian.com.au/
[mn recursive]: https://mutinynet.com/address/tb1p0p5027shf4gm79c4qx8pmafcsg2lf5jd33tznmyjejrmqqx525gsk5nr58
[rubin recurse]: https://gnusha.org/pi/bitcoindev/CAD5xwhjsVA7k7ZQ_QdrcZOxdi+L6L7dvqAj1Mhx+zmBA3DM5zw@mail.gmail.com/
[osuntokun enum]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAO3Pvs-1H2s5Dso0z5CjKcHcPvQjG6PMMXvgkzLwXgCHWxNV_Q@mail.gmail.com/
[towns enum]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Z8tes4tXo53_DRpU@erisian.com.au/
[ctv spookchain]: https://github.com/bitcoin/bips/pull/1792/files#diff-aaa82c3decf53fb4312de88fbb3cc081da786b72387c9fec7bfb977ad3558b91R589-R593
[ivgi minsc]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAGXD5f3EGyUVBc=bDoNi_nXcKmW7M_-mUZ7LOeyCCab5Nqt69Q@mail.gmail.com/
[minsc]: https://min.sc/
[poinsot alt]: https://mailing-list.bitcoindevs.xyz/bitcoindev/1JkExwyWEPJ9wACzdWqiu5cQ5WVj33ex2XHa1J9Uyew-YF6CLppDrcu3Vogl54JUi1OBExtDnLoQhC6TYDH_73wmoxi1w2CwPoiNn2AcGeo=@protonmail.com/
[moonsettler express]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Gfgs0GeY513WBZ1FueJBVhdl2D-8QD2NqlBaP0RFGErYbHLE-dnFBN_rbxnTwzlolzpjlx0vo9YSgZpC013Lj4SI_WZR0N1iwbUiNze00tA=@protonmail.com/
[obeirne readiness]: https://mailing-list.bitcoindevs.xyz/bitcoindev/45ce340a-e5c9-4ce2-8ddc-5abfda3b1904n@googlegroups.com/
[nick dlc]: https://gist.github.com/jonasnick/e9627f56d04732ca83e94d448d4b5a51#dlcs
[lava 30m]: https://x.com/MarediaShehzan/status/1896593917631680835
[news322 csv-bitvm]: /fr/newsletters/2024/09/27/#validation-cote-client-protegee-csv
[news253 ark 0conf]: /fr/newsletters/2023/05/31/#effectuer-des-transferts-internes
[clark doc]: https://ark-protocol.org/intro/clark/index.html
[oor doc]: https://ark-protocol.org/intro/oor/index.html
[lopp destroy]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CADL_X_cF=UKVa7CitXReMq8nA_4RadCF==kU4YG+0GYN97P6hQ@mail.gmail.com/
[boris timelock]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAFC_Vt54W1RR6GJSSg1tVsLi1=YHCQYiTNLxMj+vypMtTHcUBQ@mail.gmail.com/
[habovstiak gfsig]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CALkkCJY=dv6cZ_HoUNQybF4-byGOjME3Jt2DRr20yZqMmdJUnQ@mail.gmail.com/
[news141 gfsig]: /en/newsletters/2021/03/24/#taproot-improvement-in-post-qc-recovery-at-no-onchain-cost
[schéma de signature de guy fawkes]: https://www.cl.cam.ac.uk/archive/rja14/Papers/fawkes.pdf
[fournier gfsig]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CALkkCJYaLMciqYxNFa6qT6-WCsSD3P9pP7boYs=k0htAdnAR6g@mail.gmail.com/T/#ma2a9878dd4c63b520dc4f15cd51e51d31d323071
[wuille nonpublic]: https://mailing-list.bitcoindevs.xyz/bitcoindev/pXZj0cBHqBVPjkNPKBjiNE1BjPHhvRp-MwPaBsQu-s6RTEL9oBJearqZE33A2yz31LNRNUpZstq_q8YMN1VsCY2vByc9w4QyTOmIRCE3BFM=@wuille.net/T/#mfced9da4df93e56900a8e591d01d3b3abfa706ed
[cruz qramp]: https://mailing-list.bitcoindevs.xyz/bitcoindev/08a544fa-a29b-45c2-8303-8c5bde8598e7n@googlegroups.com/
[news347 bip119]: /en/newsletters/2025/03/28/#bips-1792
[roose ctvcsfs]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/
[poinsot ctvcsfs1]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/4
[10101 shutdown]: https://10101.finance/blog/10101-is-shutting-down
[towns vaults]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/14
[obeirne ctv-vaults]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/23
[sanders bitvm]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/7
[obeirne liquid]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/24
[kanjalkar liquid]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/28
[poelstra liquid]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/32
[news284 lnsym]: /fr/newsletters/2024/01/10/#implementation-de-recherche-ln-symmetry
[sanders versus]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/7
[towns nonrepo]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/14
[roose ctv-ark]: https://codeberg.org/ark-bitcoin/bark/src/branch/ctv
[roose ctv-for-ark]: https://delvingbitcoin.org/t/the-ark-case-for-ctv/1528/
[roose ctv-ark-ln]: https://delvingbitcoin.org/t/the-ark-case-for-ctv/1528/5
[harding ctv-ark-ln]: https://delvingbitcoin.org/t/the-ark-case-for-ctv/1528/8
[news256 ln-jit]: /fr/newsletters/2023/06/21/#les-canaux-jit-just-in-time
[ruffing gfsig]: https://gnusha.org/pi/bitcoindev/1518710367.3550.111.camel@mmci.uni-saarland.de/
[cruz bip]: https://github.com/chucrut/bips/blob/master/bip-xxxxx.md
[towns anticov]: https://gnusha.org/pi/bitcoindev/20220719044458.GA26986@erisian.com.au/
[ccv bip]: https://github.com/bitcoin/bips/pull/1793
[ingala ccv]: https://delvingbitcoin.org/t/op-checkcontractverify-and-its-amount-semantic/1527/
[news319 64byte]: /fr/newsletters/2024/09/06/#attenuation-des-vulnerabilites-des-arbres-de-merkle
[poinsot nsequence]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/79
[provoost bridge]: https://mailing-list.bitcoindevs.xyz/bitcoindev/19f6a854-674a-4e4d-9497-363af306e3a0@app.fastmail.com/
[poinsot cleanup]: https://mailing-list.bitcoindevs.xyz/bitcoindev/uDAujRxk4oWnEGYX9lBD3e0V7a4V4Pd-c4-2QVybSZNcfJj5a6IbO6fCM_xEQEpBvQeOT8eIi1r91iKFIveeLIxfNMzDys77HUcbl7Zne4g=@protonmail.com/
[cleanup bip]: https://github.com/darosior/bips/blob/consensus_cleanup/bip-cc.md
[news312 chilldkg]: /fr/newsletters/2024/07/19/#protocole-de-generation-de-cles-distribue-pour-frost
[fnr secp]: https://mailing-list.bitcoindevs.xyz/bitcoindev/d0044f9c-d974-43ca-9891-64bb60a90f1f@gmail.com/
[secp256k1lab]: https://github.com/secp256k1lab/secp256k1lab
[corallo eltoo]: https://x.com/TheBlueMatt/status/1857119394104500484
[bdk wallet 1.2.0]: https://github.com/bitcoindevkit/bdk/releases/tag/wallet-1.2.0
[ldk v0.1.2]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.2
[news341 pr review]: /fr/newsletters/2025/02/14/#bitcoin-core-pr-review-club