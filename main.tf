locals {

    billing_account_info = jsondecode(data.http.billing_account_request.body)

}

data "http" "billing_account_request" {
  url = "https://management.azure.com/providers/Microsoft.Billing/billingAccounts?api-version=2019-10-01-preview"

  # Optional request headers
  request_headers = {
    Accept = "application/json"
    Authorization = var.token
  }
}

output "billing_account_name" {
    value = local.billing_account_info.value[0].name
}

output "enrollment_account_name" {
    value = local.billing_account_info.value[0].properties.enrollmentAccounts[0].name
}