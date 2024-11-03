---
title: 'Zpravodaj „Bitcoin Optech” č. 317'
permalink: /cs/newsletters/2024/08/23/
name: 2024-08-23-newsletter-cs
slug: 2024-08-23-newsletter-cs
type: newsletter
layout: newsletter
lang: cs
---
Zpravodaj tento týden přináší souhrn diskuze o proti-exfiltračnímu
protokolu, který vyžaduje pouze jedno kolo komunikace mezi peněženkou a
podpisovým zařízením. Též nechybí naše pravidelné rubriky s popisem
změn v klientech a službách, oznámeními nových vydání a souhrnem
nedávných změn v populárním bitcoinovém páteřním software.

## Novinky

- **Jednoduchý (ale nedokonalý) proti-exfiltrační protokol:** vývojář
  Moonsettler zaslal do fóra Delving Bitcoin [příspěvek][moonsettler
  exfil1] s popisem [proti-exfiltračního][topic exfiltration-resistant
  signing] protokolu. Shodný protokol byl již dříve popsán (viz zpravodaje
  [č. 87][news87 exfil] a [č. 88][news88 exfil], oba _angl._),
  Pieter Wuille [odkázal][wuille exfil1] na první známý popis této
  techniky uvedený v [příspěvku][maxwell exfil] Gregoryho Maxwella z roku 2014.

  Protokol používá sign-to-contract, který umožňuje softwarové peněžence
  přispět entropií do nonce vybraného hardwarovým podpisovým zařízením
  způsobem, který později softwarové peněžence umožní ověřit, zda tato
  entropie byla použita. Sign-to-contract je variantou [pay-to-contract][topic
  p2c]: u pay-to-contract je tweaknutý veřejný klíč příjemce, u
  sign-to-contract je tweaknutý nonce podpisu plátce.

  Výhodou tohoto protokolu v porovnání s protokolem implementovaným
  v hardwarových podpisových zařízeních BitBox02 a Jade (viz [zpravodaj
  č. 136][news136 exfil], _angl._) je potřeba pouze jediného kola
  komunikace mezi softwarovou peněženkou a hardwarovým podpisovým
  zařízením. Toto jedno kolo může být zkombinováno s jinými procesy
  potřebnými pro podepsání transakce, na obvyklé postupy uživatelů tak
  tato technika nemá žádný dopad. Aktuálně nasazená technika, která je
  též založená na sign-to-contract, vyžaduje dvě kola komunikace.
  To je více, než kolik dnes většina uživatelů vyžaduje, ačkoliv více
  kol komunikace může být vyžadováno pro uživatele, kteří upgradují
  na [bezskriptové vícenásobné podpisy][topic multisignature] a
  [bezskriptové prahové podpisy][topic threshold signature]. Pro uživatele,
  kteří připojují svá podpisová zařízení k počítačům přímo či pomocí
  bezdrátových protokolů jako Bluetooth, počet kol komunikace nehraje
  roli. Avšak pro uživatele, kteří zařízení připojovat nechtějí, znamená
  každé další kolo dva ruční zásahy. To se může rychle proměnit v nepříjemné
  množství práce, pokud podepisují často nebo používají více zařízení
  pro skriptové vícenásobné podpisy.

  Nevýhodu tohoto protokolu zmínil Maxwell ve svém původním popisu:
  „ponechává otevřený [postranní kanál][topic side channels], který
  má exponenciální náklady za každý další bit, použitím obrušování
  (grinding)[…], ale odstraňuje zjevné a hodně účinné útoky, kde všechno
  unikne v jediném podpisu. Je to jistě méně dobré, ale jedná se pouze
  o dvoukolový protokol, takže hodně míst, která by nad protiopatřeními
  neuvažovala, by mohla tohle bez práce převzít jako jeden bod ve specifikaci
  protokolu.”

  Použití tohoto protokolu má jasné výhody oproti nepoužívání žádné anti-exfiltrace.
  Pieter Wuille dále [poznamenává][wuille exfil2], že se možná jedná o nejlepší
  možnou anti-exfiltraci s jedním kolem podepisování. Avšak Wuille
  obhajuje nasazený dvoukolový proti-exfiltrační protokol, který umí
  zabránit i exfiltraci založené na obrušování.

  Diskuze v době psaní nadále probíhá.

