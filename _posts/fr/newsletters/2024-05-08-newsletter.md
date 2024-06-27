---
title: 'Bulletin Hebdomadaire Bitcoin Optech #301'
permalink: /fr/newsletters/2024/05/08/
name: 2024-05-08-newsletter-fr
slug: 2024-05-08-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit une idée pour sécuriser les transactions avec des signatures
Lamport sans nécessiter de changements de consensus. Sont
également incluses nos sections habituelles avec le résumé d'une réunion du Bitcoin Core PR Review Club,
des annonces de mises à jour et versions candidates, ainsi que les changements
apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Signatures Lamport appliquées par consensus en plus des signatures ECDSA :**
  Ethan Heilman a [posté][heilman lamport] sur la liste de diffusion Bitcoin-Dev une méthode
  permettant d'exiger qu'une transaction soit signée par une [signature Lamport][] pour être valide.
  Cela peut rendre les dépenses de sorties P2SH et P2WSH [résistantes aux attaques quantiques][topic quantum
  resistance] et, [selon][poelstra lamport1] Andrew Poelstra, cela signifie "que les limites de taille
  sont désormais la seule raison pour laquelle Bitcoin n'a pas de covenants." Nous résumerons le
  protocole ci-dessous, mais pour garder notre description simple et claire, nous omettrons plusieurs
  avertissements de sécurité, donc veuillez ne rien mettre en œuvre en vous basant uniquement sur ce résumé.

  Les clés publiques Lamport se composent de deux listes de digests de hachage. Les signatures Lamport sont constituées
  des pré-images des hachages sélectionnés. Un programme partagé entre le signataire
  et le validateur interprète quelles préimages sont révélées comme instructions. Par exemple, Bob
  veut vérifier qu'Alice a signé un nombre entre 0 et 31 (en binaire, 00000 à 11111). Alice crée une
  clé privée Lamport à partir de deux listes de nombres aléatoires :

  ```text
  private_zeroes = [random(), random(), random(), random(), random()]
  private_ones   = [random(), random(), random(), random(), random()]
  ```

  Elle hache chacun de ces nombres privés pour créer sa clé publique Lamport :

  ```text
  public_zeroes = [hash(private_zeroes[0]), ..., hash(private_zeroes[4])]
  public_ones   = [hash(private_ones[0]), ..., hash(private_ones[4])]
  ```

  Elle donne à Bob sa clé publique. Plus tard, elle veut lui communiquer de manière vérifiable le
  nombre 21. Elle envoie les préimages suivantes :

  ```text
  private_ones[0]
  private_zeroes[1]
  private_ones[2]
  private_zeroes[3]
  private_ones[4]
  ```

  En binaire, c'est 10101. Bob vérifie que chacune des préimages correspond aux clés publiques qu'il a
  précédemment reçues, lui assurant que seule Alice avec sa connaissance des préimages aurait pu
  générer le message "21".

  Pour les signatures ECDSA, Bitcoin utilise la [norme d'encodage DER][der encoding], qui omet les
  octets zéro (0x00) initiaux des deux composants de la signature. Pour des valeurs aléatoires, un
  octet 0x00 se produira 1/256ème du temps, donc les signatures Bitcoin varient naturellement en
  taille. Cette variation est exacerbée par l'octet initial pour les valeurs R étant un 0x00 la moitié
  du temps (voir [low-r grinding][topic low-r grinding]) mais, en théorie,
  la variation peut être réduite à une transaction étant un octet plus petite 1/256ème du temps.

  Même si un ordinateur quantique rapide permet à un attaquant de créer des signatures sans
  connaissance préalable d'une clé privée, les signatures ECDSA encodées en DER varieront toujours en
  longueur et devront toujours s'engager sur les transactions qui les contiennent, et cette
  transaction devra toujours inclure toutes les données supplémentaires nécessaires pour la rendre
  valide, telles que les préimages de hachage.

  Cela permet au script de rachat P2SH de contenir une vérification de signature ECDSA qui s'engage
  sur la transaction et une signature Lamport qui s'engage sur la taille réelle de la signature ECDSA.
  Par exemple :

  ```text
  OP_DUP <pubkey> OP_CHECKSIGVERIFY OP_SIZE <size> OP_EQUAL
  OP_IF
    # Nous savons maintenant que la taille est égale à <size> octets
    OP_SHA256 <digest_x> OP_CHECKEQUALVERIFY
  OP_ELSE
    # Nous savons maintenant que la taille est supérieure ou inférieure à <size> octets
    OP_SHA256 <digest_y> OP_CHECKEQUALVERIFY
  OP_ENDIF
  ```

  Pour satisfaire ce fragment de script, l'émetteur qui effectue la dépense fournit une signature ECDSA. La signature est
  dupliquée et validée ; le script échoue si ce n'est pas une signature valide. Dans un monde
  post-quantique, un attaquant pourrait réussir ce test, permettant la validation de continuer. La
  taille de la signature dupliquée est mesurée. Si elle est égale à `<size>` octets, l'émetteur doit
  révéler la préimage pour `<digest_x>`. Cette `<size>` peut être réglée sur un octet de moins que le
  cas commun, ce qui se produit naturellement une fois tous les 256 signatures. Sinon, dans le cas
  commun ou avec une signature gonflée en taille, l'émetteur doit révéler la préimage pour
  `<digest_y>`. Si une préimage valide pour la taille de signature réelle n'est pas révélée, le script
  échoue.

  Maintenant, même si ECDSA est complètement cassé, un attaquant ne peut pas dépenser les bitcoins à
  moins qu'il ne connaisse également la clé privée Lamport. En soi, cela n'est pas très excitant :
  P2SH et P2WSH [ont déjà][news141 key hiding] cette propriété fondamentale lorsque leurs préimages de
  script sont gardées secrètes. Cependant, après la publication de la signature Lamport, un attaquant
  qui souhaite la réutiliser avec une signature ECDSA falsifiée devra s'assurer que la signature ECDSA
  a la même longueur que la signature ECDSA originale. Cela peut exiger de l'attaquant de broyer la
  signature, effectuant des opérations supplémentaires qu'un utilisateur honnête n'aurait pas besoin
  de faire.

  La quantité de broyage qu'un attaquant devrait effectuer peut être augmentée exponentiellement en
  incluant des paires supplémentaires de signatures ECDSA et Lamport. Malheureusement, parce que les
  signatures ECDSA varient naturellement en taille d'octet seulement une fois sur 256, la manière
  simple de faire cela nécessiterait un très grand nombre de signatures à inclure pour obtenir une
  sécurité pratique. Heilman [décrit][heilman lamport2] un mécanisme beaucoup plus efficace. Ce
  mécanisme dépasse toujours les limites de consensus pour P2SH <!-- taille de script de rachat de 520
  octets --> mais nous pensons qu'il pourrait juste fonctionner avec les limites supérieures de P2WSH <!--
  taille maximale de script de 10 000 octets -->.

  De plus, un attaquant individuel avec un ordinateur quantique rapide ou un
  ordinateur classique suffisamment puissant pourrait découvrir un nonce ECDSA court qui lui
  permettrait de voler facilement à quiconque n'aurait pas anticipé un nonce aussi court. La taille
  minimale d'un nonce est connue, donc l'attaque est évitable---cependant, la forme privée de ce nonce
  n'est pas connue, donc toute personne essayant d'éviter cette attaque serait incapable de dépenser
  ses propres bitcoins jusqu'à ce qu'un ordinateur quantique rapide soit inventé.

  La vérification de signature Lamport est pratiquement similaire à l'opcode proposé
  [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack]. Dans les deux cas, les données à vérifier, une
  clé publique et une signature sont placées sur la pile et une opération ne réussit que si la
  signature correspond à la clé publique et s'engage sur les données sur la pile. Andrew Poelstra
  [a décrit][poelstra lamport2] comment cela peut être combiné avec des opérations de style [BitVM][topic
  acc] pour créer un [covenant][topic covenants], bien qu'il avertisse que cela violerait presque
  certainement au moins une limite de taille de consensus.

## Bitcoin Core PR Review Club

*Dans cette section mensuelle, nous résumons une récente réunion du
[Bitcoin Core PR Review Club][] en soulignant certaines des questions
et réponses importantes. Cliquez sur une question ci-dessous pour voir
un résumé de la réponse de la réunion.*

[Index TxOrphanage par wtxid, permettre des entrées avec le même txid][review club 30000] est un PR
de Gloria Zhao (GitHub glozow) qui permet à plusieurs transactions avec le même `txid` d'exister
dans `TxOrphanage` en même temps en les indexant sur `wtxid` au lieu de `txid`.

Ce PR rend l'[acceptation de paquet][topic package relay] opportuniste 1-parent-1-enfant (1p1c)
introduite dans [Bitcoin Core #28970][] plus robuste.

{% include functions/details-list.md
  q0="Pourquoi voudrions-nous permettre l'existence simultanée de multiples transactions avec le même txid dans le TxOrphanage ?
      Quel type de situation cela prévient-il ?"
  a0="Par définition, les données de témoin des transactions orphelines ne peuvent pas être validées car la transaction parente est
      inconnue. Lorsque plusieurs transactions (avec différents wtxids) ayant le même txid sont reçues, il est donc impossible
      de savoir quelle version est la correcte. En les autorisant à exister en parallèle dans le TxOrphanage, on empêche un
      attaquant d'envoyer une version malfaisante incorrecte qui empêcherait l'acceptation ultérieure de la version correcte."
  a0link="https://bitcoincore.reviews/30000#l-11"

  q1="Quels sont quelques exemples d'orphelins avec le même txid mais des témoins différents ?"
  a1="Une transaction avec le même txid mais des témoins différents peut avoir une signature invalide (et donc être invalide)
      ou un témoin plus grand (mais avec les mêmes frais et donc un taux de frais inférieur)."
  a1link="https://bitcoincore.reviews/30000#l-67"

  q2="Considérons les effets de ne permettre qu'une seule entrée par txid. Que se passe-t-il si un pair malveillant nous envoie
      une version mutée de la transaction orpheline, où le parent n'est pas à faible taux de frais ? Que doit-il se passer pour
      que nous finissions par accepter cet enfant dans le mempool ? (Il y a plusieurs réponses)"
  a2="Lorsqu'un enfant muté se trouve dans l'orphelinat et qu'un parent valide non à faible taux de frais est reçu, le parent
      sera accepté dans le mempool, et l'enfant muté invalidé et retiré de l'orphelinat."
  a2link="https://bitcoincore.reviews/30000#l-52"

  q3="Considérons les effets si nous avons un package 1-parent-1-enfant (1p1c) (où le parent est à faible taux de frais et doit
      être soumis avec son enfant). Que doit-il se passer pour que nous finissions par accepter le package parent+enfant correct
      dans le mempool ?"
  a3="Étant donné que le parent est à faible taux de frais, il ne sera pas accepté dans le mempool par lui-même. Cependant,
      depuis [Bitcoin Core #28970][], il peut être accepté de manière opportuniste comme un package 1p1c si l'enfant est dans
      l'orphelinat. Si l'enfant orphelin est muté, le parent est rejeté du mempool, et l'orphelin retiré de l'orphelinat."
  a3link="https://bitcoincore.reviews/30000#l-60"

  q4="Au lieu de permettre plusieurs transactions avec le même txid (où nous gaspillons évidemment de l'espace sur une version
      que nous n'accepterons pas), devrions-nous permettre à une transaction de remplacer une entrée existante dans le TxOrphanage ?
      Quelles seraient les conditions de remplacement ?"
  a4="Il semble qu'il n'y ait pas de bon critère pour juger si une transaction devrait être autorisée à remplacer une existante.
      Une piste potentielle à explorer est de remplacer les transactions dupliquées provenant du même pair uniquement."
  a4link="https://bitcoincore.reviews/30000#l-80"
%}

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets
d'infrastructure Bitcoin. Veuillez envisager de passer aux nouvelles
versions ou d'aider à tester les versions candidates.*

- [Libsecp256k1 v0.5.0][] est une version de cette bibliothèque pour effectuer des opérations
  cryptographiques liées à Bitcoin. Elle accélère la génération de clés et la signature (voir [le
  bulletin de la semaine dernière][news300 secp]) et réduit la taille compilée "ce qui, nous
  l'espérons, bénéficiera particulièrement aux utilisateurs embarqués." Elle ajoute également une
  fonction pour trier les clés publiques.

- [LND v0.18.0-beta.rc1][] est un candidat à la version pour la prochaine version majeure de ce nœud
  LN populaire.

## Changements notables dans le code et la documentation

_Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core
lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust
Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Propositions
d'Amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Inquisition
Bitcoin][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #28970][] et [#30012][bitcoin core #30012] ajoutent le support
  pour une forme limitée de [relais de paquets][topic package relay] un-parent-un-enfant (1p1c)
  qui ne nécessite aucun changement au protocole P2P. Imaginez qu'Alice ait une
  transaction parente en dessous des paramètres de filtre de frais [BIP133][] de l'un de ses pairs, ce
  qui la décourage de la relayer sachant qu'aucun de ses pairs ne l'acceptera. Elle a également une
  transaction enfant qui paie un taux de frais suffisant avec son parent pour que tous les deux soient
  au-dessus du filtre de frais. Alice et son pair effectuent le processus suivant :

  - Alice relaie la transaction enfant à son pair.

  - Son pair réalise qu'il n'a pas la transaction parente, donc il place la transaction dans son _pool
    d'orphelins_. Toutes les versions de Bitcoin Core depuis plus d'une décennie ont un pool d'orphelins
    où elles stockent temporairement un nombre limité de transactions qui ont été reçues avant leurs
    parents. Cela compense le fait que, sur un réseau P2P, les transactions peuvent parfois
    naturellement être reçues dans le désordre.

  - Quelques instants plus tard, Alice relaie la transaction parente à son pair.

  - Avant la fusion de ce PR, le pair aurait remarqué que le taux de frais du parent était trop bas et
    aurait refusé de l'accepter ; maintenant qu'il avait évalué la transaction parente, il aurait
   également retiré la transaction enfant du pool d'orphelins. Après ce PR, le pair remarque qu'il a un
   enfant pour le parent dans son pool d'orphelins et évalue le taux de frais agrégé des deux
   transactions ensemble, les autorisant tous les deux dans le mempool si ce taux de frais est
   au-dessus de son plancher (et si elles sont toutes deux par ailleurs acceptables selon la politique
   locale du nœud).

  Il est connu que ce mécanisme peut être contourné par un attaquant. Le pool d'orphelins de Bitcoin
  Core est un tampon circulaire qui peut être ajouté par tous ses pairs, donc un attaquant qui veut
  empêcher ce type de relais de paquets peut spammer les pairs avec de nombreuses transactions
  orphelines, potentiellement conduisant à l'éviction d'une transaction enfant payante avant que son
  parent ne soit reçu. Un [follow-up PR][bitcoin core #27742] peut donner à chaque pair un accès
  exclusif à une partie du pool d'orphelins pour éliminer cette préoccupation. Voir aussi la section
  _Bitcoin PR Review Club_ de ce bulletin pour un autre PR lié.
  Des améliorations supplémentaires nécessitant des changements au protocole P2P sont décrites dans
  [BIP331][].

- [Bitcoin Core #28016][] commence à attendre que tous les nœud seed (nœuds d'archive) soient interrogés avant
  de sonder les seeds DNS. Les utilisateurs peuvent configurer à la fois des nœuds seed et
  des seeds DNS. Un nœud seed est un nœud complet Bitcoin régulier ; Bitcoin Core peut ouvrir
  une connexion TCP avec le nœud, demander une liste d'adresses pour des pairs potentiels, et fermer
  la connexion. Une seed DNS retourne des adresses IP pour des pairs potentiels via DNS, permettant
  à ces informations de voyager et d'être mises en cache à travers le réseau DNS de sorte que le
  propriétaire du serveur de seeds DNS n'apprenne pas l'adresse IP du client demandant
  l'information. Par défaut, Bitcoin Core tente de se connecter à des pairs dont il a déjà appris les
  adresses IP ; si aucune de ces connexions n'est réussie, il interroge les seeds DNS ; si aucune
  des seeds DNS n'est accessible, il contacte un ensemble de nœuds seed codés en dur. Les
  utilisateurs peuvent éventuellement fournir leur propre liste de nœuds seed à contacter.
  Avant cette PR, si un utilisateur configurait le sondage des nœuds seed et conservait la
  configuration par défaut pour utiliser également les DNS seeds, ils seraient tous deux contactés en
  parallèle et le plus rapide dominerait les adresses des pairs que le nœud essaierait. Étant donné le
  faible surcoût du DNS et le fait que les résultats pourraient déjà être mis en cache par un serveur
  physiquement proche de l'utilisateur, le DNS gagnerait généralement. Après cette PR, les nœuds
  seed sont privilégiés, en raison de la croyance qu'un utilisateur qui définit une option
  `seednode` non par défaut préférerait les résultats de cette option plutôt que les résultats par
  défaut.

- [Bitcoin Core #29623][] apporte diverses améliorations pour avertir les utilisateurs si leur heure
  locale semble être décalée de plus de 10 minutes par rapport à l'heure de leurs pairs connectés. Un
  nœud avec une mauvaise horloge pourrait temporairement rejeter des blocs valides, ce qui peut
  conduire à plusieurs problèmes de sécurité potentiellement graves. Ceci est un suivi de la
  suppression du temps ajusté par le réseau du code de consensus (voir le [Bulletin #288][news288
  time]).

## Corrections

Le script d'exemple pour la vérification de signature ECDSA avec signature Lamport utilisait à
l'origine `OP_CHECKSIG` mais a été mis à jour après publication pour utiliser `OP_CHECKSIGVERIFY`;
nous remercions Antoine Poinsot d'avoir signalé notre erreur.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30012,28016,29623,27742,28970" %}
[lnd v0.18.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.0-beta.rc1
[libsecp256k1 v0.5.0]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.5.0
[heilman lamport]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAEM=y+XyW8wNOekw13C5jDMzQ-dOJpQrBC+qR8-uDot25tM=XA@mail.gmail.com/
[signature lamport]: https://en.wikipedia.org/wiki/Lamport_signature
[poelstra lamport1]: https://mailing-list.bitcoindevs.xyz/bitcoindev/ZjD-dMMGxoGNgzIg@camus/
[der encoding]: https://en.wikipedia.org/wiki/X.690#DER_encoding
[heilman lamport2]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAEM=y+UnxB2vKQpJAa-z-qGZQfpR1ZeW3UyuFFZ6_WTWFYGfjw@mail.gmail.com/
[poelstra lamport2]: https://gnusha.org/pi/bitcoindev/Zjo72iTDYjwwsXW3@camus/T/#m9c4d5836e54ed241c887bcbf3892f800b9659ee2
[news300 secp]: /fr/newsletters/2024/05/01/#libsecp256k1-1058
[news288 time]: /fr/newsletters/2024/02/07/#bitcoin-core-28956
[news141 key hiding]: /en/newsletters/2021/03/24/#p2pkh-hides-keys
[review club 30000]: https://bitcoincore.reviews/30000
