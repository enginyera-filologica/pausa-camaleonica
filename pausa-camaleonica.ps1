<#
========================================================================
LLICÈNCIA / LICENSE - CC BY-NC 4.0
========================================================================
Pausa camaleonica © 2026 de Enginyera Filològica.

Aquest projecte (incloent el codi font i el seu fitxer executable .exe) 
està llicenciat sota la llicència Creative Commons Reconeixement-NoComercial 
4.0 Internacional (CC BY-NC 4.0).

This project (including the source code and its executable .exe file) 
is licensed under the Creative Commons Attribution-NonCommercial 4.0 
International License (CC BY-NC 4.0).
========================================================================
#>


Write-Host 
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore

# ============================================================
# CONFIGURACIÓ
# ============================================================

$TempsTreball = 50       # Minuts de treball
$TempsDescans = 5       # Minuts de descans
$TempsSegonAvis = 10     # Minuts fins al segon avís


# ============================================================
# FINESTRA GENERAL
# ============================================================

function Mostra-Finestra {
    param (
        [string]$Cara,
        [string]$Missatge,
        [string]$TextBotoDescans,
        [string]$TextBotoContinuar
    )

    $finestra = New-Object System.Windows.Window
    $finestra.Title = "Recordatori de descans"
    $finestra.Width = 802
    $finestra.Height = 552
    $finestra.WindowStartupLocation = "CenterScreen"
    $finestra.Topmost = $true
    $finestra.ResizeMode = "NoResize"
    $finestra.ShowInTaskbar = $true

    $panell = New-Object System.Windows.Controls.StackPanel
    $panell.HorizontalAlignment = "Center"
    $panell.VerticalAlignment = "Center"

    $caraText = New-Object System.Windows.Controls.TextBlock
    $caraText.Text = $Cara
    $caraText.FontSize = 70
    $caraText.HorizontalAlignment = "Center"

    $missatgeText = New-Object System.Windows.Controls.TextBlock
    $missatgeText.Text = $Missatge
    $missatgeText.FontSize = 25
    $missatgeText.FontWeight = "Bold"
    $missatgeText.TextAlignment = "Center"
    $missatgeText.Margin = "15"

    $botoDescans = New-Object System.Windows.Controls.Button
    $botoDescans.Content = $TextBotoDescans
    $botoDescans.FontSize = 20
    $botoDescans.Padding = "15,8"
    $botoDescans.Margin = "8"

    # Aquest botó s'activarà amb Enter
    $botoDescans.IsDefault = $true

    $botoDescans.Add_Click({
        $finestra.DialogResult = $true
    })

    [void]$panell.Children.Add($caraText)
    [void]$panell.Children.Add($missatgeText)
    [void]$panell.Children.Add($botoDescans)

    # Només crea el segon botó si té text
    if (-not [string]::IsNullOrWhiteSpace($TextBotoContinuar)) {

        $botoContinuar = New-Object System.Windows.Controls.Button
        $botoContinuar.Content = $TextBotoContinuar
        $botoContinuar.FontSize = 20
        $botoContinuar.Padding = "15,8"
        $botoContinuar.Margin = "8"

        $botoContinuar.Add_Click({
            $finestra.DialogResult = $false
        })

        [void]$panell.Children.Add($botoContinuar)
    }

    $finestra.Content = $panell

    return ($finestra.ShowDialog() -eq $true)
}


# ============================================================
# DESCANS
# ============================================================