## Změny ve službách a klientech

*V této měsíční rubrice upozorňujeme na zajímavé aktualizace bitcoinových
peněženek a služeb.*

- **Ohlášena Proton Wallet:**
  Proton [ohlásil][proton blog] svou [open-source][proton github] Proton
  Wallet s podporou více peněženek, [bech32][topic bech32], [dávkových][topic
  payment batching] plateb, [BIP39][] frází a s integrací svého emailu.

- **Ohlášen testnet CPUNet:**
  Přispěvatel z [braidpool][braidpool github], implementace [těžebního poolu][topic
  pooled mining], ohlásil testovací síť [CPUNet][cpunet github].
  Uživatelé CPUNet používají modifikovaný proof of work, který
  vylučuje těžaře s ASIC. Záměrem je dosáhnout konzistentnější míry tvorby bloků,
  než je pro [testnet][topic testnet] typické.

- **Spuštěn Lightning.Pub:**
  [Lightning.Pub][lightningpub github] poskytuje správu LND uzlu, která umožňuje
  sdílený přístup a koordinaci likvidity kanálů. Pro šifrovanou komunikaci
  a identity založené na klíčích používá nostr.

- **Vydán Taproot Assets v0.4.0-alpha:**
  Vydání [v0.4.0-alpha][taproot assets v0.4.0] podporuje protokol [Taproot
  Assets][topic client-side validation] na mainnetu, kde umí vydávat onchain
  aktiva a provádět atomické směny pomocí [PSBT][topic psbt], a posílání
  aktiv přes Lightning Network.

- **Vydán nástroj pro měření výkonnosti Stratum v2:**
  První [vydání 0.1.0][sbm 0.1.0] podporuje testování, reportování a porovnávání
  výkonu mezi protokoly Stratum v1 a Stratum v2 v různých scénářích.

- **Ověření konceptu STARK verifikací na signetu:**
  StarkWare [ohlásil][starkware tweet] [STARK verifier][bcs github]
  ověřující důkazy s nulovou znalostí na testovací síti [signet][topic signet]
  pomocí opkódu [OP_CAT][topic op_cat] (viz [zpravodaj č. 304][news304 inquisition]).

- **Vydán SeedSigner 0.8.0:**
  Bitcoinové hardwarové podpisové zařízení [SeedSigner][seedsigner website] přidalo
  ve vydání [0.8.0][seedsigner 0.8.0] podepisování P2PKH a P2SH multisig, rozšířilo
  podporu [PSBT][topic psbt] a aktivovalo podporu [taprootu][topic taproot] ve
  výchozím nastavení.

- **Vydána Floresta 0.6.0:**
  Ve vydání [0.6.0][floresta 0.6.0] přidává Floresta podporu pro [filtry kompaktních
  bloků][topic compact block filters], doklady o podvodu na signetu a [`florestad`][floresta
  blog], démon pro integraci existujících peněženek a klientských aplikací.

## Vydání nových verzí

*Vydání nových verzí oblíbených páteřních bitcoinových projektů. Prosíme,
zvažte upgrade či pomoc s testováním.*

- [Core Lightning 24.08rc2][] je kandidátem na vydání další hlavní verze této
  populární implementace LN uzlu.

- [LND v0.18.3-beta.rc1][] je kandidátem na menší opravné vydání této oblíbené
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

