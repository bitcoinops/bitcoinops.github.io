---
title: 'Bitcoin Optech Newsletter #74'
permalink: /es/newsletters/2019/11/27/
name: 2019-11-27-newsletter-es
slug: 2019-11-27-newsletter-es
type: newsletter
layout: newsletter
lang: es
---
El newsletter de esta semana anuncia una nueva versión principal de Bitcoin
Core, proporciona algunas actualizaciones en las listas de correo de
desarrolladores de Bitcoin y LN y describe los desarrollos recientes en la
revisión continua de schnorr/taproot. También están incluidas nuestras
secciones habituales con las preguntas y respuestas más votadas de Bitcoin
Stack Exchange y cambios notables en proyectos populares de infraestructura de
Bitcoin.

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Acciones a seguir

- **Actualización a Bitcoin Core 0.19.0.1:** se recomienda que los usuarios
  actualicen a la última [versión][bitcoin core 0.19.0.1], que contiene nuevas
  funciones y múltiples correcciones de bugs. Esta es la primera versión de
  lanzamiento de la serie 0.19 después de que se encontró y solucionó un
  [bug][Bitcoin Core #17449] que afectaba a la versión etiquetada 0.19.0.

## Noticias
{% comment %}<script>
// commit count: git shortlog -no-merges -s v0.18.1..v0.19.0 | awk '{print $1}' | numsum
// contributor count: wc -l on list in release notes
</script>{% endcomment %}

- **Lanzamiento de Bitcoin Core 0.19:** con más de 1,000 confirmaciones de más
  de 100 contribuyentes, la [última versión de Bitcoin Core][bitcoin core
  0.19.0.1] ofrece varias características nuevas visibles para el usuario,
  numerosas correcciones de bugs y múltiples mejoras en los sistemas internos,
  como el manejo de la red P2P.  Algunos cambios que pueden ser especialmente
  interesantes para los lectores incluyen:

    - _Exclusión de CPFP_: esta [nueva política de mempool][topic cpfp carve
      out] ayuda a los protocolos de contrato de dos partes (como el LN actual)
      a garantizar que ambas partes puedan usar el aumento de tarifas de
      Child-Pays-For-Parent (CPFP) (ver [Newsletter #63][news63 carve-out]).  Los
      desarrolladores de LN ya tienen una propuesta bajo discusión sobre cómo usarán
      esta función para simplificar la administración de tarifas para las
      transacciones de compromiso (consulte los newsletters [#70][news70 simple
      commits] y [#71][news71 ln carve-out]).

    - _Filtros de bloque BIP158 (solo RPC)_: los usuarios ahora pueden
      establecer una nueva opción de configuración, `blockfilterindex`, si
      quieren que Bitcoin Core genere [filtros de bloque compactos][topic compact
      block filters] según lo especificado por [BIP158][]. El filtro para cada bloque
      se puede recuperar utilizando el nuevo `getblockfilter` RPC. Filtros pueden ser
      proporcionados a un lightweight client compatible para permitirle determinar si
      un bloque puede contener transacciones que involucren sus claves (consulta la
      [Newsletter #43][news43 core bip158] para obtener más información).
      [PR#16442][Bitcoin Core #16442] está actualmente abierto para agregar soporte
      para el protocolo [BIP157][] correspondiente que permitirá compartir estos
      filtros con clientes a través de la red P2P.

    - _Funciones obsoletas o eliminadas_: el soporte para el protocolo de pago
      [BIP70][], los filtros de bloom del protocolo [BIP37][] P2P y los
      mensajes de rechazo del protocolo [BIP61][] P2P se han deshabilitado por
      default, eliminando la fuente de varios problemas (respectivamente, consulta
      los newsletters [#19][news19 bip70], [#57][news57 bip37] y [#37][news37 bip61])
      El protocolo de pago y los mensajes de rechazo están programados para
      eliminarse por completo en la próxima versión principal de Bitcoin Core dentro
      de seis meses a partir de ahora.

    - _Permisos personalizables para los whitelisted peers_: al especificar
      qué peers o interfaces deben incluirse en la lista blanca (whitelisted),
      los usuarios ahora pueden especificar a qué características especiales pueden
      acceder los whitelisted peers. Anteriormente, los whitelisted peers no estaban
      baneados y recibían transacciones retransmitidas más rápido. Estos valores
      predeterminados no han cambiado, pero ahora es posible alternar esa
      configuración por pares o permitir a whitelisted peers específicos que
      soliciten filtros de bloom BIP37 aunque están deshabilitados para peers no
      incluidos en la lista blanca de forma predeterminada. Para más detalles, ve la
      [Newsletter #60][news60 16248].

    - _Mejoras de la GUI_: los usuarios gráficos ahora pueden crear nuevas
      billeteras para usar con el modo de múltiples billeteras desde el menú de
      archivo de la GUI (ver la [Newsletter #63][news63 new wallet]). La GUI ahora
      también proporciona a los usuarios direcciones Bitcoin [bech32][topic bech32]
      de forma predeterminada, pero los usuarios pueden solicitar fácilmente una
      dirección P2SH-P2WPKH compatible con versiones anteriores al seleccionar una
      casilla de verificación al lado del botón para generar una dirección (ver la
      [Newsletter #42][news42 core gui bech32]).

    - _Administración opcional para preservar privacidad de direcciones:_ se
      puede habilitar un nuevo indicador de billetera `avoid_reuse`, que se
      puede seleccionar usando un nuevo RPC `setwalletflag`, para evitar que la
      billetera gaste bitcoins recibidos en una dirección que se usó anteriormente
      (ver la [Newsletter #52][news52 avoid_reuse]). Esto evita ciertas fugas de
      privacidad basadas en el análisis de la cadena de bloques, como [dust
      flooding][].

    Para obtener una lista completa de los cambios notables, enlaces a los PRs
    donde se realizaron esos cambios e información adicional útil para los
    operadores de nodos, consulta las [notas de lanzamiento][notes 0.19.0] del
    proyecto Bitcoin Core.

- **Nueva lista de correo de LND y nuevo host de listas de correo existentes:**
  se anunció una [nueva lista de correo][lnd engineering] alojada por Google
  Groups para desarrolladores de aplicaciones de LND, con una [publicación
  inicial][osuntokun lnd plans] de Olaoluwa Osuntokun describiendo los objetivos
  a corto plazo para el próximo lanzamiento de LND. Por separado, las listas de
  correo existentes para [Bitcoin-Dev][] y [Lightning-Dev][] han
  [transferido][togami ml update] recientemente su alojamiento al [Laboratorio de
  Código Abierto][osl] (OSL) de la Universidad Estatal de Oregón, una
  organización muy respetada que ofrece alojamiento para una gran variedad de
  proyectos de código abierto. Optech extiende nuestro agradecimiento a Warren
  Togami, Bryan Bishop y a todos los demás involucrados en el mantenimiento de
  todos los canales de comunicación abiertos de Bitcoin, sin los cuales este
  boletín no existiría.

- **Actualizaciones de Schnorr/Taproot:** los participantes en el [grupo de
  revisión de taproot][taproot review group] han continuado su revisión de los
  cambios en el soft fork propuestos a Bitcoin, con muchas preguntas interesantes
  hechas y respondidas en la sala de chat ##taproot-bip-review IRC
  [registrada][tbr log] en la red Freenode.  Además, algunos participantes han
  estado escribiendo sus propias implementaciones de partes de los BIPs,
  incluyendo los nodos de verificación completa libbitcoin y bcoin.

    Esta semana también se publicaron dos publicaciones informativas en el blog
    relacionadas con la seguridad de las firmas schnorr multiparte. El ingeniero de
    Blockstream Jonas Nick [describe][nick musig] el esquema de firma multiparte
    [MuSig][] que está diseñado para permitir que los usuarios de [bip-schnorr][]
    agreguen múltiples llaves públicas en una sola llave pública. Luego pueden
    firmar esa llave para usar una firma única generada en colaboración entre
    ellos. Nick describe los tres pasos del protocolo de firma MuSig: el
    intercambio de compromisos nonce, el intercambio de nonces y el intercambio de
    firmas parciales (con el nonces y las firmas parciales que se agregan para
    producir la firma final). Para ahorrar tiempo cuando la velocidad es crítica
    (como al crear transacciones de compromiso de canal LN), algunas personas
    pueden desear intercambiar compromisos nonce seguidas de nonces antes de saber
    a qué transacción quieren comprometerse con su firma, pero esto no es seguro
    debido al algoritmo de Wagner, como Nick explica brevemente. La única
    información que se puede compartir de manera segura antes de que cada
    participante conozca la transacción a firmar es el compromiso nonce. (No
    mencionado en la publicación del blog, pero discutido en IRC, fue que Pieter
    Wuille entre otros ha estado investigando una construcción basada en Zero
    Knowledge Proof (ZKP) que podría permitir una interactividad reducida). La
    publicación del blog concluye con una sugerencia de que los lectores
    interesados revisen la implementación de MuSig en
    [libsecp256k1-zkp][], que está diseñada para ayudar a los desarrolladores a
    usar el protocolo de manera segura.

    Influenciado por la presentación de Jonas Nick sobre este tema en la Berlin
    Lightning Conference, Adam Gibson escribió una [publicación de blog][gibson
    wagners] separada que describe el algoritmo de Wagner con mucho más detalle,
    con una combinación de matemáticas, análisis intuitivo e información de
    actualidad que los Bitcoiners pueden encontrar interesante (como el divertido
    fragmento del [artículo de Wagner][Wagner's paper] citando a Adam Back y Wei
    Dai varios años antes de que Nakamoto hiciera [lo mismo][bitcoin.pdf], aunque
    para un trabajo diferente).  Se recomienda a cualquier persona interesada en
    desarrollar sus propios protocolos criptográficos que lea ambas publicaciones,
    ya que cada una complementa a la otra sin ser repetitiva sobre el tema.

## Preguntas y respuestas seleccionadas de Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] es uno de los primeros lugares donde los
contribuyentes de Optech buscan respuestas a sus preguntas, o, cuando tenemos
algunos momentos libres, para ayudar a usuarios curiosos o confundidos. Aquí
destacamos algunas de las preguntas y respuestas más votadas, publicadas desde
nuestra última actualización.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{%
endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [¿Tendría una pubkey schnorr una longitud diferente que una pubkey taproot como P2WPKH y P2WSH?]({{bse}}91531)
  Murch explica que, a diferencia de segwit v0, que tiene diferentes tipos y
  longitudes de salida P2WPKH y P2WSH, todas las salidas segwit v1 Pay-to-Taproot
  (P2TR) son siempre de la misma longitud.

- Justinmoon de [MuSig Signature Interactivity]({{bse}}91534) pregunta por qué
  la firma [MuSig][] es siempre interactiva y sobre firmas interactivas seguras
  y fuera de línea. Nickler explica cada una de las rondas relacionadas con la
  firma de MuSig, así como algunas trampas que deben evitarse durante la firma.

- [¿Cómo funciona la debilidad de la mutación de extensión de longitud bech32?]({{bse}}91602)
  Jnewbery pide detalles sobre por qué agregar o eliminar caracteres _q_
  inmediatamente antes del caracter _p_ final de una dirección a veces puede
  producir una nueva dirección bech32 que es válida.  Pieter Wuille proporciona
  algunos detalles algebraicos sobre por qué es más probable que ocurra el
  problema que la probabilidad de aproximadamente 1 en mil millones de que
  cualquier error aleatorio de cambio de longitud no se detecte.  MCCCS
  proporciona una segunda explicación utilizando parte del código aplicable de
  Bitcoin Core.

- [¿Cuál es la diferencia entre el lenguaje de políticas de Bitcoin y Miniscript?]({{bse}}91565)
  Pieter Wuille, James C. y sanket1729 explican la relación entre Bitcoin
  Script, la política de lenguaje (una herramienta para que humanos diseñen las
  condiciones de gasto) y miniscript (una representación más estructurada de
  Bitcoin Script para la comunicación y el análisis).

## Cambios notables de código y documentación

*Cambios notables esta semana en [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals (BIPs)][bips
repo] y [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #17265][] and [#17515][Bitcoin Core #17515] completan la
  eliminación de la dependencia de OpenSSL, que se ha utilizado desde la
  versión original de Bitcoin 0.1, pero que también fue la causa de
  [vulnerabilidades de consenso][non-strict der], [fugas de memoria
  remota][heartbleed] (posibles fugas de llave privada), [otros
  bugs][cve-2014-3570] y [bajo rendimiento][libsecp256k1 sig speedup].

- [Bitcoin Core #16944][] actualiza la GUI para generar una transacción de
  Bitcoin parcialmente firmada [BIP174][] (PSBT) y la copia automáticamente en
  el portapapeles si el usuario intenta crear una transacción en una billetera de
  watch-only que tiene sus llaves privadas deshabilitadas. El PSBT se puede
  copiar en otra aplicación para firmar (por ejemplo, [HWI][topic hwi]). La GUI
  aún no proporciona un diálogo especial para copiar el PSBT firmado nuevamente
  para su transmisión.

- [Bitcoin Core #17290][] cambia qué algoritmo de selección de monedas se usa
  en los casos en que el usuario solicita que se usen ciertas entradas o
  solicita que se seleccione la tarifa de los montos de pago. Estos ahora usan el
  algoritmo predeterminado normal de Bitcoin Core de Branch and Bound (BnB). BnB
  fue diseñado para minimizar las tarifas y maximizar la privacidad mediante la
  optimización para la creación de transacciones sin cambios.

- [C-Lightning #3264][] incluye varias mitigaciones para [LND #3728][], un bug
  en la implementación de consultas de chismes. Este cambio también agrega dos
  nuevos parámetros de línea de comando útiles para probar y depurar, `--hex` y
  `--features`.

- [C-Lightning #3274][] hace que `lightningd` se niegue a iniciarse si detecta
  que `bitcoind` está ahora en una altura de bloque más baja que la última vez
  que se ejecutó `lightningd`.  Si se ve una altura más baja mientras se está
  ejecutando `lightningd`, simplemente esperará hasta que se vea una altura más
  alta. Las alturas de bloque pueden disminuir durante una reorganización de la
  cadena de bloques, durante una reindexación de la cadena de bloques o si el
  usuario ejecuta ciertos comandos destinados para pruebas de desarrollador. Para
  `lightningd` es más fácil y seguro esperar a que `bitcoind` resuelva esas
  situaciones que tratar de solucionar los problemas. Sin embargo, si el usuario
  de LN realmente quiere usar la cadena truncada, puede iniciar `lightningd` con el
  parámetro `--rescan` para reprocesar la cadena de bloques.

- [Eclair #1221][] agrega una API `networkstats` que devuelve información diversa
  sobre la red LN según lo observado desde el nodo local, que incluye la
  cantidad de canales conocidos, la cantidad de nodos LN conocidos, la capacidad
  de los nodos LN (agrupados en percentiles) y las tarifas que los nodos se están
  cargando (también agrupados en percentiles).

- [LND #3739][] permite especificar qué nodo debe ser el último salto en una
  ruta antes de que se entregue un pago al receptor. Junto con otros trabajos
  aún pendientes, como [LND #3736][], esto permitirá que un usuario reequilibre
  sus canales utilizando las funciones integradas de LND (en lugar de requerir
  herramientas externas, como es el caso actualmente).

- [LND #3729][] hace posible generar facturas con precisión millisatoshi.
  Anteriormente, LND no generaba facturas con precisión sub-satoshi.

- [LND #3499][] extiende varios RPC, como `listpayments` y `trackpayment` para
  proporcionar información sobre [pagos de múltiples rutas][topic multipath
  payments], pagos que pueden tener múltiples partes que se envían a través de
  diferentes rutas. Todavía no son totalmente compatibles con LND, pero este PR
  combinado hace que sea más fácil agregar soporte más adelante. Además, los
  pagos enviados previamente que tienen solo una parte se convierten en la misma
  estructura utilizada para la ruta múltiple, pero se muestran como si tuviesen
  una sola parte.

{% include linkers/issues.md issues="17449,3499,3729,3739,1221,16442,17265,17515,16944,3264,3728,3274,17290,3736" %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}
[bitcoin core 0.19.0.1]: https://bitcoincore.org/bin/bitcoin-core-0.19.0.1/
[notes 0.19.0]: https://bitcoincore.org/en/releases/0.19.0.1/
[news63 carve-out]: /en/newsletters/2019/09/11/#bitcoin-core-16421
[news70 simple commits]: /en/newsletters/2019/10/30/#ln-simplified-commitments
[news71 ln carve-out]: /en/newsletters/2019/11/06/#continued-discussion-of-ln-anchor-outputs
[news43 core bip158]: /en/newsletters/2019/04/23/#basic-bip158-support-merged-in-bitcoin-core
[news19 bip70]: /en/newsletters/2018/10/30/#bitcoin-core-14451
[news57 bip37]: /en/newsletters/2019/07/31/#bloom-filter-discussion
[news37 bip61]: /en/newsletters/2019/03/12/#removal-of-bip61-p2p-reject-messages
[news63 new wallet]: /en/newsletters/2019/09/11/#bitcoin-core-15450
[news42 core gui bech32]: /en/newsletters/2019/04/16/#bitcoin-core-15711
[news52 avoid_reuse]: /en/newsletters/2019/06/26/#bitcoin-core-13756
[dust flooding]: {{bse}}81509
[news60 16248]: /en/newsletters/2019/08/21/#bitcoin-core-16248
[togami ml update]: http://www.erisian.com.au/bitcoin-core-dev/log-2019-11-21.html#l-23
[nick musig]: https://medium.com/blockstream/insecure-shortcuts-in-musig-2ad0d38a97da
[gibson wagners]: https://joinmarket.me/blog/blog/avoiding-wagnerian-tragedies/
[news55 tlv]: /en/newsletters/2019/07/17/#bolts-607
[lnd engineering]: https://groups.google.com/a/lightning.engineering/forum/#!forum/lnd
[osuntokun lnd plans]: https://groups.google.com/a/lightning.engineering/forum/#!topic/lnd/GtcrXNhTLqQ
[bitcoin-dev]: https://lists.linuxfoundation.org/mailman/listinfo/bitcoin-dev
[lightning-dev]: https://lists.linuxfoundation.org/mailman/listinfo/lightning-dev
[osl]: https://osuosl.org/
[taproot review group]: https://github.com/ajtowns/taproot-review
[tbr log]: http://www.erisian.com.au/taproot-bip-review/
[libsecp256k1-zkp]: https://github.com/ElementsProject/secp256k1-zkp
[wagner's paper]: https://people.eecs.berkeley.edu/~daw/papers/genbday-long.ps
[non-strict der]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2015-July/009697.html
[heartbleed]: https://bitcoin.org/en/alert/2014-04-11-heartbleed
[cve-2014-3570]: https://www.reddit.com/r/Bitcoin/comments/2rrxq7/on_why_010s_release_notes_say_we_have_reason_to/
[libsecp256k1 sig speedup]: https://bitcoincore.org/en/2016/02/23/release-0.12.0/#x-faster-signature-validation
