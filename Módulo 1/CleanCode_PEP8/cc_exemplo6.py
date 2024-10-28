# Simplificação de Expressões Condicionais

# Código Ruim
def is_valid_age(age):
    if age >= 18 and age <= 65:
        return True
    else:
        return False


# Código Bom
def is_valid_age(age):
    return 18 <= age <= 65
