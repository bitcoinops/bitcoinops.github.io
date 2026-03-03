---
title: 'Bulletin Hebdomadaire Bitcoin Optech #373'
permalink: /fr/newsletters/2025/09/26/
name: 2025-09-26-newsletter-fr
slug: 2025-09-26-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume une vulnérabilité affectant les anciennes versions d'Eclair et
résume les recherches sur les paramètres de taux de frais des nœuds complets.
Sont également incluses nos sections régulières résumant les récentes questions et réponses de Bitcoin
Stack Exchange, annoncant de nouvelles versions et des candidats à la publication, ainsi que les
résumés des modifications notables apportées aux logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

- **Vulnérabilité Eclair :** Matt Morehouse a [posté][morehouse eclair] sur Delving Bitcoin pour
	annoncer la [divulgation responsable][topic responsible disclosures] d'une vulnérabilité affectant
	les anciennes versions d'Eclair. Il est recommandé à tous les utilisateurs d'Eclair de mettre à
	niveau vers la version 0.12 ou supérieure. La vulnérabilité permettait à un attaquant de diffuser
	une ancienne transaction d'engagement pour voler tous les fonds actuels d'un canal. En plus de
	corriger la vulnérabilité, les développeurs d'Eclair ont ajouté une suite de tests complète conçue
	pour détecter des problèmes similaires.

- **Recherche sur les paramètres de taux de frais :** Daniela Brozzoni a [posté][brozzoni feefilter]
	sur Delving Bitcoin les résultats d'un scan de près de 30 000 nœuds complets acceptant des
	connexions entrantes. Chaque nœud a été interrogé sur son filtre de frais [BIP133][], qui indique le
	taux de frais minimum auquel il acceptera actuellement de relayer des transactions non confirmées.
	Lorsque les mémoires tampons des nœuds ne sont pas pleines, il s'agit du [taux de frais minimum de
	relais de transaction par défaut du nœud][topic default minimum transaction relay feerates]. Ses
	résultats indiquent que la plupart des nœuds utilisent le défaut de 1 sat/vbyte (s/v), qui est
	depuis longtemps le défaut dans Bitcoin Core. Environ 4 % des nœuds utilisaient 0.1 s/v, le défaut
	pour la version 30.0 à venir de Bitcoin Core, et environ 8 % des nœuds n'ont pas répondu à la
	requête, indiquant qu'ils pourraient être des nœuds espions.

	Un petit pourcentage des nœuds utilisait une valeur de feefilter de 9 170 997 (10 000 s/v), valeur
	que le développeur 0xB10C a [noté][0xb10c feefilter] être celle que Bitcoin Core définit, par
	arrondissement, lorsque le nœud est à plus de 100 blocs derrière la pointe de la chaîne et se
	concentre sur la réception de données de bloc plutôt que sur des transactions qui pourraient être
	confirmées dans des blocs ultérieurs.

## Questions et réponses sélectionnées de Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech
cherchent des réponses à leurs questions---ou quand nous avons quelques moments libres pour aider
les utilisateurs curieux ou confus. Dans cette rubrique mensuelle, nous mettons en lumière certaines
des questions et réponses les mieux votées postées depuis notre dernière mise à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer-->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Implications des changements OP_RETURN dans la prochaine version 30.0 de Bitcoin Core ?]({{bse}}127895)
	Pieter Wuille décrit ses perspectives sur l'efficacité et les inconvénients de l'utilisation de la
	[politique de mempool et de relais][policy series] pour affecter le contenu des blocs minés.

- [Si les limites de relais OP_RETURN sont inefficaces, pourquoi supprimer la protection au lieu de la conserver comme découragement par défaut ?]({{bse}}127904)
	Antoine Poinsot explique le mauvais incitatif créé par la valeur limite par défaut actuelle
	d'OP_RETURN dans Bitcoin Core et la raison de sa suppression.

- [Quels sont les pires scénarios de stress pour les OP_RETURN non plafonnés dans Bitcoin Core v30 ?]({{bse}}127914)
	Vojtěch Strnad et Pieter Wuille répondent à une liste de scénarios extrêmes qui
	pourraient se produire avec le changement de politique de limite par défaut d'OP_RETURN.

- [Si OP_RETURN avait besoin de plus d'espace, pourquoi le plafond de 80 octets a-t-il été supprimé au lieu d'être augmenté à 160 ?]({{bse}}127915)
	Ava Chow et Antoine Poinsot exposent les considérations contre une valeur par défaut d'OP_RETURN
	de 160 octets, incluant une aversion à fixer continuellement le plafond, les grands mineurs existants
	contournant déjà le plafond, et les risques de ne pas anticiper l'activité future sur la chaîne.

