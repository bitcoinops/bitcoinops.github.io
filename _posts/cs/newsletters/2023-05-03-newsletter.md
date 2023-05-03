---
title: 'Zpravodaj „Bitcoin Optech” č. 249'
permalink: /cs/newsletters/2023/05/03/
name: 2023-05-03-newsletter-cs
slug: 2023-05-03-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme popis analýzy použití návrhu flexibilních
kovenantů reimplementující `OP_VAULT`, souhrn příspěvku o
bezpečnosti signature adaptorů a přeposíláme oznámení o pracovní
příležitosti, která může některé čtenáře zajímat. Též nechybí
naše pravidelné rubriky popisující nová vydání, kandidáty
na vydání a významné změny v populárních bitcoinových páteřních
projektech.

## Novinky

- **Úschovny založené na MATT:** Salvatore Ingala zaslal do emailové
  skupiny Bitcoin-Dev [příspěvek][ingala vaults] s popisem hrubé
  implementace [úschovny][topic vaults] („vault”) s chováním podobným
  nedávnému návrhu na `OP_VAULT` (viz [zpravodaj č. 234][news234 op_vault]),
  avšak založený na Ingalově návrhu Merklize All The Things (MATT, „všechno
  to zmerklujte“; viz [zpravodaj č. 226][news226 matt], *angl.*). MATT
  by umožnil vytváření velmi flexibilních bitcoinových kontraktů pomocí
  několika nových, jednoduchých [kovenantových][topic covenants] opkódu.

  Tento týden Ingala ukázal, že MATT by byl velice flexibilní a efektivní
  a bylo by jej možné snadno použít ve vzorech transakcí, které by jednou
  mohly být dosti využívané. Podobně jako poslední verze návrhu na
  `OP_VAULT`, i zde staví Ingala na návrhu [BIP119][] na [OP_CHECKTEMPLATEVERIFY][topic
  op_checktemplateverify] (CTV). Přidáním dvou dodatečných opkódů
  (které, jak uznává, nepokryjí vše potřebné) nabízí množinu funkcí,
  která je téměř ekvivalentní s `OP_VAULT`; jedinou významnou chybějící
  funkcí je „možnost přidat dodatečný výstup, který posílá zpět do
  stejné úschovny.”

  V době psaní tohoto zpravodaje neobdržel Ingalův příspěvek žádnou
  přímou reakci, ale [diskuze][halseth matt] pokračovala pod jeho
  původním příspěvkem o MATTu a jeho schopnosti ověřit, že
  byl spuštěn nějaký (v podstatě) libovolně komplexní program.

- **Analýza bezpečnosti signature adaptorů:** Adam Gibson
  [zaslal][gibson adaptors] do emailové skupiny Bitcoin-Dev analýzu
  bezpečnosti [signature adaptorů][topic adaptor signatures], která
  se soustředí zejména na jejich interakci s protokoly [vícenásobných
  podpisů][topic multisignature] jako je [MuSig][topic musig], ve kterých
  musí množství účastníků bez vzájemné důvěry kooperovat na tvorbě adaptorů.
  Plánuje se v dohledné době nasadit signature adaptory v LN pro
  použití s [PTLC][topic ptlc], které vyústí ve zvýšení výkonnosti a soukromí.
  Věří se, že budou používány také v jiných protokolech s cílem zvyšovat
  efektivitu a/nebo soukromí. Představují jeden z nejmocnějších stavebních
  kamenů nových i rozšířených existujících bitcoinových protokolů, pečlivá
  analýza jejich bezpečnostních vlastností je tedy klíčová k dosažení
  správného používání. Gibson staví na předešlé analýze Lloyda Fourniera
  a dalších (viz [zpravodaj č. 129][news129 adaptors], *angl.*), ale také
  upozorňuje na nutnost dalšího zkoumání a analyzování.

- **Pracovní příležitost pro bitcoinové mágy:** Steve Lee z organizace Spiral,
  která se zabývá distribucí grantů, [zaslal][lee hiring] do emailové skupiny
  Bitcoin-Dev nabídku pro velmi zkušené bitcoinové přispěvatele na
  placenou pozici na plný úvazek, jejíž náplní by bylo hledat a vést
  projekty významně přispívající k dlouhodobým cílům bitcoinu jako
  je škálovatelnost, bezpečnost, soukromí a flexibilita. Příspěvek obsahuje
  další podrobnosti.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [LND v0.16.2-beta][] je menší vydání této implementace LN, která
  přináší opravy několika chyb postihující výkonnost, jež byly zaneseny
  do předchozího vydání.

