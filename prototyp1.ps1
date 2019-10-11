$datenVerzeichnis = "Z:\Sonstiges\Markus\Weiterbildung\TestDatGenSTB"
$anzahlDatensaetze = 10000
$testdatendatei = "testdaten.csv"

Clear-Host

Write-Host "In Verzeichnis mit Konfigurationsdaten wechseln"
Push-Location $datenVerzeichnis

Write-Host "Listen einlesen"
$nachnamenListe = Import-Csv -Path "Dat01Nachnamen.txt"
$vornamenWeiblichListe = Import-Csv -Path "Dat02VornamenWeiblich.txt"
$vornamenMaennlichListe = Import-Csv -Path "Dat03VornamenMaennlich.txt"
$strassennamenListe = Import-Csv -Path "Dat04Strassennamen.txt"
$plzOrtListe = Import-Csv -Path "Dat05PLZOrt.txt" -Delimiter ";"

Write-Host "Testdatensätze erzeugen"
[string] $zeile = "Nr;Vorname;Nachname;Strasse;PLZ;Ort"
$zeile | Out-File -FilePath $testdatendatei 
for( $i = 1; $i -le $anzahlDatensaetze; $i++) {
    if( ($i %2) -eq 0) {
        $zufall = Get-Random -Minimum 0 -Maximum ($vornamenMaennlichListe.Length-1)
        $vorname = ($vornamenMaennlichListe[$zufall]).Vorname    
        }
    else  {
        $zufall = Get-Random -Minimum 0 -Maximum ($vornamenWeiblichListe.Length-1)
        $vorname = ($vornamenWeiblichListe[$zufall]).Vorname    
        }        
    $zufall = Get-Random -Minimum 0 -Maximum ($nachnamenListe.Length-1)
    $nachname = ($nachnamenListe[$zufall]).Nachname
    $zufall = Get-Random -Minimum 0 -Maximum ($strassennamenListe.Length-1)
    $strasse = ($strassennamenListe[$zufall]).strasse
    $hausnummer = Get-Random -Minimum 1 -Maximum 200
    $zufall = Get-Random -Minimum 0 -Maximum ($plzOrtListe.Length-1)
    $plz = ($plzOrtListe[$zufall]).plz
    $ort = ($plzOrtListe[$zufall]).ort
    $zeile = $i.ToString() + ";" + $vorname + ";" + $nachname + ";" + $strasse + " " + $hausnummer + ";" + $plz + ";" + $ort
    $zeile | Out-File -FilePath $testdatendatei -Append
    }

Pop-Location