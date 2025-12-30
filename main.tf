# Customize to suit your project

provider "azurerm" {
  features {}
}

provider "databricks" {
  azure_workspace_resource_id = azurerm_databricks_workspace.example.id
  azure_client_id             = var.client_id
  azure_client_secret         = var.client_secret
  azure_tenant_id             = var.tenant_id
}

# -------------------------------
# Azure Databricks Workspace
# -------------------------------
resource "azurerm_databricks_workspace" "example" {
  name                = "sm-productionline-dbricks"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "premium"
}

# -------------------------------
# Databricks Cluster
# -------------------------------
resource "databricks_cluster" "example_cluster" {
  cluster_name            = "sm-prodline-cluster"
  spark_version           = "14.0.x-scala2.12"
  node_type_id            = "Standard_DS3_v2"
  autotermination_minutes = 30
  num_workers             = 2
}

# -------------------------------
# Storage Mount (Landing Zone)
# -------------------------------
resource "databricks_secret_scope" "example_scope" {
  name = "sm-storage-scope"
}

resource "databricks_mount" "landing_mount" {
  mount_name       = "00_landing"
  storage_account  = var.storage_account_name
  container_name   = var.container_name
  tenant_id        = var.tenant_id
  client_id        = var.client_id
  client_secret    = var.client_secret
}

# -------------------------------
# Delta Live Tables Pipeline
# -------------------------------
resource "databricks_dlt_pipeline" "sm_pipeline" {
  name                    = "sm-productionline-pipeline"
  storage                 = "dbfs:/pipelines/sm-productionline/"
  configuration = {
    "clusters.single_node.type" = "existing_cluster"
    "clusters.single_node.id"   = databricks_cluster.example_cluster.id
  }
  development              = false
  continuous               = true
  target                   = "default"
  libraries = []
  notebook_path            = "/Repos/your_repo/SmartManufacturing/01_bronze_processing"
}
