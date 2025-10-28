"""
Query Validator - Ensures SQL queries are safe to execute
"""

class QueryValidator:
    """Validates that SQL queries are safe (SELECT only, no dangerous operations)"""
    
    DANGEROUS_KEYWORDS = [
        'DROP', 'DELETE', 'TRUNCATE', 'UPDATE', 'INSERT',
        'ALTER', 'CREATE', 'GRANT', 'REVOKE', 'EXECUTE'
    ]
    
    @staticmethod
    def validate_query(sql: str) -> bool:
        """Validate that query is safe to execute (SELECT only)"""
        sql_upper = sql.upper().strip()
        
        # Check for dangerous operations
        for keyword in QueryValidator.DANGEROUS_KEYWORDS:
            if keyword in sql_upper:
                raise ValueError(f"Query contains forbidden operation: {keyword}")
        
        # Must start with SELECT or WITH
        if not (sql_upper.startswith('SELECT') or sql_upper.startswith('WITH')):
            raise ValueError("Only SELECT queries are allowed")
        
        return True
    
    @staticmethod
    def add_limit_if_needed(sql: str, default_limit: int = 100) -> str:
        """Add LIMIT clause if query doesn't have one"""
        sql_upper = sql.upper()
        
        if 'LIMIT' not in sql_upper:
            # Remove trailing semicolon if present
            has_semicolon = sql.rstrip().endswith(';')
            sql = sql.rstrip().rstrip(';')
            
            # Add appropriate LIMIT
            if 'GROUP BY' in sql_upper or 'ORDER BY' in sql_upper:
                sql += f"\nLIMIT {default_limit}"
            elif 'WHERE' in sql_upper or 'JOIN' in sql_upper:
                sql += f"\nLIMIT {default_limit}"
            else:
                sql += f"\nLIMIT {default_limit}"
            
            # Add semicolon back if it was there
            if has_semicolon:
                sql += ';'
            else:
                sql += ';'
        
        return sql

