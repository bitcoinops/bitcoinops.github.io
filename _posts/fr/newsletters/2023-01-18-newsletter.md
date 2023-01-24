---
title: 'Bulletin Hebdomadiare Bitcoin Optech #234'
permalink: /fr/newsletters/2023/01/18/
name: 2023-01-18-newsletter-fr
slug: 2023-01-18-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit une proposition de nouveaux opcodes
spécifiques aux coffres-forts et comprend nos sections habituelles avec
des résumés de mises à jour intéressantes des clients et des services,
des annonces de nouvelles versions et de versions candidates, et des
descriptions de changements significatifs dans les logiciels
d'infrastructure Bitcoin les plus répandus.

## Nouvelles

- **Proposition de nouveaux opcodes spécifiques aux coffre-forts :** James O'Beirne
  [a publié][obeirne op_vault] sur la liste de diffusion Bitcoin-Dev une [proposition][obeirne paper]
  pour un soft fork visant à ajouter deux nouveaux opcodes, `OP_VAULT` et `OP_UNVAULT`.

    - `OP_VAULT` accepterait trois paramètres : un engagement envers
      un chemin de dépenses hautement fiable, un [période de retard][topic timelocks],
      et un engagement envers un chemin de dépenses moins fiable.

    - `OP_UNVAULT` accepterait également trois paramètres. Lorsqu'il est
      utilisé pour les coffres-forts envisagés par O'Beirne, il s'agirait
      du même engagement envers un chemin de dépense hautement fiable,
      de la même période de retard, et d'un engagement envers une ou
      plusieurs sorties à inclure dans une transaction ultérieure.

    Pour créer un [coffre-fort][topic vaults], Alice choisit un chemin de dépense
    hautement fiable, tel qu'une signature multiple nécessitant l'accès à plusieurs
    dispositifs de signature distincts ou à des portefeuilles de stockage à froid
    dans des endroits différents. Elle choisit également un chemin de dépense moins
    fiable, tel qu'une signature unique à partir de son portefeuille chaud habituel.
    Enfin, elle choisit une période de retard spécifiée en utilisant le même type
    de données que [BIP68][], ce qui permet de déterminer des périodes allant de
    quelques minutes à environ un an. Une fois ses paramètres sélectionnés, Alice
    crée une adresse Bitcoin normale pour recevoir des fonds dans son coffre-fort,
    cette adresse étant engagée dans un script utilisant `OP_VAULT`.

    Pour dépenser les fonds précédemment reçus à son adresse de coffre-fort,
    Alice commence par déterminer les sorties qu'elle souhaite finalement payer
    (par exemple, envoyer un paiement à Bob et renvoyer la monnaie dans son coffre-fort).
    Dans une utilisation typique, Alice remplit les conditions de son chemin de
    dépense moins fiable, comme la fourniture d'une signature de son porte-monnaie
    virtuel, pour créer une transaction qui paie tous les fonds du coffre-fort à
    une seule sortie. Cette sortie contient `OP_UNVAULT` avec les mêmes paramètres
    pour le chemin de dépense de confiance et le délai. Le troisième paramètre est
    un engagement envers les sorties qu'Alice veut finalement payer. Alice termine
    la construction de la transaction---y compris la fixation des frais en utilisant
    le [parrainage des frais][topic fee sponsorship], un type de [sortie d'ancrage][topic anchor outputs],
    ou un autre mécanisme.

    Alice diffuse sa transaction et celle-ci est ensuite incluse dans un bloc. Cela permet
    à n'importe qui de constater qu'une tentative de déblocage est en cours. Le logiciel
    d'Alice détecte qu'il s'agit d'une dépense de ses fonds mis en coffre et vérifie que
    le troisième paramètre de la sortie `OP_UNVAULT` de la transaction confirmée correspond
    exactement à l'engagement qu'Alice a créé plus tôt. En supposant que cela corresponde,
    Alice attend maintenant la fin du délai, après quoi elle peut diffuser une transaction
    qui dépense depuis l'UTXO `OP_UNVAULT` vers les sorties pour lesquelles elle s'est
    engagée plus tôt (par exemple, Bob et une sortie de changement). Il s'agirait d'une
    dépense réussie des fonds d'Alice en utilisant le chemin le moins sûr, par exemple en
    utilisant uniquement son portefeulle chaud.

    Cependant, imaginons que le logiciel d'Alice voit la tentative de déverrouillage confirmée
    et ne la reconnaît pas. Dans ce cas, son logiciel a la possibilité, pendant la période
    de retard, de geler les fonds. Il crée une transaction dépensant la sortie `OP_UNVAULT`
    à l'adresse de confiance qui a fait l'objet des engagements précédents. Tant que cette
    transaction de gel est confirmée avant la fin de la période de retard, les fonds d'Alice
    sont protégés contre la compromission de son chemin de dépense moins fiable. Après que les
    fonds ont été transférés vers le chemin de dépense hautement fiable d'Alice, Alice peut
    les dépenser à tout moment en satisfaisant les conditions de ce chemin (par exemple,
    en utilisant ses portefeuilles froids).

    En plus de proposer les nouveaux opcodes, O'Beirne décrit également la motivation pour
    les coffres et analyse d'autres propositions de coffres, y compris celles qui sont
    disponibles sur Bitcoin maintenant en utilisant des transactions présignées et celles
    qui dépendraient d'autres propositions de soft fork avec des [conditions de dépenses][topic covenants].
    Plusieurs avantages décrits de la proposition `OP_VAULT` incluent :

    - *Des témoins plus petits :* Les propositions de conditions de dépenses flexibles,
      telles que celles qui utilisent le [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] proposé,
      exigeraient que les témoins de transaction pour les transactions non-déverrouillées
      incluent des copies d'une quantité significative de données déjà présentes ailleurs
      dans la transaction, ce qui gonfle la taille et le coût des frais de ces transactions.
      `OP_VAULT` exige que beaucoup moins de données de script et de témoin soient
      incluses dans la chaîne.

    - *Moins d'étapes pour les dépenses :* Les propositions de conditions
      de dépenses moins flexibles et les coffres-forts disponibles aujourd'hui
      basés sur des transactions présignées exigent de retirer des fonds à
      une adresse prédéterminée avant qu'ils puissent être envoyés à une
      destination finale. Ces propositions exigent aussi généralement que
      chaque sortie reçue soit dépensée dans une transaction distincte des
      autres sorties reçues, ce qui empêche l'utilisation du
      [regroupement des paiements][topic payment batching]. Cela augmente
      le nombre de transactions impliquées, ce qui gonfle également la taille
      et le coût des dépenses.

      `OP_VAULT` nécessite moins de transactions lors de la dépense d'une seule
      sortie dans les cas typiques et il supporte également le regroupement
      de transsactions lors de la dépense ou du gel de plusieurs sorties,
      ce qui permet potentiellement d'économiser une grande quantité d'espace
      et de permettre aux coffres de recevoir beaucoup plus de transactions
      avant que leurs sorties ne doivent être consolidées pour des raisons
      de sécurité.

    Lors d'une discussion sur l'idée, Greg Sanders a proposé (comme [résumé par O'Beirne][obeirne scripthash])
    une construction légèrement différente qui "permettrait à toutes les sorties
    dans les cycles de vie du coffre-fort d'être compatible [P2TR][topic taproot],
    par exemple, ce qui dissimulerait le fonctionnement du coffre-fort---une
    fonctionnalité très intéressante".

    Par ailleurs, Anthony Towns [note][towns op_vault] que la proposition permet
    à l'utilisateur d'un coffre-fort de geler ses fonds à tout moment en dépensant
    simplement les fonds à l'adresse du chemin de dépense hautement fiable, ce qui
    permet à l'utilisateur de dégeler ses fonds plus tard. Le propriétaire du
    coffre-fort y trouve son compte, car il n'a pas besoin d'accéder à des clés
    spécialement sécurisées, comme un portefeuille froid, pour bloquer une tentative
    de vol. Cependant, tout tiers qui connaît l'adresse peut également geler les fonds
    de l'utilisateur (bien qu'il doive payer des frais de transaction pour le faire),
    ce qui constitue un inconvénient pour l'utilisateur. Étant donné que de nombreux
    portefeuilles légers divulguent leurs adresses à des tiers afin de localiser leurs
    transactions onchain, les coffres-forts construits sur ces portefeuilles pourraient
    involontairement donner à des tiers la possibilité de gêner les utilisateurs des
    coffres-forts. Towns suggère une construction alternative pour la condition de gel
    qui nécessiterait de fournir un élément supplémentaire d'information non privée afin
    d'initier un gel, préservant les avantages du schéma mais réduisant également le
    risque qu'un portefeuille donne inutilement à des tiers la possibilité de geler
    des fonds et de gêner l'utilisateur. Towns suggère également une amélioration possible
    de la prise en charge des regroupements de transactions et des modèles taproot.

    Plusieurs réponses ont également mentionné que `OP_UNVAULT` peut fournir plusieurs
    des caractéristiques de la proposition [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV),
    y compris les avantages pour les [DLC][topic dlc] précédemment décrits dans
    le [Bulletin #185][news185 ctv-dlc], bien qu'à un coût plus élevé sur la chaîne
    que l'utilisation directe de CTV.

    La discussion était toujours active au moment de la rédaction de cet article.

## Changements principaux dans le code et la documentation

*Dans cette rubrique mensuelle, nous mettons en évidence les mises à jour
intéressantes des portefeuilles et services Bitcoin.*

- **Kraken annonce l'envoi à des adresses taproot :**
  Dans un récent [article de blog][kraken bech32m], Kraken a annoncé
  qu'il prenait en charge le retrait (envoi) vers les adresses [bech32m][topic bech32].

- **Annonce de la bibliothèque client rust de Whirlpool coinjoin :**
  Le [Samourai Whirlpool Client][whirlpool rust client] est une bibliothèque rust
  permettant d'interagir avec la plateforme Whirlpool [coinjoin][topic coinjoin]

- **Ledger supporte le miniscript :**
  La version 2.1.0 du micrologiciel Bitcoin de Ledger pour ses dispositifs
  de signature matérielle prend en charge le [miniscript][topic miniscript],
  comme annoncé [précédemment][ledger miniscript].

- **Le portefeuille de Liana a été lancé :**
  La première version du porte-monnaie Liana a été [annoncée][liana blog].
  Le portefeuille prend en charge les portefeuilles singlesig avec une clé
  de récupération [timelocked][topic timelocks]. Les plans futurs du projet
  incluent l'implémentation de [taproot][topic taproot], des portefeuilles
  à multiples signatures, et des fonctionnalités multi-signatures à
  décroissance temporelle.

- **Electrum 4.3.3 a été mis à jour :**
  [Electrum 4.3.3][electrum 4.3.3] contient des améliorations pour Lightning,
  [PSBTs][topic psbt], les clés de signaturesmatériels,
  et le système de construction.

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets
d'infrastructure Bitcoin. Veuillez envisager de passer aux nouvelles
versions ou d'aider à tester les versions candidates.*

- [HWI 2.2.0][] est une version de cette application permettant aux
  portefeuilles logiciels de s'interfacer avec des dispositifs de
  signature matérielle. Elle ajoute la prise en charge des dépendances
  de chemins de clés [P2TR][topic taproot] en utilisant le dispositif
  de signature matérielle BitBox02 parmi d'autres fonctionnalités et
  corrections de bogues.

## Changements principaux dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], et [Lightning BOLTs][bolts repo].*

- [Core Lightning #5751][] supprime la prise en charge de la création de nouvelles
  adresses segwit enveloppées par P2SH.

- [BIPs #1378][] ajoute [BIP324][] pour le [protocole de transport crypté P2P version V2][topic v2 p2p transport].

{% include references.md %}
{% include linkers/issues.md v=2 issues="5751,1378" %}
[hwi 2.2.0]: https://github.com/bitcoin-core/HWI/releases/tag/2.2.0
[obeirne op_vault]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-January/021318.html
[obeirne paper]: https://jameso.be/vaults.pdf
[obeirne scripthash]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-January/021329.html
[news185 ctv-dlc]: /en/newsletters/2022/02/02/#improving-dlc-efficiency-by-changing-script
[towns op_vault]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-January/021328.html
[kraken bech32m]: https://blog.kraken.com/post/16740/bitcoin-taproot-address-now-supported-on-kraken/
[whirlpool rust client]: https://github.com/straylight-orbit/whirlpool-client-rs
[ledger miniscript]: https://blog.ledger.com/miniscript-is-coming/
[liana blog]: https://wizardsardine.com/blog/liana-announcement/
[electrum 4.3.3]: https://github.com/spesmilo/electrum/blob/4.3.3/RELEASE-NOTES
