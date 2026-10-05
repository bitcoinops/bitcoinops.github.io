---
title: 'Bulletin Hebdomadaire Bitcoin Optech #32'
permalink: /fr/newsletters/2019/02/05/
name: 2019-02-05-newsletter-fr
slug: 2019-02-05-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine comprend une annonce du programme Chaincode Residency 2019, résume quelques présentations de la Stanford
Blockchain Conference, et fournit la liste habituelle des changements notables dans le code de projets populaires d'infrastructure Bitcoin.

## Action items

- **Postulez à la Chaincode Residency :** Bitcoin Optech encourage tout ingénieur intéressé par le fait de passer l'été à contribuer à des
  projets open source Bitcoin et Lightning à postuler à la Chaincode Residency. Tous les détails de la résidence se trouvent dans la section
  *Nouvelles* ci-dessous.

## Nouvelles

- **Chaincode Residency 2019 :** Chaincode Labs a ouvert les candidatures pour son [quatrième programme de résidence][residency] qui se
  tiendra à New York pendant l'été 2019. Le programme combine une série de séminaires et de discussions de 3 semaines couvrant le
  développement des protocoles Bitcoin et Lightning avec une période de deux mois pour travailler sur un projet open source Bitcoin ou
  Lightning sous la direction d'un développeur de protocole expérimenté. La liste des [intervenants et mentors confirmés][residency
  speakers] comprend certains des contributeurs les plus prolifiques à Bitcoin et Lightning. La précédente Chaincode Residency (axée sur les
  applications Lightning Network) a été couverte dans le [Bulletin #21][].

  Chaincode invite les développeurs qui souhaitent contribuer à des projets open source de protocoles Bitcoin et Lightning à [postuler à la
  résidence][residency apply]. Les candidats de tous horizons sont les bienvenus, et Chaincode prendra en charge les frais de voyage et
  d'hébergement et fournira une allocation pour aider à couvrir les frais de subsistance.

[residency]: https://residency.chaincode.com
[residency speakers]: https://residency.chaincode.com/#mentors
[residency apply]: https://residency.chaincode.com/#apply

## Présentations notables de la Stanford Blockchain Conference

La [troisième édition][sbc] de cette conférence annuelle (anciennement nommée BPASE) a inclus plus de deux douzaines de présentations
réparties sur trois jours. Nous avons trouvé les sujets suivants particulièrement intéressants du point de vue de Bitcoin, bien que nous
encouragions toute personne souhaitant en apprendre davantage à consulter les [transcriptions][] fournies par Bryan Bishop ou les vidéos
fournies par les organisateurs ([jour 1][], [jour 2][], [jour 3][]).

- **Accumulateurs pour les blockchains** présenté par Benedikt Bünz ([transcription][accumulators txt], [vidéo][accumulators vid]). Bitcoin
  Les nœuds complets maintiennent un registre (appelé l'ensemble UTXO) qui stocke les informations de propriété pour chaque groupement de
  bitcoins actuellement dépensable. Actuellement, ce registre contient plus de 50 millions d'entrées et utilise environ trois gigaoctets
  d'espace disque. Cela permet aux nœuds qui reçoivent une transaction de s'assurer que les bitcoins dépensés existent dans l'ensemble UTXO,
  de récupérer les informations de propriété de ces bitcoins, et de vérifier ces informations par rapport à la signature et aux autres
  données de témoin fournies dans la transaction.

  Mais que se passerait-il si nous demandions aussi au dépensier de fournir une copie des informations de propriété dans sa transaction
  ainsi qu'une preuve cryptographique que ces informations se trouvent bien dans l'ensemble UTXO ? Dans ce cas, nous n'aurions pas besoin de
  stocker l'ensemble complet, nous aurions seulement besoin de stocker un engagement envers un ensemble dont nous savions qu'il était exact
  et qui pouvait être référencé par des preuves exactes. Les accumulateurs RSA sont une idée (parmi plusieurs autres) pour savoir comment
  créer cet engagement et les preuves associées. En utilisant un accumulateur, la taille de l'engagement UTXO que les nœuds stockeraient sur
  disque serait minuscule comparée à l'état complet. Les transactions augmenteraient en taille du fait de la nécessité de fournir les
  données de propriété et une preuve qu'elles faisaient partie de l'ensemble UTXO actuel, mais l'augmentation de taille serait modeste (en
  supposant les transactions typiques actuelles, environ 70 octets d'informations de propriété par entrée plus une preuve qui pourrait être
  agrégée jusqu'à environ 325 octets par bloc).

  D'autres considérations affectent l'adéquation des accumulateurs à cette tâche, notamment le fait qu'ils sont relativement nouveaux en
  cryptographie, qu'ils nécessitent soit une configuration de confiance bien étudiée soit une configuration non fiable plus novatrice, et
  qu'ils peuvent potentiellement faire en sorte que les blocs prennent plus de temps à vérifier que dans le système actuel étant donné que
  la vérification des accumulateurs est environ 100x plus lente que les systèmes alternatifs utilisant des arbres de Merkle. Dans un
  développement nouveau par rapport à une précédente version de cette présentation donnée à Scaling Bitcoin 2018, l'intervenant décrit une
  accélération potentiellement majeure de la vérification pratique.

  En résumé, les accumulateurs RSA restent un domaine d'investigation intéressant sur la manière de réduire les exigences des nœuds complets
  pour stocker et accéder rapidement à l'ensemble UTXO. Cela n'est peut-être pas particulièrement important maintenant, lorsque l'ensemble
  UTXO est relativement petit et rapide, mais cela pourrait rendre plus facile le soutien d'initiatives qui changeraient la manière dont les
  gens utilisent l'ensemble UTXO à l'avenir. Par exemple :

  - Si les preuves basées sur des accumulateurs peuvent effectivement être vérifiées rapidement, elles pourraient permettre à la taille de
    l'ensemble UTXO de croître considérablement (peut-être à cause d'une augmentation de la taille des blocs) tout en garantissant que les
    mineurs peuvent vérifier les entrées de transaction suffisamment rapidement pour minimiser l'usage du spy mining ou la production de
    blocs périmés.

  - Les logiciels qui utilisent des ensembles UTXO de confiance avec des nœuds nouvellement démarrés pour éviter le coût et le délai du
    téléchargement et de la vérification de la chaîne de blocs complète (une option que [certains logiciels][btcpay utxo] fournissent déjà)
    pourraient réduire encore davantage ces coûts et délais en remplaçant l'ensemble UTXO de plusieurs gigaoctets par un accumulateur un
    million de fois plus petit.

  Il devrait être possible pour des expérimentateurs enthousiastes d'explorer l'utilisation des accumulateurs dans Bitcoin sans modifier
  aucune règle de consensus, comme Tadge Dryja l'a fait avec son système similaire [Utreexo][] basé sur des arbres de Merkle.

- **Miniscript** présenté par Pieter Wuille ([transcription][miniscript txt], [vidéo][miniscript vid], [diapositives][miniscript slides]).
  Imaginez que vous ayez un script Bitcoin qui donne le contrôle de vos bitcoins à votre avocat un an après votre dernier déplacement de
  fonds, au cas où il aurait besoin de les distribuer à vos héritiers. C'est un script facile à écrire. Mais que se passerait-il si
  quelqu'un vous demandait alors de rejoindre un contrat multisig 3-sur-4 où vous seriez l'une des parties détenant certains fonds. À quel
  point serait-il difficile pour vous d'insérer votre politique existante dans leur contrat multisig générique et d'être sûr de n'avoir rien
  cassé ? C'est la question posée par cet intervenant, et sa réponse est le langage de politique composable *miniscript*.

  Miniscript est un sous-ensemble du langage complet Bitcoin Script qui se concentre sur seulement quelques fonctionnalités telles que les
  *signatures*, les *délais* et les *hachages* plus des opérateurs pour les combiner, tels que *and*, *or*, ou *threshold*. Il est compact,
  facile à lire, et sera compilé vers le script le plus efficace implémentant une politique donnée. À partir d'un script existant compatible
  avec ses opérations, il l'inversera aussi en une politique pour une revue facile. Par conception, il utilise un vocabulaire similaire à
  celui des [descripteurs de script de sortie][] que Wuille a implémentés dans Bitcoin Core et il peut aider le metteur à jour ou le
  finaliseur dans un flux PSBT [BIP174][] à déterminer qui doit signer ensuite ou si toutes les données nécessaires à la finalisation du
  script ont été reçues.

  En examinant le problème posé dans le paragraphe d'introduction, nous pouvons définir la politique d'exemple de dépense personnelle comme
  étant soit vous fournissant une signature pour votre clé publique compressée, `pk(C)`, soit votre avocat attendant un an,
  `time(<seconds>)`, puis fournissant une signature pour sa propre clé publique compressée. Nous combinons ces branches avec un "or"
  asymétrique, `aor`, pour réduire les données de témoin requises lors du suivi de la première branche.

  ```
  aor(pk(C),and(time(31536000),pk(C)))
  ```

  Nous pouvons définir de manière similaire la politique multisig générique 3-sur-4 en utilisant des clés publiques compressées (`C`) :

  ```
  multi(3,C,C,C,C)
  ```

  Une politique fonctionnellement équivalente qui permettrait plus de flexibilité utiliserait l'opération threshold :

  ```
  thres(3,pk(C),pk(C),pk(C),pk(C))
  ```

  Cela vous permet de simplement remplacer l'une des clés publiques par votre politique personnelle :

  ```
  thres(3,pk(C),pk(C),pk(C),aor(pk(C),and(time(31536000),pk(C))))
  ```

  Une fois compilé, le résultat est le script suivant :

  ```
  [pk] CHECKSIG SWAP [pk] CHECKSIG ADD SWAP [pk] CHECKSIG ADD
  TOALTSTACK IF [pk] CHECKSIGVERIFY 0x8033e101 CHECKSEQUENCEVERIFY
  0NOTEQUAL ELSE [pk] CHECKSIG ENDIF FROMALTSTACK ADD 3 EQUAL
  ```

  Un avantage final de miniscript est qu'il devrait permettre à une politique écrite aujourd'hui d'être automatiquement traduite dans une
  structure qui fait un usage optimal de MAST, taproot, ou d'autres possibles mises à niveau du protocole Bitcoin. Cela signifie que, à
  mesure que le protocole Bitcoin progresse, l'utilisateur ou le développeur qui a investi du temps dans l'élaboration d'une politique
  n'aura pas à refaire son travail afin de continuer à l'utiliser avec une technologie plus récente.

  L'intervenant a fourni une [démo interactive en Javascript du compilateur miniscript][miniscript demo], et lui et ses collaborateurs
  disposent également d'une version du compilateur en langage Rust qu'ils prévoient de publier bientôt en open source.

- **Soft forks Bitcoin probabilistes (sporks)** présenté par Jeremy Rubin ([transcription][spork txt], [vidéo][spork vid]). En mars 2017,
  presque tous les nœuds Bitcoin étaient prêts à commencer à appliquer le soft fork segwit mais les mineurs semblaient peu disposés à
  envoyer le signal d'activation. Cela a créé de la confusion : les mineurs ont-ils le droit de mettre leur veto aux mises à niveau du
  protocole ? S'ils l'ont, segwit est-il mort ? S'ils ne l'ont pas, que font les utilisateurs pour les contourner ? Finalement la situation
  a été résolue, mais c'était un désordre que beaucoup préféreraient ne pas répéter.

  L'intervenant identifie la cause profonde du problème comme étant le fait que les mineurs sont capables de retarder l'activation sans coût
  pour eux-mêmes. Il propose une solution : utiliser l'aléa restant dans le hachage de l'en-tête d'un bloc pour déterminer si oui ou non un
  bloc signale l'activation. Par exemple, nous choisirions une cible que seulement 1 hachage d'en-tête sur 26 000 correspondrait. Un bloc
  correspondant à cette cible serait produit une fois tous les six mois en moyenne, bien que personne ne saurait exactement quand (environ
  10 % du temps, ce serait dans les 3 semaines ; mais 10 % du temps encore, cela prendrait plus d'un an).

  Les mineurs n'auraient aucun contrôle sur le fait que leur bloc signale ou non l'activation, mais ils auraient le contrôle sur le fait de
  publier ce bloc. Un mineur qui refuserait de publier son propre bloc s'il signalait l'activation perdrait les revenus de ce bloc mais
  empêcherait avec succès l'activation du fork au moins jusqu'à ce que le prochain bloc de signalisation soit produit (ce qui pourrait être
  demain ou pourrait être deux ans plus tard). Cela donne aux mineurs une réelle possibilité de retenir un changement mais seulement en
  sacrifiant des revenus réels. La fin de la présentation suggère quelques variations de la méthode avec différents compromis.

  L'idée doit être analysée pour d'éventuels problèmes, mais elle fournit une alternative intéressante aux soft forks activés par les
  mineurs de type [BIP9][] (MASFs) et aux soft forks activés par les utilisateurs de type [BIP8][] (UASFs).

  À la conclusion de sa présentation, cet intervenant a également annoncé que la prochaine conférence Scaling Bitcoin et les sessions de
  formation EdgeDev++ auront lieu plus tard en 2019 à Tel Aviv, en Israël.

## Changements notables dans le code

*Changements notables dans le code cette semaine dans [Bitcoin Core][bitcoin core repo], [LND][lnd repo], [C-Lightning][c-lightning repo],
[Eclair][eclair repo], et [libsecp256k1][libsecp256k1 repo].*

- [Bitcoin Core #14929][] permet aux pairs que votre nœud a automatiquement déconnectés pour mauvais comportement (par ex. en envoyant des
  données invalides) de se reconnecter à votre nœud si vous avez des emplacements de connexion entrante inutilisés. Si vos emplacements se
  remplissent, les nœuds malveillants sont déconnectés pour faire de la place aux nœuds sans historique de problèmes (à moins que le nœud
  malveillant aide votre nœud d'une autre manière, par exemple en se connectant à une partie d'Internet depuis laquelle vous n'avez pas
  beaucoup d'autres pairs). Auparavant, Bitcoin Core bannissait les adresses IP des pairs malveillants pendant une certaine durée (1 jour
  par défaut) ; cela était facilement contourné par des attaquants disposant de plusieurs adresses IP. Cette solution donne à ces pairs une
  chance d'être utiles mais accorde la priorité à des pairs potentiellement plus utiles. Si vous bannissez manuellement un pair, par exemple
  en utilisant le RPC `setban`, les connexions de ce pair seront toujours rejetées.

- [Bitcoin Core #13926][] ajoute un nouvel outil `bitcoin-wallet` aux exécutables fournis par Bitcoin Core. Sans utiliser de RPC ni aucun
  accès réseau, cet outil peut actuellement créer un nouveau fichier portefeuille ou afficher quelques informations de base sur un
  portefeuille existant, par exemple si le portefeuille est chiffré, s'il utilise une graine HD, combien de transactions il contient et
  combien d'entrées de carnet d'adresses il possède. Cela aide les personnes qui ont un fichier portefeuille qui n'a pas été synchronisé
  avec le tip de chaîne le plus récent ; elles peuvent faire une inspection rapide du portefeuille pour voir s'il est intéressant avant
  d'effectuer la longue réanalyse nécessaire pour l'importer. Les développeurs prévoient d'ajouter davantage de fonctionnalités à l'outil à
  l'avenir.

- [Bitcoin Core #15159][] modifie le RPC `getrawtransaction` de sorte qu'il ne retournera désormais par défaut que les transactions du
  mempool. Si vous avez activé l'index optionnel des transactions (txindex), il retournera aussi les transactions confirmées. Avant ce
  changement, même si vous n'aviez pas activé txindex, il retournait les transactions confirmées si toutes leurs sorties n'avaient pas
  encore été dépensées. Ce comportement précédent perturbait les utilisateurs : l'appel fonctionnait sur certaines transactions confirmées
  mais pas sur d'autres, et parfois des transactions qui fonctionnaient auparavant cessaient soudainement de fonctionner. Ce changement rend
  le RPC plus cohérent dans son comportement (bien sûr, les mempools varient d'un nœud à l'autre et évoluent avec le temps).

- [LND #2538][] augmente le délai par défaut entre l'envoi de mises à jour concernant les nœuds publics existant sur le réseau de 30
  secondes à 90 secondes. Cela ralentit la propagation sur le réseau, qui a énormément grandi en taille, afin d'économiser la bande
  passante. Indépendamment de cette PR, les développeurs du protocole LN préparent des changements au protocole de gossip pour être plus
  efficaces en bande passante, bien qu'une fréquence de mise à jour plus faible permette toujours aussi d'économiser de la bande passante.
  (Voir aussi [C-Lightning #2297][] pour le correctif cette semaine d'un bug que certains nœuds rencontraient parce que le volume de gossip
  qu'ils recevaient était si important.)

- [LND #2554][] déprécie l'erreur onion `IncorrectHtlcAmount` au profit de l'erreur `UnknownPaymentHash` qui inclut maintenant le montant du
  paiement échoué. LND continuera à gérer l'ancien code d'erreur mais ne le générera plus.

- [LND #2500][] déconnecte tous les pairs qui ne prennent pas en charge le protocole Data Loss Protection (DLP). Cela garantit que le
  nouveau format de sauvegarde de LND sera utilisable. Voir la section *notable commits* et la note de bas de page du [bulletin de la
  semaine dernière][le bulletin #31] pour des informations sur le nouveau protocole de sauvegarde et le protocole DLP existant.

{% include references.md %}
{% include linkers/issues.md issues="2500,2554,15159,13926,2538,14929,2297" %}
[accumulators txt]: http://diyhpl.us/wiki/transcripts/stanford-blockchain-conference/2019/accumulators/
[accumulators vid]: https://youtu.be/XckwEw8FyEA?t=20295
[miniscript txt]: http://diyhpl.us/wiki/transcripts/stanford-blockchain-conference/2019/miniscript/
[miniscript vid]: https://youtu.be/sQOfnsW6PTY?t=22539
[miniscript slides]: https://prezi.com/view/KH7AXjnse7glXNoqCxPH/
[miniscript demo]: http://bitcoin.sipa.be/miniscript/miniscript.html
[spork txt]: http://diyhpl.us/wiki/transcripts/stanford-blockchain-conference/2019/spork-probabilistic-bitcoin-soft-forks/
[spork vid]: https://youtu.be/sQOfnsW6PTY?t=29762
[sbc]: https://cyber.stanford.edu/sbc19
[transcriptions]: http://diyhpl.us/wiki/transcripts/stanford-blockchain-conference/2019/
[jour 1]: https://www.youtube.com/watch?v=XckwEw8FyEA
[jour 2]: https://www.youtube.com/watch?v=sQOfnsW6PTY
[jour 3]: https://www.youtube.com/watch?v=U5fEvfAFs_o
[utreexo]: https://dci.mit.edu/research/2018/11/28/utreexo-a-dynamic-accumulator-for-bitcoin-state-a-description-of-research-by-thaddeus-dryja
[btcpay utxo]: https://github.com/btcpayserver/btcpayserver-docker/tree/master/contrib/FastSync
[bulletin #21]: /fr/newsletters/2018/11/13/#vidéos-de-la-résidence-sur-les-applications-lightning
[le bulletin #31]: /en/newsletters/2019/01/29/#c-lightning-2283
[descripteurs de script de sortie]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
