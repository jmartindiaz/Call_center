-- Consultas para Analisis Exploratorio

SELECT *
FROM call_center_for_sql
WHERE call_id =33116;

-- cantidad de registros
select count(*)
from call_center_for_sql; 


-- cambio el nombre de la columna vru.line
ALTER TABLE call_center.call_center_for_sql 
CHANGE `vru.line` `vru_line` varchar(50) 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_0900_ai_ci NULL;

-- pantallazo de la cantidad de registros que hay por vru_line
select vru_line , count(*) as cant_registros
from call_center_for_sql
group by vru_line
order by cant_registros desc; 

-- como vemos, no tenemos un campo que sea PRIMARY KEY, 'vru_line' tiene valores repetidos, 'call_id' tambien.

-- es por eso, que vamos a crear un campo como combinacion de otros para poder definir esta PRIMARY KEY que necesitamos
-- y así tambien, optimizar las querys que realizaremos para nuestro exploratory analysis.

-- antes de realizar esto, crearemos una tabla VIEW en la que figurara esta nueva columna PK

CREATE VIEW callcenter_vw
(id,
vru_line,
call_id,
customer_id,
priority,
`type`,
`date`,
vru_entry,
vru_exit,
vru_time,
q_start,
q_exit,
q_time,
outcome,
ser_start,
ser_exit,
ser_time,
server,
startdate
)
AS
SELECT
concat(vru_line, '-',call_id),
vru_line,
call_id,
customer_id,
priority,
`type`,
`date`,
vru_entry,
vru_exit,
vru_time,
q_start,
q_exit,
q_time,
outcome,
ser_start,
ser_exit,
ser_time,
server,
startdate
FROM call_center_for_sql;

-- Vista creada
select *
from callcenter_vw;

-- ¿En que porcentajes del total de registros se brindo servicio, se colgo la llamada o se ignoro lo sucedido?
select outcome, count(*) as cant_reg, 
count(*)*100/(select count(*) from callcenter_vw) as frec_rel
from callcenter_vw cv
group by outcome
order by frec_rel desc;

-- ¿Que relacion pueden tener los tiempos de VRU, de cola y de servicio con las llamadas que colgaron (HANG)?
select id, outcome, customer_id, priority, `type`, (vru_time/60) as vru_time_minutes , (q_time/60) as q_time_minutes , (ser_time/60) as ser_time_minutes 
from callcenter_vw cv
where outcome = 'HANG'
order by q_time_minutes desc;

select outcome, avg(q_time) as avg_time_queue
from callcenter_vw cv 
group by outcome
order by avg_time_queue desc ;
