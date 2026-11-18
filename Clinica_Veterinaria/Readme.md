
Modelo relacional
cliente(cedula PK, nombre, telefono) y mascota(codigo PK, nombre, especie ENUM, edad, cedula_cliente FK).
Relación 1:N: un cliente tiene varias mascotas, cada mascota pertenece a un solo cliente. Los datos del dueño no se repiten en mascota, así se realiza la normalizacion
CHECK (edad BETWEEN 18 AND 60) y checks de campos no vacíos.
1. Ejecutar el script
   En MySQL Workbench (como administrador), abra una pestaña y ejecute primero (no lo guarde):
   SET @pw_definer = 'clave1';  (yo coloqué 123)
   SET @pw_app     = 'clave2';  (yo coloqué 1234#)
   En la misma pestaña abra y ejecute database/01_veterinaria.sql (crea BD, tablas, usuarios, 7 procedimientos y GRANTs).
   Conéctese como vet_app y ejecute database/02_datos_ejemplo.sql (datos de ejemplo vía procedimientos)
2. Variables de entorno (IntelliJ → Run → Edit Configurations → Environment variables)
   VET_DB_URL=jdbc:mysql://localhost:3306/veterinaria?serverTimezone=UTC
   VET_DB_USER=vet_app
   VET_DB_PASSWORD=<la clave local de vet_app>  (en mi caso yo coloqué 1234)
   como en el .env.example no se cargan, se ocupan realizar estos pasos

3. Abrir la aplicación
   Abrir el proyecto con Maven en IntelliJ y ejecutar main o maven

4. Pruebas de seguridad (database/03_pruebas_seguridad.sql conectado como vet_app)
   CALL sp_listar_mascotas(); - funciona, solo tiene EXECUTE
   SELECT * FROM mascota; - ERROR 1142: SELECT command denied (sin privilegios directos sobre tablas)
   Dueño inexistente (CALL sp_insertar_mascota(...,'000000000')). error 1452 por FK




