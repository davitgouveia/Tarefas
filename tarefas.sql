CREATE DATABASE Tarefas;

CREATE SCHEMA tb;
CREATE SCHEMA vw;

CREATE TABLE tb.usuario (
	idUser INT PRIMARY KEY,
	nomeUser VARCHAR(100),
	loginUser VARCHAR(100),
	senhaUser VARCHAR(100)
);

CREATE TABLE tb.tarefa (
	idTarefa INT PRIMARY KEY,
	prioriTarefa VARCHAR (100),
	tituloTarefa VARCHAR (100),
	descTarefa VARCHAR (100),
	statusTarefa VARCHAR (30),
	dataCriTarefa DATE
);

CREATE TABLE tb.userTarefa (
	idTarefa INT,
	userTarefa INT,
	apagarTarefa VARCHAR(3)
--Criar função que muda o statusTarefa para EXCLUIDA se todos as linhas --apagarTarefa-- da tabela com idTarefa = X forem iguais a 'SIM'
);

ALTER TABLE tb.tarefa
ADD CONSTRAINT fk_UserTarefa FOREIGN KEY (userTarefa) REFERENCES tb.usuario (idUser);
ADD CONSTRAINT prioriTarefa CHECK ((prioriTarefa = 'BAIXA') OR (prioriTarefa = 'NORMAL') OR (prioriTarefa = 'ALTA'));
ADD CONSTRAINT statusTarefa CHECK ((statusTarefa = 'ABERTA') OR (statusTarefa = 'EM ANDAMENTO') OR (statusTarefa = 'CONCLUIDA') OR (statusTarefa = 'EXCLUIDA'));

ALTER TABLE tb.userTarefa (
ADD CONSTRAINT fk_idTarefa FOREIGN KEY (idTarefa) REFERENCES tb.tarefa (idTarefa);
ADD CONSTRAINT fk_UserTarefa FOREIGN KEY (userTarefa) REFERENCES tb.usuario (idUser);
ADD CONSTRAINT apagarTarefa CHECK ((apagarTarefa = 'SIM' OR (apagarTarefa = 'NAO'));
);
