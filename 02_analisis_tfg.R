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
# Archivo: 02_analisis_tfg.R
# Contenido: Código íntegro de R incluido en el Anexo B de la memoria del TFG
#            (Códigos 2 al 9).
# ==============================================================================

# ==============================================================================
# Código 2. Paquetes, constantes y lectura de datos
# ==============================================================================
library(moments)
library(corrplot)
library(nortest) # Paquete necesario para la prueba de Lilliefors (Código 5)

ACTIVOS <- c("QQQ", "SPY", "GLD", "TLT")
ACTIVO_REF <- "SPY"
TRADING_DAYS <- 252
RF <- 0

PARES   <- list(c("SPY", "QQQ"), c("SPY", "GLD"), c("SPY", "TLT"), c("GLD", "TLT"))

col_linea   <- c(QQQ = "#003396", SPY = "red",     GLD = "gold",    TLT = "green")
col_relleno <- c(QQQ = "#86CEFA", SPY = "#F9BFBF", GLD = "#FFFEB9", TLT = "#D6F6D5")
col_par     <- c("blue", "green", "red", "purple")
col_regimen <- c(`-1` = "blue", `0` = "red", `1` = "green")

VENTANAS <- data.frame(
  cod = c(-1, 0, 1),
  ini = as.Date(c("2021-02-24", "2022-02-24", "2023-02-24")),
  fin = as.Date(c("2022-02-23", "2023-02-23", "2024-02-23"))
)

# Lectura de datos: busca en 'data/datos_tfg.csv', 'datos_tfg.csv' o selector interactivo
ruta_archivo <- if (file.exists("data/datos_tfg.csv")) "data/datos_tfg.csv" else if (file.exists("datos_tfg.csv")) "datos_tfg.csv" else file.choose()
datos <- read.csv(ruta_archivo, header = TRUE, sep = ",", dec = ".")
names(datos)[1] <- "Fecha"
datos$Fecha <- as.Date(datos$Fecha)
rend <- datos[, ACTIVOS]
n <- nrow(rend)

cat("Datos cargados correctamente:", n, "observaciones desde", as.character(min(datos$Fecha)),
    "hasta", as.character(max(datos$Fecha)), "\n\n")

# ==============================================================================
# Código 3. Tabla 2. Estadísticos descriptivos
# ==============================================================================
descriptivos <- function(x) c(
  Media       = mean(x),
  Media_anual = TRADING_DAYS * mean(x),
  Varianza    = var(x),
  Desviacion  = sd(x),
  Q1          = unname(quantile(x, .25)),
  Mediana     = median(x),
  Q3          = unname(quantile(x, .75)),
  RI          = IQR(x),
  Sharpe      = (mean(x) - RF) / sd(x),
  Asimetria   = skewness(x),
  Curtosis    = kurtosis(x) - 3
)

tabla_descriptivos <- round(sapply(rend, descriptivos), 6)
cat("--- TABLA 2: ESTADÍSTICOS DESCRIPTIVOS ---\n")
print(tabla_descriptivos)
cat("\n")

# ==============================================================================
# Código 4. Histogramas y QQ-Plots
# ==============================================================================
# 4.1 Histogramas con curva normal teórica
par(mfrow = c(2, 2))
for (a in ACTIVOS) {
  x <- rend[[a]]
  m <- mean(x)
  s <- sd(x)
  hist(x, breaks = 50, prob = TRUE, col = col_relleno[a], border = "white", ylim = c(0, 60),
       main = paste("Histograma", a, "vs Normal"), xlab = "Rentabilidad diaria", ylab = "Densidad")
  curve(dnorm(x, m, s), col = col_linea[a], lwd = 2, add = TRUE)
}
par(mfrow = c(1, 1))

# 4.2 Gráficos Cuantil-Cuantil (QQ-Plots)
par(mfrow = c(2, 2))
for (a in ACTIVOS) {
  qqnorm(rend[[a]], main = paste("QQ-Plot del", a), pch = 19, col = "black")
  qqline(rend[[a]], col = col_linea[a], lwd = 3)
}
par(mfrow = c(1, 1))

# ==============================================================================
# Código 5. Prueba de Kolmogorov-Smirnov con la corrección de Lilliefors
# ==============================================================================
tabla_norm <- round(t(sapply(rend, function(x) {
  p <- lillie.test(x)
  c(D = unname(p$statistic), p_valor = p$p.value)
})), 8)

