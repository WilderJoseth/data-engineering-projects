CREATE SCHEMA staging;

CREATE SCHEMA production;

CREATE TABLE staging.fact_missions (
    company VARCHAR(50) NOT NULL,
    location VARCHAR(100) NOT NULL,
    date DATE NOT NULL,
    rocket VARCHAR(50) NOT NULL,
    mission VARCHAR(50) NOT NULL,
    rocket_status VARCHAR(15) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    mission_status VARCHAR(15) NOT NULL,
    country VARCHAR(20) NOT NULL
);

CREATE TABLE production.fact_missions (
    company VARCHAR(50) NOT NULL,
    location VARCHAR(100) NOT NULL,
    date DATE NOT NULL,
    rocket VARCHAR(50) NOT NULL,
    mission VARCHAR(50) NOT NULL,
    rocket_status VARCHAR(15) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    mission_status VARCHAR(15) NOT NULL,
    country VARCHAR(20) NOT NULL
);
