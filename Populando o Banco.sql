--Populando o banco de dados para teste

INSERT INTO tb.usuario( nomeuser, emailuser)
	VALUES 
	( 'Davi', 'davi@gmail.com'),
	( 'Mateus', 'mateus@gmail.com'),
	( 'Pedro', 'pedro@gmail.com'),
	( 'Duda', 'duda@gmail.com');
	
SELECT criar_casa('Rep dos 3', 'Casa ERROR404', '1');
SELECT add_user_casa('1', '2', 'TRUE'); --ADD mateus a casa 1
SELECT add_user_casa('1', '3', 'FALSE'); --ADD pedro a casa 1

SELECT criar_casa('Abrigo', 'Cabana quentinha', '4');

	
INSERT INTO tb.tarefa(prioriTarefa, tituloTarefa, descTarefa, tipoTarefa, statusTarefa, dataCriTarefa, idCasaTarefa)
	VALUES
	('ALTA', 'Projeto Android', 'Projeto Mobile', 'Faculdade', 'PENDENTE', '2022-12-12 10:00:00', '1'),
	('ALTA', 'Projeto Amilton', 'Projeto Aquario', 'Faculdade', 'PENDENTE', '2022-12-16', '1'),
	('NORMAL', 'Lavar Louça', 'Prato Sujo', 'Casa', 'PENDENTE', NULL, '1'),
	('NORMAL', 'Lavar Banheiro', 'Banheiro ta sujo', 'Casa', 'PENDENTE', '2022-12-10', '1'),
	('NORMAL', 'Estudar', 'Estudar ENEM', 'Faculdade', 'CONCLUIDO', '2022-12-12', '1');
	
INSERT INTO tb.userTarefa(idTarefaCon, userTarefa, concluirTarefa, apagarTarefa)
	VALUES
	('1','1','NAO','NAO'),
	('1','2','NAO','NAO'),
	('1','3','NAO','NAO'),
	('2','1','NAO','NAO'),
	('2','2','NAO','NAO'),
	('2','3','NAO','NAO'),
	('3','1','NAO','NAO'),
	('4','1','NAO','NAO'),
	('5','4','NAO','NAO');
	


