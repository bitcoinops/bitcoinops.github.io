{:.post-meta}
*par [Antoine Poinsot][] de [Wizardsardine][]*

Notre intérêt (pratique) pour miniscript a commencé au début de 2020 lorsque nous concevions [Revault][], une architecture de
[coffre-fort][topic coffres-forts] multipartie utilisant uniquement les primitives de script disponibles à l'époque.

Nous avons initialement présenté Revault en utilisant un ensemble fixe de participants. Nous avons rapidement rencontré des problèmes
lorsque nous avons essayé de le généraliser à un plus grand nombre de participants dans un environnement de production.

- Sommes-nous vraiment _sûrs_ que le script que nous avons utilisé dans la démonstration est sécurisé ? Est-il possible de le dépenser
de toutes les manières annoncées ? N'y a-t-il aucune autre façon de le dépenser que celle annoncée ?
- Même s'il l'est, comment pouvons-nous le généraliser à un nombre variable de participants tout en le maintenant sécurisé ?
Comment pouvons-nous appliquer des optimisations et nous assurer que le script résultant a les mêmes sémantiques ?
- De plus, Revault utilise des transactions pré-signées (pour appliquer des politiques de dépenses). Comment pouvons-nous connaître à
l'avance le budget à allouer pour l'augmentation des frais en fonction de la configuration du script ? Comment pouvons-nous nous assurer
que _toute_ transaction dépensant ces scripts passera les vérifications de conformité les plus courantes ?
- Enfin, même en supposant que nos scripts correspondent aux sémantiques prévues et qu'ils sont toujours dépensables, comment pouvons-nous
les dépenser _concrètement_ ? Comment pouvons-nous produire un témoin conforme ("signer pour") à chaque configuration possible ?
Comment pouvons-nous rendre les dispositifs de signature matérielle compatibles avec nos scripts ?

Ces questions auraient constitué des obstacles majeurs si ce n'était pas pour miniscript. Deux personnes dans un garage ne vont pas
écrire un logiciel qui [crée un script à la volée, et espère le meilleur][rekt lost funds] et se permettre d'appeler ça un portefeuille
Bitcoin améliorant la sécurité. Nous voulions créer une entreprise autour du développement de Revault, mais nous n'obtiendrions pas
de financement sans fournir une certaine assurance raisonnable à un investisseur que nous pourrions proposer un produit sûr sur le marché.
Et nous ne pourrions pas résoudre tous ces problèmes d'ingénierie sans financement.

[Entre en jeu miniscript][sipa miniscript], "un langage pour écrire (une partie de) Scripts Bitcoin de manière structurée, permettant
l'analyse, la composition, la signature générique et plus encore. [...] Il a une structure qui permet la composition. Il est très facile
à analyser statiquement pour diverses propriétés (conditions de dépense, correction, propriétés de sécurité, malléabilité, ...)". C'est
exactement ce dont nous avions besoin. Armés de cet outil puissant, nous pourrions offrir de meilleures garanties [0] à nos investisseurs,
lever des fonds et commencer le développement de Revault.

