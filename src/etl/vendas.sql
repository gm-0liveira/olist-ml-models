WITH tb_pedido_item AS (
  SELECT t2.*,
    t1.dtPedido
  FROM pedido AS t1
    LEFT JOIN item_pedido AS t2 ON t1.idPedido = t2.idPedido
  WHERE t1.dtPedido < '2018-01-01'
    AND t1.dtPedido >= julianday('2018-01-01', '-6 MONTHS')
    AND t2.idVendedor IS NOT NULL
),
tb_summary AS (
  SELECT idVendedor,
    -- Contando a quantidade de Pedidos de cada vendedor
    COUNT(DISTINCT idPedido) AS qtdPedidos,
    -- Contando a quantidade de dias de vendas por vendedor
    COUNT(DISTINCT date(dtPedido)) AS qtdDias,
    -- Contando a quantidade de itens vendidos por vendedor
    COUNT(idProduto) AS qtItens,
    -- Contando os dias que o um vendedor ficou sem vender (recência)
    julianday('2018-01-01', max(dtPedido)) AS qtdRecencia,
    -- Contabilizando o Ticket Médio
    SUM(vlPreco) / COUNT(DISTINCT idPedido) AS avgTicket,
    -- Calculando o valor médio dos produtos
    avg(vlPreco) AS avgValorProduto,
    -- Calculando o maior valor dos produto
    max(vlPreco) AS maxValorProduto,
    -- Calculando o menor valor dos produtos
    min(vlPreco) AS minValorProduto,
    -- Calcula a média de itens por produtos
    COUNT(idProduto) / COUNT(DISTINCT idPedido) AS avgProdutoPed
  FROM tb_pedido_item
  GROUP BY idVendedor
),
tb_pedido_summary AS (
  SELECT idVendedor, 
         idPedido, 
         sum(vlPreco) AS vlPreco
  FROM tb_pedido_item 
  GROUP BY idVendedor, idPedido 
),
-- Calcula o maior e menor valor de venda para cada Vendedor
tb_min_max AS (  
  SELECT idVendedor,
        min(vlPreco) AS minVlPedido,
        max(vlPreco) AS maxVlPedido
  FROM tb_pedido_summary
  GROUP BY idVendedor 
),
-- Calculando o LTV (Life Time Value) e a quantidade de dias desde a ultima venda
tb_life AS (
  SELECT t2.idVendedor,
       sum(vlPreco) AS LTV,
       max(julianday('2018-01-01', dtPedido)) AS qtdeDiasBase
  FROM pedido AS t1
    LEFT JOIN item_pedido AS t2 ON t1.idPedido = t2.idPedido
  WHERE t1.dtPedido < '2018-01-01'
    AND t2.idVendedor IS NOT NULL
  GROUP BY t2.idVendedor
),
-- Buscando para cada vendedor a data de cada pedido feito
tb_dtPedido AS (
  SELECT DISTINCT idVendedor,
                DATE(dtPedido) AS dtPedido
  FROM tb_pedido_item
  ORDER BY 1,2
),
-- Adiciona uma coluna com uma copia das datas de vendas de cada vendedor deslocada para baixo
tb_lag AS (
  SELECT *,
         LAG(dtPedido) OVER (PARTITION BY idVendedor ORDER BY dtPedido) AS lag1
  FROM tb_dtPedido
),
-- Calculando a quantidade de dias médio entre vendas para cada vendedor
tb_intervalo AS (
  SELECT idVendedor,
       avg(julianday(dtPedido, lag1)) AS avgIntervaloVendas
  FROM tb_lag
  GROUP BY idVendedor
)

SELECT 
       '2018-01-01' AS dtReference,
       t1.*,
       t2.minVlPedido,
       t2.maxVlPedido,
       t3.LTV,
       t3.qtdeDiasBase,
       t4.avgIntervaloVendas

FROM tb_summary AS t1

LEFT JOIN tb_min_max AS t2
ON t1.idVendedor = t2.idVendedor

LEFT JOIN tb_life AS t3
ON t1.idVendedor = t3.idVendedor

LEFT JOIN tb_intervalo AS t4
ON t1.idVendedor = t4.idVendedor