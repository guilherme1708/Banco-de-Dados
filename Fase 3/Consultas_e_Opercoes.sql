-- Consultas e operações importantes identificadas para o BD --
---------------------------------------------------------------

-- Listagem das consultas mais frequentes --

-- 1) Recuperar as salas e bloco de cada instituto que têm palestras agendadas.

SELECT S.N_Sala AS Número_da_Sala, S.Bloco, I.Nome AS Nome_do_Instituto, PF.Data AS Data_da_Palestra
	FROM PALESTRA_FISICA PF 
	LEFT JOIN INSTITUTO I ON I.CNPJ_Inst = PF.CNPJ_Inst 
	LEFT JOIN SALA S ON S.CNPJ_Inst = I.CNPJ_Inst;

-- 2) Recuperar as áreas de atuação dos professores palestrantes da USP.

SELECT P.Area_De_Atuacao AS Área_de_atuação_Prof_Palestrante_USP 
	FROM PROFESSOR P 
	LEFT JOIN USUARIO U ON P.Login = U.Login
	INTERSECT
	SELECT P.Area_De_Atuacao FROM PROFESSOR P, PROF_USP PU, PALESTRANTE PA 
	WHERE P.Login = PU.Login AND PA.Login = PU.Login;

-- 3) Recuperar as palestras que serão realizadas em inglês.

SELECT * FROM PALESTRA_FISICA WHERE Idioma = 'Inglês';

-- 4) Recuperar o CNPJ dos institutos por ordem alfabética.

SELECT CNPJ_Inst, Nome FROM INSTITUTO ORDER BY Nome ASC;

-- 5) Recuperar o número USP dos alunos cadastrados.

SELECT Num_USP FROM ALUNO_USP;

-- 6) Recuperar os e-mails das pessoas cadastradas.

SELECT Email FROM USUARIO;

-- 7) Recuperar a identificação do palestrante em cada horário de palestra marcada.

SELECT R.Id_Palestrante, PF.Horario FROM REALIZACAO R 
	LEFT JOIN PALESTRA_FISICA PF ON R.Id_Pale_Fisi = PF.Id_Pale_Fisi ORDER BY R.Id_Palestrante ASC;

-- 8) Recuperar os títulos das palestras.

SELECT Titulo FROM PALESTRA_FISICA;

-- 9) Recuperar a localização das salas (endereço do instituto, bloco, andar) com palestras agendadas.

SELECT I.Nome AS Nome_do_Instituto, I.Logradouro AS Endereço, I.Num_End AS Número, S.Bloco, S.Andar, S.N_Sala AS Número_da_Sala
	FROM PALESTRA_FISICA PF 
	LEFT JOIN SALA S ON PF.CNPJ_Inst = S.CNPJ_Inst
	LEFT JOIN INSTITUTO I ON S.CNPJ_Inst = I.CNPJ_Inst;

-- 10) Recuperar a disponibilidade dos palestrantes em dias sem palestras agendadas.

SELECT * FROM Disponibilidade
EXCEPT
SELECT DATA, R.Id_PALESTRANTE FROM PALESTRA_FISICA PF LEFT JOIN REALIZACAO R ON PF.Id_Pale_Fisi = R.Id_Pale_Fisi;

-- FIM --

-------------------------------------------- OPERAÇÕES IMPORTANTES ----------------------------------------------------

-- INSERIR NOVO USUÁRIO

-- Stored Procedure para inserir novo usuário

CREATE OR REPLACE FUNCTION InsereUsuario(novo_login VARCHAR(30), novo_email VARCHAR(50), novo_telefone TIPO_TEL, nova_data_nasc DATE, nova_senha VARCHAR(30), novo_tipo VARCHAR(30)) 
RETURNS VOID AS $$

BEGIN
	INSERT INTO USUARIO (Login, Email, Telefone, Data_Nasc, Senha, Tipo_Usu) VALUES (novo_login, novo_email, novo_telefone, nova_data_nasc, nova_senha, novo_tipo); -- Insere Novo Usuário
END;
$$ LANGUAGE 'plpgsql';

-- Teste da Stored Procedure

--SELECT InsereUsuario ('murilo12','murilo12@usp.br','11996398871','1995-05-18','soudhf','Aluno Fora');

-- DELETAR USUÁRIO

CREATE OR REPLACE FUNCTION DeletaUsuario(deleta_login VARCHAR(30)) 
RETURNS VOID AS $$

