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
$anzahlDatensaetze = $spezifikation.td.rowspec.rowcount
$anzahlSpalten = ($spezifikation.td.colspec.col).length
Write-Host "    Anzahl Datensätze: $anzahlDatensaetze"
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
    if( $spaltenTyp -eq 3) {
        $spaltenDatei = ($spezifikation.td.colspec.col)[$i].colfile
        $liste = Import-Csv -Path $spaltenDatei
        $dateiListe.Add($spaltenDatei, $liste)
        Write-Host "         Datei $spaltenDatei eingelesen"
        }
    }

Pop-Location