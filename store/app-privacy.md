# App Privacy a Data safety: připravené odpovědi

Odpovědi pro build s anonymními statistikami (`docs/telemetry.md`, plán
`DevConventions/Prompts/04-PLAN-analytika.md`). **Vyplnit až po zveřejnění
nového `docs/privacy.html`** a před odesláním prvního buildu s klíčem
`TELEMETRY_KEY`. Odpovídají manifestům `ios/Runner/PrivacyInfo.xcprivacy` a
`macos/Runner/PrivacyInfo.xcprivacy`. Co je v konzolích vyplněné dnes, v repu
není: nejdřív porovnat a zachovat, co tam už je navíc.

Privacy Policy URL (obě konzole): `https://lioilsources.github.io/DJfy/privacy.html`

Pravidla obchodů se mění; před vyplněním ověřit aktuální znění formulářů.

## App Store Connect → App Privacy

**Do you or your third-party partners collect data from this app?** **Yes.**

**Data types collected** (zaškrtnout právě tyto):

| Kategorie → typ | Linked to the user? | Used for tracking? | Purpose |
|---|---|---|---|
| Usage Data → **Product Interaction** | **No** | **No** | **Analytics** |
| Diagnostics → **Performance Data** | **No** | **No** | **Analytics** |
| Location → **Coarse Location** | **No** | **No** | **Analytics** |

Proč:

- *Product Interaction:* spuštění, obrazovky, hledání chytrého playlistu
  (jen tvar dotazu a počty), načtení a přehrání skladby, efekty, funkce decku,
  party (začátek, konec, počty).
- *Performance Data:* doba načítání skladby na deck (`track_load_end.secs`) a
  doba hledání.
- *Coarse Location:* vlastní příjemce vývojáře odvodí zemi z IP adresy
  spojení, uloží jen zemi a IP neukládá. Kdyby se země na příjemci vypnula,
  tenhle řádek odškrtnout a z obou manifestů smazat
  `NSPrivacyCollectedDataTypeCoarseLocation`.

Nesbírá se (nechat nezaškrtnuté): Contact Info, Health & Fitness, Financial
Info, Precise Location, Sensitive Info, Contacts, User Content, Browsing
History, Search History (hledaný text se neposílá vývojáři; jde jen přímo do
Last.fm a SoundCloudu kvůli funkci appky), Identifiers (žádné User ID ani
Device ID: ID relace je náhodné, jen v paměti), Purchases, Other Usage Data,
Crash Data, Other Diagnostic Data, Other Data.

Party: relay vývojáře přenáší jméno party, frontu a jména, která zadají hosté
v prohlížeči. Drží je jen v paměti po dobu party a slouží jen k funkci appky
(žádné ukládání, žádná analytika). Podle Applu se data zpracovávaná jen v
reálném čase a neuchovávaná déle, než je nutné pro obsloužení požadavku,
nemusí deklarovat; ověřit aktuální znění („data not collected“ for
ephemeral processing). Pokud by Olin chtěl být opatrnější: User Content →
Other User Content, App Functionality, Not linked, No tracking.

**Linked to the user: No** u všech typů. Žádný účet ani identifikátor, dvě
relace nejde spojit.

**Tracking: No.** Nic se nespojuje s daty jiných firem a nejsou tu reklamy.
Dialog App Tracking Transparency není potřeba (`NSPrivacyTracking` je
`false`).

## Google Play Console → Data safety

- Does your app collect or share any of the required user data types? **Yes.**
- Is all user data encrypted in transit? **Yes** (klient statistik odmítne
  adresu bez `https`; relay party jede přes `https`).
- Do you provide a way for users to request that their data is deleted?
  **No.** Appka nemá účet. Statistiky nenesou žádný identifikátor, takže k
  člověku nejde žádný záznam dohledat; vypínač v nastavení smaže neodeslané
  záznamy v zařízení a na serveru se mažou po 12 měsících.
- Datové typy, všechny **Collected**, **not shared**:

| Data type | Purpose | Ephemeral? | Required or optional |
|---|---|---|---|
| App activity → **App interactions** | **Analytics** | No | **Optional** (vypínač v nastavení) |
| App info and performance → **Diagnostics** | **Analytics** | No | **Optional** (týž vypínač; doby načítání) |
| Location → **Approximate location** | **Analytics** | No | **Optional** (týž vypínač; země z IP, IP se neukládá) |

Kdyby se země na příjemci vypnula, řádek *Approximate location* vynechat.

Party: jméno party a jména hostů zpracovává relay jen v paměti pro funkci
appky. Podle Googlu se data zpracovaná jen efemérně (v paměti, jen pro
obsloužení požadavku) neuvádějí jako „collected“; ověřit aktuální znění.

Nesbírá se: precise location, personal info, financial info, device or other
IDs (žádné Advertising ID), contacts, files, messages, web browsing.

## Mimo repo (udělat ručně, ve všech jazycích, kde existují)

1. App Store Connect → App Privacy podle tabulky výše.
2. Google Play Console → Data safety podle tabulky výše.
3. Stránka appky na olin.now (`ol1n.now/apps/djfy/meta.md` a překlady):
   zmínit anonymní statistiky, které jdou vypnout. Věta „Malý server v Go …
   jen přeposílá zprávy a nic neukládá“ zůstává pravdivá.
4. Privacy Policy URL v obou konzolích nastavit na adresu výše, pokud tam
   ještě není.
