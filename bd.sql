-- Database: backoffice

-- DROP DATABASE "backoffice";

CREATE DATABASE "backoffice"
    WITH
    OWNER = admin
    ENCODING = 'UTF8'
    TEMPLATE template0
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

--------SCHEMA AUTETICACION------
CREATE SCHEMA autenticacion;

CREATE TABLE autenticacion.perfiles (
    id_perfil SERIAL PRIMARY KEY,
    nombre VARCHAR(30),
    descripcion VARCHAR(50),
    fecha_registro timestamp without time zone DEFAULT NOW()
);
CREATE TABLE autenticacion.modulos (
    id_modulo SERIAL PRIMARY KEY,
    nombre VARCHAR(30),
    descripcion VARCHAR(50),
    fecha_registro timestamp without time zone DEFAULT NOW()
);
CREATE TABLE autenticacion.perfiles_modulos (
    id SERIAL PRIMARY KEY,
    id_perfil INT REFERENCES autenticacion.perfiles(id_perfil) ON DELETE CASCADE,
    id_modulo INT REFERENCES autenticacion.modulos(id_modulo) ON DELETE CASCADE,
    fecha_registro timestamp without time zone DEFAULT NOW()
);

CREATE TABLE autenticacion.usuarios (
    id_usuario BIGINT PRIMARY KEY,
    nombres VARCHAR(50) NOT NULL,
    apellidos VARCHAR(50) NOT NULL,
    username VARCHAR(30) UNIQUE NOT NULL,
    contrasena TEXT NOT NULL,
    id_perfil INT REFERENCES autenticacion.perfiles(id_perfil) ON DELETE SET NULL,
    fecha_registro timestamp without time zone DEFAULT NOW()
);

-------SCHEMA PARAMETROS----
CREATE SCHEMA parametros;

