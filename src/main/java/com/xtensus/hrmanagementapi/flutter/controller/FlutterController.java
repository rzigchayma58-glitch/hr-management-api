package com.xtensus.hrmanagementapi.flutter.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/flutter")
public class FlutterController {

    @Autowired
    private DataSource dataSource;

    @GetMapping("/test")
    public ResponseEntity<Map<String, Object>> test() {
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Flutter connection OK !");
        response.put("timestamp", LocalDateTime.now());
        response.put("port", 3000);
        return ResponseEntity.ok(response);
    }

    // 📝 CRÉER UNE DEMANDE DE CONGÉ (SIMPLE)
    @PostMapping("/demande-conge")
    public ResponseEntity<Map<String, Object>> createDemandeConge(@RequestBody Map<String, Object> request) {
        Map<String, Object> response = new HashMap<>();
        
        try (Connection conn = dataSource.getConnection()) {
            // Insérer une demande simple dans conge_demandes
            String sql = "INSERT INTO conge_demandes (employee_id, conge_type_id, conge_demande_nature) VALUES (?, ?, ?)";
            
            PreparedStatement stmt = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS);
            stmt.setInt(1, (Integer) request.get("employeeId"));  // ID de l'employé
            stmt.setInt(2, (Integer) request.get("typeId"));      // Type de congé
            stmt.setString(3, (String) request.get("reason"));   // Raison/commentaire
            
            int affectedRows = stmt.executeUpdate();
            
            if (affectedRows > 0) {
                ResultSet generatedKeys = stmt.getGeneratedKeys();
                if (generatedKeys.next()) {
                    response.put("success", true);
                    response.put("message", "Demande de congé créée avec succès !");
                    response.put("id", generatedKeys.getInt(1));
                }
            } else {
                response.put("success", false);
                response.put("error", "Impossible de créer la demande");
            }
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("error", "Erreur: " + e.getMessage());
            e.printStackTrace();
        }
        
        return ResponseEntity.ok(response);
    }

    // 📊 HISTORIQUE DES DEMANDES (SIMPLE)
    @GetMapping("/historique/{employeeId}")
    public ResponseEntity<List<Map<String, Object>>> getHistorique(@PathVariable Integer employeeId) {
        List<Map<String, Object>> historique = new ArrayList<>();
        
        try (Connection conn = dataSource.getConnection()) {
            // Récupérer l'historique avec les types de congé
            String sql = "SELECT cd.id, cd.employee_id, cd.conge_type_id, ct.nom as type_nom, cd.conge_demande_nature as reason " +
                        "FROM conge_demandes cd " +
                        "LEFT JOIN conge_types ct ON cd.conge_type_id = ct.id " +
                        "WHERE cd.employee_id = ? " +
                        "ORDER BY cd.id DESC";
            
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, employeeId);
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> demande = new HashMap<>();
                demande.put("id", rs.getInt("id"));
                demande.put("employeeId", rs.getInt("employee_id"));
                demande.put("typeId", rs.getInt("conge_type_id"));
                demande.put("typeName", rs.getString("type_nom") != null ? rs.getString("type_nom") : "Non défini");
                demande.put("reason", rs.getString("reason") != null ? rs.getString("reason") : "Pas de commentaire");
                demande.put("status", "EN ATTENTE"); // Statut par défaut
                historique.add(demande);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("Erreur historique: " + e.getMessage());
        }
        
        return ResponseEntity.ok(historique);
    }

    // 📋 TYPES DE CONGÉ DISPONIBLES
    @GetMapping("/types-conge")
    public ResponseEntity<List<Map<String, Object>>> getTypesConge() {
        List<Map<String, Object>> types = new ArrayList<>();
        
        try (Connection conn = dataSource.getConnection()) {
            String sql = "SELECT id, nom, description FROM conge_types WHERE actif = 1";
            
            PreparedStatement stmt = conn.prepareStatement(sql);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> type = new HashMap<>();
                type.put("id", rs.getInt("id"));
                type.put("name", rs.getString("nom"));
                type.put("description", rs.getString("description") != null ? rs.getString("description") : "");
                types.add(type);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return ResponseEntity.ok(types);
    }
}