BEGIN
	IF EXISTS (SELECT Login FROM USUARIO WHERE Login = deleta_login) -- Verificar se o login a ser deletado existe
		THEN DELETE FROM USUARIO WHERE Login = deleta_login; -- Deleta Usuário com o Login = deleta_login
	ELSE RAISE EXCEPTION 'O usuário não existe, portanto não pode ser deletado.';
    END IF;
END;
$$ LANGUAGE 'plpgsql';

-- Teste da Stored Procedure

--SELECT DeletaUsuario ('murilo12');

-- INDISPONIBILIZAR SALA

CREATE OR REPLACE FUNCTION IndispSala(novo_CNPJ_Inst TIPO_CNPJ)
RETURNS VOID AS $$

BEGIN 
	IF EXISTS (SELECT CNPJ_Inst FROM SALA WHERE CNPJ_Inst = novo_CNPJ_Inst AND Disp_Sala = TRUE) -- Verifica se a sala tem disponibilidade = True
		THEN UPDATE SALA SET Disp_Sala = FALSE WHERE CNPJ_Inst = novo_CNPJ_Inst; -- Atualiza a disponibilidade para False, assim indispnibilizando a sala para palestras
	ELSE RAISE EXCEPTION 'Instituto tem sala Indisponível';
	END IF;
END;
$$ LANGUAGE 'plpgsql';

-- Teste da Stored Procedure

--SELECT IndispSala ('63025530000104');

-- INSERIR NOVA PALESTRA

CREATE OR REPLACE FUNCTION InserePalestra(novo_Id_Pale_Fisi VARCHAR(10), novo_Titulo VARCHAR(100), nova_Duracao TIME, nova_Horario TIME, nova_Data DATE, novo_Idioma VARCHAR(30), novo_CNPJ_Inst TIPO_CNPJ) 
RETURNS VOID AS $$

BEGIN
    IF EXISTS (SELECT CNPJ_Inst, Disp_Sala FROM SALA WHERE CNPJ_Inst = novo_CNPJ_Inst AND Disp_Sala = TRUE) -- Verificar se Existe o instituto com o CNPJ = novo_CNPJ_Inst e disponibilidade = TRUE
    	THEN INSERT INTO PALESTRA_FISICA (Id_Pale_Fisi, Titulo, Duracao, Horario, Data, Idioma, CNPJ_Inst) VALUES (novo_Id_Pale_Fisi, novo_Titulo, nova_Duracao, nova_Horario, nova_Data, novo_Idioma, novo_CNPJ_Inst); -- Insere uma nova Palestra
    ELSE RAISE EXCEPTION 'Instituto tem sala Indisponível';
    END IF;
END;
$$ LANGUAGE 'plpgsql';

-- Teste da Stored Procedure

--SELECT InserePalestra ('006','Beauty and Truth in Mathematics and Science','01:30','12:25','2018-10-27','Inglês','63025530000104');

-- DELETAR PALESTRA

CREATE OR REPLACE FUNCTION DeletaPalestra(deleta_Id VARCHAR(10)) 
RETURNS VOID AS $$

BEGIN
	IF EXISTS (SELECT Id_Pale_Fisi FROM PALESTRA_FISICA WHERE Id_Pale_Fisi = deleta_Id) -- Verificar se palestra a ser deletada existe
		THEN DELETE FROM PALESTRA_FISICA WHERE Id_Pale_Fisi = deleta_Id; -- Deleta uma palestra com Id da Palestra = Id_Pale_Fisi
	ELSE RAISE EXCEPTION 'A paletra não existe, portanto não pode ser deletada.';
    END IF;
END;
$$ LANGUAGE 'plpgsql';

-- Teste da Stored Procedure

--SELECT DeletaPalestra ('005');

-- ADICIONAR NOVA LINGUA PARA O PALESTRANTE

CREATE OR REPLACE FUNCTION InsereLingua (nova_linga VARCHAR(30), novo_Id_Palestrante VARCHAR(10)) 
RETURNS VOID AS $$

BEGIN
    INSERT INTO LINGUA_PALESTRANTE (Lingua, Id_Palestrante) VALUES (nova_linga, novo_Id_Palestrante); -- Insere uma nova lingua
END;
$$ LANGUAGE 'plpgsql';

-- Teste da Stored Procedure

--SELECT InsereLingua ('Inglês','0002');

-- ATUALIZAR TELEFONE DO INSTITUTO

