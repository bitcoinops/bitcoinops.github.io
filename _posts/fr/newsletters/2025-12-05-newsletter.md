---
title: 'Bulletin Hebdomadaire Bitcoin Optech #383'
permalink: /fr/newsletters/2025/12/05/
name: 2025-12-05-newsletter-fr
slug: 2025-12-05-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine décrit une vulnérabilité corrigée affectant la bibliothèque NBitcoin.
Sont également incluses nos sections régulières résumant les récentes discussions sur
la modification des règles de consensus de Bitcoin, annonçant des mises à jour et des versions candidates,
et décrivant les changements notables dans les projets d'infrastructure Bitcoin populaires.

## Nouvelles

- **Bug de consensus dans la bibliothèque NBitcoin :** Bruno Garcia a [posté][bruno delving] sur
  Delving Bitcoin à propos d'une défaillance théorique du consensus dans NBitcoin qui pourrait se
  produire lors de l'utilisation de `OP_NIP`. Lorsque le tableau sous-jacent est à pleine capacité et
  que `_stack.Remove(-2)` est appelé, l'opération Remove supprime l'élément à l'indice 14 puis tente
  de décaler les éléments suivants vers le bas. Pendant ce décalage, l'implémentation peut essayer
  d'accéder à `_array[16]`, qui n'existe pas, conduisant à une exception.

  Ce bug a été trouvé grâce au [differential fuzzing][diff fuzz], et puisque l'échec a été capturé
  dans un bloc try/catch, il n'aurait peut-être jamais été trouvé avec des techniques de fuzzing
  traditionnelles. Après avoir trouvé le problème, Bruno Garcia l'a signalé à Nicolas Dorier le 23
  octobre 2025. Le même jour, Nicolas Dorier a confirmé le problème et ouvert un [patch][nbitcoin
  patch] pour le résoudre. Il n'existe aucune implémentation de nœud complet utilisant NBitcoin, donc
  il n'y a pas de risque de scission de la chaîne, c'est pourquoi la divulgation a été faite
  rapidement.

## Modification du consensus

_Une nouvelle section mensuelle résumant les propositions et discussions sur la modification des
règles de consensus de Bitcoin._

