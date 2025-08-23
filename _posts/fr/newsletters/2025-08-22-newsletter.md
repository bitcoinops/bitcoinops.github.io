---
title: 'Bulletin Hebdomadaire Bitcoin Optech #368'
permalink: /fr/newsletters/2025/08/22/
name: 2025-08-22-newsletter-fr
slug: 2025-08-22-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine résume un projet de BIP pour le partage de modèles de bloc entre les
nœuds complets et annonce une bibliothèque qui permet la délégation de confiance de l'évaluation de
script (y compris pour les fonctionnalités non disponibles dans les langages de script natifs de
Bitcoin). Sont également incluses nos sections régulières résumant les changements récents apportés
aux clients et services, les annonces de nouvelles versions et de candidats à la publication, et les
résumés des modifications notables apportées aux logiciels d'infrastructure Bitcoin populaires.

## Nouvelles

- **Projet de BIP pour le partage de modèles de bloc :** Anthony Towns a [posté][towns bipshare] sur
	la liste de diffusion Bitcoin-Dev le [projet][towns bipdraft] d'un BIP sur la manière dont les nœuds
	peuvent communiquer à leurs pairs les transactions qu'ils tenteraient de miner dans leur prochain
	bloc (voir le [Bulletin #366][news366 templshare]). Cela permet au nœud de partager les transactions
	qu'il acceptera via son mempool et sa politique de minage que ses pairs pourraient normalement
	rejeter selon leur propre politique, permettant à ces pairs de mettre en cache ces transactions au
	cas où elles seraient minées (ce qui améliore l'efficacité du [relais de bloc compact][topic
	compact block relay]). Les transactions dans un modèle de bloc d'un nœud sont généralement les
	transactions non confirmées les plus rentables connues de ce nœud, donc les pairs qui ont
	précédemment rejeté ces transactions pour des raisons de politique pourraient également les trouver
	dignes d'une considération supplémentaire.

	Le protocole spécifié dans le projet de BIP est simple. Peu après l'initiation d'une connexion avec
	un pair, le nœud envoie un message `sendtemplate` indiquant au pair qu'il est prêt à envoyer des
	modèles de blocs. À tout moment ultérieur, le pair peut demander un modèle avec un message
	`gettemplate`. En réponse à la demande, le nœud répond avec un message `template` qui contient une
	liste d'identifiants de transactions courts utilisant le même format qu'un message de bloc compact
	[BIP152][]. Le pair peut alors demander les transactions qu'il souhaite en incluant l'identifiant
	court dans un message `sendtransactions` (également comme dans BIP152). Le projet de BIP permet aux
	modèles d'être jusqu'à un peu plus de deux fois la taille de la limite de poids de bloc maximum
	actuelle.

	Un [║fil de discussion Bitcoin][delshare] sur le partage de modèles a vu cette semaine une
	discussion supplémentaire sur la manière d'améliorer l'efficacité de la bande passante de la
	proposition. Les idées discutées incluaient l'envoi uniquement de la [différence][towns templdiff]
	depuis le modèle précédent (une économie de bande passante estimée à 90%), l'utilisation d'un
	protocole de [réconciliation de l'ensemble][jahr templerlay] tel que celui permis par
	[minisketch][topic minisketch] (permettant de partager efficacement des modèles beaucoup plus
	grands), et l'utilisation du [codage Golomb-Rice][wuille templgr] sur les modèles
	similaires aux [filtres de bloc compact][topic compact block filters] (une efficacité estimée à
	25%).

- **Délégation de confiance pour l'évaluation de script :** Josh Doman a [posté][doman tee] sur
	Delving Bitcoin à propos d'une bibliothèque qu'il a écrite qui utilise un _environnement d'exécution
	de confiance_ ([TEE][]) qui ne signera une dépense de chemin de clé [taproot][topic taproot] que si
	la transaction contenant
	cette dépense satisfait un script. Le script peut contenir des opcodes qui ne sont actuellement pas
	actifs sur Bitcoin aujourd'hui ou une forme complètement différente de script (par exemple,
	[Simplicity][topic simplicity] ou [bll][topic bll]).

	Cette approche nécessite que ceux qui reçoivent des fonds vers le script fassent confiance au TEE---à
	la fois qu'il sera encore disponible pour signer à l'avenir et qu'il ne signera qu'une dépense qui
	satisfait son script d'encumbrance---mais elle permet une expérimentation rapide avec de nouvelles
	fonctionnalités proposées pour Bitcoin avec une valeur monétaire réelle. Pour réduire la confiance
	dans la disponibilité future du TEE, un chemin de dépense de secours peut être inclus; par exemple,
	un chemin [timelocked][topic timelocks] qui permet à un participant de dépenser unilatéralement ses
	fonds un an après les avoir confiés au TEE.

	La bibliothèque est conçue pour être utilisée avec l'enclave Nitro d'Amazon Web Services (AWS).

## Changements dans les services et logiciels clients

*Dans cette rubrique mensuelle, nous mettons en lumière des mises à jour intéressantes des
portefeuilles et services Bitcoin.*

- **ZEUS v0.11.3 publié :**
	La version [v0.11.3][zeus v0.11.3] inclut des améliorations de la gestion des pairs, [BOLT12][topic
	offers], et des fonctionnalités de [submarine swap][topic submarine swaps].

- **Ressources Rust Utreexo :**
	Abdelhamid Bakhta a [publié][abdel tweet] des ressources basées sur Rust pour [Utreexo][topic
	utreexo], incluant des [matériaux éducatifs][rustreexo webapp] interactifs et des [liaisons
	WASM][rustreexo wasm].

- **Outils d'observation des pairs et appel à l'action :**
	0xB10C a [publié][b10c blog] sur la motivation, l'architecture, le code, les bibliothèques de
	soutien, et les découvertes de son projet [peer-observer][peer-observer github]. Il cherche à
	construire "Un groupe décentralisé de personnes qui partagent l'intérêt de surveiller le Réseau
	Bitcoin. Un collectif pour permettre le partage d'idées, de discussions, de données, d'outils,
	d'aperçus, et plus encore."

- **Nœud basé sur le noyau Bitcoin Core annoncé :**
	Le backbone Bitcoin a été [annoncé][bitcoin backbone] comme une démonstration de l'utilisation de la
	bibliothèque [Bitcoin Core Kernel][kernel blog] comme fondation d'un nœud Bitcoin.

- **SimplicityHL publié :**
	[SimplicityHL][simplcityhl github] est un langage de programmation semblable à Rust qui compile vers
	le langage [Simplicity][simplicity] de niveau inférieur [récemment activé][simplicity post] sur
	Liquid. Pour plus de lecture, voir le [fil de discussion lié][simplicityhl delving].

- **Plugin LSP pour BTCPay Server :**
	Le [plugin LSP][lsp btcpay github] implémente les fonctionnalités côté client de [BLIP51][], la
	spécification pour les canaux entrants, dans BTCPay Server.

- **Matériel et logiciel de minage Proto annoncés :**
	Proto a [annoncé][proto blog] un nouveau matériel de minage Bitcoin et un logiciel de minage open
	source, construit avec les [retours de la communauté][news260 mdk] précédents.

- **Démonstration de résolution d'oracle utilisant CSFS :**
	Abdelhamid Bakhta a [publié][abdel tweet2] une démonstration d'un oracle utilisant [CSFS][topic
	op_checksigfromstack], nostr, et MutinyNet pour signer une attestation du résultat d'un événement.

