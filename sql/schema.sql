-- COME 381 - Ödev 1: Adli Bilişim Vaka Takip Sistemi
-- PostgreSQL 13+ | Temiz bir veritabanında baştan sona çalışır.
-- Not: "case" SQL'de ayrılmış kelime olduğu için vaka tablosu case_file adını aldı.

-- 1) Adli bilişim uzmanları
CREATE TABLE analyst (
    analyst_id      INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    badge_no        VARCHAR(10)  NOT NULL UNIQUE,
    full_name       VARCHAR(100) NOT NULL,
    title           VARCHAR(60)  NOT NULL,
    specialization  VARCHAR(80)  NOT NULL,
    email           VARCHAR(120) NOT NULL UNIQUE,
    phone           VARCHAR(20),
    hire_date       DATE         NOT NULL DEFAULT CURRENT_DATE
);

-- 2) Laboratuvar cihaz ve yazılım envanteri
CREATE TABLE lab_asset (
    asset_id        INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    asset_name      VARCHAR(100) NOT NULL,
    asset_type      VARCHAR(10)  NOT NULL,      -- 'cihaz' veya 'yazılım'
    model           VARCHAR(100),
    serial_no       VARCHAR(60)  UNIQUE,
    version         VARCHAR(30),
    license_expiry  DATE,
    status          VARCHAR(20)  NOT NULL DEFAULT 'aktif'
);

-- 3) Vakalar (1 analist -> N vaka)
CREATE TABLE case_file (
    case_id          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    case_no          VARCHAR(20)  NOT NULL UNIQUE,
    title            VARCHAR(200) NOT NULL,
    crime_type       VARCHAR(80)  NOT NULL,
    description      TEXT,
    reported_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status           VARCHAR(20)  NOT NULL DEFAULT 'açık',
    priority         SMALLINT     NOT NULL DEFAULT 2,
    lead_analyst_id  INTEGER REFERENCES analyst (analyst_id) ON DELETE SET NULL
);

-- 4) Şüpheli / sanıklar (1 vaka -> N şüpheli)
CREATE TABLE suspect (
    suspect_id   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    case_id      INTEGER      NOT NULL REFERENCES case_file (case_id) ON DELETE CASCADE,
    full_name    VARCHAR(100) NOT NULL,
    national_id  VARCHAR(11),
    birth_date   DATE,
    status       VARCHAR(20)  NOT NULL DEFAULT 'şüpheli',
    notes        TEXT,
    -- Aynı kişi farklı vakalarda yer alabilir, bu yüzden TC vaka ile birlikte benzersiz
    UNIQUE (case_id, national_id)
);

-- 5) Dijital kanıtlar (1 vaka -> N kanıt, 1 şüpheli -> N kanıt)
CREATE TABLE digital_evidence (
    evidence_id       INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    evidence_no       VARCHAR(25)  NOT NULL UNIQUE,
    case_id           INTEGER      NOT NULL REFERENCES case_file (case_id) ON DELETE CASCADE,
    suspect_id        INTEGER REFERENCES suspect (suspect_id) ON DELETE SET NULL,
    evidence_type     VARCHAR(40)  NOT NULL,
    description       TEXT         NOT NULL,
    serial_or_imei    VARCHAR(50),
    storage_gb        NUMERIC(8,2),
    sha256_hash       CHAR(64),
    seized_at         TIMESTAMP    NOT NULL,
    seized_location   VARCHAR(200),
    storage_status    VARCHAR(20)  NOT NULL DEFAULT 'depoda'
);

-- 6) Analiz raporları: analyst <-> digital_evidence M:N ara tablosu
--    (aynı zamanda 1 envanter kaydı -> N rapor)
CREATE TABLE analysis_report (
    report_id      INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    report_no      VARCHAR(25)  NOT NULL UNIQUE,
    evidence_id    INTEGER      NOT NULL REFERENCES digital_evidence (evidence_id) ON DELETE CASCADE,
    analyst_id     INTEGER      NOT NULL REFERENCES analyst (analyst_id) ON DELETE RESTRICT,
    asset_id       INTEGER REFERENCES lab_asset (asset_id) ON DELETE SET NULL,
    analysis_type  VARCHAR(40)  NOT NULL,
    started_at     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    finished_at    TIMESTAMP,
    findings       TEXT,
    result         VARCHAR(25)  NOT NULL DEFAULT 'devam ediyor',
    UNIQUE (evidence_id, analyst_id, analysis_type)
);
