package com.xtensus.hrmanagementapi.medical.document.exception;

public class MedicalDocumentAccessDeniedException extends RuntimeException {

    public MedicalDocumentAccessDeniedException(Long leaveRequestId) {
        super("Not allowed to attach a medical document to leave request: " + leaveRequestId);
    }
}
