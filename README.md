# Berealty — Real Estate Property Management Database

A complete MySQL database system for a fictional Berlin real estate agency:
ER design, normalized schema, constraints, triggers, and a portfolio of SQL
queries from basic retrieval to multi-table reports.
Built for the MSc Data Analytics module *Database Management Systems*.

## Structure

```
berealty-database/
├── sql/schema.sql          # Tables, constraints, and 3 triggers
├── sql/sample_data.sql     # Realistic Berlin sample records
├── sql/queries.sql         # 14 queries + live trigger demonstration
├── figures/er_diagram.png  # Entity-Relationship diagram
└── README.md
```

## Setup & run

Requires MySQL 8+ or MariaDB 10.4+.

```bash
mysql -u root -p < sql/schema.sql        # create DB, tables, triggers
mysql -u root -p < sql/sample_data.sql   # load sample data (triggers fire)
mysql -u root -p -t berealty < sql/queries.sql   # run the full query portfolio
```

The `-t` flag prints results as formatted tables. Individual queries can also
be pasted into MySQL Workbench; each is numbered (Q1–Q14) and commented.

## What's inside

**Schema** — 6 tables (agents, clients, properties, viewings, transactions,
property_status_log) in third normal form, with primary/foreign keys, UNIQUE
and CHECK constraints, and ENUM-typed categorical fields.

**Triggers** — commission auto-calculation from each agent's personal rate
(BEFORE INSERT), automatic property status update on completed transactions
(AFTER INSERT), and an audit log of every status change (AFTER UPDATE).

**Queries** — property retrieval and portfolio management; INNER/LEFT/RIGHT/
CROSS JOIN reports each solving a distinct business problem; correlated
subqueries (district-level overpricing check, top sale per district); and
monthly, quarterly and yearly revenue reports.

## Tech stack

MySQL / MariaDB · SQL (DDL, DML, triggers)
