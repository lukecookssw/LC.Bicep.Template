# Set variables
RESOURCE_GROUP=$1
SQL_SERVER_NAME=$2
DATABASE_NAME=$3
PRINCIPAL_NAME=$4

# Get the App Service's principal ID (the managed identity)
PRINCIPAL_ID=$(az webapp identity show \
  --name $PRINCIPAL_NAME \
  --resource-group $RESOURCE_GROUP \
  --query principalId \
  --output tsv)

# Check if the principal ID was retrieved
if [ -z "$PRINCIPAL_ID" ]; then
  echo "Error: Could not find principal ID for App Service '$PRINCIPAL_NAME'."
  exit 1
fi

# Connect to the SQL server using the managed identity
# You'll need to use an identity-enabled connection string or client.
# This example uses the 'az sql' command to execute a script.

# Define the SQL commands as a string
SQL_COMMANDS="
  CREATE USER [${PRINCIPAL_NAME}] FROM EXTERNAL PROVIDER;
  ALTER ROLE db_owner ADD MEMBER [${PRINCIPAL_NAME}];
"

# Execute the SQL commands on the database
az sql db execute-script \
  --resource-group $RESOURCE_GROUP \
  --server $SQL_SERVER_NAME \
  --name $DATABASE_NAME \
  --sql-script "$SQL_COMMANDS"