- [Core Lightning 23.05rc2][] je kandidátem na vydání příští verze
  této implementace LN.

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo] a [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #25158][] přidává pole `abandoned` do detailu transakce
  v odpovědích na RPC volání `gettransaction`, `listtransactions` a `listsinceblock`.
  Pole indikuje, které transakce byly označeny jako [abandoned][abandontransaction rpc]
  („zahozené”).

- [Bitcoin Core #26933][] vrací zpět podmínku, aby každá transakce splňovala
  minimální jednotkový poplatek pro přeposílání nastavený uzlem pomocí
  volby `-minrelaytxfee`, aby mohla být připuštěna do mempoolu, i v případě,
  kdy je transakce vyhodnocena jako balíček. Validace balíčku i nadále
  umožňuje navýšit poplatek transakce pod dynamický minimální jednotkový
  poplatek mempoolu. Toto pravidlo bylo vráceno, aby eliminovalo riziko,
  že transakce s nulovým poplatkem ztratí své potomky navyšující jí
  poplatek. V budoucnu může být opět odstraněno, pokud se nalezne
  lepší způsob, který by byl odolný vůči útokům odepření služby (DoS),
  např. díky restrikcím topologie balíčku jako je v3 nebo modifikací
  procesu odstranění transakcí z mempoolu.

- [Bitcoin Core #25325][] přináší znovupoužitelný paměťový zdroj pro ukládání
  UTXO do mezipaměti. Tato nová datová struktura předem alokuje a spravuje
  větší úsek znovupoužitelné paměti namísto alokování a uvolňování paměti
  pro každé UTXO zvlášť. Vyhledávání UTXO představuje hlavní důvod
  přístupu do paměti obzvláště během prvotního stahování bloků. Benchmarky
  ukazují, že rychlost reindexování se díky tomu zvýší o více než 20 %.

- [Bitcoin Core #25939][] umožňuje uzlům s aktivovaným indexem transakcí
  vyhledávat v tomto indexu během RPC volání `utxoupdatepsbt`, které přidává
  do [PSBT][topic psbt] informace o výstupech transakce, kterou utrácí.
  Když bylo volání v roce 2019 poprvé implementováno (viz [zpravodaj č. 34][news34
  psbt], *angl.*), byly v síti běžné dva druhu výstupů: zastaralé výstupy
  a segwit v0 výstupy. Každé utracení zastaralého výstupu v PSBT vyžadovalo
  začlenění kopie transakce, která tento výstup obsahovala, aby podpisovatel
  mohl ověřit částku výstupu. Ověření je důležité, neboť utracení výstupu bez
  ověření částky může vést k velkému přeplacení na poplatcích.

  Každé utracení segwit v0 výstupu zavazuje ke své částce, aby mohlo PSBT
  začlenit pouze scriptPubKey výstupu a částku namísto celé předchozí
  transakce. Věřilo se, že by to odstranilo potřebu kompletní transakci
  začlenit. Jelikož je každý neutracený výstup každé potvrzené
  transakce uložen v množině UTXO, může `utxoupdatepsbt` přidat
  nezbytný scriptPubKey a částku do PSBT utrácející nějaké UTXO. `utxoupdatepsbt`
  též dříve vyhledávalo UTXO v mempoolu, aby umožnilo uživatelům utratit
  výstup nepotvrzené transakce.

  Avšak po přidání `utxoupdatepsbt` do Bitcoin Core začala některá
  hardwarová podpisová zařízení vyžadovat začlenění kompletní transakce
  i v případě segwit v0 výstupů, aby zabránila některým případům
  přeplacení, ke kterému by mohlo dojít v důsledku dvojího podepsání
  stejné transakce (viz [zpravodaj č. 101][news101 overpayment], *angl.*).

  Tato začleněná změna umožní vyhledat v indexu transakcí, pokud je aktivovaný,
  a v místním mempoolu kompletní transakce a začlenit je do PSBT, pokud je
  tak vyžadováno. Pokud není kompletní transakce nalezena, bude použita
  množina UTXO. Taproot (segwit v1) odstraňuje podobné obavy o přeplacení
  většiny transakcí, které utrácí alespoň jeden taprootový výstup, takže
  očekáváme, že v budoucnu opadne potřeba mít v podobných
  případech přístup k plným transakcím.

- [LDK #2222][] umožňuje aktualizovat informace o kanálu pomocí zpráv
  vyměňovaných uzly účastnící se tohoto kanálu bez nutnosti ověřovat,
  zda existuje UTXO odpovídající tomuto kanálu. Gossip zprávy v LN
  by měly být akceptované pouze, patří-li kanálu s existujícím UTXO.
  Toto opatření je jedním ze způsobů ochrany před DoS útoky, avšak
  některé LN uzly nemají přístup k UTXO a mohou disponovat jinými
  způsoby ochrany před DoS útoky. Tato změna usnadňuje podobných uzlům
  přijímat aktualizace informací.

- [LDK #2208][] přidává přeposílání transakcí a navyšování poplatků
  neukončeným [HTLC][topic htlc] v kanálech, které byly uzavřeny
  bez kooperace. Změna adresuje některé [pinningové útoky][topic transaction
  pinning] a zajišťuje spolehlivost. Viz též [zpravodaj č. 243][news243
  rebroadcast], kde LND přidalo své rozhraní přeposílání, a [minulé číslo][news247
  rebroadcast], kde CLN vylepšilo svou logiku.

{% include references.md %}
{% include linkers/issues.md v=2 issues="25158,26933,25325,2222,2208,25939" %}
[Core Lightning 23.05rc2]: https://github.com/ElementsProject/lightning/releases/tag/v23.05rc2
[lnd v0.16.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.2-beta
[news101 overpayment]: /en/newsletters/2020/06/10/#fee-overpayment-attack-on-multi-input-segwit-transactions
[news129 adaptors]: /en/newsletters/2020/12/23/#ptlcs
[news243 rebroadcast]: /cs/newsletters/2023/03/22/#lnd-7448
[news247 rebroadcast]: /cs/newsletters/2023/04/19/#core-lightning-6120
[ingala vaults]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021588.html
[news226 matt]: /en/newsletters/2022/11/16/#general-smart-contracts-in-bitcoin-via-covenants
[news234 op_vault]: /cs/newsletters/2023/01/18/#navrh-na-nove-opkody-pro-uschovny
[halseth matt]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021593.html
[gibson adaptors]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021594.html
[lee hiring]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021589.html
[news34 psbt]: /en/newsletters/2019/02/19/#bitcoin-core-13932
[abandontransaction rpc]: https://developer.bitcoin.org/reference/rpc/abandontransaction.html
