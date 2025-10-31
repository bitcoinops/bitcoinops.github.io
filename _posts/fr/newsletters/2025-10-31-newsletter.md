---
title: 'Bulletin Hebdomadaire Bitcoin Optech #378'
permalink: /fr/newsletters/2025/10/31/
name: 2025-10-31-newsletter-fr
slug: 2025-10-31-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine annonce quatre vulnérabilités affectant les anciennes versions du
nœud complet Bitcoin Core. Sont également incluses nos sections régulières résumant les récentes
questions et réponses de Bitcoin Stack Exchange, annoncant de nouvelles versions et des candidats
à la publication, ainsi que les résumés des modifications notables apportées aux logiciels
d'infrastructure Bitcoin populaires.

## Nouvelles

- **Divulgation de quatre vulnérabilités de faible gravité dans Bitcoin Core :**
	Antoine Poinsot a récemment [posté][poinsot disc] sur la liste de diffusion Bitcoin-Dev quatre avis
	de sécurité de Bitcoin Core pour des vulnérabilités de faible gravité qui ont été corrigées dans
	Bitcoin Core 30.0. Selon la [politique de divulgation][disc pol] (voir le [Bulletin #306][news306
	disclosures]), une vulnérabilité de faible gravité est divulguée deux semaines après la sortie d'une
	version majeure contenant le correctif. Les quatre vulnérabilités divulguées sont les suivantes :

	- [Remplissage de disque par des autoconnexions falsifiées][CVE-2025-54604] : Ce bug permettrait à
		un attaquant de remplir l'espace disque d'un nœud victime en simulant des autoconnexions. La
		vulnérabilité a été [divulguée de manière responsable][topic responsible disclosures] par Niklas
		Gögge en mars 2022. Eugene Siegel et Niklas Gögge ont fusionné une atténuation en juillet 2025.

	- [Remplissage de disque par des blocs invalides][CVE-2025-54605] : Ce bug permettrait à un
		attaquant de remplir l'espace disque d'un nœud victime en envoyant à plusieurs reprises des blocs
		invalides. Ce bug a été divulgué de manière responsable par Niklas Gögge en mai 2022 et également de
		manière indépendante par Eugene Siegel en mars 2025. Eugene Siegel et Niklas Gögge ont fusionné
		l'atténuation en juillet 2025.

	- [Crash à distance hautement improbable sur les systèmes 32 bits][CVE-2025-46597] : Ce bug pourrait
		provoquer un crash d'un nœud lors de la réception d'un bloc pathologique dans un cas limite rare. Ce
		bug a été divulgué de manière responsable par Pieter Wuille en avril 2025. Antoine Poinsot a
		implémenté et fusionné l'atténuation en juin 2025.

	- [DoS CPU par le traitement de transaction non confirmée][CVE-2025-46598] : Ce bug causerait
		l'épuisement des ressources lors du traitement d'une transaction non confirmée. Ce bug a été signalé
		à la liste de diffusion par Antoine Poinsot en avril 2025. Pieter Wuille, Anthony Towns et Antoine
		Poinsot ont implémenté et fusionné l'atténuation en août 2025.

	Les correctifs pour les trois premières vulnérabilités ont également été inclus dans Bitcoin Core
	29.1 et les versions mineures ultérieures.

## Questions et réponses sélectionnées de Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] est l'un des premiers endroits où les contributeurs d'Optech
cherchent des réponses à leurs questions---ou quand nous avons quelques moments libres pour aider
les utilisateurs curieux ou confus. Dans cette rubrique mensuelle, nous mettons en lumière certaines
des questions et réponses les mieux votées postées depuis notre dernière mise à jour.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Pourquoi la taille de -datacarriersize a-t-elle été redéfinie en 2022, et pourquoi la proposition de 2023 pour l'élargir n'a-t-elle pas été fusionnée ?]({{bse}}128027)
	Pieter Wuille fournit un aperçu historique de la portée de l'option `-datacarriersize` de Bitcoin Core
	en relation avec les sorties `OP_RETURN`.

- [Quelle est la transaction valide la plus petite qui peut être incluse dans un bloc ?]({{bse}}129137)
	Vojtěch Strnad énumère les champs minimums et les tailles qui constitueraient la
	transaction Bitcoin valide la plus petite possible.

