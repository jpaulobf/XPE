## Funções Coesas que Fazem Apenas uma Coisa

# Código Ruim
def process_and_save_data(data, filename):
    # Processa os dados
    processed_data = [d.upper() for d in data]
    # Salva os dados no arquivo
    with open(filename, 'w') as file:
        file.write('\n'.join(processed_data))


# Código Bom
def process_data(data):
    return [d.upper() for d in data]

def save_data(data, filename):
    with open(filename, 'w') as file:
        file.write('\n'.join(data))

def process_and_save_data(data, filename):
    processed_data = process_data(data)
    save_data(processed_data, filename)
