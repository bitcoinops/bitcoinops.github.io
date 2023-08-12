Jusqu'à présent dans cette série, nous avons exploré les [motivations][policy01] et les défis associés à la transmission
décentralisée des transactions, ce qui conduit à un besoin [local][policy05] et [global][policy07] de règles de validation
des transactions plus restrictives que le consensus. Étant donné que les modifications de la politique de transmission des
transactions dans Bitcoin Core peuvent avoir un impact sur la transmission des transactions d'une application, elles nécessitent
une socialisation préalable avec la communauté Bitcoin plus large avant d'être prises en compte. De même, les applications
et les protocoles de deuxième couche qui utilisent la transmission des transactions doivent être conçus en tenant compte des
règles de politique afin d'éviter de créer des transactions qui seraient rejetées.

Les protocoles de contrat dépendent encore plus étroitement des politiques liées à la priorisation, car la possibilité de les
exécuter on chain dépend de la capacité à faire confirmer rapidement les transactions. Dans des environnements adverses,
les contreparties malveillantes peuvent avoir intérêt à retarder la confirmation d'une transaction, il faut donc également
réfléchir à la manière dont les particularités de l'interface de la politique de transmission des transactions peuvent être
utilisées contre un utilisateur.

Les transactions du Lightning Network respectent les règles de standardité mentionnées dans les publications précédentes. Par
exemple, le protocole pair-à-pair spécifie une `dust_limit_satoshis` dans son message `open_channel` pour spécifier un seuil
de poussière. Étant donné qu'une transaction contenant une sortie d'une valeur inférieure au seuil de poussière ne sera pas
transmise en raison des limites de poussière des nœuds, ces paiements sont considérés comme "non exécutoires sur la chaîne" et
sont supprimés des transactions d'engagement.

Les protocoles de contrat utilisent souvent des chemins de dépense avec verrouillage temporel pour donner à chaque participant
la possibilité de contester l'état publié on chain. Si l'utilisateur concerné ne parvient pas à faire confirmer une
transaction dans ce laps de temps, il peut subir une perte de fonds. Cela rend les frais extrêmement importants en tant que
mécanisme principal pour augmenter la priorité de confirmation, mais aussi plus difficiles à estimer. L'[estimation des frais][policy04] est
compliquée par le fait que les transactions seront diffusées à un moment ultérieur inconnu, que les nœuds fonctionnent souvent
en tant que clients légers et que certaines options d'augmentation des frais ne sont pas disponibles. Par exemple, si un
participant à un canal LN se déconnecte, l'autre partie peut diffuser unilatéralement une transaction d'engagement pré-signée
pour régler la répartition de leurs fonds partagés on chain. Aucune des parties ne peut dépenser unilatéralement l'UTXO
partagé, donc lorsque l'une des parties est déconnectée, il n'est pas possible de signer une transaction de [remplacement][topic rbf]
pour augmenter les frais de la transaction d'engagement. À la place, les transactions d'engagement LN peuvent inclure des
[sorties d'ancrage][topic anchor outputs] pour que les participants au canal puissent attacher un [enfant d'augmentation des
frais][topic cpfp] au moment de la diffusion.

Cependant, cette méthode d'augmentation des frais a également des limites. Comme mentionné dans un [message précédent][policy06],
l'ajout d'une transaction CPFP n'est pas efficace si les taux de frais minimum du mempool augmentent au-dessus du taux de frais
de la transaction d'engagement, il est donc nécessaire de les signer avec un taux de frais légèrement surestimé au cas où les
taux de frais minimum du mempool augmenteraient à l'avenir. De plus, le développement des sorties d'ancrage a pris en compte un
certain nombre de considérations liées au fait qu'une partie peut avoir intérêt à retarder la confirmation. Par exemple, une
partie (Alice) peut diffuser sa propre transaction d'engagement sur le réseau avant de se déconnecter. Si le taux de frais de
cette transaction d'engagement est trop faible pour une confirmation immédiate et si le cocontractant d'Alice (Bob) ne reçoit pas
sa transaction, il peut être confus lorsque ses diffusions de sa version de la transaction d'engagement ne sont pas transmises
avec succès. Chaque transaction d'engagement comporte deux sorties d'ancrage de sorte que chaque partie puisse utiliser CPFP sur
l'une des transactions d'engagement, par exemple, Bob peut essayer de diffuser aveuglément une augmentation des frais CPFP de la
version d'Alice de la transaction d'engagement même s'il n'est pas sûr qu'elle ait précédemment diffusé sa version. Chaque sortie
d'ancrage se voit attribuer une petite valeur supérieure au seuil de poussière et peut être réclamée par n'importe qui après un
certain temps pour éviter d'encombrer l'ensemble des UTXO.

