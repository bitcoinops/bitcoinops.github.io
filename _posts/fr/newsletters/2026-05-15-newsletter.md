---
title: 'Bulletin Hebdomadaire Bitcoin Optech #405'
permalink: /fr/newsletters/2026/05/15/
name: 2026-05-15-newsletter-fr
slug: 2026-05-15-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine annonce la divulgation responsable d'une vulnérabilité qui pourrait permettre à un attaquant disposant d'une
preuve de travail suffisante de faire planter des nœuds Bitcoin Core et décrit une proposition de BIP en brouillon pour partager l'ensemble
UTXO sur le réseau P2P. Sont également incluses nos sections régulières annonçant une nouvelle version candidate et décrivant des
changements notables dans des logiciels populaires d'infrastructure Bitcoin.

## Nouvelles

- **Divulgation d'un plantage à distance de l'interpréteur de script de Bitcoin Core :** Niklas Gögge a [publié][topic cve mailing list] sur
  la liste de diffusion Bitcoin-Dev la divulgation du [CVE-2024-52911][topic cve disclosure], une vulnérabilité affectant les versions de
  Bitcoin Core postérieures à la version 0.14.0 et antérieures à 29.0. Après la version 0.14.0 (publiée en mars 2017), la validation d'un
  bloc spécialement conçu pouvait amener le nœud à accéder à une mémoire précédemment libérée. Pendant la validation, les données
  nécessaires à la vérification des entrées de transaction sont mises en cache. Le bug survenait en raison de l'ordre de durée de vie des
  objets lors de la validation parallèle des scripts, où des données de transaction précalculées mises en cache pouvaient être libérées
  avant que les threads en arrière-plan de vérification des scripts n'aient terminé. Pour des blocs invalides spécialement conçus, il était
  possible que ces données soient détruites alors qu'elles étaient encore consultées par des threads en arrière-plan.

  Un attaquant disposant d'une preuve de travail suffisante pouvait, en utilisant le bloc invalide spécialement conçu, faire planter le nœud
  d'une victime. En raison de la nature des bugs de type use-after-free, il est possible d'exécuter du code à distance sur les nœuds des
  victimes, mais la réalisation effective de cette attaque est peu probable en raison de la difficulté à fabriquer un bloc qui y parvienne.

  La vulnérabilité a été découverte et [divulguée de manière responsable][topic responsible disclosures] par Cory Fields, qui a également
  fourni une preuve de concept et proposé une atténuation. Le problème a été corrigé dans Bitcoin Core 29.0.

