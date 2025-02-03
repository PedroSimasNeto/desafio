-- Consulta para vendedores que vendem mais que a média de PROD_1 na sua loja
WITH MediaVendasLoja AS (
    SELECT 
        V.COD_VENDEDOR,
        V.COD_LOJA,
        AVG(V.QUANTIDADE) AS MediaVendasPROD1
    FROM 
        VENDAS V
    JOIN 
        VENDEDOR VD ON V.COD_VENDEDOR = VD.COD_VENDEDOR
    WHERE 
        V.COD_PRODUTO = 'PROD_1' AND V.DATA BETWEEN DATA_INICIO AND DATA_FIM
    GROUP BY 
        V.COD_LOJA, V.COD_VENDEDOR
),
-- Consulta para lojas com mais de 1000 vendas de PROD_2 no período
LojasMaisDe1000Vendas AS (
    SELECT 
        COD_LOJA
    FROM 
        VENDAS
    WHERE 
        COD_PRODUTO = 'PROD_2' AND DATA BETWEEN DATA_INICIO AND DATA_FIM
    GROUP BY 
        COD_LOJA
    HAVING 
        SUM(QUANTIDADE) > 1000
),
-- Consulta para média de vendas de PROD_2 nas lojas com mais de 1000 vendas
MediaVendasLojasMaisDe1000 AS (
    SELECT 
        V.COD_VENDEDOR,
        AVG(V.QUANTIDADE) AS MediaVendasPROD2
    FROM 
        VENDAS V
    JOIN 
        VENDEDOR VD ON V.COD_VENDEDOR = VD.COD_VENDEDOR
    WHERE 
        V.COD_PRODUTO = 'PROD_2' AND V.DATA BETWEEN DATA_INICIO AND DATA_FIM
        AND VD.COD_LOJA IN (SELECT COD_LOJA FROM LojasMaisDe1000Vendas)
    GROUP BY 
        V.COD_VENDEDOR
)
-- Consulta final para retornar os vendedores que atendem aos requisitos
SELECT 
    V.COD_VENDEDOR
FROM 
    VENDAS V
JOIN 
    MediaVendasLoja MVL ON V.COD_VENDEDOR = MVL.COD_VENDEDOR
JOIN 
    MediaVendasLojasMaisDe1000 MVLM ON V.COD_VENDEDOR = MVLM.COD_VENDEDOR
WHERE 
    V.COD_PRODUTO = 'PROD_1' AND V.QUANTIDADE > MVL.MediaVendasPROD1
    AND V.COD_PRODUTO = 'PROD_2' AND V.QUANTIDADE > MVLM.MediaVendasPROD2
GROUP BY 
    V.COD_VENDEDOR;