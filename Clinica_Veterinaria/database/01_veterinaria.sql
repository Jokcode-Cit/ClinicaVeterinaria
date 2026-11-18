CREATE DATABASE IF NOT EXISTS veterinaria
  CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE veterinaria;

CREATE TABLE IF NOT EXISTS cliente (
                                       cedula   VARCHAR(20) NOT NULL,
    nombre   VARCHAR(80) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    PRIMARY KEY (cedula),
    CONSTRAINT ck_cliente_cedula   CHECK (TRIM(cedula)   <> ''),
    CONSTRAINT ck_cliente_nombre   CHECK (TRIM(nombre)   <> ''),
    CONSTRAINT ck_cliente_telefono CHECK (TRIM(telefono) <> '')
    ) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS mascota (
                                       codigo         VARCHAR(15) NOT NULL,
    nombre         VARCHAR(80) NOT NULL,
    especie        ENUM('PERRO','GATO','OTRO') NOT NULL,
    edad           INT NOT NULL,
    cedula_cliente VARCHAR(20) NOT NULL,
    PRIMARY KEY (codigo),
    CONSTRAINT fk_mascota_cliente FOREIGN KEY (cedula_cliente)
    REFERENCES cliente (cedula)
    ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT ck_mascota_edad   CHECK (edad BETWEEN 18 AND 60),
    CONSTRAINT ck_mascota_codigo CHECK (TRIM(codigo) <> ''),
    CONSTRAINT ck_mascota_nombre CHECK (TRIM(nombre) <> '')
    ) ENGINE=InnoDB;

SET @s = CONCAT("CREATE USER IF NOT EXISTS 'vet_definer'@'localhost' IDENTIFIED BY ", QUOTE(@pw_definer));
PREPARE st FROM @s; EXECUTE st; DEALLOCATE PREPARE st;
SET @s = CONCAT("CREATE USER IF NOT EXISTS 'vet_app'@'localhost' IDENTIFIED BY ", QUOTE(@pw_app));
PREPARE st FROM @s; EXECUTE st; DEALLOCATE PREPARE st;
SET @pw_definer = NULL; SET @pw_app = NULL; SET @s = NULL;


GRANT SELECT, INSERT ON veterinaria.cliente TO 'vet_definer'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON veterinaria.mascota TO 'vet_definer'@'localhost';

DROP PROCEDURE IF EXISTS sp_listar_clientes;
DROP PROCEDURE IF EXISTS sp_insertar_cliente;
DROP PROCEDURE IF EXISTS sp_listar_mascotas;
DROP PROCEDURE IF EXISTS sp_insertar_mascota;
DROP PROCEDURE IF EXISTS sp_actualizar_mascota;
DROP PROCEDURE IF EXISTS sp_eliminar_mascota;
DROP PROCEDURE IF EXISTS sp_listar_mascotas_con_dueno;

DELIMITER $$

CREATE DEFINER='vet_definer'@'localhost' PROCEDURE sp_listar_clientes()
  SQL SECURITY DEFINER
BEGIN
SELECT cedula, nombre, telefono FROM cliente ORDER BY cedula;
END$$

CREATE DEFINER='vet_definer'@'localhost'
PROCEDURE sp_insertar_cliente(IN p_cedula VARCHAR(20), IN p_nombre VARCHAR(80), IN p_telefono VARCHAR(20))
  SQL SECURITY DEFINER
BEGIN

INSERT INTO cliente (cedula, nombre, telefono) VALUES (p_cedula, p_nombre, p_telefono);
END$$

CREATE DEFINER='vet_definer'@'localhost' PROCEDURE sp_listar_mascotas()
  SQL SECURITY DEFINER
BEGIN
SELECT codigo, nombre, especie, edad, cedula_cliente FROM mascota ORDER BY codigo;
END$$

CREATE DEFINER='vet_definer'@'localhost'
PROCEDURE sp_insertar_mascota(IN p_codigo VARCHAR(15), IN p_nombre VARCHAR(80), IN p_especie VARCHAR(10),
                              IN p_edad INT, IN p_cedula_cliente VARCHAR(20))
  SQL SECURITY DEFINER
BEGIN

INSERT INTO mascota (codigo, nombre, especie, edad, cedula_cliente)
VALUES (p_codigo, p_nombre, p_especie, p_edad, p_cedula_cliente);
END$$

CREATE DEFINER='vet_definer'@'localhost'
PROCEDURE sp_actualizar_mascota(IN p_codigo VARCHAR(15), IN p_nombre VARCHAR(80), IN p_especie VARCHAR(10),
                                IN p_edad INT, IN p_cedula_cliente VARCHAR(20))
  SQL SECURITY DEFINER
BEGIN
  IF (SELECT COUNT(*) FROM mascota WHERE codigo = p_codigo) = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No existe la mascota que desea actualizar.';
END IF;
UPDATE mascota
SET nombre = p_nombre, especie = p_especie, edad = p_edad, cedula_cliente = p_cedula_cliente
WHERE codigo = p_codigo;
END$$

CREATE DEFINER='vet_definer'@'localhost' PROCEDURE sp_eliminar_mascota(IN p_codigo VARCHAR(15))
  SQL SECURITY DEFINER
BEGIN
  IF (SELECT COUNT(*) FROM mascota WHERE codigo = p_codigo) = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No existe la mascota que desea eliminar.';
END IF;
DELETE FROM mascota WHERE codigo = p_codigo;
END$$

CREATE DEFINER='vet_definer'@'localhost' PROCEDURE sp_listar_mascotas_con_dueno()
  SQL SECURITY DEFINER
BEGIN
SELECT m.codigo, m.nombre, m.especie, m.edad, m.cedula_cliente, c.nombre AS nombre_cliente
FROM mascota m
         INNER JOIN cliente c ON c.cedula = m.cedula_cliente
ORDER BY m.codigo;
END$$

DELIMITER ;


GRANT EXECUTE ON PROCEDURE veterinaria.sp_listar_clientes          TO 'vet_app'@'localhost';
GRANT EXECUTE ON PROCEDURE veterinaria.sp_insertar_cliente         TO 'vet_app'@'localhost';
GRANT EXECUTE ON PROCEDURE veterinaria.sp_listar_mascotas          TO 'vet_app'@'localhost';
GRANT EXECUTE ON PROCEDURE veterinaria.sp_insertar_mascota         TO 'vet_app'@'localhost';
GRANT EXECUTE ON PROCEDURE veterinaria.sp_actualizar_mascota       TO 'vet_app'@'localhost';
GRANT EXECUTE ON PROCEDURE veterinaria.sp_eliminar_mascota         TO 'vet_app'@'localhost';
GRANT EXECUTE ON PROCEDURE veterinaria.sp_listar_mascotas_con_dueno TO 'vet_app'@'localhost';
FLUSH PRIVILEGES;