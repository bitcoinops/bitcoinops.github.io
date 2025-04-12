---
title: 'Bulletin Hebdomadaire Bitcoin Optech #349'
permalink: /fr/newsletters/2025/04/11/
name: 2025-04-11-newsletter-fr
slug: 2025-04-11-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit une proposition pour accélérer le téléchargement initial des
blocs de Bitcoin Core, avec une implémentation de preuve de concept qui montre une accélération
d'environ cinq fois par rapport aux paramètres par défaut de Bitcoin Core. Sont également inclus nos
sections régulières résumant une réunion du Bitcoin Core PR Review Club, annoncant des mises à jour
et des versions candidates, et décrivant les changements notables dans les projets
d'infrastructure Bitcoin populaires.

## Nouvelles

- **Accélération SwiftSync pour le téléchargement initial des blocs :** Sebastian Falbesoner a
  [posté][falbesoner ss1] sur Delving Bitcoin une démonstration d'implémentation et les résultats de
  performance pour _SwiftSync_, une idée [proposée][somsen ssgist] par Ruben Somsen lors d'une récente
  réunion de développeurs de Bitcoin Core et plus tard [publiée][somsen ssml] sur la liste de
  diffusion. À l'heure actuelle, les [résultats les plus récents][falbesoner ss2] publiés dans le fil
  montrent une accélération de 5,28x du _téléchargement initial des blocs_ (IBD pour _initial block download_) par rapport aux
  paramètres IBD par défaut de Bitcoin Core (qui utilise [assumevalid][] mais pas [assumeUTXO][topic
  assumeutxo]), réduisant le temps de synchronisation initial d'environ 41 heures à environ 8 heures.

  Avant d'utiliser SwiftSync, une personne ayant déjà synchronisé son nœud à un bloc récent crée un
  _fichier d'indices_ qui indique quels outputs de transaction seront dans l'ensemble UTXO à ce bloc
  (c'est-à-dire, quels outputs seront non dépensés). Cela peut être encodé de manière efficace en
  quelques centaines de mégaoctets pour la taille actuelle de l'ensemble UTXO. Le fichier d'indices
  indique également à quel bloc il a été généré, que nous appellerons le _bloc terminal SwiftSync_.

  L'utilisateur effectuant SwiftSync télécharge le fichier d'indices et l'utilise lors du traitement
  de chaque bloc précédant le bloc terminal SwiftSync pour ne stocker les outputs dans la base de
  données UTXO que si le fichier d'indices indique que l'output restera dans l'ensemble UTXO lorsque
  le bloc terminal SwiftSync sera atteint. Cela réduit massivement le nombre d'entrées qui sont
  ajoutées, puis plus tard retirées, de la base de données UTXO pendant l'IBD.

  Pour s'assurer que le fichier d'indices est correct, chaque output créé non stocké dans la base de
  données UTXO est ajouté à un [accumulateur cryptographique][]. Chaque output dépensé est retiré de
  l'accumulateur. Lorsque le nœud atteint le bloc terminal SwiftSync, il s'assure que l'accumulateur
  est vide, signifiant que chaque output vu a été dépensé plus tard. Si cela échoue, cela signifie que
  le fichier d'indices était incorrect et que l'IBD doit être effectué à nouveau depuis le début sans
  utiliser SwiftSync. De cette manière, les utilisateurs n'ont pas besoin de faire confiance au
  créateur du fichier d'indices---un fichier malveillant ne peut pas entraîner un état UTXO incorrect;
  il peut seulement gaspiller quelques heures de ressources informatiques de l'utilisateur.

  Une propriété supplémentaire de SwiftSync qui n'a pas encore été implémentée est de permettre la
  validation parallèle des blocs pendant l'IBD. Cela est possible parce que assumevalid ne vérifie pas
  les scripts des blocs plus anciens, les entrées ne sont jamais retirées de la base de données UTXO
  avant le bloc terminal SwiftSync, et l'accumulateur utilisé ne suit que l'effet net des sorties ajoutées
  (créées) et retirées (dépensées). Cela élimine toute dépendance entre les blocs avant le bloc
  terminal SwiftSync. La validation parallèle pendant l'IBD est également une caractéristique de
  [Utreexo][topic utreexo] pour certaines des mêmes raisons.

  La discussion a examiné plusieurs aspects de la proposition. L'implémentation originale de
  Falbesoner utilisait l'accumulateur [MuHash][] (voir le [Bulletin #123][news123 muhash]), qui [a été
  montré][wuille muhash] résistant à l'[attaque d'anniversaire généralisée][attaque anniversaire]. Somsen [a
  décrit][somsen ss1] une approche alternative qui pourrait être plus rapide. Falbesoner s'est
  interrogé sur la sécurité cryptographique de l'approche alternative mais, puisqu'elle était simple,
  l'a quand même mise en œuvre et a trouvé qu'elle accélérait davantage SwiftSync.

  James O'Beirne [a demandé][obeirne ss] si SwiftSync est utile étant donné que assumeUTXO offre une
  accélération encore plus grande. Somsen [a répondu][somsen ss2] que SwiftSync accélère la validation
  en arrière-plan d'assumeUTXO, ce qui en fait un ajout intéressant pour les utilisateurs d'assumeUTXO. Il
  note en outre que quiconque télécharge les données requises d'assumeUTXO (la base de données UTXO à
  un bloc particulier) n'a pas besoin d'un fichier d'indices séparé s'il utilise ce même bloc comme
  bloc terminal SwiftSync.

  Vojtěch Strnad, 0xB10C, et Somsen [ont discuté][b10c ss] de la compression des données du fichier
  d'indices, avec une économie attendue d'environ 75%, réduisant le fichier d'indices de test (pour le
  bloc 850,900) à environ 88 Mo.

  La discussion était en cours au moment de la rédaction.

