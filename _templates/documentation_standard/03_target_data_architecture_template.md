# Target Data Architecture

## Document Goal

This document describes the <Target Component>, <Target Component>, and <Consumption Layer> objects that support the target reporting platform.

## Target Data Architecture Overview

The target data architecture is organized by data area and modeling responsibility.

| Architecture Area | Target Component | Target Component Name | Main Responsibility |
|---|---|---|---|
| <Layer Name> | <Target Component> | <Target Component Name> | <Main Responsibility> |
| <Layer Name> | <Target Component> | <Target Component Name> | <Main Responsibility> |
| <Layer Name> | <Target Component> | <Target Component Name> | <Main Responsibility> |
| <Consumption Layer> | <Target Component> | <Target Component Name> | Provides the governed reporting consumption layer |

## <Target Component>

The <Target Component> is organized into <Layer Name> and <Layer Name> areas.

| Schema / Area | Purpose |
|---|---|
| <Schema Name> | <Purpose> |
| <Schema Name> | <Purpose> |

### <Layer Name> Tables

<Layer Name> tables store <Purpose> from <Source System>.

| Data Category | Source Schema | Source Table | Target Schema | Target Table | Purpose |
|---|---|---|---|---|---|
| <Data Category> | <Schema Name> | <Table Name> | <Schema Name> | <Table Name> | <Purpose> |
| <Data Category> | <Schema Name> | <Table Name> | <Schema Name> | <Table Name> | <Purpose> |

#### <Layer Name> Rules

| Rule | Description |
|---|---|
| Source alignment | <Description> |
| Data quality | <Description> |
| Traceability | <Description> |
| Consumption boundary | <Description> |

### <Layer Name> Tables

<Layer Name> tables store curated or transformed data from <Source Layer>.

| Data Category | Source Inputs | Target Schema | Target Table | Purpose |
|---|---|---|---|---|
| <Data Category> | <Source Inputs> | <Schema Name> | <Table Name> | <Purpose> |
| <Data Category> | <Source Inputs> | <Schema Name> | <Table Name> | <Purpose> |

#### <Layer Name> Rules

| Rule | Description |
|---|---|
| Historical alignment | <Description> |
| Future alignment | <Description> |
| Source traceability | <Description> |
| Reporting readiness | <Description> |

## <Consumption Layer>

The <Consumption Layer> provides the governed reporting consumption layer over <Reporting Layer> objects.

| Consumption Object | Source | Purpose |
|---|---|---|
| <Consumption Object Name> | <Source Object> | Provides governed reporting consumption over <Reporting Layer> |

### <Consumption Layer> Rules

| Rule | Description |
|---|---|
| Reporting access | Reports should consume the governed consumption layer instead of directly querying technical layers |
| Business definitions | Measures, relationships, and business terms should be defined consistently for reporting |
| Data dependency | The consumption layer should depend on approved reporting-ready objects |
| Consumer focus | Technical ingestion, staging, and transformation structures should be hidden from report users |

## Target Object Naming

| Object Type | Convention | Example |
|---|---|---|
| Raw table | <Naming Convention> | <Example Name> |
| Curated table | <Naming Convention> | <Example Name> |
| Staging table | <Naming Convention> | <Example Name> |
| Reporting dimension | <Naming Convention> | <Example Name> |
| Reporting fact | <Naming Convention> | <Example Name> |
| Surrogate key | <Naming Convention> | <Example Name> |
| Source key | <Naming Convention> | <Example Name> |
| Technical column | <Naming Convention> | <Example Name> |

## Technical Metadata Columns

Target tables should include technical metadata columns where required for traceability.

| Column | Purpose |
|---|---|
| <Column Name> | Identifies <Purpose> |
| <Column Name> | Identifies <Purpose> |
| <Column Name> | Identifies <Purpose> |
