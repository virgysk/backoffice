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
    nombre VARCHAR(255) NOT NULL,
    abreviatura VARCHAR(255) NOT NULL,
    id_municipio INT REFERENCES parametros.municipios(id) ON DELETE CASCADE,
    divipo VARCHAR(20),
    direccion VARCHAR(255),
    telefono VARCHAR(50),
    pagina_web VARCHAR(255),
    email VARCHAR(100),
    horario VARCHAR(255),
    desc_mun_dep TEXT,
    estado BOOLEAN DEFAULT FALSE
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

CREATE TABLE parametros.tipo_documentos (
    id_tipo_doc INTEGER PRIMARY KEY,
    nombre_tipo VARCHAR(50) NOT NULL,
    abreviatura VARCHAR(5) NOT NULL
);

CREATE TABLE parametros.tipo_servicios (
    id_tipo_servicio INTEGER PRIMARY KEY,
    tipo_ser_desc VARCHAR(50) NOT NULL
);

CREATE TABLE parametros.tipo_vehiculos (
    id_tipo_vehiculo INTEGER PRIMARY KEY,
    tipo_veh_desc VARCHAR(50) NOT NULL
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
    id_tipo_fk VARCHAR(4) REFERENCES operacion.tipo_estado_infraccion(id_tipo) ON DELETE CASCADE,
    estado BOOLEAN DEFAULT TRUE
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
    id_agente_fk INT REFERENCES operacion.agentes(id_agente) ON DELETE SET NULL,
    id_equipo INT REFERENCES operacion.equipos(id) ON DELETE SET NULL,
    codigo_transito_fk VARCHAR(4) REFERENCES parametros.codigos_transito(codigo) ON DELETE SET NULL,
    fuente VARCHAR(20),
    fecha_validacion TIMESTAMP WITHOUT TIME ZONE,
    url_video TEXT,
    url_imagen TEXT,
    url_zoom TEXT,
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
    fecha_modificacion TIMESTAMP WITHOUT TIME ZONE,
    url TEXT NOT NULL,
    id_estado_fk INT REFERENCES operacion.estado_infraccion(id) ON DELETE SET NULL,
    usuario_modificacion BIGINT REFERENCES autenticacion.usuarios(id_usuario) ON DELETE SET NULL,
    fecha_registro TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
);


/**
 * LOS INSERTS INCIALES
**/

insert into operacion.tipo_estado_infraccion(id_tipo,descripcion)
values('VMPP','VIDEO MALPARQUE APROBACION'),('VMPR','VIDEO MALPARQUEO RECHAZO'),('INAC','INFRACCION ACTIVA');

insert into operacion.estado_infraccion(abreviatura,descripcion,id_tipo_fk)
values('VIDEO CARGADO','UNA VEZ EL VIDEO SEA CARGADO','VMPP'),
('VIDEO APROBADO','UNA VEZ EL VIDEO SEA APROBADO','VMPP'),
('INFRACCION CARGADA MP','INDICA QUE ES UNA INFRACCION CREADA DESDE MALPARQUEO','INAC');