- **Relai ajoute le support de taproot :** Relai a ajouté le support pour l'envoi vers des adresses
	[taproot][topic taproot].

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates._

- [LND v0.19.3-beta][] est une version de maintenance pour cette implémentation populaire de nœud LN
  contenant des "corrections de bugs importantes". Plus notablement, "une migration optionnelle [...]
  réduit significativement les besoins en disque et en mémoire pour les nœuds."

- [Bitcoin Core 29.1rc1][] est un candidat à la sortie pour une version de maintenance du logiciel
  de nœud complet prédominant.

- [Core Lightning v25.09rc2][] est un candidat à la sortie pour une nouvelle version majeure de
  cette implémentation populaire de nœud LN.

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core
lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust
Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Propositions
d'Amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips
repo], [Inquisition Bitcoin][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #32896][] introduit le support pour la création et la dépense de transactions
	Topologically Restricted Until Confirmation ([TRUC][topic v3 transaction relay]) non confirmées en
	ajoutant un paramètre `version` aux RPCs suivants : `createrawtransaction`, `createpsbt`, `send`,
	`sendall`, et `walletcreatefundedpsbt`. Le portefeuille applique les restrictions de transaction
	TRUC pour la limite de poids, le conflit entre frères, et l'incompatibilité entre les transactions
	TRUC non confirmées et non-TRUC.

- [Bitcoin Core #33106][] abaisse le `blockmintxfee` par défaut à 1 sat/kvB (le minimum possible),
	et le [`minrelaytxfee`][topic default minimum transaction relay feerates] par défaut et
	`incrementalrelayfee` à 100 sat/kvB (0.1 sat/vB). Bien que ces valeurs puissent être configurées, il
	est conseillé aux utilisateurs d'ajuster les valeurs `minrelaytxfee` et `incrementalrelayfee`
	ensemble. Les autres feerates minimum restent inchangées, mais les feerates minimum par défaut du
	portefeuille sont attendues pour être abaissées dans une version future. Les motivations pour ce
	changement vont de la croissance considérable du nombre de blocs minés avec des transactions sous 1
	sat/vB et du nombre de pools minant ces transactions à une augmentation du taux de change du
	Bitcoin.

- [Core Lightning #8467][] étend `xpay` (voir le [Bulletin #330][news330 xpay]) en ajoutant le
	support pour le paiement de noms lisibles par l'homme [BIP353][] (HRN) (par exemple,
	satoshi@bitcoin.com) et en lui permettant de payer directement les [offres BOLT12][topic offers],
	éliminant le besoin d'exécuter la commande `fetchinvoice` d'abord.
	Sous le capot, `xpay` récupère les instructions de paiement en utilisant la commande RPC
	`fetchbip353` du plugin `cln-bip353` introduit dans [Core Lightning #8362][].

- [Core Lightning #8354][] commence à publier des notifications d'événements `pay_part_start` et
	`pay_part_end` pour le statut de parties de paiement spécifiques envoyées avec [MPP][topic multipath
	payments]. La notification `pay_part_end` indique la durée du paiement et si celui-ci a été réussi
	ou échoué. Si le paiement échoue, un message d'erreur est fourni et, si l'oignon d'erreur n'est pas
	corrompu, des informations supplémentaires sur l'échec sont données, telles que la source de
	l'erreur et le code d'échec.

- [Eclair #3103][] introduit le support pour [simple taproot channels][topic simple taproot
	channels], exploitant le [MuSig2][topic musig] de [multisignature][topic multisignature]
	sans script pour réduire la consommation de poids de transaction de 15% et améliorer la
	confidentialité des transactions. Les transactions de financement et les fermetures coopératives
	sont indiscernables des autres transactions [P2TR][topic taproot]. Cette PR inclut également le
	support pour le [dual funding][topic dual funding] et le [splicing][topic splicing] dans les canaux
	taproot simples, et active les [mises à niveau d'engagement de canal][topic channel commitment
	upgrades] au nouveau format taproot lors d'une transaction de splice.

- [Eclair #3134][] remplace le multiplicateur de poids de pénalité pour les [HTLCs][topic htlc]
	bloqués par le [CLTV expiry delta][topic cltv expiry delta] lors de l'évaluation de la réputation
	des pairs pour l'[endorsement HTLC][topic htlc endorsement] (voir le [Bulletin #363][news363
	reputation]), pour mieux refléter combien de temps un HTLC bloqué immobilisera la liquidité. Pour
	atténuer la pénalité disproportionnée des HTLCs bloqués avec un delta d'expiration CLTV maximum,
	cette PR ajuste le paramètre de dégradation de la réputation (`half-life`) de 15 à 30 jours et le
	seuil de paiement bloqué (`max-relay-duration`) de 12 secondes à 5 minutes.

- [LDK #3897][] étend son implémentation de [stockage de pairs][topic peer storage] en détectant la
	perte de l'état du canal lors de la récupération de sauvegarde, en désérialisant la copie du pair et
	en la comparant à l'état local.

{% include snippets/recap-ad.md when="2025-08-26 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32896,33106,8467,8354,3103,3134,3897,8362" %}
[bitcoin core 29.1rc1]: https://bitcoincore.org/bin/bitcoin-core-29.1/
[lnd v0.19.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.3-beta
[core lightning v25.09rc2]: https://github.com/ElementsProject/lightning/releases/tag/v25.09rc2
[towns bipshare]: https://mailing-list.bitcoindevs.xyz/bitcoindev/aJvZwR_bPeT4LaH6@erisian.com.au/
[towns bipdraft]: https://github.com/ajtowns/bips/blob/202508-sendtemplate/bip-ajtowns-sendtemplate.md
[news366 templshare]: /en/newsletters/2025/08/08/#peer-block-template-sharing-to-mitigate-problems-with-divergent-mempool-policies
[delshare]: https://delvingbitcoin.org/t/sharing-block-templates/1906/13
[towns templdiff]: https://delvingbitcoin.org/t/sharing-block-templates/1906/7
[jahr templerlay]: https://delvingbitcoin.org/t/sharing-block-templates/1906/6
[wuille templgr]: https://delvingbitcoin.org/t/sharing-block-templates/1906/9
[doman tee]: https://delvingbitcoin.org/t/confidential-script-emulate-soft-forks-using-stateless-tees/1918/
[tee]: https://en.wikipedia.org/wiki/Trusted_execution_environment
[news330 xpay]: /en/newsletters/2024/11/22/#core-lightning-7799
[news363 reputation]: /en/newsletters/2025/07/18/#eclair-2716
[zeus v0.11.3]: https://github.com/ZeusLN/zeus/releases/tag/v0.11.3
[abdel tweet]: https://x.com/dimahledba/status/1951213485104181669
[rustreexo webapp]: https://rustreexo-playground.starkwarebitcoin.dev/
[rustreexo wasm]: https://github.com/AbdelStark/rustreexo-wasm
[b10c blog]: https://b10c.me/projects/024-peer-observer/
[peer-observer github]: https://github.com/0xB10C/peer-observer
[bitcoin backbone]: https://mailing-list.bitcoindevs.xyz/bitcoindev/9812cde0-7bbb-41a6-8e3b-8a5d446c1b3cn@googlegroups.com
[kernel blog]: https://thecharlatan.ch/Kernel/
[simplcityhl github]: https://github.com/BlockstreamResearch/SimplicityHL
[simplicity]: https://blockstream.com/simplicity.pdf
[simplicityhl delving]: https://delvingbitcoin.org/t/writing-simplicity-programs-with-simplicityhl/1900
[simplicity post]: https://blog.blockstream.com/simplicity-launches-on-liquid-mainnet/
[lsp btcpay github]: https://github.com/MegalithicBTC/BTCPayserver-LSPS1
[proto blog]: https://proto.xyz/blog/posts/proto-rig-and-proto-fleet-a-paradigm-shift
[news260 mdk]: /en/newsletters/2023/07/19/#mining-development-kit-call-for-feedback
[abdel tweet2]: https://x.com/dimahledba/status/1946223544234659877
