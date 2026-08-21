# Source Setup

## Document Goal

This document provides the execution sequence for configuring, validating, and rolling back the source security objects required by the project.

## Prerequisites

This document assumes that the following source databases have already been installed, created, and are accessible:

- Oracle database containing the `ADVENTUREWORKS2022` schema.
- SQL Server database `Sales_Operational`.

Database installation and initial database creation are outside the scope of this document.

## Setup Flow

### ADVENTUREWORKS2022

Create objects by running scripts located in `security`.

1. Run `01_create_security_objects.sql`.

Validate objects by running scripts located in `security`.

1. Run `00_evaluate_security_objects.sql`.
2. Run `02_validate_permissions.sql`.

### Sales_Operational

Create objects by running scripts located in `security`.

1. Run `01_create_security_objects.sql`.

Validate objects by running scripts located in `security`.

1. Run `00_evaluate_security_objects.sql`.
2. Run `02_validate_permissions.sql`.

## Rollback

### ADVENTUREWORKS2022

Drop objects by running scripts located in `cleanup`.

1. Run `90_cleanup_security_objects.sql`.

### Sales_Operational

Drop objects by running scripts located in `cleanup`.

1. Run `90_cleanup_security_objects.sql`.
