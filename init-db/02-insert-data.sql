-- Insert comprehensive realistic data for 15+ tables

-- ==========================================
-- 1. Create base reference data
-- ==========================================

-- Insert companies
INSERT INTO res_company (name, currency_id, active) VALUES
('Zimplistic Pte Limited', 1, TRUE),
('Manufacturing Corp', 1, TRUE),
('Retail Solutions Inc', 1, TRUE);

-- Insert stock locations
INSERT INTO stock_location (name, usage, active) VALUES
('WH/Stock', 'internal', TRUE),
('WH/Quality Control', 'internal', TRUE),
('WH/Scrapped', 'internal', TRUE),
('Vendors', 'supplier', TRUE),
('Customers', 'customer', TRUE);

-- Insert product categories
INSERT INTO product_category (name, parent_id, active) VALUES
('All Products', NULL, TRUE),
('Electronics', 1, TRUE),
('Clothing & Fashion', 1, TRUE),
('Home & Kitchen', 1, TRUE),
('Office Supplies', 1, TRUE),
('Food & Beverages', 1, TRUE),
('Health & Beauty', 1, TRUE),
('Sports & Outdoors', 1, TRUE),
('Books & Media', 1, TRUE),
('Automotive', 1, TRUE);

-- ==========================================
-- 2. Insert Users and Employees
-- ==========================================

-- Insert users
INSERT INTO res_users (name, login, email, active, is_superuser) VALUES
('Administrator', 'admin', 'admin@zimplistic.com', TRUE, TRUE),
('Sales Manager', 'sales_manager', 'sales@zimplistic.com', TRUE, FALSE),
('John Smith', 'john.smith', 'john.smith@zimplistic.com', TRUE, FALSE),
('Sarah Johnson', 'sarah.johnson', 'sarah.j@zimplistic.com', TRUE, FALSE),
('Michael Chen', 'michael.chen', 'm.chen@zimplistic.com', TRUE, FALSE),
('Emma Williams', 'emma.williams', 'emma.w@zimplistic.com', TRUE, FALSE),
('David Brown', 'david.brown', 'd.brown@zimplistic.com', TRUE, FALSE),
('Lisa Anderson', 'lisa.anderson', 'lisa.a@zimplistic.com', TRUE, FALSE),
('Robert Taylor', 'robert.taylor', 'r.taylor@zimplistic.com', TRUE, FALSE),
('Jennifer Davis', 'jennifer.davis', 'j.davis@zimplistic.com', TRUE, FALSE);

-- Insert employees
INSERT INTO hr_employee (name, user_id, work_email, phone, department, job_title, hire_date, active) VALUES
('Administrator', 1, 'admin@zimplistic.com', '+1-555-0101', 'IT', 'System Administrator', '2020-01-15', TRUE),
('Sales Manager', 2, 'sales@zimplistic.com', '+1-555-0202', 'Sales', 'Sales Manager', '2020-03-10', TRUE),
('John Smith', 3, 'john.smith@zimplistic.com', '+1-555-0303', 'Sales', 'Sales Representative', '2021-05-20', TRUE),
('Sarah Johnson', 4, 'sarah.j@zimplistic.com', '+1-555-0404', 'Sales', 'Sales Representative', '2021-06-15', TRUE),
('Michael Chen', 5, 'm.chen@zimplistic.com', '+1-555-0505', 'Operations', 'Warehouse Manager', '2020-11-30', TRUE),
('Emma Williams', 6, 'emma.w@zimplistic.com', '+1-555-0606', 'Finance', 'Accountant', '2021-02-01', TRUE),
('David Brown', 7, 'd.brown@zimplistic.com', '+1-555-0707', 'Operations', 'Logistics Coordinator', '2021-08-10', TRUE),
('Lisa Anderson', 8, 'lisa.a@zimplistic.com', '+1-555-0808', 'Sales', 'Sales Representative', '2022-01-05', TRUE),
('Robert Taylor', 9, 'r.taylor@zimplistic.com', '+1-555-0909', 'Sales', 'Senior Sales Rep', '2019-09-15', TRUE),
('Jennifer Davis', 10, 'j.davis@zimplistic.com', '+1-555-1010', 'HR', 'HR Manager', '2020-04-01', TRUE);