- [Pourquoi Bitcoin Core continue-t-il de donner un rabais sur les données de témoin même lorsqu'elles sont utilisées pour des inscriptions ?]({{bse}}128028)
	Pieter Wuille explique la raison d'être du rabais de témoin de segwit et souligne que le logiciel
	Bitcoin Core met en œuvre les règles de consensus actuelles de Bitcoin.

- [La taille toujours croissante de la blockchain Bitcoin ?]({{bse}}128048)
	Murch note la taille actuelle de l'ensemble UTXO, les exigences de stockage pour les nœuds élagués
	et complets, et souligne le taux de croissance actuel de la blockchain Bitcoin.

- [J'ai lu que OP_TEMPLATEHASH est une variante de OP_CTV. En quoi diffèrent-ils ?]({{bse}}128097)
	Rearden contraste les capacités, l'efficacité, la compatibilité, et quels champs sont hashés, entre
	[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] et la proposition récemment proposée
	`OP_TEMPLATEHASH` (voir le [Bulletin #365][news365 op_templatehash]).

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires.
Veuillez envisager de mettre à niveau vers les nouvelles versions ou d'aider à tester les versions candidates._

- [LND 0.20.0-beta.rc1][] est un candidat à la sortie pour ce nœud LN populaire. Une amélioration
	qui bénéficierait d'un test est la correction du rescannage prématuré du portefeuille, décrite dans
	la section des changements de code notables ci-dessous. Voir les [notes de version][LND notes] pour
	plus de détails.

- [Eclair 0.13.1][] est une sortie mineure de cette implémentation de nœud LN. Cette sortie contient
	des changements de base de données pour préparer la suppression des canaux pré-[anchor output][topic
	anchor outputs]. Vous devrez exécuter la version 0.13.0 d'abord pour migrer vos données de canal
	vers le dernier encodage interne.

## Changements notables dans le code et la documentation

_Changements notables récents dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core
lightning repo], [Eclair][eclair repo], [LDK][ldk repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Interface de Portefeuille Matériel (HWI)][hwi repo], [Rust
Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Propositions
d'Amélioration de Bitcoin (BIPs)][bips repo], [Lightning BOLTs][bolts repo], [Lightning BLIPs][blips
repo], [Inquisition Bitcoin][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #29640][] réinitialise les valeurs de `nSequenceId` au démarrage pour les blocs sur
	des chaînes concurrentes ayant le même montant de travail : 0 pour les blocs appartenant à la
	meilleure chaîne précédemment connue, et 1 pour tous les autres blocs chargés. Cela résout un
	problème où Bitcoin Core ne pouvait pas effectuer un départage entre deux chaînes concurrentes
	parce que la valeur `nSequenceId` ne persistait pas à travers les redémarrages.

- [Core Lightning #8400][] introduit un nouveau format de sauvegarde mnémonique [BIP39][] pour le
	`hsm_secret` avec une passphrase optionnelle pour tous les nouveaux nœuds par défaut, tout en
	conservant le support pour les `hsm_secrets` de 32 octets existants. `Hsmtool` est également mis à
	jour pour supporter les secrets basés sur des mnémoniques et les secrets traditionnels. Un nouveau
	format de dérivation standard [taproot][topic taproot] est introduit pour les portefeuilles.

- [Eclair #3173][] supprime le support pour les canaux hérités qui n'utilisent pas les [anchor
	outputs][topic anchor outputs] ou [taproot][topic taproot], également connus sous le nom de canaux
	`static_remotekey` ou `default`. Les utilisateurs devraient fermer tous les canaux hérités restants
	avant de passer à la version 0.13 ou 0.13.1.

- [LND #10280][] attend désormais que les en-têtes soient synchronisés avant de démarrer le
	notificateur de chaîne (voir le [Bulletin #31][news31 chain]) pour rescanner la chaîne pour les
	transactions de portefeuille. Cela résout un problème dans lequel LND déclenchait un rescannage
	prématuré alors que les en-têtes étaient encore en cours de synchronisation lorsqu'un nouveau
	portefeuille était créé. Cela affectait principalement les [backends Neutrino][topic compact block filters].

- [BIPs #2006][] met à jour la spécification de [BIP3][] (voir le [Bulletin #344][news344 bip3]) en
	ajoutant des conseils sur l'originalité et la qualité, en particulier en conseillant aux auteurs de
	ne pas générer de contenu avec des IA/LLM, et en encourageant la divulgation proactive de
	l'utilisation des IA/LLM.

- [BIPs #1975][] met à jour [BIP155][] qui spécifie [addr v2][topic addr v2], une nouvelle version
	du message `addr` dans le protocole réseau P2P de Bitcoin, en ajoutant une note indiquant que [Tor
	v2][topic anonymity networks] n'est plus opérationnel.

{% include snippets/recap-ad.md when="2025-11-04 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29640,8400,3173,10280,5516,2006,1975" %}

[poinsot disc]: https://groups.google.com/g/bitcoindev/c/sBpCgS_yGws
[disc pol]: https://bitcoincore.org/en/security-advisories/
[news306 disclosures]: /fr/newsletters/2024/06/07/#divulgation-a-venir-de-vulnerabilites-affectant-les-anciennes-versions-de-bitcoin-core
[CVE-2025-54604]: https://bitcoincore.org/en/2025/10/24/disclose-cve-2025-54604/
[CVE-2025-54605]: https://bitcoincore.org/en/2025/10/24/disclose-cve-2025-54605/
[CVE-2025-46597]: https://bitcoincore.org/en/2025/10/24/disclose-cve-2025-46597/
[CVE-2025-46598]: https://bitcoincore.org/en/2025/10/24/disclose-cve-2025-46598/
[LND 0.20.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.0-beta.rc2
[LND notes]: https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/release-notes-0.20.0.md
[Eclair 0.13.1]: https://github.com/ACINQ/eclair/releases/tag/v0.13.1
[news31 chain]: /en/newsletters/2019/01/29/#lnd-2314
[news344 bip3]: /fr/newsletters/2025/03/07/#bips-1712
[news365 op_templatehash]: /fr/newsletters/2025/08/01/#proposition-de-op-templatehash-natif-a-taproot
