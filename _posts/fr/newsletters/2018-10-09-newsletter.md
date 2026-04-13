---
title: 'Bulletin Hebdomadaire Bitcoin Optech #16'
permalink: /fr/newsletters/2018/10/09/
name: 2018-10-09-newsletter-fr
slug: 2018-10-09-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine consiste entièrement en résumés de plusieurs présentations notables données lors de l'atelier Scaling Bitcoin
le week-end dernier, car il y avait très peu à signaler dans nos sections habituelles Action Items, Nouvelles, et Changements notables dans
le code. Nous espérons revenir à notre format habituel la semaine prochaine.

## Résumé de l'atelier : Scaling Bitcoin V (Tokyo 2018)

La cinquième conférence Scaling Bitcoin s'est tenue samedi et dimanche à Tokyo, au Japon. Dans les sections ci-dessous, nous fournissons de
brefs aperçus de certaines des présentations qui, selon nous, pourraient être les plus intéressantes pour les lecteurs de ce bulletin, mais
nous recommandons également de regarder l'ensemble complet des [vidéos][] fournies par les organisateurs de l'atelier ou de lire les
[transcriptions][] fournies par Bryan Bishop.

Pour plus de commodité, à la fin de chaque résumé nous ajoutons un lien direct vers sa vidéo et sa transcription (et son article, si
disponible). Les présentations sont listées ci-dessous dans l'ordre où elles apparaissaient dans le programme de l'atelier.

**Avertissement :** les résumés qui suivent peuvent contenir des erreurs en raison du fait que nombre de présentations décrivaient des
sujets allant bien au-delà de l'expertise de l'auteur des résumés.

### Ajuster la subvention de bloc de Bitcoin

*Recherche par Anthony (AJ) Towns*

Cette présentation mène une réflexion intellectuelle sur la question de savoir si Bitcoin paie plus pour sa sécurité qu'il n'en a
besoin---et sur ce que nous pourrions faire si nous décidions qu'il paie effectivement trop. L'orateur précise clairement qu'il s'intéresse
à l'examen des questions et à la fourniture de réponses possibles, mais qu'il ne suggère ni qu'il y ait un problème ni ne plaide pour une
quelconque solution.

Si la base d'utilisateurs de Bitcoin pensait qu'elle surpaie la sécurité, la présentation suggère des options pour réduire le montant de
subvention versé à court terme à mesure que le niveau de sécurité augmente---tout en garantissant que pas plus de 21 millions de bitcoins ne
soient versés au total en subvention---permettant potentiellement à la subvention de durer bien plus longtemps que prévu actuellement.

Bien que la présentation ne portât pas sur une proposition spécifique, un exemple de proposition qu'elle a évaluée consistait à réduire la
subvention de 20 % chaque fois que la sécurité de preuve de travail du réseau double (mesurée par la difficulté de création des blocs).

*[vidéo][vid subsidy], [transcription][tx subsidy]*

### Forward blocks : augmentations de capacité on-chain sans hard fork

*Recherche par Mark Friedenbach*

Une méthode bien connue pour augmenter par soft fork la taille des blocs Bitcoin est celle des extension blocks---une structure de données
qui est invisible aux nœuds qui n'ont pas été mis à niveau vers le soft fork et qui n'est donc pas soumise à leurs limites historiques sur
la taille des blocs. En soi, il s'agit d'une méthode indésirable pour augmenter la taille des blocs, car empêcher les anciens nœuds de voir
les transactions dans l'extension block les empêche également de pouvoir appliquer toute autre règle de consensus à ces transactions---comme
les règles qui empêchent un utilisateur malveillant de dépenser les bitcoins d'autres utilisateurs ou d'en créer davantage que ce qui est
autorisé par le calendrier de subvention de 21 millions de bitcoins.

