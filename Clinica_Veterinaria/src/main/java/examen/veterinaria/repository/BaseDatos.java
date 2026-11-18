package examen.veterinaria.repository;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

final class BaseDatos {
    private final String url, usuario, clave;

    BaseDatos(String url, String usuario, String clave) {
        if (url == null || url.isBlank() || usuario == null || usuario.isBlank() || clave == null)
            throw new IllegalStateException("Configure VET_DB_URL, VET_DB_USER y VET_DB_PASSWORD.");
        this.url = url; this.usuario = usuario; this.clave = clave;
    }

    Connection abrir() throws SQLException { return DriverManager.getConnection(url, usuario, clave); }

    static RuntimeException traducir(SQLException e, String operacion) {
        switch (e.getErrorCode()) {
            case 1062: return new IllegalArgumentException("Ya existe un registro con ese identificador (cédula o código).");
            case 1452: return new IllegalArgumentException("Registre primero al cliente dueño de la mascota.");
            case 3819: return new IllegalArgumentException("Los datos incumplen una restricción (la edad debe estar entre 18 y 60).");
            case 1644: return new IllegalArgumentException(e.getMessage());
            default:   return new PersistenciaException("Error de base de datos al " + operacion + ": " + e.getMessage(), e);
        }
    }
}
