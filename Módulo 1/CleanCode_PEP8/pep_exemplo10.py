## Uso de List Comprehensions para Melhor Performance e Legibilidade

# Código Ruim
squared_numbers = []
for i in range(10):
    squared_numbers.append(i ** 2)


# Código Bom
squared_numbers = [i ** 2 for i in range(10)]