Cependant, il n'est pas nécessaire d'augmenter la taille des blocs pour accroître la quantité de données pouvant être ajoutée à la chaîne de
blocs par minute---il est aussi possible d'augmenter la capacité en augmentant la fréquence des blocs (en réduisant le temps moyen entre les
blocs). Une méthode pour détourner l'algorithme d'ajustement de difficulté de Bitcoin---appelée une attaque par déformation temporelle
(*time-warp attack*)---est bien connue parmi les experts et a été utilisée avec succès dans des attaques de démonstration contre le testnet
de Bitcoin et dans de véritables attaques contre des altcoins. (Note : bien que Bitcoin soit techniquement vulnérable à cette attaque, ce
serait une attaque lente qui donnerait à la base d'utilisateurs un temps important pour réagir.) En soi, augmenter la fréquence des blocs
est également une méthode indésirable pour accroître la capacité, car des intervalles de blocs plus courts augmentent l'efficacité des
mineurs disposant de grandes quantités de hachage et sont donc susceptibles d'accroître la centralisation du minage.[^freq-pow-waste]

Contredisant peut-être le dicton selon lequel « deux torts ne font pas un droit », cette présentation décrit une nouvelle façon de combiner
les extension blocks et l'attaque par déformation temporelle afin de permettre aux nœuds mis à niveau comme aux anciens nœuds de bénéficier
de la même augmentation de capacité et de voir toutes les mêmes transactions pour leur validation, tout en réduisant simultanément
légèrement le risque de centralisation du minage. Les nœuds mis à niveau valideraient un ou plusieurs extension blocks (appelés « forward
blocks ») qui fournissent de l'espace de bloc supplémentaire avec un intervalle moyen de 15 minutes réduisant la centralisation, mais les
nœuds mis à niveau restreindraient également les horodatages dans les blocs hérités afin d'assurer une attaque par déformation temporelle
permanente (mais limitée) augmentant la fréquence des blocs hérités suffisamment pour leur permettre d'inclure les mêmes transactions qui
apparaissaient auparavant dans les forward blocks.

*[vidéo][vid forward blocks], [transcription][tx forward blocks], [article][paper forward blocks]*

### Signatures multiples compactes pour des blockchains plus petites

*Recherche par Dan Boneh, Manu Drijvers, et Gregory Neven*

Cette présentation décrit une alternative au schéma de signature Schnorr décrit dans le [document MuSig][] qui utilise la [cryptographie
basée sur les appariements][], spécifiquement une adaptation du [schéma de signature Boneh--Lynn--Shacham (BLS)][bls sigs]. Bien que les
schémas basés sur les appariements exigent une hypothèse de sécurité fondamentale supplémentaire au-delà de celles faites à la fois par le
schéma ECDSA actuel de Bitcoin et par le schéma Schnorr proposé, les auteurs présentent des éléments montrant que leur schéma produirait des
signatures généralement plus petites, permettrait une agrégation de signatures non interactive, et rendrait possible de prouver quels
membres de l'ensemble des signataires ont effectivement travaillé ensemble pour créer une signature à seuil (c.-à-d. k-sur-m signataires,
par ex. multisig 2-sur-3).

*[vidéo][vid bls msig], [transcription][tx bls msig], [article (pre-print)][paper bls msig]*

### Accumulateurs : un remplacement évolutif prêt à l'emploi pour les arbres de merkle

*Recherche par Benedikt Bünz, Benjamin Fisch, et Dan Boneh*

Dans Bitcoin et d'autres cryptomonnaies, les engagements évolutifs envers des ensembles d'informations---comme les transactions ou les
UTXO---sont normalement réalisés à l'aide d'arbres de merkle qui permettent de prouver qu'un élément est membre de l'ensemble en générant
une preuve dont la taille et le coût de validation sont approximativement de *log2(n)* pour un ensemble de *n* éléments.

Cette présentation décrit une méthode alternative basée sur des accumulateurs RSA qui offre des avantages potentiels : la taille d'une
preuve est constante quel que soit le nombre d'éléments membres de l'ensemble, et l'ajout ou la suppression d'éléments d'un accumulateur
peut être efficacement regroupé (par ex. une mise à jour par bloc).

*[vidéo][vid accumulators], [transcription][tx accumulators]*

### ECDSA multipartite pour des canaux de paiement Lightning Network sans script

*Recherche par Conner Fromknecht*

Les canaux de paiement routables tels que ceux utilisés par le Lightning Network utilisent actuellement plusieurs opcodes du langage Script
qui sont appliqués par les règles de consensus de Bitcoin. Des travaux antérieurs sur les [scripts sans script][scriptless scripts
transcript] par Andrew Poelstra ont [suggéré][ln scriptless scripts] que certains ou la totalité des opcodes actuellement utilisés
pourraient être remplacés par des clés publiques Schnorr et des signatures qui seraient créées en privé (offchain) entre les participants
du canal de paiement. Les règles de consensus exigeraient toujours qu'une transaction de dépense ait une signature valide faisant référence
à une clé publique connue, mais aucune des autres informations liées à la sécurité n'apparaîtrait onchain, réduisant la consommation de
données et les frais, améliorant la confidentialité et la fongibilité, et améliorant potentiellement la sécurité.

