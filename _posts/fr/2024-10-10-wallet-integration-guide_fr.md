---
title: "Guide pour les portefeuilles utilisant les politiques de Bitcoin Core 28.0"
permalink: /fr/guide-integration-portefeuille-bitcoin-core-28/
name: 2024-10-10-guide-integration-portefeuille-bitcoin-core-28
type: posts
layout: post
lang: fr
slug: 2024-10-10-guide-integration-portefeuille-bitcoin-core-28

excerpt: >
  Bitcoin Core 28.0 contient de nouvelles fonctionnalités de politique P2P et de mempool qui peuvent être utiles pour un certain nombre de portefeuilles et de types de transactions. Ici, Gregory Sanders présente un guide de haut niveau sur l'ensemble des fonctionnalités et comment elles peuvent être utilisées individuellement ou ensemble.

---

{:.post-meta}
*par [Gregory Sanders][]*

Dans [Bitcoin Core 28.0][bc 28.0], de nouvelles [fonctionnalités][bc 28.0 release notes] de politique P2P et de mempool
qui peuvent être utiles pour un certain nombre de portefeuilles et
de types de transactions. Ici, Gregory Sanders présente un guide de haut niveau sur l'ensemble des
fonctionnalités et comment elles peuvent être utilisées individuellement ou ensemble.

## Relais Un Parent Un Enfant (1P1C)

Avant Bitcoin Core 28.0, chaque transaction doit atteindre ou dépasser le taux minimal de frais du
mempool local pour même y entrer. Cette
valeur monte et descend approximativement avec la congestion des transactions, créant un
plancher fluctuant pour la propagation d'un paiement. Cela crée une grande difficulté pour
les portefeuilles traitant des transactions pré-signées qui ne peuvent pas signer de
[replacements][topic rbf] et doivent prédire quelle sera la valeur future du plancher lorsqu'il sera
temps de régler la transaction. C'est déjà assez difficile sur une période de minutes, mais
clairement impossible sur des mois.

[Le relais de paquets][topic package relay] a été une fonctionnalité très recherchée pour
le réseau afin de mitiger ce risque de transactions bloquées sans
options de hausse des frais. Une fois correctement développé et déployé largement sur le réseau,
le relais de paquets permettrait aux développeurs de portefeuilles d'ajouter des frais à une
transaction via
des transactions liées, permettant aux ancêtres à faible frais d'être inclus dans le mempool.

Dans Bitcoin Core 28.0, une variante limitée du relais de paquets pour les paquets contenant
1 parent et 1 enfant ("1P1C") a été implémentée. 1P1C permet à un seul parent d'entrer dans
le mempool, indépendamment du taux minimal dynamique du mempool, en utilisant une seule
transaction enfant et une simple hausse de frais [Child Pays For Parent (CPFP)][topic cpfp]. Si la
transaction enfant a des parents non confirmés supplémentaires, ces
transactions ne se propageront pas avec succès. Cette restriction a grandement simplifié
l'implémentation et a permis à d'autres travaux sur le mempool, tels que [le mempool en cluster][topic
cluster mempool], de continuer sans entrave tout en ciblant un grand nombre de cas d'utilisation.

À moins qu'une transaction ne soit une [transaction TRUC][topic v3 transaction relay]
(décrite plus tard), chaque transaction doit encore rencontrer un minimum *statique* de 1 satoshi
par octet virtuel.

Une dernière mise en garde concernant cette fonctionnalité est que les garanties de propagation pour
cette version sont également limitées. Si le nœud Bitcoin Core est connecté à un
adversaire suffisamment déterminé, ils peuvent perturber la propagation de la paire de transactions
parent et enfant. Le renforcement supplémentaire du relais de paquets continue en tant que
[projet][package relay tracking issue] en cours.

Le relais de paquets général reste un travail futur, qui sera alimenté par les données du relais de
paquets limité et son déploiement sur le réseau.

Voici les commandes pour configurer un portefeuille démontrant le relais 1P1C dans un environnement
regtest :

```hack
bitcoin-cli -regtest createwallet test
{
  "name": "test"
}
```

```hack
# Obtenir une adresse pour s'envoyer à soi-même
bitcoin-cli -regtest -rpcwallet=test getnewaddress
bcrt1qqzv3ekkueheseddqge3mqdcukse6p9d5yuqxv3
```

