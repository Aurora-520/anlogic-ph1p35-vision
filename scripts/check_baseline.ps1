param(
    [string]$ProjectRoot = (Split-Path -Parent $PSScriptRoot)
)

$al = Join-Path $ProjectRoot 'td_project\camera_to_dsi_display.al'
$sdc = Join-Path $ProjectRoot 'td_project\camera_to_dsi_display.sdc'
$top = Join-Path $ProjectRoot 'rtl\app\design_top_wrapper.v'
$pin = Join-Path $ProjectRoot 'user_source\constraints_source\pin.adc'

$required = @($al, $sdc, $top, $pin)
$missing = $required | Where-Object { -not (Test-Path -LiteralPath $_) }
if ($missing) {
    Write-Error ('Missing baseline files:`n' + ($missing -join "`n"))
    exit 1
}

$alText = Get-Content -LiteralPath $al -Raw -Encoding UTF8
$checks = [ordered]@{
    'Device PH1P35MDG324' = $alText -match '<Device>PH1P35MDG324</Device>'
    'Top design_top_wrapper' = $alText -match '<MODULE>design_top_wrapper</MODULE>'
    'Vendor baseline core' = Test-Path -LiteralPath (Join-Path $ProjectRoot 'vendor_reference\rtl\vendor_lab1_core.v')
    'Application pipeline boundary' = Test-Path -LiteralPath (Join-Path $ProjectRoot 'rtl\app\vision_pipeline.v')
    '720p60 register table' = Test-Path -LiteralPath (Join-Path $ProjectRoot 'user_source\hdl_source\uics500_cfg\uics500reg_720p60.v')
    'MIPI wrapper' = Test-Path -LiteralPath (Join-Path $ProjectRoot 'user_source\hdl_source\mipi_dphy_rx\mipi_dphy_rx_ph1p_mipiio_wrapper.sv')
    'DDR wrapper' = Test-Path -LiteralPath (Join-Path $ProjectRoot 'user_source\hdl_source\ph1p35_ddr\ph1p35_324_ddr_wrapper.v')
    'HDMI TX' = Test-Path -LiteralPath (Join-Path $ProjectRoot 'user_source\hdl_source\hdmi_tx.v')
}

$checks.GetEnumerator() | ForEach-Object {
    $state = if ($_.Value) { 'OK' } else { 'MISSING' }
    '{0}: {1}' -f $state, $_.Key
}

if ($checks.Values -contains $false) { exit 1 }
Write-Output 'Baseline project structure is ready for TD.'