-- ==========================================
-- 3. Insert Partners (Customers/Vendors)
-- ==========================================

-- Realistic customer names based on the image
DO $$
DECLARE
    i INTEGER;
    customer_names TEXT[] := ARRAY[
        'Ashish Bhandari', 'Madhavi Dadi', 'Anuradha Phalke', 'raghu meka', 'Swaroopa Pulivarthi',
        'Devendra Parkhi', 'Surya Chittineni', 'Amit Kohli', 'Suchit Sharma', 'Santhosh Nair',
        'Hirdesh Ahuja', 'Tejas Dakve', 'SUBRAT KUMAR NAYAK', 'Prithwiraj Ghosh', 'Rajesh Patel',
        'Priya Sharma', 'Anil Kumar', 'Sunita Reddy', 'Vikram Singh', 'Kavita Mehta',
        'Rahul Desai', 'Sheetal Joshi', 'Manoj Pandey', 'Divya Agrawal', 'Arjun Malhotra',
        'Neha Sharma', 'Suresh Iyer', 'Rekha Nair', 'Anita Kapoor', 'Gaurav Shah',
        'Pooja Verma', 'Nikhil Agarwal', 'Meera Chaturvedi', 'Aditya Bose', 'Tanvi Joshi',
        'Kiran Rao', 'Varun Malhotra', 'Nisha Shah', 'Deepak Patel', 'Anisha Singh'
    ];
    cities TEXT[] := ARRAY['New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix', 'Philadelphia', 'San Antonio', 'San Diego', 'Dallas', 'San Jose', 'Mumbai', 'Delhi', 'Bangalore', 'Hyderabad', 'Chennai'];
    countries TEXT[] := ARRAY['USA', 'USA', 'USA', 'USA', 'USA', 'India', 'India', 'India', 'India', 'India', 'Canada', 'UK', 'Australia', 'Germany', 'France'];
BEGIN
    FOR i IN 1..5000 LOOP
        INSERT INTO res_partner (name, email, phone, city, country, customer_rank, active, create_date)
        VALUES (
            customer_names[1 + floor(random() * array_length(customer_names, 1))] || 
            CASE WHEN random() > 0.7 THEN ' ' || floor(random() * 999)::TEXT ELSE '' END,
            'customer' || i || '@company.com',
            '+1-' || LPAD(floor(random() * 999)::TEXT, 3, '0') || '-' || LPAD(floor(random() * 9999)::TEXT, 4, '0'),
            cities[1 + floor(random() * array_length(cities, 1))],
            countries[1 + floor(random() * array_length(countries, 1))],
            floor(random() * 10)::INTEGER,
            CASE WHEN random() > 0.05 THEN TRUE ELSE FALSE END,
            CURRENT_DATE - floor(random() * 1095)::INTEGER  -- Created in last 3 years
        );
    END LOOP;
END $$;

-- ==========================================
-- 4. Insert Products
-- ==========================================

DO $$
DECLARE
    i INTEGER;
    product_types TEXT[] := ARRAY['product', 'consu', 'service'];
    product_names TEXT[] := ARRAY[
        'Wireless Headphones', 'Smart Phone', 'Laptop', 'Tablet', 'Mouse', 'Keyboard', 'Monitor', 'Webcam',
        'T-Shirt', 'Jeans', 'Dress', 'Shoes', 'Jacket', 'Hat', 'Sunglasses', 'Watch',
        'Coffee Maker', 'Microwave', 'Blender', 'Dishwasher', 'Refrigerator', 'Vacuum Cleaner',
        'Pen Set', 'Notebook', 'Folder', 'Stapler', 'Calculator', 'Marker Set', 'Paper Clips',
        'Soft Drink', 'Energy Bar', 'Chocolate', 'Chips', 'Candy', 'Juice', 'Water Bottle',
        'Face Cream', 'Shampoo', 'Soap', 'Perfume', 'Toothbrush', 'Vitamin Supplement'
    ];
BEGIN
    FOR i IN 1..2000 LOOP
        INSERT INTO product_product (name, list_price, standard_price, type, active)
        VALUES (
            product_names[1 + floor(random() * array_length(product_names, 1))] || ' ' || i,
            (random() * 5000 + 10)::DECIMAL(10, 2),
            (random() * 3000 + 5)::DECIMAL(10, 2),
            product_types[1 + floor(random() * array_length(product_types, 1))],
            CASE WHEN random() > 0.05 THEN TRUE ELSE FALSE END
        );
    END LOOP;
