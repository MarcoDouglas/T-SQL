CREATE PROCEDURE SP_Corrige_Parcelas
	@idPagamentoVenda int,
	@qtParcelas int,
	@prTaxaAdministracao numeric(9,2) 
	AS

BEGIN
	DECLARE @idStatusParcelaAll INT
	
	--VARIAVEL idStatusParcelaAll CONTA A QUANTIDADE DE ID COM STATUS LIQUIDADA	
	SELECT @idStatusParcelaAll=count(idStatusParcela) 
	   FROM  card.tbParcela 
	   WHERE idPagamentoVenda=@idPagamentoVenda
	   and   idStatusParcela = 2
	
	--CONDICIONAL CASO O VALOR SEJA DIFERENTE DE 0 INDICA QUE HÁ PARCELA LIQUIDADA
	IF @idStatusParcelaAll != 0
		BEGIN
			PRINT 'EXISTE PARCELA LIQUIDADA'
		END
	ELSE
		BEGIN 
			--DELETA TODAS AS PARCELA EXCETO A PRIMEIRA PARCELA
			DELETE FROM card.tbParcela
				 WHERE (idPagamentoVenda=@idPagamentoVenda)
				 and  (nrParcela!=1)
			
			DECLARE @dtEmissao DATE, 
					@dtVencimentoFuturo DATE,
					@dtVencimento  DATE
			DECLARE
					@vlPagamento MONEY,
					@vlParcela MONEY, 
					@ajusteParcela MONEY,
					@vlTaxaAdministracao MONEY
			DECLARE
					@contador INT, 
					@nrParcela INT, 
					@idParcelas INT, 
					@idEmpresa INT,  
					@idContaCorrente INT,
					@idStatusParcela INT
					
		---ALTERA  QUANTIDADE DE PARCELAS NA TB PAGAMENTO VENDA
			UPDATE  card.tbPagamentoVenda 
				SET qtParcelas=@qtParcelas 
				WHERE idPagamentoVenda=@idPagamentoVenda; 
		
		--VARIAVEL vlPagamento  DA TABELA PAGAMENTO VENDA DE ACORDO COM O ID QUE FOI PASSADO PELA SP 
			SELECT  @vlPagamento = vlPagamento 
				FROM  card.tbPagamentoVenda 
				WHERE idPagamentoVenda=@idPagamentoVenda;

		--VARIAVEL vlParcela QUE É IGUAL O VALOR DE PAGAMENTO DIVINDINDO PELO PARAMETRO PASSADO PELA SP
			SELECT  @vlParcela = @vlPagamento / @qtParcelas
		
		---ALTERA O  VALOR DA PARCELA 1
			UPDATE  card.tbParcela 
				SET vlParcela=@vlParcela
				WHERE idPagamentoVenda=@idPagamentoVenda;

		---ALTERA O VALOR DE TAXA DE ADMINISTRAÇÃO NA TB PARCELA
			UPDATE  card.tbParcela 
				SET vlTaxaAdministracao=@prTaxaAdministracao/100*@vlPagamento/@qtParcelas
				WHERE idPagamentoVenda=@idPagamentoVenda;

		--VARIAVEL dtEmissao DA TABELA PARCELA DE ACORDO COM O ID QUE FOI PASSADO PELA PROCEDURE 
			SELECT  @dtEmissao = dtEmissao 
				FROM  card.tbParcela 
				WHERE idPagamentoVenda= @idPagamentoVenda;

		--VARIAVEL PARA PASSA COMO PARAMETROS NO INSERT DO LOOP 
			SELECT  @idStatusParcela = idStatusParcela 
				FROM  card.tbParcela 
				WHERE idPagamentoVenda= @idPagamentoVenda;

		--VARIAVEL PARA PASSA COMO PARAMETROS NO INSERT DO LOPP 
			SELECT  @idEmpresa =  idEmpresa 
				FROM  card.tbParcela 
				WHERE idPagamentoVenda= @idPagamentoVenda;

		--VARIAVEL PARA PASSA COMO PARAMETROS NO INSERT DO LOPP 
			SELECT  @idContaCorrente = idContaCorrente 
				FROM  card.tbParcela 
				WHERE idPagamentoVenda= @idPagamentoVenda;

		--VARIAVEL PARA PASSA COMO PARAMETROS NO INSERT DO LOOP 
			SELECT  @vlTaxaAdministracao = vlTaxaAdministracao 
				FROM  card.tbParcela 
				WHERE idPagamentoVenda= @idPagamentoVenda;
		
		--VARIAVEL PARA PASSA COMO PARAMETROS NO INSERT DO LOOP 
			SELECT  @dtVencimento = dtVencimento
				FROM  card.tbParcela 
				WHERE idPagamentoVenda= @idPagamentoVenda;

		--CONTADOR PARA O LOOP DE INSERT
			SELECT  @contador = count(idPagamentoVenda)
				FROM  card.tbParcela 
				WHERE idPagamentoVenda= @idPagamentoVenda;

		--LOOP COM INSERTS
			WHILE   @contador < @qtParcelas
				BEGIN
					
					--ALTERANDO A DATA DE VENCIMENTO
					SET @dtVencimentoFuturo= dateadd(d,31*@contador,@dtVencimento)
					
					--INSERTS
					INSERT INTO card.tbParcela 
						VALUES 
							(@idPagamentoVenda,
							 @contador+1,
							 @idEmpresa,
							 @dtEmissao,
							 @dtVencimentoFuturo,
							 @vlParcela,
							 @vlTaxaAdministracao,
							 @idContaCorrente,
							 NULL, 
							 NULL,
							 @idStatusParcela,
							 NULL);
						SET @contador=@contador+1
				END
		END
END
