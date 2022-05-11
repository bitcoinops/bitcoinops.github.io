---
title: 'Zpravodaj „Bitcoin Optech” č. 199'
permalink: /cs/newsletters/2022/05/11/
name: 2022-05-11-newsletter-cs
slug: 2022-05-11-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden shrnujeme sezení Bitcoin Core PR Review Club a popisujeme novinku bitcoinové
implementace v Rustu.

## Novinky

Tento týden nepřinesl žádné významné novinky. Mnoho nového bylo řečeno v diskuzích
o tématech, o kterých jsme již hovořili – mezi nimi např.
[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] a [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] –
ovšem většina příspěvků nebyla technické povahy či se týkala detailů, které
nepovažujeme za relevantní. Několik zajímavých příspěvků bylo zasláno do emailových skupin
během vzniku tohoto čísla, budeme se jimi podrobně zabývat příští týden.

## Bitcoin Core PR Review Club

*V této měsíční rubrice shrnujeme nedávné sezení [Bitcoin Core PR Review Club][] a
vyzdvihujeme některé z důležitých otázek a odpovědí. Klikněte na otázku a odpověď se vám odhalí.*

[Improve Indices on pruned nodes via prune blockers][review club pr] je PR od Fabiana Jahra,
které přidává „prune locks” (zámky ořezávání) jako nový způsob rozhodování, zda a kdy může ořezaný
(pruned) uzel bezpečně smazat blok z disku. Tato nová metoda umožňuje ořezaným uzlům udržovat index
pro coinstats a odstraňuje závislost validačního modulu na kódu indexace.

{% include functions/details-list.md

  q0="Jaké indexy v současnosti obsahuje Bitcoin Core a co je jich účelem?"
  a0="Uzly mohou udržovat až tři volitelné indexy, které jim pomáhají efektivně získávat data z disku.
  Transaction index (`-txindex`) mapuje hash transakce na blok, který transakci obsahuje. Block filter index
  (`-blockfilterindex`) indexuje pro každý blok filtry podle BIP157. Coin stats index
  (`-coinstatsindex`) ukládá statistiky UTXO."
  a0link="https://bitcoincore.reviews/21726#l-28"


  q1="Co jsou kruhové závislosti? Proč se jim chceme vyvarovat?"
  a1="Kruhová závislost mezi dvěma moduly existuje, pokud žádný z nich nemůže být použit bez druhého.
  I když kruhové závislosti nepřináší bezpečnostní problémy, ukazují na špatnou organizaci kódu
  a ztěžují vývoj, jelikož je kvůli nim obtížnější samostatně sestavovat, používat a testovat dané
  moduly nebo funkce."
  a1link="https://bitcoincore.reviews/21726#l-44"

  q2="Jak fungují prune locks představené v [tomto commitu][review club commit]?"
  a2="Tento PR přidává ke každému indexu seznam prune locks, což jsou nejnižší výšky bloků,
  které nesmí být smazány. Když se uzel v metodě `CChainState::FlushStateToDisk` rozhoduje, které bloky budou
  smazány, použije tento seznam, aby zamezil smazání bloků vyšších než daná výška. Prune locks jsou aktualizovány
  vždy, když je aktualizován příslušný index."
  a2link="https://bitcoincore.reviews/21726#l-68"

  q3="Jaké jsou výhody a nevýhody tohoto řešení v porovnání s předchozím?"
  a3="Aby zjistila maximální výšku bloků k odstranění, dotazovala se dříve implementace
  v `CChainState::FlushStateToDisk` indexu napřímo. To však vyžadovalo vzájemné provázání logiky
  validace a indexace. Nově jsou tyto výšky (v podobě prune locks) proaktivně počítány indexovací logikou;
  mohou být sice počítány častěji, není však již vyžadováno, aby se validační logika dotazovala indexu."
%}

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo] a [Lightning BOLTs][bolts repo].*

- [Rust Bitcoin #716][] přidává `amount::Display`, konfigurovatelné rozšíření pro Display
  vhodné pro zobrazování peněžních částek a jiných hodnot. V základním nastavení
  formátuje čísla do co nejkratší podoby; nepřidává již tedy nadbytečné nuly, což dříve
  generovalo zbytečně dlouhé [BIP21][] adresy a velké QR kódy.

{% include references.md %}
{% include linkers/issues.md v=2 issues="716" %}
[review club commit]: https://github.com/bitcoin-core-review-club/bitcoin/commit/527ef4463b23ab8c80b8502cd833d64245c5cfc4
[review club pr]: https://bitcoincore.reviews/21726
