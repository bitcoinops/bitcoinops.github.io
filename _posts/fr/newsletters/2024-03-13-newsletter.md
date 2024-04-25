---
title: 'Bulletin Hebdomadaire Bitcoin Optech #293'
permalink: /fr/newsletters/2024/03/13/
name: 2024-03-13-newsletter-fr
slug: 2024-03-13-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume un post sur les paris sans confiance sur la blockchain pour
les potentiels soft forks et renvoie à un aperçu détaillé de Chia Lisp pour les Bitcoiners. Sont
également incluses nos sections habituelles avec le résumé d'une réunion du Bitcoin Core PR Review Club,
des annonces de mises à jour et versions candidates, ainsi que les changements
apportés aux principaux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **Paris sans confiance sur la blockchain pour les potentiels soft forks :** ZmnSCPxj a
  [posté][zmnscpxj bet] sur Delving Bitcoin un protocole permettant de donner le contrôle d'un UTXO à
  une partie qui prédit correctement si un soft fork particulier sera activé ou non. Par exemple,
  Alice pense qu'un soft fork particulier sera activé et elle est intéressée par l'acquisition de plus
  de bitcoins ; Bob est également intéressé par l'acquisition de plus de bitcoins mais ne pense pas
  que le fork sera activé. Ils conviennent de combiner une certaine quantité de leurs bitcoins, à un
  ratio sur lequel ils sont tous deux d'accord (par exemple, 1:1), de sorte qu'Alice reçoive tous les
  bitcoins combinés si le fork est activé à un certain moment et Bob reçoive tous les bitcoins
  combinés s'il ne l'est pas. Si, avant la date limite, un split de chaîne persistant se produit où
  une chaîne active le fork et l'autre le rejette, Alice reçoit les bitcoins combinés sur la chaîne
  activée et Bob reçoit les bitcoins combinés sur la chaîne où l'activation est rejetée.

  L'idée de base a été proposée auparavant ([exemple][rubin bet]) mais la version de ZmnSCPxj traite
  des spécificités attendues pour au moins un futur soft fork potentiel,
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]. ZmnSCPxj considère également brièvement les
  défis de généralisation de la construction à d'autres soft forks proposés, en particulier ceux qui
  mettent à niveau un opcode `OP_SUCCESSx`.

