"""
PostgreSQL AI Agent - Core Agent Logic
Converts natural language to SQL and executes safely
"""

import os
import re
import time
from typing import List, Dict, Tuple, Optional
import psycopg2
import psycopg2.extras
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
import google.generativeai as genai
from dotenv import load_dotenv

load_dotenv()


class DatabaseAgent:
    def __init__(self):
        """Initialize the database agent with DB and AI connections"""
        self.db_conn = None
        self.genai = None
        self.schema_cache = None
        
        # Load credentials
        self.db_config = {
            'host': os.getenv('POSTGRES_HOST', 'localhost'),
            'port': os.getenv('POSTGRES_PORT', '5432'),
            'database': os.getenv('POSTGRES_DB'),
            'user': os.getenv('POSTGRES_USER'),
            'password': os.getenv('POSTGRES_PASSWORD'),
        }
        
        # Initialize Gemini
        api_key = os.getenv('GOOGLE_API_KEY')
        if not api_key:
            raise ValueError("GOOGLE_API_KEY not found in environment")
        genai.configure(api_key=api_key)
        
    def connect(self):
        """Connect to PostgreSQL database"""
        try:
            self.db_conn = psycopg2.connect(**self.db_config)
            print(f"[+] Connected to database: {self.db_config['database']}")
        except Exception as e:
            raise ConnectionError(f"Failed to connect to database: {e}")
    
    def disconnect(self):
        """Close database connection"""
        if self.db_conn:
            self.db_conn.close()
            print("[+] Disconnected from database")
    
    def discover_schema(self) -> Dict:
        """Discover database schema by querying information_schema"""
        print("Discovering database schema...")
        
        query = """
        SELECT 
            table_schema,
            table_name,
            column_name,
            data_type,
            is_nullable
        FROM information_schema.columns
        WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
        ORDER BY table_name, ordinal_position
        """
        
        cursor = self.db_conn.cursor()
        cursor.execute(query)
        rows = cursor.fetchall()
        cursor.close()
        
        # Organize schema by table
        schema = {}
        for row in rows:
            schema_name, table_name, col_name, col_type, nullable = row
            full_table = f"{schema_name}.{table_name}" if schema_name != 'public' else table_name
            
            if full_table not in schema:
                schema[full_table] = {
                    'table_name': table_name,
                    'schema': schema_name,
                    'columns': []
                }
            
            schema[full_table]['columns'].append({
                'name': col_name,
                'type': col_type,
                'nullable': nullable == 'YES'
            })
        
        print(f"[+] Discovered {len(schema)} tables")
        self.schema_cache = schema
        return schema
    
    def get_relevant_schema(self, question: str, limit: int = 10) -> str:
        """
        Extract relevant tables/columns based on keywords in the question.
        Returns a simplified schema description for context.
        """
        if not self.schema_cache:
            return ""
        
        # Extract keywords from question
        keywords = set(re.findall(r'\b\w+\b', question.lower()))
        
        relevant_tables = []
        
        for table_name, table_info in self.schema_cache.items():
            score = 0
            # Check if table name contains keywords
            table_lower = table_name.lower()
            for keyword in keywords:
                if keyword in table_lower:
                    score += 2
                # Check column names
                for col in table_info['columns']:
                    if keyword in col['name'].lower():
                        score += 1
            
            if score > 0:
                relevant_tables.append((table_name, score))
        
        # Sort by score and take top N
        relevant_tables.sort(key=lambda x: x[1], reverse=True)
        relevant_tables = relevant_tables[:limit]
        
        # Build schema description for Gemini
        schema_text = ""
        for table_name, _ in relevant_tables:
            table_info = self.schema_cache[table_name]
            schema_text += f"\nTable: {table_name}\n"
            schema_text += "Columns:\n"
            for col in table_info['columns']:
                schema_text += f"  - {col['name']} ({col['type']})\n"
        
        return schema_text
    
    def generate_sql(self, question: str) -> str:
        """Use Gemini to generate SQL from natural language question"""
        print(f"\n[AI] Generating SQL for: \"{question}\"")
        
        # Get relevant schema
        schema = self.get_relevant_schema(question)
        
        # Build prompt for Gemini
        prompt = f"""
You are an expert at generating SQL queries for PostgreSQL database.

Database Schema:
{schema}

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

SQL Query:
"""
        
        model = genai.GenerativeModel('gemini-2.0-flash-exp')
        response = model.generate_content(prompt)
        
        # Extract SQL from response
        sql = response.text.strip()
        
        # Clean up SQL (remove markdown code blocks if present)
        if sql.startswith('```'):
            sql = re.sub(r'```sql?\s*', '', sql)
            sql = re.sub(r'```\s*$', '', sql)
        
        return sql.strip()
    
    def validate_query(self, sql: str) -> bool:
        """Validate that query is safe to execute (SELECT only)"""
        sql_upper = sql.upper().strip()
        
        # Check for dangerous operations
        dangerous_keywords = [
            'DROP', 'DELETE', 'TRUNCATE', 'UPDATE', 'INSERT',
            'ALTER', 'CREATE', 'GRANT', 'REVOKE', 'EXECUTE'
        ]
        
        for keyword in dangerous_keywords:
            if keyword in sql_upper:
                raise ValueError(f"Query contains forbidden operation: {keyword}")
        
        # Must start with SELECT or WITH
        if not (sql_upper.startswith('SELECT') or sql_upper.startswith('WITH')):
            raise ValueError("Only SELECT queries are allowed")
        
        return True
    
    def add_limit_if_needed(self, sql: str, default_limit: int = 100) -> str:
        """Add LIMIT clause if query doesn't have one"""
        sql_upper = sql.upper()
        
        if 'LIMIT' not in sql_upper:
            # Remove trailing semicolon if present
            has_semicolon = sql.rstrip().endswith(';')
            sql = sql.rstrip()
            sql = sql.rstrip(';')
            
            # Check if it's a simple SELECT or has aggregation
            if 'GROUP BY' in sql_upper or 'ORDER BY' in sql_upper:
                sql += f"\nLIMIT {default_limit}"
            elif 'WHERE' in sql_upper or 'JOIN' in sql_upper:
                sql += f"\nLIMIT {default_limit}"
            else:
                # Simple SELECT might not need limit, but add a reasonable one
                sql += f"\nLIMIT {default_limit}"
            
            # Add semicolon back if it was there
            if has_semicolon:
                sql += ';'
            else:
                sql += ';'
        
        return sql
    
    def execute_query(self, sql: str, timeout: int = 30) -> Tuple[List, float]:
        """Execute SQL query with timeout and return results"""
        self.validate_query(sql)
        sql = self.add_limit_if_needed(sql)
        
        print(f"\n[DB] Executing query:\n{sql}\n")
        
        start_time = time.time()
        cursor = self.db_conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        
        try:
            # Set statement timeout
            cursor.execute(f"SET statement_timeout = {timeout * 1000};")
            cursor.execute(sql)
            
            results = cursor.fetchall()
            execution_time = time.time() - start_time
            
            cursor.close()
            
            return results, execution_time
            
        except psycopg2.extensions.QueryCanceledError:
            cursor.close()
            raise TimeoutError(f"Query exceeded {timeout}s timeout")
        except Exception as e:
            cursor.close()
            raise RuntimeError(f"Query execution failed: {e}")
    
    def query(self, question: str) -> None:
        """Main method: convert question to SQL and execute"""
        try:
            # Generate SQL
            sql = self.generate_sql(question)
            
            # Execute
            results, execution_time = self.execute_query(sql)
            
            # Display results
            print(f"\n[+] Query executed in {execution_time:.2f}s")
            print(f"[+] Retrieved {len(results)} rows\n")
            
            if results:
                # Convert to list of dicts for tabulate
                rows = []
                for row in results:
                    rows.append(dict(row))
                
                from tabulate import tabulate
                print(tabulate(rows, headers='keys', tablefmt='grid'))
            
            return results, sql
            
        except Exception as e:
            print(f"\n[!] Error: {e}")
            return None, None


if __name__ == '__main__':
    # Test the agent
    agent = DatabaseAgent()
    agent.connect()
    agent.discover_schema()
    agent.query("Show me all tables")
    agent.disconnect()

