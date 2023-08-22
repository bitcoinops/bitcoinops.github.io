{:.post-meta}
*par [Brandon Black][] de [BitGo][]*

Le premier [document MuSig][] a été publié en 2018, et le potentiel de [MuSig][topic musig] sur Bitcoin était l'un des arguments
de vente utilisé pour obtenir le soutien de la mise à jour logicielle taproot. Les travaux sur MuSig ont continué avec la
publication de [MuSig-DN][] et [MuSig2][] en 2020.
En 2021, alors que l'activation de taproot sur le réseau principal Bitcoin approchait, l'excitation de pouvoir apporter
la signature MuSig aux utilisateurs de Bitcoin était palpable. Chez BitGo, nous espérions lancer un portefeuille MuSig taproot
simultanément à l'activation de taproot ; mais la spécification, les vecteurs de test et la mise en œuvre de référence étaient
incomplets. À la place, BitGo a [lancé][bitgo blog taproot] le premier portefeuille multisig tapscript et a effectué la
[première transaction multisig tapscript][] sur le réseau principal. Près de deux ans plus tard, MuSig2 est spécifié dans
[BIP327][], et nous avons [lancé][bitgo blog musig2] le premier portefeuille multisig MuSig taproot.

{{include.extrah}}## Pourquoi MuSig2 ?

{{include.extrah}}### Comparé à Script Multisig

Il existe deux principaux avantages à MuSig par rapport à un script multisig. Le premier et le plus évident est une
réduction de la taille de la transaction et des frais de minage. Les signatures onchain font 64-73 octets, 16-18,25 octets
virtuels (vB), et MuSig peut combiner deux (ou plus) signatures en une seule. Dans le cas de 2-sur-3 de BitGo, une entrée
de clé MuSig coûte 57,5 vB, comparé à une entrée native SegWit à 104,5 vB ou à une profondeur 1 [tapscript][topic tapscript]
à 107,5 vB. Le deuxième avantage de MuSig est une amélioration de la confidentialité. Avec un chemin de clé MuSig sur une
sortie détenue de manière collaborative, une dépense coopérative ne peut pas être distinguée par un observateur tiers de
la blockchain d'une dépense taproot à signature unique.

Naturellement, il y a quelques inconvénients à MuSig2. Deux des plus importants tournent autour des
[nonces](#nonces-déterministes-et-aléatoires). Contrairement aux signataires pour ECDSA (algorithme de signature numérique à
courbes elliptiques) simple ou les [signautrees de schnorr][topic schnorr signatures], les signataires MuSig2 ne peuvent pas utiliser de manière cohérente des nonces déterministes. Cette incapacité rend plus difficile de garantir des nonces de haute qualité et de se prémunir contre leur réutilisation. MuSig2 nécessite deux tours de communication dans la plupart des cas.
Tout d'abord, l'échange de nonces, puis la signature. Dans certains cas, le premier tour peut être précalculé, mais cela doit
être entrepris avec prudence.

{{include.extrah}}### Comparé à d'autres protocoles MPC

Les protocoles de signature MPC (calcul multi-parties) gagnent en popularité en raison des avantages mentionnés précédemment
en termes de frais et de confidentialité. MuSig est un protocole de signature multi-signature (n-sur-n) _simple_, rendu possible
par la linéarité des signatures schnorr. MuSig2 peut être expliqué lors d'une présentation de 30 minutes, et la mise en œuvre
de référence complète ne compte que 461 lignes de code en Python. Les protocoles de [signature seuil][topic threshold signature]
(t-sur-n), tels que [FROST][], sont beaucoup plus complexes, et même les multi-signatures à deux parties basées sur ECDSA reposent
sur le chiffrement de Paillier et d'autres techniques.

{{include.extrah}}## Choix des scripts

Même avant [taproot][topic taproot], choisir un script spécifique pour un portefeuille multi-signature (t-sur-n) était difficile.
Taproot, avec ses multiples chemins de dépense, complique davantage la question, et MuSig ajoute encore plus d'options. Voici
quelques considérations qui ont été prises en compte dans la conception du portefeuille taproot MuSig2 de BitGo :

