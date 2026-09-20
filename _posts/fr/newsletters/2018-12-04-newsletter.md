---
title: 'Bulletin Hebdomadaire Bitcoin Optech #24'
permalink: /fr/newsletters/2018/12/04/
name: 2018-12-04-newsletter-fr
slug: 2018-12-04-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit une proposition pour ajuster la politique de relais de Bitcoin Core pour les transactions liées afin
d'aider à simplifier les frais onchain pour les paiements LN, mentionne des réunions à venir à propos du protocole LN, et décrit brièvement
une nouvelle version de LND ainsi que les travaux vers une version de maintenance de Bitcoin Core.

## Action à entreprendre

- Bitcoin Core se prépare pour la prochaine [version de maintenance][maintenance release] 0.17.1. Les versions de maintenance incluent des corrections de bugs
  et des rétroportages de fonctionnalités mineures. Toute personne prévoyant d'adopter cette version est encouragée à examiner la liste des
  [correctifs rétroportés][0.17.1 milestone] et à aider aux tests lorsqu'une version candidate sera mise à disposition.

## Nouvelles

- **Exception CPFP :** afin de dépenser des bitcoins, la transaction dans laquelle vous avez reçu ces bitcoins doit être ajoutée à la chaîne
  de blocs quelque part avant votre transaction de dépense. Cet ajout peut se trouver dans un bloc précédent ou plus tôt dans le même bloc
  que la transaction de dépense. Cette exigence du protocole signifie qu'une transaction de dépense avec un taux de frais élevé peut, par
  moyennage, rendre rentable le minage de sa transaction parente non confirmée même si cette parente a un faible taux de frais. Cela
  s'appelle Child Pays For Parent (CPFP).

  Le CPFP fonctionne même pour plusieurs transactions descendantes, mais plus il y a de relations à prendre en compte, plus le nœud met de
  temps à créer le modèle de bloc le plus rentable possible sur lequel les mineurs peuvent travailler. Pour cette raison, Bitcoin Core
  limite[^fn-cpfp-limits] le nombre maximal et la taille maximale des transactions liées. Pour les utilisateurs qui augmentent les frais de
  leurs propres transactions, les limites sont suffisamment élevées pour rarement poser problème. Mais pour les utilisateurs de protocoles
  multipartites, une contrepartie malveillante peut exploiter ces limites pour empêcher un utilisateur honnête de pouvoir augmenter les
  frais d'une transaction. Cela peut être un problème majeur pour des protocoles comme LN qui reposent sur des timelocks---si une
  transaction n'est pas confirmée avant l'expiration du timelock, la contrepartie peut reprendre une partie ou la totalité des fonds qu'elle
  avait précédemment payés.

  Pour aider à résoudre ce problème, Matt Corallo a [suggéré][carve out thread] une modification de la politique CPFP afin de réserver une
  partie de l'espace pour une petite transaction qui n'a qu'un seul ancêtre dans le mempool (tous ses autres ancêtres doivent déjà se
  trouver dans la chaîne de blocs). Cela accompagne une proposition pour LN décrite dans la section *Nouvelles* du [bulletin de la semaine
  dernière][] où LN ignorerait en grande partie les frais onchain (sauf pour les fermetures coopératives de canaux) et utiliserait
  l'augmentation de frais par CPFP pour choisir les frais lorsque le canal serait fermé---réduisant la complexité et améliorant la sécurité.
  Cependant, pour rendre cela sûr pour LN quel que soit le niveau des frais, les nœuds doivent également prendre en charge le relais de
  paquets de transactions comprenant à la fois des ancêtres à faible taux de frais et des descendants à taux de frais élevé d'une manière
  qui n'amène pas les nœuds à rejeter automatiquement les transactions antérieures comme étant trop bon marché et donc à ne pas voir les
  augmentations de frais ultérieures. Alors que la politique d'exception est probablement facile à mettre en œuvre, le relais de paquets est
  quelque chose qui est discuté depuis longtemps sans être encore formellement spécifié ni implémenté.

- **Organisation des efforts de spécification de LN 1.1 :** bien que les développeurs du protocole LN aient décidé [sur quels efforts][ln1.1
  accepted proposals] ils veulent travailler pour la prochaine version majeure du protocole commun, ils travaillent encore à développer et à
  se mettre d'accord sur les spécifications exactes de ces protocoles. Rusty Russell organise des réunions pour aider à accélérer le
  processus de spécification et a commencé un [fil de discussion][ln spec meetings] demandant des retours sur le média à utiliser pour la
  réunion (Google Hangout, réunion IRC, autre chose) et sur le niveau de formalisme à donner à la réunion. Il est recommandé à toute
  personne prévoyant de participer au processus de surveiller au moins ce fil de discussion.

