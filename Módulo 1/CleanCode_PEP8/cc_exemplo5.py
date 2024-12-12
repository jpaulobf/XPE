## função com multiplas responsabilidades


# Código Ruim
def process_data(data):
    # Filtrar os dados
    filtered_data = [item for item in data if item > 10]
    # Ordenar os dados
    filtered_data.sort()
    # Calcular a média
    avg = sum(filtered_data) / len(filtered_data)
    return avg


# Código Bom
def filter_data(data):
    return [item for item in data if item > 10]

def sort_data(data):
    return sorted(data)

def calculate_average(data):
    return sum(data) / len(data)

def process_data(data):
    filtered = filter_data(data)
    sorted_data = sort_data(filtered)
    return calculate_average(sorted_data)


