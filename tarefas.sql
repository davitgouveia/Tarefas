CREATE SCHEMA tb;
CREATE SCHEMA vw;

CREATE TABLE tb.usuario (
	idUser SERIAL PRIMARY KEY,
	nomeUser VARCHAR(100),
	emailUser VARCHAR(100) UNIQUE
);

CREATE TABLE tb.tarefa (
	idTarefa SERIAL PRIMARY KEY,
	prioriTarefa VARCHAR (100),
	tituloTarefa VARCHAR (100),
	descTarefa VARCHAR (100),
	tipoTarefa VARCHAR (100),
	statusTarefa VARCHAR (30),
	dataTarefa TIMESTAMP,
	idCasaTarefa INT --Ver com o mateus se deve ser NULL
);

CREATE TABLE tb.casa (
	idCasa SERIAL PRIMARY KEY,
	nomeCasa VARCHAR(100),
	descCasa VARCHAR(100)
	
);

CREATE TABLE tb.userCasa (
	idCasaCon INT,
	userCasa INT,
	adminCasa BOOLEAN DEFAULT('FALSE'),
	statusUsuarioConCasa BOOLEAN DEFAULT('TRUE')
);

CREATE TABLE tb.conviteCasa (
	idCasaConvite INT,
	userConvite INT,
	emailConvidado VARCHAR(100),
	confirmaConvite VARCHAR (3) DEFAULT ('ABR')
);

CREATE TABLE tb.userTarefa (
	idTarefaCon INT,
	userTarefa INT,
	concluirTarefa BOOLEAN DEFAULT('NO'),
	apagarTarefa BOOLEAN DEFAULT('NO')
);


----------------------------------FUNÇÕES DE CASA------------------------------------

--Funcão de criar casa
CREATE OR REPLACE FUNCTION tb.criar_casa(p_nomeCasa VARCHAR(100), p_descCasa VARCHAR(100), p_userID INT) RETURNS void AS $$
DECLARE p_idCasa INT;
BEGIN
	INSERT INTO tb.casa (nomeCasa, descCasa)
		VALUES (p_nomeCasa, p_descCasa)
		RETURNING idCasa INTO p_idCasa;
	PERFORM tb.add_user_casa(p_idCasa, p_userID, 'TRUE');
END; 
$$ LANGUAGE plpgsql;

--Função de adicionar usuario a casa
CREATE OR REPLACE FUNCTION tb.add_user_casa(p_idCasaCon INT, p_userCasa INT, p_adminCasa BOOLEAN ) RETURNS void AS $$
BEGIN
	INSERT INTO tb.userCasa (idCasaCon, userCasa, adminCasa)
		VALUES (p_idCasaCon, p_userCasa, p_adminCasa);
END;
$$ LANGUAGE plpgsql;

--Função de criar convite
CREATE FUNCTION convidar_user() RETURNS void AS $$
BEGIN
	INSERT INTO tb.conviteCasa (idCasaConvite, userConvite, emailConvidado)
		VALUES ('', '', '');
END;
$$ LANGUAGE plpgsql;

----------------------------------FIM FUNÇÕES DE CASA--------------------------------
--=================================================================================--
----------------------------------FUNÇÕES DE TAREFA----------------------------------

--Funcao de criar tarefa
CREATE OR REPLACE FUNCTION tb.criarTarefa(p_prioriTarefa VARCHAR(100), p_tituloTarefa VARCHAR(100), p_descTarefa VARCHAR(100), p_tipoTarefa VARCHAR(100), p_statusTarefa VARCHAR(30), p_dataTarefa TIMESTAMP, p_idCasaTarefa INT, p_idUserTarefa INT) RETURNS void AS $$
DECLARE p_idTarefa INT;
		p_concluirTarefa BOOLEAN = 'NO';
		p_apagarTarefa BOOLEAN = 'NO';
BEGIN
	INSERT INTO tb.tarefa(prioritarefa, titulotarefa, desctarefa, tipotarefa, statustarefa, datatarefa, idcasatarefa)
	VALUES (p_prioriTarefa, p_tituloTarefa, p_descTarefa, p_tipoTarefa, p_statusTarefa, p_dataTarefa, p_idCasaTarefa)
	RETURNING idTarefa INTO p_idTarefa;
	PERFORM tb.add_user_tarefa(p_idTarefa, p_idUserTarefa, p_concluirTarefa, p_apagarTarefa);
END;
$$ LANGUAGE plpgsql;
--Funcão adicionar usuário a tarefa
CREATE OR REPLACE FUNCTION tb.add_user_tarefa(p_idTarefaCon INT, p_idUserTarefa INT, p_concluirTarefa BOOLEAN, p_apagarTarefa BOOLEAN) RETURNS void AS $$
BEGIN
	INSERT INTO tb.userTarefa(idtarefacon, usertarefa, concluirtarefa, apagartarefa)
	VALUES (p_idTarefaCon, p_idUserTarefa, p_concluirTarefa, p_apagarTarefa);
END;
$$ LANGUAGE plpgsql;

--											!!!!LIMITAR CONEXÕES DUPLICADAS!!!!
--

--Função de conclusao da tarefa
--Workflow, caso a tarefa seja prioridade alta, o comando abaixo so rodara se todos concordarem.
CREATE OR REPLACE FUNCTION tb.check_conclusao_prioridade(p_idTarefa INT) RETURNS void AS $$
BEGIN
	IF EXISTS (SELECT prioriTarefa FROM tb.tarefa WHERE 'ALTA' IN (prioriTarefa) AND idTarefa = p_idTarefa) THEN
		PERFORM tb.check_conclusao(p_idTarefa);
	ELSE
		UPDATE tb.userTarefa SET concluirTarefa = 'YES' WHERE idTarefaCon = p_idTarefa;
		UPDATE tb.tarefa SET statusTarefa = 'CONCLUIDO' WHERE idTarefa = p_idTarefa;
	END IF;
