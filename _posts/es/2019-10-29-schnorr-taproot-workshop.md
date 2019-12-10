---
title: Bitcoin Optech Schnorr Taproot Workshop
permalink: /es/schorr-taproot-workshop/
name: 2019-10-29-schnorr-taproot-workshop-es
type: posts
layout: post
lang: es
slug: 2019-10-21-schnorr-taproot-workshop-es

excerpt: >
  Un curso de autoaprendizaje para entender más sobre la propuesta de soft-fork schnorr/taproot.

auto_id: false
---
{% include references.md %}

En septiembre del 2019, Bitcoin Optech llevó a cabo talleres en San Francisco y
Nueva York sobre las propuestas del soft-fork schnorr/taproot. Los objetivos de
los talleres fueron:

1. compartir las ideas actuales a  la comunidad open-source sobre las propuestas,
2. dar a los ingenieros la oportunidad de trabajar con la nueva tecnología a
   través de notebooks interactivos jupyter, y
3. ayudar a los ingenieros a participar en el proceso de retroalimentación de
   la comunidad.

Este artículo contiene todos los videos, diapositivas y notebooks de jupyter de
estos talleres, para que los desarrolladores puedan aprender sobre estas nuevas
y emocionantes tecnologías desde casa.

Los talleres se dividieron en 4 secciones:

