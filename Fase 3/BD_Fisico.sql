-----------------------------------------------------------------------------
-- CRIACAO DO BD DO PALESTUSP
-----------------------------------------------------------------------------

-- Criação de Domínios

CREATE DOMAIN TIPO_CNPJ AS CHAR(14); -- Domínio para CNPJ
CREATE DOMAIN TIPO_TEL AS CHAR(11); -- Domínio para Telefone
CREATE DOMAIN TIPO_CEP AS CHAR(8); -- Domínio para CEP

-- cria a tabela Usuário

-- Tabela que contém informações de cadastro de um usuário do aplicativo
-- onde Login é chave primária.

CREATE TABLE USUARIO(
	Login		VARCHAR(30) PRIMARY KEY,
	Email		VARCHAR(50) NOT NULL,
	Telefone	TIPO_TEL NOT NULL,
	Data_Nasc	DATE NOT NULL, 
	Senha		VARCHAR(30) NOT NULL,
	Tipo_Usu	VARCHAR(30) NOT NULL
);

-- cria a tabela Instituto

-- Tabela que contem informações dos institutos que oferecem palestras
-- onde o CNPJ do Instituto é a chave primária.

CREATE TABLE INSTITUTO(
	CNPJ_Inst	TIPO_CNPJ PRIMARY KEY,
	Nome		VARCHAR(70) NOT NULL,
	CEP			TIPO_CEP NOT NULL,
	Num_End		INT NOT NULL,
	Logradouro	VARCHAR(100),
	Email		VARCHAR(50) NOT NULL
);

-- cria a tabela Aluno

-- Tabela aluno se trata de todos os alunos cadastrados no aplicativo,
-- onde Login é chave primária e chave estrangeira que referencia a tabela Usuário.
-- Remoção: Cascade
-- Alteração: Cascade

CREATE TABLE ALUNO(
	Login		VARCHAR(30) PRIMARY KEY,
	FOREIGN KEY (Login) REFERENCES USUARIO (Login)
		ON DELETE CASCADE ON UPDATE CASCADE
);

-- cria a tabela Aluno fora

-- Tabela de aluno fora onde é destinada aos alunos que vem de fora da USP, onde o mesmo 
-- recebe um número de identificação que é sua chave primária e Login é a chave estrangeira que referencia 
-- a tabela Usuário.
-- Remoção: Cascade
-- Alteração: Cascade

CREATE TABLE ALUNO_FORA(
	Num_Aluno_Conv		VARCHAR(10) PRIMARY KEY,
	Login				VARCHAR(30) NOT NULL,
	Faculdade			VARCHAR(50) NOT NULL,
	FOREIGN KEY (Login) REFERENCES ALUNO (Login)
		ON DELETE CASCADE ON UPDATE CASCADE
);

-- cria a tabela Aluno USP

-- Tabela de aluno USP onde é destinada aos alunos USP, onde o mesmo 
-- tem seu número USP como identificação que é sua chave primária e Login é a chave estrangeira que referencia 
-- a tabela Aluno e também tem CNPJ como chave estrangeira que referencia a tabela Instituto.
-- Remoção: Cascade
-- Alteração: Cascade

CREATE TABLE ALUNO_USP(
	Num_USP			VARCHAR(10) PRIMARY KEY,
	Login			VARCHAR(30) UNIQUE NOT NULL,
	CNPJ_Inst		TIPO_CNPJ,
	FOREIGN KEY (Login) REFERENCES ALUNO (Login)
		ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (CNPJ_Inst) REFERENCES INSTITUTO (CNPJ_Inst)
		ON DELETE CASCADE ON UPDATE CASCADE
);

-- cria a tabela Convidado

-- Tabela destinada aos Convidados das palestras onde o mesmo 
-- recebe um número de identificação que é sua chave primária e Login é a chave estrangeira que referencia 
-- a tabela Usuário.
-- Remoção: Cascade
-- Alteração: Cascade

CREATE TABLE CONVIDADO(
	Num_Conv		VARCHAR(10) PRIMARY KEY,
	Login			VARCHAR(30) UNIQUE NOT NULL,
	Area_Trabalho	VARCHAR(50) NOT NULL,
	FOREIGN KEY (Login) REFERENCES USUARIO (Login)
		ON DELETE CASCADE ON UPDATE CASCADE
);