CREATE OR REPLACE FUNCTION AtualizaTelefone(novo_telefone TIPO_TEL, novo_CNPJ_Inst TIPO_CNPJ) 
RETURNS VOID AS $$

BEGIN
	IF EXISTS (SELECT CNPJ_Inst FROM INSTITUTO WHERE CNPJ_Inst = novo_CNPJ_Inst) -- Verificar se o instituto cujo o telefone vai ser alterado existe
		THEN UPDATE TELEFONE_INSTITUTO SET Telefone = novo_telefone WHERE CNPJ_Inst = novo_CNPJ_Inst; -- Atualiza o telefone do Instituto com CNPJ = novo_CNPJ_Inst
	ELSE RAISE EXCEPTION 'CNPJ do Instituto não existe, o telefone não alterado.';
    END IF;
END;
$$ LANGUAGE 'plpgsql';

-- Teste da Stored Procedure

--SELECT AtualizaTelefone ('1130916241','63025530006226');

-- VERIFICAR SE NENHUMA PALESTRA VAI SER ALTERADA PARA A MESMA DATA E HORA E LOCAL DE OUTRA PALESTRA

CREATE OR REPLACE FUNCTION AtualizaLocaleDataPale (new_ID_Pale VARCHAR(10), new_CNPJ TIPO_CNPJ, new_data DATE, new_horario TIME)
RETURNS VOID AS $$

BEGIN
	UPDATE PALESTRA_FISICA SET Data = new_data, Horario = new_horario, CNPJ_Inst = new_CNPJ WHERE Id_Pale_Fisi = new_ID_Pale; -- Atualiza uma palestra
END;
$$ LANGUAGE 'plpgsql';

-- Teste da Stored Procedure

--SELECT AtualizaLocaleDataPale ('002','63025530000619','2018-10-16','12:00');

-- TRIGGER PARA VERIFICAR SE UMA NOVA PALESTRA NÃO VAI SER INSERIDA OU ATUALIZADA PARA O MESMO LOCAL E HORÁRIO DE OUTRA

CREATE OR REPLACE FUNCTION VerifPale()
RETURNS TRIGGER AS $$

BEGIN
	IF EXISTS (SELECT CNPJ_Inst FROM PALESTRA_FISICA WHERE CNPJ_Inst = NEW.CNPJ_Inst AND Data = NEW.data AND Horario = NEW.Horario) --  Verificar se existe alguma palestra marcada em algum instituto 
		THEN RAISE EXCEPTION 'Existe uma palestra nesta mesma data, horário e local. A data não foi inserida ou alterada.'; -- Não deixa inserir ou alterar uma palestra caso tenha uma outra palestra marcada no mesmo local e horário ai o Trigger dispara a mensagem
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER SalaOcupada 
BEFORE INSERT OR UPDATE ON PALESTRA_FISICA -- Antes de inserir ou Atualizar uma nova palestra na tabela Palestra fisica
FOR EACH ROW
EXECUTE PROCEDURE VerifPale();

-- Teste do Trigger

-- INSERT INTO PALESTRA_FISICA (Id_Pale_Fisi, Titulo, Duracao, Horario, Data, Idioma, CNPJ_Inst) VALUES ('006','Botánica en el Contexto Cósmico','01:00','12:30','2018-12-02','Espanhol','63025530000880');

-- TRIGGER PARA VERIFICAR SE TEM 16 ANOS OU MAIS

CREATE OR REPLACE FUNCTION VerifIdade()
RETURNS TRIGGER AS $$

BEGIN
	IF ((SELECT (extract(year from NOW())) - (SELECT extract(year from NEW.Data_Nasc )))) <= 16 -- Verifica se o Usuário é menor de 16 anos
	THEN RAISE EXCEPTION 'Usuário menor de 16 anos. Usuário não foi inserido.';    -- se for ativa o Trigger e dispara a mensagem 
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER Maior16 
BEFORE INSERT OR UPDATE OF Data_Nasc ON USUARIO -- Antes de atualizar ou inserir Data de Nascimento da tabela Usuário
FOR EACH ROW
EXECUTE PROCEDURE VerifIdade();

-- Teste do Trigger

--SELECT InsereUsuario ('Roberto59','roberto59@usp.br','11971241321','2005-05-18','werwere', 'Aluno Fora');

-----------------------------------------------
------------------- FIM -----------------------
-----------------------------------------------