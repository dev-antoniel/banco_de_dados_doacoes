CREATE DATABASE banco_caridade;
USE banco_caridade;

CREATE TABLE endereco (
    id_endereco INT AUTO_INCREMENT PRIMARY KEY,
    cep VARCHAR(9) NOT NULL,
    uf CHAR(2) NOT NULL,
    cidade VARCHAR(50) NOT NULL,
    logradouro VARCHAR(100),
    numero VARCHAR(10),
    complemento VARCHAR(50),
    bairro VARCHAR(50)
);

CREATE TABLE usuario(
	id_usuario INT AUTO_INCREMENT PRIMARY KEY,
	email VARCHAR(100) NOT NULL UNIQUE, 
	senha VARCHAR(100) NOT NULL, 
	tipo_usuario ENUM('doador_fisico','doador_juridico','ong') NOT NULL,
	data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
	ativo BOOLEAN DEFAULT TRUE,
	ultimo_login DATETIME,
	foto_perfil VARCHAR(255)
);

CREATE TABLE telefone(
	id_telefone INT PRIMARY KEY AUTO_INCREMENT,
	id_usuario INT NOT NULL,
	numero VARCHAR(15) NOT NULL,
	tipo ENUM('residencial','comercial','celular'),
	FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE doador(
	id_doador INT PRIMARY KEY,
	nome_publico VARCHAR(100) NOT NULL,
	anonimo BOOLEAN DEFAULT FALSE,
	FOREIGN KEY (id_doador) REFERENCES usuario(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE doador_fisico (
    id_doador_fisico INT PRIMARY KEY,
    nome_completo VARCHAR(100) NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    data_nascimento DATE,
    FOREIGN KEY (id_doador_fisico) REFERENCES doador(id_doador) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE doador_juridico (
    id_doador_juridico INT PRIMARY KEY,
    razao_social VARCHAR(100) NOT NULL,
    nome_fantasia VARCHAR(100),
    cnpj VARCHAR(14) UNIQUE NOT NULL,
    responsavel VARCHAR(100),
    descricao TEXT,
    site_url VARCHAR(100),
    FOREIGN KEY (id_doador_juridico) REFERENCES doador(id_doador) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE selo_qualidade (
    id_selo INT AUTO_INCREMENT PRIMARY KEY,
    id_doador_juridico INT NOT NULL,
    tipo_selo ENUM('ouro', 'prata', 'bronze') NOT NULL,
    data_concessao DATE NOT NULL,
    data_validade DATE NOT NULL,
    criterios_atendidos TEXT NOT NULL,
    concedido_por VARCHAR(100) NOT NULL,
    FOREIGN KEY (id_doador_juridico) REFERENCES doador_juridico(id_doador_juridico)
);

CREATE TABLE ong(
	id_ong INT PRIMARY KEY,
	razao_social VARCHAR(100) NOT NULL,
	nome_fantasia VARCHAR(100) NOT NULL,
	cnpj VARCHAR(14) NOT NULL UNIQUE,
	responsavel VARCHAR(100) NOT NULL,
	descricao TEXT,
	areas_atuacao VARCHAR(150),
	certificacoes BOOLEAN DEFAULT FALSE,
	site_url VARCHAR(255),
	FOREIGN KEY (id_ong) REFERENCES usuario(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE categoria (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    icone VARCHAR(255)
);

CREATE TABLE tag (
    id_tag INT AUTO_INCREMENT PRIMARY KEY,
    id_categoria INT,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    cor_hex VARCHAR(7),
    FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE item (
    id_item INT AUTO_INCREMENT PRIMARY KEY,
    id_doador INT,
    id_categoria INT,
    titulo VARCHAR(100) NOT NULL,
    descricao TEXT,
    estado_conservacao ENUM('novo', 'bom', 'regular', 'precisa_reparo'),
    fotos TEXT,
    status_item ENUM('disponivel', 'reservado', 'doado') DEFAULT 'disponivel' NOT NULL,
    data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
    data_atualizada DATETIME,
    FOREIGN KEY (id_doador) REFERENCES doador(id_doador) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE item_tag(
    id_item INT,
    id_tag INT,
    PRIMARY KEY (id_item, id_tag),
    FOREIGN KEY (id_item) REFERENCES item(id_item) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_tag) REFERENCES tag(id_tag) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE reserva (
    id_reserva INT AUTO_INCREMENT PRIMARY KEY,
    id_ong INT NOT NULL,
    id_categoria INT NOT NULL,
    quantidade_solicitada INT NOT NULL CHECK (quantidade_solicitada > 0),
    status_reserva ENUM('pendente', 'concluida', 'cancelada') DEFAULT 'pendente' NOT NULL,
    data_reserva DATETIME DEFAULT CURRENT_TIMESTAMP,
    data_conclusao DATETIME,
    motivo_cancelamento TEXT,
    observacoes TEXT,
    FOREIGN KEY (id_ong) REFERENCES ong(id_ong) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE reserva_tag (
    id_reserva INT NOT NULL,
    id_tag INT NOT NULL,
    PRIMARY KEY (id_reserva, id_tag),
    FOREIGN KEY (id_reserva) REFERENCES reserva(id_reserva) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_tag) REFERENCES tag(id_tag) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE historico_status_item (
    id_historico INT AUTO_INCREMENT PRIMARY KEY,
    id_item INT NOT NULL,
    id_usuario_responsavel INT,
    status_anterior ENUM('disponível', 'reservado', 'doado', 'descarte'),
    status_novo ENUM('disponível', 'reservado', 'doado', 'descarte') NOT NULL,
    quantidade_anterior INT,
    quantidade_nova INT,
    data_mudanca DATETIME DEFAULT CURRENT_TIMESTAMP,    
    FOREIGN KEY (id_item) REFERENCES item(id_item),
    FOREIGN KEY (id_usuario_responsavel) REFERENCES usuario(id_usuario)
);

CREATE TABLE historico_status_reserva (
    id_historico INT AUTO_INCREMENT PRIMARY KEY,
    id_reserva INT NOT NULL,
    id_usuario_responsavel INT NOT NULL,
    quantidade_anterior INT CHECK (quantidade_anterior > 0) NOT NULL,
    quantidade_nova INT CHECK (quantidade_nova >= 0) NOT NULL,
    data_mudanca DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_reserva) REFERENCES reserva(id_reserva) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_usuario_responsavel) REFERENCES doador(id_doador) ON DELETE CASCADE ON UPDATE CASCADE
);
