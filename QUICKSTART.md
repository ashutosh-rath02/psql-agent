# Quick Start Guide

## 🚀 Get Started in 3 Steps

> **New?** Use the Docker test database: `docker-compose up -d` then skip to Step 3!

### Step 1: Install Dependencies

```bash
pip install -r requirements.txt
```

### Step 2: Configure Environment

```powershell
# Copy the example file
Copy-Item env.example .env

# Edit .env with your actual credentials
notepad .env
```

Fill in:

- `POSTGRES_HOST` - Your database host (e.g., localhost)
- `POSTGRES_DB` - Database name (e.g., odoo_production)
- `POSTGRES_USER` - Database user (recommended: read-only user)
- `POSTGRES_PASSWORD` - Database password
- `GOOGLE_API_KEY` - Your Gemini API key (get it from https://makersuite.google.com/app/apikey)

### Step 3: Run Your First Query

```bash
python agent.py "Show me all customers"
```

Or run in interactive mode:

```bash
python agent.py --interactive
```

## 📝 Example Questions

```
"What were total sales last month?"
"Show me top 10 customers by revenue"
"Which products are out of stock?"
"List all invoices from last week"
"Show customers who haven't ordered in 90 days"
```

## 🔑 Creating a Read-Only Database User

For safety, create a read-only user:

```sql
-- Connect to your database as superuser
CREATE USER agent_user WITH PASSWORD 'secure_password';
GRANT CONNECT ON DATABASE odoo_production TO agent_user;
GRANT USAGE ON SCHEMA public TO agent_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO agent_user;

-- Make sure future tables are also accessible
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT ON TABLES TO agent_user;
```

## ⚠️ Troubleshooting

**"Module not found"**

- Run: `pip install -r requirements.txt`

**"Failed to connect to database"**

- Check your `.env` file has correct credentials
- Verify PostgreSQL is running
- Test connection with: `psql -h localhost -U your_user -d your_db`

**"GOOGLE_API_KEY not found"**

- Get API key from: https://makersuite.google.com/app/apikey
- Add it to your `.env` file

**"Query timeout"**

- Try more specific filters
- Add date ranges to your questions

## 🎯 Next Steps

- Try different types of questions
- Explore your database schema
- Customize the agent for your needs

Need help? Check README.md for more details.
