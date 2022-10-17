---
title: 'Bitcoin Optech Newsletter #221'
permalink: /fr/newsletters/2022/10/12/
name: 2022-10-12-newsletter-fr
slug: 2022-10-12-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
La newsletter de cette semaine résume une proposition visant à permettre
aux utilisateurs occasionnels de LN de rester hors ligne jusqu'à plusieurs
mois d'affilée et décrit un document permettant aux serveurs d'information
sur les transactions d'héberger des adresses de portefeuilles inutilisées.
Vous trouverez également nos sections habituelles avec le résumé d'un
Bitcoin Core PR Review Club, des annonces de nouvelles versions de
logiciels et de release candidate (y compris un correctif critique pour le LN),
et les principaux changements apportés aux logiciels d'infrastructure Bitcoin.

## Nouvelles

- **LN avec une proposition de hors ligne long :** John Law [a posté][law post]
  sur la liste de diffusion Lightning-Dev une [proposition][law pdf] pour
  permettre aux utilisateurs occasionnels de Lightning de rester hors ligne
  jusqu'à plusieurs mois sans risquer de perdre des fonds avec leurs partenaires
  de canaux. Bien que cela soit techniquement possible dans le protocole LN actuel,
  cela dépendrait de la définition du paramètre 'settlement-delay' à des valeurs
  élevées qui permettraient à un utilisateur malheureux ou à un accident d'empêcher
  les fonds de plus d'une douzaine de canaux d'être utilisés pour ces mêmes mois.
  Law propose de mitiger ce problème à travers deux modifications du protocole:

    - *Triggered HTLCs:* Dans une norme [HTLC][topic htlc] utilisée pour
      le paiement, Alice offre à Bob une certaine quantité de BTC s'il est
      capable de publier une *préimage* inconnue auparavant pour un condensé
      de hachage connu. Alternativement, si Bob ne publie pas la préimage
      avant un certain temps, Alice peut retourner l'argent dans son propre
      portefeuille.
        Law suggère que Bob soit toujours autorisé à réclamer le paiement à
        tout moment avec la publication de la préimage, mais Alice devrait
        remplir une restriction supplémentaire. Elle devrait clairement avertir
        Bob de son intention de récupérer l'argent dans son portefeuille en
        faisant confirmer une transaction *trigger* sur la chaîne. Ce n'est
        que lorsque la transaction de déclenchement aura été confirmée par un
        certain nombre de blocs (ou pendant une certaine durée) qu'Alice
        pourra dépenser l'argent.

        Bob serait assuré de pouvoir réclamer ses fonds à tout moment jusqu'à
        ce que la transaction de déclenchement ait reçu le nombre convenu de
        confirmations, même si des mois se sont écoulés depuis qu'un HTLC
        normal aurait expiré. Si Bob est correctement indemnisé pour son attente,
        il n'y a pas de problème si Alice reste hors ligne pendant tout ce temps.
        Pour un HTLC acheminé d'Alice vers un nœud distant en passant par Bob,
        seul le canal entre Alice et Bob serait affecté----tous les autres canaux
        régleraient le HTLC rapidement (comme dans le protocole LN actuel).

    - *Asymmetric delayed commitment transactions:* chacun des deux
      partenaires d'un canal LN détient un engagement non publié qu'ils peuvent
      publier et essayer de faire confirmer à tout moment. Les deux versions de
      la transaction dépensent le même UTXO, de sorte qu'elles entrent en conflit
      l'une avec l'autre. Ce qui signifie qu'une seule peut effectivement être
      confirmée.

        Cela signifie que quand Alice veut fermer le canal, elle ne peut pas juste
        simplement diffuser sa version de la transaction d'engagement avec
        un délai raisonnable et supposer qu'elle sera confirmée.
        Elle doit aussi attendre et vérifier si Bob obtient au contraire
        sa version de la transaction d'engagement, auquel cas elle devra
        peut-être avoir besoin de prendre des mesures supplémentaires pour
        vérifier que sa transaction inclut le dernier état du canal.

        Law propose que la version d'Alice de la transaction d'engagement reste
        la même qu'aujourd'hui afin qu'elle puisse la publier à tout moment, mais
        que la version de Bob comprenne un verrou temporel afin qu'il ne puisse
        la publier que si Alice a été inactive pendant une longue période.
        Idéalement, cela permet à Alice de publier le dernier état en sachant que
        Bob ne peut pas publier une version contradictoire, ce qui lui permet de
        se déconnecter en toute sécurité après sa publication.

    Les propositions de Law recevaient encore un premier retour d'information au
    moment où cette description était rédigée.

