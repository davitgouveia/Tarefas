CREATE DATABASE Tarefas;

CREATE SCHEMA tb;
CREATE SCHEMA vw;

CREATE TABLE tb.usuario (
	idUser INT PRIMARY KEY,
	nomeUser VARCHAR(100)
);

CREATE TABLE tb.tarefa (
	idTarefa INT PRIMARY KEY,
	prioriTarefa VARCHAR (100),
	tituloTarefa VARCHAR (100),
	descTarefa VARCHAR (100),
	dataCriTarefa DATE,	
);
