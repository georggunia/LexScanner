# LexScanner – Praktikum 1: Scanner (Simple)

## Schnellstart (Windows + Docker)

1) Docker Desktop starten.
2) PowerShell im Projektordner öffnen (C:\Users\georg\LexScanner):

```powershell
docker pull markusmock/ib610:scanner
docker run -it --rm -v "${PWD}:/ib610/scanner" markusmock/ib610:scanner /bin/bash
```

3) Im Container bauen und testen:

```bash
cd /ib610/scanner
make clean
make
make test
```

4) Optional: weitere Tests und Abgabe

```bash
make atest TEST=test_ops.sim
make atest TEST=test_ints.sim
make atest TEST=test_strings.sim
make atest TEST=test_comments.sim
make atest TEST=test_ident.sim
make atest TEST=eof.sim
make submit
```

## Inhaltsverzeichnis

- Änderungen im Überblick
- Details zu simple.jlex
- Details zu P2.java
- Build & Run
- Abgabe bauen
- Windows-CRLF: Was wurde angepasst und warum?
- Alternative Variante (case/switch/default)
- Qualitätstore (Stand der letzten Läufe)
- Troubleshooting

Dieses Repository enthält den Scanner für die Sprache „Simple“ (Teilmenge von Java) auf Basis von JFlex. Unten findest du eine kompakte Zusammenfassung aller umgesetzten Änderungen, Hinweise zum Bauen und Testen (inkl. Windows/Docker), sowie Hinweise zur Abgabe.

## Änderungen im Überblick

- simple.jlex (komplettiert und robust gemacht):
	- Vollständiges Token-Set gemäß `sym.java` (Keywords, Identifier, Integer-/Stringliterale, Operatoren/Delimiter, PRINT für `System.out.println`).
	- Zustände STR und COMMENT für Strings/Kommentare; Fehler bei unterminierten Strings/Kommentaren (einmalig, dann EOF).
	- Korrekte Positionszählung (Zeile/Spalte) inkl. Newlines; CRLF (Windows) explizit unterstützt.
	- Integer-Überlauf: Warnung und Kappung auf 2147483647 (Minus ist eigener Operator, kein Teil des Literals).
	- Unerlaubte Zeichen (z. B. einzelnes `&`/`|`) werden als Fehler gemeldet.
	- Spezielle Regel für `System.out.println` → Token PRINT.
- P2.java (Testtreiber erweitert):
	- Gibt jetzt alle Tokens aus; bei Literalen/ID zusätzlich den Wert.
	- Nutzt Reflection, um Werte aus `TokenVal`-Unterklassen zu lesen (vermeidet Compile-Fehler, falls `Yylex`/Tokenklassen noch nicht generiert sind).
