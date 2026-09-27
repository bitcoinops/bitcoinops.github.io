---
title: 'Bulletin Hebdomadaire Bitcoin Optech #22'
permalink: /fr/newsletters/2018/11/20/
name: 2018-11-20-newsletter-fr
slug: 2018-11-20-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin « de taille wumbo » de cette semaine fournit une note à propos du taux de hachage de Bitcoin lié aux forks d'autres
cryptomonnaies, résume plusieurs objectifs acceptés pour la version 1.1 de la spécification du protocole Lightning Network, et liste
plusieurs commits notables dans des projets populaires d'infrastructure Bitcoin.

## Actions recommandées

- **Surveiller les taux de frais :** en raison d'une activité associée à Bitcoin Cash, qui peut utiliser le même équipement de minage que
  Bitcoin, les blocs de Bitcoin peuvent apparaître moins fréquemment que prévu, ce qui augmente les taux de frais et provoque d'autres
  effets. Cependant, ces conditions peuvent soudainement s'inverser, entraînant une période de blocs rapides et de faibles taux de frais.
  Voir la section Nouvelles ci-dessous pour plus d'informations et des actions recommandées pour les entreprises Bitcoin.

## Nouvelles des fonctionnalités : objectifs du protocole Lightning Network 1.1

Les développeurs du protocole LN se sont [réunis à Adélaïde][rusty wrapup] le week-end dernier afin de déterminer quels changements adopter
pour la prochaine spécification du protocole Lightning 1.1. Trente propositions ont été acceptées à un haut niveau---ce qui signifie que les
spécifications complètes de chaque proposition ne sont pas nécessairement encore définies ou approuvées---mais le [plan de base][ln1.1
outline] des nouvelles fonctionnalités est disponible. Quelques points saillants de la réunion incluent :

- **Paiements multi-chemins :** la manière normale actuelle d'effectuer un paiement sur LN consiste à utiliser un seul chemin. Alice paie
  Charlie via son canal vers Bob et le canal de Bob vers Charlie. Cela fonctionne bien pour les petits paiements où chaque participant
  dispose d'une capacité suffisante pour prendre en charge le paiement. Mais si nous utilisons ce mécanisme alors qu'Alice a 10 canaux
  ouverts contenant chacun au maximum 10 % du solde total de son portefeuille à chaud, Alice ne peut dépenser qu'au plus 10 % de ses fonds à
  la fois.

  Les paiements multi-chemins apportent une solution à ce problème : si Alice veut envoyer 15 % de ses fonds, elle peut envoyer 7,5 % à
  Charlie via son canal avec Bob et 7,5 % via son canal avec Dan (qui a lui aussi un canal avec Charlie). Bien que les paiements partiels
  soient routés par des chemins séparés, ils peuvent chacun s'engager sur le même hash qu'Alice aurait utilisé pour envoyer un paiement par
  chemin unique. Si Charlie reçoit plusieurs paiements dans une période de temps raisonnable qui égalent ou dépassent le montant attendu, il
  peut garantir qu'il les recevra tous simplement en révélant la préimage unique utilisée par tous les hash. Cela réutilise le même
  mécanisme de sécurité éprouvé actuellement utilisé pour les paiements par chemin unique et n'introduit donc aucune nouvelle hypothèse de
  sécurité. Le même mécanisme fonctionne aussi si une autre partie le long du chemin disposant d'une capacité de canal suffisante fusionne
  les paiements partiels et transmet un paiement unique le long du reste du chemin jusqu'à Charlie.

  Pour plus d'informations, voir les fils Lightning-Dev suivants qui appellent souvent cette fonctionnalité Atomic Multi-path Payments (AMP)
  : [une première proposition avec des hash/préimages séparés][roasbeef amp], [quelque chose comme la proposition actuellement
  privilégiée][zmn base amp], [une proposition peut-être trop optimiste][pickhardt local amp].