```hack
# Créer une transaction à faible frais au-dessus de “minrelay”
bitcoin-cli -regtest -rpcwallet=test -generate 101
{
[
...
]
}

bitcoin-cli -regtest -rpcwallet=test listunspent
[
  {
    "txid": "49ea7a01bcba744bd82ecea3e36c4ee9a994f010508a28a09df38f652e74643b",
    "vout": 0,
    ...
    "amount": 50.00000000,
    ...
  }
]

# Mempool minfee et minrelay sont identiques, pour tester cette fonctionnalité plus facilement
# nous utiliserons des transactions TRUC pour permettre des transactions sans frais qui nécessitent
un relais 1P1C.
# Fullrbf est également activé, ce qui est le défaut pour la version 28.0.
bitcoin-cli -regtest getmempoolinfo
{
  "loaded": true,
  ...
  "mempoolminfee": 0.00001000,
  "minrelaytxfee": 0.00001000,
  ...
  “fullrbf”: true,
}

# Commencer avec une transaction v2
bitcoin-cli -regtest createrawtransaction '[{"txid": "49ea7a01bcba744bd82ecea3e36c4ee9a994f010508a28a09df38f652e74643b", "vout": 0}]' '[{"bcrt1qqzv3ekkueheseddqge3mqdcukse6p9d5yuqxv3": "50.00000000"}]'

02000000013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff01f90295000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000

# Et remplacer le 02 initial par 03 qui est la version TRUC
03000000013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff01f90295000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000

# Signer et envoyer
bitcoin-cli -regtest -rpcwallet=test signrawtransactionwithwallet 03000000013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff01f90295000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000
{
  "hex": "030000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff01f90295000000000016001400991cdadccdf30cb5a04663b0371cb433a095b40247304402200a82f2fd8aa5f32cdfd9540209ccfc36a95eea21518ede1c3787561c8fb7269702207a258e6f027ce156271879c38628ad9b3425b83c33d8cd95fb20dd3c567fdff70121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000",
  "complete": true
}

bitcoin-cli -regtest sendrawtransaction 030000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff01f90295000000000016001400991cdadccdf30cb5a04663b0371cb433a095b40247304402200a82f2fd8aa5f32cdfd9540209ccfc36a95eea21518ede1c3787561c8fb7269702207a258e6f027ce156271879c38628ad9b3425b83c33d8cd95fb20dd3c567fdff70121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000

error code: -26
error message:
min relay fee not met, 0 < 110

# Nous avons besoin du relais de paquet et de CPFP utilisant la sortie unique
bitcoin-cli -regtest decoderawtransaction 030000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff01f90295000000000016001400991cdadccdf30cb5a04663b0371cb433a095b40247304402200a82f2fd8aa5f32cdfd9540209ccfc36a95eea21518ede1c3787561c8fb7269702207a258e6f027ce156271879c38628ad9b3425b83c33d8cd95fb20dd3c567fdff70121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000

{
  "txid": "bf9164db69d216da4af6d9c720a0cec6d7e0bafb1702fdf8c2cd5606101576de",
  "hash": "7d855ffbd8bc17892e28f3f326d0e4919d35c27a7370f5d9f9ce538e93a347cf",
  "version": 3,
  "size": 191,
  "vsize": 110,
  ...
  "vout": [
    ...
    "scriptPubKey": {
      "hex": "001400991cdadccdf30cb5a04663b0371cb433a095b4",
    ...
}

# Exclure les sats pour les frais de CPFP
bitcoin-cli -regtest createrawtransaction '[{"txid": "bf9164db69d216da4af6d9c720a0cec6d7e0bafb1702fdf8c2cd5606101576de", "vout": 0}]' '[{"bcrt1qqzv3ekkueheseddqge3mqdcukse6p9d5yuqxv3": "49.99994375"}]'
0200000001de7615100656cdc2f8fd0217fbbae0d7c6cea020c7d9f64ada16d269db6491bf0000000000fdffffff0100ed94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000

# Signer la variante TRUC et envoyer, comme un package 1P1C
bitcoin-cli -regtest -rpcwallet=test signrawtransactionwithwallet 0300000001de7615100656cdc2f8fd0217fbbae0d7c6cea020c7d9f64ada16d269db6491bf0000000000fdffffff0100ed94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000 '[{"txid": "bf9164db69d216da4af6d9c720a0cec6d7e0bafb1702fdf8c2cd5606101576de", "vout": 0, "scriptPubKey": "001400991cdadccdf30cb5a04663b0371cb433a095b4", "amount": "50.00000000"}]'
{
  "hex": "03000000000101de7615100656cdc2f8fd0217fbbae0d7c6cea020c7d9f64ada16d269db6491bf0000000000fdffffff0100ed94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4024730440220685a6d76db97b2c27950f267b70d606f1864002ff6b4617cd2e29afd5ddfac83022037be8bb2ebe8194b4263f16a634e5c00a5f6c4eef0968d12994ed66dcf15b9ac0121020797cc343a24dfe49c7ee9b94bf3daaf15308d8c12e3f0f7e102b95ee55f939f00000000",
  "complete": true
}

bitcoin-cli -regtest -rpcwallet=test submitpackage '["030000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff01f90295000000000016001400991cdadccdf30cb5a04663b0371cb433a095b40247304402200a82f2fd8aa5f32cdfd9540209ccfc36a95eea21518ede1c3787561c8fb7269702207a258e6f027ce156271879c38628ad9b3425b83c33d8cd95fb20dd3c567fdff70121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000", "03000000000101de7615100656cdc2f8fd0217fbbae0d7c6cea020c7d9f64ada16d269db6491bf0000000000fdffffff0100ed94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4024730440220685a6d76db97b2c27950f267b70d606f1864002ff6b4617cd2e29afd5ddfac83022037be8bb2ebe8194b4263f16a634e5c00a5f6c4eef0968d12994ed66dcf15b9ac0121020797cc343a24dfe49c7ee9b94bf3daaf15308d8c12e3f0f7e102b95ee55f939f00000000"]'
{
  "package_msg": "success",
  "tx-results": {
    "7d855ffbd8bc17892e28f3f326d0e4919d35c27a7370f5d9f9ce538e93a347cf": {
      "txid": "bf9164db69d216da4af6d9c720a0cec6d7e0bafb1702fdf8c2cd5606101576de",
      "vsize": 110,
      "fees": {
        "base": 0.00000000,
        "effective-feerate": 0.00025568,
        "effective-includes": [
          "7d855ffbd8bc17892e28f3f326d0e4919d35c27a7370f5d9f9ce538e93a347cf",
          "4333b3d2eea820373262c7ffb768028bc82f99f47839349722eb60c58cd65b55"
        ]
      }
    },
    "4333b3d2eea820373262c7ffb768028bc82f99f47839349722eb60c58cd65b55": {
      "txid": "6c2f4dec614c138703f33e6a5c215112bad4cf79593e9757105e09b09bf3e2de",
      "vsize": 110,
      "fees": {
        "base": 0.00005625,
        "effective-feerate": 0.00025568,
        "effective-includes": [
          "7d855ffbd8bc17892e28f3f326d0e4919d35c27a7370f5d9f9ce538e93a347cf",
          "4333b3d2eea820373262c7ffb768028bc82f99f47839349722eb60c58cd65b55"
        ]
      }
    }
  },
  "replaced-transactions": [
  ]
}
```