END $$;

-- ==========================================
-- 5. Insert Sale Orders
-- ==========================================

DO $$
DECLARE
    i INTEGER;
    partner_id INTEGER;
    user_id INTEGER;
    states TEXT[] := ARRAY['draft', 'sent', 'sale', 'done', 'cancel'];
    invoice_states TEXT[] := ARRAY['To Invoice', 'Nothing to Invoice', 'Fully Invoiced'];
    date_offset INTEGER;
    invoice_state TEXT;
BEGIN
    FOR i IN 1..100000 LOOP
        partner_id := 1 + floor(random() * 5000)::INTEGER;
        user_id := 1 + floor(random() * 10)::INTEGER;
        date_offset := floor(random() * 365)::INTEGER;
        invoice_state := invoice_states[1 + floor(random() * array_length(invoice_states, 1))];
        
        INSERT INTO sale_order (name, partner_id, date_order, state, amount_total, active, user_id)
        VALUES (
            'SO-' || LPAD((70000 + i)::TEXT, 8, '0'),
            partner_id,
            CURRENT_DATE - date_offset,
            states[1 + floor(random() * array_length(states, 1))],
            (random() * 10000 + 30)::DECIMAL(12, 4),
            CASE WHEN random() > 0.03 THEN TRUE ELSE FALSE END,
            user_id
        );
    END LOOP;
END $$;

-- ==========================================
-- 6. Insert Sale Order Lines
-- ==========================================

DO $$
DECLARE
    order_record RECORD;
    i INTEGER;
    num_lines INTEGER;
    product_id INTEGER;
    qty DECIMAL;
    price DECIMAL;
BEGIN
    FOR order_record IN SELECT id FROM sale_order WHERE id <= 100000 LOOP
        num_lines := 2 + floor(random() * 4)::INTEGER;
        
        FOR i IN 1..num_lines LOOP
            product_id := 1 + floor(random() * 2000)::INTEGER;
            qty := (random() * 20 + 1)::DECIMAL;
            price := (random() * 1000 + 10)::DECIMAL;
            
            INSERT INTO sale_order_line (order_id, product_id, name, product_uom_qty, price_unit, price_subtotal)
            VALUES (
                order_record.id,
                product_id,
                'Product Item ' || product_id,
                qty,
                price,
                qty * price
            );
        END LOOP;
    END LOOP;
END $$;

-- Update sale order totals
UPDATE sale_order so
SET amount_total = (
    SELECT COALESCE(SUM(price_subtotal), 0)
    FROM sale_order_line sol
    WHERE sol.order_id = so.id
);

-- ==========================================
-- 7. Insert Purchase Orders
-- ==========================================

DO $$
DECLARE
    i INTEGER;
    partner_id INTEGER;
    states TEXT[] := ARRAY['draft', 'sent', 'purchase', 'done', 'cancel'];
    date_offset INTEGER;
BEGIN
    FOR i IN 1..50000 LOOP
        partner_id := 1 + floor(random() * 5000)::INTEGER;
        date_offset := floor(random() * 365)::INTEGER;
        
        INSERT INTO purchase_order (name, partner_id, date_order, state, amount_total, active)
        VALUES (
            'PO-' || LPAD((50000 + i)::TEXT, 8, '0'),
            partner_id,
            CURRENT_DATE - date_offset,
            states[1 + floor(random() * array_length(states, 1))],
            (random() * 15000 + 50)::DECIMAL(12, 2),
            CASE WHEN random() > 0.05 THEN TRUE ELSE FALSE END
        );
    END LOOP;
END $$;

-- Insert Purchase Order Lines
DO $$
DECLARE
    order_record RECORD;
    i INTEGER;
    num_lines INTEGER;
    product_id INTEGER;
    qty DECIMAL;
    price DECIMAL;
