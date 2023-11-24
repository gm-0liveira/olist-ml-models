WITH tb_pedido AS (
  SELECT DISTINCT t1.idPedido,
    t2.idVendedor
  FROM pedido AS t1
    LEFT JOIN item_pedido AS t2 ON t1.idPedido = t2.idPedido
  WHERE t1.dtPedido < '2018-01-01'
    AND t1.dtPedido >= julianday('2018-01-01', '-6 months')
    AND idVendedor IS NOT NULL
),
tb_join AS (
  SELECT t1.*,
    t2.vlNota
  FROM tb_pedido AS t1
    LEFT JOIN avaliacao_pedido AS t2 ON t1.idPedido = t2.idPedido
),
tb_summary AS (
  SELECT idVendedor,
    avg(vlNota) AS avgNota,
    min(vlNota) AS minNota,
    max(vlNota) AS maxNota,
    count(vlNota) / count(idPedido) AS pctAvaliacao
  FROM tb_join
  GROUP BY idVendedor
)
SELECT '2018-01-01' AS dtReference,
  *
FROM tb_summary