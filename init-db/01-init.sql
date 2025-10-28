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

-- Create Odoo-like tables (foundational tables first)
CREATE TABLE IF NOT EXISTS res_users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    login VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255),
    active BOOLEAN DEFAULT TRUE,
    is_superuser BOOLEAN DEFAULT FALSE,
    create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS res_company (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    currency_id INTEGER DEFAULT 1,
    active BOOLEAN DEFAULT TRUE,
    create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

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
    user_id INTEGER REFERENCES res_users(id),
    date_order TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    state VARCHAR(50) DEFAULT 'draft',
    amount_total DECIMAL(12, 4) DEFAULT 0.00,
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
    type VARCHAR(20) DEFAULT 'out_invoice',
    sale_order_id INTEGER REFERENCES sale_order(id)
);

CREATE TABLE IF NOT EXISTS product_category (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    parent_id INTEGER REFERENCES product_category(id),
    active BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS stock_location (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    usage VARCHAR(50) DEFAULT 'internal',
    active BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS stock_picking (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    partner_id INTEGER REFERENCES res_partner(id),
    sale_id INTEGER REFERENCES sale_order(id),
    picking_type_id INTEGER DEFAULT 1,
    state VARCHAR(50) DEFAULT 'draft',
    date_planned TIMESTAMP,
    delivery_status VARCHAR(50) DEFAULT 'Pending',
    invoice_status VARCHAR(50) DEFAULT 'To Invoice',
    create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    active BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS stock_move (
    id SERIAL PRIMARY KEY,
    picking_id INTEGER REFERENCES stock_picking(id),
    product_id INTEGER REFERENCES product_product(id),
    quantity DECIMAL(10, 3) DEFAULT 1.0,
    product_uom INTEGER DEFAULT 1,
    state VARCHAR(50) DEFAULT 'draft',
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS account_payment (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    partner_id INTEGER REFERENCES res_partner(id),
    invoice_id INTEGER REFERENCES account_invoice(id),
    payment_date DATE DEFAULT CURRENT_DATE,
    amount DECIMAL(12, 2) NOT NULL,
    state VARCHAR(50) DEFAULT 'draft',
    payment_method VARCHAR(50),
    create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS account_move (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    partner_id INTEGER REFERENCES res_partner(id),
    date DATE DEFAULT CURRENT_DATE,
    move_type VARCHAR(50) DEFAULT 'entry',
    state VARCHAR(50) DEFAULT 'draft',
    amount_total DECIMAL(12, 2) DEFAULT 0.00,
    journal_id INTEGER DEFAULT 1,
    create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS account_move_line (
    id SERIAL PRIMARY KEY,
    move_id INTEGER REFERENCES account_move(id),
    account_id INTEGER,
    name VARCHAR(255),
    debit DECIMAL(12, 2) DEFAULT 0.00,
    credit DECIMAL(12, 2) DEFAULT 0.00,
    balance DECIMAL(12, 2) DEFAULT 0.00,
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS product_template (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category_id INTEGER REFERENCES product_category(id),
    list_price DECIMAL(10, 2) DEFAULT 0.00,
    standard_price DECIMAL(10, 2) DEFAULT 0.00,
    type VARCHAR(50) DEFAULT 'product',
    sale_ok BOOLEAN DEFAULT TRUE,
    purchase_ok BOOLEAN DEFAULT TRUE,
    active BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS mrp_production (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    product_id INTEGER REFERENCES product_product(id),
    product_qty DECIMAL(10, 2) DEFAULT 1.0,
    state VARCHAR(50) DEFAULT 'draft',
    date_planned_start TIMESTAMP,
    date_planned_finished TIMESTAMP,
    create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    active BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS purchase_order (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    partner_id INTEGER REFERENCES res_partner(id),
    date_order TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_planned TIMESTAMP,
    state VARCHAR(50) DEFAULT 'draft',
    amount_total DECIMAL(12, 2) DEFAULT 0.00,
    create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    active BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS purchase_order_line (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES purchase_order(id),
    product_id INTEGER REFERENCES product_product(id),
    name VARCHAR(255),
    product_qty DECIMAL(10, 2) DEFAULT 1.0,
    price_unit DECIMAL(10, 2) DEFAULT 0.00,
    price_subtotal DECIMAL(12, 2) DEFAULT 0.00
);

CREATE TABLE IF NOT EXISTS crm_lead (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    partner_id INTEGER REFERENCES res_partner(id),
    user_id INTEGER REFERENCES res_users(id),
    type VARCHAR(50) DEFAULT 'opportunity',
    stage_id INTEGER,
    probability DECIMAL(5, 2) DEFAULT 0.00,
    expected_revenue DECIMAL(12, 2) DEFAULT 0.00,
    date_deadline DATE,
    create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    active BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS hr_employee (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    user_id INTEGER REFERENCES res_users(id),
    work_email VARCHAR(255),
    phone VARCHAR(50),
    department VARCHAR(100),
    job_title VARCHAR(100),
    hire_date DATE,
    active BOOLEAN DEFAULT TRUE,
    create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS mail_message (
    id SERIAL PRIMARY KEY,
    model VARCHAR(255),
    res_id INTEGER,
    subject VARCHAR(255),
    body TEXT,
    author_id INTEGER REFERENCES res_partner(id),
    email_from VARCHAR(255),
    message_type VARCHAR(50) DEFAULT 'notification',
    create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Grant SELECT permissions
GRANT SELECT ON ALL TABLES IN SCHEMA public TO odoo_readonly;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO odoo_readonly;

