# Recommended Solution and Remediation Plan

## 1. Objective

The objective of the remediation plan is not only to improve performance, but to correct the structural weaknesses that appeared after three years of operation.

The proposed solution aims to:

- stabilize the current platform
- restore data integrity
- improve operational performance
- isolate poor-quality upstream data
- separate transactional and reporting workloads
- prepare the platform for long-term growth

---

## 2. Solution Overview

The current SQL Server implementation should evolve from a mixed-use database into a more controlled architecture with clearer workload boundaries.

### Strategic direction
The recommended direction is:

- keep **SQL Server** as the operational platform for the web application
- keep **Oracle** as an upstream legacy data source while it is still needed
- strengthen the **integration layer** so poor source data does not break downstream processes
- separate **operational processing** from **historical/reporting consumption**
- redesign the handling of very large reporting tables with scalability mechanisms

---

## 3. Remediation Approach by Level

## 3.1 Immediate Stabilization

These actions should be implemented first to reduce operational pain in the current environment.

### 3.1.1 Fix critical queries and long-running jobs
Focus on the most expensive processes first:

- recurrent web timeouts
- reporting queries taking around 1 hour
- batch jobs taking around 3 hours

#### Actions
- review execution plans of the slowest queries
- identify missing indexes
- optimize joins, filters, and lookup paths
- remove unnecessary full scans where possible
- replace expensive row-by-row logic with set-based logic
- review heavy `MERGE`, `UPDATE`, and `JOIN` operations
- avoid functions in predicates and joins when possible

#### Expected result
- lower response times
- reduced timeout frequency
- shorter execution time for batch jobs and reporting queries

---

### 3.1.2 Implement database maintenance
The database currently lacks basic performance maintenance.

#### Actions
- implement scheduled statistics updates
- implement scheduled index maintenance
- monitor fragmentation on the largest tables
- purge or archive old control/log records
- monitor expensive queries and database growth

#### Expected result
- better execution plans
- more stable performance
- reduced degradation over time

---

### 3.1.3 Strengthen transaction handling in web processes
The existence of orphaned rows indicates weak transactional protection.

#### Actions
- review all critical web processes that write into multiple tables
- wrap related operations in proper database transactions
- enforce rollback on failure
- make multi-step writes atomic
- standardize error handling in both stored procedures and application logic

#### Expected result
- no more partial writes
- reduced risk of orphaned rows
- more reliable transactional behavior

---

### 3.1.4 Strengthen source data validation
Oracle-originated bad data should not continue breaking downstream jobs.

#### Actions
- validate required fields before loading operational tables
- classify data quality rules:
  - mandatory fields
  - valid codes
  - date consistency
  - amount consistency
- redirect invalid records to rejection/error tables
- allow batch continuation where business rules permit
- define controlled manual review for rejected records

#### Expected result
- stronger protection against poor upstream data
- fewer failed batch jobs
- more controlled handling of bad records

---

## 3.2 Structural Corrections in the Current SQL Server Solution

These actions address weaknesses in the current design, beyond tuning alone.

## 3.2.1 Separate OLTP from reporting-serving structures
One of the main problems is that operational and reporting workloads are too closely coupled.

#### Current issue
- reporting queries and functions depend on transactional and historical tables in the same environment
- large historical/reporting workloads create pressure on the operational platform

#### Solution
- keep the operational model focused on the web workflow
- move reporting-serving structures into a dedicated reporting layer
- stop relying on mixed functions that join transactional and historical tables for reporting purposes

#### Options
- preferred: create a separate reporting database
- minimum acceptable: clearly separate reporting-serving tables and processes from transactional structures inside SQL Server

#### Expected result
- less interference with web processes
- more predictable reporting performance
- clearer workload boundaries

---

### 3.2.2 Redesign very large historical/reporting tables
A table growing by 50 million rows per month requires specific physical design.

#### Actions
- partition large tables by time period, ideally by month
- add aligned indexes to support partitioned access
- define retention policy
- define archival strategy for older data
- avoid keeping all history in the same hot-access operational area
- create summary or aggregate tables for frequent reporting use cases

#### Expected result
- better performance on large-range queries
- easier maintenance
- easier purge/archive
- more sustainable growth model

---

### 3.2.3 Restore structural integrity controls
The current platform relies too much on procedures to enforce consistency.

#### Actions
- identify mandatory parent-child relationships
- reintroduce foreign keys in core transactional tables where the relationship must always exist
- add unique constraints or unique indexes where business keys must remain unique
- keep relaxed controls only in staging or controlled transient areas