Le package 1P1C a été intégré dans le mempool local avec un taux de frais effectif de
25.568 sats par vB même si la transaction parente est en dessous du taux de frais minrelay.
Succès !

## Transactions TRUC

Les transactions Topologically Restricted Until Confirmation (TRUC), également connues sous le nom
de transactions v3, représentent une nouvelle [politique de mempool][policy series] facultative visant à
permettre un remplacement robuste par les frais (RBF) des transactions, en atténuant à la fois
le blocage des transactions lié aux frais ainsi que le blocage de la limite des packages. Sa
philosophie centrale est : **bien que de nombreuses fonctionnalités soient irréalisables
pour toutes les transactions, nous pouvons les implémenter pour des packages avec une topologie
limitée**. TRUC crée un moyen d'opter pour cet ensemble de politiques plus robustes en plus des
restrictions topologiques.

En bref, une transaction TRUC est une transaction avec une nVersion de 3, qui
limite la transaction soit à un singleton allant jusqu'à 10kvB, soit à l'enfant de
exactement une transaction TRUC plafonnée à 1kvB. Une transaction TRUC ne peut pas dépenser une
transaction non-TRUC, et vice versa. Toutes les transactions TRUC sont considérées
comme acceptant RBF indépendamment du signal [BIP125][]. Si un autre enfant TRUC non conflictuel
est ajouté à la transaction parente TRUC, il sera traité comme un
[conflit][topic kindred rbf] avec l'enfant original, et les règles de résolution RBF normales
s'appliquent, y compris les vérifications de taux de frais et de frais totaux.

Les transactions TRUC peuvent également être sans frais, à condition qu'une transaction enfant
augmente suffisamment le taux de frais du package global.

La topologie limitée s'inscrit également parfaitement dans le paradigme de relais 1P1C,
indépendamment de ce que font les contreparties de la transaction, en supposant que toutes les
versions des transactions signées sont TRUC.

Les paiements TRUC sont remplaçables, donc toute transaction avec des entrées non possédées au
moins en partie par le transacteur peut être dépensée en double. En d'autres termes, recevoir
des paiements TRUC zéro-conf n'est pas plus sûr que de recevoir des paiements non-TRUC.

## Topologie 1P1C Paquet RBF

Il arrive que le parent du paquet 1P1C soit en conflit avec le parent du pool de mémoire. Cela
peut se produire lorsqu'il existe plusieurs versions de la transaction parentale présignée.
Auparavant, le nouveau parent était pris en compte uniquement pour la RBF, puis rejeté si
les frais étaient trop faibles.

Avec le paquet de topologie 1P1C RBF, le nouvel enfant sera également pris en compte dans les
vérifications RBF, ce qui permettra à un développeur de portefeuille d'obtenir une transmission
robuste des paquets 1P1C à travers le réseau P2P, quelles que soient les versions des transactions
qui ont atteint leur mempool local.

Notez qu'actuellement, les transactions en conflit doivent toutes être des singletons ou des paquets
de transactions 1P1C sans autres dépendances. Sinon, le remplacement sera rejeté. N'importe quel
nombre de ces clusters peut être en conflit.
Cette règle sera assouplie dans une prochaine version grâce à l'utilisation de cluster mempool.

En poursuivant notre exemple 1P1C, nous allons exécuter un paquet RBF contre le paquet 1P1C existant,
cette fois avec une transaction en paquet non-TRUC :


