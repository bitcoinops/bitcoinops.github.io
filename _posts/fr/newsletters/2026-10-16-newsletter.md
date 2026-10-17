---
title: 'Bulletin Hebdomadaire Bitcoin Optech #427'
permalink: /fr/newsletters/2026/10/16/
name: 2026-10-16-newsletter-fr
slug: 2026-10-16-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume la divulgation de deux vulnérabilités de déni de service dans d'anciennes versions d'Eclair et décrit un
schéma proposé pour exécuter des contrats complexes à plusieurs tours à l'intérieur de canaux Lightning. Sont également incluses nos
rubriques habituelles annonçant de nouvelles versions et versions candidates et décrivant les changements notables dans les logiciels
populaires d'infrastructure Bitcoin.

## Nouvelles

- **Divulgation de deux vulnérabilités DoS corrigées dans Eclair v0.14.1** : Erick Cestari a [publié][ec eclair dos] sur Delving Bitcoin la
  [divulgation responsable][topic responsible disclosures] de deux vulnérabilités de déni de service (DoS) dans le processus d'ouverture de
  canal d'Eclair v0.14.0 et des versions antérieures. Les deux ont été corrigées dans [Eclair #3324][] et publiées dans [v0.14.1][news416
  eclair 0.14.1] en juillet, et les utilisateurs exécutant une version plus ancienne devraient effectuer une mise à niveau.

  La première, trouvée par Matt Morehouse avec son fuzzer [smite][smite repo], est une condition de course dans une vérification de
  `temporary_channel_id` dupliqué. Eclair vérifiait si l'ID était déjà utilisé avant d'accepter un message `open_channel`, mais
  n'enregistrait pas le nouveau canal avant une étape ultérieure, de sorte qu'un attaquant envoyant plusieurs messages `open_channel`
  identiques en succession rapide pouvait en faire passer deux après la vérification. Eclair créait alors deux états de canal pour un seul
  ID, et le second remplaçait le premier, laissant un état de canal inaccessible qui conservait environ 25 kB de mémoire jusqu'à ce que le
  pair se déconnecte. Répéter l'attaque provoquait une fuite d'environ 1 Mo par seconde jusqu'à ce que le nœud manque de mémoire ou consacre
  tout son CPU au ramasse-miettes.

  La seconde, trouvée par Cestari, contourne la limite d'Eclair sur le nombre de canaux en attente dont la transaction de financement n'a
  pas été confirmée. La vérification des doublons ne regardait que les IDs temporaires, donc un attaquant pouvait commencer à ouvrir un
  canal, puis réutiliser le `channel_id` final de ce canal comme `temporary_channel_id` du `open_channel` suivant. Le limiteur comptait l'ID
  réutilisé deux fois et supprimait les deux entrées une fois que le nouveau canal recevait son ID final, de sorte que son compteur ne
  dépassait jamais deux alors que le nombre de canaux en attente augmentait sans borne. Chaque canal en attente stocke une copie des
  fonctionnalités `init` du pair, et définir un seul bit de fonctionnalité impair inconnu à une position très élevée gonflait cette copie à
  environ 65 kB. Dans le test de Cestari, une connexion sans coût onchain épuisait les 4 Go de mémoire d'un nœud en environ 48 minutes.
  Comme les canaux en attente sont écrits dans la base de données, le nœud plantait à nouveau à chaque redémarrage jusqu'à ce que sa limite
  de mémoire soit augmentée ou que les lignes soient supprimées à la main.

  En réponse à une question, Morehouse a noté que les portefeuilles mobiles qui utilisent un nœud Eclair comme leur LSP, tels que Phoenix,
  ne sont pas affectés parce qu'ACINQ a corrigé ses nœuds il y a des mois.

