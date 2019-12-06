<#

.DESCRIPTION
        Dieses Skript erzeugt eine Testdatendatei. Gesteuert wird die Testdatengenerierung
        durch eine XML-Datei, welche am Skriptanfang eingelesen wird. Bei der Testdatengenerierung
        kann auf Datenlisten zugegriffen werden, welche entweder mitgeliefert sind, 
        oder vom Benutzer zur verfügung gestellt werden.

.NOTES

	Inhalt:
		Projekt: 			TdgSTB
		Thema:				Testdatengenerator

	Autor:
		Name:				Markus Breuer
		Organisaion:		STB

	Datum:
		Erstellt:			27.07.2019
		Letzte Änderung:	11.10.2019

#>

####################################################################################

$datenVerzeichnis = "Z:\Sonstiges\Markus\Weiterbildung\TestDatGenSTB"
$spezifikationsDatei = "test_01.xml"

####################################################################################

Clear-Host

Write-Host "In Verzeichnis mit Konfigurationsdaten wechseln"            # in Arbeitsverzeichnis wechseln
Push-Location $datenVerzeichnis
Write-Host ""

Write-Host "Spezifikation einlesen"                                     # Testdatenspezifikation einlesen
[xml] $spezifikation = get-content -Path $spezifikationsDatei
Write-Host ""

Write-Host "Spezifikation auswerten"                                    # Testdatenspezifikation auswerten und wichtige
$ausgabeDatei = $spezifikation.td.filespec.filename                     # Kenngrößen zur Kontrolle ausgeben
$anzahlDatensaetze = $spezifikation.td.rowspec.rowcount
$trennzeichen = $spezifikation.td.rowspec.delimeterspec
$anzahlSpalten = ($spezifikation.td.colspec.col).length
Write-Host "    Ausgabedatei: $ausgabedatei"
Write-Host "    Anzahl Datensätze: $anzahlDatensaetze"
Write-Host "    Trennzeichen: $trennzeichen"
Write-Host "    Anzahl Spalten: $anzahlSpalten (ohne Detailspalten)"
Write-Host "        (Spaltennummer;Spaltenname;Spaltentyp;Datendatei)"
for($i = 0; $i -lt $anzahlSpalten; $i++) {
    $spaltenName = ($spezifikation.td.colspec.col)[$i].colname
    $spaltenTyp = ($spezifikation.td.colspec.col)[$i].coltype
    $spaltenDatei = ($spezifikation.td.colspec.col)[$i].colfile
    Write-Host "        ($i;$spaltenName;$spaltenTyp;$spaltenDatei)"
    }
Write-Host ""

Write-Host "Benötigte Listen einlesen"                                  # Benötigte Datenlisten einlesen und 
$dateiListe = @{}                                                       # in einer Hashtabelle merken
for($i = 0; $i -lt $anzahlSpalten; $i++) {
    $spaltenTyp = ($spezifikation.td.colspec.col)[$i].coltype
    if( ($spaltenTyp -eq 3) -or ($spaltenTyp -eq 4)) {
        $spaltenDatei = ($spezifikation.td.colspec.col)[$i].colfile
        $liste = Import-Csv -Path $spaltenDatei -Header "spalte1"
        $anzahl = $liste.Length
        if (-not $dateiliste.ContainsKey($spaltenDatei)) {
            $dateiListe.Add($spaltenDatei, $liste) 
            }
        Write-Host "    Datei $spaltenDatei (Einspaltendatei) eingelesen; $anzahl Werte"
        }
    if( ($spaltenTyp -eq 5)) {
        $spaltenDatei = ($spezifikation.td.colspec.col)[$i].colfile
        $liste = Import-Csv -Path $spaltenDatei -Delimiter ";"
        $anzahl = $liste.Length
        if (-not $dateiliste.ContainsKey($spaltenDatei)) {
            $dateiListe.Add($spaltenDatei, $liste) 
            }
        Write-Host "    Datei $spaltenDatei (Mehrspaltendatei) eingelesen; $anzahl Werte"
        }
    }
Write-Host ""

