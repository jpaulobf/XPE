# Código Ruim
def calculate_total(price, tax):
    # calcula o total incluindo impostos
    total = price + (price * tax) 
    return total


# Código Bom
def calculate_total_with_tax(price, tax_rate):
    return price + (price * tax_rate)
