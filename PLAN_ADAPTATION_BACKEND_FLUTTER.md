# 🎯 Plan d'Adaptation Backend pour Application Flutter XCongés

## 📊 Situation Actuelle vs Besoins

**Backend existant** : API Spring Boot HR Management (60% de couverture fonctionnelle)  
**Frontend cible** : Application Flutter XCongés (spécifications détaillées fournies)  
**Écarts majeurs identifiés** : Format JSON, validations métier, gestion fichiers, notifications  

---

## 🚩 **PHASE 1 - CORRECTIONS CRITIQUES (Sprint 1-2)**

### 1.1 📱 **Adaptation Format LoginResponse**

**Problème** : Format JWT incompatible avec Flutter
```java
// ❌ ACTUEL
{
  "accessToken": "...",
  "tokenType": "Bearer",  
  "user": { "role": "EMPLOYEE" }
}

// ✅ REQUIS FLUTTER  
{
  "success": true,
  "data": {
    "token": "...",
    "refreshToken": "...",
    "user": {
      "id": "string",
      "employeeId": "string", 
      "department": "string",
      "role": "employee|manager|admin"
    }
  }
}
```

**Actions** :
1. **Modifier `LoginResponse.java`** :
```java
@Data
public class LoginResponse {
    private boolean success;
    private LoginData data;
    
    @Data
    public static class LoginData {
        private String token;
        private String refreshToken; 
        private UserInfo user;
    }
    
    @Data
    public static class UserInfo {
        private String id;
        private String firstName;
        private String lastName;
        private String email;
        private String employeeId;
        private String department;
        private String role;
    }
}
```

2. **Ajouter endpoint refresh token** :
```java
@PostMapping("/refresh")
public ResponseEntity<LoginResponse> refresh(@RequestBody RefreshRequest request) {
    return ResponseEntity.ok(authService.refreshToken(request.getRefreshToken()));
}
```

### 1.2 🔧 **Normaliser les Endpoints (Suppression Doublons)**

**Problème** : Duplication d'endpoints français/anglais avec logiques différentes

**Actions** :
1. **Supprimer les controllers doublons** (`CongeDemandeController`, `CertificatMedicalController`)
2. **Unifier dans `LeaveRequestController`** avec support i18n
3. **Mapping unique** : `/api/leave-requests` (avec headers Accept-Language)

### 1.3 ⏱️ **Implémenter Validations Métier Critiques**

**Créer annotations de validation** :
```java
@Target({ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Constraint(validatedBy = AdvanceNoticeValidator.class)
public @interface ValidAdvanceNotice {
    String message() default "Délai de préavis insuffisant";
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};
}

@Component
public class AdvanceNoticeValidator implements ConstraintValidator<ValidAdvanceNotice, LeaveRequestCreateRequest> {
    @Override
    public boolean isValid(LeaveRequestCreateRequest request, ConstraintValidatorContext context) {
        LocalDateTime now = LocalDateTime.now();
        long hoursUntilStart = ChronoUnit.HOURS.between(now, request.getStartDate());
        
        // Validation 48h pour absences, 72h pour congés
        int minHours = "absence".equals(request.getType()) ? 48 : 72;
        return hoursUntilStart >= minHours;
    }
}
```

**Appliquer sur DTO** :
```java
@ValidAdvanceNotice
public class LeaveRequestCreateRequest {
    @NotNull private String type; // "leave" ou "absence"
    @NotNull private LocalDateTime startDate;
    // ...
}
```

---

## 📁 **PHASE 2 - GESTION FICHIERS ET ABSENCES COURTES (Sprint 3-4)**

### 2.1 📎 **Système Upload Multi-Fichiers**

**Créer controller générique** :
```java
@RestController
@RequestMapping("/api/files")
public class FileController {
    
    @PostMapping("/upload")
    public ResponseEntity<FileUploadResponse> upload(@RequestParam("file") MultipartFile file) {
        // Validation : 5MB max, types autorisés
        FileMetadata metadata = fileService.upload(file);
        return ResponseEntity.ok(FileUploadResponse.success(metadata));
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Resource> download(@PathVariable String id) {
        // Vérification autorisation + téléchargement sécurisé
        return fileService.download(id);
    }
}
```

**Format réponse Flutter** :
```java
@Data
public class FileUploadResponse {
    private boolean success;
    private FileData data;
    
    @Data
    public static class FileData {
        private String id;
        private String name;
        private String originalName;
        private long size;
        private String type;
        private String url;
        private LocalDateTime uploadedAt;
    }
}
```

### 2.2 ⏰ **Support Absences Courtes (Heures/Demi-journées)**

**Étendre `LeaveRequest` entity** :
```java
@Entity
public class LeaveRequest {
    // ... champs existants
    
    @Column(name = "start_time")
    private LocalTime startTime;
    
    @Column(name = "end_time") 
    private LocalTime endTime;
    
    @Column(name = "is_half_day")
    private Boolean isHalfDay;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "half_day_type")
    private HalfDayType halfDayType; // MORNING, AFTERNOON
    
    @Column(name = "duration_hours")
    private Double durationHours;
}
```

