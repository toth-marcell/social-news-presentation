#import "@preview/touying:0.7.3": *
#import themes.dewdrop: *

#let accent = rgb("#007a50")
#let title = "Social news projekt"
#let author = "Tóth Marcell"

#show: dewdrop-theme.with(
  aspect-ratio: "4-3",
  primary: accent,
  navigation: none,
  config-info(
    title: title,
    author: author,
  ),
)

#set text(22pt, lang: "hu", font: "Inter", stylistic-set: (2, 7), hyphenate: false)
#show raw: set text(font: "Hack")
#set list(spacing: 1.5em)
#set par(justify: false)

#title-slide()

== Projekt leírás
- egy "social news site", tehát egy olyan weboldal (és hozzátartozó asztali, illetve mobil alkalmazás) ahol a felhasználók bejegyzéseket hozhatnak létre, amik általában linkeket tartalmaznak cikkekre vagy blogbejegyzésekre (de tartalmazhatnak szöveget is)
- lehet szavazni ezekre a bejegyzésekre, ezzel feljebb sorolva azokat a főoldalon
- lehet  megjegyzéseket tenni a bejegyzésekre, egy hierarchikus komment rendszerben

== Technológiák
- Express (Node.js) alapú szerver
  - EJS szerveroldali renderelést használ
  - HTML űrlapok a bemenethez (tehát használható böngészőoldali Javascript nélkül is)
  - sqlite adatabázis Sequelize ORM-el
- Avalonia C\#-ban írt többplatformú applikáció
  - működik asztali operációs rendszereken és Androidon is

== Fejlesztési eszközök
- Git verziókövetés
  - Github mint távoli repository
- Visual Studio Code IDE a legtöbb dologhoz, a következő bővítményekkel:
  - Prettier a kód automatikus formázásához (kivéve a HTML/EJS-hez, ehhez a VSCode beépített formázóját használtam)
  - Tinymist Typst a dokumentációnak és a prezentációnak a készítéséhez
- Visual Studio IDE az Avalonia alapú asztali és mobil alkalmazáshoz az AXAML Viewer bővítménnyel

== Adatbázis

#text(font: "Times New Roman", align(center, image("erd.svg", height: 1fr)))

== Működés bemutatása: autentikáció
- JWT (json web token) alapú autentikáció, ami tartalmazza a belépett felhasználó azonosítóját
  - a weboldalon cookie-ba van rakva
  - az API-nál az Authentication HTTP fejlécben Bearer típussal kell elküldeni, miután a belépésnél a válasz törzséből kiolvasta (és eltárolta) a kliens
- Egy bejelentkezés 1 évig él, utána újra be kell lépni
- A jelszavaknak min 8 karakterből kell állniuk
- A jelszó hash-elés először sha256-al hasheli, majd bcrypt-el a jelszavakat, így nem probléma a bcrypt max bemenethossza, lehet hosszabb jelszót ("passphrase"-t) is használni.
#pagebreak()
- 3 különböző szerepet különböztetünk meg:
  - *Vendég* (nincs bejelentkezve/nem küldött tokent)
    - megnézhet bejegyzéseket, megjegyzéseket és felhasználói profilokat
  - *Felhasználó*
    - létrehozhat bejegyzéseket, megjegyzéseket
    - szerkesztheti és törölheti saját bejegyzéseit, megjegyzéseit
    - szerkesztheti saját profilját
#pagebreak()
- *Adminisztrátor*
  - szerkeszthet és törölhet bármit
  - megnézheti a naplót
  - listázhatja a felhasználókat
  - módosíthatja bármelyik felhasználó adatait, és adminisztrátorrá teheti őket, vagy elveheti admin státuszukat (viszont nem a sajátját)

== API manuális tesztelés
- az API van automatikus is tesztelve (erre visszatérünk)
- manuális tesztelésére és az útvonalak megismerésére az OpenAPI definíció alapján automatikusan készült interaktív oldal:
  - https://social-news.toth-marcell.xyz/api-docs
