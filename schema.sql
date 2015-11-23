-- DEFINE YOUR DATABASE SCHEMA HERE

DROP TABLE IF EXISTS employee_table CASCADE;
DROP TABLE IF EXISTS customer_table CASCADE;
DROP TABLE IF EXISTS product_table CASCADE;
DROP TABLE IF EXISTS frequency_table CASCADE;
DROP TABLE IF EXISTS invoice_table CASCADE;

CREATE TABLE employee_table (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255)
);

CREATE TABLE customer_table (
  id SERIAL PRIMARY KEY,
  customer VARCHAR(255)
);

CREATE TABLE product_table (
  id SERIAL PRIMARY KEY,
  product VARCHAR(255)
);

CREATE TABLE frequency_table (
  id SERIAL PRIMARY KEY,
  frequency VARCHAR(100)
);

CREATE TABLE invoice_table (
  id SERIAL PRIMARY KEY,
  invoice_no int,
  product_id int REFERENCES product_table(id),
  employee_id int REFERENCES employee_table(id),
  customer_id int REFERENCES customer_table(id),
  sale_date date,
  sale_amount money,
  units_sold int,
  frequency_id int REFERENCES frequency_table(id)
);
