## Nomenclatura


# Código Ruim
def d(a, b):
    c = a * b
    if c > 10:
        return True
    else:
        return False


# Código Bom
def is_product_greater_than_ten(num1, num2):
    product = num1 * num2
    return product > 10