{% comment %}<!--
Copyright 2018 Anthony Towns
-->{% endcomment %}

Comme indiqué dans le [bulletin #3][newsletter 3], les faibles frais de
transaction de ces derniers mois offrent une excellente occasion de consolider
les UTXO ! La consolidation fait partie des différentes mesures prises par
[Xapo][] pour se préparer à une nouvelle flambée des frais, comme celle des
derniers mois de 2017.

{% assign img1_label = "Évolution du nombre total d'UTXO Bitcoin, de janvier à juillet 2018" %}

{:.center}
![{{img1_label}}](/img/posts/utxo-consolidation-2018.png)<br>
*{{img1_label}},
source : [Statoshi](https://statoshi.info/dashboard/db/unspent-transaction-output-set?panelId=6&fullscreen&from=1514759562608&to=1532039707168)*

[newsletter 3]: /fr/newsletters/2018/07/10/#éléments-du-tableau-de-bord
[Xapo]: https://www.xapo.com/

Le principe de la consolidation des UTXO est le suivant : lorsque le montant
moyen de vos paiements sortants dépasse celui de vos paiements entrants (ou
qu'ils sont égaux, mais que vous regroupez vos paiements sortants), vous devez
souvent combiner de nombreux UTXO pour financer un paiement. Cela augmente la
taille de vos transactions et donc les frais que vous payez. En consolidant vos
UTXO à l'avance, vous pouvez regrouper les entrées en amont et mieux choisir le
moment où vous engagez la majeure partie de ces frais. Si vous le faites lorsque
les frais sont bas, vous pouvez les réduire considérablement.

Par exemple, dépenser une douzaine d'entrées multisig 2-sur-3 à 100 s/B
(satoshis par octet) coûterait environ 360 000 satoshis. Si vous consolidez
d'abord ces entrées à 2 s/B, puis dépensez l'unique entrée ainsi obtenue à
100 s/B, les frais cumulés des deux transactions ne sont que d'environ
41 000 satoshis, soit 87 % de moins. Et si les frais n'augmentent pas, le risque
reste limité : s'ils restent à 2 s/B, vous dépenserez 7 900 satoshis pour les
deux transactions avec consolidation, contre 7 200 satoshis pour une seule
transaction sans consolidation.

La consolidation permet aussi de changer les adresses utilisées pour vos UTXO,
par exemple pour renouveler les clés, passer au multisig ou adopter des adresses
segwit ou bech32. Réduire le nombre d'UTXO facilite également l'exploitation
d'un nœud complet, ce qui améliore légèrement la décentralisation et la sécurité
globale de Bitcoin, un avantage toujours appréciable.

Bien entendu, il faut éviter que vos transactions de consolidation remplissent
la chaîne de blocs et provoquent immédiatement une hausse des frais ! Deux
indicateurs permettent de surveiller ce risque : le remplissage du
[mempool][mempool], qui fait augmenter le taux de frais minimum accepté, et
l'espace inutilisé dans les blocs récents, qui indique si les mineurs
accepteront davantage de transactions au taux de frais minimum. Ces deux
indicateurs ont été très favorables la plupart du temps au cours des derniers
mois : le mempool a régulièrement été presque vide, ce qui a permis aux
transactions payant seulement 1 s/B de parvenir aux mineurs ; et de nombreux
blocs n'étaient pas pleins, de sorte que les transactions de consolidation peu
coûteuses étaient confirmées assez rapidement, sans créer un arriéré susceptible
de faire monter les frais.

[mempool]: https://statoshi.info/dashboard/db/memory-pool?panelId=1&fullscreen&from=1509458400000&to=1531813659334&theme=dark

Pour réaliser la consolidation, nous avons utilisé un script qui sélectionnait
des groupes de petits UTXO et créait une transaction les dépensant vers une
adresse commune, à un taux de frais de 1,01 satoshi par octet. Le script
injectait progressivement les transactions de consolidation dans le réseau afin
de ne pas provoquer une hausse trop forte du mempool et, surtout, de limiter
le risque que nos transactions soient évincées parce que leurs frais étaient
bas et que le mempool s'était rempli. Nous le déclenchions manuellement lorsque
nous estimions que cela ne perturberait pas nos activités et que le réseau
Bitcoin semblait globalement peu chargé.

Dans l'ensemble, cette approche a plutôt bien fonctionné : nous avons réduit
notre nombre d'UTXO d'environ [4 millions][4 million UTXOs] cette année. Hormis
quelques [utilisateurs de Reddit][redditors2] [inquiets][redditors1], le coût
pour l'ensemble du réseau a été minime, tout comme le coût pour nous.

[4 million UTXOs]: https://www.oxt.me/entity/Xapo
[redditors1]: https://www.reddit.com/r/BitcoinDiscussion/comments/8ocyc9/massive_consolidation_currently_underway/
[redditors2]: https://www.reddit.com/r/Bitcoin/comments/8p3y5b/does_xapo_spamming_the_blockchain/

<span id="additional-resources"></span>

{{include.hlevel | default: '##'}} Ressources complémentaires

- [Techniques de réduction des frais de transaction : consolidation](https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#Consolidation) - Bitcoin Wiki
- [Comment consolider des UTXO à moindre coût pour réduire les frais de minage](https://en.bitcoin.it/wiki/How_to_cheaply_consolidate_coins_to_reduce_miner_fees) - Bitcoin Wiki
- [Quelles sont les bonnes pratiques pour les consolidations et les répartitions de fonds ?](https://bitgo.freshdesk.com/support/solutions/articles/27000044185-what-are-some-best-practices-regarding-the-usage-of-consolidations-and-fanouts-) - BitGo