- **Recommandations pour les serveurs d'adresses uniques:** Ruben Somsen
  [a posté][somsen post] sur la liste de diffusion Bitcoin-Dev un
  [document][somsen gist] avec une autre suggestion sur la façon dont les
  utilisateurs peuvent éviter un [output linking][topic output linking]
  sans faire confiance à un service tiers ou utiliser un protocole
  cryptographique qui n'est pas largement pris en charge actuellement,
  comme le [BIP47][] ou [silent payments][topic silent payments].
  La méthode recommandée est particulièrement destinée aux portefeuilles
  qui fournissent déjà leurs adresses à des tiers, comme ceux qui utilisent
  des [serveurs publics de recherche d'adresses][topic block explorers]
  (ce qui est censé être la majorité des portefeuilles légers).

    Pour illustrer le fonctionnement de cette méthode, le portefeuille d'Alice
    enregistre 100 adresses sur le serveur Example.com de style electrum.
    Elle inclut ensuite "example.com/alice" dans sa signature de courriel.
    Lorsque Bob veut donner de l'argent à Alice, il visite son URL, obtient
    une adresse, vérifie qu'Alice l'a signée, puis effectue le paiement.

    Cette idée présente l'avantage d'être largement compatible avec de nombreux
    portefeuilles grâce à un processus partiellement manuel et peut être facile
    à mettre en œuvre avec un processus automatisé. Son inconvénient est que les
    utilisateurs qui compromettent déjà leur vie privée en partageant des adresses
    avec un serveur s'engageront davantage dans la perte de confidentialité.

    La discussion sur les suggestions était en cours à la fois sur la liste de
    diffusion et sur le document au moment de la rédaction de ce résumé.

## Bitcoin Core PR Review Club

*Dans cette section mensuelle, nous résumons une récente réunion du
[Bitcoin Core PR Review Club][] en soulignant certaines des questions
et réponses importantes. Cliquez sur une question ci-dessous pour voir
un résumé de la réponse de la réunion.*

[Fabriquer des connexions AddrFetch pour fixer les seeds][review club 26114]
est une PR de Martin Zumsande qui établit des connexions `AddrFetch` vers les
[fixed seeds][] (adresses IP codées en dur) au lieu de simplement les ajouter
à `AddrMan` (la base de données de nos pairs).

{% include functions/details-list.md
  q0="Lorsqu'un nouveau nœud démarre à partir de zéro, il doit d'abord se connecter
à certains pairs à partir desquels il effectuera le téléchargement du bloc initial
(IBD). Dans quelles circonstances se connecte-t-il aux fixed seeds?"
  a0="Seulement s'il n'est pas en mesure de se connecter aux pairs dont les adresses
sont fournies par les nœuds d'amorçage Bitcoin DNS codés en dur. Cela se produit
le plus souvent lorsque le nœud est configuré pour ne pas utiliser IPv4 ou IPv6.
(par exemple, `-onlynet=tor`)."
  a0link="https://bitcoincore.reviews/26114#l-27"

  q1="Quel changement de comportement observable cette PR introduit-elle ? Quels types
d'adresses ajoutons-nous à `AddrMan`, et dans quelles circonstances?"
  a1="Le noeud, au lieu d'ajouter immédiatement les graines fixes à son `AddrMan` et
d'établir des connexions complètes avec certaines d'entre elles, il établit des
connexions `AddrFetch` avec certaines d'entre elles, et ajoute les _returned addresses_
à `AddrMan`. (`AddrFetch` sont des connexions à court terme qui ne sont utilisées que
pour récupérer des adresses.)
Le noeud se connecte ensuite à certaines des adresses qui se trouvent maintenant dans
son `AddrMan` pour effectuer l'IBD.
Il en résulte moins de connexions complètes aux nœuds à graines fixes ; au lieu de cela,
davantage de connexions sont tentées à partir de l'ensemble beaucoup plus vaste de nœuds
dont les nœuds à graines fixes nous parlent. Les connexions `AddrFetch` peuvent retourner
_tout_ type d'adresses, par exemple, `tor` ; les résultats ne sont pas limités à IPv4 et IPv6."
  a1link="https://bitcoincore.reviews/26114#l-63"

  q2="Pourquoi voudrions-nous établir une connexion `AddrFetch` au lieu d'une connexion
  sortante complète vers des graines fixes?"
  a2="Une connexion `AddrFetch` permet à notre nœud de choisir des pairs d'IBD à partir
d'un ensemble beaucoup plus grand de pairs, ce qui augmente la distribution globale de la
connectivité du réseau. Les opérateurs de nœuds de seed fixes seraient moins susceptibles
d'avoir plusieurs pairs d'IBD simultanés, ce qui réduit les besoins en ressources sur
leurs nœuds."
  a2link="https://bitcoincore.reviews/26114#l-77"

  q3="Les nœuds DNS d'amorçage sont censés être réactifs et servir les adresses actualisées
des nœuds Bitcoin. Pourquoi cela n'aide-t-il pas un noeud `-onlynet=tor?`"
  a3="Les nœuds DNS d'amorçage ne fournissent que des adresses IPv4 et IPv6;
ils ne sont pas en mesure de fournir un autre type d'adresse."
  a3link="https://bitcoincore.reviews/26114#l-35"
%}

## Mises à jour release candidate

*Nouvelles mises à jour et release candidates du principal logiciel d'infrastructure Bitcoin.
Prévoyez s'il vous plait de vous mettre à jour à la nouvelle version ou d'aider à tester
les pré-versions.*

- [LND v0.15.2-beta][] est une version d'urgence à sécurité critique qui corrige une erreur
  d'analyse qui empêchait LND d'analyser certains blocs. Tous les utilisateurs doivent
  effectuer la mise à jour.

- [Bitcoin Core 24.0 RC1][] est la première release candidate pour la prochaine version de
  l'implémentation de nœuds complets la plus largement utilisée sur le réseau.
  Un [guide pour tester][bcc testing] est disponible.

## Changements notables dans le code et la documentation

*Changements notables cette semaine dans [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], et [Lightning BOLTs][bolts repo].*

- [LND #6500][] Ajoute la possibilité de chiffrer la clé privée Tor sur le disque en utilisant
  la clé privée du portefeuille au lieu de la stocker en clair. En utilisant l'option
  `--tor.encryptkey`, LND chiffre la clé privée et le blob chiffré est écrit dans le même fichier
  sur le disque, permettant aux utilisateurs de conserver les mêmes fonctionnalités (comme le
  rafraîchissement d'un service caché), mais ajoute une protection lors de l'exécution dans des
  environnements non fiables.

{% include references.md %}
{% include linkers/issues.md v=2 issues="6500" %}
[review club 26114]: https://bitcoincore.reviews/26114
[bitcoin core 24.0 rc1]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/24.0-Release-Candidate-Testing-Guide
[law post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-October/003707.html
[law pdf]: https://raw.githubusercontent.com/JohnLaw2/ln-watchtower-free/main/watchtowerfree10.pdf
[somsen post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-September/020952.html
[somsen gist]: https://gist.github.com/RubenSomsen/960ae7eb52b79cc826d5b6eaa61291f6
[news113 witasym]: /en/newsletters/2020/09/02/#witness-asymmetric-payment-channels
[lnd v0.15.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.2-beta
[fixed seeds]: https://github.com/bitcoin/bitcoin/tree/master/contrib/seeds
