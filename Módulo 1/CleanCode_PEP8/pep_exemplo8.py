## Espaçamento em Parâmetros e Atribuições


# Código Ruim
def calculate_sum(a = 10, b=5):
    result=a+b
    return result


# Código Bom
def calculate_sum(a=10, b=5):
    result = a + b
    return result
