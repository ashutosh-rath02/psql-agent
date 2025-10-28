# PostgreSQL AI Agent

A simple AI agent that converts natural language questions to SQL queries for PostgreSQL databases (specifically designed for Odoo DB).

## Features

- 🤖 Natural language to SQL conversion using Google Gemini
- 🗄️ Automatic schema discovery
- 🔒 Safe read-only query execution
- ⚡ Fast and simple CLI interface

## Setup

### Option A: Use Test Database (Docker) - Recommended for Testing

First, start the Docker test database:

```bash
docker-compose up -d
```

Then skip to Step 3 below. The `.env` is already configured for the test database.

### Option B: Connect to Your Own Database

### 1. Install Dependencies

```bash
pip install -r requirements.txt
```

### 2. Configure Environment

Copy `env.example` to `.env` and fill in your database credentials and Gemini API key:

**Windows (PowerShell):**

```powershell
Copy-Item env.example .env
# Edit .env with your credentials
```

**Mac/Linux:**

```bash
cp env.example .env
# Edit .env with your credentials
```

Required variables:

- `POSTGRES_HOST` - Database host
- `POSTGRES_PORT` - Database port (default: 5432)
- `POSTGRES_DB` - Database name
- `POSTGRES_USER` - Database user (recommended: read-only user)
- `POSTGRES_PASSWORD` - Database password
- `GOOGLE_API_KEY` - Gemini API key

### 3. Get Gemini API Key

1. Go to https://makersuite.google.com/app/apikey
2. Create an API key
3. Add it to your `.env` file

## 🐳 Test Database (Docker)

Don't have a database yet? Use our Docker test database:

```bash
# Start test database
docker-compose up -d

# Test it
python agent.py "How many customers do we have?"
```

See `DOCKER-SETUP.md` for full details.

## Usage

### Single Question

```bash
python agent.py "What were total sales last month?"
```

### Interactive Mode

```bash
python agent.py --interactive
```

## Examples

```bash
# Sales analysis
python agent.py "Show me top 10 customers by revenue this year"

# Inventory check
python agent.py "Which products are out of stock?"

# Customer insights
python agent.py "Show customers who haven't ordered in 90 days"
```

## Security

- Only SELECT queries are allowed
- All queries have a 30s timeout
- Automatic LIMIT clauses to prevent excessive data retrieval
- Use a read-only database user for safety

## Project Structure

```
postgres-agent/
├── agent.py          # CLI interface
├── db_agent.py       # Core agent logic
├── requirements.txt  # Python dependencies
├── env.example       # Environment template
├── PRD.md           # Project requirements
└── README.md        # This file
```

## How It Works

1. **Connect** to PostgreSQL database
2. **Discover** schema (tables and columns)
3. **Convert** your question to SQL using Gemini AI
4. **Validate** query (SELECT only, timeouts)
5. **Execute** and display results in a readable format

## Limitations

- Read-only queries only (no INSERT, UPDATE, DELETE)
- Limited to PostgreSQL
- Requires Gemini API access
- Designed for Odoo databases but works with any Postgres DB

## Troubleshooting

**Connection Error**: Check your database credentials in `.env`

**API Error**: Verify your Gemini API key is correct

**Timeout**: Query exceeded 30s limit, try adding more specific filters

**No Results**: Check if tables/columns exist in your database
