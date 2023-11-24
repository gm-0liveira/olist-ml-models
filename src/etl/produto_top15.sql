-- Pega as top 15 categorias de produtos utilizando o histórico completo de vendas
SELECT descCategoria
FROM item_pedido AS t2
  LEFT JOIN produto AS t3 ON t2.idProduto = t3.idProduto
WHERE t2.idVendedor IS NOT NULL
GROUP BY 1
ORDER BY COUNT(DISTINCT idPedido) DESC
LIMIT 15