1. [Preparación y matemáticas básicas](#preparación-y-matemáticas-básicas) - muestra
  cómo configurar el entorno del notebook jupyter; ofrece una actualización de
  las matemáticas básicas de la curva elíptica e introduce hashes etiquetados.
2. [Firmas de Schnorr y MuSig](#firmas-schnorr-y-musig) - describe el
  esquema de firma bip-schnorr y cómo usar MuSig para agregar múltiples llaves
  públicas y firmas parciales en una sola llave/firma.
3. [Taproot](#taproot) - muestra cómo crear y gastar una salida de segwit v1
  utilizando la ruta de la llave (donde se proporciona una firma única) o la
  ruta del script (donde un compromiso con un solo script o múltiples scripts se
  incrusta en una llave pública para luego ser revelada y empatada)
4. [Case studies](#casos-de-estudio) - demuestra algunas aplicaciones prácticas de
  las nuevas tecnologías schnorr y taproot.

Las diapositivas de todas las presentaciones se pueden descargar
[aqui][slides].  Bryan Bishop también ha proporcionado una
[transcripción][transcript] de la sesión de Nueva York.

## Introducción

[![Introduction](/img/posts/taproot-workshop/introduction.png)](https://www.youtube.com/watch?v=1gRCVLgkyAE&list=PLPrDsP88ifOVTEJf_jQGunDUS05M9GdIC)
{:.center}

John Newbery da un resumen de por qué schnorr y taproot son tecnologías útiles
y explica por qué Bitcoin Optech creó el taller. Luego, describe los objetivos
del taller.

## Preparación y matemáticas básicas

Esta sección muestra cómo configurar el notebook jupyter y ofrece una
actualización de las matemáticas básicas de la curva elíptica. También
introduce hashes etiquetados.

#### 0.1 Notebook de Prueba

Antes de comenzar los talleres, los usuarios deben seguir las instrucciones en
el archivo [README][readme] del repositorio, clonar el [repositorio del
taller][workshop repository] y posteriormente correr las pruebas del notebook
de prueba para asegurarse de que su entorno esté configurado correctamente.

[→ Corre este notebook en Google Colab](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/0.1-test-notebook.ipynb)

#### 0.2 Matemáticas de Curva Elíptica

[![Matemáticas de Curva Elíptica](/img/posts/taproot-workshop/elliptic-curve-math.png)](https://www.youtube.com/watch?v=oix8ov9iGgk&list=PLPrDsP88ifOVTEJf_jQGunDUS05M9GdIC&index=2)
{:.center}

Elichai Turkel proporciona un repaso sobre las matemáticas básicas de la curva
elíptica que se requerirán para este taller.

[→ Corre este notebook en Google Colab](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/0.2-elliptic-curve-math.ipynb)

#### 0.3 Hashes Etiquetados

_(Sin video)_ Este capítulo presenta _hashes etiquetados_, que son utilizados
en las propuestas bip-schnorr y bip-taproot.

[→ Corre este notebook en Google Colab](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/0.3-tagged-hashes.ipynb)

## Firmas Schnorr y MuSig

Esta sección se explica la propuesta de bip-schnorr y cómo MuSig puede ser
usado para agregar múltiples llaves públicas y firmas parciales en un solo
conjunto de llave pública y firma.

#### 1.1 Firmas de Schnorr

[![Firmas de Schnorr](/img/posts/taproot-workshop/schnorr.png)](https://www.youtube.com/watch?v=wybiVFdknhg&list=PLPrDsP88ifOVTEJf_jQGunDUS05M9GdIC&index=3)
{:.center}

Elichai explica las matemáticas detrás de las firmas schnorr y explica la
propuesta bip-schnorr.

[→ Corre este notebook en Google Colab](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/1.1-schnorr-signatures.ipynb)

#### 1.2 MuSig

[![MuSig](/img/posts/taproot-workshop/musig.png)](https://www.youtube.com/watch?v=5MbTptrXEC4&list=PLPrDsP88ifOVTEJf_jQGunDUS05M9GdIC&index=4)
{:.center}

Elichai describe el [algoritmo MuSig][musig] (creado por Gregory Maxwell,
Andrew Poelstra, Yannick Seurin y Pieter Wuille), y muestra cómo puede ser
usado para agregar múltiples llaves públicas y firmas parciales en una sola
llave pública/firma.

[→ Corre este notebook en Google Colab](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/1.2-musig.ipynb)

## Taproot

Esta sección explica las propuestas bip-taproot y bip-tapscript. Muestra el
formato de una salida segwit v1 y cómo se puede usar dicha salida en un gasto
de ruta de llave o en un gasto de ruta de script. Demuestra cómo una llave
pública modificada puede comprometerse con uno o más scripts, y cómo se puede
gastar la salida de segwit v1 usando uno de esos scripts.

#### 2.0 Introducción a Taproot

[![Introducción a Taproot](/img/posts/taproot-workshop/taproot-intro.png)](https://www.youtube.com/watch?v=KLNH0ttpdFg&list=PLPrDsP88ifOVTEJf_jQGunDUS05M9GdIC&index=5)
{:.center}

James Chiang muestra una visión general de las propuestas bip-taproot y
bip-tapscript. Este notebook muestra cómo crearemos resultados de transacciones
para luego gastarlos y verificar que el gasto sea válido.

[→ Corre este notebook en Google Colab](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/2.0-taproot-introduction.ipynb)

#### 2.1 Segwit V1

[![Segwit Versión 1](/img/posts/taproot-workshop/segwit-version-1.png)](https://www.youtube.com/watch?v=n-jAUaSkcAA&list=PLPrDsP88ifOVTEJf_jQGunDUS05M9GdIC&index=6)
{:.center}

James muestra cómo crear salidas de transacciones segwit v1 y gastarlas usando
el gasto de ruta de llave.

[→ Corre este notebook en Google Colab](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/2.1-segwit-version-1.ipynb)

#### 2.2 Taptweak

[![Taptweak](/img/posts/taproot-workshop/taptweak.png)](https://www.youtube.com/watch?v=EkGbPxAExdQ&list=PLPrDsP88ifOVTEJf_jQGunDUS05M9GdIC&index=7)
{:.center}

James explica qué es un ajuste de llave y cómo se puede usar un ajuste para
confirmar datos arbitrarios.

[→ Corre este notebook en Google Colab](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/2.2-taptweak.ipynb)

#### 2.3 Tapscript

[![Tapscript](/img/posts/taproot-workshop/tapscript.png)](https://www.youtube.com/watch?v=nXGe9_M5pjk&list=PLPrDsP88ifOVTEJf_jQGunDUS05M9GdIC&index=8)
{:.center}

James analiza cómo podemos confirmar un tapscript en una salida de segwit v1
usando un taptweak, y cómo podemos gastar esa salida usando las reglas de gasto
de ruta de llave segwit v1. También explica las diferencias entre el tapscript
y el script de legacy bitcoin.

[→ Corre este notebook en Google Colab](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/2.3-tapscript.ipynb)

#### 2.4 Taptree

[![Taptree](/img/posts/taproot-workshop/taptree.png)](https://www.youtube.com/watch?v=n6R15Eo6J44&list=PLPrDsP88ifOVTEJf_jQGunDUS05M9GdIC&index=9)
{:.center}

James muestra cómo se puede construir un árbol de merkle de scripts y cómo
podemos comprometernos con ese árbol utilizando un taptweak. Luego explica cómo
gastar el resultado satisfaciendo uno de esos scripts y proporcionando una
prueba de que el script era parte del árbol comprometido.

[→ Corre este notebook en Google Colab](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/2.4-taptree.ipynb)

#### 2.5 Huffman Construction

_(Sin video)_ Este capítulo adicional muestra cómo construir de manera más
eficiente un árbol de scripts colocando scripts que tienen más probabilidades
de gastarse más cerca de la raíz del árbol.

[→ Corre este notebook en Google Colab](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/2.5-huffman.ipynb)

## Casos de estudio

Esta sección contiene demostraciones de cómo las nuevas tecnologías
schnorr/taproot pueden usarse para crear servicios y productos avanzados de
Bitcoin.

#### 3.1 Degradando Multisig

_(Sin video)_ Este capítulo muestra una billetera multisig degradante. En todos
los casos, la salida se puede gastar con un subconjunto de las llaves "vivas",
pero después de un tiempo de espera, la salida se puede gastar con una
combinación no solo de llaves "vivas" sino también "de respaldo". Taproot
permite que se comprometan múltiples rutas de gasto, pero sólo la que se ejerce
se revela en la cadena.

[→ Corre este notebook en Google Colab](https://colab.research.google.com/github/bitcoinops/taproot-workshop/blob/Colab/3.1-degrading-multisig-case-study.ipynb)

## Resumen

[![Resumen](/img/posts/taproot-workshop/summary.png)](https://www.youtube.com/watch?v=Q1od076K7IM&list=PLPrDsP88ifOVTEJf_jQGunDUS05M9GdIC&index=10)
{:.center}

John concluye el taller explicando cómo tú puedes participar en el proceso de
retroalimentación de la comunidad para estas propuestas.

[slides]: /img/posts/taproot-workshop/taproot-workshop.pdf
[transcript]: https://diyhpl.us/wiki/transcripts/bitcoinops/schnorr-taproot-workshop-2019/notes/
[readme]: https://github.com/bitcoinops/taproot-workshop/blob/master/README.md
[workshop repository]: https://github.com/bitcoinops/taproot-workshop/
