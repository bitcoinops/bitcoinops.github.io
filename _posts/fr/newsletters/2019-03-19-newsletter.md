---
title: 'Bulletin Hebdomadaire Bitcoin Optech #38'
permalink: /fr/newsletters/2019/03/19/
name: 2019-03-19-newsletter-fr
slug: 2019-03-19-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine donne une mise à jour sur la suppression prévue des messages de rejet BIP61 de Bitcoin Core, renvoie vers des
discussions supplémentaires à propos de SIGHASH_NOINPUT_UNSAFE, analyse certaines nouvelles fonctionnalités de l'explorateur de chaîne de
blocs Esplora, fournit des informations sur une liste mise à jour de bannissement de nœuds, et renvoie vers des vidéos des présentations de
la récente MIT Bitcoin Club Expo. Sont également fournis une nouvelle section hebdomadaire sur l'adoption de la prise en charge de l'envoi
bech32 et la liste habituelle des changements notables dans les projets d'infrastructure Bitcoin populaires.

{% include references.md %}

## Mesures à prendre

- **Aidez à tester Bitcoin Core 0.18.0 RC2&nbsp;:** le deuxième Release Candidate (RC) pour la prochaine version majeure de Bitcoin Core a
  été [publié][0.18.0]. Des tests sont encore nécessaires de la part des organisations et des utilisateurs expérimentés qui prévoient
  d'exécuter la nouvelle version de Bitcoin Core en production. Utilisez [ce ticket][Bitcoin Core #15555] pour signaler vos retours.

## Nouvelles