-- cria a tabela Professor

-- Tabela Professor se trata de todos os Professores cadastrados no aplicativo
-- onde Login é chave primária e chave estrangeira que referencia a tabela Usuário.
-- Remoção: Cascade
-- Alteração: Cascade

CREATE TABLE PROFESSOR(
	Login				VARCHAR(30) PRIMARY KEY,
	Area_De_Atuacao		VARCHAR(30) NOT NULL,
	FOREIGN KEY (Login) REFERENCES USUARIO (Login)
		ON DELETE CASCADE ON UPDATE CASCADE
);

-- cria a tabela professor de fora

-- Tabela de Professor Fora onde é destinada aos professores que vem de fora da USP, onde o mesmo 
-- recebe um número de identificação que é sua chave primária e Login é a chave estrangeira que referencia 
-- a tabela Professor. 
-- Remoção: Cascade
-- Alteração: Cascade

CREATE TABLE PROF_FORA(
	Num_Prof_Conv		VARCHAR(10) PRIMARY KEY,
	Login				VARCHAR(30) UNIQUE NOT NULL,
	Faculdade			VARCHAR(50) NOT NULL,
	FOREIGN KEY (Login) REFERENCES PROFESSOR (Login)
		ON DELETE CASCADE ON UPDATE CASCADE
);

-- cria a tabela professor USP

-- Tabela Professor USP onde é destinada aos professores da USP, onde o mesmo 
-- tem seu número USP como identificação que é sua chave primária e Login e a chave estrangeira que referencia 
-- a tabela Professor e também tem CNPJ como chave estrangeira que referencia a tabela Instituto.
-- Remoção: Cascade
-- Alteração: Cascade

CREATE TABLE PROF_USP(
	Num_USP				VARCHAR(10) PRIMARY KEY,
	Login				VARCHAR(30) UNIQUE NOT NULL,
	CNPJ_Inst			TIPO_CNPJ NOT NULL,
	FOREIGN KEY (Login) REFERENCES PROFESSOR (Login)
		ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (CNPJ_Inst) REFERENCES INSTITUTO (CNPJ_Inst)
		ON DELETE CASCADE ON UPDATE CASCADE
);

-- cria a tabela palestrante

-- Tabela destinada ao professor palestrante que recebe um número de identificação que é sua chave primária
-- e Login é a chave estrangeira que referencia a tabela Usuário.
-- Remoção: Cascade
-- Alteração: Cascade

CREATE TABLE PALESTRANTE(
	Id_Palestrante		VARCHAR(10) PRIMARY KEY,
	Login				VARCHAR(30) UNIQUE NOT NULL,
	FOREIGN KEY (Login) REFERENCES USUARIO (Login)
		ON DELETE CASCADE ON UPDATE CASCADE
);

-- Cria a tabela de disponibilidades do palestrante

-- Tabela que indica a disponibilidade dos palestrantes onde Disponibilidade e Identificação Palestrante
-- é uma chave primária composta e Identificação Palestrante é chave estrangeira
-- que referencia a tabela Palestrante.
-- Remoção: Cascade
-- Alteração: Cascade

CREATE TABLE DISPONIBILIDADE(
	Disponibilidade 	DATE NOT NULL,
	Id_Palestrante		VARCHAR(10) NOT NULL,
	PRIMARY KEY (Disponibilidade,Id_Palestrante),
	FOREIGN KEY (Id_Palestrante) REFERENCES PALESTRANTE (Id_Palestrante)
		ON DELETE CASCADE ON UPDATE CASCADE
);

-- cria a tabela lingua do palestrante

-- Tabela que se trata das linguas disponíveis dos palestrantes onde Lingua e 
-- Identificação do Palestrante é uma cheve primária composta
-- e também Identificação do Palestrante é chave estrangeira que referencia a tabela Palestrante.
-- Remoção: Cascade
-- Alteração: Cascade

CREATE TABLE LINGUA_PALESTRANTE(
	Lingua				VARCHAR(30) NOT NULL,
	Id_Palestrante		VARCHAR(10) NOT NULL,
	PRIMARY KEY (Lingua,Id_Palestrante),
	FOREIGN KEY (Id_Palestrante) REFERENCES PALESTRANTE (Id_Palestrante)
		ON DELETE CASCADE ON UPDATE CASCADE
);

