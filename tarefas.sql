CREATE DATABASE Tarefas;

CREATE SCHEMA tb;
CREATE SCHEMA vw;

CREATE TABLE tb.usuario (
	idUser INT PRIMARY KEY,
	nomeUser VARCHAR(100),
	senhaUser VARCHAR(100)
);

CREATE TABLE tb.tarefa (
	idTarefa INT PRIMARY KEY,
	prioriTarefa VARCHAR (100),
	tituloTarefa VARCHAR (100),
	descTarefa VARCHAR (100),
	statusTarefa VARCHAR (30),
	dataCriTarefa DATE,
	userTarefa VARCHAR (100)
	
--Como atribuir mais de um usuario à tarefa? Pensei em, com a ajuda do app, ao selecionar mais de um usuário, uma nova tarefa seria criada
--para cada usuário selecionado, (automaticamente preenchendo os mesmos valores e o nome do usuário em "userTarefa"). Porem, desse jeito
--não haveria a questão de so poder apagar a tarefa se todos concordarem.
);

ALTER TABLE tb.tarefa
ADD CONSTRAINT fk_UserTarefa FOREIGN KEY (userTarefa) REFERENCES tb.usuario (idUser);
ADD CONSTRAINT prioriTarefa CHECK ((prioriTarefa = 'BAIXA') OR (prioriTarefa = 'ALTA'));
ADD CONSTRAINT statusTarefa CHECK ((statusTarefa = 'ABERTA') OR (statusTarefa = 'EM ANDAMENTO') OR (statusTarefa = 'CONCLUIDA') OR (statusTarefa = 'EXCLUIDA'));