- Nous utilisons un ordre de clé fixe, pas un tri lexicographique. Chaque clé de signature a un rôle spécifique stocké avec
la clé, donc utiliser ces clés dans le même ordre à chaque fois est simple et prévisible.
- Notre chemin de clé MuSig ne comprend que le quorum de signature le plus courant, "utilisateur" / "bitgo". Inclure la clé
de signature "backup" dans le chemin de clé réduirait considérablement sa fréquence d'utilisation.
- Nous n'incluons pas la paire de signature "utilisateur", "bitgo" dans l'arbre de Taproot. Étant donné que c'est notre
deuxième type de script taproot et que le premier est une conception de script à trois tapscripts, les utilisateurs nécessitant
une signature de script peuvent utiliser le premier type.
- Pour les tapscripts, nous n'utilisons pas de clés MuSig. Nos portefeuilles incluent une clé "backup" qui est potentiellement
difficile d'accès ou signe avec un logiciel en dehors de notre contrôle, donc s'attendre à pouvoir signer MuSig pour la clé
"backup" n'est pas réaliste.
- Pour les tapscripts, nous choisissons les scripts `OP_CHECKSIG` / `OP_CHECKSIGVERIFY` plutôt que `OP_CHECKSIGADD`. Nous savons
quelles clés signeront lorsque nous construisons des transactions, et les scripts 2-sur-2 de profondeur 1 sont légèrement moins
chers que les scripts 2-sur-3 de profondeur 0.

La structure finale ressemble à ceci :

{:.center}
![Structure taproot MuSig de BitGo](/img/posts/bitgo-musig/musig-taproot-tree.png)

{{include.extrah}}## Nonces (déterministes et aléatoires)

Les signatures numériques sur courbe elliptique sont produites à l'aide d'une valeur secrète éphémère appelée nonce (nombre
utilisé une fois). En partageant le nonce public (le nonce public est au nonce secret ce que la clé publique est à la clé secrète)
dans la signature, les vérificateurs peuvent confirmer la validité de l'équation de signature sans révéler la clé secrète à
long terme. Pour protéger la clé secrète à long terme, un nonce ne doit jamais être réutilisé avec la même clé secrète (ou une
clé secrète liée) et le même message. Pour les signatures simples, la méthode la plus couramment recommandée pour se protéger
contre la réutilisation des nonces est la génération de nonces déterministes [RFC6979][]. Une valeur uniformément aléatoire peut
également être utilisée en toute sécurité si elle est immédiatement jetée après utilisation. Aucune de ces techniques ne peut
être appliquée directement aux protocoles multi-signatures.

Pour utiliser des nonces déterministes en toute sécurité dans MuSig, une technique comme MuSig-DN est nécessaire pour prouver
que tous les participants génèrent correctement leurs nonces déterministes. Sans cette preuve, un signataire malveillant peut
initier deux sessions de signature pour le même message mais fournir des nonces différents. Un autre signataire qui génère
son nonce de manière déterministe générera deux signatures partielles pour le même nonce avec des messages effectifs différents,
révélant ainsi sa clé secrète au signataire malveillant.

Lors du développement de la spécification MuSig2, [Dawid][] et moi avons réalisé que le dernier signataire à contribuer à un
nonce pouvait générer son nonce de manière déterministe. J'ai discuté de cela avec [Jonas Nick][], qui l'a formalisé dans la
spécification. Pour l'implémentation MuSig2 de BitGo, ce mode de signature déterministe est utilisé avec nos HSM (modules de
sécurité matérielle) pour leur permettre d'exécuter la signature MuSig2 sans état.
Lors de l'utilisation de nonces aléatoires avec des protocoles de signature à plusieurs tours, les signataires doivent prendre
en compte la manière dont les nonces secrets sont stockés entre les tours. Dans les signatures simples, le nonce secret peut
être supprimé lors de la même exécution où il est créé. Si un attaquant pouvait cloner un signataire immédiatement après la
création du nonce mais avant de fournir les nonces des autres signataires, le signataire pourrait être trompé pour produire
plusieurs signatures pour le même nonce mais avec des messages effectifs différents. Pour cette raison, il est recommandé aux
signataires de réfléchir attentivement à la manière dont leurs états internes peuvent être accessibles et à quel moment précis
les nonces secrets sont supprimés. Lorsque les utilisateurs de BitGo signent avec MuSig2 en utilisant le SDK BitGo, les nonces
secrets sont conservés dans la bibliothèque [MuSig-JS][] où ils sont supprimés lors de l'accès pour la signature.

{{include.extrah}}## Le processus de spécification

Notre expérience de mise en œuvre de MuSig2 chez BitGo montre que les entreprises et les individus travaillant dans l'espace
Bitcoin devraient prendre le temps de revoir et de contribuer au développement des spécifications qu'ils ont l'intention de
mettre en œuvre (ou même espèrent mettre en œuvre). Lorsque nous avons examiné pour la première fois la spécification MuSig2
et avons commencé à étudier la meilleure façon de l'intégrer dans nos systèmes de signature, nous avons envisagé diverses
méthodes difficiles pour introduire une signature avec état sur nos HSM.

