Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName System.Windows.Forms

$xamlString = Get-Content -Path ".\dpi_gui.xaml" -Raw
$xmlReader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($xamlString))

try {
    $window = [Windows.Markup.XamlReader]::Load($xmlReader)
} catch {
    [System.Windows.MessageBox]::Show("Failed to load XAML.`n$($_.Exception.Message)", "Error", "OK", "Error")
    exit
}

$resolutionText = $window.FindName("ResolutionText")
$inchInput = $window.FindName("InchInput")
$dpiResult = $window.FindName("DPIResult")
$calcBtn = $window.FindName("CalcBtn")

if (-not $resolutionText -or -not $inchInput -or -not $dpiResult -or -not $calcBtn) {
    [System.Windows.MessageBox]::Show("Failed to find required UI elements.", "Error", "OK", "Error")
    exit
}

$width = [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize.Width
$height = [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize.Height
$resolutionText.Text = "$width x $height"

$calcBtn.Add_Click({
    $inch = $inchInput.Text.Trim()
    if ([double]::TryParse($inch, [ref]$null) -and [double]$inch -gt 0) {
        $pixels = [math]::Sqrt(($width * $width) + ($height * $height))
        $dpi = [math]::Round($pixels / [double]$inch, 2)
        $dpiResult.Text = "Calculated DPI: $dpi"
    } else {
        [System.Windows.MessageBox]::Show("Please enter a valid positive number for inches.", "Input Error", "OK", "Error")
    }
})

$window.ShowDialog() | Out-Null