```hack
# Paire parent et enfant TRUC
bitcoin-cli -regtest getrawmempool
[
  "bf9164db69d216da4af6d9c720a0cec6d7e0bafb1702fdf8c2cd5606101576de",
  "6c2f4dec614c138703f33e6a5c215112bad4cf79593e9757105e09b09bf3e2de"
]

# Effectuer un double dépense du parent avec un nouveau package 1P1C v2
# où les frais du parent sont supérieurs à minrelay mais pas suffisants pour RBF le package
bitcoin-cli -regtest createrawtransaction '[{"txid": "49ea7a01bcba744bd82ecea3e36c4ee9a994f010508a28a09df38f652e74643b", "vout": 0}]' '[{"bcrt1qqzv3ekkueheseddqge3mqdcukse6p9d5yuqxv3": "49.99999"}]'

02000000013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff0111ff94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000

# Signer et (échouer à) envoyer
bitcoin-cli -regtest -rpcwallet=test signrawtransactionwithwallet 02000000013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff0111ff94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000
{
  "hex": "020000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff0111ff94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4024730440220488d98ad79495276bb4cdda4d7c62292043e185fa705d505c7dceef76c4b61d30220567243245416a9dd3b76f3d94bfd749e0915929226ba079ec918f6675cbfa3950121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000",
  "complete": true
}

bitcoin-cli -regtest sendrawtransaction 020000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff0111ff94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4024730440220488d98ad79495276bb4cdda4d7c62292043e185fa705d505c7dceef76c4b61d30220567243245416a9dd3b76f3d94bfd749e0915929226ba079ec918f6675cbfa3950121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000

error code: -26
error message:
insufficient fee, rejecting replacement f17146d87a029cb04777256fc0382c637a31b2375f3981df0fb498b9e44ceb59, less fees than conflicting txs; 0.00001 < 0.00005625

# Apporter des frais supplémentaires au nouveau paquet via un enfant pour battre l'ancien paquet
bitcoin-cli -regtest createrawtransaction '[{"txid": "f17146d87a029cb04777256fc0382c637a31b2375f3981df0fb498b9e44ceb59", "vout": 0}]' '[{"bcrt1qqzv3ekkueheseddqge3mqdcukse6p9d5yuqxv3": "49.99234375"}]'

020000000159eb4ce4b998b40fdf81395f37b2317a632c38c06f257747b09c027ad84671f10000000000fdffffff01405489000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000

# Signer et envoyer en tant que paquet
bitcoin-cli -regtest -rpcwallet=test signrawtransactionwithwallet 020000000159eb4ce4b998b40fdf81395f37b2317a632c38c06f257747b09c027ad84671f10000000000fdffffff01405489000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000 '[{"txid": "f17146d87a029cb04777256fc0382c637a31b2375f3981df0fb498b9e44ceb59", "vout": 0, "scriptPubKey": "001400991cdadccdf30cb5a04663b0371cb433a095b4", "amount": "49.99999"}]'
{
  "hex": "0200000000010159eb4ce4b998b40fdf81395f37b2317a632c38c06f257747b09c027ad84671f10000000000fdffffff01405489000000000016001400991cdadccdf30cb5a04663b0371cb433a095b40247304402205d086fa617bdbf5a3df3a15cc9a927ad884c714d46d9ef6762ad2fa6a259740c022032c60b4fe5d533d990489c27dc3283d8b3999b97f6c12986ac8159b92cb6de820121020797cc343a24dfe49c7ee9b94bf3daaf15308d8c12e3f0f7e102b95ee55f939f00000000",
  "complete": true
}

bitcoin-cli -regtest -rpcwallet=test submitpackage '["020000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff0111ff94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4024730440220488d98ad79495276bb4cdda4d7c62292043e185fa705d505c7dceef76c4b61d30220567243245416a9dd3b76f3d94bfd749e0915929226ba079ec918f6675cbfa3950121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000", "0200000000010159eb4ce4b998b40fdf81395f37b2317a632c38c06f257747b09c027ad84671f10000000000fdffffff01405489000000000016001400991cdadccdf30cb5a04663b0371cb433a095b40247304402205d086fa617bdbf5a3df3a15cc9a927ad884c714d46d9ef6762ad2fa6a259740c022032c60b4fe5d533d990489c27dc3283d8b3999b97f6c12986ac8159b92cb6de820121020797cc343a24dfe49c7ee9b94bf3daaf15308d8c12e3f0f7e102b95ee55f939f00000000"]'
{
  "package_msg": "success",
  "tx-results": {
    "fe15d23f59537d12cddf510616397b639a7b91ba2f846c64533e847e53d7c313": {
      "txid": "f17146d87a029cb04777256fc0382c637a31b2375f3981df0fb498b9e44ceb59",
      "vsize": 110,
      "fees": {
        "base": 0.00001000,
        "effective-feerate": 0.03480113,
        "effective-includes": [
          "fe15d23f59537d12cddf510616397b639a7b91ba2f846c64533e847e53d7c313",
          "256cebd037963d77b2692cdc33ee36ee0b0944e6b9486a6aaad0792daa0f677c"
        ]
      }
    },
    "256cebd037963d77b2692cdc33ee36ee0b0944e6b9486a6aaad0792daa0f677c": {
      "txid": "858fe07b01bc7c1c1dda50ba16a33b164c0bc03d0eff8f9546558c088e087f60",
      "vsize": 110,
      "fees": {
        "base": 0.00764625,
        "effective-feerate": 0.03480113,
        "effective-includes": [
          "fe15d23f59537d12cddf510616397b639a7b91ba2f846c64533e847e53d7c313",
          "256cebd037963d77b2692cdc33ee36ee0b0944e6b9486a6aaad0792daa0f677c"
        ]
      }
    }
  },
  "replaced-transactions": [
    "bf9164db69d216da4af6d9c720a0cec6d7e0bafb1702fdf8c2cd5606101576de",
    "6c2f4dec614c138703f33e6a5c215112bad4cf79593e9757105e09b09bf3e2de"
  ]
}

```