- [Bitcoin Core #28553][] přidává parametry mainnetového bloku 840 000
  do [assumeUTXO][topic assumeutxo] snapshotu: haš bloku, počet transakcí
  až po tento blok a SHA256 haš serializované množiny UTXO až po tento
  blok. Několik přispěvatelů testováním potvrdilo, že dosáhli stejného
  [souboru snapshotu][snapshot file] s očekávaným kontrolním součtem
  a že tento snapshot bylo možné načíst.

- [Bitcoin Core #30246][] přidává do nástroje `asmap-tool` podpříkaz
  `diff_addrs`, který uživatelům umožní porovnat dvě mapy [autonomních
  systémů][auto sys] (ASMap) a spočítat statistky o adresách uzlů,
  které byly přiřazeny do jiných čísel autonomních systémů (Autonomous
  System Number, ASN). Tato funkce měří degradaci ASMap během času, což
  je důležitým krokem na cestě k přibalení předem spočítaných ASMap do
  vydání Bitcoin Core. Účelem je zvýšení odolnosti vůči [útokům
  zastíněním][topic eclipse attacks]. Viz též [zpravodaj č. 290][news290
  asmap].

- [Bitcoin Core GUI #824][] mění položku menu `Migrate Wallet` na podmenu,
  což uživatelům umožní migrovat kteroukoliv zastaralou peněženku v adresáři,
  včetně takových, které již není možné načíst. Tato změna je přípravou
  na možnou budoucnost, kdy budou používány pouze [deskriptorové][topic
  descriptors] peněženky a staré typy peněženek nebude možné načíst.
  Po zvolení peněženky k migraci se GUI zeptá uživatele na případné heslo.

- [Core Lightning #7540][] vylepšuje vzorec, kterým se počítá pravděpodobnost
  úspěšného nalezení cesty v `renepay` pluginu (viz [zpravodaj č. 263][news263
  renepay]). Přidává konstantní multiplikátor reprezentující pravděpodobnost,
  že náhodně zvolený kanál v síti je schopen přeposlat nejméně 1 msat. Výchozí
  hodnota je nastavena na 0,98, může se však v budoucnosti změnit.

- [Core Lightning #7403][] přidává do pluginu `renepay` filtr, který ignoruje
  kanály s velmi nízkým `max_htlc`. V budoucnosti může být filtr rozšířen
  o další parametry: vysoký poplatek, nízká kapacita, vysoká latence. Uzly
  či kanály mohou být manuálně vyloučeny volbou `exclude`.

- [LND #8943][] přidává do kódu [Alloy][alloy model] modely, počínaje modelem
  pro [Linear Fee Function][lnd linear] pro navyšování poplatků (inspirováno
  opravou chyby v [LND #8751][]). Alloy poskytuje lehkotonážní formální metodu
  pro ověřování správnosti systémových komponent, což během implementace
  pomáhá hledat chyby. Narozdíl od plnohodnotných formálních metod, které se snaží
  dokázat, že je model vždy správný, operuje Alloy nad vstupem množiny
  omezených parametrů a iterací a snaží se najít protipříklady danému tvrzení.
  Modely mohou být též použity pro specifikaci protokolů v P2P systémech, což
  je pro Lightning Network zvláště vhodné.

- [BDK #1478][] přináší několik změn do struktur `FullScanRequest` a `SyncRequest`
  v `bdk_chain`: přináší builder vzor, mění pole `chain_tip` na volitelné
  (uživatelé tak nemusí být informováni o změnách `LocalChain`, což je užitečné
  pro používání `bdk_esplora`) a zlepšuje ergonomii sledování postupu synchronizace.
  Dále `bdk_esplora` automaticky přidává do `TxGraph` předchozí výstupy.

- [BDK #1533][] umožňuje pomocí `Wallet::create_single` vytvářet peněženky
  s jediným [deskriptorem][topic descriptors]. Tato změna revertuje předchozí
  update, kterým struktura `Wallet` vyžadovala přítomnost interního deskriptoru
  pro zbytky. Důvodem předchozí změny byla ochrana soukromí adres pro zbytky
  během používání veřejných Electrum či Esplora serverů, avšak nyní převážila
  potřeba podporovat více případu použití.

- [BOLTs #1182][] zlepšuje srozumitelnost a úplnost částí specifikace [BOLT4][]
  věnujících se [zaslepování cest][topic rv routing] a [onion zprávám][topic onion
  messages]: přesouvá sekci o zaslepování cest o jednu úroveň výše (aby bylo zřejmé,
  že se týká i plateb a ne jen onion zpráv), poskytuje konkrétnější detaily
  o datovém typu `blinded_path` a jeho požadavcích, rozšiřuje popis zodpovědností,
  rozděluje sekci příjemce na `blinded_path` a `encrypted_recipient_data`,
  zlepšuje vysvětlení konceptu `blinded_path`, přidává doporučení pro používání
  falešného skoku, přejmenovává `onionmsg_hop` na `blinded_path_hop` a další.

- [BLIPs #39][] přidává [BLIP39][] specifikující volitelné pole `b` v [BOLT11][]
  fakturách, které určuje [zaslepenou cestu][topic rv routing] pro platbu.
  LND již toto pole implementuje (viz [zpravodaj č. 315][news315 blinded]).
  Záměrem je toto pole používat, dokud se protokolu [nabídek][topic offers]
  nedostane širokého nasazení.

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28553,30246,824,7540,7403,8943,1478,1533,1182,39,8751" %}
[Core Lightning 24.08rc2]: https://github.com/ElementsProject/lightning/releases/tag/v24.08rc2
[LND v0.18.3-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.3-beta.rc1
[moonsettler exfil1]: https://delvingbitcoin.org/t/non-interactive-anti-exfil-airgap-compatible/1081
[wuille exfil1]: https://delvingbitcoin.org/t/non-interactive-anti-exfil-airgap-compatible/1081/3
[wuille exfil2]: https://delvingbitcoin.org/t/non-interactive-anti-exfil-airgap-compatible/1081/7
[news87 exfil]: /en/newsletters/2020/03/04/#proposal-to-standardize-an-exfiltration-resistant-nonce-protocol
[news88 exfil]: /en/newsletters/2020/03/11/#exfiltration-resistant-nonce-protocols
[maxwell exfil]: https://bitcointalk.org/index.php?topic=893898.msg9861102#msg9861102
[news136 exfil]: /en/newsletters/2021/02/17/#anti-exfiltration
[proton blog]: https://proton.me/blog/proton-wallet-launch
[proton github]: https://github.com/protonwallet/
[braidpool github]: https://github.com/braidpool/braidpool
[cpunet post]: https://x.com/BobMcElrath/status/1823370268728873411
[cpunet github]: https://github.com/braidpool/bitcoin/blob/cpunet/contrib/cpunet/README.md
[lightningpub github]: https://github.com/shocknet/Lightning.Pub
[taproot assets v0.4.0]: https://github.com/lightninglabs/taproot-assets/releases/tag/v0.4.0
[sbm 0.1.0]: https://github.com/stratum-mining/benchmarking-tool/releases/tag/0.1.0
[starkware tweet]: https://x.com/StarkWareLtd/status/1813929304209723700
[bcs github]: https://github.com/Bitcoin-Wildlife-Sanctuary/bitcoin-circle-stark
[news304 inquisition]: /cs/newsletters/2024/05/24/#bitcoin-inquisition-27-0
[seedsigner website]: https://seedsigner.com/
[seedsigner 0.8.0]: https://github.com/SeedSigner/seedsigner/releases/tag/0.8.0
[floresta 0.6.0]: https://github.com/vinteumorg/Floresta/releases/tag/0.6.0
[floresta blog]: https://medium.com/vinteum-org/floresta-update-simplifying-bitcoin-node-integration-for-wallets-6886ea7c975c
[auto sys]: https://cs.wikipedia.org/wiki/Autonomn%C3%AD_syst%C3%A9m
[news290 asmap]: /cs/newsletters/2024/02/21/#vylepseny-proces-opakovatelneho-sestavovani-asmap
[news263 renepay]: /cs/newsletters/2023/08/09/#core-lightning-6376
[alloy model]: https://alloytools.org/about.html
[lnd linear]: https://github.com/lightningnetwork/lnd/blob/b7c59b36a74975c4e710a02ea42959053735402e/sweep/fee_function.go#L66-L109
[news315 blinded]: /cs/newsletters/2024/08/09/#lnd-8735
[snapshot file]: magnet:?xt=urn:btih:596c26cc709e213fdfec997183ff67067241440c&dn=utxo-840000.dat&tr=udp%3A%2F%2Ftracker.bitcoin.sprovoost.nl%3A6969
