## Duplicação de Código

# Código Ruim
def print_report(data):
    print("Relatório de Vendas:")
    for sale in data:
        print(f"Produto: {sale['product']}, Quantidade: {sale['quantity']}, Preço: {sale['price']}")
    print("\nRelatório de Compras:")
    for purchase in data:
        print(f"Produto: {purchase['product']}, Quantidade: {purchase['quantity']}, Preço: {purchase['price']}")


# Código Bom
def print_items(title, items):
    print(title)
    for item in items:
        print(f"Produto: {item['product']}, Quantidade: {item['quantity']}, Preço: {item['price']}")

def print_report(data):
    print_items("Relatório de Vendas:", data["sales"])
    print_items("Relatório de Compras:", data["purchases"])
