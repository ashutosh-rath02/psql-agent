"""
Currency Formatter
Formats numeric values as currency for display
"""

from decimal import Decimal


class CurrencyFormatter:
    """Handles currency formatting for output"""
    
    CURRENCY_KEYWORDS = [
        'amount', 'price', 'cost', 'revenue', 'value',
        'price_unit', 'price_subtotal', 'list_price', 'standard_price'
    ]
    
    EXCLUDE_KEYWORDS = [
        'quantity', 'qty', 'count', 'number', 'total_count'
    ]
    
    @staticmethod
    def format_currency_value(value) -> str:
        """Format numeric value as currency"""
        try:
            if value is None:
                return None
            
            # Convert to float for formatting
            if not isinstance(value, (int, float, Decimal)):
                value = float(value)
            
            return f"${value:,.2f}"
        except (ValueError, TypeError, AttributeError):
            return str(value)
    
    @staticmethod
    def is_currency_column(col_name: str) -> bool:
        """Check if column name suggests it contains currency values"""
        col_lower = col_name.lower()
        
        # First check if it's explicitly excluded (quantity counts, etc.)
        if any(exclude in col_lower for exclude in CurrencyFormatter.EXCLUDE_KEYWORDS):
            return False
        
        # Check for currency keywords
        if any(keyword in col_lower for keyword in CurrencyFormatter.CURRENCY_KEYWORDS):
            return True
        
        # Check for "total" but only with currency context (amount, price, etc.)
        if 'total' in col_lower:
            currency_indicators = ['amount', 'price', 'cost', 'revenue', 'sales', 'revenue', 'income']
            if any(indicator in col_lower for indicator in currency_indicators):
                return True
        
        # Check for "sum" but only with currency context
        if 'sum' in col_lower:
            currency_indicators = ['amount', 'price', 'cost', 'revenue']
            if any(indicator in col_lower for indicator in currency_indicators):
                return True
        
        return False
    
    @staticmethod
    def format_results(results: list) -> list:
        """Format currency columns in query results"""
        if not results:
            return results
        
        formatted_results = []
        
        for row in results:
            formatted_row = row.copy() if isinstance(row, dict) else dict(row)
            
            # Format currency columns
            for key, value in formatted_row.items():
                if CurrencyFormatter.is_currency_column(key) and value is not None:
                    formatted_row[key] = CurrencyFormatter.format_currency_value(value)
            
            formatted_results.append(formatted_row)
        
        return formatted_results

