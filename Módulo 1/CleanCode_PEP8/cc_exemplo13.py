## Não utilização de princípios da Orientação a Objetos
## p.e. encapsulamento

# Código Ruim
item_price = 50

def apply_discount(discount):
    global item_price
    item_price -= discount


# Código Bom
class Item:
    def __init__(self, price):
        self.price = price

    def apply_discount(self, discount):
        self.price -= discount

item = Item(50)
item.apply_discount(10)
