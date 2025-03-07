-- Database: backoffice

-- DROP DATABASE "backoffice";

CREATE DATABASE "backoffice"
    WITH
    OWNER = dtech_admin
    ENCODING = 'UTF8'
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

--------SCHEMA SNAPSHOT--------
CREATE SCHEMA snapshot;

CREATE TABLE snapshot.videos (
    id_video VARCHAR(50) PRIMARY KEY,
    fecha_captura timestamp without time zone,
    url TEXT NOT NULL,
    estado BOOLEAN,
    fecha_registro timestamp without time zone DEFAULT NOW()
);