BEGIN
    FOR order_record IN SELECT id FROM purchase_order WHERE id <= 50000 LOOP
        num_lines := 1 + floor(random() * 6)::INTEGER;
        
        FOR i IN 1..num_lines LOOP
            product_id := 1 + floor(random() * 2000)::INTEGER;
            qty := (random() * 100 + 1)::DECIMAL;
            price := (random() * 800 + 5)::DECIMAL;
            
            INSERT INTO purchase_order_line (order_id, product_id, name, product_qty, price_unit, price_subtotal)
            VALUES (
                order_record.id,
                product_id,
                'Product Item ' || product_id,
                qty,
                price,
                qty * price
            );
        END LOOP;
    END LOOP;
END $$;

-- Update purchase order totals
UPDATE purchase_order po
SET amount_total = (
    SELECT COALESCE(SUM(price_subtotal), 0)
    FROM purchase_order_line pol
    WHERE pol.order_id = po.id
);

-- ==========================================
-- 8. Insert Invoices
-- ==========================================

DO $$
DECLARE
    i INTEGER;
    partner_id INTEGER;
    sale_order_id INTEGER;
    states TEXT[] := ARRAY['draft', 'open', 'paid', 'cancel'];
    inv_types TEXT[] := ARRAY['out_invoice', 'out_refund'];
    date_offset INTEGER;
BEGIN
    FOR i IN 1..80000 LOOP
        partner_id := 1 + floor(random() * 5000)::INTEGER;
        sale_order_id := 1 + floor(random() * 100000)::INTEGER;
        date_offset := floor(random() * 365)::INTEGER;
        
        INSERT INTO account_invoice (name, partner_id, date_invoice, state, amount_total, type, sale_order_id)
        VALUES (
            'INV-' || LPAD((100000 + i)::TEXT, 8, '0'),
            partner_id,
            CURRENT_DATE - date_offset,
            states[1 + floor(random() * array_length(states, 1))],
            (random() * 12000 + 25)::DECIMAL(12, 2),
            inv_types[1 + floor(random() * array_length(inv_types, 1))],
            sale_order_id
        );
    END LOOP;
END $$;

-- ==========================================
-- 9. Insert Stock Pickings (Deliveries)
-- ==========================================

DO $$
DECLARE
    i INTEGER;
    partner_id INTEGER;
    sale_id INTEGER;
    states TEXT[] := ARRAY['draft', 'waiting', 'partial', 'assigned', 'done', 'cancel'];
    delivery_statuses TEXT[] := ARRAY['Pending', 'Shipped', 'Delivered', 'In Transit'];
    invoice_statuses TEXT[] := ARRAY['To Invoice', 'Nothing to Invoice', 'Fully Invoiced'];
    date_offset INTEGER;
BEGIN
    FOR i IN 1..60000 LOOP
        partner_id := 1 + floor(random() * 5000)::INTEGER;
        sale_id := 1 + floor(random() * 100000)::INTEGER;
        date_offset := floor(random() * 365)::INTEGER;
        
        INSERT INTO stock_picking (name, partner_id, sale_id, picking_type_id, state, delivery_status, invoice_status, date_planned, active)
        VALUES (
            'WH/OUT/' || LPAD((80000 + i)::TEXT, 6, '0'),
            partner_id,
            sale_id,
            1,
            states[1 + floor(random() * array_length(states, 1))],
            delivery_statuses[1 + floor(random() * array_length(delivery_statuses, 1))],
            invoice_statuses[1 + floor(random() * array_length(invoice_statuses, 1))],
            CURRENT_TIMESTAMP - (date_offset || ' days')::INTERVAL,
            CASE WHEN random() > 0.05 THEN TRUE ELSE FALSE END
        );
    END LOOP;
END $$;

-- ==========================================
-- 10. Insert Stock Moves
-- ==========================================

DO $$
DECLARE
    picking_record RECORD;
    i INTEGER;
    num_moves INTEGER;
    product_id INTEGER;
    qty DECIMAL;
BEGIN
    FOR picking_record IN SELECT id FROM stock_picking WHERE id <= 60000 LOOP
        num_moves := 1 + floor(random() * 5)::INTEGER;
        
        FOR i IN 1..num_moves LOOP
            product_id := 1 + floor(random() * 2000)::INTEGER;
            qty := (random() * 50 + 1)::DECIMAL;
            
            INSERT INTO stock_move (picking_id, product_id, quantity, product_uom, state)
            VALUES (
                picking_record.id,
                product_id,
                qty,
                1,
                'done'
            );
        END LOOP;
    END LOOP;
