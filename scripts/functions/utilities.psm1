function Join-HashTables(
  [Parameter(Mandatory = $true)]
  [Hashtable] $hashTable1,

  [Parameter(Mandatory = $true)]
  [Hashtable] $hashTable2
) {
  $keys = $hashTable1.GetEnumerator() | ForEach-Object { $_.Key }
  $keys | ForEach-Object {
    $key = $_
    if ($hashTable2.ContainsKey($key)) {
      $hashTable1.Remove($key)
    }
  }
  return ($hashTable1 + $hashTable2)
}

function Write-Exception(
  [Parameter(Mandatory = $true)]
  [object] $ex
) {
  
  Write-Host -ForegroundColor Red "Exception $($ex.Exception.Message) ($($ex.Exception.GetType()))"

  if ($ex.Exception.InnerException) {
    Write-Host -ForegroundColor Red "Inner exception: $($ex.Exception.InnerException.Message)"
  }

  if ($ex.ScriptStackTrace) {
    Write-Host -ForegroundColor Red $_.ScriptStackTrace
  }
}

function Get-CurrentIpAddress() {
  return Invoke-RestMethod -Uri "https://ipinfo.io/json" -Verbose:$false | Select-Object -ExpandProperty ip
}

function Get-JSONFromInBicep(
  [Parameter(Mandatory = $true)]
  [string] $JSON
) {
  if (-not (Test-Json $JSON -ErrorAction SilentlyContinue)) {
    $JSON = $JSON.TrimEnd()
    $lines = $JSON -split "`n"
    if ($lines.Count -gt 1) {
      # Join with ",`n" but skip the first line
      $JSON = "{`n"
      $JSON += $lines[1..($lines.Count - 2)] -join ",`n"
        
      # Add the last line back without comma
      $JSON += ",`n" + $lines[-1]
    }
    $result = Test-Json $JSON -ErrorAction SilentlyContinue
  }
  else {
    $result = $true
  }

  if ($result) {
    return $JSON
  }
  else {
    throw "JSON cannot be formatted"
  }
}

function Test-Any() {
  begin {
    $any = $false
  }
  process {
    $any = $true
  }
  end {
    $any
  }
}

function Compare-AzurePALId(
  [Parameter(Mandatory = $true)]
  [int] $partnerId
) {
  $AzurePAL = $null 
  $AzurePAL = Get-AzManagementPartner -ErrorAction SilentlyContinue
  if ($null -ne $AzurePAL) {
    if ($AzurePAL.PartnerId -eq $partnerId.ToString()) {
      return $true
    }
    else {
      return $false
    }
  }
  else {
    return $false
  }
}

Export-ModuleMember -Function * -Verbose:$false