cat("--- TABLA 3: PRUEBA DE NORMALIDAD DE LILLIEFORS (KS) ---\n")
print(tabla_norm)
cat("\n")

# ==============================================================================
# Código 6 (rotulado como Código 4 en docx). Figura 3. Diagramas de dispersión
# ==============================================================================
par(mfrow = c(2, 2))
for (k in seq_along(PARES)) {
  ex <- PARES[[k]][1]
  ey <- PARES[[k]][2]
  x <- rend[[ex]]
  y <- rend[[ey]]
  plot(x, y, pch = 20, cex = .5, col = col_par[k], main = paste(ex, "vs", ey),
       xlab = ex, ylab = ey, xlim = c(-.15, .15), ylim = c(-.15, .15))
  abline(h = 0, v = 0, col = "grey80", lty = 2)
  abline(lm(y ~ x), col = col_par[k], lwd = 2)
}
par(mfrow = c(1, 1))

# ==============================================================================
# Código 7. Figura 4. Matrices de correlación
# ==============================================================================
matrices <- list(
  Pearson  = cor(rend, method = "pearson"),
  Spearman = cor(rend, method = "spearman")
)
paleta <- colorRampPalette(c("yellow", "white", "blue"))(200)

par(mfrow = c(1, 2))
for (m in names(matrices)) {
  corrplot(matrices[[m]], method = "color", col = paleta, addCoef.col = "black", number.cex = .9,
           tl.col = "black", tl.srt = 90, mar = c(0, 0, 2, 0),
           title = paste("Matriz de Correlacion de", m))
}
par(mfrow = c(1, 1))

# ==============================================================================
# Código 8. Tabla 4. Momentos sistemáticos de orden superior
# ==============================================================================
comovimiento <- function(i, j) {
  di <- i - mean(i)
  dj <- j - mean(j)
  sum(di^2 * dj^2) / sum(dj^4)
}

coasimetria <- function(i, j) {
  di <- i - mean(i)
  dj <- j - mean(j)
  sum(di * dj^2) / (length(i) * sd(i) * sd(j)^2)
}

cocurtosis <- function(i, j) {
  di <- i - mean(i)
  dj <- j - mean(j)
  sum(di * dj^3) / sum(dj^4)
}

ref <- rend[[ACTIVO_REF]]
tabla_comomentos <- round(t(sapply(setdiff(ACTIVOS, ACTIVO_REF), function(a) {
  c(
    Comovimiento = comovimiento(rend[[a]], ref),
    Coasimetria  = coasimetria(rend[[a]], ref),
    Cocurtosis   = cocurtosis(rend[[a]], ref)
  )
})), 6)

cat("--- TABLA 4: MOMENTOS SISTEMÁTICOS DE ORDEN SUPERIOR (REF: SPY) ---\n")
print(tabla_comomentos)
cat("\n")

# ==============================================================================
# Código 9. Figuras 5 a 8. Precio y volatilidad por régimen
# ==============================================================================
datos$Periodo <- NA_integer_
for (k in 1:3) {
  datos$Periodo[datos$Fecha >= VENTANAS$ini[k] & datos$Fecha <= VENTANAS$fin[k]] <- VENTANAS$cod[k]
}

regimenes <- subset(datos, !is.na(Periodo))
regimenes$Periodo <- factor(regimenes$Periodo, levels = c(-1, 0, 1))

for (a in c("SPY", "QQQ", "GLD", "TLT")) {
  x <- regimenes[[a]]
  base1 <- exp(cumsum(x))
  
  par(mfrow = c(1, 2), oma = c(0, 0, 2.5, 0))
  plot(regimenes$Fecha, base1, type = "n", main = "Evolucion del Precio",
       xlab = "Fecha", ylab = "Precio Acumulado (Base 1)")
  for (p in levels(regimenes$Periodo)) {
    i <- regimenes$Periodo == p
    lines(regimenes$Fecha[i], base1[i], col = col_regimen[p], lwd = 2)
  }
  legend("topleft", c("Preguerra", "Guerra", "Posguerra"), col = col_regimen, lwd = 2, bty = "n", cex = .7)
  
  barplot(abs(x), col = col_regimen[as.character(regimenes$Periodo)], border = NA, space = 0,
          main = "Rentabilidad diaria en valor absoluto",
          xlab = "Tiempo (Dias)", ylab = "Rentabilidad Absoluta")
  mtext(paste("Grafico", a), outer = TRUE, cex = 1.1, font = 2)
}
par(mfrow = c(1, 1))
