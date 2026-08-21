# Target Setup

## Document Goal

This document provides the execution sequence for configuring, validating, and rolling back the target objects required by the project.

## Prerequisites

This document assumes that the following Azure SQL databases have already been created and are accessible:

- `Enterprise_Operational`
- `DataOps_Control`

`DataOps_Control` is an existing shared control database. Its database creation and base implementation are outside the scope of this project.

## Setup Flow

### Enterprise_Operational

Create objects by running scripts located in `ddl`.

1. Run `01_create_schema_prod.sql`.

Create objects by running scripts located in `security`.

1. Run `01_create_security_objects.sql`.

Validate objects by running scripts located in `security`.

1. Run `00_evaluate_security_objects.sql`.
2. Run `02_validate_permissions.sql`.

### DataOps_Control

Create objects by running scripts located in `security`.

1. Run `01_create_security_objects.sql`.

Validate objects by running scripts located in `security`.

1. Run `00_evaluate_security_objects.sql`.
2. Run `02_validate_permissions.sql`.

## Rollback

### Enterprise_Operational

Drop objects by running scripts located in `cleanup/objects`.

1. Run `90_cleanup_schema_prod.sql`.

Drop objects by running scripts located in `cleanup/security`.

1. Run `90_cleanup_security_objects.sql`.

### DataOps_Control

Drop objects by running scripts located in `cleanup`.

1. Run `90_cleanup_security_objects.sql`.
