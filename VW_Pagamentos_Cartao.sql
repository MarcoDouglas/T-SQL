CREATE VIEW VW_Pagamentos_Cartao 
AS

SELECT 
    e.nrCNPJ AS CNPJ,
	pv.nrNSU AS NSU, 
	pv.dtEmissao AS Data_do_Pagamento,
	b.idBandeira AS Código_da_Bandeira,
	b.dsBandeira AS Descrição_da_Bandeira,
	pv.vlPagamento AS Valor_do_Pagamento,
	pv.qtParcelas AS Quantidade_de_parcelas,
	pv.idPagamentoVenda AS Código_Pagamento 

FROM        card.tbPagamentoVenda pv
inner join  card.tbFormaPagamento fp on pv.idFormaPagamento = fp.idFormaPagamento
inner join  card.tbEmpresa e on  pv.idEmpresa = e.idEmpresa
inner join  card.tbBandeira b on b.idBandeira = pv.idBandeira

WHERE pv.idFormaPagamento in (3,4)

SELECT * FROM VW_Pagamentos_Cartao;