À l'époque, miniscript était encore loin d'être une solution clé en main pour tout développeur d'application Bitcoin. (Si vous êtes un
nouveau développeur Bitcoin lisant ceci après l'année 2023, oui, il fut un temps où nous écrivions les scripts Bitcoin À LA MAIN.)
Nous avons dû intégrer miniscript dans Bitcoin Core (voir les PR [#24147][Bitcoin Core #24147], [#24148][Bitcoin Core #24148] et
[#24149][Bitcoin Core #24149]), que nous avons utilisé comme backend du portefeuille Revault, et convaincre les fabricants de dispositifs
de signature de l'implémenter dans leur firmware. Cette dernière partie s'est avérée la plus difficile.

C'était un problème de poule et d'œuf : les incitations étaient faibles pour les fabricants d'implémenter miniscript sans demande des
utilisateurs. Et nous ne pouvions pas sortir Revault sans avoir des dispositifs de signature compatibles avec miniscript sans prise en
charge de l'appareil de signature. Heureusement, ce cycle a finalement été brisé par [Stepan Snigirev][] en mars 2021 en
[apportant][github embit descriptors] la prise en charge des descripteurs miniscript à [Specter DIY][]. Cependant, le Specter DIY a été
pendant longtemps considéré comme un simple "prototype fonctionnel", et [Salvatore Ingala][] a apporté [miniscript à un appareil de
signature prêt pour la production][ledger miniscript blog] pour la première fois en 2022 avec la [nouvelle application
Bitcoin][ledger bitcoin app] pour le Ledger Nano S(+). L'application a été publiée en janvier 2023, ce qui nous a permis de publier le
[portefeuille Liana][] avec prise en charge de l'appareil de signature le plus populaire.

Il ne reste plus qu'un dernier développement pour conclure notre parcours miniscript. [Liana][github liana] est un portefeuille Bitcoin
axé sur les options de récupération. Il permet de spécifier certaines conditions de récupération avec verrouillage temporel (par exemple,
une [clé de récupération tierce qui ne peut normalement pas dépenser les fonds][blog liana 0.2 recovery], ou un [multisig en déclin/
expansion][blog liana 0.2 decaying]). Miniscript était initialement disponible uniquement pour les scripts P2WSH. Près de 2 ans après
l'activation de [taproot][topic taproot], il est regrettable que vous deviez publier vos chemins de dépense de récupération on chain
à chaque fois que vous faites une dépense. À cette fin, nous avons travaillé pour porter miniscript à tapscript (voir
[ici][github minitapscript] et [ici][Bitcoin Core #27255]).

L'avenir est prometteur. La plupart des appareils de signature ayant déjà implémenté ou étant en cours d'implémentation
de miniscript (par exemple récemment [Bitbox][github bitbox v9.15.0] et [Coldcard][github coldcard 227]), les frameworks
natifs de [taproot et miniscript][github bdk] ayant été peaufinés, la contractualisation sur Bitcoin avec des primitives sécurisées est
plus accessible que jamais.

Il est intéressant de noter comment le financement des outils et des frameworks Open Source réduit les barrières à l'entrée pour les
entreprises innovantes qui peuvent désormais affronter la concurrence et, plus généralement, mettre en œuvre des projets. Cette tendance,
qui s'est accélérée ces dernières années, nous permet d'être optimistes quant à l'avenir de cet espace.

[0] Il y avait toujours un risque, bien sûr. Mais au moins, nous étions confiants de pouvoir passer à l'étape off-chain. Celle-ci s'est
avérée (comme prévu) plus difficile.

{% include references.md %}
{% include linkers/issues.md v=2 issues="24147,24148,24149,27255" %}
[Antoine Poinsot]: https://twitter.com/darosior
[Wizardsardine]: https://wizardsardine.com/
[Revault]: https://wizardsardine.com/revault
[rekt lost funds]: https://rekt.news/leaderboard/
[sipa miniscript]: https://bitcoin.sipa.be/miniscript
[Stepan Snigirev]: https://github.com/stepansnigirev
[github embit descriptors]: https://github.com/diybitcoinhardware/embit/pull/4
[github specter descriptors]: https://github.com/cryptoadvance/specter-diy/pull/133
[Specter DIY]: https://github.com/cryptoadvance/specter-diy
[Salvatore Ingala]: https://github.com/bigspider
[ledger miniscript blog]: https://www.ledger.com/blog/miniscript-is-coming
[ledger bitcoin app]: https://github.com/LedgerHQ/app-bitcoin-new
[Liana wallet]: https://wizardsardine.com/liana/
[github liana]: https://github.com/wizardsardine/liana
[blog liana 0.2 recovery]: https://wizardsardine.com/blog/liana-0.2-release/#trust-distributed-safety-net
[blog liana 0.2 decaying]: https://wizardsardine.com/blog/liana-0.2-release/#decaying-multisig
[github minitapscript]: https://github.com/sipa/miniscript/pull/134
[github bitbox v9.15.0]: https://github.com/digitalbitbox/bitbox02-firmware/releases/tag/firmware%2Fv9.15.0
[github coldcard 227]: https://github.com/Coldcard/firmware/pull/227
[github bdk]: https://github.com/bitcoindevkit/bdk