---
title: 'Zpravodaj „Bitcoin Optech” č. 305'
permalink: /cs/newsletters/2024/05/31/
name: 2024-05-31-newsletter-cs
slug: 2024-05-31-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden popisuje návrh protokolu pro používání tichých plateb
lehkými klienty, shrnuje návrhy dvou deskriptorů pro taproot a odkazuje
na diskuzi o tom, zda by měly být soft forkem přidávány opkódy s překrývajícími
se schopnostmi. Též nechybí naše pravidelné rubriky s populárními otázkami
a odpověďmi z Bitcoin Stack Exchange, oznámeními nových vydání a souhrnem
významných změn v populárním bitcoinovém páteřním software.

## Novinky

- **Protokol pro tiché platby v lehkých klientech:** Setor Blagogee
  zaslal do fóra Delving Bitcoin [příspěvek][blagogee lcsp] s popisem návrhu
  specifikace protokolu, který by umožnil lehkým klientům přijímat
  [tiché platby][topic silent payments] (SP). Přidání několika kryptografických
  primitiv postačuje k rozšíření možností peněženek o odesílání SP, ale
  kromě těchto primitiv vyžaduje přijímání SP přístup k informacím o každé
  onchain transakci kompatibilní s SP. Pro plné uzly jako Bitcoin Core je to
  snadný úkol, neboť již zpracovávají každou onchain transakci, avšak na lehké
  klienty, které se snaží minimalizovat množství vyžadovaných dat, to klade nové požadavky.

  V základním protokolu generuje nějaký poskytovatel služby pro každý blok
  index veřejných klíčů, které mohou být použity s tichými platbami. Klient
  tento index stáhne spolu s [kompaktními filtry bloků][topic compact block filters]
  stejného bloku. Klient pro každý z klíčů (nebo sadu klíčů) spočítá svůj tweak
  a určí, zda filtr bloků obsahuje platbu na korespondující tweaknutý klíč.
  Pokud ano, klient stáhne dodatečná data, která mu umožní určit výši přijaté
  částky a později tuto platbu utratit.

- **Nezpracované taprootové deskriptory:** Oghenovo Usiwoma zaslal do fóra Delving Bitcoin
  [příspěvek][usiwoma descriptors] s návrhem dvou nových [deskriptorů][topic
  descriptors] pro konstruování [taprootových][topic taproot] platebních podmínek:

  - `rawnode(<hash>)` obsahuje haš uzlu Merkleova stromu, ať již vnitřního uzlu
    či listu. To umožní peněžence či jinému skenovacímu programu nalézt konkrétní
    výstupní skripty bez nutnosti přesně znát, jaké tapscripty obsahují. Ve většině
    případů se nejedná o bezpečný způsob přijímání peněz (neznámý skript může
    být neutratitelný nebo může umožnit třetí straně prostředky utratit), avšak
    mohou existovat protokoly, kde je takové použití bezpečné.

    Anthony Towns poskytl [příklad][towns descriptors], ve kterém Alice chce,
    aby mohl Bob zdědit její peníze. Za své učiněné platby poskytne Alice Bobovi pouze
    nezpracované haše uzlů. Pro Bobovo dědictví poskytne Alice Bobovi šablonu
    deskriptoru (obsahující například časový zámek, aby nemohl Bob prostředky utratit
    před vypršením nějaké doby). Tento způsob je pro Boba bezpečný, neboť peníze
    nejsou jeho, a je výhodný pro Alicino soukromí, neboť nemusí Bobovi dopředu odhalit
    žádnou ze svých platebních podmínek (ačkoliv se o nich může Bob dozvědět z Aliciných
    onchain transakcí).

  - `rawleaf(<script>,[version])` je podobný existujícímu deskriptoru `raw` pro začlenění
    skriptů, které nemohou být vyjádřeny šablonou deskriptoru. Hlavním rozdílem je,
    že obsahuje možnost určit odlišnou verzi taprootového listu, než která je v [BIP342][]
    specifikována jako výchozí verze pro [tapscript][topic tapscript].

  Usiwomaův příspěvek poskytuje příklad a odkazuje na předchozí diskuzi a svou [referenční
  implementaci][usiwoma poc].

- **Měly by se překrývající se návrhy na soft forky vzájemně vylučovat?**
  Pierre Rochard [se ptá][rochard exclusive], zda by navrhované soft forky, které by
  poskytovaly podobné funkce s podobnými náklady, měly být považovány za vzájemně
  se vylučující, nebo zda by mělo smysl aktivovat více návrhů a nechat vývojáře,
  ať si vyberou své preferované alternativy.

  Anthony Towns [reagoval][towns exclusive] na několik bodů. Mimo jiné se domnívá,
  že překrývající se funkce nejsou samy o sobě problematické, avšak problémy mohou přinést
  funkce, které nejsou vůbec používané, protože každý preferuje nějakou jinou alternativu.
  Navrhuje, aby kdokoliv, kdo upřednostňuje nějaký konkrétní návrh, otestoval jeho funkce
  v předprodukčním software, ať se s ním náležitě seznámí, obzvláště v porovnání
  s alternativami nabízejícími podobné funkce.

