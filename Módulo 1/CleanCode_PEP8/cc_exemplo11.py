## Docstrings Explicativas para Métodos Públicos

# Código Ruim
class Calculator:
    def add(self, a, b):
        return a + b

    def subtract(self, a, b):
        return a - b


# Código Bom
class Calculator:
    """Classe para realizar operações matemáticas básicas."""

    def add(self, a, b):
        """Retorna a soma de a e b."""
        return a + b

    def subtract(self, a, b):
        """Retorna a subtração de b de a."""
        return a - b