function Descans {
    param (
        [int]$DuradaMinuts
    )

    $duradaSegons = $DuradaMinuts * 60

    $finestra = New-Object System.Windows.Window
    $finestra.Title = "Hora de desconnectar"
    $finestra.Width = 802
    $finestra.Height = 552
    $finestra.WindowStartupLocation = "CenterScreen"
    $finestra.Topmost = $true
    $finestra.ResizeMode = "NoResize"
    $finestra.ShowInTaskbar = $true

    $panell = New-Object System.Windows.Controls.StackPanel
    $panell.HorizontalAlignment = "Center"
    $panell.VerticalAlignment = "Center"

    $cara = New-Object System.Windows.Controls.TextBlock
    $cara.Text = "🙂"
    $cara.FontSize = 80
    $cara.HorizontalAlignment = "Center"

    $missatge = New-Object System.Windows.Controls.TextBlock

    $textDescans =
        "Mou-te durant una estona, aixeca't i camina; si no pot ser:`n`n" +
        "• Aixeca les puntes dels peus.`n" +
        "• Mou les cames i els turmells.`n" +
        "• Canvia de postura.`n" +
        "• Estira suaument l'esquena.`n" +
        "• Mira lluny de la pantalla."

    $missatge.Text = $textDescans
    $missatge.FontSize = 24
    $missatge.FontWeight = "Bold"
    $missatge.TextAlignment = "Center"
    $missatge.Margin = "15"

    $comptador = New-Object System.Windows.Controls.TextBlock
    $comptador.Text = "Temps de descans: $DuradaMinuts minuts"
    $comptador.FontSize = 24
    $comptador.TextAlignment = "Center"
    $comptador.Margin = "10"

    $boto = New-Object System.Windows.Controls.Button
    $boto.Content = "Acabar el descans"
    $boto.FontSize = 20
    $boto.Padding = "15,8"
    $boto.Margin = "10"

    # Enter acaba el descans
    $boto.IsDefault = $true

    $estat = @{
        Restants = $duradaSegons
    }

    $temporitzador = New-Object System.Windows.Threading.DispatcherTimer
    $temporitzador.Interval = [TimeSpan]::FromSeconds(1)

    $temporitzador.Add_Tick({

        $estat.Restants--

        if ($estat.Restants -gt 0) {
            $minutsRestants = [Math]::Floor($estat.Restants / 60)
            $segonsRestants = $estat.Restants % 60

            $comptador.Text = "Temps de descans: {0}:{1:D2}" -f `
                $minutsRestants, $segonsRestants
        }
        else {
            $temporitzador.Stop()
            $comptador.Text = "Descans acabat!"
            $boto.Content = "Continuar treballant"
        }
    })

    $boto.Add_Click({
        $temporitzador.Stop()
        $finestra.Close()
    })

    [void]$panell.Children.Add($cara)
    [void]$panell.Children.Add($missatge)
    [void]$panell.Children.Add($comptador)
    [void]$panell.Children.Add($boto)

    $finestra.Content = $panell

    $temporitzador.Start()

    [void]$finestra.ShowDialog()

    $temporitzador.Stop()
}


# ============================================================
# SELECCIÓ DE L'HORA DEL SEGÜENT AVÍS
# ============================================================

function Selecciona-HoraAvis {

    $ara = Get-Date
    $horaPredeterminada = $ara.AddMinutes($TempsSegonAvis)

    $finestra = New-Object System.Windows.Window
    $finestra.Title = "Programar el següent avís"
    $finestra.Width = 550
    $finestra.Height = 350
    $finestra.WindowStartupLocation = "CenterScreen"
    $finestra.Topmost = $true
    $finestra.ResizeMode = "NoResize"

    $panell = New-Object System.Windows.Controls.StackPanel
    $panell.HorizontalAlignment = "Center"
    $panell.VerticalAlignment = "Center"

    $missatge = New-Object System.Windows.Controls.TextBlock

    $textProgramacio =
        "Si vols, pots programar un altre recordatori.`n" +
        "Serà opcional, mes recomanable fer."

    $missatge.Text = $textProgramacio
    $missatge.FontSize = 22
    $missatge.FontWeight = "Bold"
    $missatge.TextAlignment = "Center"
    $missatge.Margin = "15"

    $panellHora = New-Object System.Windows.Controls.StackPanel
    $panellHora.Orientation = "Horizontal"
    $panellHora.HorizontalAlignment = "Center"

    $hora = New-Object System.Windows.Controls.ComboBox
    $hora.Width = 90
    $hora.FontSize = 22
    $hora.Margin = "5"

    for ($i = 0; $i -le 23; $i++) {
        [void]$hora.Items.Add(("{0:D2}" -f $i))
    }

    $minuts = New-Object System.Windows.Controls.ComboBox
    $minuts.Width = 90
    $minuts.FontSize = 22
    $minuts.Margin = "5"

    for ($i = 0; $i -le 59; $i++) {
        [void]$minuts.Items.Add(("{0:D2}" -f $i))
    }

    $hora.SelectedItem = "{0:D2}" -f $horaPredeterminada.Hour
    $minuts.SelectedItem = "{0:D2}" -f $horaPredeterminada.Minute

    $separador = New-Object System.Windows.Controls.TextBlock
    $separador.Text = ":"
    $separador.FontSize = 24
    $separador.VerticalAlignment = "Center"

    [void]$panellHora.Children.Add($hora)
    [void]$panellHora.Children.Add($separador)
    [void]$panellHora.Children.Add($minuts)

    $botoProgramar = New-Object System.Windows.Controls.Button
    $botoProgramar.Content = "Programar recordatori"
    $botoProgramar.FontSize = 20
    $botoProgramar.Padding = "15,8"
    $botoProgramar.Margin = "15"

    # Enter programa l'avís
    $botoProgramar.IsDefault = $true

    $botoContinuar = New-Object System.Windows.Controls.Button
    $botoContinuar.Content = "No programar cap altre avís"
    $botoContinuar.FontSize = 18
    $botoContinuar.Padding = "12,6"
    $botoContinuar.Margin = "5"

    $botoProgramar.Add_Click({

        $dataActual = Get-Date

        $horaEscollida = [int]$hora.SelectedItem
        $minutEscollit = [int]$minuts.SelectedItem

        $dataAvis = Get-Date `
            -Year $dataActual.Year `
            -Month $dataActual.Month `
            -Day $dataActual.Day `
            -Hour $horaEscollida `
            -Minute $minutEscollit `
            -Second 0

        if ($dataAvis -le $dataActual) {
            $dataAvis = $dataAvis.AddDays(1)
        }

        $finestra.Tag = $dataAvis
        $finestra.DialogResult = $true
    })

    $botoContinuar.Add_Click({
        $finestra.Tag = "NO_PROGRAMAR"
        $finestra.DialogResult = $false
    })

    [void]$panell.Children.Add($missatge)
    [void]$panell.Children.Add($panellHora)
    [void]$panell.Children.Add($botoProgramar)
    [void]$panell.Children.Add($botoContinuar)

    $finestra.Content = $panell

    [void]$finestra.ShowDialog()

    return $finestra.Tag
}


# ============================================================
# PROGRAMA PRINCIPAL
# ============================================================

while ($true) {

    Write-Host "Treballant durant $TempsTreball minuts..."

    Start-Sleep -Seconds ($TempsTreball * 60)

    # --------------------------------------------------------
    # PRIMER AVÍS
    # --------------------------------------------------------

    $resposta = Mostra-Finestra `
        "🙂" `
        "Ja has treballat durant $TempsTreball minuts.`nVols fer una pausa?" `
        "Fer un descans" `
        "Continuar treballant"

    if ($resposta -eq $true) {
        Descans -DuradaMinuts $TempsDescans
        continue
    }

    # --------------------------------------------------------
    # SEGONA PREGUNTA
    # --------------------------------------------------------

    $segonaResposta = Mostra-Finestra `
        "🤔" `
        "Segur que no vols descansar?`nHauries de fer una pausa." `
        "D'acord, descansaré" `
        "No, continuaré treballant"

    if ($segonaResposta -eq $true) {
        Descans -DuradaMinuts $TempsDescans
        continue
    }

    # --------------------------------------------------------
    # PROGRAMAR UN AVÍS OPCIONAL
    # --------------------------------------------------------

    $horaAvis = Selecciona-HoraAvis

    if ($horaAvis -eq "NO_PROGRAMAR") {

        Write-Host "No s'ha programat cap altre avís."

        $respostaFinal = Mostra-Finestra `
            "👍" `
            "D'acord.`nContinua treballant i cuida't quan puguis." `
            "Fer un descans ara" `
            "Continuar treballant"

        if ($respostaFinal -eq $true) {
            Descans -DuradaMinuts $TempsDescans
        }

        continue
    }

    if ($null -eq $horaAvis) {
        continue
    }

    $ara = Get-Date

    $segonsFinsAvis = [int][Math]::Ceiling(
        ($horaAvis - $ara).TotalSeconds
    )

    if ($segonsFinsAvis -lt 1) {
        $segonsFinsAvis = 1
    }

    $horaText = $horaAvis.ToString("HH:mm")

    # --------------------------------------------------------
    # CONFIRMACIÓ DE L'HORA PROGRAMADA
    # --------------------------------------------------------

    $textConfirmacio =
        "T'avisaré a les $horaText.`n`n" +
        "Serà només un recordatori opcional."

    [void](Mostra-Finestra `
        "⏰" `
        $textConfirmacio `
        "Entesos" `
        "")

    Write-Host "Et recordaré descansar a les $horaText."
    Write-Host "Esperant $segonsFinsAvis segons..."

    Start-Sleep -Seconds $segonsFinsAvis

  # --------------------------------------------------------
    # AVÍS PROGRAMAT OPCIONAL
    # --------------------------------------------------------

    $textAvis =
        "És l'hora del recordatori opcional.`n`n" +
        "Vols fer ara una pausa?"

    $respostaAvis = Mostra-Finestra `
        "⏰🙂" `
        $textAvis `
        "Fer un descans" `
        "Continuar treballant"

    if ($respostaAvis -eq $true) {
        Descans -DuradaMinuts $TempsDescans
    }
    else {
        Write-Host "Has decidit continuar treballant."
    }

    # El cicle torna a començar
}