- **Canaux financés par les deux parties :** une fonctionnalité intéressante de l'implémentation actuelle est qu'une seule partie du canal
  doit initialement y engager des fonds. Par exemple, Alice ouvre un canal vers Bob avec 0,1 BTC de son argent et aucun argent de Bob. Cela
  facilite grandement l'acceptation de nouveaux canaux entrants par les utilisateurs, mais cela signifie aussi que les canaux ne peuvent
  être utilisés que dans une seule direction au départ---Alice peut payer Bob ou router des paiements via Bob, mais Alice ne peut pas
  recevoir de paiements de Bob ni d'aucun chemin de routage incluant Bob tant qu'Alice n'a pas envoyé de l'argent à Bob. Cela crée un
  problème d'amorçage : si Alice veut recevoir des paiements via LN, elle doit amener des gens à ouvrir de nouveaux canaux vers son
  nœud---ce qui exige qu'ils paient des frais de transaction onchain et attendent des confirmations onchain pouvant prendre des heures.

  Une solution proposée à ce problème consiste à autoriser des canaux financés par les deux parties. Alice accepte de mettre 0,1 BTC dans un
  canal avec Bob si Bob accepte d'ouvrir le canal avec 0,1 BTC de ses propres fonds. Cela peut coûter de l'argent à Bob---à savoir les frais
  de transaction onchain et le coût d'opportunité d'avoir ses fonds immobilisés pendant un certain temps---mais Bob reçoit aussi la
  possibilité de gagner des frais de routage LN pour tous les paiements envoyés à Alice.

  L'implémentation de base du financement bilatéral est probablement simple (les nœuds LN gèrent déjà les paiements bidirectionnels) mais la
  création d'un mécanisme d'incitation capable de récompenser les fournisseurs de capital comme Bob fait encore l'objet de discussions. Pour
  plus d'informations, voir les fils suivants : [1][neigut liquidity], [2][zmn liquidity], [3][zmn dual rbf]. Voir aussi la section sur la
  *publicité de la liquidité des nœuds* dans le [Bulletin #21][].

- **Splicing :** vous ne pouvez actuellement pas augmenter le solde maximal d'un canal ni envoyer onchain une partie des fonds du canal à
  une autre personne sans fermer tout le canal et en ouvrir un autre entre les mêmes parties. Fermer un canal et en ouvrir un autre
  nécessite d'arrêter complètement tous les paiements entre les deux parties jusqu'à ce qu'un nombre approprié de confirmations onchain
  aient été reçues pour la transaction de fermeture et réouverture.

  Le splicing apporte une solution où les parties créent de façon coopérative une transaction onchain qui ajoute ou soustrait des fonds au
  canal. Lors de l'ajout de fonds (splicing in), les fonds précédemment dans le canal peuvent continuer à être utilisés offchain sans
  interruption pendant que les nouveaux fonds sont confirmés. Lors de la dépense de fonds onchain (splicing out), les fonds restants peuvent
  aussi continuer à être utilisés offchain sans interruption tandis que le destinataire onchain ne voit aucune différence avec une
  transaction normale. Cela permet à l'interface du portefeuille de faire des fonds dans le canal une partie du solde total disponible à
  dépenser dans les transactions onchain afin que les utilisateurs n'aient pas à gérer manuellement séparément les soldes offchain et
  onchain. <span id="multipath-splicing-ux">Combiné aux paiements multi-chemins qui permettent de mélanger dans les paiements des fonds
  provenant de plusieurs canaux, cela simplifie grandement la dépense : les utilisateurs cliqueront simplement sur un lien, examineront la
  facture, puis cliqueront sur *Payer*---laissant le portefeuille utiliser automatiquement n'importe quelle partie de son solde disponible
  pour un paiement onchain ou un paiement offchain en utilisant n'importe quel nombre de chemins.</span>

  Pour plus d'informations, voir les fils suivants : [1][zmn splicing cut-through], [2][pickhardt bolt splicing], [3][russell splicing].
  Voir aussi la nouvelle concernant le *splicing de canaux* dans le [Bulletin #17][].

- **Wumbo :** par accord entre les premières implémentations LN, actuellement la capacité de chaque canal est limitée par défaut à environ
  0,168 BTC (environ 40 $ USD au moment de la définition ; actuellement environ 750 $). Cela a été [choisi][russell why limit] pour aider à
  empêcher les utilisateurs de placer trop d'argent dans des logiciels encore non éprouvés.

  Plusieurs années plus tard, LN a significativement mûri et certains participants veulent signaler qu'ils sont prêts à ouvrir des canaux de
  plus grande valeur. La proposition de spécification 1.1 permettra à ces participants de définir un bit nommé « wumbo » (jumbo) pour
  indiquer leur volonté d'accepter des canaux plus grands et des paiements dans les canaux plus importants.

  Pour plus d'informations, voir les fils suivants : [1][zmn describing wumbo], [2][zmn global wumbo]. À titre de référence étymologique, le
  nom wumbo semble provenir d'un [segment][youtube wumbo] du dessin animé Bob l'éponge où un « M » est interprété comme signifiant Mini, est
  inversé en « W », et redéfini comme signifiant wumbo.

- **Destinations cachées :** les paiements LN routent actuellement les paiements en utilisant une méthode en oignon similaire à l'envoi de
  données vers un nœud de sortie Tor. Alice veut finalement payer Zed, alors elle trouve un chemin jusqu'à lui via Bob, Charlene et Dan.
  Pour empêcher les intermédiaires d'apprendre autre chose que les deux canaux qu'ils routent (par ex. Charlene connaît Bob et Dan), Alice
  chiffre chaque étape du chemin de sorte que seule l'étape suivante soit révélée à chaque destinataire. Quand Zed reçoit finalement le
  paiement, il peut simplement renvoyer la préimage de succès à Dan, qui la renvoie à Charlene, et ainsi de suite jusqu'à Alice.

  Cependant, Tor dispose aussi d'un mode service caché où à la fois l'expéditeur et le destinataire choisissent chacun une partie du chemin
  afin que ni l'un ni l'autre ne puissent déterminer exactement d'où les paquets sont venus ou où ils sont allés---offrant une
  confidentialité nettement améliorée. Cette proposition pour LN reflète ce mode. Alice choisira toujours Bob, Charlene et Dan, mais Zed
  peut empêcher Alice d'en apprendre davantage sur ses routes en choisissant Edmond, Fran et George. Zed fournit à Alice des informations
  sur la manière de trouver Edmond---mais les informations sur Fran, George et le propre nœud de Zed sont chiffrées afin qu'Alice ne puisse
  pas les voir. Cela peut permettre à des canaux cachés---une fonctionnalité actuelle de plusieurs implémentations LN---de rester cachés
  même lors du routage de paiements provenant de dépensiers arbitraires.

  Cette fonctionnalité est aussi appelée routage rendez-vous. Pour plus d'informations, voir la [description][lnrfc rz] sur le wiki de
  documentation du protocole LN. Voir également les fils de la liste de diffusion suivants : [1][cjp rz], [2][zmn rz], [3][zmn rz
  packetswitch].

Bien qu'ils aient été discutés au sommet, les objectifs proposés pour la 1.1 n'abordent pas directement les *watchtowers* qui aident à
protéger les canaux des utilisateurs qui sont actuellement hors ligne, les *autopilots* qui aident les utilisateurs à ouvrir leurs canaux de
paiement initiaux, ni la *génération déterministe de préimages* qui permet aux clés privées de rester hors ligne tandis qu'un composant en
ligne se contente de compléter l'acceptation des paiements. Ce sont des services qui peuvent être construits au-dessus du protocole et ne
nécessitent donc actuellement aucune coordination entre les implémentations.

## Nouvelles

{% comment %}<!-- math for first sub-bullet:
exp(-45/9) # 45 minute block, 9 minute avg interval exp(-45/12) # 45 minute block, 12 minute avg interval

The reason long interblock periods become more common at a faster rate than average interblock times increase is because the variance for
independent events is the square of the average.

-->{% endcomment %}

- **Production de blocs ralentie, frais accrus :** comme cela a été largement rapporté, plusieurs mineurs et pools de minage produisent des
  blocs pour des forks concurrents de Bitcoin Cash alors qu'ils pourraient probablement gagner davantage en créant des blocs pour Bitcoin.
  C'est probablement la cause de la réduction d'environ 7 % de la difficulté de Bitcoin sur la période de réajustement se terminant vendredi
  (UTC) et cela peut signifier des diminutions supplémentaires du taux de hachage et de la difficulté de Bitcoin pendant une durée inconnue.
  Les conséquences pertinentes pour les entreprises Bitcoin incluent :

  - *Temps de confirmation plus lents :* le temps moyen entre les blocs peut augmenter modérément jusqu'à 11 ou 12 minutes et la probabilité
    qu'il y ait une longue attente entre les blocs augmentera significativement en pourcentage relatif (par ex. avec des intervalles moyens
    de blocs historiquement typiques de 9 minutes, environ 0,7 % des blocs prennent plus de 45 minutes ; avec un intervalle de 12 minutes,
    2,3 % prennent plus de 45 minutes). Recommandation : les utilisateurs de Bitcoin sont déjà familiers avec des retards occasionnels
    importants, donc aucune action n'est probablement nécessaire.

  - *Frais possiblement accrus :* un temps plus long entre la découverte des blocs signifie moins d'espace pour les transactions, ce qui
    peut entraîner une hausse des frais. Les longues attentes occasionnelles entre les blocs tendent aussi à créer des pics soudains de
    frais qui peuvent persister pendant des heures ensuite. Recommandation : assurez-vous que votre estimation des frais fonctionne
    correctement et envisagez de préparer toutes les mesures de réduction des frais que vous êtes prêt à utiliser comme le traitement par
    lots des paiements.

  - *Revenus accrus pour les mineurs maximisant leur profit :* les mineurs ne profitent pas seulement de l'augmentation des frais, mais à
    chaque fois que la difficulté de Bitcoin s'ajuste à la baisse, le minage devient plus rentable pour les mineurs Bitcoin (toutes choses
    égales par ailleurs). Recommandation : faites les calculs concernant la réactivation de mineurs légèrement anciens et l'overclocking des
    mineurs actuels. Avec la récente baisse du prix, cela peut au contraire signifier que vous n'avez pas besoin d'éteindre un mineur qui
    aurait autrement été non rentable à exploiter.

  - *Fin soudaine possible :* il est possible qu'un grand ensemble de mineurs idéologiques produisant des blocs pour Bitcoin Cash reviennent
    tous miner la chaîne la plus rentable à peu près au même moment. Combiné à toute baisse passée de difficulté, cela pourrait produire une
    série de blocs Bitcoin avec un temps moyen entre les blocs plus court que la normale. Cela effacera probablement tout arriéré modéré et
    permettra aux frais de retomber à leurs minimums par défaut. Recommandation : envisagez de vous préparer à effectuer des [consolidations
    d'entrées][input consolidations] réduisant les frais si les frais retombent à leurs minimums.

- **Discussion sur le protocole Lightning :** plus de 75 e-mails ont été publiés sur la liste de diffusion Lightning-Dev au cours de la
  semaine passée, représentant presque 10 % du trafic de la liste sur les 365 derniers jours. Beaucoup des fils poursuivent des
  conversations commencées lors du sommet des développeurs du protocole. Si vous êtes intéressé par le développement du protocole Lightning,
  nous vous suggérons de lire chacun des [fils][ln threads] de ce mois.

- **LND entre en cycle de publication pour la version 0.5.1 :** les utilisateurs expérimentés de l'implémentation LND peuvent souhaiter
  tester cette préversion afin d'aider à trouver d'éventuels problèmes de dernière minute avant la publication finale de cette mise à jour
  de maintenance.

## Nouvelles d'Optech

- **Deuxième atelier Optech tenu à Paris :** comme annoncé dans le [Bulletin #12][], nous avons tenu notre deuxième atelier à Paris la
  semaine dernière. Il y avait 24 ingénieurs de sociétés Bitcoin et de projets open source présents, et nous avons eu d'excellentes
  discussions sur les descripteurs de portefeuille, les Partially Signed Bitcoin Transactions (PSBTs), l'intégration Lightning, taproot, la
  sélection de pièces et l'augmentation des frais. Un immense merci à Ledger pour l'accueil et l'aide à l'organisation.

  Si vous travaillez dans une entreprise membre et avez des demandes ou suggestions pour de futurs événements Optech (tels que le lieu, le
  site, les dates, le format, les sujets, ou toute autre chose), veuillez [nous contacter][optech email]. Nous sommes là pour aider nos
  entreprises membres !

## Changements notables dans le code

*Changements notables dans le code cette semaine dans [Bitcoin Core][bitcoin core repo], [LND][lnd repo], [C-lightning][core lightning
repo], et [libsecp256k1][libsecp256k1 repo].*

- [C-Lightning #2075][] ajoute la prise en charge des plugins. Comme leur [documentation][cl plugin] le décrit, « les plugins sont un moyen
  simple mais puissant d'étendre les fonctionnalités fournies par c-lightning. Ce sont des sous-processus qui sont démarrés par le démon
  principal `lightningd` et peuvent interagir avec `lightningd` de diverses manières. » À l'heure actuelle, les plugins peuvent ajouter des
  options en ligne de commande au processus principal, mais il est prévu qu'ils puissent ajouter de nouvelles commandes JSON-RPC, recevoir
  des événements, et insérer du code à appeler par des hooks dans le processus principal. Un plugin `helloworld` écrit en Python est fourni
  avec C-Lightning à titre d'exemple.

- [Bitcoin Core #14411][] Le RPC [listtransactions][rpc listtransactions] voit son paramètre de filtre partiellement rétabli, ce qui permet
  de récupérer une liste des transactions envoyées vers des adresses ou scripts ayant un libellé particulier. Cela a été rétroporté vers la
  branche 0.17 sous la forme de [PR #14441][Bitcoin Core #14441] et devrait être distribué dans la prochaine version de maintenance.

- [LND #2124][] ajoute une autre portion essentielle de la prise en charge des watchtowers, en particulier la capacité de détecter qu'un
  attaquant a effectué une tentative onchain de voler l'un des utilisateurs de la watchtower. La watchtower peut utiliser les informations
  de la transaction onchain pour déchiffrer une transaction de remède à une violation précédemment fournie par la victime afin à la fois
  d'annuler l'attaque et de pénaliser l'attaquant en réclamant tous les fonds que l'attaquant possédait légitimement dans le canal. Dans
  l'implémentation actuelle, la watchtower reçoit un pourcentage des fonds récupérés pour la compenser de sa surveillance diligente. Cette
  fusion est une extension des PR [#1535][LND #1535] et [#1512][LND
  #1512] décrites dans le [Bulletin #19][] et constitue une étape majeure vers
  une LN plus sûre pour les utilisateurs quotidiens.

## Remerciements particuliers

Nous remercions Christian Decker, practicalswift et René Pickhardt pour avoir fourni des suggestions ou répondu à des questions liées au
contenu de ce bulletin. Toute erreur restante est entièrement de la faute de l'auteur du bulletin.

{% include references.md %}
{% include linkers/issues.md issues="2075,14411,2124,1535,1512,14441" %}

[ln threads]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/thread.html
[roasbeef amp]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-February/000993.html
[zmn base amp]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001577.html
[pickhardt local amp]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001626.html
[neigut liquidity]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001532.html
[zmn liquidity]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001555.html
[zmn dual rbf]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001631.html
[zmn splicing cut-through]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-April/001153.html
[pickhardt bolt splicing]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-June/001322.html
[russell splicing]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-October/001434.html
[russell why limit]: https://medium.com/@rusty_lightning/bitcoin-lightning-faq-why-the-0-042-bitcoin-limit-2eb48b703f3
[youtube wumbo]: https://www.youtube.com/watch?v=--hsVknT1c0
[zmn describing wumbo]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001596.html
[zmn global wumbo]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001576.html
[cjp rz]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001498.html
[zmn rz]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001547.html
[zmn rz packetswitch]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001553.html
[cl plugin]: https://github.com/ElementsProject/lightning/blob/master/doc/PLUGINS.md
[rusty wrapup]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001569.html
[ln1.1 outline]: https://github.com/lightningnetwork/lightning-rfc/wiki/Lightning-Specification-1.1-Proposal-States
[input consolidations]: https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#Consolidation
[lnrfc rz]: https://github.com/lightningnetwork/lightning-rfc/wiki/Rendez-vous-mechanism-on-top-of-Sphinx
[bulletin #21]: /fr/newsletters/2018/11/13/#publicite-de-la-liquidite-des-noeuds
[bulletin #17]: /fr/newsletters/2018/10/16/#proposition-de-splice-pour-les-canaux-de-paiement-du-lightning-network
[bulletin #12]: /fr/newsletters/2018/09/11/#atelier
[bulletin #19]: /fr/newsletters/2018/10/30/#lnd-1535-1512
