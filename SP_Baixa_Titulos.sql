CREATE PROCEDURE SP_Baixa_Titulos 
	@dtPagamento DATE,
	@idEmpresa INT,
	@idContaCorrente INT, 
	@nrDocumento VARCHAR(20),
	@dsMovimento VARCHAR(50) 
	AS

BEGIN

	DECLARE @verificaDados INT,
			@verificaMovimentacao INT
		
	--VARIAVEL QUE VERIFICA A COMPATIBILIDADE DE DADOS INSERIDOS
	SELECT @verificaDados=count(*)
		FROM card.tbParcela
		WHERE (dtVencimento = @dtPagamento) 
		and (idContaCorrente=@idContaCorrente) 
		and (idEmpresa=@idEmpresa)
	
	--VARIAVEL QUE  VERIFICA SE A CONTA JÁ FOI MOVIMENTADA
	SELECT @verificaMovimentacao=count(*) 
		FROM card.tbMovimentoBanco 
		WHERE (dtMovimento = @dtPagamento) 
		and (idContaCorrente=@idContaCorrente) 
		and (idEmpresa=@idEmpresa)
		
		IF (@verificaDados= 0)
			BEGIN
				PRINT 'DADOS INVÁLIDOS'
			END
		ELSE
			BEGIN
				IF (@verificaMovimentaca > 0) 
					BEGIN
						PRINT ' JÁ FOI MOVIMENTADA'	
					END
				ELSE
					BEGIN
						DECLARE 
							@vlParcela MONEY, 
							@vlTaxaAdministracao MONEY,
							@vlMovimento MONEY
						DECLARE
							@dtMovimento DATE
						DECLARE
							@idMovimentoBanco INT
						
						--ALTERA dtPagamento NA TABELA DE PARCELA
						UPDATE  card.tbParcela
							SET dtPagamento = dtVencimento
							WHERE (dtVencimento = @dtPagamento) 
							and (idContaCorrente=@idContaCorrente) 
							and (idEmpresa=@idEmpresa); 
				
						--ALTERA idStatusParcela  NA TABELA DE PARCELA
						UPDATE  card.tbParcela
							SET idStatusParcela=2
							WHERE (dtVencimento = @dtPagamento) 
							and (idContaCorrente=@idContaCorrente) 
							and (idEmpresa=@idEmpresa);
				
						--SET @dtMovimento= @dtPagamento
				
						--VARIAVEL vlMovimento SOMATORIO DOS VALORES DE PARCELA
						SELECT @vlMovimento=sum(vlParcela) 
							FROM card.tbParcela 
							WHERE (dtVencimento = @dtPagamento) 
							and (idContaCorrente=@idContaCorrente) 
							and (idEmpresa=@idEmpresa);
				
						--VARIAVEL vlTaxaAdministracao SOMATORIO DO VALOR DA TAXA DE ADMINISTRACAO
						SELECT @vlTaxaAdministracao=sum(vlTaxaAdministracao) 
							FROM card.tbParcela 
							WHERE (dtVencimento = @dtPagamento) 
							and (idContaCorrente=@idContaCorrente) 
							and (idEmpresa=@idEmpresa);
				
						--ALTERA O VALOR PAGO DA TABELA PARCELA
						UPDATE  card.tbParcela
							SET vlPago = @vlMovimento-@vlTaxaAdministracao
							WHERE (dtVencimento = @dtPagamento) 
							and (idContaCorrente=@idContaCorrente) 
							and (idEmpresa=@idEmpresa);

						--O BANCO DE DADOS NÃO GERENCIA idMovimentoBanco	
						SET IDENTITY_INSERT dbAtosCapital.card.tbMovimentoBanco ON;
				
						--VARIAVEL idMovimentoBanco MAIS UM
						SELECT @idMovimentoBanco=max(idMovimentoBanco) + 1
							FROM card.tbMovimentoBanco

						--INSERT NA TABELA MOVIMENTO BANCO
						INSERT INTO card.tbMovimentoBanco(
							idMovimentoBanco,
							idEmpresa,
							idContaCorrente,
							nrDocumento,
							dsMovimento,
							vlMovimento,
							tpOperacao,
							dtMovimento ) 
						VALUES( 
							@idMovimentoBanco,
							@idEmpresa,
							@idContaCorrente,
							@nrDocumento,
							@dsMovimento,
							@vlMovimento,
							'E',
							@dtPagamento )	
						SET IDENTITY_INSERT dbAtosCapital.card.tbMovimentoBanco OFF;			
					END			
		END
END