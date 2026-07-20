# Source Data Profile

## Document Goal

This document describes the source systems, their roles, source object categories, estimated data volumes, growth assumptions, and how each source contributes to the target reporting platform.

## Source Platform Overview

The current <Business Domain> platform runs on <Source Platform>, and it contains <Number> source systems with different responsibilities.

| Source System | Current Responsibility | Data Model | Modernization Role |
|---|---|---|---|
| <Source System> | <Current Responsibility> | <Data Model> | <Modernization Role> |
| <Source System> | <Current Responsibility> | <Data Model> | <Modernization Role> |

## Source Data Categories

The source data is grouped by business and analytical role.

| Data Category | Description | Source System | Expected Data Volume | Estimated Row Count |
|---|---|---|---|---|
| Reference / Lookup | Stable or low-change descriptive values | <Source System> | <Low/Medium/High> | <Estimated Row Count> |
| Master / Core | Business entities | <Source System> | <Low/Medium/High> | <Estimated Row Count> |
| Transactional | Business events or transactions | <Source System> | <Low/Medium/High> | <Estimated Row Count> |
| Analytical Dimensions | Reporting-ready descriptive structures | <Source System> | <Low/Medium/High> | <Estimated Row Count> |
| Analytical Facts | Reporting-ready measurable business events | <Source System> | <Low/Medium/High> | <Estimated Row Count> |

## Source Volume Summary

| Source System | Rows | Data Size | Index Size |
|---|---|---|---|
| <Source System> | <Estimated Rows> | <Estimated Data Size> | <Estimated Index Size> |
| <Source System> | <Estimated Rows> | <Estimated Data Size> | <Estimated Index Size> |
| **Total** | **<Estimated Rows>** | **<Estimated Data Size>** | **<Estimated Index Size>** |

## <Source System> Source Tables

For target ingestion, only approved persisted business tables from <Schema Name> are included in the <Source System> source inventory.

| Data Category | Source Schema | Source Table | Estimated Monthly Growth | Estimated Current Rows | Estimated Current Data Size | Estimated Current Index Size |
|---|---|---|---|---|---|---|
| <Data Category> | <Schema Name> | <Table Name> | <Growth Estimate> | <Estimated Rows> | <Estimated Data Size> | <Estimated Index Size> |
| <Data Category> | <Schema Name> | <Table Name> | <Growth Estimate> | <Estimated Rows> | <Estimated Data Size> | <Estimated Index Size> |

## <Source System> Source Tables

For target ingestion, only approved reporting or analytical tables from <Schema Name> are included in the <Source System> source inventory.

| Data Category | Source Schema | Source Table | Estimated Monthly Growth | Estimated Current Rows | Estimated Current Data Size | Estimated Current Index Size |
|---|---|---|---|---|---|---|
| <Data Category> | <Schema Name> | <Table Name> | <Growth Estimate> | <Estimated Rows> | <Estimated Data Size> | <Estimated Index Size> |
| <Data Category> | <Schema Name> | <Table Name> | <Growth Estimate> | <Estimated Rows> | <Estimated Data Size> | <Estimated Index Size> |
