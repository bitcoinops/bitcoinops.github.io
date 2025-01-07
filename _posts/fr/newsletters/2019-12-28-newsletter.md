---
title: 'Bulletin Hebdomadaire Bitcoin Optech #78 : Revue Spéciale Année 2019'
permalink: /fr/newsletters/2019/12/28/
name: 2019-12-28-newsletter-fr
slug: 2019-12-28-newsletter-fr
type: newsletter
layout: newsletter
lang: fr

excerpt: >
  Cette édition spéciale du Bulletin Optech résume les développements notables
  de Bitcoin tout au long de l'année 2019.
---
{{page.excerpt}} C'est la suite de notre [résumé de 2018][].

{% comment %}
  ## Commits
  $ for d in bitcoin/ c-lightning/ eclair/ lnd/ secp256k1/ bips/ lightning-rfc/ ; do
    cd $d ; git log --oneline --since=2019-01-01 upstream/master | wc -l ; cd -
  done | numsum
  8863

  ## Merges
  $ for d in bitcoin/ c-lightning/ eclair/ lnd/ secp256k1/ bips/ lightning-rfc/ ; do
    cd $d ; git log --oneline --merges --since=2019-01-01 upstream/master | wc -l ; cd -
  done | numsum
  1988

  ## Posts sur la liste de diffusion
  $ for d in .lists.bitcoin-devel/ .lists.lightning/ ; do
    find $d -type f | xargs -i sed -n '1,/^$/p' '{}' | grep '^Date: .* 2019 ' | wc -l
  done | numsum
  1529

  ## Mots du bulletin ; diviser par 350 pour obtenir les pages
  #
  ## Remarque, n'inclus pas ce résumé
  $ cd _posts/fr/newsletters   # fin italique_
  $ find 2019-* | xargs wc -w | tail -n1   # fin italique*
  72450 total
{% endcomment %}