Cependant, garantir la capacité de chaque partie à utiliser CPFP sur une transaction est plus compliqué que de donner à chaque
partie une sortie d'ancrage. Comme mentionné dans un [message précédent][policy05], Bitcoin Core limite le nombre et la taille
totale des transactions descendantes qui peuvent être attachées à une transaction non confirmée en tant que protection contre
les attaques de déni de service. Étant donné que chaque cocontractant a la possibilité d'attacher des transactions descendantes
à la transaction partagée, l'un pourrait bloquer la transaction CPFP de l'autre en épuisant ces limites. La présence de ces
transactions descendantes "épingle" par conséquent la transaction d'engagement à son statut de basse priorité dans les mempools.

Pour atténuer cette attaque potentielle, la proposition des sorties d'ancrage LN verrouille toutes les sorties sans ancrage avec
un verrouillage temporel relatif, les empêchant d'être dépensées tant que la transaction n'est pas confirmée, et la politique
de limite des transactions descendantes de Bitcoin Core a été [modifiée pour permettre une transaction descendante
supplémentaire][topic cpfp carve out] lorsque cette nouvelle transaction descendante était de petite taille et n'avait pas d'autres
ancêtres. Cette combinaison de modifications des deux protocoles garantit qu'au moins deux participants à une transaction partagée
peuvent ajuster les frais au moment de la diffusion, sans augmenter de manière significative la surface d'attaque de déni de
service de la transmission des transactions.

La prévention du CPFP par domination de la limite des transactions descendantes est un exemple d'une [attaque
d'épinglage][topic transaction pinning]. Les attaques d'épinglage exploitent les limitations de la politique des mempools pour
empêcher les transactions compatibles avec les incitations d'entrer dans les mempools ou d'être confirmées. Dans ce cas, la
politique des mempools a fait un compromis entre la [résistance aux attaques de déni de service][policy05] et la [compatibilité des
incitations][policy02]. Un compromis doit être fait---un nœud doit prendre en compte les augmentations de frais mais ne peut pas
traiter un nombre infini de transactions descendantes. Le découpage du CPFP permet d'affiner ce compromis pour un cas d'usage
spécifique.

Outre l'épuisement de la limite des transactions descendantes, il existe d'autres attaques d'épinglage qui [empêchent totalement
l'utilisation de RBF][full rbf pinning], rendent RBF [prohibitivement coûteux][rbf ml] ou utilisent RBF pour retarder la
confirmation d'une transaction ANYONECANPAY. L'épinglage n'est un problème que dans les scénarios où plusieurs parties collaborent
à la création d'une transaction ou lorsqu'il y a par ailleurs une possibilité pour une partie non fiable d'interagir avec la
transaction. Minimiser l'exposition d'une transaction à des parties non fiables est généralement un bon moyen d'éviter l'épinglage.

Ces points de friction mettent en évidence non seulement l'importance de la politique en tant qu'interface pour les applications
et les protocoles dans l'écosystème Bitcoin, mais aussi les domaines dans lesquels elle doit s'améliorer. Le prochain article de la
semaine prochaine abordera les propositions de politique et les questions ouvertes.

[full rbf pinning]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-May/003033.html
[rbf ml]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019817.html
[n25038 notes]: https://bitcoincore.reviews/25038
[policy01]: /fr/newsletters/2023/05/17/#en-attente-de-confirmation-1--pourquoi-avons-nous-un-mempool-
[policy02]: /fr/newsletters/2023/05/24/#en-attente-de-confirmation-2--mesures-dincitation
[policy04]: /fr/newsletters/2023/06/07/#en-attente-de-confirmation-4--estimation-du-taux-de-frais
[policy05]: /fr/newsletters/2023/06/14/#en-attente-de-confirmation-5--politique-de-protection-des-ressources-des-nœuds
[policy06]: /fr/newsletters/2023/06/21/#en-attente-de-confirmation-6--cohérence-des-politiques
[policy07]: /fr/newsletters/2023/06/28/#en-attente-de-confirmation-7--ressources-du-réseau
