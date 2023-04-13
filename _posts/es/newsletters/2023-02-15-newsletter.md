---
title: 'Boletín Bitcoin Optech #238'
permalink: /es/newsletters/2023/02/15/
name: 2023-02-15-newsletter-es
slug: 2023-02-15-newsletter-es
type: newsletter
layout: newsletter
lang: es
---
El boletín de esta semana resume la continuacion de la discusión sobre el almacenamiento de datos en la cadena de bloques de Bitcoin, describe un hipotético ataque de dilución de fees contra algunos tipos de protocolos multiparte, y describe cómo un compromiso de firma tapscript puede ser usado con diferentes partes del mismo árbol. También se incluyen nuestras secciones habituales con resúmenes de cambios en servicios y en el software del cliente, anuncios de nuevas versiones y de las versiones candidatas, y descripciones de cambios destacados en el popular software de infraestructura de Bitcoin. Adicionalmente proporcionamos una de nuestras inusuales recomendaciones para un nuevo motor de búsqueda enfocado en documentación técnica y discusión sobre Bitcoin.

## News

- **Continúa el debate sobre el almacenamiento de datos en la cadena de bloques:** en varios hilos de la lista de correo Bitcoin-Dev se ha seguido debatiendo esta semana sobre el almacenamiento de datos en la cadena de bloques.

  - *Offchain coin coloring:* Anthony Towns [posted][towns color] un
    resumen de un protocolo que se utiliza actualmente para asignar
    un significado especial a ciertos resultados de transacciones, una clase de técnicas
    generalmente llamadas *coloreado de monedas*.  También resumió un protocolo
    para almacenar datos binarios codificados en transacciones de Bitcoin
    y asociarlos a monedas "_coloreadas_" concretas.
    Tras resumir el estado actual de la situación, describió un
    método para almacenar datos utilizando el protocolo de transferencia de mensajes [nostr][] y asociarlos a monedas "_coloreadas_" concretas.
    de mensajes [nostr][] y asociarlo a monedas de colores que podrían
    transferirse en transacciones Bitcoin.  Esto tendría varias
    ventajas:

    - *Costes reducidos:* no es necesario pagar tasas de transacción por los datos
      almacenados offchain.

    - *Privado:* dos personas pueden intercambiar una moneda _"coloreada"_ sin que
      sin que nadie más sepa nada sobre los datos a los que hace referencia.

    - *No se requiere ninguna transacción para su creación*: los datos pueden asociarse a un UTXO existente.
      con un UTXO existente; no hay necesidad de crear un nuevo UTXO.

    - *Resistente a la censura:* si la asociación entre los datos
      y la moneda "_coloreada_" no es ampliamente conocida, entonces las transferencias de
      la moneda "_coloreada_" son tan resistentes a la censura como cualquier otro
      pago de Bitcoin onchain.

    En cuanto al aspecto de la resistencia a la censura, Towns afirma que
    "los bitcoins '_coloreados_' son en gran medida inevitables y simplemente algo
    con lo que hay que lidiar, en lugar de ser algo con lo que deberíamos
    tratar de prevenir/ evitar".  Compara la idea de que las monedas "_coloreadas_"
    puedan tener más valor que los bitcoins fungibles con el funcionamiento de
    Bitcoin que cobra comisiones por transacciones basadas en el tamaño de la transacción
    en lugar del valor transferido, concluyendo que no cree
    que esto conduzca necesariamente a incentivos significativamente desalineados.

  - *Aumentar el espacio permitido `OP_RETURN` en transacciones estándar:*
    Christopher Allen [preguntó][allen op_return] si era mejor
    poner datos arbitrarios en la salida de una transacción usando `OP_RETURN` o
    los datos testigo de una transacción.  Tras un debate, varios
    participantes ([1][todd o], [2][o'connor o], [3][poelstra o])
    señalaron que estaban a favor de flexibilizar las políticas de relay y de minado
    para permitir que las salidas `OP_RETURN` almacenen ```
    más de 83 bytes de datos arbitrarios.  Razonaron que otros
    métodos para almacenar grandes cantidades de datos se utilizan actualmente
    y no habría ningún daño adicional si se utilizara `OP_RETURN`
    en su lugar.

- **Dilución de tarifas en protocolos multipartitos:** Yuval Kogman
[publicó][kogman dilution] a la lista de correo Bitcoin-Dev la
descripción de un ataque contra ciertos protocolos multiparte.
Aunque el ataque fue [descrito previamente][riard dilution],
el post de Kogman atrajo de nuevo la atención sobre él.  Imaginemos que Mallory
y Bob contribuyen cada uno con una entrada a una transacción conjunta con un
tamaño y una comisión esperados, lo que implica un feerate esperado.
Bob proporciona un testigo del tamaño esperado para su aporte, pero Mallory proporciona un testigo mucho mayor de lo esperado.
Esto disminuye el feerate
de la transacción.  En la lista de correo fueron discutidas varias consecuencias de esto:

  - *Mallory consigue que Bob pague sus honorarios:* si Mallory tiene algún motivo oculto
    para incluir un testigo de gran tamaño en la cadena de bloques, por ejemplo, 
    quiere añadir datos arbitrarios---ella puede usar parte de los honorarios de Bob para pagar
    por ello.  Por ejemplo, Bob quiere crear una transacción de 1.000 vbytes
    con una tarifa de 10.000 satoshi, pagando 10 satoshi/vbyte para que se confirme rápidamente.
    Mallory rellena la transacción con 9.000
    vbytes de datos que Bob no esperaba, reduciendo su tarifa a 1
    sat/vbyte.  Aunque Bob pague la misma tarifa absoluta en ambos casos,
    no consigue lo que quería (confirmación rápida) y Mallory obtiene
    9.000 sats de datos añadidos a la cadena de bloques sin coste alguno para ella.

  - *Mallory puede ralentizar la confirmación:* una transacción con un
    feerate mas bajo puede confirmarse más lentamente. En un protocolo sensible al tiempo, esto
    podría causar un serio problema a Bob.  En otros casos, Bob puede
    que necesite aumentar la fee de la transacción, lo que le costará más dinero.
    adicional.

  Kogman describe varias mitigaciones en su post, aunque todas ellas
  implican concesiones.  En un [segundo post][kogman dilution2], señala
  que no conoce ningún protocolo implantado actualmente que sea
  vulnerable.

- **Maleabilidad de la firma Tapscript:** en un aparte de la mencionada
  conversación sobre la dilución de tasas, el desarrollador Russell O'Connor
  [señaló][o'connor tsm] que las firmas para un [tapscript][tema
  tapscript] pueden aplicarse a una copia del tapscript colocada en otro lugar
  en el árbol taproot.  Por ejemplo, el mismo tapscript *A* se coloca en
  dos lugares diferentes en un árbol taproot.  Para utilizar la alternativa más profunda
  requerirá colocar un hash adicional de 32 bytes en los datos testigo de
  la transacción de gasto.

  ```text
    *
  / \
  A   *
    / \
    A   B
  ```

  Eso significa que incluso si Mallory proporciona a Bob un testigo válido para
  su gasto tapscript antes de que Bob proporcione su propia firma, es
  todavía posible para Mallory emitir una versión alternativa de la
  transacción con un testigo mayor. Bob sólo puede evitar este problema
  recibiendo de Mallory una copia completa de su árbol de tapscripts.

  En el contexto de futuras actualizaciones mediante un soft fork de Bitcoin, Anthony Towns
  abrió un [issue][bitcoin inquisition #19] en el repositorio Bitcoin
  Inquisition siendo utilizado para probar [SIGHASH_ANYPREVOUT][tema
  sighash_anyprevout] (APO) para considerar tener un commit de APO para agregar datos adicionales y así evitarles este problema a los usuarios de esa extensión.

## Cambios en servicios y software cliente

*En este artículo mensual, destacamos actualizaciones interesantes de wallets (billeteras/ carteras/ monederos) y servicios de Bitcoin.*

- **El monedero Liana añade multisig:**
[Liana][news234 liana]'s [0.2 release][liana 0.2] añade soporte multisig usando
[descriptores][topic descriptors].

- **Lanzamiento de la cartera Sparrow 1.7.2:**
La [versión 1.7.2][sparrow 1.7.2] de Sparrow añade soporte para [taproot][topic taproot]
soporte, [BIP329][] características de importación y exportación (ver [Newsletter #235][news235
bip329]), y soporte adicional para dispositivos de firma por hardware.

- **La biblioteca Bitcoinex añade compatibilidad con schnorr:**.
[Bitcoinex][bitcoinex github] es una librería de utilidades Bitcoin para el lenguaje de programación funcional Elixir.

- **Libwally 0.8.8 publicado:**
[Libwally 0.8.8][] añade soporte para hash etiquetado [BIP340][], soporte adicional para sighash
incluyendo [BIP118][] ([SIGHASH_ANYPREVOUT][topic SIGHASH_ANYPREVOUT]), y
funciones adicionales [miniscript][tema miniscript], descriptor y [PSBT][tema psbt].

## Optech Recomienda

[BitcoinSearch.xyz][] es un motor de búsqueda recientemente lanzado para Bitcoin
documentación técnica y debates.  Se utilizó para encontrar rápidamente
varias de las fuentes enlazadas en este boletín, una gran mejora
sobre otros métodos más laboriosos que hemos utilizado anteriormente.  Contribuciones
a su [código][repositorios bitcoinsearch] son bienvenidas.

## Lanzamientos y versiones candidatas

*Nuevas versiones y versiones candidatas de populares proyectos de infraestructura Bitcoin.
Bitcoin.  Por favor, considere actualizarse a las nuevas versiones o ayudar a probar las versiones candidatas.
versiones candidatas.*

- [Core Lightning 23.02rc2][] es una versión candidata para una nueva versión de mantenimiento de esta popular implementación de LN.
versión de mantenimiento de esta popular implementación de LN.

- [BTCPay Server 1.7.11][] es una nueva versión.  Desde la última versión
que cubrimos (1.7.1), se han añadido varias nuevas características y se han
correcciones de errores y mejoras.  Especialmente notables, varios
aspectos relacionados con plugins e integraciones de terceros.
integración con terceros, se ha añadido una ruta de migración desde MySQL y SQLite
y se ha corregido una vulnerabilidad de secuencias de comandos entre sitios.

- [BDK 0.27.0][] es una actualización de esta biblioteca para crear monederos y aplicaciones Bitcoin.

## Cambios notables en código y documentación

*Cambios notables esta semana en [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][repositorio del servidor btcpay], [BDK][repositorio bdk], [Propuestas de mejoras de Bitcoin
(BIPs)][repositorio bips], y [Lightning BOLTs][repositorio bolts].*

- [Core Lightning #5361][] añade soporte experimental para copias de seguridad.
Como se mencionó por última vez en [Newsletter #147][news147 backups],
esto permite a un nodo para almacenar un pequeño archivo de copia de seguridad cifrada para su
sus pares.  Si más tarde un peer necesita reconectarse, quizás después de perder datos,
puede solicitar el archivo de copia de seguridad.  El par puede utilizar una clave derivada
de su cartera para descifrar el archivo y utilizar su contenido para recuperar
el último estado de todos sus canales.  Esto puede considerarse una
forma mejorada de [copias de seguridad estáticas de canales][topic static channel
copias de seguridad].  El PR fusionado añade soporte para crear, almacenar y recuperar
las copias de seguridad encriptadas.  Como se indica en los mensajes de confirmación, la función
aún no ha sido completamente especificada o adoptada por otras implementaciones de LN.
implementaciones.

- [Core Lightning #5670][] y [#5956][core lightning #5956] realizan
varias actualizaciones de su implementación de [doble financiación][tema doble
financiación] basándose tanto en los cambios recientes de la [especificación][tornillos
#851] y los comentarios de los evaluadores de interoperabilidad.  Además, un
RPC `upgradewallet` para mover todos los fondos en salidas envueltas en P2SH
a salidas segwit nativas, lo que es necesario para abrir canales interactivos.
abre.

- [Core Lightning #5697][] añade un RPC `signinvoice` que firmará una
[BOLT11][] factura.  Anteriormente, CLN sólo firmaba una factura cuando
tenía la imagen previa para el hash [HTLC][tema HTLC], asegurando que sería
poder reclamar un pago a la factura.  Este RPC puede anular
que el comportamiento, que podría (por ejemplo) ser utilizado para enviar una factura
ahora y más tarde utilizar un plugin para recuperar la preimagen de otro
programa.  Cualquiera que utilice esta RPC debe ser consciente de que cualquier tercero
que tiene conocimiento anterior del preimage para un pago previsto para
su nodo puede demandar ese pago antes de que llegue.  Eso no sólo
roba su dinero pero, porque usted firmó la factura, genera muy
pruebas muy convincentes de que se le pagó (estas pruebas son tan convincentes
que muchos desarrolladores de LN la llaman *prueba de pago*).

- [Core Lightning #5960][] añade una [política de seguridad][cln security.md]
que incluye direcciones de contacto y claves PGP.

- [LND #7171][] actualiza el RPC `signrpc` <!--sic--> para que sea compatible con el
último [borrador BIP][borrador bip musig] para [MuSig2][tema musig].  El RPC ahora crea
sesiones vinculadas a un número de versión del protocolo MuSig2 para que todas las
operaciones dentro de una sesión utilicen el protocolo correcto. Un
problema de seguridad con una versión antigua del protocolo MuSig2 fue
mencionado en [Newsletter #222][news222 musig2].

- [LDK #2002][] añade soporte para reenviar automáticamente [pagos espontáneos
pagos][tema pagos] que no tienen éxito inicialmente.

- [BTCPay Server #4600][] actualiza la [selección de moneda][tema selección de moneda] para su [payjoin][tema payjoin]
para tratar de evitar la creación de transacciones con *entradas 
innecesarias*, concretamente una entrada mayor que cualquier salida en una
transacción que contenga múltiples entradas.  Esto no ocurriría con
un pago normal de un solo pagador y un solo receptor: la mayor entrada
habría proporcionado un pago suficiente para el resultado del pago y no
se habría añadido ninguna otra entrada.
Este RP se inspiró en parte en un [documento que analiza los payjoins][].

{% include references.md %}
{% include linkers/issues.md v=2 issues="5361,5670,5956,851,5697,5960,7171,2002,4541,4600" %}
[news147 backups]: /en/newsletters/2021/05/05/#closing-lost-channels-with-only-a-bip32-seed
[cln security.md]: https://github.com/ElementsProject/lightning/blob/master/SECURITY.md
[news222 musig2]: /en/newsletters/2022/10/19/#musig2-security-vulnerability
[musig draft bip]: https://github.com/jonasnick/bips/blob/musig2/bip-musig2.mediawiki
[paper analyzing payjoins]: https://eprint.iacr.org/2022/589.pdf
[bitcoinsearch repos]: https://github.com/bitcoinsearch
[towns color]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021396.html
[nostr]: https://github.com/nostr-protocol/nostr
[allen op_return]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021387.html
[todd or]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021435.html
[o'connor or]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021439.html
[poelstra or]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021438.html
[kogman dilution]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021444.html
[riard dilution]: https://gist.github.com/ariard/7e509bf2c81ea8049fd0c67978c521af#witness-malleability
[kogman dilution2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021459.html
[o'connor tsm]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021452.html
[bitcoin inquisition #19]: https://github.com/bitcoin-inquisition/bitcoin/issues/19
[bitcoinsearch.xyz]: https://bitcoinsearch.xyz/
[core lightning 23.02rc2]: https://github.com/ElementsProject/lightning/releases/tag/v23.02rc2
[BTCPay Server 1.7.11]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.7.11
[bdk 0.27.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.27.0
[news234 liana]: /en/newsletters/2023/01/18/#liana-wallet-released
[liana 0.2]: https://github.com/wizardsardine/liana/releases/tag/0.2
[sparrow 1.7.2]: https://github.com/sparrowwallet/sparrow/releases/tag/1.7.2
[news235 bip329]: /en/newsletters/2023/01/25/#bips-1383
[bitcoinex github]: https://github.com/RiverFinancial/bitcoinex
[libwally 0.8.8]: https://github.com/ElementsProject/libwally-core/releases/tag/release_0.8.8
