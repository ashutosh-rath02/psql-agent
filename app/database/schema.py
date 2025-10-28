"""
Schema Discovery Module
Discovers and caches database schema information
"""

from typing import Dict, List, Optional
import re


class SchemaDiscovery:
    """Handles database schema discovery and caching"""
    
    def __init__(self, db_connection):
        self.db = db_connection
        self.schema_cache: Optional[Dict] = None
    
    def discover_schema(self) -> Dict:
        """Discover complete database schema"""
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
        
        results = self.db.execute_query(query)
        
        # Organize schema by table
        schema = {}
        for row in results:
            schema_name = row['table_schema']
            table_name = row['table_name']
            col_name = row['column_name']
            col_type = row['data_type']
            nullable = row['is_nullable']
            
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
        """Extract relevant tables/columns based on question keywords"""
        if not self.schema_cache:
            return ""
        
        # Extract keywords from question
        keywords = set(re.findall(r'\b\w+\b', question.lower()))
        
        relevant_tables = []
        
        for table_name, table_info in self.schema_cache.items():
            score = 0
            
            # Check table name
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
        
        # Build schema description
        schema_text = ""
        for table_name, _ in relevant_tables:
            table_info = self.schema_cache[table_name]
            schema_text += f"\nTable: {table_name}\n"
            schema_text += "Columns:\n"
            for col in table_info['columns']:
                schema_text += f"  - {col['name']} ({col['type']})\n"
        
        return schema_text