## Vybrané otázky a odpovědi z Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] je jedním z prvních míst, kde hledají
přispěvatelé Optechu odpovědi na své otázky a kde – najdou-li volnou chvíli –
pomáhají zvědavým či zmateným uživatelům. V této měsíční rubrice nabízíme
některé z otázek a odpovědí, které obdržely vysoký počet hlasů.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aa
nswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Jaká je nejmenší možná coinbasová transakce / velikost bloku?]({{bse}}122951)
  Antoine Poinsot objasňuje minima kolem coinbasové transakce a uzavírá tvrzením,
  že nejmenší možný validní bitcoinový blok v současných výškách má 145 bajtů.

- [Jak rozumět kódování čísel Scriptu a CScriptNum?]({{bse}}122939)
  Antoine Poinsot popisuje, jakým způsobem CScriptNum reprezentuje celá čísla
  v bitcoinovém Scriptu, poskytuje příklady kódování a odkazuje na dvě implementace
  serializace.

- [Je možné zveřejnit adresu BTC peněženky, ale neodhalit, kolik BTC obsahuje?]({{bse}}122786)
  Vojtěch Strnad vysvětluje, že opakovaně použitelné adresy [tichých plateb][topic
  silent payments] umožňují publikování platebního identifikátoru bez možnosti
  určit, které transakce na něj posílají prostředky.

- [Testování vysokých poplatků na regtestu]({{bse}}122837)
  Ava Chow doporučuje pro testování v simulovaném prostředí s vysokými poplatky na regtestu
  používat testovací framework Bitcoin Core a nastavit `-maxmempool` na nízkou hodnotu
  a `-datacarriersize` na vysokou hodnotu.

- [Proč je můj P2P V2 peer připojen přes v1?]({{bse}}122774)
  Pieter Wuille se domnívá, že za případem, kdy byl peer podporující [šifrovaný
  transport][topic v2 p2p transport] dle BIP324 připojen přes v1 nešifrované spojení,
  stály zastaralé informace o adrese.

- [Posílá P2PKH transakce na haš komprimovaného nebo nekomprimovaného klíče?]({{bse}}122875)
  Pieter Wuille poznamenává, že použity mohou být komprimované i nekomprimované veřejné klíče
  s rozdílnými výslednými P2PKH adresami, a dodává, že P2WPKH dle pravidel povolují pouze
  komprimované veřejné klíče a P2TR používá [x-only veřejné klíče][topic X-only public keys].

- [Jaké existují způsoby zveřejnění bloku v bitcoinové síti?]({{bse}}122953)
  Pieter Wuille vypisuje čtyři způsoby oznamování bloků v P2P síti: pomocí [BIP130][],
  pomocí [BIP152][], posláním [nevyžádané zprávy `block`][unsolicited `block` messages]
  a starší kombinací zpráv `inv` / `getdata` / `block`.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [LND v0.18.0-beta][] je nejnovějším hlavním vydáním této populární implementace
  LN uzlu. Dle [poznámek k vydání][lnd rn] byla přidána experimentální podpora
  pro _příchozí poplatky za přeposlání_ (viz [zpravodaj č. 297][news297 inbound]),
  bylo zpřístupněno hledání tras pro [zaslepené cesty][topic rv routing],
  [strážní věže][topic watchtowers] nově podporují [jednoduché taprootové kanály][topic
  simple taproot channels], bylo zjednodušeno sdílení zašifrovaných informací pro ladění
  (viz [zpravodaj č. 285][news285 encdebug]) a přidáno bylo mnoho dalších nových funkcí.
  Vydání též přináší mnoho oprav chyb.

- [Core Lightning 24.05rc2][] je kandidátem na vydání příští hlavní verze této populární
  implementace LN uzlu.

## Významné změny kódu a dokumentace

_Významné změny z tohoto týdne v [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo] a [repozitáři BINANA][binana
repo]._