END $$;

-- ==========================================
-- 11. Insert Stock Quants
-- ==========================================

DO $$
DECLARE
    i INTEGER;
BEGIN
    FOR i IN 1..2000 LOOP
        INSERT INTO stock_quant (product_id, location_id, quantity)
        VALUES (
            i,
            1 + floor(random() * 5)::INTEGER,
            (random() * 5000)::DECIMAL
        );
    END LOOP;
END $$;

-- ==========================================
-- 12. Insert CRM Leads
-- ==========================================

DO $$
DECLARE
    i INTEGER;
    partner_id INTEGER;
    user_id INTEGER;
    stages TEXT[] := ARRAY['New', 'Qualified', 'Proposal', 'Negotiation', 'Won', 'Lost'];
    date_offset INTEGER;
BEGIN
    FOR i IN 1..10000 LOOP
        partner_id := 1 + floor(random() * 5000)::INTEGER;
        user_id := 1 + floor(random() * 10)::INTEGER;
        date_offset := floor(random() * 180)::INTEGER;
        
        INSERT INTO crm_lead (name, partner_id, user_id, type, stage_id, probability, expected_revenue, date_deadline, active)
        VALUES (
            'Opportunity: Lead ' || i,
            partner_id,
            user_id,
            'opportunity',
            floor(random() * 6) + 1,
            (random() * 100)::DECIMAL,
            (random() * 500000 + 1000)::DECIMAL,
            CURRENT_DATE + floor(random() * 90)::INTEGER,
            CASE WHEN random() > 0.1 THEN TRUE ELSE FALSE END
        );
    END LOOP;
END $$;

-- ==========================================
-- 13. Insert Account Payments
-- ==========================================

DO $$
DECLARE
    i INTEGER;
    partner_id INTEGER;
    invoice_id INTEGER;
    states TEXT[] := ARRAY['draft', 'posted', 'sent', 'reconciled', 'cancel'];
    methods TEXT[] := ARRAY['check', 'wire_transfer', 'credit_card', 'paypal', 'ach'];
    date_offset INTEGER;
BEGIN
    FOR i IN 1..50000 LOOP
        partner_id := 1 + floor(random() * 5000)::INTEGER;
        invoice_id := 1 + floor(random() * 80000)::INTEGER;
        date_offset := floor(random() * 365)::INTEGER;
        
        INSERT INTO account_payment (name, partner_id, invoice_id, payment_date, amount, state, payment_method)
        VALUES (
            'PAY-' || LPAD((200000 + i)::TEXT, 8, '0'),
            partner_id,
            invoice_id,
            CURRENT_DATE - date_offset,
            (random() * 10000 + 50)::DECIMAL,
            states[1 + floor(random() * array_length(states, 1))],
            methods[1 + floor(random() * array_length(methods, 1))]
        );
    END LOOP;
END $$;

-- ==========================================
-- 14. Insert MRP Production Orders
-- ==========================================

DO $$
DECLARE
    i INTEGER;
    product_id INTEGER;
    states TEXT[] := ARRAY['draft', 'confirmed', 'planned', 'progress', 'done', 'cancel'];
    date_offset INTEGER;
BEGIN
    FOR i IN 1..5000 LOOP
        product_id := 1 + floor(random() * 2000)::INTEGER;
        date_offset := floor(random() * 180)::INTEGER;
        
        INSERT INTO mrp_production (name, product_id, product_qty, state, date_planned_start, date_planned_finished, active)
        VALUES (
            'MO-' || LPAD((10000 + i)::TEXT, 6, '0'),
            product_id,
            (random() * 1000 + 10)::DECIMAL,
            states[1 + floor(random() * array_length(states, 1))],
            CURRENT_TIMESTAMP - (date_offset || ' days')::INTERVAL,
            CURRENT_TIMESTAMP - ((date_offset - 5)::TEXT || ' days')::INTERVAL,
            CASE WHEN random() > 0.05 THEN TRUE ELSE FALSE END
        );
    END LOOP;
END $$;

-- ==========================================
-- 15. Insert Mail Messages
-- ==========================================

DO $$
DECLARE
    i INTEGER;
    models TEXT[] := ARRAY['sale.order', 'account.invoice', 'stock.picking', 'purchase.order', 'crm.lead'];
    message_types TEXT[] := ARRAY['email', 'notification', 'comment'];
    res_id INTEGER;
    subject_prefix TEXT;
    date_offset INTEGER;
