## Código Duplicado


# Código Ruim
def calculate_total_with_discount(price, discount):
    if discount > 0:
        total = price - (price * discount)
    else:
        total = price
    return total

def calculate_total_with_tax(price, tax):
    total = price + (price * tax)
    return total



# Código Bom
def calculate_total(price, rate=0, is_discount=False):
    if is_discount:
        return price - (price * rate)
    return price + (price * rate)
