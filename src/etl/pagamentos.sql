-- Resumo da Query: Pegando as estatisticas de cada vendendo que fizeram pedidos
-- entre os dia 01-07-2017 até 01-01-2018
WITH tb_pedidos AS (
  SELECT DISTINCT t1.idPedido,
    t2.idVendedor
  FROM pedido AS t1
    LEFT JOIN item_pedido AS t2 ON t1.idPedido = t2.idPedido
  WHERE t1.dtPedido < '2018-01-01'
    AND t1.dtPedido >= julianday('2018-01-01', '-6 month')
    AND idVendedor IS NOT NULL
),
tb_join AS (
  SELECT t1.idVendedor,
    t2.*
  FROM tb_pedidos AS t1
    LEFT JOIN pagamento_pedido AS t2 ON t1.idPedido = t2.idPedido
),
tb_group AS (
  SELECT idVendedor,
    descTipoPagamento,
    COUNT(distinct idPedido) as qtdePedidoMeioPagamento,
    SUM(vlPagamento) as vlPedidoMeioPagamento
  FROM tb_join
  GROUP BY idVendedor,
    descTipoPagamento
  ORDER BY idVendedor,
    descTipoPagamento
),
tb_summary AS (
  SELECT idVendedor,
    SUM(
      CASE
        WHEN descTipoPagamento = 'boleto' THEN qtdePedidoMeioPagamento
        ELSE 0
      END
    ) AS qtde_boleto_pedido,
    SUM(
      CASE
        WHEN descTipoPagamento = 'credit_card' THEN qtdePedidoMeioPagamento
        ELSE 0
      END
    ) AS qtde_credit_card_pedido,
    SUM(
      CASE
        WHEN descTipoPagamento = 'voucher' THEN qtdePedidoMeioPagamento
        ELSE 0
      END
    ) AS qtde_voucher_pedido,
    SUM(
      CASE
        WHEN descTipoPagamento = 'debit_card' THEN qtdePedidoMeioPagamento
        ELSE 0
      END
    ) AS qtde_debit_card_pedido,
    SUM(
      CASE
        WHEN descTipoPagamento = 'boleto' THEN vlPedidoMeioPagamento
        ELSE 0
      END
    ) AS valor_boleto_pedido,
    SUM(
      CASE
        WHEN descTipoPagamento = 'credit_card' THEN vlPedidoMeioPagamento
        ELSE 0
      END
    ) AS valor_credit_card_pedido,
    SUM(
      CASE
        WHEN descTipoPagamento = 'voucher' THEN vlPedidoMeioPagamento
        ELSE 0
      END
    ) AS valor_voucher_pedido,
    SUM(
      CASE
        WHEN descTipoPagamento = 'debit_card' THEN vlPedidoMeioPagamento
        ELSE 0
      END
    ) AS valor_debit_card_pedido,
    SUM(
      CASE
        WHEN descTipoPagamento = 'boleto' THEN qtdePedidoMeioPagamento
        ELSE 0
      END
    ) / SUM(qtdePedidoMeioPagamento) AS pct_qtd_boleto_pedido,
    SUM(
      CASE
        WHEN descTipoPagamento = 'credit_card' THEN qtdePedidoMeioPagamento
        ELSE 0
      END
    ) / SUM(qtdePedidoMeioPagamento) AS pct_qtd_credit_card_pedido,
    SUM(
      CASE
        WHEN descTipoPagamento = 'voucher' THEN qtdePedidoMeioPagamento
        ELSE 0
      END
    ) / SUM(qtdePedidoMeioPagamento) AS pct_qtd_voucher_pedido,
    SUM(
      CASE
        WHEN descTipoPagamento = 'debit_card' THEN qtdePedidoMeioPagamento
        ELSE 0
      END
    ) / SUM(qtdePedidoMeioPagamento) AS pct_qtd_debit_card_pedido,
    SUM(
      CASE
        WHEN descTipoPagamento = 'boleto' THEN vlPedidoMeioPagamento
        ELSE 0
      END
    ) / SUM(vlPedidoMeioPagamento) AS pct_valor_boleto_pedido,
    SUM(
      CASE
        WHEN descTipoPagamento = 'credit_card' THEN vlPedidoMeioPagamento
        ELSE 0
      END
    ) / SUM(vlPedidoMeioPagamento) AS pct_valor_credit_card_pedido,
    SUM(
      CASE
        WHEN descTipoPagamento = 'voucher' THEN vlPedidoMeioPagamento
        ELSE 0
      END
    ) / SUM(vlPedidoMeioPagamento) AS pct_valor_voucher_pedido,
    SUM(
      CASE
        WHEN descTipoPagamento = 'debit_card' THEN vlPedidoMeioPagamento
        ELSE 0
      END
    ) / SUM(vlPedidoMeioPagamento) AS pct_valor_debit_card_pedido
  FROM tb_group
  GROUP BY idVendedor
),
tb_cartao AS (
  SELECT idVendedor,
    AVG(nrParcelas) AS avgQtdParcelas,
    MAX(nrParcelas) AS maxQtdParcelas,
    MIN(nrParcelas) AS minQtdParcelas
  FROM tb_join
  WHERE descTipoPagamento = 'credit_card'
  GROUP BY idVendedor
)
SELECT '2018-01-01' AS dtReference,
  t1.*,
  t2.avgQtdParcelas,
  t2.maxQtdParcelas,
  t2.minQtdParcelas
FROM tb_summary AS t1
  LEFT JOIN tb_cartao as t2 ON t1.idVendedor = t2.idVendedor