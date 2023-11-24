WITH tb_pedido AS (
  SELECT t1.idPedido,
    t2.idVendedor,
    t1.descSituacao,
    t1.dtPedido,
    t1.dtAprovado,
    t1.dtEntregue,
    t1.dtEstimativaEntrega,
    sum(vlFrete) as totalFrente
  FROM pedido AS t1
    LEFT JOIN item_pedido as t2 ON t1.idPedido = t2.idPedido
  WHERE dtPedido < '2018-01-01'
    AND dtPedido >= JULIANDAY('2018-01-01', '-6 months')
  GROUP BY t1.idPedido,
    t2.idVendedor,
    t1.descSituacao,
    t1.dtPedido,
    t1.dtAprovado,
    t1.dtEntregue,
    t1.dtEstimativaEntrega
)
SELECT idVendedor,
  -- Faz o percentual de entregas com atraso para cada vendedor
  COUNT(
    DISTINCT CASE
      WHEN date(coalesce(dtEntregue, '2018-01-01')) > date(dtEstimativaEntrega) THEN idPedido
    END
  ) / COUNT(
    DISTINCT CASE
      WHEN descSituacao = 'delivered' THEN idPedido
    END
  ) AS pctPedidoAtraso,
  -- Conta de formas distintas quantos pedidos cancelados cada vendedor teve
  count(
    distinct case
      when descSituacao = 'canceled' then idPedido
    end
  ) / count(distinct idPedido) AS pctPedidoCancelado,
  -- Calculando o valor médio do frete para cada vendedor
  avg(totalFrente) as avgFrete,
  -- Calculando o valor máximo do frete para cada vendedor
  max(totalFrente) as maxFrete,
  -- Calculando o valor mínimo do frete para cada vendedor
  min(totalFrente) as minFrete,
  -- Calculando qual a média de dias para entrega de um pedido para cada vendedor 
  --de acordo de quando o pedido foi aprovado e quando foi entregue
  avg(
    JULIANDAY(coalesce(dtEntregue, '2018-01-01'), dtAprovado)
  ) AS qtdDiasAprovadoEntrega,
  -- Calculando qual a média de dias para entrega de um pedido para cada vendedor 
  --de acordo de quando o pedido foi feito e quando foi entregue
  avg(
    JULIANDAY(coalesce(dtEntregue, '2018-01-01'), dtPedido)
  ) AS qtdDiasPedidoEntrega,
  -- Calculando a diferença entre o tempo de estimativa da entrega e quando o pedido foi entregue 
  avg(
    JULIANDAY(
      dtEstimativaEntrega,
      coalesce(dtEntregue, '2018-01-01')
    )
  ) AS qtdeDiasEntregaPromessa
FROM tb_pedido
GROUP BY 1