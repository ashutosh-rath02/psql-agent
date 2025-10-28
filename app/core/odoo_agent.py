"""
Odoo.sh Core AI Agent
Orchestrates Odoo.sh database operations, AI, validation, and formatting
"""

from typing import List, Dict, Tuple
import time
from tabulate import tabulate

from app.database.odoo_connection import OdooDatabaseConnection
from app.database.schema import SchemaDiscovery
from app.ai.gemini_service import GeminiSQLGenerator
from app.security.validator import QueryValidator
from app.formatters.currency import CurrencyFormatter


class OdooDatabaseAgent:
    """Main agent class for Odoo.sh that orchestrates all components"""
    
    def __init__(self):
        self.db = OdooDatabaseConnection()
        self.schema = SchemaDiscovery(self.db)
        self.ai = GeminiSQLGenerator()
        self.validator = QueryValidator()
        self.formatter = CurrencyFormatter()
        self._last_usage_info = {}
    
    def query(self, question: str) -> Tuple[List, str]:
        """Main method: convert question to SQL, execute, and return results"""
        try:
            # Discover schema if needed
            if not self.schema.schema_cache:
                print("[+] Discovering Odoo database schema...")
                self.schema.discover_schema()
            
            # Get relevant schema for context
            schema_context = self.schema.get_relevant_schema(question)
            
            # Generate SQL and get token usage
            sql, usage_info = self.ai.generate_sql(question, schema_context)
            
            # Store usage info for logging
            self._last_usage_info = usage_info
            
            # Validate and execute
            self.validator.validate_query(sql)
            sql = self.validator.add_limit_if_needed(sql)
            
            print(f"\n[DB] Executing query on Odoo.sh:\n{sql}\n")
            
            start_time = time.time()
            results = self.db.execute_query(sql)
            execution_time = time.time() - start_time
            
            print(f"\n[+] Query executed in {execution_time:.2f}s")
            print(f"[+] Retrieved {len(results)} rows\n")
            
            if results:
                # Format currency values
                formatted_results = self.formatter.format_results(results)
                
                # Display results
                print(tabulate(formatted_results, headers='keys', tablefmt='grid'))
            
            return results, sql
            
        except Exception as e:
            print(f"\n[!] Error: {e}")
            return None, None


