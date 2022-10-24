---
title: 'Bitcoin Optech Newsletter #222'
permalink: /fr/newsletters/2022/10/19/
name: 2022-10-19-newsletter-fr
slug: 2022-10-19-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
La newsletter de cette semaine décrit le bug d'analyse de blocs affectant BTCD
et LND la semaine dernière, résume la discussion sur un changement de fonctionnalité
prévu sur Bitcoin Core lié au replace by fee, décrit la recherche
sur les validity rollups avec Bitcoin, partage une annonce sur une vulnérabilité
dans le projet de BIP pour MuSig2 , examine une proposition visant à réduire
la taille minimale d'une transaction non confirmée que Bitcoin Core relayera,
et établit un lien vers une mise à jour de la proposition BIP324 pour une
version 2 du protocole de transport chiffré pour Bitcoin. Sont également incluses
nos sections régulières avec des résumés des modifications apportées aux services
et aux logiciels clients, des annonces de nouvelles versions et de release candidate,
et des descriptions d'ajout sur les projets d'infrastructure Bitcoin populaires.

## Nouvelles

- **Bug d'analyse de bloc affectant BTCD et LND:** le 9 octobre,
  un [utilisateur][brqgoo] a créé une [transaction][big msig] en utilisant
  [taproot][topic taproot] avec un témoin contenant près d'un millier
  de signatures. Les règles de consensus pour taproot n'imposent aucune
  limite directe à la taille des données des témoins. Il s'agissait d'un
  élément de conception discuté lors du développement de taproot
  (voir la [Newsletter #65][news65 tapscript limits]).

    Peu après la confirmation de grandes transactions, les utilisateurs
    ont commencés à signaler que l'implémentation du nœud complet BTCD et celle
    du réseau Lightning LND ne fournissaient pas les données des blocs les plus
    récents disponibles pour les nœuds complets Bitcoin Core. Pour les nœuds
    BTCD, cela signifiait que les transactions qui avaient été récemment confirmées
    étaient signalées comme étant toujours non confirmées. Pour LND, cela signifiait
    que les nouveaux canaux qui étaient récemment prêts à être utilisés n'étaient
    pas signalés comme étant totalement ouverts.

    Un développeur de BTCD et de LND a corrigé le problème dans le code de BTCD,
    que LND utilise comme une bibliothèque, et a rapidement publié de nouvelles
    versions pour [LND][lnd 0.15.2-beta] (comme mentionné dans [la newsletter]
    [news221 lnd] de la semaine dernière) et [BTCD]. Tous les utilisateurs de
    BTCD et LND doivent effectuer une mise à jour.

    Tant qu'un utilisateur n'aura pas mis à jour son logiciel, il souffrira des
    problèmes d'absence de confirmation décrits ci-dessus et peuvent également être
    vulnérable à plusieurs attaques. Certaines de ces attaques nécessitent l'accès
    à un taux de hachage important (ce qui les rend coûteuses et, espérons-le,
    peu pratiques dans ce cas). D'autres attaques, en particulier celles
    contre les utilisateurs de LND, exigent que l'attaquant risque de perdre une
    partie de ses fonds dans un canal, ce qui est aussi, espérons-le, suffisant dissuasif.
    À nouveau, nous recommandons de mettre à jour et, en outre, nous recommandons que toute
    personne utilisant un logiciel Bitcoin de s'inscrire aux annonces de sécurité de
    l'équipe de développement de ce logiciel.

    Après les divulgations ci-dessus, Loki Verloren a [posté][verloren limits]
    sur la liste de diffusion Bitcoin-Dev pour suggérer que des limites directes soient
    être ajoutées à la taille des témoins de taproot. Greg Sanders a [répondu][sanders limits]
    pour faire remarquer que l'ajout de limites maintenant n'augmenterait pas seulement
    la complexité du code, mais pourrait également conduire à ce que des personnes
    perdent leur argent si elles ont déjà reçu des bitcoins d'un script qui nécessite
    un grand témoin pour les dépenser.

- **Option de remplacement de transaction:** comme indiqué dans les Newsletters
  [#205][news205 rbf] et [#208][news208 rbf], Bitcoin Core a fusionné
  le support d'une option de configuration `mempoolfullrbf` qui utilise par défaut
  le comportement existant de Bitcoin Core qui n'autorise que les [remplacement RBF]
  [topic rbf] des transactions contenant le signal [BIP125][]. Cependant, si un
  utilisateur définit cette nouvelle option sur true, son nœud acceptera et relaiera
  les remplacements pour les transactions qui ne contiennent pas le signal BIP125,
  à condition que les transactions de remplacement respectent toutes les autres
  règles de Bitcoin Core pour les remplacements.

    Dario Sneidermanis a [posté][sne rbf] sur la liste de diffusion Bitcoin-Dev que
    cette nouvelle option peut créer des problèmes pour les services qui acceptent actuellement
    des transactions non confirmées comme définitives. Bien qu'il soit possible depuis des
    années, les utilisateurs peuvent exécuter des logiciels non Bitcoin Core (ou des
    versions éditées de Bitcoin Core) qui permettent le remplacement de transactions *full*[^full-rbf]
    non signalées, rien ne prouve que ces logiciels sont largement utilisés. Sneidermanis pense
    qu'une option facilement accessible dans Bitcoin Core pourrait changer cela en permettant à suffisamment
    d'utilisateurs et de mineurs d'activer le RBF complet et de rendre le remplacement non signalé
    fiable. Un remplacement non signalé plus fiable rendrait également
    plus fiable de voler des services qui acceptent les transactions non confirmées comme définitives, ce qui
    obligerait ces services à modifier leur comportement.

    En plus de la description du problème et de la description détaillée de la manière
    dont les services choisissent d'accepter des transactions non confirmées,
    Sneidermanis a également proposé une approche alternative : supprimer l'option de configuration
    de la prochaine version de Bitcoin Core, mais aussi ajouter du code qui
    activera par défaut le RBF complet à un moment ultérieur. Anthony Towns
    [a publié][towns rbf] plusieurs options à prendre en considération et a ouvert une
    [pull request][bitcoin core #26323] qui implémente une version légèrement modifiée
    de la proposition de Sneidermanis.  Si elle est fusionnée et publiée
    dans son état actuel, le PR de Towns activera par défaut le RBF complet
    à partir du 1er mai 2023.  Les utilisateurs qui s'opposent à la RBF complète pourront
    toujours empêcher leurs nœuds de participer en définissant l'option
    `mempoolfullrbf` à false.

- **Recherche sur les rollups de validité** : John Light a [posté][light ml ru]
  sur la liste de diffusion Bitcoin-Dev un lien vers un [rapport de recherche détaillé][light ru].
  qu'il a préparé sur les validity rollups--un type de [sidechain][topic sidechains] où
  l'état actuel de la sidechain est stocké de manière compacte sur la chaîne principale.
  Un utilisateur de la chaîne latérale peut utiliser l'état stocké sur la chaîne principale
  pour prouver combien de bitcoins de la sidechain il contrôle. En soumettant une transaction
  sur la chaîne principale avec une preuve de validité, ils peuvent retirer les bitcoins
  qu'ils possèdent de la sidechain même si les opérateurs ou les mineurs de la
  chaîne latérale tentent d'empêcher le retrait.

    Les recherches de Light décrivent en profondeur les validity rollups, examinent comment
    leur prise en charge pourrait être ajoutée à Bitcoin, et examine les différentes
    préoccupations liées à leur mise en œuvre.

- **Validité de la sécurité de MuSig2:** Jonas Nick a [posté][nick musig2] sur la
  liste de diffusion Bitcoin-Dev à propos d'une vulnérabilité que lui et plusieurs
  autres personnes ont découvert dans l'algorithme [MuSig2][topic musig]
  tel que documenté dans un [projet de BIP][bips #1372]. En bref, le protocole est vulnérable si
  un attaquant connaît la clé publique d'un utilisateur, une modification de cette clé publique
  pour laquelle l'utilisateur signera (comme avec [BIP32][topic bip32] extended pubkeys)
  et peut manipuler la version de la clé pour laquelle l'utilisateur signera.

    Jonas Nick pense que la vulnérabilité "ne devrait s'appliquer que dans des cas relativement rares".
    et encourage toute personne utilisant (ou prévoyant d'utiliser bientôt MuSig2
    à lui poser des questions, ainsi qu'à ses co-auteurs.
    Le projet de BIP pour MuSig2 devrait être mis à jour prochainement afin d'aborder ce problème.

- **Taille minimale des transactions relayables:** Greg Sanders a [posté][sanders
  min] sur la liste de diffusion Bitcoin-Dev une demande pour que Bitcoin Core puisse
  assouplir une politique ajoutée pour rendre plus difficile l'exploitation de la
  vulnerabilité[CVE-2017-12842][]. Cette vulnérabilité permet à un
  attaquant qui peut obtenir une transaction de 64 octets spécialement conçue pour être confirmée
  dans un bloc, de faire croire à des clients légers qu'une ou plusieurs transactions
  arbitraires différentes ont été confirmées. Par exemple, Bob un utilisateur innocent
  du portefeuille SPV (Simplified Payment Verification), pourrait afficher
  qu'il a reçu un paiement d'un million de BTC avec des dizaines de confirmations même si
  aucun paiement de ce type n'a jamais été confirmé.

    Lorsque la vulnérabilité n'était connue qu'en privé par quelques développeurs,
    une limite a été ajoutée à Bitcoin Core pour empêcher le relais de toute transaction
    de moins de 85 octets (sans compter les témoins), qui est à peu près la plus
    petite taille pouvant être créée à l'aide de modèles de transaction standard.
    Cela obligerait un attaquant à faire miner sa transaction par un logiciel
    non basé sur Bitcoin Core.
    Plus tard, le [consensus cleanup soft fork proposal][topic consensus
    cleanup] a suggéré de résoudre définitivement le problème en interdisant toutes
    transactions de moins de 65 octets d'être incluses dans les nouveaux blocs.

    Sanders suggère d'abaisser la limite de la politique de relais des transactions
    de 85 octets à la limite de 65 octets suggérée dans le nettoyage de consensus, ce qui peut
    permettre une expérimentation et un usage supplémentaire sans changer le
    profil de risque actuel. Sanders a ouvert une [pull request][bitcoin core
    #26265] pour effectuer ce changement. Voir aussi la [Newsletter #99][news99
    min] pour une discussion antérieure liée à cette proposition de changement.

- **Mise à jour BIP324:** Dhruv M a [posté][dhruv 324] sur la liste de
  diffusion Bitcoin-Dev un résumé de plusieurs mises à jour de la proposition
  BIP324 pour un [protocole de transport P2P crypté version 2][topic v2 p2p transport].
  Cela inclut une réécriture du [projet de BIP] [bips #1378] et la
  publication d'une [variété de ressources][bip324.com] pour aider les examinateurs à
  évaluer la proposition, y compris un excellent [guide sur les
  modifications du code][bip324 changes] à travers plusieurs référentiels.

    Comme décrit dans la section *motivation* de l'ébauche du BIP,
    un protocole de transport crypté natif pour les noeuds Bitcoin peut améliorer la vie privée
    lors de l'annonce des transactions, empêcher la falsification des connexions
    (ou du moins rendre plus facile la détection de la falsification), et également rendre la censure des
    connexions P2P et les [attaques d'éclipse][topic eclipse attacks] plus faciles à détecter.

## Changements dans les services et les logiciels clients

*Dans cette rubrique mensuelle, nous mettons en avant les mises à jour intéressantes des portefeuilles et
services Bitcoin.*

- **btcd v0.23.2 publié :**
  btcd v0.23.2 (et [v0.23.1][btcd 0.23.1]) ajoute [addr v2][topic addr v2] et un
  support supplémentaire pour les [PSBT][topic psbt], [taproot][topic taproot],
  et [MuSig2][topic musig] ainsi que d'autres améliorations et corrections.

- **ZEBEDEE annonce des bibliothèques de canaux hébergés :**
  Dans un récent [article de blog][zbd nbd], ZEBEDEE a annoncé un porte-monnaie open source (Open
  Bitcoin Wallet), un plugin Core Lightning (Poncho), un client Lightning (Cliché), ainsi
  qu'une bibliothèque Lightning (Immortan) qui se concentrent sur le support des [canaux hébergés].

- **Cashu est lancé avec le support de Lightning :**
  Le logiciel de monnaie électronique [Cashu][cashu github] est lancé en tant que
  porte-monnaie de démonstration avec un support de réception Lightning.

- **Lancement de l'explorateur d'adresses Spiral :**
  [Spiral][spiral explorer] est un [explorateur][topic block explorers] d'adresses
  publiques open source qui utilise la cryptographie pour assurer la confidentialité
  des utilisateurs qui recherchent des informations sur une adresse.

- **BitGo annonce le support de Lightning :**
  Dans un [article de blog][bitgo lightning], BitGo décrit son service de garde Lightning
  qui exécute des nœuds pour le compte de ses clients et maintient la liquidité des canaux de paiement.

- **Lancement du projet ZeroSync :**
  Le projet [ZeroSync][zerosync github] utilise [Utreexo][topic utreexo] et des preuves STARK pour synchroniser
  un nœud Bitcoin, comme cela se produit dans le téléchargement du bloc initial (IBD).

## Mises à jour et Release candidate

*Nouvelles versions et release candidate pour les principaux projets d'infrastructure Bitcoin.
Veuillez envisager de passer aux nouvelles versions ou d'aider à tester les release candidate.*

- [Bitcoin Core 24.0 RC2][] est une release candidate pour la prochaine version
  de l'implémentation de nœud complet la plus utilisée du réseau.
  Un [guide de test][bcc testing] est disponible.

- [LND 0.15.3-beta][] est une version mineure qui corrige plusieurs bogues.

## Changements principaux dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], et [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #23549][] ajoute le RPC `scanblocks` qui identifie les blocs
  pertinents dans une plage donnée pour un ensemble fourni de
  [descripteurs][topic descriptors]. Cet RPC n'est disponible que sur
  les noeuds qui maintiennent un [filtre de blocs compact][topic compact
  block filters] (`-blockfilterindex=1`).

- [Bitcoin Core #25412][] ajoute un nouveau point de terminaison REST
  `/deploymentinfo` qui contient des informations sur les déploiements de soft fork,
  similaire au RPC existant `getdeploymentinfo`.

- [LND #6956][] permet de configurer la réserve minimale des canaux appliquée
  sur les paiements reçus du partenaire d'un canal. Un noeud n'acceptera pas un
  paiement de son partenaire de canal si cela diminue la quantité de fonds
  du partenaire dans le canal en dessous de la réserve, qui est de 1% par
  défaut avec LND. Cela garantit que le partenaire devra payer au moins
  le montant de la réserve en tant que pénalité s'il ne respecte pas ses engagements.
  L'approbation de ce PR permet d'abaisser ou d'augmenter le montant de la réserve.

- [LND #7004][] met à jour la version de la bibliothèque BTCD utilisée par LND,
  corrigeant la vulnérabilité de sécurité précédemment décrite dans ce
  bulletin d'information.

- [LDK #1625][] commence à suivre les informations concernant la liquidité des
  canaux distants par lesquels le noeud local a tenté d'acheminer des paiements.
  Le nœud local stocke des informations sur la taille des paiements
  qui ont été acheminés avec succès par le nœud distant ou
  qui ont échoué en raison d'une insuffisance apparente de fonds. Cette information,
  ajustée en fonction de leur âge, est utilisée comme données d'entrée
  pour la recherche probabiliste d'un chemin, voir la [Newsletter #163][news163 pr]).

## Notes de bas de page

<!-- TODO:harding is 95% sure the below is correct and will delete this
comment when he gets verification from the person he thinks first used
the "full RBF" term.  -->

[^full-rbf]:
    Le remplacement des transactions a été inclus dans la première version de Bitcoin
    et a fait l'objet de nombreuses discussions au fil des ans. Au cours de cette période,
    plusieurs termes utilisés pour décrire certains de ses aspects ont changés,
    entraînant une confusion potentielle. La plus grande source de confusion
    serait le terme "RBF complet", qui a été utilisé pour deux concepts
    différents :

    - *Le remplacement complet de n'importe quelle **partie** d'une transaction*, par opposition
      à la simple addition d'entrées et de sorties supplémentaires. Pendant une période
      où l'activation de RBF était controversée et avant que l'idée de RBF opt-in,
      une [suggestion][superset rbf] était d'autoriser le remplacement d'une
      transaction à être remplacée uniquement si le remplacement incluait l'ensemble
      des résultats plus des entrées et sorties supplémentaires utilisées pour
      payer les frais et collecter la monnaie. L'obligation de conserver les sorties
      originales garantissait que le remplacement paierait toujours
      le même montant d'argent au destinataire initial. Cette idée, appelée plus tard First
      Seen Safe (FSS) RBF, était un type de remplacement *partiel*.

        En comparaison, le remplacement complet à cette époque signifiait que le remplacement
        pouvait changer complètement tout ce qui concernait la
        transaction originale (à condition qu'elle soit toujours en conflit avec la transaction
        originale en dépensant au moins une des mêmes entrées). C'est
        cet usage de full qui est utilisé dans le titre de [BIP125][],
        "Opt-in Full Replace-by-Fee Signaling".

    - Le remplacement complet de **n'importe quelle** transaction* est différent du remplacement seulement
      des transactions qui acceptent de permettre le remplacement via un signal BIP125. Le RBF
      Opt-in a été proposé comme un compromis entre les personnes qui ne voulaient pas autoriser
      le RBF et celles qui pensaient qu'il était nécessaire ou inévitable. Cependant, à ce jour, seule une
      minorité de transactions opte pour le RBF, ce qui peut être considéré comme une adoption partielle de la
      méthode RBF.

        En comparaison, l'adoption *complète* de RBF peut être permise en autorisant
        toute transaction non confirmée à être remplacée. C'est cette utilisation de
        complet qui est actuellement discutée dans l'option de configuration `mempoolfullrbf`
        de Bitcoin Core.

{% include references.md %}
{% include linkers/issues.md v=2 issues="23549,25412,25667,2448,6956,6972,7004,1625,26323,1372,1378,26265" %}
[bitcoin core 24.0 rc2]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/24.0-Release-Candidate-Testing-Guide
[superset rbf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2013-March/002240.html
[brqgoo]: https://twitter.com/brqgoo/status/1579216353780957185
[big msig]: https://blockstream.info/tx/7393096d97bfee8660f4100ffd61874d62f9a65de9fb6acf740c4c386990ef73?expand
[news65 tapscript limits]: /en/newsletters/2019/09/25/#tapscript-resource-limits
[lnd 0.15.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.2-beta
[news221 lnd]: /en/newsletters/2022/10/12/#lnd-v0-15-2-beta
[btcd 0.23.2]: https://github.com/btcsuite/btcd/releases/tag/v0.23.2
[verloren limits]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/020993.html
[sanders limits]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/020996.html
[news205 rbf]: /en/newsletters/2022/06/22/#full-replace-by-fee
[news208 rbf]: /en/newsletters/2022/07/13/#bitcoin-core-25353
[sne rbf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/020980.html
[towns rbf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021017.html
[light ml ru]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/020998.html
[light ru]: https://bitcoinrollups.org/
[nick musig2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021000.html
[sanders min]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/020995.html
[cve-2017-12842]: /en/topics/cve/#CVE-2017-12842
[news99 min]: /en/newsletters/2020/05/27/#minimum-transaction-size-discussion
[dhruv 324]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/020985.html
[bip324.com]: https://bip324.com
[bip324 changes]: https://bip324.com/sections/code-review/
[news163 pr]: /en/newsletters/2021/08/25/#zero-base-fee-ln-discussion
[lnd 0.15.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.3-beta
[btcd 0.23.1]: https://github.com/btcsuite/btcd/releases/tag/v0.23.1
[zbd nbd]: https://blog.zebedee.io/announcing-nbd/
[hosted channels]: https://fanismichalakis.fr/posts/what-are-hosted-channels/
[cashu github]: https://github.com/callebtc/cashu
[spiral explorer]: https://btc.usespiral.com/
[bitgo lightning]: https://blog.bitgo.com/bitgo-unveils-custodial-lightning-898554d3b749
[zerosync github]: https://github.com/zerosync/zerosync
