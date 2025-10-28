"""
Odoo.sh SSH Connection Manager
Handles SSH tunnel and database connection to Odoo.sh instances using paramiko
"""

import os
import socket
import threading
import psycopg2
import psycopg2.extras
from contextlib import contextmanager
from dotenv import load_dotenv
import paramiko
import atexit

load_dotenv()


class OdooDatabaseConnection:
    """Manages PostgreSQL connection through SSH tunnel to Odoo.sh"""
    
    def __init__(self):
        self.tunnel = None
        self.local_port = None
        self.ssh_client = None
        self.local_socket = None
        
        # SSH Configuration
        ssh_host = os.getenv('ODOO_SSH_HOST')
        ssh_username = os.getenv('ODOO_SSH_USERNAME')
        ssh_key_path = os.path.expanduser(os.getenv('ODOO_SSH_KEY_PATH', '~/.ssh/ai_agent_id_ed25519'))
        ssh_port = int(os.getenv('ODOO_SSH_PORT', '22'))
        
        # Database Configuration
        db_user = os.getenv('ODOO_DB_USER') or ssh_username
        db_password = os.getenv('ODOO_DB_PASSWORD') or ''
        
        self.ssh_config = {
            'host': ssh_host,
            'username': ssh_username,
            'pkey': ssh_key_path,
            'port': ssh_port,
        }
        
        self.db_config = {
            'host': '127.0.0.1',  # Will be updated after tunnel starts
            'database': os.getenv('ODOO_DB_NAME'),
            'user': db_user,
            'password': db_password,
        }
        
        # Start tunnel on init
        self.start_tunnel()
        
        # Register cleanup on exit
        atexit.register(self.stop_tunnel)
    
    def start_tunnel(self):
        """Start the SSH tunnel connection using paramiko"""
        try:
            ssh_host = self.ssh_config['host']
            ssh_port = self.ssh_config['port']
            username = self.ssh_config['username']
            key_path = self.ssh_config['pkey']
            
            print(f"[+] Establishing SSH tunnel to {ssh_host}:{ssh_port}...")
            
            # Create SSH client
            self.ssh_client = paramiko.SSHClient()
            self.ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            
            # Load the SSH key
            try:
                # Try Ed25519 key first
                key = paramiko.Ed25519Key.from_private_key_file(key_path)
            except Exception:
                # Try RSA key as fallback
                key = paramiko.RSAKey.from_private_key_file(key_path)
            
            # Connect to SSH server
            self.ssh_client.connect(
                hostname=ssh_host,
                port=ssh_port,
                username=username,
                pkey=key,
                look_for_keys=False,
                allow_agent=False,
                timeout=30
            )
            
            print(f"[+] SSH connection established")
            
            # Create local socket that forwards to remote PostgreSQL
            self.local_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.local_socket.bind(('127.0.0.1', 0))
            self.local_socket.listen(1)
            self.local_port = self.local_socket.getsockname()[1]
            
            # Update db config with local port
            self.db_config['port'] = self.local_port
            
            print(f"[+] Starting port forward thread on local port {self.local_port}...")
            
            # Start forwarding in a separate thread
            self.forward_thread = threading.Thread(
                target=self._forward_connection,
                daemon=True
            )
            self.forward_thread.start()
            
            print(f"[+] SSH tunnel established on port {self.local_port}")
            
        except Exception as e:
            raise ConnectionError(f"Failed to establish SSH tunnel: {e}")
    
    def _forward_connection(self):
        """Forward connections from local socket to remote PostgreSQL"""
        while True:
            try:
                local_conn, _ = self.local_socket.accept()
                # Create transport channel
                transport = self.ssh_client.get_transport()
                
                # Open channel for forwarding
                channel = transport.open_channel(
                    'direct-tcpip',
                    ('localhost', 5432),  # Remote PostgreSQL
                    ('127.0.0.1', self.local_port)
                )
                
                # Forward data between sockets
                def forward_data(src, dst):
                    try:
                        while True:
                            data = src.recv(4096)
                            if not data:
                                break
                            dst.send(data)
                    except Exception:
                        pass
                    finally:
                        src.close()
                        dst.close()
                
                # Start forwarding in both directions
                threading.Thread(target=forward_data, args=(local_conn, channel), daemon=True).start()
                threading.Thread(target=forward_data, args=(channel, local_conn), daemon=True).start()
                
            except Exception:
                break
    
    def stop_tunnel(self):
        """Stop the SSH tunnel"""
        try:
            if self.local_socket:
                print("[+] Closing SSH tunnel...")
                self.local_socket.close()
            
            if self.ssh_client:
                self.ssh_client.close()
            
            print("[+] SSH tunnel closed")
        except Exception as e:
            print(f"[!] Error closing SSH tunnel: {e}")
    
    def connect(self):
        """Create and return a database connection through tunnel"""
        try:
            # Wait a bit for the tunnel to be ready
            import time
            time.sleep(0.5)
            
            conn = psycopg2.connect(**self.db_config)
            print(f"[+] Connected to database: {self.db_config['database']}")
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
    
    def test_connection(self):
        """Test the database connection"""
        try:
            conn = self.connect()
            cursor = conn.cursor()
            cursor.execute("SELECT version();")
            version = cursor.fetchone()
            cursor.close()
            conn.close()
            print(f"[+] Database connection successful")
            print(f"[+] PostgreSQL version: {version[0]}")
            return True
        except Exception as e:
            print(f"[!] Connection test failed: {e}")
            return False
