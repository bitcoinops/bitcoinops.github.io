---
title: 'Bulletin Hebdomadaire Bitcoin Optech #40'
permalink: /fr/newsletters/2019/04/02/
name: 2019-04-02-newsletter-fr
slug: 2019-04-02-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
Le bulletin de cette semaine note une hausse des frais de transaction estimés, décrit les paiements trampoline pour LN, et annonce
l'intention de Bitcoin Core de faire des adresses de réception bech32 le choix par défaut de son portefeuille intégré dans la version 0.20
ou antérieure. Sont également incluses les rubriques habituelles sur la prise en charge de l'envoi vers bech32 et les changements notables
dans le code de projets populaires d'infrastructure Bitcoin.

{% include references.md %}

## Mesures à prendre

- **Aidez à tester Bitcoin Core 0.18.0 RC2 :** le deuxième candidat à la publication (RC) pour la prochaine version majeure de Bitcoin Core
  a été [publié][0.18.0]. Des tests sont encore nécessaires par les organisations et les utilisateurs expérimentés qui prévoient d'exécuter
  la nouvelle version de Bitcoin Core en production. Utilisez [ce ticket][Bitcoin Core #15555] pour signaler vos retours.

## État du réseau

- **Hausse des frais pour une confirmation rapide :** après plus d'un an durant lequel la plupart des transactions Bitcoin se confirmaient
  assez rapidement tant qu'elles payaient un taux de frais supérieur au frais minimum de relais par défaut (sauf pendant [une brève période
  exceptionnelle][le bulletin #22]), un arriéré modeste s'est développé au cours de la semaine précédente et a augmenté les taux de frais
  pour les personnes qui ont besoin que leurs transactions soient confirmées dans les prochains blocs. Les dépensiers prêts à attendre un
  peu plus longtemps peuvent toujours économiser de l'argent. Par exemple, au moment de la rédaction, l'estimateur de frais de Bitcoin Core
  suggère des frais de 0.00059060 BTC par 1 000 vbytes pour une confirmation sous 2 blocs mais seulement 0.00002120 pour une confirmation
  sous 50 blocs---soit plus de 95 % d'économies en attendant jusqu'à 8 heures supplémentaires. Pour plus d'informations, nous recommandons
  [les statistiques du mempool de Johoe][Johoe's mempool statistics] et [le suivi de l'estimation des frais de P2SH.info][P2SH.info's fee
  estimate tracker].

## Nouvelles

- **Paiements trampoline pour LN :** Pierre-Marie Padiou a lancé un [fil][trampoline thread] sur la liste de diffusion Lightning-Dev
  suggérant qu'Alice pourrait envoyer un paiement à Zed même si elle ne connaissait pas de chemin vers son nœud en envoyant d'abord un
  paiement à un nœud intermédiaire (Dan) et en demandant à Dan de déterminer la route pour le reste du trajet jusqu'à Zed. Cela
  bénéficierait particulièrement à Alice si elle exploitait un nœud LN léger qui n'essaie pas de suivre l'ensemble du réseau. Pour une
  confidentialité accrue, Alice pourrait utiliser plusieurs nœuds intermédiaires plutôt qu'un seul (chacun recevant ses propres instructions
  chiffrées par Alice). Un inconvénient décrit dans l'e-mail est qu'Alice ne pourrait faire qu'une estimation approximative des frais requis
  car elle ne connaîtrait pas le chemin réel, et elle finirait donc probablement par payer plus de frais que si elle choisissait elle-même
  la route.