----PARA RECHAZO DEL VIDEO----
insert into operacion.estado_infraccion(abreviatura,descripcion,orden,id_tipo_fk)
values('VIDEO CON CORTA DURACIÓN','EL VIDEO APENAS TIENE POCOS SEGUNDOS',1,'VMPR'),
('VIDEO CON CAPTURA EN MOVIMIENTO','VIDEO CON CAPTURA EN MOVIMIENTO',2,'VMPR'),
('VIDEO CON OBSTRUCCIÓN DE VEHÍCULO','VIDEO CON OBSTRUCCIÓN DE VEHÍCULO',3,'VMPR'),
('VIDEO CON PLACA EN MAL ESTADO','VIDEO CON PLACA EN MAL ESTADO',4,'VMPR'),
('VIDEO CON PLACA CUBIERTA','VIDEO CON PLACA CUBIERTA',5,'VMPR'),
('VIDEO NO LEGIBLE O CON POCA ILUMINACION','VIDEO NO LEGIBLE O CON POCA ILUMINACION',6,'VMPR'),
('VIDEO REPETIDO','EL VIDEO SE ENCUENTRA REPETIDO',7,'VMPR'),
('VIDEO CON INFRACCION - INGRESO/SALIDA DE PASAJEROS','VIDEO CON INFRACCION - INGRESO/SALIDA DE PASAJEROS',8,'VMPR'),
('VIDEO CON SEMAFORO EN ROJO','VIDEO CON SEMAFORO EN ROJO',9,'VMPR'),
('VIDEO BORROSO','EL VIDEO ESTA BORROSO O DE BAJA CALIDAD',10,'VMPR'),
('VIDEO CON INFRACCION - VEHICULO SE MUEVE DEL SITIO','VIDEO CON INFRACCION - VEHICULO SE MUEVE DEL SITIO',11,'VMPR'),
('OTROS','OTROS',12,'VMPR'),
('VIDEO SIN INFRACCION','EL VIDEO NO REGISTRA INFRACCION',13,'VMPR'),
('VIDEO DISTORSIONADO','EL VIDEO ESTA DISTORCIONADO',14,'VMPR'),
('VIDEO DE PRUEBA','VIDEO DE PRUEBA',15,'VMPR'),
('VIDEO CON REPRODUCCIÓN ATÍPICA','EL VIDEO ES EN CAMARA LENTO O VA MUY RAPIDO',16,'VMPR'),
('VIDEO CON POCA ILUMINACION','EL VIDEO TIENE POCA ILUMINACION',17,'VMPR');


INSERT INTO operacion.equipos(nombre,descripcion,id_organismo)
VALUES('LE3339','EQUIPO DE MALPARQUEO',83);

INSERT INTO parametros.tipos_codigos (id, descripcion) VALUES
(1, 'Codigo de transito de valor completo'),
(2, 'Codigo de transito de mitad del valor'),
(3, 'Valor cero fuente SOAT RTM');




INSERT INTO parametros.codigo_valor(ano,valor,id_tipo_codigo)
VALUES(2025,1207877,1),(2025,603939,2);

INSERT INTO parametros.codigos_transito(codigo,descripcion,id_tipo_codigo)
VALUES
('C02','ESTACIONAR UN VEHICULO EN SITIOS PROHIBIDOS.',2),
('C29','CONDUCIR UN VEHICULO A VELOCIDAD SUPERIOR A LA MAXIMA PERMITIDA',2),
('C35','NO REALIZAR LA REVISION TECNICOMECANICA Y DE EMISIONES CONTAMINANTES EN LOS SIGUIENTES PLAZOS O CUANDO AUN PORTANDO LOS CERTIFICADOS CORRESPONDIENTES NO CUENTAN CON LAS SIGUIENTES CONDICIONES TECNICOM',2),
('D02','CONDUCIR SIN PORTAR EL SEGURO OBLIGATORIO DE ACCIDENTES DE TRANSITO ORDENADO POR LA LEY. ADEMAS, EL VEHICULO SERA INMOVILIZADO.',1),
('D04','NO DETENERSE ANTE UNA LUZ ROJA O AMARILLA DE SEMAFORO,UNA SEÑAL DE PARE O UN SEMAFORO INTERMITENTE EN ROJO',1),
('SM0','FUENTE POSIBLE SOAT Y/O RTM',3);


INSERT into autenticacion.perfiles (nombre,descripcion)
VALUES ('admin','Administradores'),('agente','Agentes de transito');

INSERT INTO autenticacion.usuarios (id_usuario,nombres,apellidos,username,contrasena,id_perfil)
VALUES(-10,'Admin','Admin','admin',md5('12345'),1);


update organismos o set nombre = 'SECRETARIA DE TRANSITO Y TRANSPORTE DE VALLEDUPAR'
,direccion = 'Calle 16a No.10-24 Edificio la casa en el aire - Centro'
,telefono = '3241000616'
,email = 'atencionusuariotransito@valledupar-cesar.gov.co'
,horario = 'Lunes a Viernes 7:30 am 4:30 pm'
,desc_mun_dep = 'Valledupar - Cesar'
,estado = true
where o.id = 83;