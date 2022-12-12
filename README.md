# Synapse ARM/Bicep deployment example

## Description
This repository is a minimal example on how to deploy a Synapse workspace with ARM/Bicep.

> **TL;DR: Not everything is possible in ARM/Bicep, it's a two step process** 
> First the Azure Resource can be created with ARM/Bicep, but Linked Services, Notebooks, Synapse RBAC and Managed Private Endpoints are not available in ARM/Bicep. These resources can only be created with the Synapse API's.

> Links to the official deployment documentation:
https://learn.microsoft.com/en-us/azure/synapse-analytics/cicd/continuous-integration-delivery


> **TL;DR 2: It's possible if you integrate the other API calls into the Bicep with 'DeploymentScripts'** 
> See the example here: https://github.com/Azure/azure-synapse-analytics-end2end
>



## Features
- [x] Create a Synapse workspace
- [ ] Create a Linked Service Example
- [ ] Create a private Managed Endpoint
- [ ] Add Synapse RBAC rules

## How to test it
```
az deployment sub create --location westeurope --template-file main.bicep --debug -w

```

## What is missing in ARM/Bicep:
- Linked Services
- Managed Private Endpoint
- Synapse RBAC
- Notebooks
- SQL Scripts
- Spark Job Definitions
- Pipelines
- Datasets
- ... all things create in Synapse in general

## Why are these services missing?
In general, ARM Bicep can only call Azure Resource Manager API's. The Linked Services, Managed Private Endpoint and Synapse RBAC are not available in the ARM API's. This is why we need to use the Synapse API's to create these resources.

## How to use the Synapse API's
There are multiple ways to use it:
- With the Azure CLI `az synapse ...`
- With the Synapse SDK (e.g. for Python)
- Via the REST API
- Via an Azure DevOps / GitHub Action: https://learn.microsoft.com/en-us/azure/synapse-analytics/cicd/continuous-integration-delivery
