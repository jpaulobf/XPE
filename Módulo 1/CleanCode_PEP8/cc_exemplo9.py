## Uso apropriado de exceções


# Código Ruim
def divide(a, b):
    try:
        return a / b
    except:
        return "Erro!"


# Código Bom
def divide(a, b):
    try:
        return a / b
    except ZeroDivisionError:
        return "Divisão por zero não é permitida!"
    except TypeError:
        return "Entradas devem ser números!"
