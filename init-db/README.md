# Database Initialization Scripts

These scripts will create a dummy Odoo-like database with sample data.

## What Gets Created

- **500 customers** in `res_partner` table
- **100 products** in `product_product` table
- **2000 sales orders** in `sale_order` table
- **~5000 order lines** in `sale_order_line` table
- **500 invoices** in `account_invoice` table
- **100 stock records** in `stock_quant` table

## Tables Structure

### res_partner

- Customers and contacts
- Fields: id, name, email, phone, city, country, customer_rank, active

### sale_order

- Sales orders/quotations
- Fields: id, name, partner_id, date_order, state, amount_total, active
- States: draft, sent, sale, done, cancel

### sale_order_line

- Order line items
- Fields: id, order_id, product_id, product_uom_qty, price_unit, price_subtotal

### product_product

- Products catalog
- Fields: id, name, list_price, standard_price, type, active

### stock_quant

- Inventory/stock levels
- Fields: id, product_id, location_id, quantity

### account_invoice

- Invoices
- Fields: id, name, partner_id, date_invoice, state, amount_total, type

## Notes

- Scripts run automatically when Docker container starts
- Data is randomized and realistic
- Indexes are created for performance
- Read-only user is created with SELECT permissions