#### Expected result
- fewer orphaned rows
- stronger data integrity
- less dependence on code for basic consistency

---

### 3.2.4 Replace heavy reporting functions with reporting-serving structures
Functions that join transactional and historical data create performance and design problems.

#### Actions
- replace heavy functions with pre-built reporting tables
- create scheduled summary tables for common reporting use cases
- avoid direct reporting queries over live transactional structures where possible
- reduce reuse of expensive function-based access patterns

#### Expected result
- faster reporting
- reduced query complexity
- lower pressure on OLTP tables

---

## 3.3 Long-Term Target Architecture

The platform should evolve toward a clearer multi-layer design.

## 3.3.1 Recommended logical architecture

### A. Integration layer
Purpose:
- receive Oracle data
- validate and standardize source data
- isolate poor-quality records
- control load status and errors

Components:
- staging tables
- rejection/error tables
- control and audit tables
- transformation logic

### B. Operational layer
Purpose:
- support the web application
- manage active business workflow
- hold operationally relevant data only

Characteristics:
- strong PK/FK/unique enforcement
- proper transaction handling
- optimized for low-latency operational access
- limited historical burden

### C. Reporting layer
Purpose:
- serve historical queries and reporting workloads

Characteristics:
- separate from OLTP workload
- optimized for large-range queries
- partitioned large tables
- summary tables where needed
- retention and archive model

---

## 4. Recommended Actions by Problem Area

| Problem Area | Recommended Action |
|---|---|
| Web timeouts on transactional processes | Optimize critical web queries, improve indexing, reduce heavy access to large tables, strengthen transactions |
| Batch jobs taking 3 hours | Review execution plans, redesign heavy jobs, partition large reporting tables, reduce full-table processing |
| Reporting queries taking 1 hour | Move reporting consumption to dedicated reporting structures, add summary tables, optimize indexing and storage strategy |
| Orphaned rows | Reintroduce FKs where mandatory, improve transaction handling, enforce rollback consistency |
| Reporting functions joining transactional and historical data | Replace with precomputed reporting tables and dedicated reporting-serving design |
| Batch failures due to poor Oracle data | Strengthen source validation, rejection handling, and data-quality shielding before operational load |
| No large-table scalability strategy | Implement partitioning, archival, retention, and maintenance model |
| Weak physical maintenance | Implement statistics update, index maintenance, and log/control-table retention |

---

## 5. Suggested Implementation Roadmap

## Phase 1 — Urgent Stabilization
Implement immediately:

- optimize the worst web queries
- optimize the slowest reporting queries
- optimize the longest batch jobs
- implement statistics maintenance
- implement index maintenance
- add stronger transaction handling to critical web processes
- isolate and reject invalid Oracle records before operational use
- clean up oversized control/log tables

### Goal
Reduce current pain and improve operational stability quickly.

---

## Phase 2 — Structural Improvement
Implement next:

- redesign heavy reporting functions
- add missing unique constraints
- restore mandatory foreign keys in core transactional tables
- partition the largest historical/reporting tables
- define retention and archive strategy
- reduce dependence on mixed transactional/historical query patterns

### Goal
Correct the most important structural weaknesses in the current SQL Server solution.

---

## Phase 3 — Target Architecture Evolution
Implement strategically:

- separate reporting workload from OLTP workload
- move historical/reporting consumption into a dedicated reporting layer
- simplify the operational database around active web workflow
- formalize source-data quality shielding in the integration layer
- move from reactive support to preventive operational governance

### Goal
Create a sustainable architecture that can continue growing without repeating the same problems.

---

## 6. Recommended Priority

If only a limited number of actions can be executed first, the highest-priority ones should be:

1. **separate reporting-serving workload from OLTP workload**
2. **partition and govern the very large historical/reporting tables**
3. **restore integrity controls with foreign keys and unique enforcement where mandatory**
4. **add robust transaction handling to web processes**
5. **implement database maintenance and source-data validation shielding**

These actions will produce the greatest impact on performance, integrity, and platform stability.

---

## 7. Final Recommendation

### Final statement
> The current solution should not be treated as a simple tuning problem. It requires both immediate stabilization and structural redesign.

### Key idea
The platform should continue using SQL Server as the operational engine, but it should stop forcing the same structures to support transactional processing, massive historical growth, and reporting consumption at the same time.

### Expected outcome
If the remediation plan is implemented correctly, the expected benefits are:

- fewer web timeouts
- shorter batch runtimes
- faster reporting
- fewer integrity issues
- fewer failures caused by bad source data
- better long-term scalability
- more stable support operations

---