#install.packages('RPostgreSQL', dependencies = T) # Caso necessário
#install.packages('plotly', dependencies = T) # Caso necessário

library(RPostgreSQL)
library(ggplot2)
library(plotly)

## Carrega o driver PostgreSQL
drv <- dbDriver("PostgreSQL")

## Abre uma conexao
BD <- dbConnect(drv, host="localhost",
port="5432", dbname="Trabalho",
user="postgres", password="senha")

# Lista as Tabelas do BD
dbListTables(BD)

# Submete e executa uma consultas SQL

dbGetQuery(BD, "SELECT COUNT(*) FROM INSTITUTO")

# Podemos notar que em nosso BD tem 29 Institutos

dbGetQuery(BD, "SELECT COUNT(*) FROM USUARIO")

# Podemos notar que em nosso BD tem 32 usuários

dbGetQuery(BD, "SELECT Titulo as TITULO_DA_PALESTRA, COUNT(*) AS NUMERO_DE_PESSOAS_NA_PALESTRA FROM ASSISTE A LEFT JOIN 
                PALESTRA_FISICA PF ON A.Id_Pale_Fisi = PF.Id_Pale_Fisi 
                GROUP BY PF.Id_Pale_Fisi") # verifica qual palestra é mais assitida

# Logo a Palestra mais assistida são é "Estatística aplicada ao Machine Leraning"

dbGetQuery(BD, "SELECT AVG((extract(year from NOW())) - (SELECT extract(year from Data_Nasc))) 
                FROM USUARIO") # Verifica a média de idade dos usuários

# Temos que a média de idade dos usuários é de 31.9 Anos

#Armazena os dados de uma tabela do BD em uma variável
usu_idade <- dbGetQuery(BD, "SELECT (extract(year from NOW())) - (SELECT extract(year from Data_Nasc)) AS Idade 
                        FROM USUARIO") # Data Frame da idade dos usuários

# BoxPlot da Idade dos Usuários
ggplot(usu_idade, aes( y=idade)) + 
       geom_boxplot(outlier.colour="red", outlier.shape=8,outlier.size=4) + 
       scale_x_discrete(name = "Idade") +
       ggtitle("Boxplot Idades dos Usuários")

dbGetQuery(BD, "SELECT MAX((extract(year from NOW())) - (SELECT extract(year from Data_Nasc))) 
                        FROM USUARIO") # Usuário mais velho

dbGetQuery(BD, "SELECT MIN((extract(year from NOW())) - (SELECT extract(year from Data_Nasc))) 
                        FROM USUARIO") # Usuário mais novo

quantile(usu_idade$idade) # Quantis das idades

#Como podemos ver o usuário mais velho tem 54 Anos o mais novo tem 18 Anos 
#e a mediana das idades é 29.5 anos, podemos observar também que 50% dos usários tem  24 e 37 Anos

# Histograma das Idades
hist(usu_idade$idade, probability = T, xlab = 'Idades', ylab = 'Densidade de Frequências', 
     main = 'Histograma das Idades', col = 'Darkgoldenrod3', xlim = c(15,55))

dbGetQuery(BD, "SELECT AVG(Duracao) AS MEDIA_DE_DURACAO_PALESTRA FROM PALESTRA_FISICA")
# Duaração média das palestras é de 01 hora e 14 minutos

# Armazena os dados de uma tabela do BD em uma variável
table <- dbGetQuery(BD, "SELECT TIPO_USU, COUNT(*) AS CONTA_USUARIO FROM USUARIO 
                        GROUP BY TIPO_USU") # Cria uma tabela com os tipos de usuários e a contagem deles

# Gráfico de barras com a contagem de tipos de usuários
plot_ly(x = table$tipo_usu, y = table$conta_usuario,
  type = "bar", color = I('Orange')) %>%
  layout(title = "Contagem de usuários por grupo",
       xaxis = list(title = "Tipo de Usuário"),
       yaxis = list(title = "Contagem"))

# Assim como esperado temos que a maioria dos usuários é Aluno USP

#Fecha a Conexão com o BD
dbDisconnect(BD)

# Libera os recursos usados pelo driver
dbUnloadDriver(drv)

############## FIM #####################################