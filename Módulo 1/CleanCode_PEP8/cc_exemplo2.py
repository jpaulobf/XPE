## Código morto ou redundante

# Código Ruim
def calculate_discount(price):
    discount = price * 0.1
    final_price = price - discount
    # print("Calculating discount...") # Código morto
    return final_price


# Código Bom
def calculate_discount(price):
    discount = price * 0.1
    return price - discount
