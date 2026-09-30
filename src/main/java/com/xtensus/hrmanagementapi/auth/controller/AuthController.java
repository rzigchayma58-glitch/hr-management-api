package com.xtensus.hrmanagementapi.auth.controller;

import com.xtensus.hrmanagementapi.auth.dto.AuthenticatedUserResponse;
import com.xtensus.hrmanagementapi.auth.dto.LoginRequest;
import com.xtensus.hrmanagementapi.auth.dto.LoginResponse;
import com.xtensus.hrmanagementapi.auth.service.AuthenticationService;
import com.xtensus.hrmanagementapi.domain.entity.User;
import com.xtensus.hrmanagementapi.domain.enums.RoleType;
import com.xtensus.hrmanagementapi.domain.enums.UserStatus;
import com.xtensus.hrmanagementapi.repository.UserRepository;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthenticationService authenticationService;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public AuthController(AuthenticationService authenticationService, 
                         UserRepository userRepository,
                         PasswordEncoder passwordEncoder) {
        this.authenticationService = authenticationService;
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(authenticationService.login(request));
    }

    @GetMapping("/me")
    public ResponseEntity<AuthenticatedUserResponse> me() {
        return ResponseEntity.ok(authenticationService.me());
    }
    
    @PostMapping("/register")
    public ResponseEntity<Map<String, Object>> register(@RequestBody Map<String, String> request) {
        Map<String, Object> response = new HashMap<>();
        try {
            // Créer un nouvel utilisateur
            User user = new User();
            user.setUsername(request.get("username") != null ? request.get("username") : request.get("email").split("@")[0]);
            user.setEmail(request.get("email"));
            user.setFirstName(request.get("firstName") != null ? request.get("firstName") : "Utilisateur");
            user.setLastName(request.get("lastName") != null ? request.get("lastName") : "Test");
            user.setPasswordHash(passwordEncoder.encode(request.get("password")));
            
            // Définir le rôle selon la sélection
            String role = request.get("role");
            if ("Responsable".equals(role) || "MANAGER".equals(role)) {
                user.setRole(RoleType.MANAGER);
            } else {
                user.setRole(RoleType.EMPLOYEE);
            }
            
            user.setStatus(UserStatus.ACTIVE);
            user.setEnabled(true);
            user.setCreatedAt(java.time.LocalDateTime.now());
            user.setUpdatedAt(java.time.LocalDateTime.now());
            
            // Vérifier si l'email existe déjà
            if (userRepository.findByEmail(request.get("email")).isPresent()) {
                response.put("success", false);
                response.put("error", "Un compte avec cet email existe déjà");
                return ResponseEntity.badRequest().body(response);
            }
            
            userRepository.save(user);
            
            // Connecter automatiquement après création
            LoginRequest loginRequest = new LoginRequest();
            loginRequest.setUsernameOrEmail(user.getUsername());
            loginRequest.setPassword(request.get("password"));
            
            LoginResponse loginResponse = authenticationService.login(loginRequest);
            
            response.put("success", true);
            response.put("message", "Compte créé avec succès !");
            response.put("token", loginResponse.getAccessToken());
            response.put("user", loginResponse.getUser());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("error", "Erreur lors de la création : " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
    
    @PostMapping("/create-test-user")
    public ResponseEntity<Map<String, Object>> createTestUser() {
        Map<String, Object> response = new HashMap<>();
        try {
            // Vérifier si l'utilisateur existe déjà
            if (userRepository.findByEmail("admin@test.com").isPresent()) {
                response.put("success", true);
                response.put("message", "Utilisateur admin existe déjà dans la base de données !");
                response.put("credentials", Map.of("usernameOrEmail", "admin", "password", "password123"));
                response.put("loginUrl", "/api/auth/login");
                return ResponseEntity.ok(response);
            }
            
            // Créer l'utilisateur directement dans la base
            User user = new User();
            user.setUsername("admin");
            user.setEmail("admin@test.com");
            user.setFirstName("Admin");
            user.setLastName("Test");
            user.setPasswordHash(passwordEncoder.encode("password123"));
            user.setRole(RoleType.ADMIN);
            user.setStatus(UserStatus.ACTIVE);
            user.setEnabled(true);
            user.setCreatedAt(java.time.LocalDateTime.now());
            user.setUpdatedAt(java.time.LocalDateTime.now());
            
            userRepository.save(user);
            
            response.put("success", true);
            response.put("message", "✅ Utilisateur admin créé avec succès dans la base de données !");
            response.put("credentials", Map.of("usernameOrEmail", "admin", "password", "password123"));
            response.put("loginUrl", "/api/auth/login");
            response.put("testLogin", "Vous pouvez maintenant tester le login avec ces identifiants");
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("error", "Erreur lors de la création: " + e.getMessage());
            return ResponseEntity.ok(response);
        }
    }
}