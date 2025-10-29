"""
Odoo.sh PostgreSQL AI Agent - CLI Interface
Entry point for connecting to Odoo.sh databases
"""

import sys
import argparse
from app.core.odoo_agent import OdooDatabaseAgent


def main():
    parser = argparse.ArgumentParser(
        description='Odoo.sh AI Agent - Query Odoo database with natural language'
    )
    
    parser.add_argument(
        'question',
        nargs='?',
        help='Natural language question to ask about the database'
    )
    
    parser.add_argument(
        '--interactive', '-i',
        action='store_true',
        help='Run in interactive mode'
    )
    
    parser.add_argument(
        '--test-connection',
        action='store_true',
        help='Test database connection'
    )
    
    args = parser.parse_args()
    
    # Initialize agent
    agent = OdooDatabaseAgent()
    
    try:
        if args.test_connection:
            # Test connection mode
            print("\n🔌 Testing Odoo.sh connection...")
            success = agent.db.test_connection()
            if success:
                print("✅ Connection successful!")
            else:
                print("❌ Connection failed!")
                sys.exit(1)
                
        elif args.interactive:
            # Interactive mode
            print("\n🤖 Odoo.sh AI Agent - Interactive Mode")
            print("Type 'exit' or 'quit' to exit\n")
            
            while True:
                question = input("Ask a question: ").strip()
                
                if question.lower() in ['exit', 'quit', 'q']:
                    break
                
                if not question:
                    continue
                
                try:
                    agent.query(question)
                except Exception as e:
                    print(f"\n❌ Error: {e}\n")
                    
        elif args.question:
            # Single question mode
            agent.query(args.question)
            
        else:
            # No question provided
            parser.print_help()
            
    except Exception as e:
        print(f"\nERROR: Fatal error: {e}")
        sys.exit(1)


if __name__ == '__main__':
    main()



