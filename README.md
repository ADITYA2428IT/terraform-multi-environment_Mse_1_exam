# Terraform Multi-Environment AWS Infrastructure

## 📌 Overview

This project demonstrates how to provision and manage multiple AWS environments using **Terraform Infrastructure as Code (IaC)**.

The project uses the **same Terraform configuration** for two environments:

- **DEV** → Mumbai (`ap-south-1`)
- **PROD** → N. Virginia (`us-east-1`)

Terraform Workspaces, Variables, `.tfvars` files and Data Sources are used to create environment-specific infrastructure.

---

## 🏗️ Architecture

```text
                         Terraform
                             |
              +--------------+--------------+
              |                             |
        DEV Workspace                  PROD Workspace
              |                             |
        ap-south-1                      us-east-1
              |                             |
        1 × t3.micro                  3 × t3.small
              |                             |
              +--------------+--------------+
                             |
                           AWS EC2
                             |
                           Nginx
                             |
                       Web Application