- Neue Testdateien (zusätzlich zu `test.sim`, `test2.sim`, `eof.sim`):
	- `test_ops.sim` – alle Operatoren/Delimiter.
	- `test_ints.sim` – Integer-Grenzfälle inkl. Überlauf, negatives Vorzeichen als eigener Operator.
	- `test_strings.sim` – leere/normale Strings, Escapes (\n, \t, \", \\).
	- `test_comments.sim` – // und /* */ inkl. unterminiertem Kommentar.
	- `test_ident.sim` – Keywords vs. IDs, PRINT, illegale Zeichen `&`/`|`, sowie `case/switch/default` (aktuell IDs).
- Optionale Alternativen (nur auf Wunsch verwenden):
	- `simple_with_case_switch_default.jlex`: Variante, die `case/switch/default` als Keywords liefert.
	- `sym_with_case_switch_default.java`: passendes alternatives `sym` mit CASE/SWITCH/DEFAULT.
	- `P2_with_case_switch_default.java`: Testtreiber, der diese drei Tokens explizit ausgibt.
	- Hinweis: Diese Alternativen werden vom Standard-`Makefile` nicht automatisch verwendet. Nur nutzen, wenn du `sym.java`/`simple.jlex` temporär ersetzen möchtest.

## Details zu simple.jlex

- Zustände: `%state STR`, `%state COMMENT`.
- Positionszählung: Hilfsfunktion `updateCharNum`, die bei `\n` oder `\r` `CharNum.num` auf 1 setzt, ansonsten inkrementiert.
- Newline-Handling für Windows-CRLF: Ausdrucke wie `(\r\n|[\r\n])` in STR/COMMENT.
- Whitespace, `//`, `/*` starten nur im Initialzustand (`<YYINITIAL>`), damit die STR-Regeln (z. B. schließendes `"`) sicher erreichbar sind.
- Strings: erlaubte Escapes `\n`, `\t`, `\'`, `\"`, `\\`; unerlaubte Escapes → Fehler. Newline/EOF im String → „unterminated string literal“ (einmalig, dann EOF).
- Integer: Parsing als long; Werte > Integer.MAX_VALUE → Warnung und Kappung. Minus separat als `MINUS`-Token.
- Keywords/IDs: Keywords per Liste, ansonsten `ID`. `System.out.println` → PRINT.
- Operatoren: Mehrzeichen zuerst (&&, ||, ==, !=, <=, >=), dann Einzelzeichen. Einzelne `&`/`|` sind illegal.

## Details zu P2.java

- Ausgabeformat pro Token: `zeile:spalte TOKENNAME`.
- Bei `ID`, `INTLITERAL`, `STRINGLITERAL` werden zusätzlich Werte ausgegeben: `ID (name)`, `INTLITERAL (42)`, `STRINGLITERAL ("text")`.
- Reflection zum Auslesen der Werte aus `TokenVal`-Subklassen vermeidet Build-Probleme vor der Lexer-Generierung.

## Build & Run

Empfohlen ist der bereitgestellte Docker-Container. Auf Windows entwickelst du in VS Code und mountest deinen Ordner in den Container.

### Windows: Container mit Volume-Mount starten (PowerShell)

```powershell
docker pull markusmock/ib610:scanner
cd C:\Users\georg\LexScanner
docker run -it --rm -v "${PWD}:/ib610/scanner" markusmock/ib610:scanner /bin/bash
```

Alternativ (cmd.exe):

```cmd
docker run -it --rm -v "C:\Users\georg\LexScanner:/ib610/scanner" markusmock/ib610:scanner /bin/bash
```

Typische Stolperfallen unter Windows:
- „invalid reference format“ → Stelle sicher, dass der gesamte `-v` Parameter in EINEM Anführungszeichenblock steht: `"C:\\Pfad:/ib610/scanner"`.
- Laufwerk nicht freigegeben → In Docker Desktop unter Settings → Resources → File Sharing das Laufwerk C: (oder `C:\Users`) freigeben.

### Im Container bauen und testen

```bash
cd /ib610/scanner
make clean
make
make test

# zusätzliche Tests
make atest TEST=test_ops.sim
make atest TEST=test_ints.sim
make atest TEST=test_strings.sim
make atest TEST=test_comments.sim
make atest TEST=test_ident.sim
make atest TEST=eof.sim
```

### Abgabe bauen

```bash
make submit
```

Es entsteht `submit.zip` im gemounteten Ordner (unter Windows sichtbar).

## Windows-CRLF: Was wurde angepasst und warum?

- Problem: Dateien mit CRLF (`\r\n`) führten zu „Error: could not match input“, da `\r` weder als Whitespace noch als Newline gematcht wurde.
- Lösung:
	- `WHITESPACE = [ \t\r\n]` (vorher ohne `\r`).
	- `updateCharNum` setzt bei `\r` und `\n` die Spaltennummer zurück.
	- In STR/COMMENT werden Newlines als `(\r\n|[\r\n])` erkannt.
	- Ergebnis: Scanner verarbeitet CRLF-Dateien fehlerfrei.

## Alternative Variante (case/switch/default)

Falls du die drei zusätzlichen Keywords nutzen willst:
- `simple_with_case_switch_default.jlex` + `sym_with_case_switch_default.java` (und optional `P2_with_case_switch_default.java`).
- Nutzung (temporär, im Container):

```bash
cp sym_with_case_switch_default.java sym.java
cp simple_with_case_switch_default.jlex simple.jlex
# optional
cp P2_with_case_switch_default.java P2.java
make clean && make && make test
```

Zurück zur Standardvariante:

```bash
git restore sym.java simple.jlex P2.java
make clean && make
```

## Qualitätstore (Stand der letzten Läufe)

- Build: PASS (JFlex-Generierung + `javac`).
- Tests: PASS (mit den bereitgestellten und zusätzlichen Testdateien).
- Lint/Typen: PASS im Container; lokale Editor-Warnungen (vor Lexer-Generierung) sind erwartbar.

## Troubleshooting

- „invalid reference format“ beim `docker run`:
	- Korrigiere die Anführungszeichen um den kompletten `-v` Parameter (siehe oben).
- „could not match input“ direkt nach dem ersten Token:
	- CRLF-Datei? Stelle sicher, dass du die aktuelle `simple.jlex` (mit `\r`-Handling) nutzt und neu gebaut hast (`make clean && make`).
- Unterminierte Strings/Kommentare spammen Fehler:
	- In dieser Version geben diese Fälle nur eine Fehlermeldung aus und liefern dann EOF – baue neu, falls noch Loops auftreten.

---

Bei weiteren Fragen oder wenn du die Variante mit `case/switch/default` dauerhaft integrieren möchtest, einfach melden – ich passe `sym.java`, `simple.jlex` und `P2.java` entsprechend an und erweitere die Tests.