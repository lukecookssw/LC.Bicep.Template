param(
  [string]$ResourceGroup,
  [string]$SqlServerName,
  [string]$DatabaseName,
  [string]$PrincipalName
)

Write-Host "Granting db_owner role to $PrincipalName on $DatabaseName in $SqlServerName..."

Write-Host "Installing required PowerShell modules..."
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name SqlServer -AllowClobber -Scope CurrentUser -Confirm:$false
Install-Module -Name Az.Accounts -Repository PSGallery -Scope CurrentUser -Force -AllowClobber

Write-Host "Getting principal ID..."
# Get the App Service's principal ID (the managed identity)
$principalId = az webapp identity show `
  --name $PrincipalName `
  --resource-group $ResourceGroup `
  --query principalId `
  --output tsv

if (-not $principalId) {
  Write-Error "Error: Could not find principal ID for App Service '$PrincipalName'."
  exit 1
}

# Define the SQL commands as a string
$sqlCommands = @"
CREATE USER [$PrincipalName] FROM EXTERNAL PROVIDER;
ALTER ROLE db_owner ADD MEMBER [$PrincipalName];
"@

try
{
  Invoke-Sqlcmd -ServerInstance $SqlServerName `
                    -Database $DatabaseName `
                    -Username 'sqlAdmin' `
                    -Password 'sqlPW!2@23iuhFDFDaf23987@#%1'
                    -Query $sqlCommands `
                    -ErrorAction Stop
}
catch {
  Write-Error "Error: Failed to execute SQL commands on database '$DatabaseName'."
  Write-Error "Exception: $($_.Exception.Message)"
  exit 1
}
