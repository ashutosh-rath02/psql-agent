"""
Gemini AI Service for SQL Generation
"""

import os
import re
from datetime import datetime
from pathlib import Path
import google.generativeai as genai
from dotenv import load_dotenv

load_dotenv()


class GeminiSQLGenerator:
    """Uses Gemini AI to generate SQL queries from natural language"""
    
    def __init__(self):
        api_key = os.getenv('GOOGLE_API_KEY')
        if not api_key:
            raise ValueError("GOOGLE_API_KEY not found in environment")
        genai.configure(api_key=api_key)
        self.model = genai.GenerativeModel('gemini-2.0-flash-exp')
        self.log_file = Path("token_usage.txt")
    
    def log_token_usage(self, question: str, sql: str, usage_info: dict):
        """Log token usage to a text file"""
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        
        log_entry = f"""
{'='*70}
Timestamp: {timestamp}
Question: {question}
Generated SQL: {sql[:200]}...
Token Usage:
  - Prompt Tokens: {usage_info.get('prompt_token_count', 'N/A')}
  - Candidates Tokens: {usage_info.get('candidates_token_count', 'N/A')}
  - Total Tokens: {usage_info.get('total_token_count', 'N/A')}
Model: gemini-2.0-flash-exp
{'='*70}

"""
        
        # Append to log file
        with open(self.log_file, 'a', encoding='utf-8') as f:
            f.write(log_entry)
        
        # Also print to console
        print(f"\n[Token Usage] Prompt: {usage_info.get('prompt_token_count', 'N/A')}, "
              f"Response: {usage_info.get('candidates_token_count', 'N/A')}, "
              f"Total: {usage_info.get('total_token_count', 'N/A')}")
    
    def generate_sql(self, question: str, schema_context: str = ""):
        """Generate SQL query from natural language question
        
        Returns:
            tuple: (sql_query, usage_info_dict)
        """
        print(f"\n[AI] Generating SQL for: \"{question}\"")
        
        prompt = f"""
You are an expert at generating SQL queries for PostgreSQL database.

Database Schema:
{schema_context}

Generate a SQL query to answer this question: {question}

Requirements:
1. Return ONLY the SQL query, no explanations
2. The database is Odoo (ERP), use common Odoo conventions
3. Use proper JOINs, aggregate functions where needed
4. Filter out inactive records (active=false) when present
5. Add a reasonable LIMIT if not specified
6. Only use SELECT queries (read-only)
7. Use PostgreSQL syntax
8. Handle common Odoo fields like 'active', 'state', 'date_order', etc.
9. When returning currency amounts, use descriptive column names like 'total_sales', 'amount_total', etc.

SQL Query:
"""
        
        # Generate content
        response = self.model.generate_content(prompt)
        
        # Extract SQL from response
        sql = response.text.strip()
        
        # Clean up SQL (remove markdown code blocks if present)
        if sql.startswith('```'):
            sql = re.sub(r'```sql?\s*', '', sql)
            sql = re.sub(r'```\s*$', '', sql)
        sql = sql.strip()
        
        # Extract usage metadata
        usage_info = {}
        
        # Try to get usage metadata from response
        try:
            if hasattr(response, 'usage_metadata'):
                usage_info = {
                    'prompt_token_count': getattr(response.usage_metadata, 'prompt_token_count', 'N/A'),
                    'candidates_token_count': getattr(response.usage_metadata, 'candidates_token_count', 'N/A'),
                    'total_token_count': getattr(response.usage_metadata, 'total_token_count', 'N/A'),
                }
        except Exception as e:
            print(f"[Warning] Could not extract usage metadata: {e}")
        
        # Log token usage
        self.log_token_usage(question, sql, usage_info)
        
        return sql, usage_info

