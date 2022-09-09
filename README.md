# AKS-Private

## Bonita
Bonita is an open-source business process management and workflow suite created in 2001. It was started in France National Institute for Research in Computer Science, and then had incubated several years inside the French computer science company Groupe Bull. Since 2009, the development of Bonita is supported by a company dedicated to this activity: Bonitasoft.

https://hub.docker.com/_/bonita/

https://wikipedia.org/wiki/Bonita_BPM

## Challenge

Create AKS cluster that implement Bonita workload, this cluster may be totally private, and cover a complete security standard, bonita is using a postgress SQL databases, this may be save data in volumes in case of cluster disaster. AKS cluster may be monitoring using grafana dashboard.

### Thechnology

* Bonita
* Postgres SQL
* Azure Kubernetes Services
* YAML
* Key Vault
* Azure Files

### Azure Architecture

[Architecture](https://github.com/RodrigoVeraSYS/AKS-Private/blob/main/Docs/AzureArquitecture.md "Architecture")

### Azure Architecture Implementation

[Architecture Implementation](https://github.com/RodrigoVeraSYS/AKS-Private/blob/main/Docs/AzureArchitectureImplementation.md "Architecture Implementation")

### AKS Implementation

[AKS Application Implementation](https://github.com/RodrigoVeraSYS/AKS-Private/blob/main/Docs/AKSImplementation.md "AKS Application Implementation")


