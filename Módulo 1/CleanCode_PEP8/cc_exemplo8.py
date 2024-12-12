## Evitar Parâmetros em Excesso


# Código Ruim
def create_user(name, age, email, address, phone, is_active, is_admin):
    return {
        "name": name,
        "age": age,
        "email": email,
        "address": address,
        "phone": phone,
        "is_active": is_active,
        "is_admin": is_admin
    }



# Código Bom
def create_user(user_data):
    return {
        "name": user_data["name"],
        "age": user_data["age"],
        "email": user_data["email"],
        "address": user_data["address"],
        "phone": user_data["phone"],
        "is_active": user_data["is_active"],
        "is_admin": user_data["is_admin"]
    }
