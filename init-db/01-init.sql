-- Create read-only user for the agent (ignore error if exists)
DO $$
BEGIN
    CREATE USER odoo_readonly WITH PASSWORD 'postgres';
EXCEPTION WHEN OTHERS THEN
    -- User already exists, ignore
END
$$;

GRANT CONNECT ON DATABASE odoo_test TO odoo_readonly;
GRANT USAGE ON SCHEMA public TO odoo_readonly;

-- Create Odoo-like tables
CREATE TABLE IF NOT EXISTS res_partner (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(50),
    city VARCHAR(100),
    country VARCHAR(100),
    customer_rank INTEGER DEFAULT 0,
    active BOOLEAN DEFAULT TRUE,
    create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS sale_order (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    partner_id INTEGER REFERENCES res_partner(id),
    date_order TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    state VARCHAR(50) DEFAULT 'draft',
    amount_total DECIMAL(12, 2) DEFAULT 0.00,
    create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    active BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS sale_order_line (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES sale_order(id),
    product_id INTEGER,
    name VARCHAR(255),
    product_uom_qty DECIMAL(10, 2) DEFAULT 1.0,
    price_unit DECIMAL(10, 2) DEFAULT 0.00,
    price_subtotal DECIMAL(12, 2) DEFAULT 0.00
);

CREATE TABLE IF NOT EXISTS product_product (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    list_price DECIMAL(10, 2) DEFAULT 0.00,
    standard_price DECIMAL(10, 2) DEFAULT 0.00,
    type VARCHAR(50) DEFAULT 'consu',
    active BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS stock_quant (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES product_product(id),
    location_id INTEGER DEFAULT 1,
    quantity DECIMAL(10, 2) DEFAULT 0.00
);

CREATE TABLE IF NOT EXISTS account_invoice (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    partner_id INTEGER REFERENCES res_partner(id),
    date_invoice DATE DEFAULT CURRENT_DATE,
    state VARCHAR(50) DEFAULT 'draft',
    amount_total DECIMAL(12, 2) DEFAULT 0.00,
    type VARCHAR(20) DEFAULT 'out_invoice'
);

-- Grant SELECT permissions
GRANT SELECT ON ALL TABLES IN SCHEMA public TO odoo_readonly;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO odoo_readonly;