**Validation durée 2h max pour absences** :
```java
@Component
public class AbsenceDurationValidator implements ConstraintValidator<ValidAbsenceDuration, LeaveRequestCreateRequest> {
    @Override
    public boolean isValid(LeaveRequestCreateRequest request, ConstraintValidatorContext context) {
        if (!"absence".equals(request.getType())) return true;
        
        if (request.getStartTime() != null && request.getEndTime() != null) {
            Duration duration = Duration.between(request.getStartTime(), request.getEndTime());
            return duration.toMinutes() <= 120; // Max 2h
        }
        return true;
    }
}
```

---

## 🔔 **PHASE 3 - NOTIFICATIONS ET DASHBOARD (Sprint 5-6)**

### 3.1 📱 **Système Notifications Complet**

**Créer entité Notification** :
```java
@Entity
public class Notification {
    @Id
    private String id;
    private String userId;
    private String title;
    private String message;
    private NotificationType type;
    private Map<String, Object> data;
    private boolean isRead;
    private LocalDateTime createdAt;
}
```

**Controller notifications** :
```java
@RestController  
@RequestMapping("/api/notifications")
public class NotificationController {
    
    @GetMapping
    public ResponseEntity<NotificationListResponse> getNotifications(
            @RequestParam(required = false) Boolean unread,
            @RequestParam(defaultValue = "1") int page) {
        // Pagination + filtrage
        return ResponseEntity.ok(notificationService.getUserNotifications(unread, page));
    }
    
    @PutMapping("/{id}/read")
    public ResponseEntity<Void> markAsRead(@PathVariable String id) {
        notificationService.markAsRead(id);
        return ResponseEntity.ok().build();
    }
}
```

### 3.2 📊 **API Statistiques et Soldes**

**Endpoint soldes utilisateur** :
```java
@GetMapping("/api/user/balance")
public ResponseEntity<UserBalanceResponse> getUserBalance() {
    String userId = getCurrentUserId();
    UserBalance balance = leaveBalanceService.calculateBalance(userId);
    return ResponseEntity.ok(UserBalanceResponse.success(balance));
}
```

**Format réponse Flutter** :
```java
@Data
public class UserBalanceResponse {
    private boolean success;
    private BalanceData data;
    
    @Data
    public static class BalanceData {
        private int availableDays;
        private int totalDaysPerYear;
        private int usedDays;
        private int pendingDays;
        private Map<String, LeaveTypeBalance> details;
    }
}
```

---

## 👥 **PHASE 4 - API MANAGER ET WORKFLOW (Sprint 7-8)**

### 4.1 🎭 **Endpoints Manager Spécialisés**

```java
@RestController
@RequestMapping("/api/manager") 
public class ManagerController {
    
    @GetMapping("/team-requests")
    public ResponseEntity<TeamRequestsResponse> getTeamRequests() {
        String managerId = getCurrentUserId();
        List<LeaveRequestWithEmployee> requests = leaveService.getTeamRequests(managerId);
        return ResponseEntity.ok(TeamRequestsResponse.success(requests));
    }
    
    @PutMapping("/requests/{id}/approve")
    public ResponseEntity<LeaveRequestResponse> approve(
            @PathVariable Long id,
            @RequestBody ApprovalRequest request) {
        
        LeaveRequest approved = leaveService.approve(id, request.getComment());
        // Envoyer notification automatique
        notificationService.sendApprovalNotification(approved);
        return ResponseEntity.ok(LeaveRequestResponse.success(approved));
    }
}
```

### 4.2 🔄 **Workflow Approbation Configurable**

**Entité workflow** :
```java
@Entity
public class ApprovalWorkflow {
    @Id
    private Long id;
    private Long departmentId;
    private Long leaveTypeId;
    
    @ElementCollection
    private List<WorkflowStep> steps;
    
    @Embeddable
    public static class WorkflowStep {
        private int order;
        private String approverRole;
        private boolean required;
        private int timeoutDays;
    }
}
```

---

## 🗄️ **PHASE 5 - MIGRATIONS BASE DE DONNÉES (Sprint 9)**

### 5.1 📝 **Scripts Flyway Additionnels**

**V2__add_flutter_support.sql** :
```sql
-- Support absences courtes
ALTER TABLE leave_requests ADD COLUMN start_time TIME;
ALTER TABLE leave_requests ADD COLUMN end_time TIME;
ALTER TABLE leave_requests ADD COLUMN is_half_day BOOLEAN DEFAULT FALSE;
ALTER TABLE leave_requests ADD COLUMN half_day_type VARCHAR(20);
ALTER TABLE leave_requests ADD COLUMN duration_hours DECIMAL(3,1);

-- Table fichiers génériques
CREATE TABLE file_attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    leave_request_id BIGINT REFERENCES leave_requests(id) ON DELETE CASCADE,
    original_name VARCHAR(255) NOT NULL,
    stored_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_type VARCHAR(50) NOT NULL,
    file_size BIGINT NOT NULL,
    uploaded_by BIGINT REFERENCES users(id),
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table notifications  
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    notification_type VARCHAR(50) NOT NULL,
    data JSONB,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Refresh tokens
CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(token_hash)
);

-- Index pour performances  
CREATE INDEX idx_leave_requests_requester_status ON leave_requests(requester_id, status);
CREATE INDEX idx_notifications_user_read ON notifications(user_id, is_read);
CREATE INDEX idx_file_attachments_request ON file_attachments(leave_request_id);
```