END; 
$$ LANGUAGE plpgsql;

--Função de mudar para concluida se todos concordarem
CREATE FUNCTION tb.check_conclusao(p_idTarefa INT) RETURNS void AS $$
DECLARE resultado VARCHAR(1) = (
SELECT CASE
         WHEN NOT EXISTS(SELECT 
                         FROM   tb.userTarefa
                         WHERE  concluirTarefa = 'YES' AND idTarefaCon = p_idTarefa) THEN 'Y'
         ELSE 'N'
       END);
BEGIN	   
IF resultado = 'Y' THEN 
	UPDATE tb.tarefa SET statusTarefa = 'CONCLUIDO' WHERE idTarefa = p_idTarefa;
END IF;
END; 
$$ LANGUAGE plpgsql;

----------------------------FIM DE FUNÇÕES DE TAREFA----------------------------------

--Adicionando Constrains
ALTER TABLE tb.tarefa
ADD CONSTRAINT prioriTarefa CHECK ((prioriTarefa = 'BAIXA') OR (prioriTarefa = 'NORMAL') OR (prioriTarefa = 'ALTA'));
ALTER TABLE tb.tarefa
ADD CONSTRAINT statusTarefa CHECK ((statusTarefa = 'PENDENTE') OR (statusTarefa = 'ATRASADA') OR (statusTarefa = 'CONCLUIDO') OR (statusTarefa = 'EXCLUIDA'));

ALTER TABLE tb.userTarefa 
ADD CONSTRAINT fk_idTarefa FOREIGN KEY (idTarefaCon) REFERENCES tb.tarefa (idTarefa);
ALTER TABLE tb.userTarefa 
ADD CONSTRAINT fk_UserTarefa FOREIGN KEY (userTarefa) REFERENCES tb.usuario (idUser);

--Chave estrangeira UsuarioCasa e idUsuario
ALTER TABLE tb.userCasa
ADD CONSTRAINT fk_UserCasa FOREIGN KEY (userCasa) REFERENCES tb.usuario (idUser);
--Chave estrangeira IdConCasa e idCasa
ALTER TABLE tb.userCasa
ADD CONSTRAINT fk_idCasa FOREIGN KEY (idCasaCon) REFERENCES tb.casa (idCasa);
--Chave estrangeira Tarefa com idCasa
ALTER TABLE tb.tarefa
ADD CONSTRAINT fk_idCasaTarefa FOREIGN KEY (idCasaTarefa) REFERENCES tb.casa(idCasa);


--Confirmação do convite
ALTER TABLE tb.conviteCasa 
ADD CONSTRAINT confirmaConvite CHECK ((confirmaConvite = 'SIM' OR (confirmaConvite = 'NAO') OR (confirmaConvite = 'ABR')));
--Chave estrangeira Usuario Convite e Usuario
ALTER TABLE tb.conviteCasa
ADD CONSTRAINT fk_UserConvite FOREIGN KEY (userConvite) REFERENCES tb.usuario(idUser);
--Chave estrangeira EmailConvidado e EmailUsuario
ALTER TABLE tb.conviteCasa
ADD CONSTRAINT fk_EmailConvidado FOREIGN KEY (emailConvidado) REFERENCES tb.usuario(emailUser);
--Chave estrangeira idCasa do Convite e idCasa
ALTER TABLE tb.conviteCasa
ADD CONSTRAINT fk_CasaConvite FOREIGN KEY (idCasaConvite) REFERENCES tb.casa(idCasa);


--Comando de busca por usuario
SELECT  FROM tb.tarefa AS tr INNER JOIN tb.userTarefa AS utr ON tr.idTarefa = utr.idTarefa WHERE userTarefa = 'idUsuarioCadastrado';

--MENU
--Tarefas atrasadas
SELECT * FROM tb.tarefa AS tr INNER JOIN tb.userTarefa AS utr ON tr.idTarefa = utr.idTarefaCon 
	WHERE userTarefa = 'idUsuarioCadastrado' AND tr.dataTarefa < CURRENT_TIMESTAMP ORDER BY tr.dataTarefa ASC;

--Tarefas de hoje
SELECT  FROM tb.tarefa AS tr INNER JOIN tb.userTarefa AS utr ON tr.idTarefa = utr.idTarefaCon WHERE userTarefa = 'idUsuarioCadastrado' AND tr.dataTarefa::DATE = CURRENT_TIMESTAMP;

--Comando para concluir tarefa
UPDATE tb.tarefa SET statusTarefa = 'CONCLUIDO' WHERE idTarefa = '' AND 

--Comando do usuario concluir tarefa compartilhada
UPDATE tb.usertarefa SET apagarTarefa = 'YES' WHERE idTarefa = 'idTarefa' AND userTarefa = 'idUsuarioCadastrado';

--Workflow usuário cria nova tarefa, escolhe a qual casa pertence a tarefa.
--Casas do usuário
SELECT nomeCasa FROM tb.casa AS casa INNER JOIN tb.userCasa AS ucasa ON casa.idCasa = ucasa.idCasaCon WHERE ucasa.userCasa = 'idUsuarioCadastrado';

--Sistema limita a as pessoas da casa escolhida
--Usuarios da mesma casa na tarefa
SELECT nomeUser FROM tb.usuario AS us INNER JOIN tb.userCasa AS ucasa ON ucasa.userCasa = us.idUser WHERE ucasa.idCasaCon = 'idDaCasaDaTarefa';



--NOTAS DATETIME - format YYYY-MM-DD HHMISS
--funcao CURRENT DATE tem q utilizar de acordo com a plataforma.
