# Docker Test Database Setup

Quick guide to spin up a dummy PostgreSQL database for testing the AI agent.

## 🚀 Quick Start

### 1. Start the Database

```powershell
docker-compose up -d
```

This will:

- Download PostgreSQL 15 image
- Create a database called `odoo_test`
- Create 500+ customers, 2000+ sales orders, and 500+ invoices
- Set up a read-only user for the agent

### 2. Check Database Status

```powershell
docker ps
```

You should see `postgres-agent-test` running.

### 3. Connect and Verify

```powershell
docker exec -it postgres-agent-test psql -U odoo_readonly -d odoo_test
```

Then run:

```sql
SELECT COUNT(*) FROM res_partner;
SELECT COUNT(*) FROM sale_order;
SELECT COUNT(*) FROM sale_order_line;
```

### 4. Configure Your Agent

Update your `.env` file:

```bash
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DB=odoo_test
POSTGRES_USER=odoo_readonly
POSTGRES_PASSWORD=postgres
```

### 5. Test the Agent

```bash
python agent.py "How many customers do we have?"
python agent.py "What are total sales this month?"
python agent.py "Show top 10 products by sales"
```

## 🧹 Clean Up

### Stop the database:

```powershell
docker-compose down
```

### Remove database and data (careful!):

```powershell
docker-compose down -v
```

## 📊 What's in the Database

- **500 customers** (some active, some inactive)
- **100 products** (various categories)
- **2000 sales orders** (over last 365 days)
- **~5000 order lines** (2-6 items per order)
- **500 invoices** (different states)
- **Realistic data** with random variations

## 🔧 Advanced Usage

### View logs:

```powershell
docker logs postgres-agent-test
```

### Connect as admin:

```powershell
docker exec -it postgres-agent-test psql -U postgres -d odoo_test
```

### Recreate database:

```powershell
docker-compose down -v
docker-compose up -d
```

## 🐛 Troubleshooting

**Port already in use?**

- Check if another PostgreSQL is running on port 5432
- Stop it or change the port in `docker-compose.yml`

**Container won't start?**

- Check Docker is running: `docker ps`
- Check logs: `docker logs postgres-agent-test`

**Can't connect from agent?**

- Make sure container is running: `docker ps`
- Verify credentials in `.env` file

## 💡 Tips

- The database persists in a Docker volume
- To reset data: `docker-compose down -v` then `docker-compose up -d`
- Use `docker-compose logs` to see initialization progress
- Data is realistic but randomized each time you recreate

