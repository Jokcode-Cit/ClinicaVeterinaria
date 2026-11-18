package examen.veterinaria.repository;

import examen.veterinaria.model.Especie;
import examen.veterinaria.model.Mascota;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class RepositorioMascotaMySQL implements RepositorioMascota {
    private final BaseDatos bd;

    public RepositorioMascotaMySQL(String url, String usuario, String clave) { bd = new BaseDatos(url, usuario, clave); }

    private static Mascota mapear(ResultSet rs) throws SQLException {
        return new Mascota(rs.getString("codigo"), rs.getString("nombre"),
                Especie.valueOf(rs.getString("especie")), rs.getInt("edad"), rs.getString("cedula_cliente"));
    }

    @Override public List<Mascota> cargarTodos() {
        List<Mascota> lista = new ArrayList<>();
        try (Connection con = bd.abrir();
             CallableStatement cs = con.prepareCall("{CALL sp_listar_mascotas()}");
             ResultSet rs = cs.executeQuery()) {
            while (rs.next()) lista.add(mapear(rs));
            return lista;
        } catch (SQLException e) { throw BaseDatos.traducir(e, "cargar las mascotas"); }
    }

    @Override public List<String> listarConDueno() {
        List<String> filas = new ArrayList<>();
        try (Connection con = bd.abrir();
             CallableStatement cs = con.prepareCall("{CALL sp_listar_mascotas_con_dueno()}");
             ResultSet rs = cs.executeQuery()) {
            while (rs.next()) filas.add(mapear(rs) + " | Cliente: " + rs.getString("nombre_cliente"));
            return filas;
        } catch (SQLException e) { throw BaseDatos.traducir(e, "listar las mascotas con su dueño"); }
    }

    @Override public void insertar(Mascota m) {
        try (Connection con = bd.abrir();
             CallableStatement cs = con.prepareCall("{CALL sp_insertar_mascota(?,?,?,?,?)}")) {
            asignar(cs, m); cs.execute();
        } catch (SQLException e) { throw BaseDatos.traducir(e, "guardar la mascota"); }
    }

    @Override public void actualizar(Mascota m) {
        try (Connection con = bd.abrir();
             CallableStatement cs = con.prepareCall("{CALL sp_actualizar_mascota(?,?,?,?,?)}")) {
            asignar(cs, m); cs.execute();
        } catch (SQLException e) { throw BaseDatos.traducir(e, "actualizar la mascota"); }
    }

    @Override public void eliminar(String codigo) {
        try (Connection con = bd.abrir();
             CallableStatement cs = con.prepareCall("{CALL sp_eliminar_mascota(?)}")) {
            cs.setString(1, codigo.trim());
            cs.execute();
        } catch (SQLException e) { throw BaseDatos.traducir(e, "eliminar la mascota"); }
    }

    private static void asignar(CallableStatement cs, Mascota m) throws SQLException {
        cs.setString(1, m.getCodigo());
        cs.setString(2, m.getNombre());
        cs.setString(3, m.getEspecie().name());
        cs.setInt(4, m.getEdad());
        cs.setString(5, m.getCedulaCliente());
    }
}
