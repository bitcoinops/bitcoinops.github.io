---
title: 'Zpravodaj „Bitcoin Optech” č. 238'
permalink: /cs/newsletters/2023/02/15/
name: 2023-02-15-newsletter-cs
slug: 2023-02-15-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Tento týden přinášíme souhrn pokračující diskuze o ukládání dat v
bitcoinovém blockchainu, popisujeme hypotetický útok ředění poplatků
napadající některé protokoly s více účastníky a popisujeme, jak mohou
být taprootové podpisy použity s různými částmi stejného stromu.
Též nechybí naše pravidelné rubriky se souhrnem změn ve službách a
klientech, oznámeními o nových vydáních a popisem významných změn
oblíbených bitcoinových páteřních projektů. Navíc poskytujeme
jedno z našich vzácných doporučení na nový vyhledávač zaměřený
na bitcoinovou technickou dokumentaci a diskuze.

## Novinky

- **Pokračující debata o ukládání dat v blockchainu:** v několika
  vláknech emailové skupiny Bitcoin-Dev pokračovala tento týden
  diskuze o ukládání dat v blockchainu.

    - *Offchain obarvování mincí:* Anthony Towns [poslal][towns color]
      souhrn protokolu používaného pro přiřazování zvláštního významu
      některým výstupům. Těmto technikám se obecně říká *obarvování mincí*.
      Též popsal související protokol používaný pro ukládání binárních
      dat uvnitř bitcoinových transakcí a jejich asociaci s konkrétními
      obarvenými mincemi. Po souhrnu současného stavu popsal metodu
      pro ukládání dat pomocí zpráv na [Nostru][nostr] a jejich asociaci
      s obarvenými mincemi, které by mohly být posílány v bitcoinových
      transakcích. To by mělo několik výhod:

      - *Redukce nákladů:* žádné transakční poplatky za data přenášená
        offchain.

      - *Soukromí:* dva lidé mohou vyměnit obarvené mince, aniž by
        kdokoliv jiný věděl o datech, na která poukazují.

      - *Pro vytvoření není třeba transakce:* data mohou být asociována
        s existujícími UTXO, není nutné vytvářet nová UTXO.

      - *Odolnost vůči cenzuře:* není-li asociace mezi daty a obarvenými
        mincemi běžně známa, je posílání obarvených mincí natolik odolné
        vůči cenzuře, jako je sám bitcoin.

      Ve spojení s odolností vůči cenzuře Towns říká, že „obarvené
      bitcoiny jsou v podstatě nevyhnutelné a něco, s čím se musíme
      potýkat, spíš než něco, co se snažit potlačovat.” Porovnává
      myšlenku, že obarvené mince mohou mít větší hodnotu než zaměnitelné
      bitcoiny, s provozem bitcoinu a vyžadováním poplatků podle váhy
      transakce oproti poplatkům podle přenášené hodnoty. V závěru
      říká, že nevěří, že by toto muselo nutně vést ke špatným
      incentivám.

    - *Více prostoru pro `OP_RETURN` v běžných transakcích:*
      Christopher Allen [se tázal][allen op_return], zda-li je lepší
      umístit libovolná data ve witnessu transakce nebo v `OP_RETURN`
      výstupu. Po krátké diskuzi se několik účastníků  ([1][todd or],
      [2][o'connor or], [3][poelstra or]) vyjádřilo, že by souhlasili
      s uvolněním výchozích pravidel pro přeposílání a těžbu, aby
      umožnila více než 83 bytů v rámci `OP_RETURN` výstupů. Podle nich
      by rozšíření `OP_RETURN` nepřineslo větší škody, neboť jsou
      již používány i jiné metody ukládání dat.

- **Ředění poplatků v protokolech s více účastníky:** Yuval Kogman
  [zaslal][kogman dilution] do emailové skupiny Bitcoin-Dev popis
  útoku proti protokolům s více stranami. I když byl tento útok
  již [dříve popsán][riard dilution], Kogmanův příspěvek mu přinesl
  novou pozornost. Představte si, že Mallory a Bob přispějí každý
  jedním vstupem do společné transakce s očekávanou velikostí a
  poplatkem (tj. s očekávaným jednotkovým poplatkem). Bob pro svůj
  vstup poskytne witness očekávané velikosti, ale Mallory poskytne
  witness mnohem větší. To v důsledků sníží jednotkový poplatek za
  transakci. V emailové skupině bylo probráno několik důsledků:

    - *Bob platí za Malloryho:* má-li Mallory vedlejší úmysly, například
      chce-li poslat libovolná data, může na jejich poplatek použít
      část Bobova poplatku. Příklad: Bob chce vytvořit transakci
      o velikosti 1 000 vbytů s poplatkem 10 000 satoshi, tedy
      10 sat/vbyte, s cílem rychlého potvrzení transakce. Mallory přidá
      do transakce 9 000 vbytů dat, která Bob neočekával, což sníží
      jednotkový poplatek na 1 sat/vbyte. I když Bob platí v obou
      případech stejnou absolutní částku, nedostane, co chtěl (rychlou
      konfirmaci), a Mallory mohl přidat data v hodnotě 9 000 sat, aniž
      by ho to stálo cokoliv navíc.

    - *Mallory zpomaluje konfirmaci:* transakce s nižším jednotkovým
      poplatkem může být potvrzena pomaleji. V časově citlivých protokolech
      to může pro Boba znamenat vážný problém. V jiných případech
      by mohl Bob poplatek navýšit, což by ho stálo dodatečné prostředky.

  Kogman ve svém příspěvku popisuje několik opatření, avšak všechny vyžadují
  nějaký kompromis. Ve svém [druhém příspěvku][kogman dilution2] poznamenává,
  že neví o žádném v současnosti zavedeném zranitelném protokolu.

- **Poddajnost tapscriptových podpisů:** během diskuze zmíněné výše
  [poznamenal][o'connor tsm] vývojář Russell O'Connor, že podpisy pro
  [tapscript][topic tapscript] mohou být aplikovány na tapscript
  umístěný jinde v taprootovém stromu. Například totožný tapscript *A*
  se ve stromu objevuje na dvou různých místech. Použití hlubší
  alternativy by vyžadovalo přidání dodatečného 32bytového hashe do
  witnessu utrácející transakce.

    ```text
      *
     / \
    A   *
       / \
      A   B
    ```

   Znamená to, že i kdyby Mallory poskytl Bobovi platný witness pro svou
   tapscriptovou transakci před tím, než by Bob poskytl svůj podpis, mohl by
   Mallory stále odeslat alternativní verzi transakce s větším witnessem.
   Bob by tomu mohl zabránit, kdyby od Malloryho obdržel kopii kompletního
   stromu tapscriptů.

   V kontextu budoucích soft forků bitcoinu otevřel Anthony Towns [pull
   request][bitcoin inquisition #19] v repozitáři Bitcoin Inquisition
   používaném pro testování [SIGHASH_ANYPREVOUT][topic sighash_anyprevout]
   (APO). APO by tak měl k zamezení tohoto problému používat dodatečná data.

## Změny ve službách a klientech

*V této měsíční rubrice upozorňujeme na zajímavé aktualizace bitcoinových
peněženek a služeb.*

- **Peněženka Liana přidává multisig:**
  [Vydání verze 0.2][liana 0.2] peněženky [Liana][news234 liana] přidává podporu pro
  vícenásobné podpisy s použitím [deskriptorů][topic descriptors].

- **Vydána peněženka Sparrow 1.7.2:**
  [Vydání 1.7.2][sparrow 1.7.2] peněženky Sparrow přidává podporu pro [taproot][topic
  taproot], export a import podle [BIP329][] (viz [zpravodaj č. 235][news235
  bip329]) a dodatečnou podporu pro hardwarová podpisová zařízení.

- **Knihovna Bitcoinex přidává podporu pro schnorr:**
  [Bitcoinex][bitcoinex github] je knihovna pro funkcionální programovací jazyk Elixir.

- **Vydána Libwally 0.8.8:**
  [Libwally 0.8.8][] přidává podporu pro tagované hashe podle [BIP340][], podporu
  pro další sighash včetně [BIP118][] ([SIGHASH_ANYPREVOUT][topic SIGHASH_ANYPREVOUT])
  a nové funkce pro [miniscript][topic miniscript], deskriptory a [PSBT][topic psbt].

## Optech doporučuje

[BitcoinSearch.xyz][] je nedávno uvolněný vyhledávač v rámci bitcoinové
technické dokumentace a diskuzí. Byl použit během psaní tohoto zpravodaje
pro rychlé nalezení několika zdrojů, což značí obrovské zlepšení oproti
jiným, pracnějším metodám, které jsme dříve používali. Vítány jsou
příspěvky do jeho [vývoje][bitcoinsearch repos].

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Core Lightning 23.02rc2][] je kandidát na vydání údržbové verze této
  oblíbené implementace LN.

- [BTCPay Server 1.7.11][] je nové vydání. Od posledního vydání, o kterém
  jsme informovali (1.7.1), bylo přidáno několik novinek, oprav chyb
  a vylepšení. Za pozornost zvláště stojí změna systému pluginů a
  integrace služeb třetích stran. Dále byla přidána možnost migrovat
  mimo MySQL a SQLite.

- [BDK 0.27.0][] je aktualizace této knihovny pro tvorbu bitcoinových peněženek
  a aplikací.

## Významné změny v kódu a dokumentaci

*Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo] a [Lightning BOLTs][bolts repo].*

- [Core Lightning #5361][] přidává experimentální podporu pro ukládání
  záloh pro svá spojení. Jak bylo naposledy zmíněno ve [zpravodaji č. 147][news147
  backups] (*angl.*), toto umožňuje, aby uzel ukládal malé zašifrované
  zálohy pro svá spojení. Pokud se spojení později potřebuje znovu
  připojit nebo ztratí-li data, může o zálohu požádat. Spojení může
  pro dešifrování použít klíč derivovaný ze své peněženky a obnovit
  se podle posledního stavu svých kanálů. Může to být považováno za
  vylepšenou formu [statických záloh kanálu][topic static channel backups].
  Toto PR přidává podporu pro vytváření, ukládání a stahování zašifrovaných
  záloh. Jak je poznamenáno v commitech, tato schopnost nebyla ještě plně
  specifikována ani převzata jinými implementacemi LN.

- [Core Lightning #5670][] a [#5956][core lightning #5956] přináší několik
  aktualizací své implementace [duálního financování][topic dual funding]
  založených na nedávných změnách [specifikace][bolts #851] a výsledcích
  testů interoperability. Dále bylo přidáno RPC volán `upgradewallet`,
  které přesune všechny prostředky v P2SH výstupech na nativní
  segwit výstupy, které jsou vyžadovány pro interaktivní otevírání
  kanálů.

- [Core Lightning #5697][] přidává RPC volání `signinvoice` pro podepisování
  [BOLT11][] faktur. Dříve podepisovalo CLN faktury pouze, pokud mělo
  k dispozici předobraz [HTLC][topic HTLC] hashe, aby později mohlo platbu
  nárokovat. Toto volání může podobné chování přepsat, což by mohlo být
  například použito k okamžitému odeslání faktury a pozdějšímu obdržení
  předobrazu z jiného programu. Uživatelé tohoto RPC volání by měli
  mít na paměti, že kdokoliv se znalostí předobrazu by mohl platbu nárokovat.
  To by znamenalo ne jen krádež prostředků, ale také poskytnutí
  přesvědčivého svědectví o proběhlé platbě (toto svědectví je natolik silné,
  že jej mnoho vývojářů nazývá *důkazem platby*).

- [Core Lightning #5960][] přidává [bezpečnostní pravidlo][cln security.md]
  s kontaktními adresami a PGP klíči.

- [LND #7171][] vylepšuje RPC volání `signrpc` o podporu posledního
  [návrhu BIP][musig draft bip] pro [MuSig2][topic musig]. Volání
  nově vytváří sezení spojené s číslem verze MuSig2 protokolu,
  aby všechny operace v rámci sezení používaly správný protokol. Bezpečnostní
  problém starších verzí MuSig2 protokolu byl zmíněn ve [zpravodaji č. 222][news222
  musig2] (*angl.*).

- [LDK #2022][] přidává podporu pro automatické opětovné poslání neúspěšných
  [spontánních plateb][topic spontaneous payments].

- [BTCPay Server #4600][] aktualizuje [výběr mincí][topic coin selection] své
  implementace [payjoinu][topic payjoin]. Nově se algoritmus pokusí vyvarovat
  vytváření transakcí s *nadbytečnými vstupy*, konkrétně vstupy, které jsou
  větší než jakýkoliv výstup u transakcí s více vstupy. Taková situace by
  u běžné platby s jedním odesílatelem a jedním příjemcem nenastala: největší
  vstup by byl schopen poskytnout platební výstup a další vstupy by tak
  nebyly potřeba. Tato změna byla částečně inspirována [analýzou payjoinů][paper
  analyzing payjoins].

{% include references.md %}
{% include linkers/issues.md v=2 issues="5361,5670,5956,851,5697,5960,7171,2022,4541,4600" %}
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
[news234 liana]: /cs/newsletters/2023/01/18/#vydana-penezenka-liana
[liana 0.2]: https://github.com/wizardsardine/liana/releases/tag/0.2
[sparrow 1.7.2]: https://github.com/sparrowwallet/sparrow/releases/tag/1.7.2
[news235 bip329]: /cs/newsletters/2023/01/25/#bips-1383
[bitcoinex github]: https://github.com/RiverFinancial/bitcoinex
[libwally 0.8.8]: https://github.com/ElementsProject/libwally-core/releases/tag/release_0.8.8