-- cria a tabela sala

-- Tabela que se trata das salas onde é possível realizar as palestras e tem como chave primária
-- e chave estrangeira o CNPJ do Instituto que referencia a tabela Instituto.
-- Remoção: Cascade
-- Alteração: Cascade

CREATE TABLE SALA(
	N_Sala			INT NOT NULL,
	Bloco			CHAR(1) NOT NULL,
	Andar			INT NOT NULL,
	DISP_Sala		BOOLEAN DEFAULT TRUE,
	CNPJ_Inst		TIPO_CNPJ PRIMARY KEY,
	FOREIGN KEY (CNPJ_Inst) REFERENCES INSTITUTO (CNPJ_Inst)
		ON DELETE CASCADE ON UPDATE CASCADE
);

-- cria a tabela palestra fisica

-- Tabela que contém informações das palestras, onde Identificação da Palestra Física 
-- é chave primária e CNPJ é chave estrangeira que referencia a tabela Sala.
-- Remoção: Cascade
-- Alteração: Cascade

CREATE TABLE PALESTRA_FISICA(
	Id_Pale_Fisi		VARCHAR(10) PRIMARY KEY,
	Titulo				VARCHAR(100) NOT NULL,
	Duracao				TIME NOT NULL,
	Horario				TIME NOT NULL,
	Data 				DATE NOT NULL,
	Idioma				VARCHAR(30) NOT NULL,
	CNPJ_Inst			TIPO_CNPJ NOT NULL,
	FOREIGN KEY (CNPJ_Inst) REFERENCES SALA (CNPJ_Inst)
		ON DELETE CASCADE ON UPDATE CASCADE
);

-- cria a tabela assiste

-- Tabela que se trata dos usuários do aplicativo que assistem as palestras e tem 
-- Identificação do Palestrante e Login como cheve primária composta e 
-- Identificação do Palestrante como chave estrangeira que referencia a tabela Palestrante 
-- e também Login que referencia a tabela Usuario.
-- Remoção: Cascade
-- Alteração: Cascade

CREATE TABLE ASSISTE(
	Id_Pale_Fisi	VARCHAR(10) NOT NULL,
	Login			VARCHAR(30) NOT NULL,
	PRIMARY KEY (Id_Pale_Fisi, Login),
	FOREIGN KEY (Id_Pale_Fisi) REFERENCES PALESTRA_FISICA (Id_Pale_Fisi)
		ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (Login) REFERENCES USUARIO (Login)
		ON DELETE CASCADE ON UPDATE CASCADE

);

-- cria a tabela realização da palestra

-- Tabela que se trata da realização das palestras e tem Identificação da Palestra Física, 
-- Identificação do Palestrante como cheve primária composta e
-- Identificação da Palestra Física e Identificação do Palestrante são chaves estrangeiras
-- que referencia as tabelas Palestra Física e Palestrante respectivamente.
-- Remoção: Cascade
-- Alteração: Cascade

CREATE TABLE REALIZACAO(
	Id_Pale_Fisi		VARCHAR(10) NOT NULL,
	Id_Palestrante		VARCHAR(10) NOT NULL,
		PRIMARY KEY (Id_Pale_Fisi, Id_Palestrante),
	FOREIGN KEY (Id_Pale_Fisi) REFERENCES PALESTRA_FISICA (Id_Pale_Fisi)
		ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (Id_Palestrante) REFERENCES PALESTRANTE (Id_Palestrante)
		ON DELETE CASCADE ON UPDATE CASCADE

);

-- cria a tabela Telefone do Instituto

-- Tabela com os telefones dos institutos onde Telefone e CNPJ é uma 
-- chave primária composta e CNPJ é chave estrangeira que referencia a tabela Instituto.
-- Remoção: Cascade
-- Alteração: Cascade

CREATE TABLE TELEFONE_INSTITUTO(
	Telefone	CHAR(10) NOT NULL,
	CNPJ_Inst	TIPO_CNPJ UNIQUE NOT NULL,
	PRIMARY KEY (Telefone, CNPJ_Inst),
	FOREIGN KEY (CNPJ_Inst) REFERENCES INSTITUTO (CNPJ_Inst)
		ON DELETE CASCADE ON UPDATE CASCADE
);

-----------------------------------------------
------------------- FIM -----------------------
-----------------------------------------------