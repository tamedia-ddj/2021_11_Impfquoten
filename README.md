# Impfquoten

### Modellierung von Impfquoten in Schweizer Gemeinden

**Artikel**: [Tagesanzeiger: Einkommen und SVP Anteil spielen grosse Rolle Pass ist unwichtig](https://www.tagesanzeiger.ch/einkommen-und-svp-anteil-spielen-grosse-rolle-pass-ist-unwichtig-981610948363) (Publiziert am: 8. November 2021)

## Daten

**Datenquelle(n)**:

* [BFS - Gemdeindeportraits](https://www.bfs.admin.ch/bfs/de/home/statistiken/regionalstatistik/regionale-portraets-kennzahlen/gemeinden.assetdetail.15864450.html) 
* [Einkommen - Eidgenössische Steuerverwaltung](https://www.estv.admin.ch/estv/de/home/allgemein/steuerstatistiken/fachinformationen/steuerstatistiken/direkte-bundessteuer.html): Median des steuerbares Einkommen über alle bundessteurpflichtigen Einwohner. Stand 2017. Gemeinden die nach 2017 fusioniet haben sind in der Analyse nicht enthalten.
* Impfquoten - Kantone
* [Eidg. Gebäude- und Wohnungsregister GWR des BFS](https://data.geo.admin.ch/ch.bfs.gebaeude_wohnungs_register/CSV/CH/CH37.zip) (ist zu gross und muss separat heruntergeladen werden) Wird verwendet um die Impfquoten pro Postleitzahl den Gemeinden zuzuordnen

Die Impfquoten wurden bei allen Kantonen angefragt.  Von 5 Kantonen konnten die Impfquoten auf Gemeinde- bzw. Postleitzahlebene erhalten werden: Zürich, Aargau, Basel-Land, Waadt, Neuenburg


## Code

#### Postleitzahl Zuordnung:

Für die Kantone Zürich und Waadt werden die Impfquoten pro Postleitzahl angegeben und müssen zuerst auf Gemeinden umgerechnet werden. Dies geschieht mit dem Script [prep_Postleitzahl.R](prep_Postleitzahl.R). Für jede Postleitzahl wird gezählt, wie viele Adressen auf die verschiedenen Gemeinden fallen. Anhand dieser Anteile werden die geimpften Personen einer Postleitzahl auf die Gemeinden aufgeteilt. Das benötigte schweizweite Adressverzeichnis ist sehr gross und muss hier separat heruntergeladen werden: https://data.geo.admin.ch/ch.bfs.gebaeude_wohnungs_register/CSV/CH/CH37.zip (wird wöchentlich aktualisiert).

#### Statistische Modellierung:

Diese geschieht im R-Markdown file [Impfkarte.Rmd](Impfkarte.Rmd).

Der HTML Output des Markdown files lässt sich hier betrachten: [Impfkarte.html](https://interaktiv.tagesanzeiger.ch/datenteam/Impfkarte.html). Hier wird das HTML file von einer externen Quelle verlinkt, da Github HMTL files nicht direkt anzeigen kann. (Es müsste separat heruntergeladen und im Browser geöffnet werde.)  

Die Stichtage für die Impfquote sind nicht einheitlich (zwischen 25. August im Kanton Aargau bis zum 31. Oktober im Kanton Zürich) und im Kanton Aargau lagen zudem nur die Quoten der vollständig geimpften vor. Diese kantonalen Unterschiede haben aber keinen entscheidenden Einfluss auf die genannten Resultate, da sie über eine entsprechende Kontrollvariable aufgefangen werden. In den Kantonen Zürich und Waadt werden die Impfquoten zudem pro Postleitzahl publiziert und mussten auf die Gemeinden umgerechnet werden. Dabei können kleinere Verzerrungen entstehen, da die Zuordnung von Postleitzahl zu Gemeinde nicht in allen Fällen eindeutig ist.


## Lizenz

*Impfquoten* is free and open source software released under the permissive MIT License.