Write-Host "Testdatendatei erstellen"                                   # Kopfzeile generieren
$zeilenText = ""
$erste = $true
for($i = 0; $i -lt $anzahlSpalten; $i++) {
    $spaltenTyp = ($spezifikation.td.colspec.col)[$i].coltype
    if( ($spaltenTyp -eq 5)) {                              # Mehrspaltendatei
        $anzahlDetailSpalten = (($spezifikation.td.colspec.col)[$i].detailcol.detailcolname).length
        for( $j = 0; $j -lt $anzahlDetailSpalten; $j++){
            $spaltenName = (($spezifikation.td.colspec.col)[$i].detailcol).detailcolname[$j]
            if( $erste -ne $true) {
                $zeilenText = $zeilenText + $trennzeichen
                }
            $zeilenText = $zeilenText + $spaltenName   
            $erste = $false 
            }
        }
    else {                                                  # keine Mehrspaltendatei
        $spaltenName = ($spezifikation.td.colspec.col)[$i].colname        
        if( $erste -ne $true) {
            $zeilenText = $zeilenText + $trennzeichen
            }
        $zeilenText = $zeilenText + $spaltenName
        $erste = $false
        }
    }
$zeilenText | Out-File -FilePath $ausgabeDatei              # Kopfzeile ausgeben
Write-Host "    Kopfzeile erstellt"

[int]$zeile = 1                                                         # Datenzeilen generieren
Write-Host "    Datenzeilen erstellen " -NoNewline
for( $zeile = 1; $zeile -le $anzahlDatensaetze; $zeile++) {
    if( ($zeile % 500) -eq 0) {                                         # Fortschrittsanzeige
        Write-Host "." -NoNewline
        }
    $zeilenText = ""
    for($i = 0; $i -lt $anzahlSpalten; $i++) {
        if( $i -ne 0) {
            $zeilenText = $zeilenText + $trennzeichen
            }
        $spaltenTyp = ($spezifikation.td.colspec.col)[$i].coltype
        if( $spaltenTyp -eq 1) {                                                # 1 - laufende Nummer
            $zeilenText = $zeilenText + $zeile
            }
        elseif( $spaltenTyp -eq 2) {                                            # 2 - generierte Zufallszahl
            $zahl = Get-Random -Minimum 1 -Maximum 200
            $zeilenText = $zeilenText + $zahl
            }
        elseif( $spaltenTyp -eq 3) {                                            # 3 - Einspaltendatei - Zufallsreihenfolge
            $spaltenDatei = ($spezifikation.td.colspec.col)[$i].colfile
            $maxZahl = ($dateiListe[$spaltenDatei]).Length - 1
            $zufall = Get-Random -Minimum 0 -Maximum ($maxZahl)
            $wert = ($dateiListe[$spaltenDatei])[$zufall].spalte1
            $zeilenText = $zeilenText + $wert
            }
        elseif( $spaltenTyp -eq 4) {                                            # 4 - Einspaltendatei - Reihenfolge
            $spaltenDatei = ($spezifikation.td.colspec.col)[$i].colfile
            $maxZahl = ($dateiListe[$spaltenDatei]).Length 
            $index = ($zeile - 1) % $maxZahl
            $wert = ($dateiListe[$spaltenDatei])[$index].spalte1
            $zeilenText = $zeilenText + $wert
            }
        elseif( $spaltenTyp -eq 5) {                                            # 5 - Mehrspaltendatei - Zufallsreihenfolge
            $spaltenDatei = ($spezifikation.td.colspec.col)[$i].colfile
            $maxZahl = ($dateiListe[$spaltenDatei]).Length - 1
            $zufall = Get-Random -Minimum 0 -Maximum ($maxZahl)
            $anzahlDetailSpalten = (($spezifikation.td.colspec.col)[$i].detailcol.detailcolname).length
            for( $j=0; $j -lt $anzahlDetailSpalten; $j++) {
                if( $j -ne 0) {
                    $zeilenText = $zeilenText + $trennzeichen
                    }
                $spaltenName = (($spezifikation.td.colspec.col)[$i].detailcol).detailcolname[$j]
                $wert = ($dateiListe[$spaltenDatei])[$zufall].$spaltenName
                $zeilenText = $zeilenText + $wert
                }
            }
        }
        $zeilenText | Out-File -FilePath $ausgabeDatei -Append                  # Datenzeile ausgeben
    }   
    Write-Host ""
    $zeile--
    Write-Host "    Datenzeilen erstellt; $zeile Datenzeilen"
    Write-Host ""

    Write-Host "Testdatendatei `"$ausgabedatei`" (Verzeichnis: `"$datenverzeichnis`") erfolgreich angelegt."
    Write-Host ""

Pop-Location                                                            # in Ausgangsverzeichnis zurückkehren