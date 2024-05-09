---
title: 'Bulletin Hebdomadaire Bitcoin Optech #296'
permalink: /fr/newsletters/2024/04/03/
name: 2024-04-03-newsletter-fr
slug: 2024-04-03-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume les discussions sur une nouvelle initiative pour un soft fork
de nettoyage du consensus et annonce un plan pour choisir des éditeurs BIP supplémentaires d'ici la
fin de la semaine. Sont également incluses nos sections habituelles avec
des annonces de mises à jour et versions candidates, ainsi que les changements
apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Revisiter le nettoyage du consensus :** Antoine Poinsot a [posté][poinsot cleanup] sur Delving
  Bitcoin concernant la révision de la proposition de [nettoyage du consensus][topic consensus
  cleanup] de Matt Corallo de 2019 (voir le [Bulletin #36][news36 cleanup]). Il commence par tenter de
  quantifier le pire cas de plusieurs problèmes que la proposition pourrait résoudre, incluant : la
  capacité de créer un bloc qui peut prendre plus de 3 minutes à vérifier sur un ordinateur portable
  moderne et 90 minutes sur un Raspberry Pi 4 ; la capacité pour les mineurs de voler la subvention et
  de rendre LN insécurisé en utilisant l'[attaque par manipulation temporelle][topic time warp] avec
  environ un mois de préparation ; la capacité de tromper les clients légers en acceptant de fausses
  transactions ([CVE-2017-12842][topic cves]) et de confondre les nœuds complets en rejetant des blocs
  valides (voir le [Bulletin #37][news37 trees]).

  En plus des préoccupations ci-dessus issues de la proposition originale de nettoyage du consensus de
  Corallo, Poinsot suggère de s'attaquer au problème restant des [transactions dupliquées][topic
  duplicate transactions] qui commencera à affecter les nœuds complets au bloc 1,983,702 (et affecte
  déjà les nœuds de testnet).

  Tous les problèmes ci-dessus ont des solutions techniquement simples qui peuvent être déployées dans
  un soft fork. La solution précédemment proposée pour les blocs à vérification lente était légèrement
  controversée étant donné qu'elle aurait pu théoriquement rendre invalides certains scripts que les
  gens auraient pu utiliser avec des transactions pré-signées, violant potentiellement la politique de
  développement d'[évitement de confiscation][topic accidental confiscation] (voir le [Bulletin
  #37][news37 confiscation]). Nous ne sommes pas au courant d'une utilisation réelle d'un tel script,
  soit dans les 10 ans où Bitcoin existait avant la proposition originale de nettoyage du consensus,
  soit dans les 5 années depuis, bien que certains types d'utilisation seraient impossibles à détecter
  jusqu'à ce qu'une transaction pré-signée soit diffusée.

  Pour répondre à la préoccupation, Poinsot a proposé que les règles de consensus mises à jour
  s'appliquent uniquement aux sorties de transactions créées après une certaine hauteur de bloc.
  Toutes les sorties créées avant cette hauteur seraient encore dépensables selon les anciennes
  règles.

- **Choisir de nouveaux éditeurs BIP :** Mark "Murch" Erhardt a poursuivi le [fil][erhardt bip
  editors] sur l'ajout de nouveaux éditeurs BIP en proposant que tout le monde exprime "leurs
  arguments pour et contre tout candidat dans ce fil jusqu'à vendredi fin de journée (5 avril). Si des
  candidats trouvent un large soutien, ces candidats pourraient être ajoutés comme nouveaux éditeurs
  au dépôt le lundi suivant (8 avril)."

  La discussion était en cours au moment de la rédaction et nous ferons de notre mieux pour rapporter
  les résultats dans le bulletin de la semaine prochaine.

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets
d'infrastructure Bitcoin. Veuillez envisager de passer aux nouvelles
versions ou d'aider à tester les versions candidates.*

- [Bitcoin Core 26.1][] est une version de maintenance de l'implémentation principale du nœud
  complet du réseau. Ses [notes de version][26.1 rn] décrivent plusieurs corrections de bugs.

- [Bitcoin Core 27.0rc1][] est un candidat à la version pour la prochaine version majeure de
  l'implémentation principale du nœud complet du réseau. Les testeurs sont encouragés à examiner la
  liste des [sujets de test suggérés][bcc testing].

- [HWI 3.0.0-rc1][] est un candidat à la version pour la prochaine version de ce package fournissant
  une interface commune à plusieurs dispositifs de signature matérielle différents.

## Changements notables dans le code et la documentation

_Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo],
[Lightning BOLTs][bolts repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana
repo]._

*Note : les commits sur Bitcoin Core mentionnés ci-dessous s'appliquent à sa branche de
développement principale et donc ces changements ne seront probablement pas publiés avant environ
six mois après la sortie de la version à venir 27.*

- [Bitcoin Core #27307][] commence à suivre le txid des transactions dans le mempool qui entrent en
  conflit avec une transaction appartenant au portefeuille intégré de Bitcoin Core. Cela inclut les
  transactions dans le mempool qui entrent en conflit avec un ancêtre d'une transaction de
  portefeuille. Si une transaction en conflit est confirmée, la transaction du portefeuille ne peut
  pas être incluse sur cette blockchain, il est donc très utile de connaître les conflits. Les
  transactions du mempool en conflit sont maintenant affichées dans un nouveau champ
  `mempoolconflicts` lors de l'appel de `gettransaction` sur la transaction du portefeuille. Les
  entrées d'une transaction en conflit dans le mempool peuvent être réutilisées sans abandonner
  manuellement la transaction en conflit et sont comptées dans le solde du portefeuille.

- [Bitcoin Core #29242][] introduit des fonctions utilitaires pour comparer deux [Diagramme
  de taux de frais][sdaftuar incentive compatibility] et pour évaluer la compatibilité incitative du
  remplacement de clusters par jusqu'à deux transactions. Ces fonctions jettent les bases pour le
  [package][topic package relay] [replace-by-fee][topic rbf] avec des clusters de taille jusqu'à deux
  incluant les transactions [Topologically Restricted Until Confirmation (TRUC)][TRUC BIP draft]
  (alias [transactions v3][topic v3 transaction relay]).

- [Core Lightning #7094][] supprime plusieurs fonctionnalités qui étaient précédemment dépréciées en
  utilisant le nouveau système de dépréciation de Core Lightning (voir le [Bulletin #288][news288 cln
  deprecation]).

- [BDK #1351][] apporte plusieurs changements à la manière dont BDK interprète le paramètre
  `stop_gap`, qui contrôle son comportement de [limite de gap][topic gap limits]. Un changement en
  particulier tente de correspondre au comportement dans d'autres portefeuilles où une limite de
  `stop_gap` de 10 entraînera BDK à continuer de générer de nouvelles adresses pour la recherche de
  transactions jusqu'à ce que 10 adresses consécutives aient été générées sans trouver de transactions
  correspondantes.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}{%
include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="27307,29242,7094,1351" %}
[bitcoin core 26.1]: https://bitcoincore.org/bin/bitcoin-core-26.1/
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/27.0-Release-Candidate-Testing-Guide
[Bitcoin Core 27.0rc1]: https://bitcoincore.org/bin/bitcoin-core-27.0/test.rc1/
[poinsot cleanup]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710
[news36 cleanup]: /en/newsletters/2019/03/05/#cleanup-soft-fork-proposal
[news37 confiscation]: /en/newsletters/2019/03/12/#cleanup-soft-fork-proposal-discussion
[erhardt bip editors]: https://gnusha.org/pi/bitcoindev/52a0d792-d99f-4360-ba34-0b12de183fef@murch.one/
[sdaftuar incentive compatibility]: https://delvingbitcoin.org/t/mempool-incentive-compatibility/553
[TRUC BIP draft]: https://github.com/bitcoin/bips/pull/1541
[news288 cln deprecation]: /fr/newsletters/2024/02/07/#core-lightning-6936
[26.1 rn]: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-26.1.md
[HWI 3.0.0-rc1]: https://github.com/bitcoin-core/HWI/releases/tag/3.0.0-rc.1
[news37 trees]: /en/newsletters/2019/03/12/#bitcoin-core-vulnerability-disclosure