- itt látható, hogy milyen útvonalak elérhetők, a bemeneteik, kimeneteik
#image("swagger-parameters.png")
#image("swagger-responses.png")

== Felhasználói felület manuális tesztelés
- a felhasználói felületeket (a weboldalt, asztali  és mobil alkalmazást) manuálisan teszteltem.
- követjük a felhasználói dokumentációt és kipróbálunk minden egyes listázott funkciót, minden gombnyomásnál pedig megnézzük, hogy az történt-e, amit vártunk
- ezt a felhasználói dokumentáció írása közben is megcsináltam, tehát azt mondhatjuk, minden ott listázott funkció megfelelően működik.

- a manuális teszteléshez, hogy legyenek már felhasználók, bejegyzések és kommentek, ne üres legyen minden, készítettem egy script-et ami létrehoz sok adatot az adatbázisban véletlenszerű nevekkel/szöveggel/stb.

#align(center)[
  #show image: it => block(stroke: (paint: black, thickness: 1mm), it)
  #image("screenshots/web/frontpage-first.png")
  #image("screenshots/web/post-first.png")
  #image("screenshots/web/post.png")
  #image("screenshots/web/register.png")
  #image("screenshots/web/register-err.png")
  #image("screenshots/web/login-after-register.png")
  #image("screenshots/web/frontpage-after-login.png")
  #image("screenshots/web/frontpage-admin.png")
  #image("screenshots/web/newpost.png")
  #image("screenshots/web/editpost.png")
  #image("screenshots/web/editcomment.png")
  #image("screenshots/web/profile.png")
  #image("screenshots/web/profile-own.png")
  #image("screenshots/web/profile-admin.png")
  #image("screenshots/web/logs.png")
  #image("screenshots/web/users.png")
]

== Automatikus (egység és integrációs) tesztelés
- automatikus tesztelve vannak a web szerver egyes komponensei és az API útvonalak
- ehhez a `jest` és `supertest` npm csomagokat használtam
#align(center, {
  v(1fr)
  set text(fill: white)
  let stat(n, unit, desc) = block(fill: accent, height: 5cm, pad(x: 1cm)[
    #v(1fr)
    #text(50pt, [#n]) #unit

    #desc
    #v(1fr)
  ])
  stack(
    dir: { ltr },
    spacing: .5cm,
    stat(5, "db", "teszt fájl"),
    stat(38, "db", "teszt eset"),
    stat(79.97, "%", "kód lefedettség"),
    stat(100, "%", "siker"),
  )
  v(1fr)
})

== Fejlesztési lehetőségek
- ha tényleg elindítanánk egy nyilvános weboldalt, akkor
  - ki kellene egészíteni a szabályokat
  - esetleg több moderációs eszközt kellene hozzáadni
- az Avalonia támogatja az iOS alkalmazás készítését is,
  tehát arra is lehetne építeni az alkalmazást (csak erre kell eszköz is teszteléshez)
- az alkalmazáshoz hozzá lehetne adni az összes funkciót, amik jelenleg csak a weboldalon érhetők el

== A projekt sorás szerzett skillek
=== Hard skillek
- a használt informatikai technológiák ismerete
- angol nyelvtudás
  - a használt technológiák dokumentációjának olvasása
  - a projekt kódja és felhasználói felületei angolul vannak
=== Soft skillek
- problémamegoldás
- időgazdálkodás
- tanulás

== Summary
- a social news website, desktop and Android app where users can register, then create and upvote posts and comments
- website and API server uses Express (Node.js)
- desktop and Android app made with Avalonia (C\#), both programs are built from a single codebase
- API automatically tested using `jest` and `supertest`
- User interfaces manually tested by following user documentation which lists all functions

== Vége
#v(40%)
#align(center)[
  Köszönöm a figyelmet!

  Kérdések?

  Questions?
]