- **Proposition de BIP pour le partage de l'ensemble UTXO sur le réseau P2P** : Fabian Jahr a [publié][p2p share ml] sur la liste de
  diffusion Bitcoin-Dev à propos d'un [brouillon de BIP][BIPs #2137] pour partager l'ensemble UTXO sur la couche P2P. L'objectif de la
  proposition est d'améliorer la fonctionnalité [assumeUTXO][topic assumeutxo] en fournissant un moyen pour les nouveaux nœuds de recevoir
  directement l'ensemble UTXO de leurs pairs, au lieu de sources externes. En particulier, la proposition définit une extension du protocole
  P2P qui introduit un nouveau bit de service, quatre nouveaux messages P2P, et une racine de merkle de l'ensemble UTXO connue du nœud
  demandeur, afin de vérifier l'exactitude de l'ensemble UTXO fourni.

  La proposition a reçu des retours. Antoine Riard a proposé de construire le brouillon actuel au-dessus de [BIP434][], qui définit la
  négociation des fonctionnalités des pairs (voir le [Bulletin #386][news386 feat negot]), et a soulevé certaines préoccupations concernant
  des pairs malveillants relayant un ensemble UTXO malformé. Eric Voskuil a mis en garde l'auteur contre les risques à long terme d'un tel
  BIP, qui pourrait conduire à de nouvelles propositions d'engagements des mineurs envers l'état UTXO. Selon Voskuil, cela affaiblirait le
  modèle de sécurité de Bitcoin, les nouveaux nœuds faisant confiance aux mineurs au lieu de vérifier toute la chaîne depuis le bloc
  genesis.

## Mises à jour et versions candidates

_Nouvelles versions et versions candidates pour des projets d'infrastructure Bitcoin populaires. Veuillez envisager de mettre à niveau vers
les nouvelles versions ou d'aider à tester les versions candidates._

- [Core Lightning 26.06rc1][] est une version candidate pour la prochaine version majeure de ce nœud LN populaire qui inclut de nouvelles
  RPC `graceful`, `sendamount` et `xkeysend`, commence le cycle de dépréciation de `pay` en faveur de `xpay`, et ajoute la prise en charge
  RPC des preuves de payeur BOLT12.

## Changements notables dans le code et la documentation

_Changements récents notables dans [Bitcoin Core][bitcoin core repo], [Core Lightning][core lightning repo], [Eclair][eclair repo],
[LDK][ldk repo], [LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Interface de portefeuille matériel (HWI)][hwi repo], [Rust
Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo],
[Lightning BOLTs][bolts repo], [Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition repo], et [BINANAs][binana repo]._

- [Bitcoin Core #35209][] construit désormais le vecteur `txsdata` avant l'objet `CCheckQueueControl`, traitant la cause racine de
  [CVE-2024-52911][topic cve disclosure] (voir la section nouvelles ci-dessus). Puisque C++ détruit les objets locaux dans l'ordre inverse
  de leur construction, cela garantit que la file de vérification des scripts est terminée avant que les données de transaction précalculées
  référencées par les objets `CScriptCheck` mis en file ne soient détruites. Cela empêche que des chemins de validation avec retour anticipé
  n'amènent les threads en arrière-plan de vérification des scripts à accéder à de la mémoire libérée. Cette vulnérabilité avait été
  précédemment corrigée dans Bitcoin Core 29.0 par un correctif discret du comportement de retour anticipé (voir le [Bulletin #333][news333
  fix]).

- [BIPs #2116][] publie [BIP323][], qui propose d'étendre le nombre de bits disponibles dans l'espace nonce de `nVersion` pour les mineurs
  de 16 à 24, remplaçant [BIP320][]. Il réserve les bits 5 à 28 pour le minage sur en-tête seul sans dépendre d'un roulement de `nTime` plus
  fréquent qu'une fois par seconde. Voir le [Bulletin #395][news395 nversion] pour la discussion précédente.

- [BIPs #2141][] et [BIPs #2155][] révisent et étendent [BIP322][], qui proposait à l'origine un [format générique de message signé][topic
  generic signmessage] en 2018. La mise à jour répond à des questions ouvertes de longue date et à des retours, étoffe la construction
  proposée de preuve de fonds, et ajoute un flux de signature basé sur PSBT. La révision apporte des changements cassants à la spécification
  précédente, notamment l'ajout d'un nouveau préfixe lisible par l'humain à la signature et des modifications au format de signature de
  preuve de fonds. Une implémentation de référence plus complète basée sur btcd et des vecteurs de test supplémentaires sont ajoutés alors
  que le BIP passe à l'état Complete et est formellement proposé à l'écosystème pour adoption.

- [Core Lightning #9116][] ajoute un support expérimental pour les [preuves de payeur BOLT12][topic offers], implémentant la dernière
  proposition en brouillon de [BOLTs #1295][]. Les preuves de payeur sont un format de reçu BOLT12 qui permet [à un payeur de prouver][topic
  proof of payment] qu'il a payé une facture en utilisant le préimage de paiement, la signature du nœud émetteur de la facture, et une
  signature du payeur issue de `invreq_payer_id`, tout en permettant d'omettre certains champs de la facture pour la confidentialité. La PR
  ajoute des routines communes pour créer et valider des preuves de payeur, met à jour `bolt12-cli`, et ajoute une RPC expérimentale
  `createproof`. Le format reste expérimental et peut changer.

- [Core Lightning #9110][] déprécie les RPC `pay`, `paystatus`, `keysend`, `getroute`, `renepay` et `renepaystatus`, la dépréciation
  commençant en version 26.06 et la suppression étant prévue pour la version 27.03. La RPC `xpay` (voir le [Bulletin #330][news330 xpay])
  gère désormais la plupart des invocations de paiement, et une RPC `xkeysend` est ajoutée pour maintenir la fonctionnalité [keysend][topic
  spontaneous payments]. La PR étend également `xpay` avec des paramètres `label` et `localinvreqid`, le shadow routing CLTV, une meilleure
  gestion des paiements répétés, et la gestion des erreurs `channel_update`. Elle met aussi à jour `getroutes` pour renvoyer des champs plus
  clairs par saut concernant le montant, le nœud et le CLTV, et met à jour `sendpay` pour accepter des routes utilisant ces champs.

- [LDK #4598][] met à jour `OutputSweeper` pour s'assurer que son indicateur `pending_sweep` est effacé même si une tentative de sweep en
  cours est annulée avant son achèvement. L'indicateur empêche les tentatives de sweep concurrentes, mais s'il restait activé après un sweep
  annulé, les tentatives ultérieures seraient ignorées à tort, pouvant empêcher la réclamation de sorties [HTLC][topic htlc] sensibles au
  temps jusqu'à ce que le nœud redémarre. La PR efface désormais l'indicateur à l'aide d'un objet de garde qui s'exécute lors d'un retour
  normal, d'une erreur ou d'une annulation.

- [LDK #4528][] engage `payment_metadata` de BOLT11 (voir le [Bulletin #182][news182 metadata]) dans le HMAC de paiement entrant. Lorsque
  des métadonnées sont incluses dans une facture, LDK exige désormais que la charge utile onion finale renvoie les mêmes métadonnées avant
  d'accepter le paiement, empêchant toute modification ou omission côté expéditeur. En outre, le constructeur de facture exige maintenant
  par défaut des métadonnées de paiement, mais les utilisateurs peuvent s'en dispenser via `optional_payment_metadata()` pour assurer la
  compatibilité avec les expéditeurs qui ne le prennent pas en charge.

- [LND #10612][] ajoute la recherche de chemin basée sur le graphe pour les [messages onion][topic onion messages], en s'appuyant sur le
  support antérieur du relais (voir le [Bulletin #396][news396 onion]). LND peut désormais trouver une route vers une destination à travers
  des nœuds qui annoncent la prise en charge des messages onion à l'aide des bits de fonctionnalité 38/39. Comme les messages onion ne sont
  pas des paiements, la recherche ne tient compte ni de la liquidité ni des frais.

- [BTCPay Server #7354][] corrige un problème d'exposition de clé de portefeuille à chaud introduit après que [BTCPay Server #7329][] a
  ajouté des permissions granulaires de portefeuille. Les utilisateurs disposant de la permission de signature du portefeuille, mais pas de
  la permission de voir la seed du portefeuille ou de modifier les paramètres de la boutique, pouvaient être exposés à des clés privées
  dérivées du portefeuille à chaud pendant la signature [PSBT][topic psbt]. La PR introduit un helper `HotwalletSafe` pour centraliser
  l'accès au portefeuille à chaud, sépare la permission de signer de la permission de voir le matériel de seed, et met à jour les flux de
  signature pour utiliser le portefeuille à chaud côté serveur sans renvoyer de clés privées de signature via des champs de formulaire HTTP.

- [BDK #2195][] corrige la synchronisation depuis des serveurs Electrum lorsque la première sortie d'une transaction n'est pas indexée,
  comme une sortie `OP_RETURN`. Auparavant, `BdkElectrumClient::populate_with_txids` interrogeait l'historique des confirmations en
  utilisant le script de la première sortie, ce qui pouvait renvoyer un historique vide. BDK utilise désormais le script de la première
  sortie indexée, ou se rabat sur le script de sortie précédente d'une entrée si aucune des sorties n'est indexée.

- [Bitcoin Inquisition #100][] implémente l'opcode `OP_TEMPLATEHASH` de [BIP446][] pour tester des modifications proposées du consensus sur
  [signet][topic signet]. `OP_TEMPLATEHASH` est un opcode [tapscript][topic tapscript] qui pousse un hachage de la transaction de dépense
  sur la pile (voir le [Bulletin #397][news397 templatehash]). La PR ajoute également un cadre de test étendu.

- [BINANAs #20][] assigne BIN-2026-0002 à une future implémentation dans Bitcoin Inquisition de l'opcode [OP_CHECKCONTRACTVERIFY][topic
  matt] (OP_CCV) de [BIP443][]. Voir les Bulletins [#348][news348 op_ccv] et [#356][news356 op_ccv] pour la discussion précédente de ce
  [covenant][topic covenants] proposé.

{% include snippets/recap-ad.md when="2026-05-19 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2137,20,100,1295,2116,2141,2155,2195,4528,4598,7329,7354,9110,9116,10612,35209" %}
[topic cve mailing list]: https://groups.google.com/g/bitcoindev/c/e1UEdViSYkU
[topic cve disclosure]: https://bitcoincore.org/en/2026/05/05/disclose-cve-2024-52911/
[Core Lightning 26.06rc1]: https://github.com/ElementsProject/lightning/releases/tag/v26.06rc1
[news333 fix]: /fr/newsletters/2024/12/13/#bitcoin-core-31112
[news330 xpay]: /fr/newsletters/2024/11/22/#core-lightning-7799
[news182 metadata]: /en/newsletters/2022/01/12/#bolts-912
[news396 onion]: /fr/newsletters/2026/03/13/#lnd-10089
[news395 nversion]: /fr/newsletters/2026/03/06/#projet-de-bip-pour-l-expansion-de-l-espace-nonce-nversion-pour-les-mineurs
[news397 templatehash]: /fr/newsletters/2026/03/20/#bips-1974
[news348 op_ccv]: /fr/newsletters/2025/04/04/#semantique-de-op-checkcontractverify
[news356 op_ccv]: /fr/newsletters/2025/05/30/#bips-1793
[p2p share ml]: https://groups.google.com/g/bitcoindev/c/rThmyI8ZN3Q
[news386 feat negot]: /fr/newsletters/2026/01/02/#negociation-de-fonctionnalites-entre-pairs
