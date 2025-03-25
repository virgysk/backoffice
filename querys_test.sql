ALTER TABLE operacion.infracciones
ADD COLUMN codigo_transito_fk VARCHAR NULL,
ADD CONSTRAINT fk_codigo_transito
FOREIGN KEY (codigo_transito_fk) REFERENCES parametros.codigos_transito(codigo);

select * from operacion.infracciones

update operacion.infracciones set codigo_transito_fk = 'C02'

ALTER TABLE operacion.infracciones 
ALTER COLUMN codigo_transito_fk SET NOT NULL;