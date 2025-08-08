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

Write-Host "Getting access token for SQL Server..."
# Get access token for SQL Server using the current Azure CLI session
$accessToken = az account get-access-token --resource https://database.windows.net/ --query accessToken --output tsv

if (-not $accessToken) {
  Write-Error "Error: Could not get access token for SQL Server."
  exit 1
}

# Define the SQL commands as a string
$sqlCommands = @"
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = '$PrincipalName')
BEGIN
    CREATE USER [$PrincipalName] FROM EXTERNAL PROVIDER;
END
ALTER ROLE db_owner ADD MEMBER [$PrincipalName];
"@

try
{
  Invoke-Sqlcmd -ServerInstance $SqlServerName `
                    -Database $DatabaseName `
                    -Query $sqlCommands `
                    -AccessToken $accessToken `
                    -ErrorAction Stop
  
  Write-Host "Successfully granted db_owner role to $PrincipalName"
}
catch {
  Write-Error "Error: Failed to execute SQL commands on database '$DatabaseName'."
  Write-Error "Exception: $($_.Exception.Message)"
  exit 1
}
