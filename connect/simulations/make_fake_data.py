import argparse
import pandas as pd
import numpy as np
from sqlalchemy import create_engine
from faker import Faker
import time
from datetime import datetime

# função para parsear a saída do parâmetro SILENT
def str2bool(v):
    if isinstance(v, bool):
       return v
    if v.lower() in ('yes', 'true', 't', 'y', '1'):
        return True
    elif v.lower() in ('no', 'false', 'f', 'n', '0'):
        return False
    else:
        raise argparse.ArgumentTypeError('Boolean value expected.')

# Instancia a classe Faker
faker = Faker()

# Função MAIN
if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='Generate fake data...')

    parser.add_argument('--interval', type=float, default=0.5,
                        help='interval of generating fake data in seconds')
    parser.add_argument('-n', type=int, default=1,
                        help='sample size')
    parser.add_argument('--connection-string', '-cs', dest="connection_string", 
                        type=str, default='postgresql://postgres:Ney1987@localhost:5432/postgres',
                        help='Connection string to the database')
    parser.add_argument('--silent', type=str2bool, nargs='?',
                        const=True, default=False,
                        help="print fake data")

    args = parser.parse_args()

    print(f"Args parsed:")
    print(f"Interval: {args.interval}")
    print(f"Sample size; {args.n}")
    print(f"Connection string: {args.connection_string}", end='\n\n')

    #-----------------------------------------------------------------

    engine = create_engine(args.connection_string)

    print("Iniciando a simulacao...", end="\n\n")

    # Gera dados fake a faz ingestáo
    while True:
        nome       = [faker.name() for i in range(args.n)]
        gender     = [np.random.choice(["M", "F"], p=[0.5, 0.5]) for i in range(args.n)]
        endereco   = [faker.address() for i in range(args.n)]
        telefone   = [faker.phone_number() for i in range(args.n)]
        email      = [faker.safe_email() for i in range(args.n)]
        foto       = [faker.image_url() for i in range(args.n)]
        nascimento = [faker.date_of_birth().strftime("%Y-%m-%d") for i in range(args.n)]
        profissao  = [faker.job() for i in range(args.n)]
        dt_update  = [datetime.now() for i in range(args.n)]

        df = pd.DataFrame({
            "nome": nome,
            "sexo": gender,
            "endereco": endereco,
            "telefone": telefone,
            "email": email,
            "foto": foto,
            "nascimento": nascimento,
            "profissao": profissao,
            "dt_update": dt_update
        })

        df.to_sql("customers", con=engine, if_exists="append", index=False)

        if not args.silent:
            print(df, end="\n\n")

        time.sleep(args.interval)