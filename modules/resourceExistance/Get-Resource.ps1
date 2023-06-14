param
(
  [Parameter(Mandatory)]
  [string[]]$Id,

  [Parameter()]
  [hashtable]$PropertyMap
)
$DeploymentScriptOutputs = @{}
foreach ($rid in $Id) {
  try {
    $r = Get-AzResource -ResourceId $rid -ErrorAction Stop
  } catch {

  }
  if ($r) {
    $result = @{
      exists = $true
    }
    if ($PSBoundParameters.ContainsKey('PropertyMap')) {
      foreach ($p in $PropertyMap.Keys) {
        $result[$p] = $PropertyMap[$p].InvokeWithContext($null, [psvariable]::new('res', $r)) | ConvertTo-Json -Depth 10
      }
    }
  } else {
    $result = @{
      exists = $false
    }
  }
  $DeploymentScriptOutputs[$rid] = $result
}