### 5.2 🔧 **Configuration Environnement**

**application-flutter.yml** :
```yaml
app:
  cors:
    allowed-origins:
      - "http://localhost:3000"  # Flutter web dev
      - "https://*.xconges.com"   # Production mobile
  
  file-upload:
    max-size: 5MB
    allowed-types: 
      - "application/pdf"
      - "image/jpeg"  
      - "image/png"
    storage-path: "${UPLOAD_PATH:/tmp/uploads}"
    
  notifications:
    firebase:
      project-id: "${FIREBASE_PROJECT_ID}"
      private-key: "${FIREBASE_PRIVATE_KEY}"
    
  leave-validation:
    advance-notice:
      leave-hours: 72
      absence-hours: 48
    absence:
      max-duration-hours: 2
    working-days:
      exclude-weekends: true
      holidays-api: "https://api.gouv.fr/api/jours-feries"
```

---

## 🧪 **PHASE 6 - TESTS ET DOCUMENTATION (Sprint 10)**

### 6.1 ✅ **Tests d'Intégration Flutter**

**Créer collection Postman** avec scénarios complets :
```json
{
  "scenarios": [
    {
      "name": "Authentification Flutter",
      "steps": [
        "POST /api/auth/login (format Flutter)",
        "GET /api/auth/me", 
        "POST /api/auth/refresh"
      ]
    },
    {
      "name": "Demande congé complète",
      "steps": [
        "POST /api/files/upload (certificat)",
        "POST /api/leave-requests (avec attachmentIds)", 
        "GET /api/leave-requests/requester/{id}",
        "PUT /api/leave-requests/{id} (modification)",
        "DELETE /api/leave-requests/{id} (annulation)"
      ]
    }
  ]
}
```

### 6.2 📚 **Documentation OpenAPI Complète**

**Annotations Swagger détaillées** :
```java
@Operation(
    summary = "Créer une demande de congé/absence",
    description = "Permet de créer une nouvelle demande avec validation des délais et pièces jointes"
)
@ApiResponses({
    @ApiResponse(responseCode = "201", description = "Demande créée avec succès"),
    @ApiResponse(responseCode = "422", description = "Erreurs de validation", 
                 content = @Content(schema = @Schema(implementation = ValidationErrorResponse.class)))
})
@PostMapping
public ResponseEntity<LeaveRequestResponse> create(@Valid @RequestBody LeaveRequestCreateRequest request)
```

---

## 🎯 **RÉSUMÉ PLANNING**

| Phase | Durée | Priorité | Livrables |
|-------|--------|----------|-----------|
| **Phase 1** | 2 sprints | 🔴 P0 | LoginResponse, Validations, Endpoints unifiés |
| **Phase 2** | 2 sprints | 🟠 P1 | Upload fichiers, Absences courtes |
| **Phase 3** | 2 sprints | 🟡 P1 | Notifications, Dashboard stats |
| **Phase 4** | 2 sprints | 🟢 P2 | API Manager, Workflow |
| **Phase 5** | 1 sprint  | 🟠 P1 | Migrations DB, Config |
| **Phase 6** | 1 sprint  | 🟡 P2 | Tests, Documentation |

## 📋 **CHECKLIST DE VALIDATION**

### ✅ **Avant Intégration Flutter** :
- [ ] Format LoginResponse conforme
- [ ] Endpoints `/api/auth/*` complets  
- [ ] Validations 48h/72h fonctionnelles
- [ ] Upload fichiers opérationnel
- [ ] Format erreurs standardisé
- [ ] Tests Postman validés

### ✅ **Pour Production** :
- [ ] Notifications push configurées
- [ ] Dashboard statistiques
- [ ] Workflow approbation  
- [ ] Monitoring et logs
- [ ] Documentation complète
- [ ] Tests d'intégration E2E

---

## 🚀 **RECOMMANDATION EXÉCUTIVE**

**Effort estimé** : 10 sprints (5 mois)  
**Complexité** : Moyenne-Élevée  
**Risque principal** : Incompatibilité format JSON (résolu en Phase 1)  

**Approche recommandée** :
1. ⚡ **Démarrer immédiatement Phase 1** (critique pour déblocage frontend)
2. 🤝 **Synchronisation hebdomadaire** avec équipe Flutter  
3. 🧪 **Tests continus** avec mocks frontend
4. 📚 **Documentation incrémentale** à chaque phase

**Ce plan permet une intégration backend-frontend progressive avec validation continue des fonctionnalités critiques.**