---
titre: 'Bulletin Hebdomadaire Bitcoin Optech #271'
permalink: /fr/newsletters/2023/10/04/
name: 2023-10-04-newsletter-fr
slug: 2023-10-04-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume une proposition pour contrôler à distance les nœuds LN à l'aide d'un dispositif de signature matériel,
décrit des recherches axées sur la confidentialité et du code permettant aux nœuds de transmission de diviser dynamiquement les paiements
LN, et examine une proposition visant à améliorer la liquidité LN en permettant à des groupes de nœuds de transfert de regrouper des
fonds séparément de leurs canaux normaux. Sont également incluses nos sections régulières annonçant les
nouvelles versions de logiciels et les versions candidates, et décrivant les principaux changements apportés aux logiciels
d'infrastructure Bitcoin les plus répandus.

## Nouvelles

- **Contrôle à distance sécurisé des nœuds LN :** Bastien Teinturier a [publié][teinturier remote post] sur la liste de diffusion
  Lightning-Dev une [proposition BLIP][blips #28] qui spécifierait comment un utilisateur pourrait envoyer des commandes signées à son
  nœud LN à partir d'un dispositif de signature matériel (ou de tout autre portefeuille). Le dispositif de signature n'aurait besoin de
  mettre en œuvre que le BLIP plus la communication entre pairs [BOLT8][] et le nœud LN n'aurait besoin de mettre en œuvre que le BLIP.
  Cela ressemble au plugin _commando_ de Core Lightning (voir [Bulletin #210][news210 commando]), qui permet un contrôle presque complet
  à distance d'un nœud LN, mais Bastien Teinturier envisage sa fonctionnalité principalement pour le contrôle des actions de nœud les plus
  sensibles, telles que l'autorisation d'un paiement---le type d'actions pour lesquelles un utilisateur serait raisonnablement prêt à
  passer par la peine de connecter et de déverrouiller un dispositif de sécurité matériel, puis d'autoriser l'action. Cela faciliterait
  la sécurisation du solde LN d'un utilisateur avec le même niveau de sécurité de dispositif de signature matériel que son solde onchain.

- **Division et commutation des paiements :** Gijs van Dam a [publié][van dam pss post] sur la liste de diffusion Lightning-Dev un
  [plugin][pss plugin] qu'il a écrit pour Core Lightning et des [recherches][pss research] qu'il a effectuées à ce sujet. Le plugin
  permet aux nœuds de transfert d'indiquer à leurs pairs qu'ils prennent en charge la _division et la commutation des paiements_ (PSS).
  Si Alice et Bob partagent un canal et que tous deux prennent en charge le PSS, alors lorsque Alice reçoit un paiement à transférer
  à Bob, le plugin peut diviser ce paiement en deux ou plusieurs [parties de paiement][topic multipath payments]. L'un de ces paiements
  peut être transféré à Bob comme d'habitude, mais les autres peuvent suivre des chemins alternatifs (par exemple, d'Alice à Carol à Bob).
  Bob attend de recevoir toutes les parties, puis continue de transférer le paiement comme d'habitude vers le prochain saut.

     Le principal avantage de cette approche est qu'elle rend plus difficile l'exécution d'attaques de _découverte de solde_ (BDA) où
     une tierce partie [sonde][topic payment probes] de manière répétée un canal pour suivre son solde. Si cela est fait fréquemment,
     une BDA peut suivre le montant d'un paiement passant par un canal. Si cela est fait sur de nombreux canaux, il peut être possible
     de suivre ce paiement lorsqu'il traverse le réseau. Lorsque le PSS est utilisé, l'attaquant devrait suivre non seulement le solde
     du canal Alice-et-Bob, mais aussi celui du canal Alice-et-Carol et les canaux Carol-et-Bob. Même si l'attaquant suivait le solde de
     tous ces canaux, la difficulté de calcul pour suivre le paiement augmente, tout comme la possibilité que des parties des paiements
     d'autres utilisateurs qui passent simultanément par ces canaux puissent être confondues avec des parties du paiement original qui
     est suivi. Un [article][pss research] de van Dam a montré qu'un attaquant pouvait obtenir
     une réduction de 62% de la quantité d'informations lorsque PSS est déployé.

     Deux avantages supplémentaires sont mentionnés dans l'article de van Dam sur PSS :
     une augmentation du débit de LN et une partie d'atténuation contre les [attaques de brouillage de canal][topic channel
     jamming attacks]. L'idée de PSS a fait l'objet d'une petite discussion sur la liste de diffusion à la date de rédaction de cet
     article.

- **Liquidité mutualisée pour LN :** ZmnSCPxj [a proposé][zmnscpxj sidepools1] à la liste de diffusion Lightning-Dev une suggestion
  qu'il appelle des _sidepools_. Cela impliquerait des groupes de nœuds de transfert travaillant ensemble pour déposer des fonds dans
  un contrat d'état multiparties---un contrat hors chaîne (qui est ancré sur la chaîne de manière similaire à un canal LN) qui permettrait
  de déplacer des fonds entre les participants en mettant à jour l'état du contrat hors chaîne. Par exemple, un état initial qui donne
  à Alice, Bob et Carol chacun 1 BTC pourrait être mis à jour vers un nouvel état qui donne à Alice 2 BTC, Bob 0 BTC et Carol 1 BTC.

     Les nœuds de transfert continueraient également à utiliser et à annoncer des canaux LN ordinaires entre des paires de nœuds ;
     par exemple, les trois utilisateurs décrits précédemment pourraient avoir trois canaux distincts : Alice et Bob, Bob et Carol, et
     Alice et Carol. Ils transféreraient les paiements à travers ces canaux exactement de la même manière qu'ils le peuvent aujourd'hui.

     Si un ou plusieurs des canaux ordinaires devenaient déséquilibrés---par exemple, une trop grande partie des fonds dans le canal
     entre Alice et Bob appartient maintenant à Alice---le déséquilibre pourrait être résolu en effectuant un [peerswap][] hors chaîne
     dans le contrat d'état. Par exemple, Carol pourrait fournir des fonds à Alice dans le contrat d'état à condition qu'Alice transfère
     la même quantité de fonds à travers Bob vers Carol dans le canal LN ordinaire---rétablissant l'équilibre dans le canal LN entre
     Alice et Bob.

     L'avantage de cette approche c'est que personne n'a besoin de connaître le contrat d'état à part les participants de chaque contrat
     particulier. Pour tous les utilisateurs LN ordinaires et tous les nœuds de transfert qui ne sont pas impliqués dans un contrat
     particulier, LN continue de fonctionner en utilisant le protocole actuel. Un autre avantage, par rapport aux opérations de
     rééquilibrage de canal existantes, c'est que l'approche du contrat d'état permet à un grand nombre de nœuds de transfert de
     maintenir une relation directe entre pairs pour une petite quantité d'espace sur la chaîne, éliminant ainsi probablement les
     frais de rééquilibrage hors chaîne entre ces pairs. Le maintien de frais de rééquilibrage minimaux aide grandement les nœuds
     de transfert à maintenir l'équilibre de leurs canaux, ce qui améliore leur potentiel de revenus et rend l'envoi de paiements
     à travers LN plus fiable.

     L'inconvénient de cette approche c'est qu'elle nécessite un contrat d'état multiparties, ce qui n'a jamais été mis en œuvre en
     production jusqu'à notre connaissance. ZmnSCPxj mentionne deux protocoles de contrat qui pourraient être utiles à utiliser comme
     base, [LN-Symmetry][topic eltoo] et [duplex payment channels][]. LN-Symmetry nécessiterait un changement de consensus, ce qui semble
     peu probable dans un avenir proche, c'est pourquoi un [article de suivi][zmnscpxj sidepools2] de ZmnSCPxj semble se concentrer sur
     les canaux de paiement duplex (que ZmnSCPxj appelle "Decker-Wattenhofer" d'après les chercheurs qui les ont proposés en premier).
     Le problème avec les canaux de paiement duplex c'est qu'ils ne peuvent pas rester ouverts indéfiniment, bien que l'analyse de ZmnSCPxj
     indique qu'ils peuvent probablement rester ouverts suffisamment longtemps, et à travers suffisamment de changements d'état, pour
     amortir leur coût de manière efficace.

     Il n'y a eu aucune réponse publique aux articles au moment de la rédaction, bien que nous ayons appris dans une correspondance
     privée avec ZmnSCPxj qu'il travaille à développer davantage l'idée.

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets
d'infrastructure Bitcoin. Veuillez envisager de passer aux nouvelles
versions ou d'aider à tester les versions candidates.*

- [LND v0.17.0-beta][] est la version pour la prochaine version majeure de cette implémentation populaire de nœud LN. Une nouvelle
  fonctionnalité expérimentale majeure incluse dans cette version est la prise en charge des "canaux [taproot][topic taproot] simples",
  ce qui permet d'utiliser des [canaux non annoncés][topic unannounced channels] financés onchain à l'aide d'une sortie P2TR. Il s'agit
  de la première étape vers l'ajout d'autres fonctionnalités aux canaux de LND, telles que la prise en charge des [Taproot Assets][topic
  client-side validation] et des [PTLC][topic ptlc]. La version inclut également une amélioration significative des performances pour les
  utilisateurs du backend Neutrino, qui prend en charge les [filtres de bloc compacts][topic compact block filters], ainsi que des
  améliorations de la fonctionnalité [watchtower][topic watchtowers] intégrée de LND. Pour plus d'informations, veuillez consulter les
  [notes de version][lnd rn] et le [billet de blog de la version][lnd 17 blog].

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning
BOLTs][bolts repo], et [Bitcoin Inquisition][bitcoin inquisition repo].*

- [Eclair #2756][] introduit la surveillance des opérations de [splicing][topic splicing]. Les métriques collectent l'initiateur de
  l'opération et distinguent trois types de splices : splice-in, splice-out et splice-cpfp.

- [LDK #2486][] ajoute la prise en charge du financement de plusieurs canaux dans une seule transaction, garantissant l'atomicité avec
  soit tous les canaux groupés financés et ouverts, soit tous fermés.

- [LDK #2609][] permet de demander les [descripteurs][topic descriptors] utilisés pour recevoir des paiements dans des transactions
  passées. Auparavant, les utilisateurs devaient les stocker eux-mêmes ; avec l'API mise à jour, les descripteurs peut être reconstruit
  à partir d'autres données stockées.

{% include references.md %}
{% include linkers/issues.md v=2 issues="2756,2486,2609,28" %}
[LND v0.17.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.0-beta
[teinturier remote post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004084.html
[news210 commando]: /en/newsletters/2022/07/27/#core-lightning-5370
[van dam pss post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004114.html
[pss plugin]: https://github.com/gijswijs/plugins/tree/master/pss
[pss research]: https://eprint.iacr.org/2023/1360
[zmnscpxj sidepools1]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004099.html
[peerswap]: https://github.com/ElementsProject/peerswap
[duplex payment channels]: https://www.tik.ee.ethz.ch/file/716b955c130e6c703fac336ea17b1670/duplex-micropayment-channels.pdf
[zmnscpxj sidepools2]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004108.html
[lnd rn]: https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/release-notes-0.17.0.md
[lnd 17 blog]: https://lightning.engineering/posts/2023-10-03-lnd-0.17-launch/
