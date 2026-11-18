package examen.veterinaria;
import examen.veterinaria.controller.VeterinariaController;
import examen.veterinaria.repository.*;
import examen.veterinaria.service.VeterinariaService;
import examen.veterinaria.view.VentanaVeterinaria;
import javax.swing.JOptionPane;
import javax.swing.SwingUtilities;

public class Main {
    public static void main(String[] args) {
        String url = System.getenv("VET_DB_URL");
        String usuario = System.getenv("VET_DB_USER");
        String clave = System.getenv("VET_DB_PASSWORD");
        if (url == null || usuario == null || clave == null) {
            JOptionPane.showMessageDialog(null,
                    "Configure las variables de entorno VET_DB_URL, VET_DB_USER y VET_DB_PASSWORD.",
                    "Configuración faltante", JOptionPane.ERROR_MESSAGE);
            return;
        }
        SwingUtilities.invokeLater(() -> {
            RepositorioCliente clientes = new RepositorioClienteMySQL(url, usuario, clave);
            RepositorioMascota mascotas = new RepositorioMascotaMySQL(url, usuario, clave);
            VeterinariaService service = new VeterinariaService(clientes, mascotas);
            new VentanaVeterinaria(new VeterinariaController(service)).setVisible(true);
        });
    }
}