- **Soft fork LNHANCE :** Moonsettler [propose][ms ml lnhance] un soft fork pour LNHANCE maintenant
  que les quatre opcodes qui le constituent ont des BIPs mis à jour et des implémentations de
  référence. [BIP119][] ([OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]), [BIP348][]
  ([OP_CHECKSIGFROMSTACK][topic op_checksigfromstack]), [BIP349][] (OP_INTERNALKEY), et [BIPs #1699][]
  (OP_PAIRCOMMIT) ajoutent des signatures ré-associables et des multi-engagements à [tapscript][topic
  tapscript], et des engagements de transaction suivants à toutes les versions de Script. Un opcode
  similaire uniquement pour le [package][gs ml thikcs] tapscript incluant `OP_TEMPLATEHASH` a été
  [récemment proposé][news365 oth] et possède des capacités similaires, mais sans multi-engagements
  généraux et, étant plus récent, attend davantage de retours et de révisions.

- **Benchmarking du budget Varops :** Julian a [posté][j ml varops] un appel à l'action pour
  benchmark le script Bitcoin sous le [budget varops][bip varops]. L'équipe de Restauration de Script
  (voir le [Bulletin #374][news374 gsr]) demande que les utilisateurs exécutent leur [benchmark][j gh
  bench] et partagent les résultats provenant d'une grande variété de matériel et de systèmes
  d'exploitation pour confirmer ou améliorer les paramètres varops choisis. En réponse à Russell
  O'Connor, Julian a également clarifié que le budget varops serait utilisé au lieu de (et non en plus
  de) le budget sigops dans la nouvelle version de [tapscript][topic tapscript].

- **Optimisations de signature post-quantique SLH-DSA (SPHINCS)** : Poursuivant les discussions sur
  le renforcement de Bitcoin pour la [résistance quantique][topic quantum resistance], conduition a
  [présenté][c ml sphincs] son travail sur l'optimisation de l'algorithme de signature SPHINCS. Ces
  optimisations nécessitent plusieurs mégaoctets de RAM et des shaders compilés localement (code
  machine hautement optimisé, spécifique au CPU---soit mis en cache de manière durable ou calculé au
  démarrage). Lorsqu'applicable, les opérations de signature et de génération de clés SPHINCS
  optimisées sont un ordre de grandeur plus rapides que l'état précédent de l'art et seulement deux
  ordres de grandeur plus lentes que les opérations sur courbes elliptiques. Plus important encore, la
  vérification de signature optimisée est approximativement aussi rapide que la vérification de
  signature sur courbes elliptiques.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates._

- [Core Lightning v25.12][] est une version de cette importante mise en œuvre de LN qui ajoute les
  phrases de semence mnémonique [BIP39][] comme nouvelle méthode de sauvegarde par défaut, améliore le
  cheminement, ajoute un support expérimental pour les [canaux JIT][topic jit channels], et de
  nombreuses autres fonctionnalités et corrections de bugs. En raison de changements importants dans
  la base de données, cette version inclut un outil de rétrogradation en cas de problème (voir
  ci-dessous pour plus d'informations).

- [LDK 0.2][] est une version majeure de cette bibliothèque pour construire des applications
  Lightning qui ajoute le support pour le [splicing][topic splicing] (expérimental), servant et payant
  des factures statiques pour les [paiements asynchrones][topic async payments], les canaux
  [zero-fee-commitment][topic v3 commitments] utilisant des [ancres éphémères][topic ephemeral
  anchors] ainsi que de nombreuses autres fonctionnalités, corrections de bugs et améliorations de
  l'API.

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning
repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo],
[Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Propositions d'Amélioration de Bitcoin (BIPs)][bips
repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Inquisition Bitcoin][bitcoin
inquisition repo], et [BINANAs][binana repo]._

- [Core Lightning #8728][] corrige un bug qui provoquait le crash de `hsmd` lorsqu'un utilisateur
  entrait le mauvais mot de passe ; il gère maintenant correctement ce cas d'erreur utilisateur et se
  ferme proprement.

- [Core Lightning #8702][] ajoute un outil `lightningd-downgrade` qui rétrograde la version de la
  base de données de 25.12 à la précédente 25.09 en cas d'erreur de mise à niveau.

- [Core Lightning #8735][] corrige un bug de longue date où certaines dépenses sur la chaîne
  pouvaient disparaître de la vue de CLN lors d'un redémarrage. Au démarrage, CLN revient sur les 15
  derniers blocs (par défaut), réinitialise la hauteur de dépense des UTXOs dépensés dans ces blocs à
  `null`, puis effectue un nouveau scan. Auparavant, CLN échouait à surveiller à nouveau ces UTXOs, ce
  qui pourrait causer à CLN de continuer à relayer des [annonces de canaux][topic channel announcements]
  qui avaient déjà été clôturées, ou pour manquer des dépenses importantes onchain. Cette PR garantit que
  ces UTXOs sont surveillés à nouveau lors du démarrage et ajoute un scan rétroactif unique pour récupérer
  toutes les dépenses qui ont été précédemment manquées en raison de ce bug.

- [LDK #4226][] commence à valider le montant et les champs CLTV des paiements en oignon
  [trampoline][topic trampoline payments] reçus contre un oignon externe. Il
  ajoute également trois nouvelles raisons d'échec locales :
  `TemporaryTrampolineFailure`,`TrampolineFeeOrExpiryInsufficient`, et
  `UnknownNextTrampoline` comme premier pas vers le support du transfert de paiement
  trampoline.

- [LND #10341][] corrige un bug où la même adresse oignon [Tor][topic anonymity networks]
  était dupliquée dans l'annonce du nœud et dans la sortie `getinfo`
  chaque fois que le service caché était redémarré. La PR assure que la
  fonction `createNewHiddenService` ne duplique jamais une adresse.

- [BTCPay Server #6986][] introduit `Monetization`, qui permet aux administrateurs de serveur
  d'exiger un `Subscription` (voir le [Bulletin #379][news379 btcpay]) pour la connexion utilisateur.
  Cette fonctionnalité permet aux ambassadeurs, utilisateurs de Bitcoin qui intègrent de nouveaux
  utilisateurs et commerçants dans des contextes locaux, de monétiser leur travail. Il y a une période d'essai
  gratuite par défaut de sept jours et un plan gratuit pour débutants ; cependant, les abonnements
  sont personnalisables. Les utilisateurs existants ne seront pas automatiquement inscrits à un
  abonnement, bien qu'ils puissent être migrés plus tard.

- [BIPs #2015][] ajoute des vecteurs de test à [BIP54][], la proposition de [nettoyage du
  consensus][topic consensus cleanup], en introduisant un ensemble de vecteurs pour chacune des
  quatre atténuations. Les vecteurs sont générés à partir de l'implémentation [BIP54][]
  dans Bitcoin Inquisition et un test unitaire de minage Bitcoin Core personnalisé, et sont
  documentés avec des instructions pour leur utilisation dans l'implémentation et la révision.
  Voir le [Bulletin #379][news379 bip54] pour un contexte supplémentaire.

{% include snippets/recap-ad.md when="2025-12-09 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1699,8728,8702,8735,4226,10341,6986,2015" %}
[ms ml lnhance]: https://groups.google.com/g/bitcoindev/c/AlMqLbmzxNA
[gs ml thikcs]: https://groups.google.com/g/bitcoindev/c/5wLThgegha4/m/iUWIZPIaCAAJ
[j ml varops]: https://groups.google.com/g/bitcoindev/c/epbDDH9MHNw/m/OUrIeSHmAAAJ
[news365 oth]: /fr/newsletters/2025/08/01/#proposition-de-op-templatehash-natif-a-taproot
[news374 gsr]: /fr/newsletters/2025/10/03/#brouillons-de-bip-pour-la-restauration-de-script
[bip varops]: https://github.com/rustyrussell/bips/blob/guilt/varops/bip-unknown-varops-budget.mediawiki
[j gh bench]: https://github.com/jmoik/bitcoin/blob/gsr/src/bench/bench_varops.cpp
[c ml sphincs]: https://groups.google.com/g/bitcoindev/c/LAll07BHwjw/m/2k7o2VKwAQAJ
[bruno delving]: https://delvingbitcoin.org/t/consensus-bug-on-nbitcoin-out-of-bound-issue-in-remove/2120
[nbitcoin patch]: https://github.com/MetacoSA/NBitcoin/pull/1288
[diff fuzz]: https://github.com/bitcoinfuzz/bitcoinfuzz
[LDK 0.2]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.2
[news379 btcpay]: /fr/newsletters/2025/11/07/#btcpay-server-6922
[news379 bip54]: /fr/newsletters/2025/11/07/#implementation-de-bip54-et-vecteurs-de-test
[Core Lightning v25.12]: https://github.com/ElementsProject/lightning/releases/tag/v25.12