CREATE SCHEMA tb;
CREATE SCHEMA vw;

CREATE TABLE tb.usuario (
	idUser INT PRIMARY KEY,
	nomeUser VARCHAR(100),
	emailUser VARCHAR(100),
	idCasa INT DEFAULT(NULL)
);

CREATE TABLE tb.tarefa (
	idTarefa INT PRIMARY KEY,
	prioriTarefa VARCHAR (100),
	tituloTarefa VARCHAR (100),
	descTarefa VARCHAR (100),
	statusTarefa VARCHAR (30),
	dataCriTarefa DATETIME
);

CREATE TABLE tb.casa (
	idCasa INT PRIMARY KEY,
	nomeCasa VARCHAR(100),
	descCasa VARCHAR(100),
	
);

CREATE TABLE tb.userCasa (
	idCasaCon INT,
	userCasa INT,
	statusUsuarioConCasa INT(1) --(1) ATIVO (0) DESATIVO
);

CREATE TABLE tb.conviteCasa (
	idCasaConvite INT,
	userConvite INT,
	emailConvidado VARCHAR(100),
	confirmaConvite VARCHAR (3) DEFAULT ('ABR')
)

CREATE TABLE tb.userTarefa (
	idTarefaCon INT,
	userTarefa INT,
	concluirTarefa VARCHAR(3) DEFAULT('NAO')
	apagarTarefa VARCHAR(3) DEFAULT('NAO')

);

--Função de mudar para concluida se todos concordarem:
CREATE FUNCTION check_conclusao() RETURNS void AS $$

DECLARE resultado VARCHAR(1) := (
SELECT CASE
         WHEN NOT EXISTS(SELECT *
                         FROM   tb.userTarefa
                         WHERE  concluirTarefa <> 'SIM' AND idTarefa = '3') THEN 'Y'
         ELSE 'N'
       END);
BEGIN	   
IF resultado = 'Y' THEN 
	UPDATE tb.tarefa SET statusTarefa = 'CONCLUIDO' WHERE idTarefa = '3';
END IF;
END;
$$ LANGUAGE plpgsql;

--Funcão de criar casa
CREATE FUNCTION criar_casa() RETURNS void AS $$
BEGIN
	INSERT INTO tb.casa (nomeCasa, descCasa)
		VALUES ('', '');
	SELECT add_user_casa();
END;
$$ LANGUAGE plpgsql;

--Função de adicionar usuario a casa
CREATE FUNCTION add_user_casa() RETURNS void AS $$
BEGIN
	INSERT INTO tb.userCasa (idCasaCon, userCasa, statusUsuarioConCasa)
		VALUES ('', '', '1');
END;
$$ LANGUAGE plpgsql;

--Função de criar convite
CREATE FUNCTION convidar_user() RETURNS void AS $$
BEGIN
	INSERT INTO tb.conviteCasa (idCasaConvite, userConvite, emailConvidado)
		VALUES ('', '', '');
END;
$$ LANGUAGE plpgsql;

--Adicionando Constrains
ALTER TABLE tb.tarefa
ADD CONSTRAINT prioriTarefa CHECK ((prioriTarefa = 'BAIXA') OR (prioriTarefa = 'NORMAL') OR (prioriTarefa = 'ALTA'));
ALTER TABLE tb.tarefa
ADD CONSTRAINT statusTarefa CHECK ((statusTarefa = 'PENDENTE') OR (statusTarefa = 'ATRASADA') OR (statusTarefa = 'CONCLUIDO') OR (statusTarefa = 'EXCLUIDA'));

ALTER TABLE tb.userTarefa 
ADD CONSTRAINT fk_idTarefa FOREIGN KEY (idTarefaCon) REFERENCES tb.tarefa (idTarefa);
ALTER TABLE tb.userTarefa 
ADD CONSTRAINT fk_UserTarefa FOREIGN KEY (userTarefa) REFERENCES tb.usuario (idUser);
ALTER TABLE tb.userTarefa 
ADD CONSTRAINT apagarTarefa CHECK ((apagarTarefa = 'SIM' OR (apagarTarefa = 'NAO')));

--Chave estrangeira UsuarioCasa e idUsuario
ALTER TABLE tb.userCasa
ADD CONSTRAINT fk_UserCasa FOREIGN KEY (userCasa) REFERENCES tb.usuario (idUser);
--Chave estrangeira IdConCasa e idCasa
ALTER TABLE tb.userCasa
ADD CONSTRAINT fk_idCasa FOREIGN KEY (idCasaCon) REFERENCES tb.casa (idCasa);


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
SELECT * FROM tb.tarefa AS tr INNER JOIN tb.userTarefa AS utr ON tr.idTarefa = utr.idTarefa WHERE userTarefa = '1';

--MENU
--Tarefas atrasadas
SELECT * FROM tb.tarefa AS tr INNER JOIN tb.userTarefa AS utr ON tr.idTarefa = utr.idTarefa WHERE userTarefa = '1' AND tr.dataCriTarefa < CURRENT_TIMESTAMP;

--Tarefas de hoje
SELECT * FROM tb.tarefa AS tr INNER JOIN tb.userTarefa AS utr ON tr.idTarefa = utr.idTarefa WHERE userTarefa = '1' AND tr.dataCriTarefa::DATE = CURRENT_DATE

--Comando para concluir tarefa
UPDATE tb.tarefa SET statusTarefa = 'CONCLUIDO' WHERE idTarefa = '' AND 

--Comando do usuario concluir tarefa compartilhada
UPDATE tb.usertarefa SET apagarTarefa = 'SIM' WHERE idTarefa = '' AND userTarefa = '';

--NOTAS DATETIME - format: YYYY-MM-DD HH:MI:SS
--funcao CURRENT DATE tem q utilizar de acordo com a plataforma.