Ce résumé est largement basé sur nos [bulletins d'information hebdomadaire][] de l'année dernière pour lesquels
nous avons examiné près de 9 000 commits (près de 2 000 fusions), plus de 1 500 messages sur la
liste de diffusion, de nombreuses milliers de lignes de logs IRC, et de nombreuses autres sources
publiques. Il nous a fallu 50 numéros de bulletin et plus de 200 pages imprimées de contenu pour
résumer tout ce travail incroyable à l'origine. Même alors, nous avons manqué de nombreuses
contributions importantes, en particulier de la part des personnes corrigeant des bugs, rédigeant
des tests, effectuant des revues et fournissant un soutien---un travail critique mais pas
nécessairement "digne d'être mentionné". En résumant encore plus et en essayant de compresser toute
l'année dans les quelques pages de cet article, nous avons maintenant également omis de nombreuses
autres contributions importantes.

Donc, avant de continuer, nous tenons à exprimer nos sincères remerciements à tous ceux qui ont
contribué à Bitcoin en 2019. Même si le résumé suivant ne vous mentionne pas ou l'un de vos projets,
sachez que nous chez Optech---et probablement tous les utilisateurs de Bitcoin---sommes plus
reconnaissants que les mots ne peuvent l'exprimer pour tout ce que vous avez fait pour aider
Bitcoin.

## Contenu

* Janvier
    * [BIP127 preuve des réserves](#bip127)
* Février
    * [Bitcoin Core compatible avec HWI](#core-hwi)
    * <a href="#miniscript">Miniscript</a>
* Mars
    * [Proposition de soft-fork de nettoyage du consensus](#cleanup)
    * <a href="#signet">Signet</a>
    * [Lightning Loop](#loop)
* Avril
    * <a href="#assumeutxo">AssumeUTXO</a>
    * [Paiements Trampoline](#trampoline)
* Mai
    * <a href="#taproot">Taproot</a>
    * [SIGHASH_ANYPREVOUT](#anyprevout)
    * [OP_CHECKTEMPLATEVERIFY](#ctv)
* Juin
    * [Erlay et autres améliorations du relais P2P](#erlay-and-other-p2p-improvements)
    * <a href="#watchtowers">Watchtowers</a>
* Juillet
    * [Compilations reproductibles](#reproducibility)
* Août
    * [Coffres-forts sans covenants](#vaults)
* Septembre
    * <a href="#snicker">SNICKER</a>
    * [Vulnérabilité LN](#ln-cve)
* Octobre
    * [Sorties d'ancrage LN](#anchor-outputs)
* Novembre
    * <a href="#bech32-mutability">Mutabilité Bech32</a>
    * [Suppression d'OpenSSL de Bitcoin Core](#openssl)
    * [Suppression de BIP70 de Bitcoin Core](#bip70)
* Décembre
    * [Paiements multipath](#multipath)
* Résumés en vedette
    * [Principales versions de projets d'infrastructure populaire](#releases)
    * [Conférences techniques remarquables et autres événements](#conferences)
    * [Bitcoin Optech](#optech)
    * [Nouvelles solutions d'infrastructure open source](#new-infrastructure)

## Janvier

{:#bip127}
En janvier, Steven Roose a [proposé][roose reserves] un format standardisé
pour les pseudo-transactions de *preuve de réserves* que les gardiens de bitcoins peuvent
utiliser pour générer des preuves qu'ils contrôlent un certain nombre de bitcoins.
Aucun outil de ce type ne peut garantir que les déposants pourront retirer leurs bitcoins d'un
gardien, mais cela peut rendre plus difficile pour un gardien de dissimuler la
perte ou le vol de bitcoins. Roose allait ensuite produire un [outil][news33
reserves] basé sur les Transactions Bitcoin Partiellement Signées ([PSBTs][topic
psbt]) pour créer des preuves de réserves et verrait la
spécification publiée en tant que [BIP127][].

## Février

{:#core-hwi}
En février, la branche de développement principale de Bitcoin Core a vu la fusion de
l'ensemble final de PR nécessaires pour l'utiliser avec l'[interface de portefeuille matériel
(HWI)][topic hwi] Python et l'outil en ligne de commande. HWI
verrait plus tard sa première version stable en mars, Wasabi Wallet ajouterait
son support en [avril][wasabi hwi], et BTCPay ajouterait son support via
un [package annexe][btcpayserver.vault] en novembre. HWI facilite
l'interaction entre les portefeuilles matériels et logiciels en utilisant une
combinaison de [descripteurs de script de sortie][topic descriptors] et les
Transactions Bitcoin Partiellement Signées ([PSBTs][topic psbt]). Le
soutien croissant en 2019 pour des formats et des API standardisés rend plus
facile pour les utilisateurs de choisir la bonne combinaison de solutions matérielles et
logicielles pour leurs besoins plutôt que de devoir choisir une
solution ou une autre.

<div markdown="1" id="miniscript">

Également en février, Pieter Wuille a donné une [présentation][wuille sbc
miniscript] lors de la [Stanford Blockchain Conference][] sur [miniscript][topic miniscript], une
déclinaison de son travail sur les descripteurs de script de sortie. Miniscript fournit une
représentation structurée des scripts Bitcoin qui simplifie l'analyse automatisée par des logiciels.
L'analyse peut déterminer quelles données un portefeuille doit fournir pour satisfaire le script
(par exemple, une signature ou une préimage de hachage), combien de données de transaction seront
utilisées par le script et les données qui le satisfont, et si le script respecte ou non les règles
de consensus connues et les principales politiques de relais de transaction.

En plus de miniscript, Wuille, Andrew Poelstra et Sanket Kanjalkar ont également fourni un langage
de politique composite qui se compile en miniscript (qui se convertit lui-même en Bitcoin Script).
Avec le langage de politique, les utilisateurs peuvent facilement décrire les conditions qu'ils
souhaitent voir remplies pour dépenser leurs pièces. Lorsque plusieurs utilisateurs veulent partager
le contrôle d'une pièce, la composition du langage de politique facilite la combinaison des
politiques de signature de chaque utilisateur en un seul script.

Si largement adopté, miniscript pourrait faciliter la collaboration entre différents systèmes
Bitcoin pour signer une transaction, réduisant considérablement la quantité de code personnalisé à
écrire pour intégrer des interfaces de portefeuille, des nœuds LN, des systèmes de coinjoin, des
portefeuilles multisig, des portefeuilles matériels grand public, des modules de signature
matérielle industrielle (HSM) et d'autres logiciels et matériels.

Wuille et ses collaborateurs ont continué à travailler sur miniscript tout au long de l'année,
demandant ensuite des retours de la communauté et ouvrant une PR pour ajouter le support à Bitcoin
Core. Miniscript serait également utilisé par les développeurs LN en décembre pour analyser et
optimiser plusieurs nouveaux scripts pour des versions améliorées de certaines de leurs transactions
onchain.

</div>

## Mars

<div markdown="1" id="cleanup">

En mars, Matt Corallo a proposé le [soft fork de nettoyage du consensus][topic consensus cleanup]
pour éliminer les problèmes potentiels dans le code de consensus de Bitcoin. Si adoptées,
les corrections élimineraient l'[attaque de décalage temporel][], réduiraient l'[utilisation CPU maximale][]
du script hérité, rendraient le cache de validation des transactions plus fiable et élimineraient
une attaque connue (mais coûteuse) contre les [clients légers][news37 merkle tree
attacks].

Bien que certaines parties de la proposition (comme la correction du décalage temporel) semblaient
intéresser diverses personnes, d'autres parties de la proposition (comme les corrections pour
l'utilisation CPU maximale et le cache de validité) ont reçu certaines [critiques][news37 cleanup discussion].
Peut-être est-ce pour cette raison que la proposition n'a pas progressé de manière évidente vers sa mise en œuvre
dans la seconde moitié de l'année.

</div>

<div markdown="1" id="signet">

En mars également, Kalle Alm a demandé d'initer des retours sur [signet][topic signet], qui
deviendrait finalement [BIP325][]. Le protocole signet permet de créer des testnets où tous les
nouveaux blocs valides doivent être signés par une partie centralisée. Bien que cette centralisation
soit antithétique à Bitcoin, elle est idéale pour un testnet où les testeurs veulent parfois créer
un scénario perturbateur (comme une réorganisation de la chaîne) et d'autres fois veulent simplement
une plateforme stable pour tester l'interopérabilité des logiciels. Sur le testnet existant de
Bitcoin, les réorganisations et autres perturbations peuvent se produire fréquemment et pendant de
longues périodes, rendant les tests réguliers impraticable.

Signet évoluerait tout au long de l'année et serait finalement [intégré][cl signet] dans des logiciels tels que
C-Lightning, ainsi qu'utilisé pour une démonstration de [eltoo][]. Une [pull request][Bitcoin Core
#16411] ajoutant le support à Bitcoin Core reste ouverte.

</div>

{:#loop}
De plus, en mars, Lightning Labs a annoncé [Lightning Loop][], fournissant une solution non-custodiale
pour les utilisateurs qui souhaitent retirer une partie de leurs fonds d'un canal LN vers un UTXO
onchain sans fermer le canal. En juin, ils [mettraient à jour][loop-in] Loop pour permettre également aux
utilisateurs de dépenser un UTXO dans un canal existant. Loop utilise des contrats Hash Time Locked
(HTLC) similaires à ceux utilisés par les transactions régulières LN offchain, garantissant que
les fonds d'un utilisateur sont soit transférés comme prévu, soit que l'utilisateur reçoit un
remboursement de tous les coûts sauf les frais de transaction onchain. Cela rend Loop presque
entièrement sans confiance.

<div markdown="1" class="callout" id="releases">

### Résumé 2019 :<br>Principales versions de projets d'infrastructure populaires

- [C-Lightning 0.7][] publié en mars a ajouté un système de plugins qui serait largement utilisé à la
  fin de l'année. C'était également la première version de C-Lightning prenant en charge des [compilations
  reproductibles][topic reproducible builds] pour une sécurité accrue grâce à une meilleure auditabilité.

- [LND 0.6-beta][] publié en avril incluait le support des [sauvegardes de canal statiques (SCB)][lnd scb] qui
  aident les utilisateurs à récupérer des fonds réglés dans leurs canaux LN même s'ils ont perdu leur
  état de canal récent. La version comprenait également un autopilote amélioré pour aider les
  utilisateurs à ouvrir de nouveaux canaux, ainsi qu'une compatibilité intégrée avec [Lightning Loop][]
  pour déplacer des fonds onchain sans fermer un canal ou utiliser un gardien.

- [Bitcoin Core 0.18][] publié en mai a amélioré le support des transactions Bitcoin partiellement
  signées ([PSBT][topic psbt]) et ajouté le support des [descripteurs de script de sortie][topic descriptors].
  La combinaison de ces deux fonctionnalités lui a permis d'être utilisé avec la première version publiée de
  l'interface de portefeuille matériel ([HWI][]).

- [Eclair 0.3][] publié en mai a amélioré la sécurité des sauvegardes, ajouté le support des plugins et
  rendu possible l'exécution en tant que service caché Tor.

- [LND 0.7-beta][] publié en juillet a ajouté le support de l'utilisation d'une [tour de guet][topic watchtowers] pour
  protéger vos canaux lorsque vous êtes hors ligne.

- [LND 0.8-beta][] publié en octobre a ajouté le support d'un format en oignon plus extensible, amélioré
  la sécurité des sauvegardes et amélioré le support de la tour de guet.

- [Bitcoin Core 0.19][] publié en novembre a mis en œuvre la nouvelle politique de pool de mémoire [CPFP
  carve-out][topic cpfp carve out], ajouté un support initial pour les [filtres de blocs compacts][topic compact block
  filters] de style [BIP158][]
  (actuellement RPC uniquement), amélioré la sécurité en désactivant des protocoles tels que les
  filtres de bloom [BIP37][] et les demandes de paiement [BIP70][] par défaut. Il passe également les
  utilisateurs de GUI à des adresses bech32 par défaut.

- [C-Lightning 0.8][] publié en décembre a ajouté le support des [paiements multiparites][topic multipath payments]
  et a basculé son réseau par défaut de testnet vers le réseau principal.
  C'était également la première version majeure de
  C-Lightning à prendre en charge des bases de données alternatives, avec le support de postgresql
  disponible en plus du support par défaut de sqlite.

</div>

## Avril

{:#assumeutxo}
En avril, James O’Beirne a proposé [AssumeUTXO][topic assumeutxo], une méthode permettant aux nœuds
complets de différer la vérification de l'historique ancien de la chaîne de blocs en téléchargeant
et en utilisant temporairement une copie de confiance de l'ensemble UTXO récent. Cela permettrait
aux portefeuilles et autres logiciels utilisant le nœud complet de commencer à recevoir et à envoyer
des transactions en quelques minutes seulement après le démarrage du nœud, au lieu de devoir
attendre des heures ou des jours, comme c'est le cas actuellement pour un nœud nouvellement démarré.
AssumeUTXO propose que le nœud télécharge et vérifie l'historique ancien de la chaîne de blocs en
arrière-plan jusqu'à ce qu'il vérifie finalement son état UTXO initial, lui permettant d'obtenir
finalement la même sécurité sans confiance qu'un nœud qui n'utilise pas AssumeUTXO. O'Beirne
continuerait à travailler sur le projet tout au long de l'année, ajoutant progressivement [de
nouvelles fonctionnalités][dumptxoutset] et refactorisant le code existant sur la voie de l'objectif
d'ajouter finalement AssumeUTXO à Bitcoin Core.

<div markdown="1" id="trampoline">
Également en avril, Pierre-Marie Padiou a [proposé][trampoline proposed] l'idée de [paiements
trampoline][topic trampoline payments], une méthode permettant aux nœuds LN légers de sous-traiter
la recherche de chemin aux nœuds de routage lourds. Un nœud léger, tel qu'une application mobile,
pourrait ne pas suivre le graphe de routage LN complet, ce qui l'empêcherait de trouver des routes
vers d'autres nœuds. La proposition de Padiou permettrait au nœud léger de router le paiement vers
un nœud proche, puis de laisser ce nœud calculer le reste du chemin. En essence, le paiement
rebondirait sur le nœud trampoline en route vers sa destination. Pour ajouter de la confidentialité,
le dépensier original pourrait exiger que le paiement rebondisse sur plusieurs nœuds trampoline en
séquence afin que chacun d'eux ne sache pas s'il acheminait le paiement vers le destinataire final
ou simplement vers un autre nœud trampoline.

Un [PR][trampolines pr] ajoutant des fonctionnalités pour les paiements trampoline à la
spécification LN est actuellement ouvert et l'implémentation Eclair de LN a ajouté un [support
expérimental][exp tramp] pour le relais des paiements trampoline.

</div>

## Mai

<div markdown="1" id="taproot">

En mai, Pieter Wuille a proposé une [soft fork taproot][topic taproot] composée de [bip-taproot][]
et [bip-tapscript][] (qui dépendent tous deux de la proposition [bip-schnorr][] de l'année
dernière). Si elle est implémentée, ce changement permettra aux transactions single-sig, multisig et
de nombreux contrats d'utiliser tous le même style de scriptPubKeys. De nombreuses dépenses à partir
de multisigs et de contrats complexes auront également un aspect identique les unes aux autres
qu'aux dépenses single-sig. Cela peut améliorer considérablement la confidentialité des utilisateurs et
la fongibilité des pièces tout en réduisant la quantité d'espace de la chaîne de blocs utilisée par
les cas d'utilisation de multisig et de contrats.

Même dans les cas où les dépenses de multisig et de contrats ne peuvent pas tirer pleinement parti
de la confidentialité et des économies d'espace de taproot, elles pourraient quand même ne devoir
mettre qu'un sous-ensemble de leur code onchain, leur offrant plus de confidentialité et
d'économies d'espace qu'elles n'en ont aujourd'hui. En plus de taproot, [tapscript][topic tapscript]
apporte des améliorations mineures à la structure de Bitcoin en capacités de script,
principalement en rendant plus facile et plus propre l'ajout de nouveaux opcodes à l'avenir.

Les propositions ont fait l'objet de discussions et d'examens importants tout au long de l'année,
notamment à travers une série de [sessions d'examen de groupe][taproot review]  organisées par
Anthony Towns qui ont vu plus de 150 personnes s'inscrire pour aider à l'examen.

</div>

<div markdown="1" id="anyprevout">

Towns a également proposé en mai deux nouveaux hachages de signature à utiliser en combinaison avec
tapscript, `SIGHASH_ANYPREVOUT` et `SIGHASH_ANYPREVOUTANYSCRIPT`. Un hachage de signature (sighash)
est le hachage des champs d'une transaction et des données associées auxquelles une signature
s'engage. Différents sighashes dans Bitcoin s'engagent à différentes parties d'une transaction,
permettant aux signataires de laisser éventuellement d'autres personnes apporter certaines
modifications à leurs transactions. Les deux nouveaux sighashes proposés fonctionnent de manière
similaire à [SIGHASH_NOINPUT][topic sighash_anyprevout] de [BIP118][]  en n'identifiant pas
délibérément quelle UTXO ils dépensent, permettant à la signature de dépenser n'importe quelle UTXO
dont elle peut satisfaire le script (par exemple, qui utilise la même clé publique).

L'utilisation principale suggérée pour les sighashs de type noinput est de permettre la couche de
mise à jour [eltoo][topic eltoo] précédemment proposée pour LN. Eltoo peut simplifier plusieurs
aspects de la construction et de la gestion des canaux ; il est particulièrement souhaitable pour
simplifier les [canaux impliquant plus de deux participants][topic channel factories] qui peuvent
réduire considérablement les coûts des canaux onchain.

</div>

<div markdown="1" id="ctv">

Un troisième soft fork proposé ce mois-ci est venu de Jeremy Rubin, qui a [décrit][coshv] un nouveau
opcode maintenant appelé `OP_CHECKTEMPLATEVERIFY` (CTV). Cela permettrait une forme limitée de
[contrats][topic covenants] où une sortie d'une transaction nécessiterait qu'une transaction
ultérieure la dépensant contienne certaines autres sorties. Une utilisation suggérée pour cela
serait des engagements de paiements futurs où un dépensier paie une seule petite sortie qui ne peut être
dépensée que par une transaction (ou un arbre de transactions) qui paie ensuite des dizaines, des
centaines, voire des milliers de destinataires différents. Cela pourrait permettre de nouvelles
techniques pour améliorer la confidentialité de style coinjoin, soutenir des coffres-forts
renforçant la sécurité, ou gérer les coûts du dépensier lorsque les frais de transaction augmentent.

Rubin continuerait à travailler sur CTV pour le reste de l'année, y compris en ouvrant des PR
([1][Bitcoin Core #17268], [2][Bitcoin Core #17292]) pour des améliorations à des parties de Bitcoin
Core où des optimisations pourraient rendre un deploiement d'une version de CTV plus efficace.

</div>

<div markdown="1" class="callout" id="conferences">

### Résumé 2019 :<br>Conférences techniques notables et autres événements

- [Stanford Blockchain Conference][], janvier, Université de Stanford
- [MIT Bitcoin Expo][], mars, MIT
- [Optech Executive Briefing][], mai, New York City
- [Magical Crypto Friends (piste technique)][mcf], mai, New York City
- [Breaking Bitcoin][], juin, Amsterdam
- [Bitcoin Core developers meetup][coredevtech amsterdam], juin, Amsterdam
- [Edge Dev++][], septembre, Tel Aviv
- [Scaling Bitcoin][], septembre, Tel Aviv
- [Cryptoeconomic Systems Summit][], octobre, MIT

</div>

## Juin

<div markdown="1" id="erlay-and-other-p2p-improvements">

Gleb Naumenko, Pieter Wuille, Gregory Maxwell, Sasha Fedorova et Ivan Beschastnikh ont publié un
[article][erlay] sur [erlay][topic erlay], un protocole de relais d'annonces de transactions non
confirmées entre les nœuds qui utilise un ensemble basé sur [libminisketch][topic minisketch] pour
la réconciliation des ensembles, permettant une réduction estimée de 84 % de la bande passante des
annonces. L'article démontre également qu'erlay rendrait beaucoup plus pratique d'augmenter
significativement le nombre de connexions sortantes par défaut que les nœuds établissent. Cela
pourrait améliorer la résistance de chaque nœud aux [attaques d'éclipse][] qui pourraient le tromper
en acceptant des blocs ne faisant pas partie de la chaîne de blocs avec le plus de preuves de
travail. Plus de connexions sortantes améliorent également la résistance du nœud contre d'autres
attaques qui pourraient être utilisées pour suivre ou retarder les paiements provenant du nœud. Le
travail sur erlay se poursuivrait tout au long de l'année avec des recherches supplémentaires et la
proposition de [BIP330][] pour le protocole de réconciliation des ensembles.

D'autres améliorations apportées cette année au relai P2P comprenaient les [améliorations de
confidentialité pour le relais de transactions][#14897] de Bitcoin Core (éliminant un problème
décrit dans l'article [TxProbe][] de Sergi Delgado-Segura et d'autres) et l'ajout de [deux
connexions sortantes supplémentaires][] utilisées uniquement pour le relais de nouveaux blocs,
améliorant la résistance contre les attaques d'éclipse.

</div>

<div markdown="1" id="watchtowers">

Après un travail préalable important, le mois de juin a également vu la [fusion][altruist
watchtowers] des [watchtowers LN altruistes][topic watchtowers] dans LND. Les watchtowers altruistes
ne reçoivent aucune récompense via le protocole pour aider à sécuriser les canaux de leurs clients,
donc un utilisateur doit exécuter son propre watchtower ou dépendre de la charité d'un opérateur de
watchtower, mais cela suffit à démontrer que les watchtowers peuvent envoyer de manière fiable des
transactions de pénalité au nom d'autres utilisateurs, garantissant que les utilisateurs qui se
déconnectent pendant de longues périodes ne perdent pas d'argent.

Les watchtowers altruistes seraient finalement publiés dans [LND 0.7.0-beta][lnd 0.7-beta] et
verraient un développement supplémentaire tout au long de l'année, y compris une [proposition de
spécification][watchtower spec] et une [discussion][eltoo watchtowers] sur la manière dont ils pourraient
être combinés avec des canaux de paiement de nouvelle génération tels que [eltoo][topic eltoo].

</div>

## Juillet

<div markdown="1" id="reproducibility">

En juillet, le projet Bitcoin Core a [fusionné][guix merge] le PR de Carl Dong ajoutant le support
des compilations reproductibles des binaires Linux de Bitcoin Core en utilisant GNU Guix (prononcé
"geeks"). Bien que Bitcoin Core ait depuis longtemps fourni un support pour des compilations
reproductibles en utilisant le système [Gitian][], il peut être difficile à mettre en place et
dépend de la sécurité de plusieurs centaines de packages Ubuntu. En comparaison, Guix peut être
beaucoup plus facile à installer et à exécuter, et les compilationss de Bitcoin Core l'utilisant dépendent
actuellement d'un nombre beaucoup plus restreint de packages. À long terme, les contributeurs à Guix
travaillent également à éliminer le problème de [confiance aveugle][] pour permettre aux
utilisateurs de vérifier facilement que les binaires tels que `bitcoind` sont dérivés uniquement du
code source vérifiable.

Le travail sur le support des compilations Guix a continué tout au long de l'année, certains contributeurs
espérant que Guix sera utilisé pour la première version majeure.
de Bitcoin Core publiée en 2020 (peut-être en parallèle avec l'ancien mécanisme basé sur Gitian).

Indépendamment, une documentation a été ajoutée cette année aux référentiels [C-Lightning][cl repro]
et [LND][lnd repro] décrivant comment créer des compilations reproductibles de leur logiciel en
utilisant des compilateurs de confiance.

</div>

## Août

<div markdown="1" id="vaults">

En août, Bryan Bishop a décrit une méthode pour implémenter des [coffres-forts sur Bitcoin sans
utiliser de covenants][]. *Coffres-forts* est un terme utilisé pour décrire un script qui limite la
capacité d'un attaquant de voler des fonds même s'il obtient la clé privée normale d'un utilisateur.
Un *[covenant][topic covenants]* est un script qui ne peut être dépensé que pour certains autres
scripts. Il n'existe pas de moyen connu de créer des covenants en utilisant le langage de script
Bitcoin actuel, mais il s'avère qu'ils ne sont pas nécessaires si les utilisateurs sont prêts à
exécuter du code qui effectue quelques étapes supplémentaires lors du dépôt de leur argent dans le
contrat de coffre-fort.

Plus notablement, Bishop a décrit une nouvelle faiblesse dans les propositions de coffres-forts
précédentes ainsi qu'une atténuation possible qui limiterait le montant maximum de fonds
pouvant être volés dans un coffre-fort par un attaquant. Le développement de coffres-forts pratiques
pourrait être utile tant pour les utilisateurs individuels que pour les grandes organisations de
garde telles que les échanges.

</div>

<div markdown="1" class="callout" id="optech">

### Résumé 2019<br>Bitcoin Optech

Au cours de la deuxième année d'Optech, nous avons accueilli six nouvelles entreprises membres,
organisé un [briefing exécutif][optech executive briefing] lors de la semaine de la blockchain à New
York, publié une [série de 24 semaines][bech32 sending support] promouvant le support de l'envoi en
bech32, ajouté une matrice de compatibilité des portefeuilles et des services à notre site web,
publié 51 [bulletins d'information hebdomadaire][]<!-- #28 à #78, inclus -->, vu plusieurs de nos
bulletins d'information et articles de blog traduits dans des langues telles que le
[japonais][xlation ja] et l'[espagnol][xlation es], créé un [index des sujets][], ajouté un chapitre
à notre [Workbook sur la scalabilité][], organisé deux [ateliers schnorr/taproot][] avec
des [notebooks jupyter][], et publié des rapports de terrain de [BTSE][] et [BRD][].

Nous avons de grands projets pour 2020, donc nous espérons que vous continuerez à nous suivre sur
[Twitter][], à vous abonner à notre [bulletin d'information hebdomadaire][], ou à suivre notre [RSS feed][].

</div>

## Septembre

<div markdown="1" id="snicker">

Adam Gibson a [proposé][snicker] une nouvelle forme de coinjoin non interactif pour le système
Bitcoin existant. Le protocole, appelé SNICKER, implique qu'un utilisateur sélectionne l'un de ses
UTXO et un UTXO sélectionné de manière aléatoire dans l'ensemble global des UTXO à dépenser dans la
même transaction. L'initiateur signe sa partie de cette transaction et la télécharge au
format Transaction Bitcoin Partiellement Signée ([PSBT][topic psbt]) sur un serveur public. Si
l'autre utilisateur vérifie le serveur et voit la PSBT, il peut la télécharger, la signer et la
diffuser, complétant ainsi le coinjoin sans que les deux utilisateurs aient besoin d'être en ligne
en même temps. L'initiateur peut créer et télécharger autant de PSBT qu'il le souhaite en
utilisant le même UTXO jusqu'à ce qu'un autre utilisateur accepte le coinjoin.

Les principaux avantages de SNICKER par rapport à d'autres approches de coinjoin sont qu'il ne
nécessite pas que les utilisateurs soient en ligne en même temps et qu'il devrait être facile
d'ajouter son support à n'importe quel portefeuille qui a déjà le support PSBT de [BIP174][], ce qui
est de plus en plus le cas pour de nombreux portefeuilles.

</div>

{:#ln-cve}
Également en septembre, les mainteneurs de C-Lightning, Eclair et LND ont [révélé][ln missed
validation] une vulnérabilité qui affectait les versions précédentes de leur logiciel. Il semblait
que, dans certains cas, chacune des implémentations ne confirmait pas que les transactions de
financement de canal qui payaient le script correct ou le montant correct (ou les deux). Si elle était
exploitée, cela pourrait entraîner l'impossibilité de confirmer les paiements de canal onchain,
rendant possible pour les nœuds de perdre de l'argent en relayant des paiements d'un canal invalide
à un canal valide. Optech n'a connaissance d'aucun utilisateur ayant perdu de l'argent avant les
premières annonces publiques de la vulnérabilité. La spécification LN a été [mise à jour][news67
bolts676] pour aider les futurs implémenteurs à éviter ce problème et il est prévu que [d'autres
propositions de changements][dual-funding serialization] au protocole de communication de LN aideront à
éviter d'autres échecs de ce type.

## Octobre

<div markdown="1" id="anchor-outputs">

Les développeurs LN ont réalisés des progrès significatifs en octobre et novembre pour répondre à une
préoccupation de longue date concernant le fait de garantir que les utilisateurs puissent toujours
fermer leurs canaux sans délais excessifs. Si un utilisateur décide de fermer l'un de ses canaux et
qu'il est incapable de contacter son pair distant, il diffuse la dernière *transaction de
commitment* pour ce canal---une transaction pré-signée qui dépense les fonds du canal onchain à
chaque partie selon la dernière version de leur contrat offchain. Un problème potentiel avec cet
arrangement est que la transaction de commitment a potentiellement été créée des jours ou des
semaines plus tôt lorsque les frais de transaction étaient plus bas, de sorte qu'elle peut ne pas
payer des frais suffisamment élevés pour se confirmer rapidement avant l'expiration de tout
verrouillage temporel essentiel à la sécurité.

Il a toujours été connu que la solution à ce problème est de permettre de modifier les frais des
transactions de commitment. Malheureusement, des nœuds tels que Bitcoin Core doivent limiter
l'utilisation de l'augmentation des frais pour éviter les attaques de déni de service (DoS) qui
gaspillent leur bande passante et leur CPU. Dans des protocoles multi-utilisateurs sans confiance
comme LN, votre contrepartie pourrait être un attaquant qui pourrait délibérément déclencher la
politique anti-DoS afin de retarder la confirmation de votre transaction de commitment LN, une
attaque parfois appelée [épinglage de transaction][topic transaction pinning]. Une transaction épinglée
peut ne pas se confirmer avant l'expiration de ses verrous temporels, permettant à une contrepartie
attaquante de vous voler des fonds.

L'année dernière, Matt Corallo a [suggéré][carve-out proposed] de créer une exemption spéciale de la
politique de relais de transactions de Bitcoin Core liée à l'augmentation des frais
Child-Pays-For-Parent (CPFP). Cette exemption limitée garantit que les protocoles de contrat à deux
parties (comme LN de génération actuelle) peuvent garantir à chaque partie la possibilité de créer
leur propre augmentation de frais. L'idée de Corallo a été nommée [CPFP carve-out][topic cpfp carve
out] et son implémentation a été publiée dans le cadre de Bitcoin Core 0.19. Même avant cette
publication, d'autres développeurs LN ont travaillé sur les [révisions][anchor outputs] des scripts
LN et des messages de protocole nécessaires pour commencer à utiliser le changement. Au moment de la
rédaction de cet article, ces changements de spécification sont en attente de mise en œuvre et
d'acceptation finale avant de voir le déploiement sur le réseau.

</div>

<div markdown="1" class="callout" id="new-infrastructure">

### Résumé 2019<br>Nouvelles solutions d'infrastructure open source

- [Outil de preuve de réserves][] publié en février permet aux échanges et
  autres gardiens de bitcoins de prouver qu'ils ont le contrôle sur un certain
  ensemble d'UTXOs en utilisant des preuves de réserves [BIP127][].

- [Interface de portefeuille matériel][topic hwi] publiée en mars facilite
  l'utilisation de plusieurs modèles de portefeuilles matériels pour le stockage
  sécurisé des clés et la signature par un portefeuille déjà compatible avec les Transactions Bitcoin
  Partiellement Signées ([PSBTs][topic psbt]) et les [descripteurs de scripts de sortie][topic
  descriptors].

- <a href="/en/newsletters/2019/03/26/#loop-announced">Lightning Loop</a> publié en mars (avec le
  support de loop-in ajouté en juin) fournit un service non-custodial qui permet aux utilisateurs
  d'ajouter ou de retirer des fonds de leurs canaux LN sans fermer les canaux existants
  ou en ouvrir de nouveaux.

</div>

## Novembre

<div markdown="1" id="bech32-mutability">

La discussion en novembre sur l'utilisation des adresses bech32 pour les paiements [taproot][topic
taproot] a attiré l'attention sur un [problème][bech32 malleability issue] découvert en mai.
Selon le [BIP173][], les chaînes bech32 mal copiées sont censées avoir un taux d'échec maximal
d'environ 1 sur un milliard. Cependant, il a été découvert que les chaînes
bech32 se terminant par un `p` pouvaient avoir n'importe quel nombre de caractères `q` précédents
ajoutés ou supprimés. Cela n'affecte pas pratiquement les adresses bech32 pour
les adresses segwit P2WPKH ou P2WSH, car au moins 19 caractères `q` consécutifs
devraient être ajoutés ou supprimés pour transformer un type d'adresse en un autre---et tout autre
changement de longueur pour les adresses segwit v0 serait invalide. <!-- mathématiques des
"19 caractères" dans le _posts/fr/newsletters/2019-11-13-newsletter.md -->

Mais ce n'est pas le cas pour les adresses segwit v1+, telles que celles proposées pour taproot, où
un seul caractère `q` ajouté ou supprimé dans une adresse vulnérable pourrait entraîner
une perte de fonds. Pieter Wuille, co-auteur de BIP173, a effectué
[une analyse supplémentaire][bech32 analysis] et a constaté que c'était la seule
déviation par rapport à la capacité de correction d'erreur attendue de bech32, il a donc
proposé de limiter l'utilisation des adresses BIP173 dans Bitcoin à seulement 20 octets
ou 32 octets y compris l'inclusion de témoins. Cela garantira que les versions d'adresse segwit v1 et
ultérieures fournissent la même correction d'erreur fiable que les adresses segwit v0. Il a également décrit une
petite modification de l'algorithme bech32 qui permettra à d'autres applications utilisant bech32,
ainsi qu'aux formats d'adresse Bitcoin de nouvelle génération, d'utiliser la détection d'erreur BCH sans ce
problème.

</div>

{:#openssl}
Également en novembre, Bitcoin Core [a supprimé sa dépendance à OpenSSL][rm
openssl], qui faisait partie de son code depuis la version originale de 2009
de Bitcoin 0.1. OpenSSL était la cause de [vulnérabilités de consensus][non-strict der], [fuites de
mémoire à distance][heartbleed]
(fuites potentielles de clés privées), d'[autres bugs][cve-2014-3570], et de [faibles
performance][libsecp256k1 sig speedup]. On espère que sa suppression réduira la fréquence des
futures vulnérabilités.

{:#bip70}
Dans le cadre de la suppression d'OpenSSL, Bitcoin Core a déprécié son support du protocole de
paiement [BIP70][] dans la version 0.18, puis a désactivé le support par défaut dans la version
0.19. Cette décision a été [soutenue][ceo bitpay] par le PDG d'une des rares entreprises qui ont
continué à utiliser BIP70 en 2019.

## Décembre

{:#multipath}
En décembre, les développeurs de LN ont atteint l'un de leurs principaux objectifs de la réunion de
planification de l'année dernière [ln1.1] : la [mise en œuvre][mpp implementation] de paiements
[multiparties de base][topic multipath payments]. Il s'agit de paiements qui peuvent être divisés en
plusieurs parties, chaque partie étant acheminée séparément à travers différents canaux. Cela permet
aux utilisateurs de dépenser ou de recevoir de l'argent en utilisant plus d'un de leurs canaux à la
fois, ce qui rend possible de dépenser leur solde offchain complet ou de recevoir jusqu'à leur
capacité maximale en un seul paiement (dans les limites de certaines restrictions de sécurité). <!--
restrictions de sécurité : non-wumbo et financement de réserve de canal --> On s'attend à ce que
cela rende LN significativement plus convivial en éliminant le besoin pour les dépensiers de se
soucier des soldes des canaux spécifiques.

## Conclusion

Dans le résumé ci-dessus, nous ne voyons pas de propositions ou d'améliorations révolutionnaires. Au
lieu de cela, nous voyons une série d'améliorations progressives---des solutions qui prennent des
cas où Bitcoin et LN sont déjà performants et les améliorent pour rendre le système encore meilleur.
Nous voyons des développeurs travailler pour rendre les portefeuilles matériels plus accessibles
(HWI), généraliser la communication entre les portefeuilles pour les cas d'utilisation multisig et
de contrats (descripteurs, PSBTs, miniscript), renforcer la sécurité du consensus (cleanup soft
fork), simplifier les tests (signet), éliminer la garde inutile (loop), faciliter le démarrage d'un
nœud (assumeutxo), améliorer la confidentialité et économiser de l'espace de bloc (taproot),
simplifier l'application de LN (anyprevout), mieux gérer les pics de frais de transaction (CTV),
réduire la bande passante des nœuds (erlay), protéger les utilisateurs de LN lorsqu'ils sont hors
ligne (watchtowers), réduire le besoin de confiance (reproducible builds), prévenir les vols
(vaults), rendre la confidentialité plus accessible (SNICKER), mieux gérer les frais onchain pour
les utilisateurs de LN (anchor outputs), et faire en sorte que les paiements LN fonctionnent
automatiquement plus souvent (paiements multiparties).

(Et ce ne sont que les points forts de l'année !)

Nous ne pouvons que deviner ce que les contributeurs de Bitcoin accompliront l'année prochaine, mais
nous soupçonnons que ce sera plus de la même chose---des dizaines de changements modestes qui
rendent chacun le système meilleur sans le casser pour ceux qui sont déjà satisfaits.

*La newsletter Optech reprendra son calendrier de publication régulier le mercredi 8 janvier.*

{% include references.md %}
{% include linkers/issues.md issues="16800,16411,17268,17292" %}
[#14897]: /en/newsletters/2019/02/12/#bitcoin-core-14897
[résumé de 2018]: /en/newsletters/2018/12/28/
[altruist watchtowers]: /en/newsletters/2019/06/19/#lnd-3133
[anchor miniscript]: https://github.com/lightningnetwork/lightning-rfc/pull/688#pullrequestreview-326862133
[anchor outputs]: /en/newsletters/2019/10/30/#ln-simplified-commitments
[bech32 analysis]: /en/newsletters/2019/12/18/#analysis-of-bech32-error-detection
[bech32 malleability issue]: https://github.com/sipa/bech32/issues/51
[bech32 sending support]: /en/bech32-sending-support/
[bitcoin core 0.18]: /en/newsletters/2019/05/07/#bitcoin-core-0-18-0-released
[bitcoin core 0.19]: /en/newsletters/2019/11/27/#bitcoin-core-0-19-released
[brd]: /en/newsletters/2019/08/07/#bech32-sending-support
[breaking bitcoin]: /en/newsletters/2019/06/19/#breaking-bitcoin
[btcpayserver.vault]: https://github.com/btcpayserver/BTCPayServer.Vault
[btse]: /en/btse-exchange-operation/
[carve-out proposed]: /en/newsletters/2018/12/04/#cpfp-carve-out
[ceo bitpay]: /en/newsletters/2018/10/30/#bitcoin-core-14451
[c-lightning 0.7]: /en/newsletters/2019/03/05/#upgrade-to-c-lightning-0-7
[c-lightning 0.8]: https://github.com/ElementsProject/lightning/releases/tag/v0.8.0
[cl repro]: https://github.com/ElementsProject/lightning/blob/master/doc/REPRODUCIBLE.md
[cl signet]: /en/newsletters/2019/07/24/#c-lightning-2816
[coredevtech amsterdam]: /en/newsletters/2019/06/12/#bitcoin-core-contributor-meetings
[coshv]: /en/newsletters/2019/05/29/#proposed-transaction-output-commitments
[cryptoeconomic systems summit]: /en/newsletters/2019/10/16/#conference-summary-cryptoeconomic-systems-summit
[cve-2014-3570]: https://www.reddit.com/r/Bitcoin/comments/2rrxq7/on_why_010s_release_notes_say_we_have_reason_to/
[dual-funding serialization]: https://twitter.com/rusty_twit/status/1179976386619928576
[dumptxoutset]: /en/newsletters/2019/11/13/#bitcoin-core-16899
[eclair 0.3]: https://github.com/ACINQ/eclair/releases/tag/v0.3
[attaques d'éclipse]: https://eprint.iacr.org/2015/263.pdf
[edge dev++]: /en/newsletters/2019/09/18/#bitcoin-edge-dev
[eltoo watchtowers]: /en/newsletters/2019/12/11/#watchtowers-for-eltoo-payment-channels
[exp tramp]: /en/newsletters/2019/11/20/#eclair-1209
[gitian]: https://github.com/devrandom/gitian-builder
[guix merge]: /en/newsletters/2019/07/17/#bitcoin-core-15277
[heartbleed]: https://bitcoin.org/en/alert/2014-04-11-heartbleed
[notebooks jupyter]: https://github.com/bitcoinops/taproot-workshop#readme
[libsecp256k1 sig speedup]: https://bitcoincore.org/en/2016/02/23/release-0.12.0/#x-faster-signature-validation
[lightning loop]: /en/newsletters/2019/03/26/#loop-announced
[ln1.1]: /en/newsletters/2018/11/20/#feature-news-lightning-network-protocol-11-goals
[lnd 0.6-beta]: /en/newsletters/2019/04/23/#lnd-0-6-beta-released
[lnd 0.7-beta]: /en/newsletters/2019/07/03/#lnd-0-7-0-beta-released
[lnd 0.8-beta]: /en/newsletters/2019/10/16/#upgrade-lnd-to-version-0-8-0-beta
[lnd repro]: https://github.com/lightningnetwork/lnd/blob/master/build/release/README.md
[lnd scb]: /en/newsletters/2019/04/09/#lnd-2313
[ln missed validation]: /en/newsletters/2019/10/02/#full-disclosure-of-fixed-vulnerabilities-affecting-multiple-ln-implementations
[loop-in]: /en/newsletters/2019/07/03/#lightning-loop-supports-user-loop-ins
[mcf]: /en/newsletters/2019/05/21/#talks-of-technical-interest-at-magical-crypto-friends-conference
[mit bitcoin expo]: /en/newsletters/2019/03/19/#mit-bitcoin-club-2019-expo-videos-available
[mpp implementation]: /en/newsletters/2019/12/18/#ln-implementations-add-multipath-payment-support
[news33 reserves]: /en/newsletters/2019/02/12/#tool-released-for-generating-and-verifying-bitcoin-ownership-proofs
[news37 cleanup discussion]: /en/newsletters/2019/03/12/#cleanup-soft-fork-proposal-discussion
[news37 merkle tree attacks]: /en/newsletters/2019/03/05/#merkle-tree-attacks
[news61 miniscript feedback]: /en/newsletters/2019/08/28/#miniscript-request-for-comments
[news67 bolts676]: /en/newsletters/2019/10/09/#bolts-676
[bulletin d'information hebdomadaire]: /en/newsletters/
[bulletins d'information hebdomadaire]: /en/newsletters/
[non-strict der]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2015-July/009697.html
[optech executive briefing]: /en/2019-exec-briefing/
[outil de preuve de réserves]: /en/newsletters/2019/02/12/#tool-released-for-generating-and-verifying-bitcoin-ownership-proofs
[rm openssl]: /en/newsletters/2019/11/27/#bitcoin-core-17265
[roose reserves]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-January/016633.html
[Workbook sur la scalabilité]: https://github.com/bitcoinops/scaling-book
[scaling bitcoin]: /en/newsletters/2019/09/18/#scaling-bitcoin
[ateliers schnorr/taproot]: /en/schnorr-taproot-workshop/
[snicker]: /en/newsletters/2019/09/04/#snicker-proposed
[stanford blockchain conference]: /en/newsletters/2019/02/05/#notable-talks-from-the-stanford-blockchain-conference
[sybil attacks]: https://en.wikipedia.org/wiki/Sybil_attack
[taproot review]: /en/newsletters/2019/10/23/#taproot-review
[attaque de décalage temporel]: /en/newsletters/2019/03/05/#the-time-warp-attack
[index des sujets]: /en/topics/
[trampoline proposed]: /en/newsletters/2019/04/02/#trampoline-payments-for-ln
[trampolines pr]: /en/newsletters/2019/08/07/#trampoline-payments
[confiance aveugle]: https://www.archive.ece.cmu.edu/~ganger/712.fall02/papers/p761-thompson.pdf
[twitter]: https://twitter.com/bitcoinoptech/
[deux connexions sortantes supplémentaires]: /en/newsletters/2019/09/11/#bitcoin-core-15759
[txprobe]: /en/newsletters/2019/09/18/#txprobe-discovering-bitcoin-s-network-topology-using-orphan-transactions
[coffres-forts sur Bitcoin sans utiliser de covenants]: /en/newsletters/2019/08/14/#bitcoin-vaults-without-covenants
[wasabi hwi]: https://github.com/zkSNACKs/WalletWasabi/releases/tag/v1.1.4
[watchtower spec]: /en/newsletters/2019/12/04/#proposed-watchtower-bolt
[weekly newsletter]: /en/newsletters/
[weekly newsletters]: /en/newsletters/
[utilisation CPU maximale]: /en/newsletters/2019/03/05/#legacy-transaction-verification
[wuille sbc miniscript]: /en/newsletters/2019/02/05/#miniscript
[xlation es]: /es/publications/
[xlation ja]: /ja/publications/
[eltoo]: https://blockstream.com/eltoo.pdf
[hwi]: https://github.com/bitcoin-core/HWI
[erlay]: https://arxiv.org/pdf/1905.10518.pdf