BEGIN
    FOR i IN 1..25000 LOOP
        res_id := 1 + floor(random() * 100000)::INTEGER;
        date_offset := floor(random() * 365)::INTEGER;
        subject_prefix := CASE 
            WHEN random() < 0.3 THEN 'Re: Order'
            WHEN random() < 0.5 THEN 'Re: Invoice'
            WHEN random() < 0.7 THEN 'Re: Delivery'
            ELSE 'Re: Payment'
        END;
        
        INSERT INTO mail_message (model, res_id, subject, body, author_id, email_from, message_type, create_date)
        VALUES (
            models[1 + floor(random() * array_length(models, 1))],
            res_id,
            subject_prefix || ' ' || res_id,
            'This is a message regarding ' || models[1 + floor(random() * array_length(models, 1))],
            1 + floor(random() * 5000)::INTEGER,
            'sender' || i || '@company.com',
            message_types[1 + floor(random() * array_length(message_types, 1))],
            CURRENT_TIMESTAMP - (date_offset || ' days')::INTERVAL
        );
    END LOOP;
END $$;

-- ==========================================
-- Create Indexes for Performance
-- ==========================================

CREATE INDEX IF NOT EXISTS idx_res_partner_active ON res_partner(active);
CREATE INDEX IF NOT EXISTS idx_res_partner_customer_rank ON res_partner(customer_rank);
CREATE INDEX IF NOT EXISTS idx_sale_order_partner ON sale_order(partner_id);
CREATE INDEX IF NOT EXISTS idx_sale_order_date ON sale_order(date_order);
CREATE INDEX IF NOT EXISTS idx_sale_order_state ON sale_order(state);
CREATE INDEX IF NOT EXISTS idx_sale_order_user ON sale_order(user_id);
CREATE INDEX IF NOT EXISTS idx_sale_order_line_order ON sale_order_line(order_id);
CREATE INDEX IF NOT EXISTS idx_product_active ON product_product(active);
CREATE INDEX IF NOT EXISTS idx_account_invoice_partner ON account_invoice(partner_id);
CREATE INDEX IF NOT EXISTS idx_account_invoice_date ON account_invoice(date_invoice);
CREATE INDEX IF NOT EXISTS idx_stock_picking_partner ON stock_picking(partner_id);
CREATE INDEX IF NOT EXISTS idx_stock_picking_sale ON stock_picking(sale_id);
CREATE INDEX IF NOT EXISTS idx_stock_picking_state ON stock_picking(state);
CREATE INDEX IF NOT EXISTS idx_purchase_order_partner ON purchase_order(partner_id);
CREATE INDEX IF NOT EXISTS idx_purchase_order_date ON purchase_order(date_order);
CREATE INDEX IF NOT EXISTS idx_crm_lead_partner ON crm_lead(partner_id);
CREATE INDEX IF NOT EXISTS idx_crm_lead_user ON crm_lead(user_id);
CREATE INDEX IF NOT EXISTS idx_account_payment_partner ON account_payment(partner_id);
CREATE INDEX IF NOT EXISTS idx_account_payment_invoice ON account_payment(invoice_id);
CREATE INDEX IF NOT EXISTS idx_mail_message_model ON mail_message(model, res_id);

-- ==========================================
-- Final Statistics
-- ==========================================

SELECT 'Data insertion completed!' as status;
SELECT 
    (SELECT COUNT(*) FROM res_partner) as partners,
    (SELECT COUNT(*) FROM res_users) as users,
    (SELECT COUNT(*) FROM sale_order) as sale_orders,
    (SELECT COUNT(*) FROM sale_order_line) as order_lines,
    (SELECT COUNT(*) FROM purchase_order) as purchase_orders,
    (SELECT COUNT(*) FROM account_invoice) as invoices,
    (SELECT COUNT(*) FROM stock_picking) as pickings,
    (SELECT COUNT(*) FROM stock_move) as stock_moves,
    (SELECT COUNT(*) FROM crm_lead) as crm_leads,
    (SELECT COUNT(*) FROM account_payment) as payments,
    (SELECT COUNT(*) FROM product_product) as products;
