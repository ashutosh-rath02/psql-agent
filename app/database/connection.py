"""
Database Connection Manager
Handles connection, disconnection, and connection pooling
"""

import os
import psycopg2
import psycopg2.extras
from contextlib import contextmanager
from dotenv import load_dotenv

load_dotenv()


class DatabaseConnection:
    """Manages PostgreSQL database connections"""
    
    def __init__(self):
        self.config = {
            'host': os.getenv('POSTGRES_HOST', 'localhost'),
            'port': os.getenv('POSTGRES_PORT', '5432'),
            'database': os.getenv('POSTGRES_DB'),
            'user': os.getenv('POSTGRES_USER'),
            'password': os.getenv('POSTGRES_PASSWORD'),
        }
    
    def connect(self):
        """Create and return a database connection"""
        try:
            conn = psycopg2.connect(**self.config)
            print(f"[+] Connected to database: {self.config['database']}")
            return conn
        except Exception as e:
            raise ConnectionError(f"Failed to connect to database: {e}")
    
    @contextmanager
    def get_connection(self):
        """Context manager for database connections"""
        conn = None
        try:
            conn = self.connect()
            yield conn
        finally:
            if conn:
                conn.close()
                print("[+] Disconnected from database")
    
    def execute_query(self, sql, params=None, timeout=30):
        """Execute a query and return results"""
        with self.get_connection() as conn:
            conn.set_session(readonly=True, autocommit=True)
            cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
            
            try:
                # Set timeout
                cursor.execute(f"SET statement_timeout = {timeout * 1000};")
                cursor.execute(sql, params)
                results = cursor.fetchall()
                
                # Convert to list of dicts
                return [dict(row) for row in results]
            except psycopg2.extensions.QueryCanceledError:
                raise TimeoutError(f"Query exceeded {timeout}s timeout")
            except Exception as e:
                raise RuntimeError(f"Query execution failed: {e}")
            finally:
                cursor.close()