## Paiement Vers Ancre (P2A)

[Les ancres][topic anchor outputs] sont définies comme une sortie ajoutée uniquement pour permettre à une transaction enfant
de payer une transaction parent, CPFP (Child Pays for Parent). Puisque ces sorties ne sont pas des paiements,
elles ont des valeurs en satoshis faibles, proches de la "poussière", et sont immédiatement
dépensées.

Un nouveau type de script de sortie, [Paiement Vers Ancre (P2A)][topic ephemeral anchors], a été ajouté, permettant une version
"sans clé" optimisée des ancres. Le script de sortie est "OP_1 <4e73>", qui ne nécessite aucune
donnée de témoin pour être dépensé, signifiant une réduction des frais par rapport aux sorties
d'ancre existantes. Il permet également à quiconque de créer la transaction CPFP.

P2A peut être utilisé indépendamment des transactions TRUC ou des paquets 1P1C. Une transaction avec
une sortie P2A mais sans enfant peut être diffusée, bien que la sortie soit trivialement dépensable.
De même, les paquets et les transactions TRUC n'ont pas besoin d'avoir des sorties P2A pour utiliser
les nouvelles fonctionnalités de hausse des frais.

Ce nouveau type de sortie a une limite de poussière de 240 satoshis. Les sorties P2A en dessous de
ce seuil de poussière ne se propagent pas, même si elles sont dépensées dans un paquet, car la
limite de [poussière][topic uneconomical outputs] est toujours entièrement appliquée dans la
politique. Bien que cette proposition ait été précédemment liée à la poussière éphémère, ce n'est
plus le cas.

Exemple de création et de dépense P2A :

```hack
# L'adresse Regtest pour P2A est “bcrt1pfeesnyr2tx” en regtest, “bc1pfeessrawgf” en mainnet
bitcoin-cli -regtest getaddressinfo bcrt1pfeesnyr2tx
{
  "address": "bcrt1pfeesnyr2tx",
  "scriptPubKey": "51024e73",
  "ismine": false,
  "solvable": false,
  "iswatchonly": false,
  "isscript": true,
  "iswitness": true,
  "ischange": false,
  "labels": [
  ]
}

# Sortie Segwit, type "anchor"
bitcoin-cli -regtest decodescript 51024e73
{
  "asm": "1 29518",
  "desc": "addr(bcrt1pfeesnyr2tx)#swxgse0y",
  "address": "bcrt1pfeesnyr2tx",
  "type": "anchor"
}

# Valeur satoshi minimale pour les sorties P2WPKH et P2A
bitcoin-cli -regtest createrawtransaction '[{"txid": "49ea7a01bcba744bd82ecea3e36c4ee9a994f010508a28a09df38f652e74643b", "vout": 0}]' '[{"bcrt1qqzv3ekkueheseddqge3mqdcukse6p9d5yuqxv3": "0.00000294"}, {"bcrt1pfeesnyr2tx": "0.00000240"}]'
02000000013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff02260100000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4f0000000000000000451024e7300000000

# Signer et envoyer la transaction avec sortie P2A
bitcoin-cli -regtest -rpcwallet=test signrawtransactionwithwallet 02000000013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff02260100000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4f0000000000000000451024e7300000000
{
  "hex": "020000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff02260100000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4f0000000000000000451024e7302473044022002c7e756b15135a3c0a061df893a857b42572fd816e41d3768511437baaeee4102200c51fcce1e5afd69a28c2d48a74fd5e58b280b7aa2f967460673f6959ab565e80121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000",
  "complete": true

# Désactivation de la vérification de frais de cohérence
bitcoin-cli -regtest -rpcwallet=test sendrawtransaction 020000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff02260100000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4f0000000000000000451024e7302473044022002c7e756b15135a3c0a061df893a857b42572fd816e41d3768511437baaeee4102200c51fcce1e5afd69a28c2d48a74fd5e58b280b7aa2f967460673f6959ab565e80121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000 "0"
fdee3b6a5354f31ce32242db10eb9ee66017e939ea87db0c39332262a41a424b

# Remplacement du paquet précédent
bitcoin-cli -regtest getrawmempool
[
  "fdee3b6a5354f31ce32242db10eb9ee66017e939ea87db0c39332262a41a424b"
]

# Pour l'enfant, brûler la valeur en frais, créer une tx de 65vbyte avec OP_RETURN pour éviter
l'erreur tx-size-small
bitcoin-cli -regtest createrawtransaction '[{"txid": "fdee3b6a5354f31ce32242db10eb9ee66017e939ea87db0c39332262a41a424b", "vout": 1}]' '[{"data": "feeeee"}]'
02000000014b421aa4622233390cdb87ea39e91760e69eeb10db4222e31cf354536a3beefd0100000000fdffffff010000000000000000056a03feeeee00000000

# Pas besoin de signature ; c’est un segwit sans témoin
bitcoin-cli -regtest -rpcwallet=test sendrawtransaction 02000000014b421aa4622233390cdb87ea39e91760e69eeb10db4222e31cf354536a3beefd0100000000fdffffff010000000000000000056a03feeeee00000000
8d092b61ef3c1a58c24915671b91fbc6a89962912264afabc071a4dbfd1a484e

```

