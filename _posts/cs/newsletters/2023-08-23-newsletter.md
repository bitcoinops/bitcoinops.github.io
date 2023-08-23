---
title: 'Zpravodaj „Bitcoin Optech” č. 265'
permalink: /cs/newsletters/2023/08/23/
name: 2023-08-23-newsletter-cs
slug: 2023-08-23-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme popis dokladů o podvodu za poskytnutí staré zálohy
stavu kanálu. Nechybí též naše pravidelné rubriky s popisem nedávných
změn ve službách a klientech, oznámeními o nových vydáních a popisem
významných změn v populárním bitcoinovém páteřním software.

## Novinky

- **Doklad o podvodu za poskytnutí staré zálohy:** Thomas Voegtlin zaslal
  do emailové skupiny Lightning-Dev [příspěvek][voegtlin backups] s myšlenkou
  na službu, která by mohla být penalizována v případě poskytnutí jiné než
  poslední verze zálohy. Základní mechanismus je jednoduchý:

    - Alice má data, která chce zálohovat. Přidá do nich číslo verze, podepíše
      je a data i podpis poskytne Bobovi.

    - Okamžitě po obdržení Aliciných dat jí Bob pošle podpis, který zavazuje
      k číslu verze jejích dat a k aktuálnímu času.

    - Po čase Alice data aktualizuje, navýší číslo verze a poskytne aktualizaci
      Bobovi spolu s novým podpisem. Bob vrátí podpis zavazující k nové, vyšší
      verzi a novému, vyššímu aktuální času. Tento krok mnohokrát opakují.

    - V jeden okamžik Alice od Boba vyžádá svá data, aby ho otestovala. Bob
      jí pošle verzi dat a její podpis, které může Alice ověřit. Bob jí též
      pošle další podpis, který zavazuje k číslu verze dat a aktuálnímu
      času.

    - Pokud by Bob jednal nečestně a poslal Alici stará data se starým číslem
      verze, Alice by mohla vygenerovat _doklad o podvodu_: mohla by prokázat,
      že Bob předtím podepsal vyšší číslo verze s dřívějším časem, než ke kterým
      zavazuje podpis, který jí poslal právě teď.

  Mechanismus generování dokladů o podvodu, jak byl zatím popsán, nemá nic
  společného s bitcoinem. Voegtlin však poznamenal, že pokud by opkódy
  [OP_CHECKSIGFROMSTACK (CSFS) a OP_CAT][topic op_checksigfromstack] byly
  soft forkem přidány do bitcoinu, bylo by možné používat doklady o podvodu
  onchain.

  Příklad: Alice a Bob sdílejí LN kanál s dodatečnou [taprootovou][topic taproot]
  podmínkou, která Alici umožňuje utratit všechny prostředky kanálu, pokud
  by poskytla doklad o podvodu. Běžný provoz kanálu by obsahoval jen
  jeden další krok: po každé aktualizaci kanálu by Alice poskytla Bobovi
  podpis současného stavu (včetně čísla verze). Nato by při každém novém
  připojení k Bobovi Alice vyžádala poslední zálohu a ověřila její integritu.
  Pokud by Bob poskytl starou zálohu, Alice by si mohla díky dokladu o
  podvodu a platební podmínce CSFS nárokovat celý zůstatek kanálu.

  Pro Alici by díky tomuto mechanismu bylo bezpečnější použít stav poskytnutý
  Bobem jako poslední stav kanálu v případě, kdy by Alice opravdu svá
  data ztratila. Podle současného designu LN kanálů (LN-Penalty) by mohl Bob
  ukrást celý Alicin zůstatek, kdyby se mu podařilo podstrčit jí starý stav.
  I v navrhovaných aktualizacích jako [LN-Symmetry][topic eltoo] by Alicino
  použití starého stavu umožnilo Bobovi ji okrást. Bobova ochota nabídnout
  starý stav by v případě hrozby penalizace byla nižší.

  Návrh obdržel významné množství reakcí:

  - Peter Todd [poznamenal][todd backups1], že mechanismus je v základu
    obecně použitelný. Není vázaný na LN a mohl by být užitečný v řadě
    protokolů. [Též poznamenal][todd backups2], že jednodušším způsobem by
    bylo, kdyby Alice od Boba jednoduše stahovala poslední stav při každém
    novém připojení bez použití jakýchkoliv dokladů o podvodu. Kdyby jí
    poskytl starý stav, mohla by kanál zavřít a tím mu odepřít možné budoucí
    poplatky za přeposílání plateb. Podobá se to verzi [peer storage][topic
    peer storage] popsané v [BOLT 881][BOLTs #881], jehož experimentální
    implementace se dříve letos objevila v Core Lightning (viz [zpravodaj č.
    238][news238 peer storage]) a (jak ve svém [příspěvku][teinturier
    backups] naznačuje Bastien Teinturier) i ve verzi schématu implementovaného
    v LN peněžence Phoenix.

  - Ghost43 ve své [reakci][ghost43 backups] vysvětlil, že doklady o podvodu
    vedoucí k finanční penalizaci poskytují mocný nástroj klientům
    ukládajícím data u anonymních uzlů. Velké populární služby mohou dbát o
    svou reputaci natolik, aby se lhaní svým klientům vyvarovaly, ale
    anonymní uzly nemají žádnou reputaci, o kterou by mohly přijít. Ghost43
    dále navrhl úpravu protokolu, která by jej učinila symetrickým, tedy aby
    vedle Alice ukládající stav u Boba (s potrestáním Boba v případě lhaní)
    ukládal i Bob svůj stav u Alice, která by mohla být za lhaní potrestána.

    Voegtlin tuto myšlenku rozšířil o [varování][voegtlin backups2], že
    poskytovatelé softwarových peněženek mají potřebu zachovat si dobrou
    reputaci, kterou by ztráceli, kdyby jejich uživatelé ztráceli peníze,
    i kdyby software fungoval, jak nejlépe mohl. Pro něj jako vývojáře softwarové
    peněženky je tak velmi důležité minimalizovat hrozbu, že by anonymní
    uzel mohl okrást uživatele peněženky Electrum, který používá podobný
    mechanismus zálohování.

  Diskuze nepřinesla jasné rozuzlení.

## Změny ve službách a klientech

*V této měsíční rubrice upozorňujeme na zajímavé aktualizace bitcoinových
peněženek a služeb.*

- **Scaling Lightning žádá o zpětnou vazbu:**
  [Scaling Lightning][] je testovacím souborem nástrojů pro Lightning Network
  na regtestu a signetu. Projekt si klade za cíl poskytnout nástroje pro
  testování různých implementací LN v rozličných konfiguracích a scénářích.
  Projekt nedávno komunitě nabídl [video update][sl twitter update]. Vývojáři
  LN, badatelé a provozovatelé infrastruktury jsou vyzýváni k [poskytnutí
  zpětné vazby][sl tg].

- **Vydán Torq v1.0:**
  Software pro pokročilou správu LN uzlu [Torq][torq github] [oznámil][torq blog]
  vydání verze 1.0 včetně funkcí Lightning Service Provider (LSP), automatizačních
  postupů a pokročilých funkcí pro provozovatele velkých uzlů.

- **Vydána Blixt Wallet v0.6.8:**
  [Vydání v0.6.8][blixt v0.6.8] obsahuje mimo jiné podporu pro [pozdržené
  faktury][topic hold invoices] („hold invoices”) a [zero-conf kanály][topic
  zero-conf channels].

- **Vydán Sparrow 1.7.8:**
  Sparrow [1.7.8][sparrow 1.7.8] přidává podporu pro [podepisování zpráv][topic
  generic signmessage] dle [BIP322][] včetně P2TR adres a přidává několik
  vylepšení do navyšování poplatků pomocí [RBF][topic rbf] a [CPFP][topic cpfp].

- **Prototyp bitaxeUltra, open source ASIC zařízení pro těžbu:**
  [BitaxeUltra][github bitaxeUltra] je open source zařízením pro těžbu používající
  zákaznického integrovaného obvodu (ASIC) a založený na existujícím komerčním
  těžícím hardware.

- **Oznámen FROST software Frostsnap:**
  Tým [oznámil][frostsnap blog] svou představu [budování][frostsnap github]
  nad schématem [prahového elektronického podpisu][topic threshold signature]
  FROST a za použití experimentální implementace FROST [secp256kfun][secp256kfun
  github].

- **Oznámena knihovna Libfloresta:**
  [Libfloresta][libfloresta blog] je rustová knihovna pro přidání podpory funkcí
  bitcoinového uzlu založeného na [utreexo][topic utreexo] do aplikací. Staví na
  výsledcích práce na utreexo uzlu [Floresta][news247 floresta].

- **Vydána Wasabi Wallet 2.0.4:**
  Wasabi [2.0.4][wasabi 2.0.4] přidává nové funkce pro navyšování poplatků pomocí
  [RBF][topic rbf] i [CPFP][topic cpfp], vylepšení [coinjoinu][topic coinjoin],
  rychlejší načítání peněženky, vylepšení RPC a další novinky a opravy chyb.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Core Lightning 23.08rc3][] je kandidátem na vydání příští hlavní verze této
  populární implementace LN uzlu.

