-- Pegando todas as vendas no mesmo range de estudo e cruzando com a tabela de 
-- de produto e pedido com intuito de enteder para cada vendedor qual foi seu 
-- portifólio de vendas durante esse mesmo range de estudo
WITH tb_join AS (
  SELECT DISTINCT t2.idVendedor,
    t3.*
  FROM pedido AS t1
    LEFT JOIN item_pedido AS t2 ON t1.idPedido = t2.idPedido
    LEFT JOIN produto AS t3 ON t2.idProduto = t3.idProduto
  WHERE dtPedido < '2018-01-01'
    AND dtPedido >= julianday('2018-01-01', '-6 months')
    AND t2.idVendedor IS NOT NULL
),
-- Buscando as estatisticas de interesse para analise destes pedidos para cada vendedor
tb_summary AS (
  SELECT idVendedor,
    -- Pega a média de fotos que o produto buscado tem
    avg(coalesce(nrFotos, 0)) AS avgFotos,
    -- Pega a média do tamanho dos produtos
    avg(vlAlturaCm * vlComprimentoCm * vlLarguraCm) AS avgVolumeProduto,
    -- Pega o min e o max de tamanho dos produtos 
    min(vlAlturaCm * vlComprimentoCm * vlLarguraCm) AS minVolumeProduto,
    max(vlAlturaCm * vlComprimentoCm * vlLarguraCm) AS maxVolumeProduto,
    -- Contando quantos produtos do vendedor pertencem as 15 top categorias de vendas
    COUNT(
      CASE
        WHEN descCategoria = 'cama_mesa_banho' THEN idProduto
      END
    ) / COUNT(DISTINCT idProduto) AS pct_categoria_cama_mesa_banho,
    COUNT(
      CASE
        WHEN descCategoria = 'beleza_saude' THEN idProduto
      END
    ) / COUNT(DISTINCT idProduto) AS pct_categoria_beleza_saude,
    COUNT(
      CASE
        WHEN descCategoria = 'esporte_lazer' THEN idProduto
      END
    ) / COUNT(DISTINCT idProduto) AS pct_categoria_esporte_lazer,
    COUNT(
      CASE
        WHEN descCategoria = 'informatica_acessorios' THEN idProduto
      END
    ) / COUNT(DISTINCT idProduto) AS pct_categoria_informatica_acessorios,
    COUNT(
      CASE
        WHEN descCategoria = 'moveis_decoracao' THEN idProduto
      END
    ) / COUNT(DISTINCT idProduto) AS pct_categoria_moveis_decoracao,
    COUNT(
      CASE
        WHEN descCategoria = 'utilidades_domesticas' THEN idProduto
      END
    ) / COUNT(DISTINCT idProduto) AS pct_categoria_utilidades_domesticas,
    COUNT(
      CASE
        WHEN descCategoria = 'relogios_presentes' THEN idProduto
      END
    ) / COUNT(DISTINCT idProduto) AS pct_categoria_relogios_presentes,
    COUNT(
      CASE
        WHEN descCategoria = 'telefonia' THEN idProduto
      END
    ) / COUNT(DISTINCT idProduto) AS pct_categoria_telefonia,
    COUNT(
      CASE
        WHEN descCategoria = 'automotivo' THEN idProduto
      END
    ) / COUNT(DISTINCT idProduto) AS pct_categoria_automotivo,
    COUNT(
      CASE
        WHEN descCategoria = 'brinquedos' THEN idProduto
      END
    ) / COUNT(DISTINCT idProduto) AS pct_categoria_brinquedos,
    COUNT(
      CASE
        WHEN descCategoria = 'cool_stuff' THEN idProduto
      END
    ) / COUNT(DISTINCT idProduto) AS pct_categoria_cool_stuff,
    COUNT(
      CASE
        WHEN descCategoria = 'ferramentas_jardim' THEN idProduto
      END
    ) / COUNT(DISTINCT idProduto) AS pct_categoria_ferramentas_jardim,
    COUNT(
      CASE
        WHEN descCategoria = 'perfumaria' THEN idProduto
      END
    ) / COUNT(DISTINCT idProduto) AS pct_categoria_perfumaria,
    COUNT(
      CASE
        WHEN descCategoria = 'bebes' THEN idProduto
      END
    ) / COUNT(DISTINCT idProduto) AS pct_categoria_bebes,
    COUNT(
      CASE
        WHEN descCategoria = 'eletronicos' THEN idProduto
      END
    ) / COUNT(DISTINCT idProduto) AS pct_categoria_eletronicos
  FROM tb_join
  GROUP BY idVendedor
)
SELECT '2018-01-01' AS dtReference,
  *
FROM tb_summary