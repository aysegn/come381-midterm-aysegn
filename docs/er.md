# ER Diyagramı: Adli Bilişim Vaka Takip Sistemi

```mermaid
erDiagram
    analyst ||--o{ case_file : "yürütür"
    case_file ||--o{ suspect : "şüpheli içerir"
    case_file ||--o{ digital_evidence : "kanıt içerir"
    suspect |o--o{ digital_evidence : "kanıt ele geçirilir"
    digital_evidence ||--o{ analysis_report : "incelenir"
    analyst ||--o{ analysis_report : "hazırlar"
    lab_asset |o--o{ analysis_report : "kullanılır"

    analyst {
        int analyst_id PK
        string badge_no UK
        string full_name
        string title
        string specialization
        string email UK
        string phone
        date hire_date
    }

    case_file {
        int case_id PK
        string case_no UK
        string title
        string crime_type
        text description
        timestamp reported_at
        string status
        int priority
        int lead_analyst_id FK
    }

    suspect {
        int suspect_id PK
        int case_id FK
        string full_name
        string national_id
        date birth_date
        string status
        text notes
    }

    digital_evidence {
        int evidence_id PK
        string evidence_no UK
        int case_id FK
        int suspect_id FK
        string evidence_type
        text description
        string serial_or_imei
        numeric storage_gb
        string sha256_hash
        timestamp seized_at
        string seized_location
        string storage_status
    }

    lab_asset {
        int asset_id PK
        string asset_name
        string asset_type
        string model
        string serial_no UK
        string version
        date license_expiry
        string status
    }

    analysis_report {
        int report_id PK
        string report_no UK
        int evidence_id FK
        int analyst_id FK
        int asset_id FK
        string analysis_type
        timestamp started_at
        timestamp finished_at
        text findings
        string result
    }
```

## Kardinaliteler

| İlişki | Tür |
|---|---|
| analyst → case_file | 1:N |
| case_file → suspect | 1:N |
| case_file → digital_evidence | 1:N |
| suspect → digital_evidence | 1:N (isteğe bağlı) |
| lab_asset → analysis_report | 1:N (isteğe bağlı) |
| **analyst ↔ digital_evidence** | **M:N** (`analysis_report` ara tablosu ile) |
