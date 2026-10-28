terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "5.0.0"

    }
  }
}

provider "azurerm" {
  subscription_id = "15562448-510d-4c24-b2f2-08b2970ef823"
    
  features {}
}