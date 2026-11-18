package examen.veterinaria.repository;

import examen.veterinaria.model.Cliente;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RepositorioClienteMySQL implements RepositorioCliente {
    private final BaseDatos bd;

    public RepositorioClienteMySQL(String url, String usuario, String clave) { bd = new BaseDatos(url, usuario, clave); }

    @Override public List<Cliente> cargarTodos() {
        List<Cliente> lista = new ArrayList<>();
        try (Connection con = bd.abrir();
             CallableStatement cs = con.prepareCall("{CALL sp_listar_clientes()}");
             ResultSet rs = cs.executeQuery()) {
            while (rs.next())
                lista.add(new Cliente(rs.getString("cedula"), rs.getString("nombre"), rs.getString("telefono")));
            return lista;
        } catch (SQLException e) { throw BaseDatos.traducir(e, "cargar los clientes"); }
    }

    @Override public void insertar(Cliente c) {
        try (Connection con = bd.abrir();
             CallableStatement cs = con.prepareCall("{CALL sp_insertar_cliente(?,?,?)}")) {
            cs.setString(1, c.getCedula());
            cs.setString(2, c.getNombre());
            cs.setString(3, c.getTelefono());
            cs.execute();
        } catch (SQLException e) { throw BaseDatos.traducir(e, "guardar el cliente"); }
    }
}
