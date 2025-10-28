-- Insert dummy data

-- Insert 500 random partners/customers
DO $$
DECLARE
    i INTEGER;
    cities TEXT[] := ARRAY['Mumbai', 'Delhi', 'Bangalore', 'Hyderabad', 'Chennai', 'Pune', 'Kolkata', 'Ahmedabad', 'Jaipur', 'Lucknow'];
    countries TEXT[] := ARRAY['India', 'USA', 'UK', 'Australia', 'Canada', 'Germany', 'France', 'Japan', 'China', 'Brazil'];
BEGIN
    FOR i IN 1..500 LOOP
        INSERT INTO res_partner (name, email, phone, city, country, customer_rank, active)
        VALUES (
            'Customer ' || i,
            'customer' || i || '@example.com',
            '+91-98765' || (10000 + i)::TEXT,
            cities[1 + floor(random() * array_length(cities, 1))],
            countries[1 + floor(random() * array_length(countries, 1))],
            floor(random() * 10)::INTEGER,
            CASE WHEN random() > 0.05 THEN TRUE ELSE FALSE END
        );
    END LOOP;
END $$;

-- Insert 100 products
DO $$
DECLARE
    i INTEGER;
    product_types TEXT[] := ARRAY['Product', 'Service', 'Consumable'];
    categories TEXT[] := ARRAY['Electronics', 'Clothing', 'Food', 'Books', 'Furniture'];
BEGIN
    FOR i IN 1..100 LOOP
        INSERT INTO product_product (name, list_price, standard_price, type, active)
        VALUES (
            categories[1 + floor(random() * array_length(categories, 1))] || ' Item ' || i,
            (random() * 10000 + 100)::DECIMAL(10, 2),
            (random() * 7000 + 70)::DECIMAL(10, 2),
            product_types[1 + floor(random() * array_length(product_types, 1))],
            CASE WHEN random() > 0.05 THEN TRUE ELSE FALSE END
        );
    END LOOP;
END $$;

-- Insert 2000 sale orders
DO $$
DECLARE
    i INTEGER;
    partner_id INTEGER;
    states TEXT[] := ARRAY['draft', 'sent', 'sale', 'done', 'cancel'];
    date_offset INTEGER;
BEGIN
    FOR i IN 1..2000 LOOP
        -- Random partner (from IDs 1 to 500)
        partner_id := 1 + floor(random() * 500)::INTEGER;
        
        -- Random date in last 365 days
        date_offset := floor(random() * 365)::INTEGER;
        
        INSERT INTO sale_order (name, partner_id, date_order, state, amount_total, active)
        VALUES (
            'SO-' || (1000 + i)::TEXT,
            partner_id,
            CURRENT_DATE - date_offset,
            states[1 + floor(random() * array_length(states, 1))],
            (random() * 50000 + 1000)::DECIMAL(12, 2),
            CASE WHEN random() > 0.05 THEN TRUE ELSE FALSE END
        );
    END LOOP;
END $$;

-- Insert order lines for sale orders (avg 3-5 lines per order)
DO $$
DECLARE
    order_record RECORD;
    i INTEGER;
    num_lines INTEGER;
    product_id INTEGER;
    qty DECIMAL;
    price DECIMAL;
BEGIN
    FOR order_record IN SELECT id FROM sale_order LOOP
        -- Each order has 2-6 line items
        num_lines := 2 + floor(random() * 5)::INTEGER;
        
        FOR i IN 1..num_lines LOOP
            product_id := 1 + floor(random() * 100)::INTEGER;
            qty := (random() * 10 + 1)::DECIMAL;
            price := (random() * 5000 + 100)::DECIMAL;
            
            INSERT INTO sale_order_line (order_id, product_id, name, product_uom_qty, price_unit, price_subtotal)
            VALUES (
                order_record.id,
                product_id,
                'Product ' || product_id,
                qty,
                price,
                qty * price
            );
        END LOOP;
    END LOOP;
END $$;

-- Insert stock quantities for products
DO $$
DECLARE
    i INTEGER;
BEGIN
    FOR i IN 1..100 LOOP
        INSERT INTO stock_quant (product_id, location_id, quantity)
        VALUES (
            i,
            1,
            (random() * 1000)::DECIMAL
        );
    END LOOP;
END $$;

-- Insert 500 invoices
DO $$
DECLARE
    i INTEGER;
    partner_id INTEGER;
    states TEXT[] := ARRAY['draft', 'open', 'paid', 'cancel'];
    date_offset INTEGER;
    inv_types TEXT[] := ARRAY['out_invoice', 'out_refund'];
BEGIN
    FOR i IN 1..500 LOOP
        partner_id := 1 + floor(random() * 500)::INTEGER;
        date_offset := floor(random() * 180)::INTEGER;
        
        INSERT INTO account_invoice (name, partner_id, date_invoice, state, amount_total, type)
        VALUES (
            'INV-' || (1000 + i)::TEXT,
            partner_id,
            CURRENT_DATE - date_offset,
            states[1 + floor(random() * array_length(states, 1))],
            (random() * 50000 + 1000)::DECIMAL(12, 2),
            inv_types[1 + floor(random() * array_length(inv_types, 1))]
        );
    END LOOP;
END $$;

-- Create indexes for better performance
CREATE INDEX idx_res_partner_active ON res_partner(active);
CREATE INDEX idx_res_partner_customer_rank ON res_partner(customer_rank);
CREATE INDEX idx_sale_order_partner ON sale_order(partner_id);
CREATE INDEX idx_sale_order_date ON sale_order(date_order);
CREATE INDEX idx_sale_order_state ON sale_order(state);
CREATE INDEX idx_sale_order_line_order ON sale_order_line(order_id);
CREATE INDEX idx_product_active ON product_product(active);
CREATE INDEX idx_account_invoice_partner ON account_invoice(partner_id);
CREATE INDEX idx_account_invoice_date ON account_invoice(date_invoice);

-- Update sale order totals from line items
UPDATE sale_order so
SET amount_total = (
    SELECT COALESCE(SUM(price_subtotal), 0)
    FROM sale_order_line sol
    WHERE sol.order_id = so.id
);

SELECT 'Data insertion completed!' as status;
SELECT 
    (SELECT COUNT(*) FROM res_partner) as partners,
    (SELECT COUNT(*) FROM sale_order) as sale_orders,
    (SELECT COUNT(*) FROM sale_order_line) as order_lines,
    (SELECT COUNT(*) FROM product_product) as products,
    (SELECT COUNT(*) FROM account_invoice) as invoices;