## Histoires d'utilisateurs

Passant des descriptions de fonctionnalités de niveau notes de version plus générales, nous allons
décrire quelques modèles de portefeuilles courants et comment ils peuvent bénéficier de ces
mises à jour, avec ou sans modifications actives des portefeuilles.

### Paiements simples

Un problème que les utilisateurs rencontrent est qu'ils ne peuvent pas remplacer par frais (RBF)
avec confiance car les récepteurs de bitcoin pourraient créer des chaînes arbitraires de transactions
à partir du paiement, bloquant l'utilisateur. Si les utilisateurs souhaitent avoir un comportement RBF plus
prévisible, une manière serait d'opter pour les transactions TRUC. Les paiements entrants
pourraient également être augmentés de manière robuste via une dépense jusqu'à 1kvB de la sortie du
dépôt entrant.

Si adaptés, les portefeuilles devraient :

- définir la version à 3
- utiliser uniquement des sorties confirmées
- restez en dessous de 10kvB (par opposition à la limite non-TRUC de 100kvB) 
  - Cette limite restreinte prend toujours en charge les paiements par lots plus importants.
  - Si un portefeuille n'a pas d'autre choix que de dépenser une entrée non confirmée, l'entrée doit
    provenir d'une transaction TRUC, et cette nouvelle transaction doit être inférieure
    à 1kvB.

### Coinjoins

Dans le scénario [coinjoin][topic coinjoin] où la confidentialité est le focus mais que
le coinjoin ne tente pas d'être discret, les transactions TRUC pour le coinjoin
lui-même peuvent valoir la peine. Le coinjoin peut avoir un taux de frais insuffisant pour
l'inclusion dans la blockchain, nécessitant ainsi une augmentation des frais.

Avec les transactions TRUC, une sortie P2A pourrait être ajoutée permettant à un
portefeuille ségrégué comme une watchtower de payer seul les frais de transaction.

Si d'autres participants dépensent leurs sorties non confirmées, une éviction de la fratrie TRUC peut
se produire. L'éviction de la fratrie préserve les limites de topologie TRUC, mais permet à un CPFP à
taux de frais plus élevé d'être ajouté - un nouvel enfant est autorisé à "remplacer" le précédent
sans dépenser des entrées conflictuelles. Ainsi, tous les participants du coinjoin sont
toujours capables de CPFP la transaction.

Avertissement concernant l'épinglage : Les participants au coinjoin peuvent encore économiquement gêner la
transaction en dépensant en double leur propre entrée dans le coinjoin, nécessitant que le
coinjoin RBF la première transaction du fauteur de troubles.

### Réseau Lightning

Les transactions générées dans le protocole du Réseau Lightning consistent en quelques types
principaux :

1. Transactions de financement : Transactions financées par une seule partie ou par deux parties
pour mettre en place le contrat. Moins de sensibilité temporelle pour confirmer.
2. Transactions d'engagement : La transaction qui s'engage sur l'état le plus récent du
canal de paiement. Ces transactions sont asymétriques et nécessitent actuellement un message
“update_fee” bi-directionnel pour mettre à jour la part de la valeur de sortie de financement donnée
aux frais. Les frais doivent être suffisants pour propager la dernière version
de la transaction d'engagement dans les mempools des mineurs.
3. Transactions HTLC pré-signées

Avec le relais 1P1C et le package RBF, la mise à niveau des nœuds Bitcoin Core augmente
significativement
la sécurité du Réseau Lightning. Les fermetures unilatérales de Lightning peuvent
être réalisées avec des transactions d'engagement avec des taux de frais minimaux du mempool,
ou en conflit avec un autre package de transaction d'engagement à faible frais qui ne serait
pas promptement inclus dans un bloc.

Pour tirer le maximum d'avantage de cette mise à niveau, les portefeuilles et les backends devraient
s'intégrer avec la commande RPC **submitpackage** de Bitcoin Core :