CREATE TABLE parametros.departamentos (
    id BIGINT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE parametros.municipios (
    id BIGINT PRIMARY KEY,
    id_departamento BIGINT REFERENCES parametros.departamentos(id) ON DELETE CASCADE,
    nombre VARCHAR(100) NOT NULL,
    divipo VARCHAR(15)
);
CREATE TABLE parametros.organismos (
    id SERIAL PRIMARY KEY,
    abreviatura VARCHAR(255) NOT NULL,
    id_municipio INT REFERENCES parametros.municipios(id) ON DELETE CASCADE,
    divipo VARCHAR(20),
    nombre VARCHAR(255),
    direccion VARCHAR(255),
    telefono VARCHAR(50),
    pagina_web VARCHAR(255),
    email VARCHAR(100),
    horario VARCHAR(255)
);
CREATE TABLE parametros.tipos_codigos (
    id BIGINT PRIMARY KEY,
    descripcion TEXT NOT NULL
);
-- Crear una tabla de codigo_valor en el esquema parametros
CREATE TABLE parametros.codigo_valor (
    ano INT CHECK (ano >= 1000 AND ano <= 9999),
    valor DOUBLE PRECISION NOT NULL,
    id_tipo_codigo BIGINT REFERENCES parametros.tipos_codigos(id) ON DELETE CASCADE,
    PRIMARY KEY (ano, valor, id_tipo_codigo)
);

CREATE TABLE parametros.codigos_transito (
    codigo VARCHAR(4) PRIMARY KEY,
    descripcion TEXT,
    id_tipo_codigo BIGINT REFERENCES parametros.tipos_codigos(id) ON DELETE SET NULL
);
--------SCHEMA OPERACION------
CREATE SCHEMA operacion;

CREATE TABLE operacion.agentes (
    id_agente SERIAL PRIMARY KEY,
    id_usuario_fk BIGINT REFERENCES autenticacion.usuarios(id_usuario) ON DELETE CASCADE,
    placa_ag VARCHAR(10) NOT NULL,
    firma TEXT,
    estado BOOLEAN DEFAULT TRUE
);

CREATE TABLE operacion.tipo_estado_infraccion (
    id_tipo VARCHAR(4) PRIMARY KEY,
    descripcion VARCHAR(30) NOT NULL
);
CREATE TABLE operacion.estado_infraccion (
    id SERIAL PRIMARY KEY,
    abreviatura TEXT NOT NULL,
    descripcion TEXT NOT NULL,
    orden INT,
    id_tipo_fk VARCHAR(4) REFERENCES operacion.tipo_estado_infraccion(id_tipo) ON DELETE CASCADE
);
CREATE SEQUENCE operacion.consecutivo_infraccion_seq START WITH 1 INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE operacion.infracciones (
    nro_infraccion VARCHAR(20) PRIMARY KEY,
    fecha_infraccion TIMESTAMP WITHOUT TIME ZONE,
    direccion TEXT,
    placa VARCHAR(20),
    fecha_soap DATE,
    fecha_tec_mecanica DATE,
    id_estado_fk INT REFERENCES operacion.estado_infraccion(id) ON DELETE SET NULL,
    id_organismo_fk INT REFERENCES parametros.organismos(id) ON DELETE SET NULL,
    id_agente_fk INT REFERENCES operacion.agentes(id_agente) ON DELETE SET NULL NULL,
    id_equipo INT REFERENCES operacion.equipos(id) ON DELETE SET NULL,
    fuente VARCHAR(20),
    fecha_validacion TIMESTAMP WITHOUT TIME ZONE,
    fecha_registro TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
);

CREATE TABLE operacion.trazabilidad_infracciones (
    id SERIAL PRIMARY KEY,
    nro_infraccion_fk VARCHAR(20) REFERENCES operacion.infracciones(nro_infraccion) ON DELETE CASCADE,
    id_usuario_fk BIGINT REFERENCES autenticacion.usuarios(id_usuario) ON DELETE SET NULL,
    estado_anterior INT REFERENCES operacion.estado_infraccion(id) ON DELETE SET NULL,
    estado_actual INT REFERENCES operacion.estado_infraccion(id) ON DELETE SET NULL,
    fecha_estado_actual TIMESTAMP WITHOUT TIME ZONE,
    fecha_estado_anterior TIMESTAMP WITHOUT TIME ZONE,
    fecha_registro TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
);

CREATE TABLE operacion.logos_organismo (
    id SERIAL PRIMARY KEY,
    id_organismo_fk INT REFERENCES parametros.organismos(id) ON DELETE SET NULL,
    fecha_inicio DATE,
    fecha_fin DATE,
    url TEXT,
    fecha_registro TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
);

--------SCHEMA SNAPSHOT--------
CREATE SCHEMA snapshot;

CREATE TABLE snapshot.videos (
    id_video SERIAL PRIMARY KEY,
    id_equipo INT REFERENCES operacion.equipos(id) ON DELETE SET NULL,
    fecha_video TIMESTAMP WITHOUT TIME ZONE,
    fecha_captura TIMESTAMP WITHOUT TIME ZONE,
    url TEXT NOT NULL,
    estado BOOLEAN,
    fecha_registro TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
);


/**
 * LOS INSERTS INCIALES
**/
INSERT INTO operacion.equipos(nombre,descripcion,id_organismo)
VALUES('LE3339','EQUIPO DE MALPARQUEO',83);

INSERT INTO parametros.tipos_codigos (id, descripcion) VALUES
(1, 'Codigo de transito de valor completo'),
(2, 'Codigo de transito de mitad del valor');

INSERT INTO parametros.codigo_valor(ano,valor,id_tipo_codigo)
VALUES(2025,1207877,1),(2025,603939,2);

INSERT INTO parametros.codigos_transito(codigo,descripcion,id_tipo_codigo)
VALUES
('C02','ESTACIONAR UN VEHICULO EN SITIOS PROHIBIDOS.',2),
('C29','CONDUCIR UN VEHICULO A VELOCIDAD SUPERIOR A LA MAXIMA PERMITIDA',2),
('C35','NO REALIZAR LA REVISION TECNICOMECANICA Y DE EMISIONES CONTAMINANTES EN LOS SIGUIENTES PLAZOS O CUANDO AUN PORTANDO LOS CERTIFICADOS CORRESPONDIENTES NO CUENTAN CON LAS SIGUIENTES CONDICIONES TECNICOM',2),
('D02','CONDUCIR SIN PORTAR EL SEGURO OBLIGATORIO DE ACCIDENTES DE TRANSITO ORDENADO POR LA LEY. ADEMAS, EL VEHICULO SERA INMOVILIZADO.',1),
('D04','NO DETENERSE ANTE UNA LUZ ROJA O AMARILLA DE SEMAFORO,UNA SEÑAL DE PARE O UN SEMAFORO INTERMITENTE EN ROJO',1);


INSERT into autenticacion.perfiles (nombre,descripcion)
VALUES ('admin','Administradores'),('agente','Agentes de transito');

INSERT INTO autenticacion.usuarios (id_usuario,nombres,apellidos,username,contrasena,id_perfil)
VALUES(-10,'Admin','Admin','admin',md5('12345'),1);