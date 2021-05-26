MI_NAME='<your managed identity>' # <<<<<<<<<<<< put your Managed Identity Name here

echo Managed Identity Name = $MI_NAME

SUBSCRIPTION_ID=########-####-####-####-############ # <<<<<<<<< put your subscription ID here

echo SUBSCRIPTION_ID = $SUBSCRIPTION_ID

az login # <<<<<<<< this will launch browser for Enrollment Account login

BILLING_ACCOUNT_NAME=$(az rest --method get --url 'https://management.azure.com/providers/Microsoft.Billing/billingAccounts?api-version=2019-10-01-preview'| jq '.value[0].name' --raw-output)

echo BILLING_ACCOUNT_NAME = $BILLING_ACCOUNT_NAME

ENROLLMENT_ACCOUNT_NAME=$(az rest --method get --url 'https://management.azure.com/providers/Microsoft.Billing/billingAccounts?api-version=2019-10-01-preview'| jq '.value[0].properties.enrollmentAccounts[0].name' --raw-output)

echo ENROLLMENT_ACCOUNT_NAME = $ENROLLMENT_ACCOUNT_NAME

BILLING_ROLE_ASSIGNMENT_NAME=$(az rest --method get --url https://management.azure.com/providers/Microsoft.Billing/billingAccounts/$BILLING_ACCOUNT_NAME/enrollmentAccounts/$ENROLLMENT_ACCOUNT_NAME/billingRoleDefinitions --url-parameters api-version=2019-10-01-preview billingAccountName=$BILLING_ACCOUNT_NAME enrollmentAccountName=$ENROLLMENT_ACCOUNT_NAME | jq '.value[1].name' --raw-output)

echo BILLING_ROLE_ASSIGNMENT_NAME = $BILLING_ROLE_ASSIGNMENT_NAME

TENANT_ID=$(az rest --method get --url 'https://management.azure.com/providers/Microsoft.Billing/billingAccounts?api-version=2019-10-01-preview'| jq '.value[1].properties.omsAccountDetails.identity.identifier.id' --raw-output)

echo TENANT_ID = $TENANT_ID

PRINCIPAL_ID=$(az identity list --subscription $SUBSCRIPTION_ID | jq -r --arg MI_NAME "$MI_NAME" '.[] | select(.name == $MI_NAME)' | jq '.principalId' --raw-output)

echo Managed Identity PrincipalID = $PRINCIPAL_ID

ROLE_DEF_ID=/providers/Microsoft.Billing/billingAccounts/$BILLING_ACCOUNT_NAME/enrollmentAccounts/$ENROLLMENT_ACCOUNT_NAME/billingRoleAssignments/$BILLING_ROLE_ASSIGNMENT_NAME

echo ROLE_DEF_ID = $ROLE_DEF_ID

JSON_STRING=$( jq -n --arg rdi "$ROLE_DEF_ID" --arg ti "$TENANT_ID" --arg pi "$PRINCIPAL_ID" '{"properties":{"principalId":$pi,"principalTenantId":$ti,"roleDefinitionId":$rdi}}')

echo $JSON_STRING > ./body.json

az rest --method put --url https://management.azure.com/providers/Microsoft.Billing/billingAccounts/$BILLING_ACCOUNT_NAME/enrollmentAccounts/$ENROLLMENT_ACCOUNT_NAME/billingRoleAssignments/$BILLING_ROLE_ASSIGNMENT_NAME --url-parameters api-version=2019-10-01-preview billingAccountName=$BILLING_ACCOUNT_NAME enrollmentAccountName=$ENROLLMENT_ACCOUNT_NAME billingRoleAssignmentName=$BILLING_ROLE_ASSIGNMENT_NAME --body @body.json

rm ./body.json