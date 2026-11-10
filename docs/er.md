erDiagram
    analyst |o--o{ case_file : "yürütür"
    case_file ||--o{ suspect : "şüpheli içerir"
    case_file ||--o{ digital_evidence : "kanıt içerir"
    suspect |o--o{ digital_evidence : "kanıt ele geçirilir"
    digital_evidence ||--o{ analysis_report : "incelenir"
    analyst ||--o{ analysis_report : "hazırlar"
    lab_asset |o--o{ analysis_report : "kullanılır"

    analyst {
        int analyst_id PK "IDENTITY"
        varchar badge_no UK "NOT NULL"
        varchar full_name "NOT NULL"
        varchar title "NOT NULL"
        varchar specialization "NOT NULL"
        varchar email UK "NOT NULL"
        varchar phone
        date hire_date "NOT NULL, DEFAULT CURRENT_DATE"
    }

    lab_asset {
        int asset_id PK "IDENTITY"
        varchar asset_name "NOT NULL"
        varchar asset_type "NOT NULL"
        varchar model
        varchar serial_no UK
        varchar version
        date license_expiry
        varchar status "NOT NULL, DEFAULT 'aktif'"
    }

    case_file {
        int case_id PK "IDENTITY"
        varchar case_no UK "NOT NULL"
        varchar title "NOT NULL"
        varchar crime_type "NOT NULL"
        text description
        timestamp reported_at "NOT NULL, DEFAULT CURRENT_TIMESTAMP"
        varchar status "NOT NULL, DEFAULT 'açık'"
        smallint priority "NOT NULL, DEFAULT 2"
        int lead_analyst_id FK "ON DELETE SET NULL"
    }

    suspect {
        int suspect_id PK "IDENTITY"
        int case_id FK "NOT NULL, ON DELETE CASCADE"
        varchar full_name "NOT NULL"
        varchar national_id "UNIQUE (case_id, national_id)"
        date birth_date
        varchar status "NOT NULL, DEFAULT 'şüpheli'"
        text notes
    }

    digital_evidence {
        int evidence_id PK "IDENTITY"
        varchar evidence_no UK "NOT NULL"
        int case_id FK "NOT NULL, ON DELETE CASCADE"
        int suspect_id FK "ON DELETE SET NULL"
        varchar evidence_type "NOT NULL"
        text description "NOT NULL"
        varchar serial_or_imei
        numeric storage_gb
        char sha256_hash
        timestamp seized_at "NOT NULL"
        varchar seized_location
        varchar storage_status "NOT NULL, DEFAULT 'depoda'"
    }

    analysis_report {
        int report_id PK "IDENTITY"
        varchar report_no UK "NOT NULL"
        int evidence_id FK "NOT NULL, ON DELETE CASCADE"
        int analyst_id FK "NOT NULL, ON DELETE RESTRICT"
        int asset_id FK "ON DELETE SET NULL"
        varchar analysis_type "NOT NULL, UNIQUE (evidence_id, analyst_id, analysis_type)"
        timestamp started_at "NOT NULL, DEFAULT CURRENT_TIMESTAMP"
        timestamp finished_at
        text findings
        varchar result "NOT NULL, DEFAULT 'devam ediyor'"
    }