- **Contrats hors chaîne dans les canaux Lightning** : Adam Gibson a [publié][lngap ml] sur la liste de diffusion Bitcoin-Dev à propos d'une
  proposition de protocole, appelée LN-GAP, pour exécuter des contrats complexes, à plusieurs tours, entre deux parties, à l'intérieur d'un
  canal Lightning tout en réglant les litiges onchain avec un nombre constant de transactions. Afin d'illustrer la proposition, Gibson a
  implémenté un jeu d'échecs, qu'il considère comme un bon exemple de jeu difficile à exécuter onchain, dans lequel le vainqueur remporte
  toute la cagnotte. Un [dépôt][lngap repo] et un [article][lngap paper] pour la proposition sont disponibles.

  Deux joueurs, Alice et Bob, s'accordent sur un certain ensemble de règles. Chaque joueur effectue ses propres coups. En cas de litige,
  Alice peut faire appliquer les règles onchain. Cependant, Gibson note que Lightning peut faire respecter des règles concernant un état
  publié, mais ne peut pas le faire dans le cas où une contrepartie temporise ou cesse de répondre. Pour résoudre ce problème, Gibson
  introduit une instance, un comité de membres dont le rôle est d'attester si un message signé (un coup dans une partie d'échecs et sa
  signature) a été publié avant une certaine échéance ou non. L'instance n'a besoin d'attester que de la ponctualité de la publication, pas du
  contenu du message. En cas de litige, Alice publie une transaction affirmant qu'aucun événement n'a été publié par Bob ; en retour, Bob
  peut publier une seconde transaction contenant une réfutation (son coup et l'attestation du venue) ; enfin, Alice peut publier une
  invalidation, déclarant que la réfutation de Bob ne tient pas parce que l'événement n'est pas conforme aux règles.

  Dans la proposition de Gibson, l'instance ne détient jamais les fonds des utilisateurs. De plus, elle évite de s'appuyer sur une signature à
  seuil de style FROST afin de rendre la fraude attribuable uniquement aux membres malveillants. Pour ce faire, l'attestation est effectuée
  au moyen de « signatures d'un bit » par membre vérifiées à l'aide de `OP_CHECKSIGADD`. Les membres sont incités par des frais payés
  atomiquement via des canaux en utilisant des [adaptateurs][topic adaptor signatures]. Cependant, la construction repose sur une hypothèse
  de majorité honnête. Si plus de la moitié des membres de l'instance colludent avec l'une des parties impliquées, les fonds peuvent être volés.

  En dehors des jeux, les applications possibles incluent des contrats de preuve de stockage, où un fournisseur perd une caution s'il ne
  répond pas à un défi, et une résolution de litiges hors chaîne similaire à ce que les vérificateurs à connaissance nulle de style
  [BitVMX][topic acc] font onchain.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires. Veuillez envisager de mettre à niveau vers
les nouvelles versions ou d'aider à tester les versions candidates._

- [Bitcoin Core 32.0rc4][] est une version candidate pour la prochaine version majeure de l'implémentation de nœud complet prédominante. Un
  [guide de test][bcc32 testing] est disponible.

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet Interface (HWI)][hwi repo], [Rust Bitcoin][rust
bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], [Lightning
BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Eclair #3396][], [#3397][eclair #3397], et [#3400][eclair #3400] corrigent plusieurs façons dont un pair de canal malveillant pouvait
  empêcher Eclair de faire appliquer des [HTLCs][topic htlc] onchain pendant le [splicing][topic splicing] (voir le [Bulletin #423][news423
  eclair splice]). Auparavant, un pair pouvait amener Eclair à signer une transaction de splice qui ne pouvait pas être publiée rapidement
  en choisissant un verrouillage absolu éloigné, en ajoutant des entrées avec des [verrouillages relatifs][topic timelocks], en fournissant
  des témoins non standards, en dépassant la limite standard de poids de transaction, ou en définissant un taux de frais trop faible pour la
  transaction signée. La première PR ajoute des vérifications pour ces cas. La seconde fait réessayer à Eclair les transactions d'engagement
  et les [transactions de pénalité][topic ln-penalty] qui ont été rejetées par une transaction conflictuelle non confirmée, car le pair peut
  plus tard remplacer cette transaction via [RBF][topic rbf] en faisant une double dépense de l'une de ses autres entrées. Le correctif de
  nouvelle tentative s'applique également lorsque la transaction de financement du canal n'est pas confirmée, y compris les [canaux zero-conf][topic
  zero-conf channels]. La troisième corrige une autre lacune de récupération : si un remplacement RBF d'un splice est confirmé après
  qu'Eclair a forcé la fermeture en utilisant un engagement pour une tentative sœur, Eclair reconnaît désormais que la transaction de
  financement a changé et diffuse une transaction d'engagement qui dépense la sortie du splice confirmé. Auparavant, les fonds pouvaient
  rester bloqués et les HTLCs ne pas être appliqués.

- [Eclair #3399][] et [#3394][eclair #3394] corrigent deux façons dont le [financement à la volée][topic jit channels] pouvait laisser
  Eclair payer un pair en aval sans encaisser le [HTLC][topic htlc] entrant correspondant (voir Le [Bulletin #419][news419 eclair funding]).
  Auparavant, après qu'Eclair avait cessé de suivre un paiement expiré, un nouveau paiement pouvait réutiliser son hash de paiement. Si le
  pair en aval réclamait alors onchain le HTLC sortant original, révélant la préimage, Eclair pouvait par erreur régler les HTLCs entrants
  du paiement plus récent au lieu de ceux d'origine, permettant aux HTLCs entrants d'origine d'expirer sans payer Eclair. La première PR
  vérifie maintenant si un règlement appartient au paiement actuellement suivi et, si ce n'est pas le cas, elle utilise les détails du HTLC
  entrant conservés avec le règlement pour régler les HTLCs corrects. La seconde PR garantit que les paiements financés ne sont relayés que
  sur le canal où la liquidité a été achetée. Auparavant, Eclair pouvait relayer via un autre canal avec le même pair, mais ne vérifiait que
  le canal financé avant d'échouer en amont à l'expiration, même si le HTLC sortant sur l'autre canal restait réclamable.

- [Eclair #3395][] corrige un bug où un dépensier pouvait construire un paquet onion de paiement mal formé avec un HMAC valide qui laissait
  un [HTLC][topic htlc] entrant non résolu. Le dépensier pouvait encoder une longueur de charge utile par saut supérieure à la capacité
  réelle du paquet tout en fournissant un HMAC valide. Auparavant, Eclair ne validait pas la longueur avant d'extraire le HMAC suivant,
  provoquant une exception non interceptée. Le relai reprenait alors sans faire échouer le HTLC, et le paquet mal formé pouvait aussi
  empêcher l'initialisation du nettoyage des HTLC après un redémarrage. Désormais, Eclair vérifie que la charge utile par saut, y compris
  son HMAC, tient dans le paquet. Si ce n'est pas le cas, Eclair renvoie `InvalidOnionVersion`, permettant une gestion normale de l'échec.

- [Eclair #3401][] corrige un bug qui pouvait amener un nœud de transfert à perdre des fonds après une déconnexion. Eclair stocke des
  instructions pour régler ou échouer des [HTLCs][topic htlc] jusqu'à ce que les mises à jour de canal correspondantes soient signées, ce
  qui permet de les réessayer après reconnexion. Auparavant, si une instruction dupliquée ou conflictuelle était rejetée parce qu'un
  règlement avait déjà été proposé mais pas signé, Eclair planifiait la suppression de l'instruction originale stockée. Si le canal se
  déconnectait avant la signature, la mise à jour non signée était abandonnée, ne laissant aucune instruction à rejouer pour le règlement.
  Le HTLC entrant pouvait alors expirer même si le HTLC sortant avait déjà été réglé. Eclair conserve désormais l'instruction d'origine
  jusqu'à ce que le règlement soit signé.

- [LDK #5080][] corrige un bug où un redémarrage pendant une fermeture coopérative de canal pouvait empêcher les [HTLCs][topic htlc] en
  attente d'être renvoyés en échec à leur pair en amont. Auparavant, lors du redémarrage de LDK, il excluait les canaux en cours de
  fermeture coopérative de la recherche utilisée pour traiter les HTLCs, même si ces canaux pouvaient encore avoir des paiements non
  résolus. En conséquence, lorsqu'un pair en aval faisait échouer un HTLC, LDK pouvait traiter à tort le canal en amont comme inexistant et
  supprimer l'échec. LDK pouvait également abandonner des HTLCs entrants en attente de décodage onion. Cela pouvait laisser des HTLCs non
  résolus jusqu'à ce que le pair en amont force la fermeture du canal à l'expiration. LDK inclut désormais les canaux en cours d'arrêt lors
  de la restauration des informations nécessaires pour résoudre les HTLCs existants.

- [LDK #5087][] corrige une fuite potentielle de confidentialité dans les [messages onion][topic onion messages] envoyés via des [chemins
  aveuglés][topic rv routing] qui utilisent des sauts factices (voir Le [Bulletin #370][news370 dummy hops]). Les sauts factices sont des
  couches chiffrées supplémentaires que le destinataire traite pour masquer sa position dans le chemin. Auparavant, les sauts de transfert
  rejetaient les couches onion intermédiaires contenant des enregistrements TLV de contenu de message, mais les sauts factices les
  acceptaient. Un expéditeur malveillant pouvait insérer ces enregistrements à différentes couches non finales et observer si le message
  final produisait une réponse, révélant potentiellement où le transfert réel se terminait et où les sauts factices commençaient. LDK
  rejette désormais aussi les enregistrements de contenu de message aux sauts factices.

- [LND #11068][] corrige une vérification manquante des signatures auxiliaires de [HTLC][topic htlc] sur les canaux overlay taproot
  expérimentaux utilisés pour [Taproot Assets][topic client-side validation] (voir le [Bulletin #324][news324 overlay]). Dans ces canaux, un
  signataire Taproot Assets (`tapd`) fournit une entrée de signature supplémentaire pour chaque HTLC non-[poussière][topic uneconomical
  outputs] en plus des signatures Bitcoin habituelles. Auparavant, si un pair envoyait un engagement contenant les signatures Bitcoin
  requises mais omettait une partie ou la totalité des entrées de signature auxiliaire HTLC, le nœud LND récepteur l'acceptait à tort. Si le
  canal est ensuite fermé de force, les signatures manquantes pourraient empêcher les HTLCs d'actifs affectés d'être résolus onchain. LND
  vérifie désormais que le nombre d'entrées de signature auxiliaire reçues correspond au nombre de HTLCs non-poussière. S'ils diffèrent, LND
  rejette l'engagement et force la fermeture du canal.

- [Rust Bitcoin #6956][] introduit un type `ScriptCode` pour les données de script utilisées dans le hachage de signature legacy et segwit
  v0, qui peuvent différer du script complet en cours de dépense. Selon [BIP143][], lorsqu'un script P2WSH contient [OP_CODESEPARATOR][topic
  OP_CODESEPARATOR], le hachage de signature exclut tout jusqu'au dernier séparateur exécuté avant la vérification de signature
  inclusivement, tout en conservant les éventuels séparateurs suivants. Auparavant, `p2wsh_signature_hash` acceptait un script témoin, ce
  qui pouvait amener les appelants à hacher le script complet et à produire une signature invalide. L'API accepte maintenant `ScriptCode`,
  mais les appelants doivent toujours identifier eux-mêmes le dernier séparateur exécuté et raccourcir le script. La PR ajoute également
  `P2wpkhScriptCode`, une représentation à taille fixe, sans allocation, du script standard utilisé pour signer les entrées P2WPKH.

- [BDK #2319][] corrige un bug où un portefeuille reposant sur Electrum pouvait perdre la trace de la confirmation d'une transaction après
  une réorganisation si la même transaction était minée à nouveau à la même hauteur. BDK pouvait conserver dans son cache l'en-tête du bloc
  évincé et ne pas reconnaître la confirmation de la transaction dans le bloc de remplacement, l'affichant à tort comme non confirmée. Le
  correctif rafraîchit le cache des en-têtes avec les en-têtes de bloc nouvellement récupérés pendant la synchronisation, y compris après
  une réorganisation d'un bloc.

{% include snippets/recap-ad.md when="2026-10-20 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3324,3396,3397,3400,3399,3394,3395,3401,5080,5087,11068,6956,2319" %}

[ec eclair dos]: https://delvingbitcoin.org/t/disclosure-dos-vulnerabilities-fixed-in-eclair-v0-14-1/2928
[news416 eclair 0.14.1]: /fr/newsletters/2026/07/31/#eclair-0-14-1
[smite repo]: https://github.com/lnfuzz/smite
[lngap ml]: https://groups.google.com/g/bitcoindev/c/pjv6bL_42kg
[lngap repo]: https://github.com/AdamISZ/ln-gap
[lngap paper]: https://github.com/AdamISZ/ln-gap/blob/master/docs/paper/lngap-short.pdf
[Bitcoin Core 32.0rc4]: https://bitcoincore.org/bin/bitcoin-core-32.0/test.rc4/
[bcc32 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/32.0-Release-Candidate-Testing-Guide
[LDK #5080]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5080
[LDK #5087]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5087
[news324 overlay]: /fr/newsletters/2024/10/11/#lnd-8960
[news370 dummy hops]: /fr/newsletters/2025/09/05/#ldk-3726
[news423 eclair splice]: /fr/newsletters/2026/09/18/#eclair-3376
[news419 eclair funding]: /fr/newsletters/2026/08/21/#eclair-3351
