<!--
  300 to 1000 words
  put title in main newsletter
  put links in this file
  for any subheads use h3 (i.e., ###)
  illustrations welcome (max width 800px)
  if uncertain about anything, just do what seems best and harding will edit
-->

Množství uzlů v bitcoinové síti ukládá nepotvrzené transakce v memory poolu
(tj. v předem alokovaném znovupoužitelném bloku paměti); odtud „mempool.”
Tato mezipaměť je důležitým zdrojem každého uzlu, který umožňuje
peer-to-peer přeposílání transakcí.

Uzly, které se přeposílání transakcí účastní, stahují a validují bloky
postupně. Uzly bez mempoolu zaznamenávají každých zhruba deset minut
špičku v datovém přenosu následovanou výpočetně náročnou validací
každé transakce. Na druhou stranu uzly s mempoolem již mají pravděpodobně
v mempoolu všechny transakce z bloku uložené. Díky [přeposílání kompaktních
bloků][topic compact block relay] mohou tyto uzly stáhnout pouze hlavičku
bloku spolu se zkrácenými identifikátory a následně blok rekonstruovat
z transakcí v mempoolu.

Množství přenášených dat je v případě používání kompaktních bloků
v porovnání s velikostí celého bloku minimální. Validace transakcí probíhá
rychleji, neboť uzel již ověřil a uchoval elektronické podpisy a skripty,
spočítal požadavky časových zámků a načetl z disku související UTXO.
Tento uzel může také okamžitě přeposlat blok svým spojením a tím dramaticky
zvýšit rychlost propagace bloku. Rychlost rozšiřování bloku po síti
snižuje riziko objevení zastaralých bloků.

Mempooly mohou též sloužit k nezávislému odhadování poplatků. Trh s
prostorem pro bloky je aukcí založenou na poplatcích, mempool tak
dává uživatelům lepší přehled o nabídkách ostatních účastníků a
poskytuje historii nabídek.

Neexistuje však žádný globální, sdílený mempool; každý uzel může přijímat
jiné transakce. Zaslání transakce jednomu uzlu neznamená, že se nakonec
dostane k těžařům. Někteří uživatelé považují tuto nejistotu za
frustrující a táží se, proč nelze transakce zasílat přímo těžařům.

Představme si bitcoinovou síť, ve které jsou všechny transakce posílány
od uživatelů přímo těžařům. Bylo by snadné donutit několik malých subjektů
k logování IP adres odpovídajících jednotlivým transakcím a tím cenzurovat
transakce a sledovat finanční toky. Takový bitcoin by se možná používal
pohodlněji, ale postrádal by některé z nejdůležitějších vlastností.

Soukromí a odolnost vůči cenzuře jsou vlastnosti vycházející z
peer-to-peer sítě. Aby mohly uzly transakce přeposílat, mohou se připojit
k anonymní množině uzlů, z nichž každý by mohl být těžař nebo někdo
k těžařovi připojený. Tento způsob pomáhá zmást stopy k uzlu, od kterého
transakce pochází a který ji potvrdil. Cenzor by mohl cílit na některé
těžaře, populární směnárny či jiné centralizované služby, ale bylo by
náročné blokovat zcela všechno.

Přístup k nepotvrzeným transakcím dále pomáhá minimalizovat vstupní náklady
zahájení produkce bloků: kdokoliv nespokojený s výběrem transakcí (nebo
jejich vylučováním) se může okamžitě stát dalším těžařem. Považovaní všech
uzlů za rovnocenné při zveřejňování transakcí odpírá těžařům výsadní přístup
k transakcím a jejím poplatkům.

Mempool je mimořádně užitečná mezipaměť, která umožňuje uzlům rozložit v čase
náklady na stahování a validaci bloků a která dává uživatelům přístup k
lepšímu odhadování poplatků. Na úrovni sítě podporují mempooly distribuci
transakcí a bloků. Všechny tyto výhody jsou nejvýraznější v případě, kdy
každý vidí všechny transakce před tím, než je těžaři začlení do bloků.
Jako kterákoliv jiná mezipaměť, i mempool je nejužitečnější, když je
často používaný. Musí být také omezen na velikosti, aby mohl být obsažen
v paměti. Příští týden se podíváme na slučitelnost pobídek jako metriku
držení nejužitečnějších transakcí v mempoolech.