## Bitcoin Core PR Review Club

*Dans cette section mensuelle, nous résumons une récente réunion du [Bitcoin Core PR Review Club][],
en soulignant certaines des questions et réponses importantes. Cliquez sur une question ci-dessous
pour voir un résumé de la réponse de la réunion.*

[Add Fee rate Forecaster Manager][review club 31664] est un PR par [ismaelsadeeq][gh ismaelsadeeq]
qui améliore la logique de prévision des frais de transaction (également appelée [estimation][topic
fee estimation]). Il introduit une nouvelle classe `ForecasterManager` à laquelle plusieurs
`Forecaster`s peuvent être enregistrés. Le `CBlockPolicyEstimator` existant (qui ne considère que
les transactions confirmées) est refactorisé pour devenir un de ces prévisionnistes, mais notablement un
nouveau `MemPoolForecaster` est introduit. `MemPoolForecaster` considère les transactions non
confirmées qui sont dans le mempool, et en tant que tel peut réagir plus rapidement aux changements
de taux de frais.

{% include functions/details-list.md
  q0="Pourquoi le nouveau système est-il appelé un « Forecaster » et « ForecasterManager » plutôt
  qu' « Estimator » et « Fee Estimation Manager » ?"
  a0="Le système prédit les résultats futurs basés sur les données actuelles et passées. Contrairement
  à un estimateur, qui approximise les conditions présentes avec une certaine randomisation, un
  prévisionniste projette des événements futurs, ce qui s'aligne avec la nature prédictive de ce
  système et sa sortie de niveaux d'incertitude/risque."
  a0link="https://bitcoincore.reviews/31664#l-19"

  q1="Pourquoi `CBlockPolicyEstimator` n'est-il pas modifié pour contenir la référence mempool,
  comme dans le PR #12966 ? Quelle est l'approche actuelle
  et pourquoi est-elle meilleure que de conserver une référence à mempool ?
  (Hint : see PR #28368)"
  a1="`CBlockPolicyEstimator` hérite de `CValidationInterface` et
  implémente ses méthodes virtuelles `TransactionAddedToMempool`,
  `TransactionRemovedFromMempool`, et
  `MempoolTransactionsRemovedForBlock`. Cela donne à
  `CBlockPolicyEstimator` toutes les informations mempool dont il a besoin sans
  être inutilement couplé au mempool via une référence."
  a1link="https://bitcoincore.reviews/31664#l-26"

  q2="Quels sont les compromis entre la nouvelle architecture et une
  modification directe de `CBlockPolicyEstimator` ?"
  a2="La nouvelle architecture avec une classe `FeeRateForecasterManager` à
  laquelle plusieurs `Forecaster` peuvent être enregistrés est une approche plus modulaire
  qui permet de meilleurs tests, et applique une meilleure
  séparation des préoccupations. Elle permet d'intégrer facilement de nouvelles stratégies de prévision
  par la suite. Cela se fait au prix d'un peu plus de code à
  maintenir, et d'une confusion potentielle pour les utilisateurs quant à la méthode d'estimation
  à utiliser."
  a2link="https://bitcoincore.reviews/31664#l-43"
%}

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates._

- [Core Lightning 25.02.1][] est une version de maintenance pour la version majeure actuelle de ce
  nœud LN populaire qui inclut plusieurs corrections de bugs.

- [Core Lightning 24.11.2][] est une version de maintenance pour une version majeure antérieure de
  ce nœud LN. Elle inclut plusieurs corrections de bugs, certaines étant les mêmes que celles sorties
  dans la version 25.02.1.

- [BTCPay Server 2.1.0][] est une version majeure de ce logiciel de traitement de paiements
  auto-hébergé. Elle inclut des changements importants pour les utilisateurs de certains altcoins,
  des améliorations pour le [RBF][topic rbf] et le [CPFP][topic cpfp] pour augmenter les frais, et un
  meilleur flux pour le multisig lorsque tous les signataires utilisent BTCPay Server.

- [Bitcoin Core 29.0rc3][] est un candidat à la sortie pour la prochaine version majeure du nœud
  complet prédominant du réseau. Veuillez consulter le [guide de test de la version 29][bcc29 testing
  guide].

- [LND 0.19.0-beta.rc2][] est un candidat à la sortie pour ce nœud LN populaire. L'une des
  principales améliorations qui pourrait probablement nécessiter des tests est le nouveau bumping de
  frais basé sur RBF pour les fermetures coopératives.

## Changements de code et de documentation notables

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Amélioration de Bitcoin]
Propositions (BIPs)][bips repo], [Lightning BOLTs][bolts repo],[Lightning BLIPs][blips repo],
[Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [LDK #2256][] et [LDK #3709][] améliorent les échecs attribuables (voir le Bulletin [#224][news224
  failures]) comme spécifié dans [BOLTs #1044][] en ajoutant un champ `attribution_data` optionnel à
  la structure `UpdateFailHTLC` et en introduisant la structure `AttributionData`. Dans ce protocole,
  chaque nœud de transfert ajoute au message d'échec un drapeau `hop_payload`, un champ de durée qui
  enregistre combien de temps le nœud a détenu le HTLC, et des HMAC correspondant à différentes
  positions supposées dans l'itinéraire. Si un nœud corrompt le message d'échec, le décalage dans la
  chaîne HMAC aide à identifier la paire de nœuds entre lesquels cela s'est produit.

- [LND #9669][] rétrograde les [canaux taproot simples][topic simple taproot channels] pour toujours
  utiliser le flux de fermeture coopérative classique, même si le flux de fermeture coopérative
  [RBF][topic rbf] (voir le Bulletin [#347][news347 coop]) est configuré. Auparavant, un nœud ayant les
  deux fonctionnalités configurées échouerait à démarrer.

- [Rust Bitcoin #4302][] ajoute une nouvelle méthode `push_relative_lock_time()` à l'API du
  générateur de script, qui prend un paramètre de [verrouillage temporel relatif][topic timelocks],
  et rend obsolète `push_sequence()` qui prend un numéro de séquence brut comme paramètre. Ce changement
  résout une confusion potentielle où les développeurs pousseraient par erreur un numéro de séquence
  brut dans les scripts au lieu d'une valeur de verrouillage temporel relatif, qui est ensuite
  vérifiée contre le numéro de séquence d'une entrée en utilisant `CHECKSEQUENCEVERIFY`.

{% include snippets/recap-ad.md when="2025-04-15 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2256,3709,9669,4302,1044" %}
[bitcoin core 29.0rc3]: https://bitcoincore.org/bin/bitcoin-core-29.0/
[bcc29 testing guide]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/29.0-Release-Candidate-Testing-Guide
[lnd 0.19.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc2
[wuille muhash]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2017-May/014337.html
[falbesoner ss1]: https://delvingbitcoin.org/t/ibd-booster-speeding-up-ibd-with-pre-generated-hints-poc/1562/
[somsen ssgist]: https://gist.github.com/RubenSomsen/a61a37d14182ccd78760e477c78133cd
[falbesoner ss2]: https://delvingbitcoin.org/t/ibd-booster-speeding-up-ibd-with-pre-generated-hints-poc/1562/7
[assumevalid]: https://bitcoincore.org/en/2017/03/08/release-0.14.0/#assumed-valid-blocks
[accumulateur cryptographique]: https://en.wikipedia.org/wiki/Accumulator_(cryptography)
[news123 muhash]: /en/newsletters/2020/11/11/#bitcoin-core-pr-review-club
[muhash]: https://cseweb.ucsd.edu/~mihir/papers/inchash.pdf
[attaque anniversaire]: https://www.iacr.org/archive/crypto2002/24420288/24420288.pdf
[somsen ss1]: https://delvingbitcoin.org/t/ibd-booster-speeding-up-ibd-with-pre-generated-hints-poc/1562/2
[obeirne ss]: https://delvingbitcoin.org/t/ibd-booster-speeding-up-ibd-with-pre-generated-hints-poc/1562/5
[somsen ss2]: https://delvingbitcoin.org/t/ibd-booster-speeding-up-ibd-with-pre-generated-hints-poc/1562/6
[b10c ss]: https://delvingbitcoin.org/t/ibd-booster-speeding-up-ibd-with-pre-generated-hints-poc/1562/4
[somsen ssml]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAPv7TjaM0tfbcBTRa0_713Bk6Y9jr+ShOC1KZi2V3V2zooTXyg@mail.gmail.com/T/#u
[core lightning 25.02.1]: https://github.com/ElementsProject/lightning/releases/tag/v25.02.1
[core lightning 24.11.2]: https://github.com/ElementsProject/lightning/releases/tag/v24.11.2
[btcpay server 2.1.0]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.1.0
[news224 failures]: /fr/newsletters/2022/11/02/#attribution-de-l-echec-du-routage-ln
[news347 coop]: /en/newsletters/2025/03/28/#lnd-8453
[review club 31664]: https://bitcoincore.reviews/31664
[gh ismaelsadeeq]: https://github.com/ismaelsadeeq
[forecastresult compare]: https://github.com/bitcoin-core-review-club/bitcoin/commit/1e6ce06bf34eb3179f807efbddb0e9bca2d27f28#diff-5baaa59bccb2c7365d516b648dea557eb50e63837de71531dc460dbcc62eb9adR74-R77
