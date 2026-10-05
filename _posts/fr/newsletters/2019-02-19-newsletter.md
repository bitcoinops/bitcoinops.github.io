---
title: 'Bulletin Hebdomadaire Bitcoin Optech #34'
permalink: /fr/newsletters/2019/02/19/
name: 2019-02-19-newsletter-fr
slug: 2019-02-19-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume une discussion sur le marquage des sorties pour BIP118 SIGHASH_NOINPUT_UNSAFE, annonce des fusions qui
permettront d’associer le portefeuille intégré de Bitcoin Core en mode observation seule à un portefeuille matériel, et décrit l’achèvement
du gel des fonctionnalités pour la prochaine version de Bitcoin Core. Sont également résumés de nombreux changements de code et de
documentation dans des projets populaires d’infrastructure Bitcoin.

## Action items

Aucun cette semaine.

## Nouvelles

- **Discussion sur le marquage des sorties pour activer des fonctionnalités restreintes lors de la dépense :** La proposition [BIP118][]
  SIGHASH_NOINPUT_UNSAFE (noinput) permet à la personne générant une signature qui autorise la dépense d’un UTXO d’autoriser facultativement
  la réutilisation ("rejeu") de cette signature pour dépenser d’autres UTXOs envoyés à la même clé publique. Cela permet de nouvelles
  fonctionnalités lorsqu’elle est utilisée avec des protocoles tels que les canaux de paiement qui contiennent tous les mêmes clés publiques
  (voir la couche proposée [Eltoo][] pour LN), mais cela rend également possibles des *attaques par rejeu* qui peuvent entraîner une perte
  d’argent lorsque les utilisateurs réutilisent des adresses. Par exemple : Alice utilise une pièce qu’elle a précédemment reçue sur l’une
  de ses adresses et signe une dépense vers Bob en utilisant SIGHASH_NOINPUT_UNSAFE. Plus tard, quelqu’un d’autre envoie de l’argent à cette
  même adresse d’Alice avec l’intention de lui envoyer davantage d’argent. Bob (ou n’importe qui d’autre) peut alors maintenant envoyer
  cette sortie à Bob en rejouant l’ancienne signature d’Alice.

  Une façon d’aider à éviter de tels accidents est simplement d’ajouter "UNSAFE" au nom de la fonctionnalité, afin d’encourager les
  développeurs à se renseigner sur les nuances du protocole avant de l’implémenter dans leurs outils. Cependant, certains développeurs ont
  cherché d’autres moyens d’éviter les problèmes. En décembre, Johnson Lau a [proposé][lau output tagging] de n’autoriser l’utilisation de
  noinput que si la sortie dépensée avait été spécialement marquée lors de sa création pour permettre l’utilisation de noinput. Cela
  n’autoriserait l’utilisation de la fonctionnalité que lorsque le dépensier et le destinataire sont tous deux d’accord (comme dans le cas
  d’un canal de paiement), empêchant que des erreurs de communication ou des malentendus ne se traduisent par une perte de fonds.

  La reprise de la discussion [la semaine dernière][nick output tagging] et cette semaine a vu une analyse de l’impact que cela aurait sur
  les protocoles proposés de couche deux tels qu’Eltoo et les [Channel Factories][]. Bien que le marquage augmente la complexité, l’opinion
  générale semble être qu’il n’augmente pas fondamentalement le coût et ne réduit pas l’efficacité des propositions décrites, bien qu’il
  puisse les rendre un peu moins privées.

- **Support préliminaire des portefeuilles matériels dans Bitcoin Core :** après des mois d’améliorations progressives, cette semaine a vu
  la fusion du dernier ensemble de PRs nécessaires pour que la branche de développement master de Bitcoin Core prenne en charge la réception
  et l’envoi de transactions en conjonction avec un portefeuille matériel via l’outil [Hardware Wallet Interaction][HWI] (HWI). HWI fait
  partie du projet Bitcoin Core, mais n’est pas encore distribué avec le logiciel Bitcoin Core et n’est actuellement accessible que depuis
  la ligne de commande. Il fournit une base solide sur laquelle construire des outils capables de faciliter l’utilisation d’un magasin de
  clés externe avec le portefeuille natif de Bitcoin Core et un nœud de vérification complet. Notez également qu’il est déjà possible de
  connecter un portefeuille matériel à un portefeuille Electrum connecté à votre nœud complet en utilisant [Electrum Personal Server][].

  Les organisations utilisant des techniques de sécurité avancées telles que des modules matériels de sécurité (HSMs), des portefeuilles à
  froid et du multisig peuvent vouloir étudier la conception de HWI et la manière dont il interagit avec Bitcoin Core en utilisant les
  [descripteurs de script de sortie][descriptor] et les PSBTs [BIP174][]. Ces encodages de nouvelle génération des données de clé et de
  transaction (et des métadonnées), ainsi que d’autres avancées comme le langage de politique [miniscript][], rendent plus facile que jamais
  la construction et l’exploitation de solutions sécurisées de stockage de bitcoins interagissant avec un nœud complet pour la vérification.

