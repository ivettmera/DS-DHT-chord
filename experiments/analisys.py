#importar los csv y hacer un promedio para cada numero de nodos
#hacer un grafico scatter de los promedios (milisegundos) por la cantidad de nodos
#nombre del grafica Latencia vs Escala de Nodos
import pandas as pd
import matplotlib.pyplot as plt

def plot_latency_vs_nodes(file_paths, labels):
    all_data = []

    for file_path, label in zip(file_paths, labels):
        # Leer el archivo CSV
        data = pd.read_csv(file_path)
        
        # Agrupar por 'num_nodos' y calcular el promedio de 'latencia_ms'
        grouped_data = data.groupby('num_nodos')['latencia_ms'].mean().reset_index()
        grouped_data['label'] = label
        all_data.append(grouped_data)

    # Concatenar todos los datos en un solo DataFrame
    combined_data = pd.concat(all_data)

    # Crear el gráfico scatter
    plt.figure(figsize=(10, 6))
    for label in labels:
        subset = combined_data[combined_data['label'] == label]
        plt.scatter(subset['num_nodos'], subset['latencia_ms'], label=label)

    plt.title('Latencia vs Escala de Nodos')
    plt.xlabel('Número de Nodos')
    plt.ylabel('Latencia (ms)')
    plt.legend()
    plt.grid(True)
    plt.show()