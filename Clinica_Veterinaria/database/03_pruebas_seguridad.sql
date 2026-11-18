
USE veterinaria;

CALL sp_listar_mascotas();


SELECT * FROM mascota;

INSERT INTO cliente VALUES ('999', 'Hacker', '000');


CALL sp_insertar_mascota('M99', 'Fantasma', 'GATO', 20, '000000000');


CALL sp_insertar_mascota('M98', 'Viejo', 'PERRO', 5, '101110111');


CALL sp_insertar_cliente('101110111', 'Otro', '111');


CALL sp_eliminar_mascota('NOEXISTE');
