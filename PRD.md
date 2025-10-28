# PostgreSQL AI Agent - MVP

## 📋 Project Overview

Build a simple AI agent that converts natural language to SQL queries for a PostgreSQL database (specifically Odoo DB).

### MVP Features

- Natural language to SQL conversion using Gemini AI
- Auto-detect Odoo business tables
- Safe read-only query execution
- Simple CLI interface

---

## 🎯 Core Requirements

1. Connect to PostgreSQL and discover schema
2. Convert natural language to SQL using Gemini
3. Execute queries safely (SELECT only, timeout)
4. Display results in readable format

---

## 🛠️ Technology Stack

- **AI**: Google Gemini (`gemini-2.0-flash-exp`)
- **Database**: PostgreSQL with `psycopg2-binary`
- **Language**: Python 3.8+
- **Interface**: CLI tool

### Dependencies

```
google-generativeai>=0.3.0
psycopg2-binary>=2.9.0
python-dotenv>=1.0.0
tabulate>=0.9.0
```

---

## 🔄 How It Works

1. Connect to PostgreSQL and discover tables/columns
2. User asks a natural language question
3. Gemini generates SQL based on schema + question
4. Validate query (SELECT only, add LIMIT if needed)
5. Execute with timeout
6. Display results in table format

---

## 💻 Usage Example

```bash
python agent.py "What were total sales last month?"
```

Generates and executes:

```sql
SELECT SUM(amount_total)
FROM sale_order
WHERE date_order >= CURRENT_DATE - INTERVAL '1 month'
AND state IN ('sale', 'done')
```

---

## 🔧 Setup

### 1. Environment Variables (.env file)

```bash
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DB=odoo_production
POSTGRES_USER=odoo_readonly
POSTGRES_PASSWORD=your_password
GOOGLE_API_KEY=your_gemini_api_key
```

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

### 3. Run

```bash
python agent.py "Your question here"
```