- [Si les données arbitraires sont inévitables, est-ce que supprimer les limites d'OP_RETURN déplace la demande vers des méthodes de stockage plus nuisibles (comme les adresses gonflant l'UTXO) ?]({{bse}}127916)
	Ava Chow souligne que la suppression de la limite d'OP_RETURN offre des incitations à utiliser une
	alternative moins nuisible pour le stockage des données de sortie dans certaines situations.

- [Si le déplafonnement d'OP_RETURN n'augmente pas l'ensemble UTXO, comment contribue-t-il encore au gonflement de la blockchain et à la pression de centralisation ?]({{bse}}127912)
	Ava Chow explique comment l'utilisation accrue des sorties OP_RETURN affecte l'utilisation des
	ressources des nœuds Bitcoin.

- [Comment le déplafonnement d'OP_RETURN impacte-t-il la qualité du marché des frais à long terme et le budget de sécurité ?]({{bse}}127906)
	Ava Chow répond à une série de questions sur l'utilisation hypothétique d'OP_RETURN et son impact
	sur les revenus futurs de minage de Bitcoin.

- [Assurance que la blockchain ne souffrira pas de contenu illégal avec OP_RETURN de 100KB ?]({{bse}}127958)
	L'utilisateur jb55 fournit plusieurs exemples de schémas d'encodage possibles pour
	les données, concluant "Donc non, en général, vous ne pouvez pas vraiment arrêter ce genre de choses
	dans un réseau décentralisé résistant à la censure."

- [Quelle analyse montre que le déplafonnement d'OP_RETURN ne nuira pas à la propagation des blocs ou au risque d'orphelins ?]({{bse}}127905)
	Ava Chow souligne que bien qu'il n'existe pas de jeu de données isolant spécifiquement les grands
	OP_RETURN, les analyses précédentes des [blocs compacts][topic compact block relay] et des blocs
	obsolètes indiquent qu'il n'y a pas de raison de s'attendre à ce qu'ils se comportent différemment.

- [Où Bitcoin Core conserve-t-il les clés d'obfuscation XOR pour les fichiers de données de blocs et les index de bases de données LevelDB ?]({{bse}}127927)
	Vojtěch Strnad note que la clé chainstate est stockée dans LevelDB sous la clé "\000obfuscate_key"
	et la clé de données de blocs et d'annulation est stockée dans le fichier blocks/xor.dat.

- [Quelle est la robustesse de la transmission de transaction 1p1c dans bitcoin core 28.0 ?]({{bse}}127873)
	Glozow clarifie que le manque de robustesse mentionné dans la PR originale de relai opportuniste
	[one parent one child (1P1C)][28.0 1p1c] signifie "pas garanti de fonctionner, particulièrement
	en présence d'adversaires ou lorsque le volume est vraiment élevé donc nous manquons des choses."

- [Comment puis-je permettre à getblocktemplate d'inclure des transactions sous 1 sat/vbyte ?]({{bse}}127881)
	L'utilisateur inersha découvre les paramètres requis non seulement pour relayer des transactions
	sous 1 sat/vbyte mais aussi pour les inclure dans un modèle de bloc candidat.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates._

- [Bitcoin Core 30.0rc1][] est un candidat à la version pour la prochaine version majeure de ce
	logiciel de nœud de vérification complète. Veuillez consulter le [guide de test du candidat à la
	version 30][bcc30 testing].

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core
lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust
Bitcoin][rust bitcoin repo], [Serveur BTCPay][btcpay server repo], [BDK][bdk repo], [Propositions
d'Amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips
repo], [Inquisition Bitcoin][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #33333][] émet un message d'avertissement au démarrage si le paramètre `dbcache`
	d'un nœud dépasse un plafond dérivé de la RAM système du nœud, pour prévenir les erreurs de manque
	de mémoire ou un swapping intensif. Pour les systèmes avec moins de 2GB de RAM, le seuil
	d'avertissement `dbcache` est de 450MB ; autrement, le seuil est de 75% de la RAM totale. La limite
	de 16GB pour `dbcache` a été supprimée en septembre 2024 (voir le Bulletin [#321][news321 dbcache]).

- [Bitcoin Core #28592][] augmente le taux de relais de transactions par pair de 7 à 14 pour les
	pairs entrants en raison d'une présence accrue de transactions plus petites sur le réseau. Le taux
	pour les pairs sortants est 2,5 fois plus élevé, passant à 35 transactions par seconde. Le taux de
	relais de transactions limite le nombre de transactions qu'un nœud envoie à ses pairs.

- [Eclair #3171][] supprime `PaymentWeightRatios`, une méthode de recherche de chemin qui supposait
	une uniformité dans les soldes des canaux, et la remplace par une approche probabiliste nouvellement
	introduite basée sur l'historique des tentatives de paiement passées (voir le Bulletin [#371][news371
	path]).

- [Eclair #3175][] commence à rejeter les [offres][topic offers] [BOLT12][] impayables où les champs
	`offer_chains`, `offer_paths`, `invoice_paths`, et `invoice_blindedpay` sont présents mais vides.

- [LDK #4064][] met à jour sa logique de vérification de signature pour s'assurer que si le champ
	`n` (clé publique du bénéficiaire) est présent, la signature est vérifiée contre celui-ci. Sinon, la
	clé publique du bénéficiaire est extraite de la facture [BOLT11][] avec une signature high-S ou
	low-S. Cette PR aligne les vérifications de signature avec les propositions [BOLTs #1284][] et avec
	d'autres implémentations telles qu'Eclair (Voir le Bulletin [#371][news371 pubkey]).

- [LDK #4067][] ajoute le support pour dépenser les sorties d'[ancres éphémères P2A][topic ephemeral
	anchors] des transactions [d'engagement sans frais][topic v3 commitments], assurant
	les pairs de canal peuvent récupérer leurs fonds onchain. Voir le Bulletin [#371][news371
	p2a] pour l'implémentation par LDK des canaux d'engagement sans frais.

- [LDK #4046][] permet à un expéditeur souvent hors ligne d'envoyer des [paiements
	asynchrones][topic async payments] à un destinataire souvent hors ligne. L'expéditeur définit un
	drapeau dans le message `update_add_htlc` pour indiquer que le [HTLC][topic htlc] doit être retenu
	par le LSP jusqu'à ce que le destinataire revienne en ligne et envoie un `release_held_htlc`
	[message onion][topic onion messages] pour réclamer le paiement.

- [LDK #4083][] déprécie le point de terminaison `pay_for_offer_from_human_readable_name` pour
	supprimer les API de paiement HRN [BIP353][] en double. Les portefeuilles sont encouragés à utiliser
	le crate `bitcoin-payment-instructions` pour analyser et résoudre les instructions de paiement avant
	d'appeler `pay_for_offer_from_hrn` pour payer une [offre][topic offers] à partir d'un HRN [BIP353][]
	(par exemple, satoshi@nakamoto.com).

- [LND #10189][] met à jour son système `sweeper` (voir le Bulletin [#346][news346 sweeper]) pour
	reconnaître correctement le code d'erreur `ErrMinRelayFeeNotMet` et réessayer les transactions
	échouées par [augmentation des frais][topic rbf] jusqu'à ce que la diffusion soit réussie.
	Auparavant, l'erreur serait mal appariée, et la transaction ne serait pas réessayée. Cette PR
	améliore également l'estimation du poids en tenant compte d'une sortie de changement supplémentaire
	possible, ce qui est pertinent dans les canaux d'overlay [taproot][topic taproot] utilisés pour
	améliorer les [Taproot Assets][topic client-side validation] de LND.

- [BIPs #1963][] met à jour le statut des BIPs qui spécifient les [filtres de blocs compacts][topic
	compact block filters], [BIP157][] et [BIP158][], de `Draft` à `Final` car ils ont été déployés dans
	Bitcoin Core et d'autres logiciels depuis 2020.

{% include snippets/recap-ad.md when="2025-09-30 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33333,28592,3171,3175,4064,4067,4046,4083,10189,1963,1284" %}
[morehouse eclair]: https://delvingbitcoin.org/t/disclosure-eclair-preimage-extraction-exploit/2010
[brozzoni feefilter]: https://delvingbitcoin.org/t/measuring-minrelaytxfee-across-the-bitcoin-network/1989
[0xb10c feefilter]: https://delvingbitcoin.org/t/measuring-minrelaytxfee-across-the-bitcoin-network/1989/3
[bitcoin core 30.0rc1]: https://bitcoincore.org/bin/bitcoin-core-30.0/
[bcc30 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/30.0-Release-Candidate-Testing-Guide/
[news321 dbcache]: /fr/newsletters/2024/09/20/#bitcoin-core-28358
[news371 path]: /fr/newsletters/2025/09/12/#eclair-2308
[news371 pubkey]: /fr/newsletters/2025/09/12/#eclair-3163
[news371 p2a]: /fr/newsletters/2025/09/12/#ldk-4053
[news346 sweeper]: /fr/newsletters/2025/03/21/#discussion-sur-le-systeme-de-reajustement-dynamique-du-taux-de-frais-de-lnd
[policy series]: /fr/blog/waiting-for-confirmation/
[28.0 1p1c]: /fr/bitcoin-core-28-wallet-integration-guide/#relais-un-parent-un-enfant-1p1c
