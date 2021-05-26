terraform {
  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      version = ">=2.43.0"
      source  = "hashicorp/azurerm"
    }
    azuread = {
      version = ">=0.7.0"
      source  = "hashicorp/azuread"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}