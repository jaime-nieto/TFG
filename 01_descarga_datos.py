# ==============================================================================
# TRABAJO DE FIN DE GRADO - UNIVERSIDAD DE CÓRDOBA
# Grado en Administración y Dirección de Empresas (ADE) | Curso 2025/26
#
# Título: Análisis estadístico de la rentabilidad, el riesgo y la asociación entre
#         activos financieros (2005-2025): análisis global y comparación de
#         periodos en torno a la guerra de Ucrania
# Autor:  Jaime Nieto Godino
# Tutora: Dña. Sonia Navajas Torrente
#
# Archivo: 01_descarga_datos.py
# Contenido: Código 1 (Anexo A) - Obtención de precios ajustados de los activos
#            seleccionados (QQQ, SPY, GLD, TLT) y cálculo de rendimientos continuos.
# ==============================================================================

import yfinance as yf
import numpy as np  # Necesario para el logaritmo

ruta_salida = "z:/Proyects/TFG/datos_tfg.csv"

datos = yf.download("QQQ SPY GLD TLT", start="2004-12-31", end="2025-10-21", auto_adjust=False)["Adj Close"][["QQQ", "SPY", "GLD", "TLT"]] # type: ignore

log_returns = np.log(datos / datos.shift(1)) # Formula: ln(Precio / Precio_ayer)
log_returns = log_returns.dropna() # type: ignore # 3. Eliminamos la primera fila (que será NaN porque no tiene día previo)
log_returns.to_csv(ruta_salida) # 4. Guardamos