- [Bitcoin Core #29612][] upravuje formát exportované serializované sady UTXO
  vytvořené pomocí RPC volání `dumptxoutset`. Výsledkem je o 17,4 % nižší
  použitý prostor. RPC volání `loadtxoutset` nyní během načítání ze souboru
  očekává tento nový formát, starý formát již není podporován. Zpravodaje
  [č. 178][news178 txoutset] a [č. 72][news72 txoutset] (oba _angl._) též
  odkazují na `dumptxoutset`.

- [Bitcoin Core #27064][] mění na Windows u čerstvých instalací výchozí složku pro data
  z `C:\Users\Username\AppData\Roaming\Bitcoin` na `C:\Users\Username\AppData\Local\Bitcoin`.

- [Bitcoin Core #29873][] přináší váhový limit o hodnotě 10 kvB na transakce
  [do potvrzení topologicky omezené][topic v3 transaction relay] (Topologically
  Restricted Until Confirmation, TRUC; též „v3 transakce”). Tento limit
  snižuje potenciální náklady na obranu před [pinningem transakcí][topic transaction
  pinning], navyšuje efektivitu konstrukce šablon bloků a vynucuje přísnější limity
  na některé datové struktury. V3 transakce jsou podmnožinou standardních transakcí
  s dodatečnými pravidly navrženými tak, aby umožnily nahrazování transakcí a zároveň
  minimalizovaly náklady na překonání pinningových útoků. Více informací o v3 transakcích
  lze nalézt ve zpravodajích [č. 289][news289 v3] a [č. 296][news296 v3].

- [Bitcoin Core #30062][] přidává do RPC volání `getrawaddrman` dvě nová pole
  `mapped_as` a `source_mapped_as`. Tento příkaz vrací informace o síťových adresách
  uzlů spojení. Nová pole vrátí Autonomous System Number (ASN) namapované na spojení
  a jeho zdroj a tím poskytnou přibližné informace o tom, která ISP kontrolují které
  IP adresy. To navýší odolnost Bitcoin Core vůči [útokům zastíněním][topic eclipse
  attacks]. Viz též zpravodaje [č. 52][news52 asmap], [č. 83][news83 asmap],
  [č. 101][news101 asmap] (vše _angl._) a [č. 290][news290 asmap].

- [Bitcoin Core #26606][] přináší `BerkeleyRODatabase`, nezávislou implementaci
  parseru souborů Berkeley Database (BDB), která přináší podporu pro čtení BDB
  souborů. Data zastaralých peněženek tak mohou být extrahována bez závislosti na
  těžkotonážní BDB knihovně, čímž se usnadní migrace na [deskriptorové][topic descriptors]
  peněženky. Příkaz `dump` nástroje `wallettool` byl změněn, aby používal `BerkeleyRODatabase`.

- [BOLTs #1092][] pročišťuje specifikace Lightning Network odstraněním nepoužívaných či dlouho
  nepodporovaných schopností `initial_routing_sync` a `option_anchor_outputs`. Předpokládá
  se, že tři schopnosti jsou podporovány každým uzlem: `var_onion_optin` pro [onion zprávy][topic
  onion messages] s proměnlivou velikostí pro posílání libovolných dat konkrétním uzlům,
  `option_data_loss_protect`, aby mohly uzly během opakovaného připojení poslat informace
  o posledním stavu kanálu, a `option_static_remotekey` umožňující uzlu požadovat, aby se každá
  aktualizace kanálu zavázala poslat ne-[HTLC][topic htlc] prostředky uzlu na stejnou adresu.
  Schopnost `gossip_queries` byla pozměněna tak, aby uzel bez její podpory nebyl na konkrétní
  gossip požadavky dotazován jinými uzly. Viz též [zpravodaj č. 259][news259 cleanup].

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when="2024-06-04 14:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29612,27064,29873,30062,26606,1092" %}
[lnd v0.18.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.0-beta
[blagogee lcsp]: https://delvingbitcoin.org/t/silent-payments-light-client-protocol/891/
[usiwoma descriptors]: https://delvingbitcoin.org/t/tr-rawnode-and-rawleaf-support/901/
[towns descriptors]: https://delvingbitcoin.org/t/tr-rawnode-and-rawleaf-support/901/6
[usiwoma poc]: https://github.com/Eunovo/bitcoin/tree/wip-tr-raw-nodes
[rochard exclusive]:  https://delvingbitcoin.org/t/mutual-exclusiveness-of-op-codes/890/3
[towns exclusive]: https://delvingbitcoin.org/t/mutual-exclusiveness-of-op-codes/890/3
[news72 txoutset]: /en/newsletters/2019/11/13/#bitcoin-core-16899
[news178 txoutset]: /en/newsletters/2021/12/08/#bitcoin-core-23155
[news289 v3]: /cs/newsletters/2024/02/14/#bitcoin-core-28948
[news296 v3]: /cs/newsletters/2024/04/03/#bitcoin-core-29242
[news52 asmap]: /en/newsletters/2019/06/26/#differentiating-peers-based-on-asn-instead-of-address-prefix
[news83 asmap]: /en/newsletters/2020/02/05/#bitcoin-core-16702
[news101 asmap]: /en/newsletters/2020/06/10/#bitcoin-core-0-20-0
[news290 asmap]: /cs/newsletters/2024/02/21/#vylepseny-proces-opakovatelneho-sestavovani-asmap
[news259 cleanup]:/cs/newsletters/2023/07/12/#navrh-na-procisteni-specifikace-ln
[unsolicited `block` messages]: https://developer.bitcoin.org/devguide/p2p_network.html#block-broadcasting
[lnd rn]: https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/release-notes-0.18.0.md
[core lightning 24.05rc2]: https://github.com/ElementsProject/lightning/releases/tag/v24.05rc2
[news297 inbound]: /cs/newsletters/2024/04/10/#lnd-6703
[news285 encdebug]: /cs/newsletters/2024/01/17/#lnd-8188