Bitcoin ne prend actuellement pas en charge les signatures Schnorr et aucune conception complète pour cela n'a été proposée (bien qu'une
telle proposition puisse ne pas être bien loin), donc cette présentation décrit des résultats de preuve de concept issus d'une
implémentation partielle de scripts sans script pour canaux de paiement qui est compatible avec les clés et signatures ECDSA actuelles de
Bitcoin. Des économies impressionnantes sont obtenues sur la taille des scripts et des données witness---des économies qui augmentent le
nombre de canaux pouvant être ouverts ou fermés dans un bloc et qui réduisent le montant des frais de transaction payés par les utilisateurs
de canaux de paiement Lightning Network.

*[vidéo][vid scriptless ecdsa], [transcription][tx scriptless ecdsa]*

## Discussion : l'évolution du script bitcoin

Un groupe de discussion de deux heures centré sur ce sujet a mentionné une grande variété de modifications proposées au langage Script de
Bitcoin---bien trop nombreuses pour être mentionnées ici, même sous forme de résumé. Cependant, quelques modifications ont été mentionnées
comme théoriquement réalisables en 2019 si la communauté est prête à les adopter :

- **Schéma de signature Schnorr :** une fonctionnalité optionnelle fournissant des signatures plus petites dans tous les cas, une validation
  plus rapide, des données de clé publique et de signature beaucoup plus petites pour les multisigs coopératifs, et une compatibilité plus
  aisée avec les scripts sans script. Voir la [proposition de BIP][schnorr pre-bip] de Pieter Wuille.

- **SIGHASH_NOINPUT_UNSAFE :** la capacité de créer des dépenses sans référencer explicitement quelle sortie vous souhaitez dépenser. Permet
  de créer des canaux de paiement plus efficaces en utilisant le [protocole Eltoo][] qui permet aussi facilement à chaque canal de prendre
  en charge jusqu'à 150 participants. Voir [BIP118][].

- **OP_CHECKSIGFROMSTACK :** rend possible la création de covenants qui restreignent les sorties vers lesquelles une pièce particulière peut
  être dépensée. Par exemple, vous pourriez imposer un délai obligatoire d'une semaine sur les dépenses provenant de votre portefeuille à
  froid. Pendant ce délai, vous ne pourriez dépenser les pièces qu'en les renvoyant dans votre portefeuille à froid. Mais si vous attendiez
  l'expiration du délai, vous pourriez dépenser les pièces vers n'importe quelle adresse arbitraire. Cela signifie que si quelqu'un volait
  une copie de la clé privée de votre portefeuille à froid, vous pourriez utiliser ce mécanisme pour l'empêcher de dépenser vos bitcoins en
  les renvoyant dans votre portefeuille à froid pendant la période de délai. (Il a été noté que certains développeurs s'opposent à
  l'activation de la forme la plus simple de cet opcode pour des raisons de fongibilité, bien que des approches alternatives puissent être
  davantage acceptables.)

- **Correction du bug de déformation temporelle :** un ensemble de mineurs contrôlant la majorité du taux de hachage peut actuellement
  manipuler l'algorithme d'ajustement de difficulté de Bitcoin pour leur permettre de créer de façon constante plus d'un bloc toutes les dix
  minutes, même sans augmenter le taux de hachage global. Il existe au moins une proposition simple pour réduire la quantité de manipulation
  possible sans casser les logiciels plus anciens ni le matériel de minage. Voir le récent [fil de discussion par e-mail][bitcoin-dev
  timewarp] sur la liste de diffusion Bitcoin-Dev.

- **Frais explicites :** actuellement les frais dans Bitcoin sont implicites via la différence entre la valeur des entrées agrégées et celle
  des sorties agrégées. Cependant, la transaction pourrait alternativement s'engager explicitement sur les frais et permettre que l'une des
  sorties soit fixée à la différence entre la valeur des entrées agrégées et les frais explicites plus toutes les autres sorties. Cela
  pourrait être utile pour récompenser les watchtowers du Lightning Network qui envoient des transactions de remédiation de violation pour
  le compte d'utilisateurs hors ligne, ou cela pourrait être utile pour l'augmentation des frais de transactions de groupe.