- [HWI 2.3.1][] je nové vydání tohoto nástroje pro práci s hardwarovými podpisovými
  zařízeními.

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo] a
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #27981][] opravuje chybu, které mohla potenciálně způsobit,
  že by dva uzly nebyly schopny od sebe navzájem přijímat data. Pokud by
  Alicin uzel měl hodně dat čekajících ve frontě na odeslání Bobovu uzlu,
  pokusil by se tato data odeslat před přijetím jakýchkoliv dat od Boba. Pokud by Bob
  též měl hodně dat ve frontě na odeslání Alici, také by nepřijal od Alice
  žádná nová data. To by mohlo vést k situaci, kdy by se žádný z těchto
  uzlů nikdy nepokusil o přijetí dat od druhého. Problém byl původně
  objeven v [projektu Elements][Elements Project].

- [BOLTs #919][] přidává do specifikace LN doporučení, aby po dosažení určité
  částky přestaly uzly akceptovat další ořezaná HTLC. Ořezané HLTC je
  přeposílatelná platba, která však není přidána na výstup commitment
  transakce kanálu. Namísto toho je částka rovnající se hodnotě ořezaného
  HTLC vyhrazena na transakční poplatky. Díky tomu je možná v rámci LN
  přeposílat platby, které by onchain byly [neekonomické][topic uneconomical
  outputs]. Avšak pokud by se kanál měl zavřít v době, kdy jsou zpracovávány
  ořezaná HTLC, nemá uzel žádnou možnost, jak tyto prostředky nárokovat.
  Stanovení horní meze tohoto druhu ztráty je tedy rozumné. Viz též naše
  popisy rozličných implementací přidávající tento limit: LDK ve [zpravodaji
  č. 162][news162 trim], Eclair ve [zpravodaji č. 171][news171 trim] a
  Core Lightning ve [zpravodaji č. 173][news173 trim] a také
  [zpravodaj č. 170][news170 trim] (vše *angl.*) popisující relevantní
  bezpečností problémy.

- [Rust Bitcoin #1990][] volitelně umožňuje, aby byl `bitcoin_hashes` zkompilován
  s pomalejšími implementacemi SHA256, SHA512 a RIPEMD160, která mají však
  poloviční velikost. Užitečné mohou být ve vestavěných zařízeních, které
  nevykonávají časté hashování.

- [Rust Bitcoin #1962][] přidává možnost používat hardwarově optimalizované
  SHA256 operace na x86 kompatibilních architekturách.

- [BIPs #1485][] přidává několik aktualizací do [BIP300][] specifikace
  [drivechainů][topic sidechains]. Hlavní změnou se jeví být nová definice
  `OP_NOP5` v některých kontextech `OP_DRIVECHAIN`.

{% include references.md %}
{% include linkers/issues.md v=2 issues="27460,27981,919,1990,1962,1485,881" %}
[core lightning 23.08rc3]: https://github.com/ElementsProject/lightning/releases/tag/v23.08rc3
[news238 peer storage]: /cs/newsletters/2023/02/15/#core-lightning-5361
[news162 trim]: /en/newsletters/2021/08/18/#rust-lightning-1009
[news171 trim]: /en/newsletters/2021/10/20/#eclair-1985
[news173 trim]: /en/newsletters/2021/11/03/#c-lightning-4837
[news170 trim]: /en/newsletters/2021/10/13/#ln-spend-to-fees-cve
[elements project]: https://elementsproject.org/
[voegtlin backups]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004043.html
[todd backups1]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004046.html
[todd backups2]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004044.html
[teinturier backups]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004045.html
[ghost43 backups]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004052.html
[voegtlin backups2]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004055.html
[Scaling Lightning]: https://github.com/scaling-lightning/scaling-lightning
[sl twitter update]: https://twitter.com/max_blue__/status/1681781001373065216
[sl tg]: https://t.me/+AytRsS0QKH5mMzM8
[torq github]: https://github.com/lncapital/torq
[torq blog]: https://ln.capital/articles/announcing-torq-V1.0
[blixt v0.6.8]: https://github.com/hsjoberg/blixt-wallet/releases
[sparrow 1.7.8]: https://github.com/sparrowwallet/sparrow/releases/tag/1.7.8
[github bitaxeUltra]: https://github.com/skot/bitaxe/tree/ultra
[frostsnap blog]: https://frostsnap.com/introducing-frostsnap.html
[frostsnap github]: https://github.com/frostsnap/frostsnap
[secp256kfun github]: https://github.com/LLFourn/secp256kfun
[news247 floresta]: /en/newsletters/2023/04/19/#utreexo-based-electrum-server-announced
[libfloresta blog]: https://blog.dlsouza.lol/2023/07/07/libfloresta.html
[wasabi 2.0.4]: https://github.com/zkSNACKs/WalletWasabi/releases/tag/v2.0.4
[hwi 2.3.1]: https://github.com/bitcoin-core/HWI/releases/tag/2.3.1
