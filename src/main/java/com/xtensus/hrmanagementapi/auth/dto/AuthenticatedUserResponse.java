package com.xtensus.hrmanagementapi.auth.dto;

import com.xtensus.hrmanagementapi.domain.enums.RoleType;
import com.xtensus.hrmanagementapi.domain.enums.UserStatus;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class AuthenticatedUserResponse {

    private Long id;

    private String username;

    private String email;

    private String firstName;

    private String lastName;

    private RoleType role;
    
    private UserStatus status;
    
    private Boolean enabled;
    
    // Informations département et position pour Flutter
    private DepartmentSummary department;
    
    private PositionSummary position;
    
    private ManagerSummary manager;

    @Getter
    @Setter
    @NoArgsConstructor
    public static class DepartmentSummary {
        private Long id;
        private String name;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    public static class PositionSummary {
        private Long id;
        private String name;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    public static class ManagerSummary {
        private Long id;
        private String firstName;
        private String lastName;
    }
}