- **Bitcoin Core planifie le passage aux adresses de réception bech32 par défaut :** depuis la [version 0.16.0][0.16.0 segwit], le
  portefeuille intégré de Bitcoin Core génère par défaut des adresses segwit encapsulées dans P2SH lorsque les utilisateurs veulent recevoir
  des paiements. Ces adresses sont rétrocompatibles avec tous les logiciels largement utilisés. Comme discuté dans un [ticket][Bitcoin Core
  #15560] et [la réunion hebdomadaire du projet ][core meeting segwit], à partir de Bitcoin Core 0.20 (attendu dans environ un an), Bitcoin
  Core utilisera par défaut des adresses segwit natives (bech32) qui offrent des économies de frais supplémentaires et d'autres avantages.
  Actuellement, de nombreux portefeuilles et services [prennent déjà en charge l'envoi vers des adresses bech32][bech32 adoption], et si le
  projet Bitcoin Core constate une adoption supplémentaire suffisante au cours des six prochains mois pour justifier un changement plus
  précoce, il utilisera à la place des adresses de réception bech32 par défaut dans Bitcoin Core 0.19. Les adresses segwit encapsulées dans
  P2SH continueront d'être fournies si l'utilisateur les demande dans l'interface graphique ou par RPC, et toute personne qui ne souhaite
  pas cette mise à jour pourra configurer son type d'adresse par défaut. (De même, les utilisateurs pionniers qui veulent changer leur
  valeur par défaut dès maintenant peuvent définir l'option de configuration `addresstype=bech32` dans toute version de Bitcoin Core à
  partir de 0.16.0.)

## Prise en charge de l'envoi vers Bech32

*Semaine 3 sur 24. Jusqu'au deuxième anniversaire du verrouillage du soft fork segwit le 24 août 2019, le bulletin Optech contiendra cette
rubrique hebdomadaire qui fournit des informations pour aider les développeurs et organisations à mettre en œuvre la prise en charge de
l'envoi vers bech32---la capacité de payer des adresses segwit natives. Cela [ne nécessite pas d'implémenter segwit][bech32 series]
vous-même, mais cela permet aux personnes que vous payez d'accéder à l'ensemble des multiples avantages de segwit.*

{% capture bech32_section %}{% include specials/bech32/03-python-ref.md %}{% endcapture %}
{{ bech32_section
  | replace: "/en/newsletters/", "/fr/newsletters/"
  | replace: "/fr/newsletters/2019/03/19/#bech32-sending-support",
             "/fr/newsletters/2019/03/19/#prise-en-charge-de-lenvoi-vers-bech32"
}}

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [LND][lnd repo], [C-Lightning][c-lightning repo],
[Eclair][eclair repo], [libsecp256k1][libsecp256k1 repo], et [Bitcoin Improvement Proposals (BIPs)][bips repo]. Remarque : toutes les
fusions décrites pour Bitcoin Core sont dans sa branche de développement master ; certaines peuvent également être rétroportées vers la
branche 0.18 pour la publication en attente de la version 0.18.0.*

- [Bitcoin Core #15620][] empêche le paramètre de configuration `maxtxfee` d'affecter les RPC `sendrawtransaction` et `testmempoolaccept`.
  Auparavant, ces RPC rejetaient par défaut une transaction payant des frais supérieurs au maximum configuré. Désormais, une valeur par
  défaut codée en dur de 0.1 BTC est utilisée comme plafond acceptable. Le paramètre de configuration `maxtxfee` est toujours utilisé par le
  portefeuille intégré de Bitcoin Core ; il a simplement été séparé des RPC spécifiques au nœud. Ce changement fait partie d'un [nettoyage
  général des options de configuration du portefeuille][Bitcoin Core #13044] ainsi que de la séparation du nœud et du portefeuille (qui
  utilisaient tous deux ce réglage avant ce changement).

- [Bitcoin Core #15643][] modifie le script Python que les développeurs de Bitcoin Core utilisent pour fusionner des commits afin que le
  message de fusion git inclue une liste des développeurs ayant approuvé (ACKed) la version d'une PR qui a été fusionnée. (Ce changement
  interne au projet n'est peut-être pas notable en lui-même, mais l'une des autres fonctionnalités de l'outil---copier la description
  complète de la PR dans le message de fusion---rend beaucoup plus facile pour l'auteur de cette section de rédiger ces résumés de fusion,
  il encourage donc les autres projets Bitcoin à étudier les avantages de l'utilisation de cet outil pour créer automatiquement une
  meilleure documentation basée sur git, ainsi que pour améliorer leur sécurité et leur auditabilité.)

