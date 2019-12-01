$datenVerzeichnis = "Z:\Sonstiges\Markus\Weiterbildung\TestDatGenSTB"
$spezifikationsDatei = "test_01.xml"

Clear-Host

Write-Host "In Verzeichnis mit Konfigurationsdaten wechseln"
Push-Location $datenVerzeichnis
Write-Host ""

Write-Host "Spezifikation einlesen"
[xml] $spezifikation = get-content -Path $spezifikationsDatei
Write-Host ""

Write-Host "Spezifikation auswerten"
$ausgabeDatei = $spezifikation.td.filespec.filename
$anzahlDatensaetze = $spezifikation.td.rowspec.rowcount
$trennzeichen = $spezifikation.td.rowspec.delimeterspec
$anzahlSpalten = ($spezifikation.td.colspec.col).length
Write-Host "    Ausgabedatei: $ausgabedatei"
Write-Host "    Anzahl Datensätze: $anzahlDatensaetze"
Write-Host "    Trennzeichen: $trennzeichen"
Write-Host "    Anzahl Spalten: $anzahlSpalten"
for($i = 0; $i -lt $anzahlSpalten; $i++) {
    $spaltenName = ($spezifikation.td.colspec.col)[$i].colname
    $spaltenTyp = ($spezifikation.td.colspec.col)[$i].coltype
    $spaltenDatei = ($spezifikation.td.colspec.col)[$i].colfile
    Write-Host "        $spaltenName;$spaltenTyp;$spaltenDatei"
    }
Write-Host ""

Write-Host "Benötigte Listen einlesen"
$dateiListe = @{}
for($i = 0; $i -lt $anzahlSpalten; $i++) {
    $spaltenTyp = ($spezifikation.td.colspec.col)[$i].coltype
    if( ($spaltenTyp -eq 3) -or ($spaltenTyp -eq 4)) {
        $spaltenDatei = ($spezifikation.td.colspec.col)[$i].colfile
        $liste = Import-Csv -Path $spaltenDatei -Header "spalte1"
        $dateiListe.Add($spaltenDatei, $liste)
        Write-Host "         Datei $spaltenDatei (Einspaltendatei) eingelesen"
        }
    if( ($spaltenTyp -eq 5)) {
        $spaltenDatei = ($spezifikation.td.colspec.col)[$i].colfile
        $liste = Import-Csv -Path $spaltenDatei 
        $dateiListe.Add($spaltenDatei, $liste)
        Write-Host "         Datei $spaltenDatei (Mehrspaltendatei) eingelesen"
        }
    }
Write-Host ""

Write-Host "Testdatendatei erstellen"
$zeilenText = ""
for($i = 0; $i -lt $anzahlSpalten; $i++) {
    $spaltenName = ($spezifikation.td.colspec.col)[$i].colname
    if( $i -ne 0) {
        $zeilenText = $zeilenText + $trennzeichen
        }
    $zeilenText = $zeilenText + $spaltenName
    }
$zeilenText | Out-File -FilePath $ausgabeDatei 
Write-Host "    Kopfzeile erstellt"

[int]$zeile = 1
for( $zeile = 1; $zeile -le $anzahlDatensaetze; $zeile++) {
    $zeilenText = ""
    for($i = 0; $i -lt $anzahlSpalten; $i++) {
        if( $i -ne 0) {
            $zeilenText = $zeilenText + $trennzeichen
            }
        $spaltenTyp = ($spezifikation.td.colspec.col)[$i].coltype
        if( $spaltenTyp -eq 1) {                                                # 1 - laufende Nummer
            $zeilenText = $zeilenText + $zeile
            }
        if( $spaltenTyp -eq 2) {                                                # 2 - generierte Zufallszahl
            $zahl = Get-Random -Minimum 1 -Maximum 200
            $zeilenText = $zeilenText + $zahl
            }
        if( $spaltenTyp -eq 3) {                                                # 3 - Einspaltendatei - Zufallsreihenfolge
            $spaltenDatei = ($spezifikation.td.colspec.col)[$i].colfile
            $maxZahl = ($dateiListe[$spaltenDatei]).Length - 1
            $zufall = Get-Random -Minimum 0 -Maximum ($maxZahl)
            $wert = ($dateiListe[$spaltenDatei])[$zufall].spalte1
            $zeilenText = $zeilenText + $wert
            }
        if( $spaltenTyp -eq 4) {                                                # 4 - Einspaltendatei - Reihenfolge
            $spaltenDatei = ($spezifikation.td.colspec.col)[$i].colfile
            $maxZahl = ($dateiListe[$spaltenDatei]).Length 
            $index = ($zeile - 1) % $maxZahl
            $wert = ($dateiListe[$spaltenDatei])[$index].spalte1
            $zeilenText = $zeilenText + $wert
            }
        if( $spaltenTyp -eq 5) {                                                # 5 - Mehrspaltendatei - Zufallsreihenfolge
            $spaltenDatei = ($spezifikation.td.colspec.col)[$i].colfile
            $maxZahl = ($dateiListe[$spaltenDatei]).Length - 1
            $zufall = Get-Random -Minimum 0 -Maximum ($maxZahl)
            $anzahlDetailspalten = $spaltenDatei = (($spezifikation.td.colspec.col)[$i].detailcol).length
            for( $detailspalte = 1; $detailspalte -le $anzahlDetailspalten; $detailspalte++) {
                $wert = ($dateiListe[$spaltenDatei])[$zufall].plz
                $zeilenText = $zeilenText + $wert
                }
            }
        }
        $zeilenText | Out-File -FilePath $ausgabeDatei -Append                  # Datenzeile ausgeben
    }   
    Write-Host "    Datenzeilen erstellt"
    Write-Host ""

Pop-Location