```hack
bitcoin-cli submitpackage ‘[“<commitment_tx_hex>”, “<anchor_spend_hex>”]’
```

Les implémentations de portefeuille devraient intégrer leur logiciel avec la commande en utilisant
la transaction d'engagement ainsi qu'une dépense enfant ancre pour assurer l'inclusion
dans les mempools des mineurs avec le taux de frais approprié.

Note : Le point de terminaison RPC retournera un succès si vous soumettez un package à plusieurs
enfants,
à parent unique, mais ceux-ci ne se propageront pas sous la mise à jour du relais 1P1C.

Après qu'un nombre suffisant de nœuds se soit mis à niveau sur le réseau, le protocole LN pourrait
être mis à jour pour supprimer le message “update_fee”, qui a été une source de
fermetures forcées inutiles pendant les pics de frais depuis des années maintenant. Avec la
suppression de ce
message de protocole, les transactions d'engagement pourraient être fixées à un taux de frais
statique de 1 sat/vbyte. Avec les transactions TRUC, nous pouvons nous assurer que les transactions
d'engagement concurrentes avec des dépenses d'ancre sont autorisées à se RBF mutuellement sur le
réseau,
et si il y a des dépenses de sortie concurrentes de la même transaction d'engagement,
que le RBF peut se produire quel que soit le résultat dépensé. Les transactions TRUC peuvent
également être sans frais, permettant de réduire la complexité des spécifications. Avec l'éviction
de fratrie de TRUC, nous pouvons également supprimer les verrouillages CSV d'un bloc, puisque nous
ne sommes plus excessivement préoccupés par les sorties non confirmées dépensées, tant que chaque
partie peut dépenser une sortie elle-même.

Avec TRUC + Ancres P2A, nous pouvons réduire l'utilisation de l'espace de bloc de deux ancres
actuelles à une seule ancre sans clé. Cette ancre ne nécessite aucun engagement envers une clé
publique ou des signatures, économisant ainsi de l'espace de bloc supplémentaire. Le bumping des
frais peut également être externalisé à d'autres agents qui n'ont pas de matériel clé privilégié.
Les ancres pourraient également consister en une seule sortie avec du matériel clé partagé entre les
contreparties plutôt que P2A, au coût de vbytes supplémentaires dans le cas de fermeture unilatérale
bénigne.

Des stratégies similaires peuvent être poursuivies lors de l'implémentation de fonctionnalités
avancées telles que le splicing, pour réduire le risque de pinning RBF. Par exemple, un splice de
canal TRUC de moins de 1kvB pourrait CPFP la fermeture unilatérale d'un autre canal, sans exposer le
bumper aux pins RBF. Les bumps subséquents peuvent être effectués en série en remplaçant juste la
transaction de splice de canal. Cela vient au coût de révéler le type de transaction TRUC lors des
splices.

Comme vous pouvez le voir, une complexité significative peut être évitée et des économies réalisées
avec les fonctionnalités mises à jour, à condition que chaque transaction puisse s'insérer dans le
paradigme 1P1C.

### Ark

Tous les modèles de transaction ne s'insèrent pas dans le paradigme 1P1C. Un exemple parfait de cela
est les sorties [Ark][topic ark], qui s'engagent sur un arbre de transactions pré-signées (ou
engagées par covenant) pour dérouler un UTXO partagé.

Si un fournisseur de service Ark (ASP) se déconnecte ou traite une transaction, l'utilisateur peut
choisir de faire une sortie unilatérale, qui implique que l'utilisateur soumette une série de
transactions pour dérouler leur place de branche dans l'arbre de transaction. Cela nécessite des
transactions O(logn). Des difficultés peuvent survenir si d'autres clients tentent également de
quitter l'arbre, dépassant les limites de chaîne de mempool, ou créant des transactions
conflictuelles avec des frais insuffisants pour une inclusion rapide dans un bloc. Si une fenêtre de
temps particulièrement longue s'écoule sans inclusion, l'ASP est capable de récupérer tous les fonds
de manière unilatérale, résultant en une perte de fonds pour l'utilisateur.

Idéalement, la fermeture unilatérale initiale d'un arbre Ark serait :

1. La publication d'une branche de merkle entière à l'UTXO virtuel sous-jacent (vUTXO)
2. Chacune de ces transactions sont sans frais, pour éviter la prédiction des frais ou la nécessité
de décider à l'avance qui paie les frais
3. La transaction finale de la feuille a une dépense d'ancre à 0 valeur où le CPFP paie pour la
publication de l'arbre de merkle entier dans le mempool d'un mineur et son inclusion dans un bloc

Pour exécuter cet idéal correctement, il nous manque quelques éléments :