- **Aperçu de Chia Lisp pour les Bitcoiners :** Anthony Towns a [publié][towns lisp] sur Delving
  Bitcoin un aperçu détaillé de la variante [Lisp][] utilisée par la cryptomonnaie Chia. Towns a
  précédemment proposé une introduction de soft fork d'un langage de script basé sur Lisp pour Bitcoin
  (voir le [Bulletin #191][news191 lisp]). Toute personne intéressée par le sujet est fortement
  encouragée à lire son post.

## Bitcoin Core PR Review Club

*Dans cette section mensuelle, nous résumons une récente réunion du
[Bitcoin Core PR Review Club][] en soulignant certaines des questions
et réponses importantes. Cliquez sur une question ci-dessous pour voir
un résumé de la réponse de la réunion.*

[Re enable `OP_CAT`][review club bitcoin-inquisition 39]
est une PR de Armin Sabouri (GitHub 0xBEEFCAF3) qui réintroduit l'opcode [OP_CAT][topic op_cat]
mais seulement sur [signet][topic signet] [Bitcoin Inquisition][bitcoin inquisition repo] et
uniquement pour [tapscript][topic tapscript] (script taproot).
Satoshi Nakamoto a désactivé cet opcode en 2010, probablement par excès de prudence. L'opération
remplace la fusion des deux éléments supérieurs sur la pile d'évaluation du script avec la concaténation de ces
éléments.

Les motivations pour `OP_CAT` n'ont pas été discutées.

{% include functions/details-list.md
  q0="Quelles sont les différentes conditions selon lesquelles l'exécution de `OP_CAT` peut échouer ?"
  a0="Moins de 2 éléments sur la pile, l'élément résultant est trop grand, interdit par les drapeaux
      de vérification de script (par exemple, le soft fork n'est pas encore activé), et apparaît dans un
      script non-taproot (version de témoin 0 ou héritage)."
  a0link="https://bitcoincore.reviews/bitcoin-inquisition-39#l-46"

  q1="`OP_CAT` redéfinit l'un des opcodes `OP_SUCCESSx`. Pourquoi ne redéfinit-il pas l'un des opcodes
      `OP_NOPx` (qui ont également été utilisés pour mettre en œuvre des mises à jour de soft fork par le
      passé) ?"
  a1="Les opcodes `OP_SUCCESSx` et `OP_NOPx` peuvent être redéfinis pour mettre en œuvre des soft
      forks car ils restreignent les règles de validation (ils réussissent toujours tandis que les opcodes
      redéfinis peuvent échouer). Puisque l'exécution du script continue après un `OP_NOP`, les opcodes
      `OP_NOP` redéfinis ne peuvent pas affecter la pile d'exécution (sinon des scripts qui avaient
      l'habitude d'échouer pourraient réussir, ce qui assouplirait les règles). Les opcodes `OP_SUCCESS`
      redéfinis peuvent affecter la pile, car `OP_SUCCESS` termine immédiatement le script (avec succès).
      Puisque `OP_CAT` doit affecter la pile, il ne peut pas redéfinir l'un des opcodes `OP_NOP`."
  a1link="https://bitcoincore.reviews/bitcoin-inquisition-39#l-33"

  q2="Cette PR ajoute à la fois `SCRIPT_VERIFY_OP_CAT` et `SCRIPT_VERIFY_DISCOURAGE_OP_CAT`. Pourquoi
      les deux sont-ils nécessaires ?"
  a2="Cela permet de mettre en place le soft fork par phases. D'abord, les deux sont définis sur
      `true` (activés par consensus mais non relayés ni minés) jusqu'à ce que la plupart des nœuds du
      réseau soient mis à jour. Ensuite, `SCRIPT_VERIFY_DISCOURAGE_OP_CAT` est défini sur `false` pour
      permettre une utilisation réelle. Si l'expérience Bitcoin Inquisition échoue plus tard, le processus
      peut être inversé. Si les deux sont définis sur `false`, `OP_CAT` est juste `OP_SUCCESS`."
  a2link="https://bitcoincore.reviews/bitcoin-inquisition-39#l-60"
%}

## Mises à jour et versions candidates

*Nouvelles versions et versions candidates pour les principaux projets
d'infrastructure Bitcoin. Veuillez envisager de passer aux nouvelles
versions ou d'aider à tester les versions candidates.*

- [Core Lightning v24.02.1][] est une mise à jour mineure de ce nœud LN contenant "quelques
  corrections mineures [et] améliorations dans la fonction de coût de l'algorithme de routage."

- [Bitcoin Core 26.1rc1][] est un candidat à la sortie pour une version de maintenance de
  l'implémentation de nœud complet prédominante du réseau.

- [Bitcoin Core 27.0rc1][] est un candidat à la sortie pour la prochaine version majeure de
  l'implémentation de nœud complet prédominante du réseau.

## Changements notables dans le code et la documentation

_Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
[Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust
Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo], [Propositions
d'Amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Inquisition
Bitcoin][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [LND #8136][] met à jour le RPC `EstimateRouteFee` pour accepter une facture et un délai
  d'attente. Une route pour payer la facture sera sélectionnée et une [sonde de paiement][topic
  payment probes] sera envoyée. Si la sonde se termine avec succès avant que le délai d'attente ne
  soit atteint, le coût d'utilisation de la route choisie sera retourné. Sinon, une erreur sera
  retournée.

- [LND #8499][] apporte des modifications significatives aux types Type-Length-Value (TLV)
  utilisés pour [les canaux taproot simples][topic simple taproot channels] afin d'améliorer l'API de
  LND pour cela. Nous ne sommes pas au courant d'autres implémentations LN utilisant actuellement les
  canaux taproot simples, mais si certaines les utilisent, soyez conscients que cela peut constituer
  un changement majeur.

- [LDK #2916][] ajoute une API simple pour convertir une préimage de paiement en un hachage de
  paiement. Une facture LN inclut un hachage de paiement ; pour réclamer un paiement, le destinataire
  final libère la préimage correspondant à ce hachage (et chaque saut le long du chemin utilise la
  préimage qu'il reçoit de son pair en aval pour réclamer le paiement de son pair en amont). Puisqu'un
  hachage peut être dérivé d'une préimage (mais pas l'inverse), les destinataires et les nœuds de
  transfert peuvent uniquement stocker la préimage. Cette API leur permet de dériver facilement le
  hachage à la demande.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="8136,8499,2916" %}
[zmnscpxj bet]: https://delvingbitcoin.org/t/economic-majority-signaling-for-op-ctv-activation/635
[rubin bet]: https://blog.bitmex.com/taproot-you-betcha/
[news191 lisp]: /en/newsletters/2022/03/16/#using-chia-lisp
[towns lisp]: https://delvingbitcoin.org/t/chia-lisp-for-bitcoiners/636
[lisp]: https://en.wikipedia.org/wiki/Lisp_(programming_language)
[Bitcoin Core 26.1rc1]: https://bitcoincore.org/bin/bitcoin-core-26.1/
[Bitcoin Core 27.0rc1]: https://bitcoincore.org/bin/bitcoin-core-27.0/test.rc1/
[Core Lightning v24.02.1]: https://github.com/ElementsProject/lightning/releases/tag/v24.02.1
[review club bitcoin-inquisition 39]: https://bitcoincore.reviews/bitcoin-inquisition-39