Cependant, un membre du groupe de discussion a suggéré que « les seules personnes à l'aise avec les soft forks sont peu susceptibles de
proposer un soft fork et de produire un logiciel qui serait adopté. Les gens vont combattre tout ce qui ajoute quoi que ce soit, surtout
compte tenu du récent [CVE][CVE-2018-17144]. Les gens vont être, pendant les 6 prochains mois, significativement plus conservateurs. Il
faudra encore 6 mois avant que les gens n'envisagent même cela. Je ne pense pas que nous allons obtenir de nouveaux soft forks dans l'année
qui vient. »

*(pas de vidéo), [transcription][tx script]*

## Remerciements particuliers

Nous remercions Andrew Poelstra, Anthony Towns, Bryan Bishop, et Pieter Wuille pour avoir fourni des suggestions ou répondu à des questions
liées au contenu de ce bulletin. Toute erreur restante est entièrement de la faute de l'auteur du bulletin.

## Notes de bas de page

[^freq-pow-waste]: Lorsqu'un mineur crée un nouveau bloc à la pointe de la chaîne, il peut commencer à travailler immédiatement sur le bloc
suivant---mais tous les autres mineurs travaillent encore sur un ancien bloc jusqu'à ce qu'ils reçoivent le nouveau bloc, ce qui signifie
que leur preuve de travail pendant cette brève période est gaspillée (elle n'augmente ni la sécurité du réseau ni ne fournit aux mineurs une
compensation financière). Les mineurs disposant de plus de taux de hachage produisent davantage de blocs en moyenne, ils obtiennent donc
cette avance plus souvent et une plus petite partie de leur preuve de travail est gaspillée.

    Pour deux mineurs parfaitement équitables séparés par la moitié du globe, le délai réseau pratique minimal entre eux est d'environ 0,2
    seconde, ce qui signifie qu'un petit mineur éloigné de la plupart des autres mineurs n'est probablement productif que pendant 599,8
    secondes sur la moyenne de 600,0 secondes (dix minutes) entre les blocs. Une perte d'efficacité de 0,2/600,0 (0,03 %) est probablement
    acceptable, mais si la fréquence des blocs était augmentée, la perte d'efficacité augmenterait également : à un bloc par minute, la
    perte d'efficacité serait de 0,33 % ; à un bloc toutes les six secondes, de 3,33 %.

    Le petit mineur pourrait augmenter son efficacité en se rapprochant des autres mineurs ou même éliminer complètement la perte
    d'efficacité en fusionnant avec eux, mais c'est cette centralisation du minage qu'il est essentiel d'éviter dans Bitcoin si nous voulons
    empêcher les mineurs de pouvoir censurer facilement quelles transactions sont incluses dans les blocs.

{% include references.md %}

[videos]: https://tokyo2018.scalingbitcoin.org/#remote-participation
[transcriptions]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/
[vid subsidy]: https://youtu.be/y8hJ0VTPE34?t=39
[tx subsidy]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/playing-with-fire-adjusting-bitcoin-block-subsidy/
[vid forward blocks]: https://youtu.be/y8hJ0VTPE34?t=3744
[tx forward blocks]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/forward-blocks/
[paper forward blocks]: http://freico.in/forward-blocks-scalingbitcoin-paper.pdf
[vid bls msig]: https://youtu.be/IMzLa9B1_3E?t=29
[tx bls msig]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/compact-multi-signatures-for-smaller-blockchains/
[paper bls msig]: https://eprint.iacr.org/2018/483.pdf
[vid accumulators]: https://youtu.be/IMzLa9B1_3E?t=3522
[tx accumulators]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/accumulators/
[vid scriptless ecdsa]: https://youtu.be/3mJURLD2XS8?t=3624
[tx scriptless ecdsa]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/scriptless-ecdsa/
[tx script]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/bitcoin-script/
[document musig]: https://eprint.iacr.org/2018/068
[schnorr pre-bip]: https://github.com/sipa/bips/blob/bip-schnorr/bip-schnorr.mediawiki
[cryptographie basée sur les appariements]: https://en.wikipedia.org/wiki/Pairing-based_cryptography
[bls sigs]: https://en.wikipedia.org/wiki/Boneh%E2%80%93Lynn%E2%80%93Shacham
[scriptless scripts transcript]: https://scalingbitcoin.org/transcript/stanford2017/using-the-chain-for-what-chains-are-good-for
[protocole Eltoo]: https://blockstream.com/2018/04/30/eltoo-next-lightning.html
[bitcoin-dev timewarp]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016316.html
[ln scriptless scripts]: https://lists.launchpad.net/mimblewimble/msg00086.html
[cve-2018-17144]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2018-17144