- **Versions :** [LND 0.5.1][] est publiée comme nouvelle version mineure avec des améliorations particulièrement axées sur sa prise en
  charge de Neutrino, un mode portefeuille léger (SPV) avec lequel LND peut fonctionner pour effectuer des paiements LN sans avoir à
  utiliser directement un nœud complet. Cette version corrige également un bug de comptabilité pour les utilisateurs du backend btcwallet où
  tous les paiements de monnaie à soi-même n'étaient pas forcément reflétés dans le solde affiché. Lors de la mise à niveau, une réanalyse
  de la chaîne de blocs sera effectuée afin que les informations comptables manquantes soient récupérées et que votre solde correct soit
  affiché. Aucun fonds n'était à risque, ils n'étaient simplement pas correctement suivis.

  Le projet Bitcoin Core prévoit de commencer bientôt à marquer des versions candidates pour la [version de maintenance][maintenance
  release] 0.17.1. On s'attend à ce que cela résolve certains bugs d'incompatibilités avec le système de compilation sur des distributions
  Linux récentes ainsi que d'autres [problèmes mineurs][0.17.1 milestone].

[LND 0.5.1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.5.1-beta

## Changements notables dans le code

*Changements notables dans le code cette semaine dans [Bitcoin Core][bitcoin core repo], [LND][lnd repo], [C-lightning][core lightning
repo], et [libsecp256k1][libsecp256k1 repo].*

- [LND #1937][] stocke le message de rétablissement de canal le plus récent dans la base de données du nœud afin qu'il puisse être renvoyé
  même après qu'un canal a été fermé. Cela améliore les chances du nœud de se rétablir après un problème de connectivité combiné à une perte
  partielle de données.

- [Bitcoin Core #14477][] ajoute un nouveau champ `desc` aux RPC `getaddressinfo`, `listunspent` et `scantxoutset` avec le [descripteur de
  script de sortie][output script descriptors] pour chaque adresse lorsque le portefeuille dispose de suffisamment d'informations pour
  considérer cette adresse comme *solvable*. Une adresse est solvable lorsqu'un programme en sait suffisamment sur son scriptPubKey, son
  redeemScript optionnel et son witnessScript optionnel afin que le programme puisse générer une entrée non signée dépensant des fonds
  envoyés à cette adresse. Un nouveau champ `solvable` est ajouté au RPC `getaddressinfo` pour indiquer indépendamment que le portefeuille
  sait comment résoudre cette adresse.

  Les nouveaux champs `desc` ne devraient pas être particulièrement utiles pour le moment car ils ne peuvent actuellement être utilisés
  qu'avec le RPC `scantxoutset`, mais ils fourniront un moyen compact de fournir toutes les informations nécessaires pour rendre des
  adresses solvables à de futurs RPC de Bitcoin Core et à des RPC améliorés tels que ceux utilisés pour les interactions entre portefeuilles
  hors ligne/en ligne (froids/chauds), portefeuilles multisig, implémentations coinjoin, et autres cas.

- [LND #2081][] ajoute des RPC qui permettent de signer un modèle de transaction où certaines entrées sont contrôlées par LND. Bien que cet
  outil particulier reflète des fonctionnalités déjà fournies par le service `lnwallet.Signer`, le mécanisme utilisé pour activer ce nouveau
  service permet aux développeurs d'étendre les RPC (gRPC) fournis via LND avec des gRPC fournis par un autre code sur la machine locale ou
  même par un service distant. Plusieurs nouveaux services supplémentaires utilisant ce mécanisme sont prévus dans un futur proche.

## Notes de bas de page

[^fn-cpfp-limits]: Limites de profondeur des ancêtres et descendants de Bitcoin Core :

    ```text
    $ bitcoind -help-debug | grep -A3 -- -limit
      -limitancestorcount=<n>
           Do not accept transactions if number of in-mempool ancestors is <n> or
           more (default: 25)

      -limitancestorsize=<n>
           Do not accept transactions whose size with all in-mempool ancestors
           exceeds <n> kilobytes (default: 101)

      -limitdescendantcount=<n>
           Do not accept transactions if any ancestor would have <n> or more
           in-mempool descendants (default: 25)

      -limitdescendantsize=<n>
           Do not accept transactions if any ancestor would have more than <n>
           kilobytes of in-mempool descendants (default: 101).
    ```

{% include references.md %}
{% include linkers/issues.md issues="1937,14477,2081" %}

[maintenance release]: https://bitcoincore.org/en/lifecycle/#maintenance-releases
[bulletin de la semaine dernière]: /en/newsletters/2018/11/27/#simplified-fee-bumping-for-ln
[carve out thread]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-November/016518.html
[ln1.1 accepted proposals]: https://github.com/lightningnetwork/lightning-rfc/wiki/Lightning-Specification-1.1-Proposal-States
[ln spec meetings]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001673.html
[0.17.1 milestone]: https://github.com/bitcoin/bitcoin/milestone/39?closed=1
[output script descriptors]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