1. Relais de paquet général. Nous n'avons actuellement aucun moyen de propager ces chaînes de
transactions sans frais sur le réseau P2P de manière robuste.
2. Si trop de branches sont publiées à des taux de frais bas, cela peut entraîner l'incapacité des
utilisateurs à publier leur propre branche rapidement en raison du pinning de la limite du nombre de
descendants. Cela pourrait être désastreux à mesure que le nombre de contreparties devient grand,
comme c'est le cas dans le scénario idéalisé d'Ark.
3. Nous avons besoin d'une éviction de fratrie généralisée. Nous n'avons pas de support de sortie à
0 valeur pour les ancres sans valeur.
Au lieu de cela, essayons d'adapter la structure de transaction requise dans le paradigme 1P1C du
mieux que nous pouvons, au prix de quelques frais supplémentaires. Toutes les transactions de
l'arbre Ark, en commençant par la racine, sont une transaction TRUC et y ajoutent une valeur
minimale en satoshi de sortie P2A.

Lorsqu'un transacteur choisit de sortir unilatéralement d'un Ark, l'utilisateur publie la
transaction racine plus la dépense de P2A pour les frais, puis attend la confirmation. Une fois
confirmé, l'utilisateur soumet la transaction suivante dans sa branche de merkle, avec sa propre P2A
dépensée pour CPFP. Cela continue jusqu'à ce que toute la branche de merkle soit publiée et que les
fonds soient en toute sécurité extraits de l'arbre Ark. D'autres utilisateurs du même Ark peuvent
malicieusement ou accidentellement soumettre la même transaction de nœud interne avec un taux de
frais trop bas, mais l'éviction de fratrie garantirait qu'à chaque étape, les transactions enfant
honnêtes en dessous de 1kvB pourraient RBF les enfants concurrents sans nécessiter que tous les
autres sorties soient verrouillées, ou plusieurs ancres.

En supposant des arbres binaires, cela vient au coût asymptotique de près de 100% de surcharge vbyte
par rapport à l'Ark idéalisé pour le premier utilisateur, et d'environ 50% sur l'ensemble de l'arbre
s'il se déroule complètement. Pour les arbres 4-naires, cela diminue à ~25% sur l'ensemble de
l'arbre.

### LN Splices

D'autres topologies apparaissent également dans des constructions plus avancées du Lightning Network
qui peuvent nécessiter un peu de travail pour correspondre avec le relais 1P1C.

Les [splices][topic splicing] du Lightning Network sont une norme émergente et sont déjà utilisées
en général. Chaque splice dépense la sortie de financement originale, redéposant les fonds du
contrat dans une nouvelle sortie de financement, avec la même chaîne de transactions d'engagement
pré-signée qu'auparavant. Tant qu'elle n'est pas confirmée, l'état du canal original et le(s)
nouvel(s) état(s) du canal sont simultanément signés et suivis.

Un exemple qui pourrait dépasser le paradigme 1P1C est le cas où :

1. Alice et Bob financent un canal.
2. Alice fait un splice *out* de certains fonds vers une adresse on-chain contrôlée par Carol, qui
utilise un ensemble de clés froides, donc elle ne peut pas CPFP. Ce splice-out vise une confirmation
dans quelques heures.
3. Le nœud de Bob se déconnecte ou force la fermeture pour une raison quelconque.
4. Les taux de frais montent en flèche (peut-être qu'un token vient d'être lancé), retardant
indûment la confirmation de la transaction de splice-out.

Alice veut que le paiement on-chain à Carol se fasse, donc elle ne va pas en chaîne avec une
transaction d'engagement sans le splice. Cela signifie que splice_tx->commitment_tx->anchor_spend
devient le package requis pour faire propager cela.

Au lieu de cela, considérons comment l'adapter dans le paradigme 1P1C, sans gaspiller de vbytes
inutilement. Un portefeuille LN pourrait, au lieu d'exécuter un splice-out par paiement on-chain,
faire 2 splice-outs, puisqu'ils sont en conflit. Une version utilise le taux de frais relativement
conservateur choisi par l'estimateur de frais. L'autre version pourrait inclure une sortie P2A à 240
satoshis, ou 0 satoshis à l'avenir avec des [ancres éphémères][topic ephemeral anchors].

D'abord, diffusez le splice-out non ancré.

S'il n'y a pas d'événement de frais, il est confirmé et Alice peut continuer la fermeture forcée
comme d'habitude si désiré.

S'il y a un événement de frais causant au premier splice-out de prendre trop de temps, diffusez le
splice 1P1C *avec* ancre ainsi que la dépense d'ancre, en utilisant le RBF de package pour remplacer
le premier splice-out. Cette augmentation de frais permet la confirmation et le paiement à
Carol, puis continuez avec la fermeture forcée si souhaité.
Des copies supplémentaires des splice-outs pourraient également être émises à différents niveaux de
frais, mais notez
que chaque copie nécessiterait un ensemble supplémentaire de signatures pour la transaction
d'engagement ainsi que pour tous les HTLCs offerts en attente.

{% include references.md %}

[Gregory Sanders]: https://github.com/instagibbs
[bc 28.0]: https://github.com/bitcoin/bitcoin/releases/tag/v28.0
[bc 28.0 release notes]: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-28.0.md
[package relay tracking issue]: https://github.com/bitcoin/bitcoin/issues/27463
[policy series]: /fr/blog/waiting-for-confirmation/