"""
PostgreSQL AI Agent - CLI Interface
Simple command-line interface for querying database with natural language
"""

import sys
import argparse
from db_agent import DatabaseAgent


def main():
    parser = argparse.ArgumentParser(
        description='PostgreSQL AI Agent - Query database with natural language'
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
    
    args = parser.parse_args()
    
    # Initialize agent
    agent = DatabaseAgent()
    
    try:
        # Connect to database
        agent.connect()
        
        # Discover schema (one-time setup)
        agent.discover_schema()
        
        if args.interactive:
            # Interactive mode
            print("\n🤖 PostgreSQL AI Agent - Interactive Mode")
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
        
    finally:
        agent.disconnect()


if __name__ == '__main__':
    main()