- **Semaine de gel de Bitcoin Core :** comme [prévu][Bitcoin Core #14438], le projet a cessé d’accepter des fonctionnalités pour la
  prochaine version majeure 0.18. Comme cela arrive souvent, cela a été précédé d’une semaine environ de revue active de dernière minute et
  de fusion de nouvelles fonctionnalités, ce qui se reflète dans la longue liste de changements de la section *changements notables*
  ci-dessous dans ce bulletin. Les deux prochaines semaines se concentreront sur les tests des développeurs et les corrections de bugs,
  suivis par l’émission de Release Candidates (RCs) pour les tests utilisateurs. Le cycle de RC pour une version majeure dure généralement
  de deux à quatre semaines avant une version finale.

  Dans le même ordre d’idées, le projet préfère fusionner les nouvelles fonctionnalités majeures tôt dans un nouveau cycle de développement
  afin qu’elles bénéficient d’autant de tests supplémentaires par les développeurs que possible. Après la création de la branche 0.18 autour
  du 1er mars, il serait conseillé à quiconque souhaite voir une fonctionnalité dans 0.19 (sortie estimée en octobre 2019) soit d’essayer
  d’ouvrir une PR pour celle-ci dans les deux prochains mois, soit d’aider à relire une PR existante pour cette fonctionnalité. Parmi les
  PRs existantes notables qui ont besoin de davantage de relecture ou de développement figurent le support de BIP156 Dandelion pour le
  [relais de transactions améliorant la confidentialité][Bitcoin Core #13947], BIP151 [connexions P2P chiffrées][Bitcoin Core #14032],
  BIP157/158 [filtres de blocs compacts][Bitcoin Core #14121], les [builds reproductibles][Bitcoin Core #15277] simplifiés utilisant GNU
  Guix, un support amélioré pour les [signataires externes][Bitcoin Core #14912] (par ex. les portefeuilles matériels), la [séparation du
  portefeuille du nœud][Bitcoin Core
  #10973], et l’autorisation du [RBF sur n’importe quelle transaction][Bitcoin Core #10823]
  après qu’elle ait été dans la mempool pendant plus de quelques heures.

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [LND][lnd repo], [C-Lightning][c-lightning repo],
[Eclair][eclair repo], [libsecp256k1][libsecp256k1 repo], et [Bitcoin Improvement Proposals (BIPs)][bips repo].*

- [Bitcoin Core #15368][] ajoute le support des sommes de contrôle aux descripteurs de script de sortie. Les [descripteurs][descriptor] sont
  utilisés pour surveiller les paiements reçus et générer de nouvelles adresses, donc les sommes de contrôle améliorent la sécurité en
  empêchant les erreurs de copie qui pourraient faire disparaître de l’argent ou l’envoyer vers une adresse impossible à dépenser. Un
  caractère `#` est ajouté à la grammaire des descripteurs pour séparer le descripteur de sa somme de contrôle de 8 caractères, par ex.
  `wpkh(031234...cdef)#012345678` (voir la note de bas de page[^fn-example] pour un exemple étendu). Toutes les RPCs de Bitcoin Core qui
  renvoient des descripteurs incluent maintenant une somme de contrôle. Les RPCs qui ne présentent pas un risque particulier de perte
  d’argent n’exigent pas que l’entrée inclue la somme de contrôle, mais les RPCs critiques pour la sécurité, comme `deriveaddress` et
  `importmulti`, sont mises à jour pour exiger des utilisateurs qu’ils fournissent la somme de contrôle. Enfin, une nouvelle RPC
  `getdescriptorinfo` est ajoutée ; elle accepte un descripteur et en renvoie une forme normalisée contenant une somme de contrôle ainsi que
  d’autres informations à son sujet.

- [Bitcoin Core #13932][] ajoute trois nouvelles RPCs pour gérer les PSBTs : `utxoupdatepsbt` recherche dans l’ensemble des Unspent
  Transaction Outputs (UTXOs) pour trouver les sorties dépensées par la transaction partielle. Si l’une de ces sorties a payé une adresse
  segwit native, elle ajoute les détails de cette sortie à un champ du PSBT. Ces informations sont requises par les signataires de PSBT car
  le format de signature [BIP143][] pour segwit requiert la signature d’informations qui ne sont pas directement contenues dans la
  transaction de dépense ni dérivables de la clé privée du signataire, comme la valeur de la sortie dépensée. `joinpsbts` combine les
  entrées de plusieurs PSBTs en un seul PSBT. `analyzepsbt` examine un PSBT et affiche l’étape suivante que l’utilisateur doit entreprendre
  pour le finaliser.

- [Bitcoin Core #14075][] ajoute un paramètre `keypool` à la RPC `importmulti` qui permet d’ajouter les clés publiques importées au
  keypool---la liste des clés utilisées pour créer de nouvelles adresses de réception et de monnaie rendue. Cette option n’est disponible
  que pour les portefeuilles dont les clés privées sont désactivées (voir [PR#9662][Bitcoin Core #9662] décrite dans le [Bulletin #5][]).
  Cela permet à un utilisateur de portefeuille à froid ou de portefeuille matériel d’importer ses clés publiques dans un portefeuille
  Bitcoin Core en observation seule puis de recevoir des paiements normalement. Lors d’une tentative de dépense des paiements, le
  portefeuille peut générer une transaction non signée---incluant une adresse de monnaie rendue---en utilisant un PSBT [BIP174][] et
  l’envoyer à un outil tel que [HWI][] qui se connectera au portefeuille externe pour revue et signature.

- [Bitcoin Core #14021][] modifie la RPC `importmulti` pour stocker toute métadonnée d’e de clé incluse comme partie d’un [descripteur
  de script de sortie][descriptor]. Les [informations d’origine de clé][key origin] spécifient quelle graine HD et quel chemin de dérivation ont été
  utilisés pour générer une clé publique. Lorsque des métadonnées d’origine de clé sont disponibles dans le portefeuille, tous les PSBTs
  générés par le portefeuille incluront ces données afin de permettre aux portefeuilles matériels ou à d’autres programmes de localiser les
  clés privées nécessaires pour signer le PSBT. Voir la note de bas de page[^fn-example] pour un exemple d’informations d’origine de clé
  dans un descripteur.

- [Bitcoin Core #14481][] met à jour les RPCs `listunspent`, `signrawtransactionwithkey`, et `signrawtransactionwithwallet` afin qu’elles
  contiennent chacune un nouveau champ `witnessScript`. La première RPC renvoie le witnessScript et les deux autres peuvent l’accepter en
  entrée. Auparavant, Bitcoin Core surchargeait les champs P2SH `redeemScript` existants pour les witnessScripts segwit, mais cela peut être
  particulièrement déroutant dans le cas du segwit encapsulé dans P2SH. Ce changement clarifie où chaque donnée doit aller.

- [Bitcoin Core #15063][] permet au portefeuille de revenir à l’analyse [BIP21][] d’un URI `bitcoin:` si le support [BIP70][] a été
  désactivé. Comme spécifié par [BIP72][], l’URI `bitcoin:` a été étendu d’une manière rétrocompatible pour contenir un paramètre
  supplémentaire `r=` contenant l’URL BIP70. Cela a été fait pour permettre aux services utilisant déjà des URIs BIP21 de passer au support
  de BIP70 sans perdre leurs utilisateurs existants. Cependant, maintenant que de nombreux portefeuilles et services abandonnent leur
  support de BIP70, le même mécanisme peut être utilisé en sens inverse afin que les services qui supportaient auparavant BIP70 puissent
  permettre à leurs utilisateurs non-BIP70 de continuer à obtenir les détails de paiement simplement en cliquant sur un lien `bitcoin:`.

- [Bitcoin Core #15153][] ajoute un menu GUI pour ouvrir un portefeuille et [#15195][Bitcoin Core #15195] ajoute un menu pour fermer un
  portefeuille. Cela rend beaucoup plus facile l’utilisation du mode multiwallet de Bitcoin Core depuis la GUI, bien qu’il ne soit pas
  encore possible de créer un portefeuille depuis la GUI sans utiliser la console de débogage (cette tâche à faire est le dernier élément de
  la [liste de contrôle du portefeuille dynamique][Bitcoin Core #13059]).

- [Eclair #862][] prend désormais en charge les demandes de paiement (factures) entièrement en majuscules ainsi qu’entièrement en
  minuscules. La casse mixte n’est pas autorisée, conformément à la spécification [BOLT11][] (qui base le format de facture sur [BIP173][]
  bech32).

- [BIPs #760][] met à jour les filtres de blocs compacts [BIP158][] pour ajouter des vecteurs de test supplémentaires pour le traitement
  correct des sorties de transport de données (sorties `OP_RETURN`).

## Footnotes

[^fn-example]: Un exemple actuel du format de descripteur avec informations d’origine de clé et somme de contrôle détectant les erreurs :

    ```
    $ bitcoin-cli getaddressinfo bc1qsksdpqqmsyk9654puz259y0r84afzkyqdfspvc | jq .desc
    "wpkh([f6bb4c63/0'/0'/21']034ed70f273611a3f21b205c9151836d6fa9051f74f6e6bbff67238c9ebc7d04f6)#mtdep7g7"
    ```

    En l’analysant, nous voyons ce qui suit :

    - L’adresse est un Witness Public Key Hash `wpkh()`, autrement dit un P2WPKH. Les descripteurs peuvent décrire succinctement tous les
      usages communs de P2PKH, P2SH, P2WPKH, P2WSH, et du segwit imbriqué.

    - L’[origine de clé][key origin] est décrite entre les crochets `[...]`.

        - `f6bb4c63` est une empreinte qui identifie la clé à la racine du chemin fourni. L’empreinte est constituée des 32 premiers bits de
          son hachage `ripemd(sha256())` tel que [défini par BIP32][bip32 keyid]. Cela permet aux outils, tels que ceux utilisés avec les
          PSBTs, de travailler facilement avec des scripts multisig et d’autres cas où vous avez plusieurs dispositifs de signature
          utilisant différentes clés.

        - `/0'/0'/21'` est le chemin de clé HD, correspondant à `m/0'/0'/21'` dans la notation standard [BIP32][]. Cela permet à un
          portefeuille qui n’a pas toutes ses clés publiques pré-calculées de savoir quelle clé privée il doit générer afin de produire la
          signature. (Bitcoin Core pré-calcule ses clés publiques et n’a donc généralement pas besoin de cette information lorsqu’il est
          utilisé comme portefeuille à froid---mais les portefeuilles matériels avec un stockage minimal et une vitesse de calcul limitée
          ont besoin des informations de chemin HD pour fonctionner efficacement.)

    - La clé publique réelle utilisée pour générer le hash de clé P2WPKH est `034ed7...04f6`

    - Une somme de contrôle suivant un `#` protège la chaîne du descripteur contre les fautes de frappe lors de l’importation, `mtdep7g7`

{% include references.md %}
{% include linkers/issues.md issues="14438,13947,14032,14121,15277,14912,10973,10823,15368,13932,14075,9662,14021,14481,15063,15153,15195,13059,862,760" %}
[bip32 keyid]: https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#key-identifiers
[eltoo]: https://blockstream.com/eltoo.pdf
[lau output tagging]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-December/016549.html
[nick output tagging]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-February/016667.html
[channel factories]: https://www.tik.ee.ethz.ch/file/a20a865ce40d40c8f942cf206a7cba96/Scalable_Funding_Of_Blockchain_Micropayment_Networks.pdf
[electrum personal server]: https://github.com/chris-belcher/electrum-personal-server
[key origin]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md#key-origin-identification
[bulletin #5]: /fr/newsletters/2018/07/24/#bitcoin-core-9662
[hwi]: https://github.com/bitcoin-core/HWI
[descriptor]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
[output script descriptors]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
[miniscript]: /en/topics/miniscript/