- **Messages de rejet BIP61&nbsp;:** comme résumé dans le [bulletin de la semaine dernière][le bulletin #37], plusieurs développeurs se sont
  plaints que les messages de rejet [BIP61][] soient désactivés par défaut dans la future version 0.18.0 de Bitcoin Core, d'autant plus que
  cela n'a été annoncé que peu de temps avant cette publication prévue. Les développeurs de Bitcoin Core ont [discuté][core dev irc] de la
  question et ont décidé de réactiver BIP61 par défaut pour la version 0.18.0, tout en le décrivant comme obsolète dans les notes de
  version. Ils prévoient de le désactiver par défaut dans la 0.19.0 (attendue aux alentours d'octobre 2019) et potentiellement de le
  supprimer à ce moment-là ou plus tard.

- **Migration des listes de diffusion&nbsp;:** comme annoncé sur chaque liste, les listes de diffusion [bitcoin-dev][bdev mv] et
  [lightning-dev][ldev mv] vont prochainement migrer vers le service d'hébergement de discussions [Groups.io][]. Les listes resteront
  utilisables à leurs adresses actuelles jusqu'à la fin de la migration, moment auquel les abonnés devraient recevoir une notification. Si
  vous ne souhaitez pas que Groups.io apprenne vos informations d'abonné, vous devriez vous désabonner des listes immédiatement. Vous n'avez
  pas besoin de créer un compte groups.io pour le moment.

- **Davantage de discussions à propos de SIGHASH_NOINPUT_UNSAFE&nbsp;:** Anthony Towns a lancé un nouveau [fil][noinput thread] sur la
  manière de s'assurer que le mode sighash noinput proposé soit difficile à mal utiliser de façons pouvant entraîner une perte de fonds.
  Noinput peut permettre une couche alternative d'application onchain pour LN, mieux adaptée aux canaux avec plusieurs participants,
  permettant au final qu'un plus grand nombre de canaux soient ouverts dans la même quantité d'espace de bloc. Towns décrit un scénario du
  pire raisonnablement plausible dans lequel l'échec à garantir la sécurité de noinput met en danger l'adoption d'autres fonctionnalités de
  protocole précieuses. Pour éviter cela, il propose des raffinements à des idées antérieures sur le marquage des sorties (voir [le bulletin
  #34][]) ainsi qu'une nouvelle alternative qui exigerait que chaque transaction avec une signature utilisant noinput contienne aussi une
  signature n'utilisant pas noinput. Cela empêcherait des tiers d'exécuter des attaques par rejeu avec des transactions noinput, mais cela
  signifierait que l'utilisation la plus efficace de taproot ne pourrait pas être employée et entraînerait donc des tailles de transaction
  modérément plus grandes lorsque noinput serait utilisé.

- **Mise à jour d'Esplora&nbsp;:** Nadav Ivgi a [annoncé][ivgi twitter] une mise à jour de cet explorateur open source de chaîne de blocs.
  (Voir notre couverture de sa sortie initiale dans le [Bulletin #25][le bulletin #25].) Les transactions non confirmées sont maintenant
  affichées avec une estimation du temps qu'il leur faudra pour être confirmées compte tenu des conditions actuelles du réseau, ou un
  avertissement de surpaiement si elles paient plus que nécessaire pour être confirmées rapidement. Plus notable encore, la vue détaillée
  des transactions confirmées comme non confirmées fournit une analyse des fonctionnalités et anti-fonctionnalités utilisées ou omises dans
  la transaction. Par exemple&nbsp;: utilisation de segwit, réutilisation d'adresse, précision incohérente des sorties, correspondance avec
  une [heuristique d'entrée inutile][uih2], types de script d'entrée/sortie incohérents, et transactions sans change.

  Après avoir vu les nouveaux changements, Ryan Havar a soulevé des préoccupations [sur Reddit][havar reddit] à propos du taux
  potentiellement élevé de faux positifs dans les avertissements de confidentialité, ce qui l'a conduit à ouvrir un [ticket][havar github]
  sur le GitHub d'Esplora à propos du problème. En essayant de répondre à ces préoccupations, Ivgi a entamé une [conversation][esplora
  convo] avec plusieurs développeurs de Bitcoin Core. Les défenseurs de la vie privée voudront peut-être examiner cette conversation, qui a
  couvert des sujets tels que&nbsp;:

  - Gregory Maxwell et Pieter Wuille pensent que Bitcoin Core correspondrait occasionnellement à l'Heuristique d'Entrée Inutile #2 (UIH2)
    depuis la sortie de Bitcoin 0.1 en 2009, avec une fréquence croissante dans les versions plus récentes, rendant cette heuristique moins
    utile qu'hypothétisé pour distinguer les services commerciaux des portefeuilles d'utilisateurs finaux.

  - Les mises à jour de la sélection de pièces de Bitcoin Core au cours des deux dernières versions lui permettent de produire fréquemment
    des transactions sans sorties de change. Ces transactions sont plus efficaces et préservent mieux la vie privée que les transactions
    avec change, mais Esplora les affiche actuellement en rouge comme des transactions qui divulguent la vie privée parce qu'elles
    correspondent aussi au schéma d'un utilisateur utilisant une fonctionnalité d'"envoi max" pour envoyer tous ses bitcoins d'un
    portefeuille vers un autre portefeuille ou une plateforme d'échange.

  - Maxwell a proposé qu'un ajout utile à l'analyse de confidentialité serait d'identifier quand un utilisateur contrôle plusieurs UTXOs
    reçus à la même adresse mais n'envoie qu'une transaction dépensant un sous-ensemble de ces UTXOs. Ce comportement permet de relier des
    transactions ultérieures dépensant ces UTXOs à la transaction antérieure, détruisant la vie privée.

  Dans l'ensemble, il est formidable de voir des développeurs construire des outils qui aident les gens à identifier les défauts dans leur
  logiciel ou leur comportement, mais il est aussi important de prendre en compte la manière dont les utilisateurs interagiront avec
  l'outil. Comme l'a dit Wuille vers la fin de la conversation&nbsp;: "Je suis très heureux qu'il existe maintenant un explorateur correct
  pour déboguer ce genre de choses, mais je crains qu'on le présente comme un véritable outil de production. Je sais que les gens
  utiliseront des explorateurs, et qu'un explorateur qui donne de bonnes informations vaut mieux qu'un explorateur qui embrouille tout.
  Mais, vraiment, nous ne devrions pas encourager son utilisation. Si cette fonctionnalité de détection de la confidentialité pousse les
  gens à aller consulter toutes leurs transactions à cause d'une sorte de gamification du type 'oooh voyons comment ma transaction s'en est
  sortie ici&nbsp;?!', c'est probablement globalement négatif. [...] La chose la plus importante à afficher sur un explorateur de blocs
  est&nbsp;: 'Avertissement&nbsp;: rechercher vos propres adresses sur un explorateur de blocs divulgue votre vie privée à l'opérateur du
  site'."

- **Liste de bannissement de nœuds espions mise à jour&nbsp;:** certaines adresses IP effectuent diverses attaques qui visent probablement à
  surveiller la propagation des transactions afin d'essayer de déterminer quels nœuds ont émis quelles transactions. Pour aider les
  opérateurs de nœuds à refuser les connexions provenant de ces adresses IP, Gregory Maxwell maintient une liste de bannissement qui peut
  être importée dans Bitcoin Core et les nœuds compatibles. Il n'est absolument pas nécessaire d'utiliser cette liste centralisée---votre
  nœud entièrement décentralisé tentera de se connecter à un ensemble de pairs suffisamment diversifié pour qu'il puisse établir au moins
  une connexion honnête---mais utiliser cette liste de bannissement peut réduire la quantité de trafic que vous gaspillez sur des nœuds
  espions et autres acteurs malveillants. La liste est fournie en deux formats, l'un à utiliser en ligne de commande avec
  [bitcoin-cli][banlist cli] et l'autre pouvant être collé dans la console de débogage de l'[interface graphique de Bitcoin Core][banlist
  gui]. Les adresses IP mises sur liste noire sont bannies pendant un an et Bitcoin Core se souviendra des bannissements entre les
  redémarrages, vous n'avez donc besoin d'importer la liste qu'une seule fois. Note&nbsp;: certains utilisateurs ont signalé que la liste de
  bannissement peut dépasser la taille maximale du tampon pour l'interface graphique sur certaines plateformes, nécessitant de la coller par
  morceaux d'environ 250 entrées chacun afin de charger toute la liste.

- **Vidéos de la MIT Bitcoin Club 2019 Expo disponibles&nbsp;:** une série de présentations de l'exposition d'il y a deux semaines a été
  divisée en [vidéos][mit vids] individuelles et téléversée sur YouTube. Nous avons entendu dire que beaucoup de ces présentations étaient
  excellentes, alors envisagez de parcourir la liste de lecture pour les sujets qui vous semblent intéressants.

## Prise en charge de l'envoi vers bech32

*Semaine 1 sur 24*

{% include specials/bech32/01-intro.md %}

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [LND][lnd repo], [C-Lightning][c-lightning repo],
[Eclair][eclair repo], [libsecp256k1][libsecp256k1 repo], et [Bitcoin Improvement Proposals (BIPs)][bips repo].*

- [LND #2022][] permet la création de "hold invoices". Il s'agit de factures LN standard qui sont traitées différemment lorsqu'un paiement
  est reçu. Au lieu que le receveur retourne immédiatement la préimage de paiement afin de réclamer les fonds payés, le receveur retarde
  cela jusqu'au maximum autorisé par le timelock du paiement. Cela permet au receveur d'accepter ou de rejeter le paiement après avoir
  appris que l'argent est disponible. Par exemple, Alice pourrait générer automatiquement des hold invoices sur son site web mais attendre
  qu'un client ait réellement payé avant de chercher dans son inventaire l'article demandé. Cela lui donnerait une chance d'annuler le
  paiement si elle ne pouvait pas livrer. D'autres cas d'utilisation sont fournis dans la description principale de la PR.

- [LND #2618][] implémente la plupart du code nécessaire à une version initiale de la prise en charge du client watchtower qui permettra à
  un nœud LND de s'apparier avec une watchtower privée et de lui envoyer des sauvegardes d'état chiffrées. La watchtower peut alors
  surveiller la chaîne de blocs pour détecter les tentatives de violation du contrat de canal et soumettre des transactions de remède à la
  violation (justice) qui empêchent la partie honnête de perdre des fonds. Voir les sections sur les changements notables dans le code de
  nos bulletins précédents pour une couverture des commits implémentant les changements watchtower côté serveur&nbsp;: [#7][le bulletin #7],
  [#19][le bulletin #19], [#22][le bulletin #22], et [#30][le bulletin #30].

- [C-Lightning #2342][] ajoute une nouvelle RPC `setchannelfee` qui permet à l'utilisateur de définir individuellement les taux de frais
  pour chacun de ses canaux.

{% include linkers/issues.md issues="2022,2618,2342,15555" %}
[esplora convo]: http://www.erisian.com.au/bitcoin-core-dev/log-2019-03-08.html#l-53
[havar github]: https://github.com/Blockstream/esplora/issues/51
[mit vids]: https://www.youtube.com/user/MITBitcoinClub/videos
[0.18.0]: https://bitcoincore.org/bin/bitcoin-core-0.18.0/
[noinput thread]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-March/016766.html
[ivgi twitter]: https://twitter.com/shesek/status/1103320174936109057
[uih2]: https://gist.github.com/AdamISZ/4551b947789d3216bacfcb7af25e029e#gistcomment-2796539
[havar reddit]: https://old.reddit.com/r/Bitcoin/comments/ay1b0e/new_update_for_blockstreaminfo_is_out_fee_privacy/ehy77cn/
[banlist cli]: https://people.xiph.org/~greg/banlist.cli.txt
[banlist gui]: https://people.xiph.org/~greg/banlist.gui.txt
[core dev irc]: http://www.erisian.com.au/meetbot/bitcoin-core-dev/2019/bitcoin-core-dev.2019-03-14-19.00.log.html#l-53
[ldev mv]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-March/001915.html
[bdev mv]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-March/016785.html
[groups.io]: https://groups.io/
[le bulletin #37]: /en/newsletters/2019/03/12/#removal-of-bip61-p2p-reject-messages
[le bulletin #34]: /en/newsletters/2019/02/19/#discussion-about-tagging-outputs-to-enable-restricted-features-on-spending
[le bulletin #25]: /fr/newsletters/2018/12/11/#explorateur-de-blocs-moderne-publie-en-open-source
[le bulletin #7]: /fr/newsletters/2018/08/07/#lnd-1543
[le bulletin #19]: /fr/newsletters/2018/10/30/#lnd-1535-1512
[le bulletin #22]: /fr/newsletters/2018/11/20/#lnd-2124
[le bulletin #30]: /en/newsletters/2019/01/22/#lnd-2448