Heureusement, lorsque j'ai exposé les défis à Dawid, il était confiant qu'il existait un moyen d'utiliser un nonce déterministe,
et nous avons finalement opté pour l'idée approximative qu'un signataire pouvait être déterministe. Lorsque j'ai ensuite soulevé
cette idée à Jonas et expliqué le cas d'utilisation spécifique que nous essayions de permettre, il a reconnu la valeur et l'a
formalisée dans la spécification.

Maintenant, d'autres implémenteurs de MuSig2 peuvent également profiter de la flexibilité offerte en permettant à l'un de leurs
signataires de ne pas gérer l'état. En examinant (et en mettant en œuvre) la spécification provisoire pendant son développement,
nous avons pu contribuer à la spécification et être prêts à lancer la signature MuSig2 peu de temps après que la spécification
ait été officiellement publiée en tant que BIP327.

{{include.extrah}}## MuSig et PSBT

Le format [PSBT (Partially Signed Bitcoin Transaction)][topic psbt] est destiné à transporter toutes les informations nécessaires
pour signer une transaction entre les parties (par exemple, le coordinateur et les signataires dans un cas simple). Plus
d'informations sont nécessaires pour la signature, plus le format devient précieux. Nous avons examiné les coûts et les avantages
de l'expansion de notre format d'API existant avec des champs supplémentaires pour faciliter la signature MuSig2 par rapport à la
conversion en PSBT. Nous avons opté pour la conversion au format PSBT pour l'interchangeabilité des données de transaction, et
cela a été un énorme succès. Ce n'est pas encore largement connu, mais les portefeuilles BitGo (sauf ceux utilisant MuSig2, voir
le paragraphe suivant) peuvent désormais s'intégrer aux dispositifs de signature matérielle prenant en charge les PSBT.

Il n'existe pas encore de champs PSBT publiés pour une utilisation dans la signature MuSig2. Pour notre implémentation, nous avons
utilisé des champs propriétaires basés sur un brouillon partagé avec nous par [Sanket][]. C'est l'un des avantages peu discutés
du format PSBT---la possibilité d'inclure _n'importe_ quelle donnée supplémentaire pouvant être nécessaire pour votre construction
de transaction personnalisée ou votre protocole de signature dans le même format de données binaires, avec des sections globales,
par entrée et par sortie déjà définies. La spécification PSBT sépare la transaction non signée des scripts, des signatures et des
autres données nécessaires pour former finalement une transaction complète. Cette séparation peut permettre une communication plus
efficace pendant le processus de signature. Par exemple, notre HSM peut répondre avec un PSBT minimal comprenant uniquement ses
nonces ou signatures, et ils peuvent être facilement combinés dans le PSBT de pré-signature.

{{include.extrah}}## Remerciements

Merci à Jonas Nick et Sanket Kanjalkar chez Blockstream ; Dawid Ciężarkiewicz chez Fedi ; et [Saravanan Mani][], David Kaplan,
et le reste de l'équipe chez BitGo.

{% include references.md %}
[Brandon Black]: https://twitter.com/reardencode
[BitGo]: https://www.bitgo.com/
[document MuSig]: https://eprint.iacr.org/2018/068
[MuSig-DN]: https://eprint.iacr.org/2020/1057
[MuSig2]: https://eprint.iacr.org/2020/1261
[bitgo blog taproot]: https://blog.bitgo.com/taproot-support-for-bitgo-wallets-9ed97f412460
[première transaction multisig tapscript]: https://mempool.space/tx/905ecdf95a84804b192f4dc221cfed4d77959b81ed66013a7e41a6e61e7ed530
[bitgo blog musig2]: https://blog.bitgo.com/save-fees-with-musig2-at-bitgo-3248d690f573
[FROST]: https://datatracker.ietf.org/doc/draft-irtf-cfrg-frost/
[2-party multi-signatures]: https://duo.com/labs/tech-notes/2p-ecdsa-explained
[RFC6979]: https://datatracker.ietf.org/doc/html/rfc6979
[Dawid]: https://twitter.com/dpc_pw
[Jonas Nick]: https://twitter.com/n1ckler
[MuSig-JS]: https://github.com/brandonblack/musig-js
[Sanket]: https://twitter.com/sanket1729
[Saravanan Mani]: https://twitter.com/saravananmani_