- [Bitcoin Core #15519][] ajoute une implémentation de [Poly1305][] à Bitcoin Core mais ne l'utilise pas. Il est prévu qu'elle soit utilisée
  plus tard pour une implémentation du [chiffrement du protocole P2P][p2p protocol encryption].

- [Bitcoin Core #15637][] modifie les RPC liés au mempool (tels que `getrawmempool`) pour renommer le champ `size` en `vsize`. La valeur
  précédente était également la vsize, donc le calcul n'a pas changé. Cette PR fusionnée clarifie simplement qu'il s'agit d'une vsize et non
  d'une taille dépouillée. Pour la rétrocompatibilité, vous pouvez démarrer Bitcoin Core avec le paramètre `deprecatedrpc=size` pour
  continuer à utiliser l'ancien nom de champ, bien que cela sera supprimé dans une future version.

- [LND #2759][] abaisse le [delta CLTV][bolt2 delta] par défaut pour tous les canaux de 144 blocs (environ 24,0 heures) à 40 blocs (environ
  6,7 heures). Quand Alice veut payer Zed à travers une série de nœuds de routage, elle commence par donner de l'argent à Bob selon les
  termes voulant qu'Alice puisse soit le reprendre après (disons) 400 blocs, soit Bob puisse réclamer l'argent avant cela s'il peut fournir
  la préimage d'un hachage particulier (la clé qui ouvre un hashlock). Le délai de 400 blocs est appliqué onchain si nécessaire en utilisant
  `OP_CHECKLOCKTIMEVERIFY` (CLTV). Bob envoie ensuite l'argent (moins ses frais de routage) à Charlie avec des conditions similaires sauf
  que la valeur CLTV est réduite par rapport aux 400 blocs initiaux d'Alice du delta CLTV de son canal avec Charlie, réduisant la valeur à
  360 blocs. Cela garantit que si Charlie attend le temps maximal pour exécuter son HTLC envers Bob et réclamer son paiement (360 blocs),
  Bob dispose encore de 40 blocs pour réclamer _son_ paiement auprès d'Alice en exécutant le HTLC initial. Si le délai d'expiration du HTLC
  de Bob avec Charlie n'était pas réduit du tout et utilisait un délai de 400 blocs, Bob courrait le risque de perdre de l'argent. Charlie
  pourrait retarder l'exécution de son HTLC jusqu'à 400 blocs, et Alice pourrait alors annuler son HTLC avec Bob avant que Bob n'ait eu le
  temps d'exécuter le HTLC.

  Les routeurs suivants soustraient chacun successivement leur delta de la valeur des conditions qu'ils donnent au nœud suivant dans la
  route. Utiliser un delta CLTV élevé réduit donc le nombre possible de sauts pouvant être utilisés dans une route, et rend un canal moins
  attrayant pour être utilisé lors du routage des paiements.

- [Eclair #894][] remplace l'interface JSON-RPC par une interface HTTP POST. Au lieu de commandes RPC, des points de terminaison HTTP sont
  utilisés (par ex. le RPC `channelstats` est maintenant `POST http://localhost:8080/channelstats`). Les paramètres sont fournis au point de
  terminaison à l'aide de paramètres de formulaire nommés avec la même syntaxe JSON que celle utilisée avec les paramètres RPC. Les
  résultats renvoyés sont identiques à avant le changement. L'ancienne interface est toujours disponible en utilisant le paramètre de
  configuration `eclair.api.use-old-api=true`, mais il est prévu qu'elle soit supprimée dans une version ultérieure. Voir la [documentation
  API mise à jour][eclair api docs] pour les détails.

{% include linkers/issues.md issues="15555,15560,15620,15643,15519,15637,2759,894,13044" %}
[0.18.0]: https://bitcoincore.org/bin/bitcoin-core-0.18.0/
[poly1305]: https://en.wikipedia.org/wiki/Poly1305
[0.16.0 segwit]: https://bitcoincore.org/en/releases/0.16.0/#segwit-wallet
[eclair api docs]: https://acinq.github.io/eclair/#introduction
[johoe's mempool statistics]: https://jochen-hoenicke.de/queue/#0,1w
[p2sh.info's fee estimate tracker]: https://p2sh.info/dashboard/db/fee-estimation?orgId=1
[trampoline thread]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-March/001939.html
[core meeting segwit]: http://www.erisian.com.au/meetbot/bitcoin-core-dev/2019/bitcoin-core-dev.2019-03-28-19.01.log.html#l-83
[bech32 adoption]: https://en.bitcoin.it/wiki/Bech32_adoption
[bolt2 delta]: https://github.com/lightningnetwork/lightning-rfc/blob/master/02-peer-protocol.md#cltv_expiry_delta-selection
[p2p protocol encryption]: https://gist.github.com/jonasschnelli/c530ea8421b8d0e80c51486325587c52
[bech32 series]: /en/bech32-sending-support/
[le bulletin #22]: /fr/newsletters/2018/11/20/#surveiller-les-taux-de-frais
