
# Funções muito longas

# Código Ruim
def generate_report(data):
    # Filtra os dados
    filtered_data = [d for d in data if d > 0]
    # Calcula a média
    avg = sum(filtered_data) / len(filtered_data)
    # Imprime o relatório
    print("Relatório")
    print("Dados filtrados:", filtered_data)
    print("Média:", avg)


# Código Bom
def filter_data(data):
    return [d for d in data if d > 0]

def calculate_average(data):
    return sum(data) / len(data)

def print_report(filtered_data, avg):
    print("Relatório")
    print("Dados filtrados:", filtered_data)
    print("Média:", avg)

def generate_report(data):
    filtered_data = filter_data(data)
    avg = calculate_average(filtered_data)
    print_report(filtered_data, avg)


