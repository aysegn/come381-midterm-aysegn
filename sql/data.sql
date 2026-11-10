-- =====================================================================
-- COME 381 Veri Tabanı Sistemleri - Ödev 1
-- Hazırlayan : Ayşegülsüm Gültekin ([202502009026])
-- Proje      : Adli Bilişim Vaka Takip Sistemi
--
-- Özet: Bir il emniyet müdürlüğü siber suçlar şubesinde vakaları,
-- şüphelileri, ele geçirilen dijital kanıtları, adli bilişim
-- analistlerini ve laboratuvar envanterini takip eden, PostgreSQL
-- üzerinde çalışan 6 tablolu ilişkisel bir veritabanıdır.
--
-- Tablolar : analyst, lab_asset, case_file, suspect,
--            digital_evidence, analysis_report
-- M:N ilişki: analyst <-> digital_evidence (ara tablo: analysis_report)
-- =====================================================================

SET client_encoding = 'UTF8';

DROP TABLE IF EXISTS analysis_report CASCADE;
DROP TABLE IF EXISTS digital_evidence CASCADE;
DROP TABLE IF EXISTS suspect CASCADE;
DROP TABLE IF EXISTS case_file CASCADE;
DROP TABLE IF EXISTS lab_asset CASCADE;
DROP TABLE IF EXISTS analyst CASCADE;

-- =====================================================================
-- TABLO OLUŞTURMA İŞLEMLERİ
-- =====================================================================

-- 1) Adli Bilişim Uzmanları
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

-- 2) Laboratuvar Cihaz ve Yazılım Envanteri
CREATE TABLE lab_asset (
    asset_id        INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    asset_name      VARCHAR(100) NOT NULL,
    asset_type      VARCHAR(10)  NOT NULL, -- 'cihaz' veya 'yazılım'
    model           VARCHAR(100),
    serial_no       VARCHAR(60)  UNIQUE,
    version         VARCHAR(30),
    license_expiry  DATE,
    status          VARCHAR(20)  NOT NULL DEFAULT 'aktif'
);

-- 3) Vakalar (1 analist -> N vaka)
CREATE TABLE case_file (
    case_id         INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    case_no         VARCHAR(20)  NOT NULL UNIQUE,
    title           VARCHAR(200) NOT NULL,
    crime_type      VARCHAR(80)  NOT NULL,
    description     TEXT,
    reported_at     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status          VARCHAR(20)  NOT NULL DEFAULT 'açık',
    priority        SMALLINT     NOT NULL DEFAULT 2,
    lead_analyst_id INTEGER REFERENCES analyst (analyst_id) ON DELETE SET NULL
);

-- 4) Şüpheliler / Sanıklar (1 vaka -> N şüpheli)
CREATE TABLE suspect (
    suspect_id   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    case_id      INTEGER      NOT NULL REFERENCES case_file (case_id) ON DELETE CASCADE,
    full_name    VARCHAR(100) NOT NULL,
    national_id  VARCHAR(11),
    birth_date   DATE,
    status       VARCHAR(20)  NOT NULL DEFAULT 'şüpheli',
    notes        TEXT,
    UNIQUE (case_id, national_id)
);

-- 5) Dijital Kanıtlar
CREATE TABLE digital_evidence (
    evidence_id     INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    evidence_no     VARCHAR(25)  NOT NULL UNIQUE,
    case_id         INTEGER      NOT NULL REFERENCES case_file (case_id) ON DELETE CASCADE,
    suspect_id      INTEGER REFERENCES suspect (suspect_id) ON DELETE SET NULL,
    evidence_type   VARCHAR(40)  NOT NULL,
    description     TEXT         NOT NULL,
    serial_or_imei  VARCHAR(50),
    storage_gb      NUMERIC(8,2),
    sha256_hash     CHAR(64),
    seized_at       TIMESTAMP    NOT NULL,
    seized_location VARCHAR(200),
    storage_status  VARCHAR(20)  NOT NULL DEFAULT 'depoda'
);

-- 6) Analiz Raporları (M:N İlişki Tablosu)
CREATE TABLE analysis_report (
    report_id     INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    report_no     VARCHAR(25)  NOT NULL UNIQUE,
    evidence_id   INTEGER      NOT NULL REFERENCES digital_evidence (evidence_id) ON DELETE CASCADE,
    analyst_id    INTEGER      NOT NULL REFERENCES analyst (analyst_id) ON DELETE RESTRICT,
    asset_id      INTEGER REFERENCES lab_asset (asset_id) ON DELETE SET NULL,
    analysis_type VARCHAR(40)  NOT NULL,
    started_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    finished_at   TIMESTAMP,
    findings      TEXT,
    result        VARCHAR(25)  NOT NULL DEFAULT 'devam ediyor',
    UNIQUE (evidence_id, analyst_id, analysis_type)
);

-- =====================================================================
-- ÖRNEK VERİ EKLEME (SEED DATA)
-- =====================================================================

INSERT INTO analyst (badge_no, full_name, title, specialization, email, phone, hire_date) VALUES
('SCL-1001', 'Elif Kaya',    'Kıdemli Uzman',    'Bellek Analizi',                'elif.kaya@siber.example',    '0500 000 00 01', '2018-03-12'),
('SCL-1002', 'Burak Yıldız',  'Dijital İncelemeci', 'Mobil İnceleme',                'burak.yildiz@siber.example',  '0500 000 00 02', '2020-09-01'),
('SCL-1003', 'Selin Arslan',  'Kıdemli Uzman',    'Ağ Adli Bilişimi',              'selin.arslan@siber.example',  '0500 000 00 03', '2017-05-22'),
('SCL-1004', 'Kerem Öztürk',  'Uzman Yardımcısı',  'Disk ve Dosya Sistemi Analizi', 'kerem.ozturk@siber.example',  NULL,             '2023-02-15');

INSERT INTO lab_asset (asset_name, asset_type, model, serial_no, version, license_expiry, status) VALUES
('Tableau Yazma Engelleyici', 'cihaz',   'T8u',    'TBL-8841-A',  NULL,     NULL,         'bakımda'),
('FTK Imager',                'yazılım', NULL,    'SW-FTK-001',  '4.7.1',  '2027-03-31', 'aktif'),
('Autopsy',                   'yazılım', NULL,    'SW-AUT-002',  '4.21.0', NULL,         'aktif'),
('Volatility 3',              'yazılım', NULL,    'SW-VOL-003',  '2.5.2',  NULL,         'aktif'),
('Wireshark',                 'yazılım', NULL,    'SW-WSH-004',  '4.2.5',  NULL,         'aktif'),
('Mobil Adli Bilişim Cihazı', 'cihaz',   'MAB-X1', 'DEV-MOB-777', NULL,     '2026-12-31', 'aktif');

INSERT INTO case_file (case_no, title, crime_type, description, reported_at, status, priority, lead_analyst_id) VALUES
('VK-2026-001', 'Banka müşterilerine yönelik kimlik avı', 'Nitelikli dolandırıcılık',
 'Sahte banka sayfası üzerinden müşterilerin kart bilgileri toplandı.',
 '2026-08-03 09:30:00', 'incelemede', 1, (SELECT analyst_id FROM analyst WHERE badge_no = 'SCL-1003')),
('VK-2026-002', 'Hastane sistemine fidye yazılımı saldırısı', 'Bilişim sistemine izinsiz erişim',
 'Hastane sunucuları şifrelendi, fidye talep edildi. Saldırgan henüz belirlenemedi.',
 '2026-08-19 14:10:00', 'incelemede', 1, (SELECT analyst_id FROM analyst WHERE badge_no = 'SCL-1001')),
('VK-2026-003', 'Sosyal medya hesabı ele geçirme ve şantaj', 'Şantaj',
 'Mağdurun hesabı ele geçirilip özel görüntüler üzerinden tehdit edildi.',
 '2026-09-02 11:45:00', 'mahkemede', 2, (SELECT analyst_id FROM analyst WHERE badge_no = 'SCL-1002')),
('VK-2026-004', 'Sahte kripto yatırım platformu', 'Dolandırıcılık',
 'Sahte yatırım sitesi üzerinden çok sayıda kişiden para toplandı.',
 '2026-09-15 10:00:00', 'açık', 2, (SELECT analyst_id FROM analyst WHERE badge_no = 'SCL-1004')),
('VK-2026-005', 'Şirket verilerinin izinsiz kopyalanması', 'Verileri hukuka aykırı olarak ele geçirme',
 'Eski bir çalışanın şirket müşteri listesini kopyaladığı iddia edildi.',
 '2026-10-01 16:20:00', 'kapandı', 3, (SELECT analyst_id FROM analyst WHERE badge_no = 'SCL-1004')),
('VK-2026-006', 'Sahte e-ticaret sitesi', 'Nitelikli dolandırıcılık',
 'Ödeme alıp ürün göndermeyen sahte mağaza sitesi. Sorumlu analist henüz atanmadı.',
 '2026-10-20 13:05:00', 'açık', 3, NULL);


INSERT INTO suspect (case_id, full_name, national_id, birth_date, status, notes) VALUES
((SELECT case_id FROM case_file WHERE case_no = 'VK-2026-001'), 'Ozan Çelik',   '10000000011', '1994-04-17', 'şüpheli', 'Sahte sayfanın alan adını satın aldığı iddia ediliyor.'),
((SELECT case_id FROM case_file WHERE case_no = 'VK-2026-001'), 'Hakan Polat',  '10000000022', '1990-11-02', 'sanık',   'Toplanan kart bilgilerini kullanmakla suçlanıyor.'),
((SELECT case_id FROM case_file WHERE case_no = 'VK-2026-003'), 'Deniz Aksoy',  '10000000033', '1999-07-25', 'sanık',   'Mağdurun hesabına yetkisiz giriş yaptığı tespit edildi.'),
((SELECT case_id FROM case_file WHERE case_no = 'VK-2026-004'), 'Tolga Erdem',  '10000000044', '1987-01-30', 'tutuklu', 'Platformun yöneticisi olduğu değerlendiriliyor.'),
((SELECT case_id FROM case_file WHERE case_no = 'VK-2026-004'), 'Cem Yavuz',    '10000000055', '1992-12-09', 'şüpheli', 'Para transferlerinde aracı olduğu düşünülüyor.'),
((SELECT case_id FROM case_file WHERE case_no = 'VK-2026-005'), 'Gökhan Başar', '10000000066', '1985-06-14', 'beraat',  'İnceleme sonucunda suçlama doğrulanamadı.'),
((SELECT case_id FROM case_file WHERE case_no = 'VK-2026-006'), 'Merve Tunç',   NULL,          NULL,         'şüpheli', 'Kimlik bilgileri henüz tespit edilemedi.');

INSERT INTO digital_evidence (evidence_no, case_id, suspect_id, evidence_type, description, serial_or_imei, storage_gb, sha256_hash, seized_at, seized_location, storage_status) VALUES
('KNT-2026-001-A', (SELECT case_id FROM case_file WHERE case_no = 'VK-2026-001'),
 (SELECT suspect_id FROM suspect WHERE national_id = '10000000011'),
 'dizüstü bilgisayar', 'Şüphelinin evinde ele geçirilen dizüstü bilgisayar.', 'SN-LT-448120', 512.00,
 '8cbe7a073e711ad35b90f499e18bc2c7f5f08d0b5e1df94b1591ccf49d7a977e', '2026-08-05 08:15:00', 'İstanbul, Kadıköy', 'incelemede'),
('KNT-2026-001-B', (SELECT case_id FROM case_file WHERE case_no = 'VK-2026-001'),
 (SELECT suspect_id FROM suspect WHERE national_id = '10000000022'),
 'USB bellek', 'Üzerinde kart bilgisi tablosu bulunan USB bellek.', 'SN-USB-902331', 64.00,
 '63a50effb7dde21bd9b0974d343a1478e7204d3e2340273c1edeea34d0b9a541', '2026-08-05 08:40:00', 'İstanbul, Kadıköy', 'depoda'),
('KNT-2026-002-A', (SELECT case_id FROM case_file WHERE case_no = 'VK-2026-002'),
 NULL,
 'sunucu disk imajı', 'Şifrelenen hastane sunucusunun disk ve bellek imajı.', NULL, 2000.00,
 'ba9507013b11164924e66265b59fbd38cfb1bbd06f830ee270d91e2e7ff6117e', '2026-08-20 02:30:00', 'Hastane veri merkezi', 'incelemede'),
('KNT-2026-002-B', (SELECT case_id FROM case_file WHERE case_no = 'VK-2026-002'),
 NULL,
 'ağ trafik kaydı', 'Saldırı anına ait güvenlik duvarı ve ağ trafik kayıtları.', NULL, 35.50,
 '77d201233a6de8ed1492203803669f9fb965d379f526bf5385103c266cbc3de2', '2026-08-20 03:10:00', 'Hastane veri merkezi', 'incelemede'),
('KNT-2026-003-A', (SELECT case_id FROM case_file WHERE case_no = 'VK-2026-003'),
 (SELECT suspect_id FROM suspect WHERE national_id = '10000000033'),
 'cep telefonu', 'Şüpheliye ait akıllı telefon.', '350000000000011', 128.00,
 '4866e4ffc8eec0f827306d48ea0365ae90735d9fe35191e9f85415afdac5940a', '2026-09-03 10:20:00', 'Ankara, Çankaya', 'mahkemeye teslim'),
('KNT-2026-004-A', (SELECT case_id FROM case_file WHERE case_no = 'VK-2026-004'),
 (SELECT suspect_id FROM suspect WHERE national_id = '10000000044'),
 'harici disk', 'Platformun yönetim dosyalarını içeren harici disk.', 'SN-HDD-117744', 1000.00,
 '9aef7540e55a5044cda7a02d10f4549e5c3d55e5b743e12e18e69a5c80581ebe', '2026-09-16 09:00:00', 'İzmir, Bornova', 'incelemede'),
('KNT-2026-004-B', (SELECT case_id FROM case_file WHERE case_no = 'VK-2026-004'),
 (SELECT suspect_id FROM suspect WHERE national_id = '10000000055'),
 'dizüstü bilgisayar', 'Para transfer kayıtlarının tutulduğu dizüstü bilgisayar.', 'SN-LT-553908', 256.00,
 'd9598859160bf4da97f39d483f4e01750b82c45db485a0d1419172704558d28b', '2026-09-16 09:30:00', 'İzmir, Karşıyaka', 'depoda'),
('KNT-2026-005-A', (SELECT case_id FROM case_file WHERE case_no = 'VK-2026-005'),
 (SELECT suspect_id FROM suspect WHERE national_id = '10000000066'),
 'iş istasyonu', 'Eski çalışanın kullandığı masaüstü bilgisayar.', 'SN-WS-660271', 1000.00,
 '72e5ad92c499bef7f8a19d17172a9b1546cf90c0a38a9cd8bbe0fb4815866d13', '2026-10-02 12:00:00', 'Bursa, Nilüfer', 'iade edildi'),
('KNT-2026-005-B', (SELECT case_id FROM case_file WHERE case_no = 'VK-2026-005'),
 (SELECT suspect_id FROM suspect WHERE national_id = '10000000066'),
 'USB bellek', 'İş istasyonuna takılı bulunan USB bellek.', 'SN-USB-774120', 32.00,
 'fb17354b36f1ed31415d4da0f3d357206f1536a14d013707e4e198cc04f50dbf', '2026-10-02 12:10:00', 'Bursa, Nilüfer', 'iade edildi'),
('KNT-2026-006-A', (SELECT case_id FROM case_file WHERE case_no = 'VK-2026-006'),
 (SELECT suspect_id FROM suspect WHERE full_name = 'Merve Tunç'),
 'web sunucu imajı', 'Sahte mağaza sitesinin barındırıldığı sunucunun imajı.', NULL, 120.00,
 'aa9765146350713f44864b84f48975bed86b96e5374367d4be8964062fbfd2de', '2026-10-22 15:30:00', 'Hosting firması (talep üzerine)', 'depoda');


INSERT INTO analysis_report (report_no, evidence_id, analyst_id, asset_id, analysis_type, started_at, finished_at, findings, result) VALUES
('RPR-2026-001', (SELECT evidence_id FROM digital_evidence WHERE evidence_no = 'KNT-2026-001-A'),
 (SELECT analyst_id FROM analyst WHERE badge_no = 'SCL-1004'), (SELECT asset_id FROM lab_asset WHERE serial_no = 'SW-FTK-001'),
 'disk imajı analizi', '2026-08-06 09:00:00', '2026-08-08 17:30:00',
 'Sahte sayfa şablonları ve çalınan kart bilgilerini içeren tablo bulundu.', 'delil bulundu'),
('RPR-2026-002', (SELECT evidence_id FROM digital_evidence WHERE evidence_no = 'KNT-2026-001-A'),
 (SELECT analyst_id FROM analyst WHERE badge_no = 'SCL-1003'), (SELECT asset_id FROM lab_asset WHERE serial_no = 'SW-AUT-002'),
 'e-posta başlık analizi', '2026-08-09 10:00:00', '2026-08-10 16:00:00',
 'Oltalama e-postalarının gönderim kaynağı şüphelinin bilgisayarıyla eşleşti.', 'delil bulundu'),
('RPR-2026-003', (SELECT evidence_id FROM digital_evidence WHERE evidence_no = 'KNT-2026-001-B'),
 (SELECT analyst_id FROM analyst WHERE badge_no = 'SCL-1004'), (SELECT asset_id FROM lab_asset WHERE serial_no = 'SW-FTK-001'),
 'disk imajı analizi', '2026-08-07 11:00:00', '2026-08-07 15:45:00',
 'Silinmiş dosyaların bir kısmı kurtarılabildi.', 'kısmi bulgu'),
('RPR-2026-004', (SELECT evidence_id FROM digital_evidence WHERE evidence_no = 'KNT-2026-002-A'),
 (SELECT analyst_id FROM analyst WHERE badge_no = 'SCL-1001'), (SELECT asset_id FROM lab_asset WHERE serial_no = 'SW-VOL-003'),
 'bellek analizi', '2026-08-21 09:30:00', NULL,
 'Bellekte şüpheli bir işlem tespit edildi, inceleme sürüyor.', DEFAULT),
('RPR-2026-005', (SELECT evidence_id FROM digital_evidence WHERE evidence_no = 'KNT-2026-002-B'),
 (SELECT analyst_id FROM analyst WHERE badge_no = 'SCL-1003'), (SELECT asset_id FROM lab_asset WHERE serial_no = 'SW-WSH-004'),
 'ağ trafiği analizi', '2026-08-22 09:00:00', '2026-08-25 18:00:00',
 'Dışarıdaki bir adresle şüpheli iletişim kurulduğu görüldü.', 'kısmi bulgu'),
('RPR-2026-006', (SELECT evidence_id FROM digital_evidence WHERE evidence_no = 'KNT-2026-002-A'),
 (SELECT analyst_id FROM analyst WHERE badge_no = 'SCL-1004'), (SELECT asset_id FROM lab_asset WHERE serial_no = 'SW-AUT-002'),
 'disk imajı analizi', '2026-08-24 10:00:00', NULL,
 NULL, DEFAULT),
('RPR-2026-007', (SELECT evidence_id FROM digital_evidence WHERE evidence_no = 'KNT-2026-003-A'),
 (SELECT analyst_id FROM analyst WHERE badge_no = 'SCL-1002'), (SELECT asset_id FROM lab_asset WHERE serial_no = 'DEV-MOB-777'),
 'mobil cihaz incelemesi', '2026-09-04 09:00:00', '2026-09-09 17:00:00',
 'Hesaba yetkisiz erişim kayıtları ve tehdit mesajları tespit edildi.', 'delil bulundu'),
('RPR-2026-008', (SELECT evidence_id FROM digital_evidence WHERE evidence_no = 'KNT-2026-004-A'),
 (SELECT analyst_id FROM analyst WHERE badge_no = 'SCL-1004'), (SELECT asset_id FROM lab_asset WHERE serial_no = 'SW-FTK-001'),
 'disk imajı analizi', '2026-09-17 09:00:00', '2026-09-21 17:00:00',
 'Sahte platformun yönetim paneline ait dosyalar bulundu.', 'delil bulundu'),
('RPR-2026-009', (SELECT evidence_id FROM digital_evidence WHERE evidence_no = 'KNT-2026-004-B'),
 (SELECT analyst_id FROM analyst WHERE badge_no = 'SCL-1001'), (SELECT asset_id FROM lab_asset WHERE serial_no = 'SW-AUT-002'),
 'disk imajı analizi', '2026-09-18 09:30:00', '2026-09-22 16:30:00',
 'Para transfer kayıtlarının bulunduğu hesap tablosu ele geçirildi.', 'delil bulundu'),
('RPR-2026-010', (SELECT evidence_id FROM digital_evidence WHERE evidence_no = 'KNT-2026-005-A'),
 (SELECT analyst_id FROM analyst WHERE badge_no = 'SCL-1001'), (SELECT asset_id FROM lab_asset WHERE serial_no = 'SW-FTK-001'),
 'disk imajı analizi', '2026-10-03 09:00:00', '2026-10-06 17:00:00',
 'Müşteri listesinin kopyalandığına dair bir iz bulunamadı.', 'delil bulunamadı'),
('RPR-2026-011', (SELECT evidence_id FROM digital_evidence WHERE evidence_no = 'KNT-2026-006-A'),
 (SELECT analyst_id FROM analyst WHERE badge_no = 'SCL-1003'), NULL,
 'log analizi', '2026-10-23 09:00:00', '2026-10-24 14:00:00',
 'Sunucu kayıtlarında ödeme sayfası değişikliklerinin kaynağı belirlendi.', 'delil bulundu');


-- =====================================================================
-- KONTROL / TEST SORGULARI
-- =====================================================================

-- Sorgu 1: Vakalar ve sorumlu analistleri
SELECT c.case_no, c.title, c.status,
       COALESCE(a.full_name, 'Atanmadı') AS sorumlu_analist
FROM case_file c
LEFT JOIN analyst a ON a.analyst_id = c.lead_analyst_id
ORDER BY c.case_no;

-- Sorgu 2: Vaka başına kanıt sayısı ve toplam depolama boyutu
SELECT c.case_no,
       COUNT(e.evidence_id)        AS kanit_sayisi,
       COALESCE(SUM(e.storage_gb), 0) AS toplam_gb
FROM case_file c
LEFT JOIN digital_evidence e ON e.case_id = c.case_id
GROUP BY c.case_no
ORDER BY kanit_sayisi DESC, c.case_no;

-- Sorgu 3: Hangi analist hangi kanıtı inceledi?
SELECT a.full_name AS analist, e.evidence_no, e.evidence_type,
       r.analysis_type, r.result
FROM analysis_report r
JOIN analyst a         ON a.analyst_id  = r.analyst_id
JOIN digital_evidence e ON e.evidence_id = r.evidence_id
ORDER BY a.full_name, e.evidence_no;

-- Sorgu 4: Birden fazla analist tarafından incelenen kanıtlar
SELECT e.evidence_no,
       COUNT(DISTINCT r.analyst_id) AS analist_sayisi
FROM digital_evidence e
JOIN analysis_report r ON r.evidence_id = e.evidence_id
GROUP BY e.evidence_no
HAVING COUNT(DISTINCT r.analyst_id) > 1
ORDER BY e.evidence_no;

-- Sorgu 5: Henüz raporu yazılmamış kanıtlar
SELECT e.evidence_no, e.evidence_type, c.case_no
FROM digital_evidence e
JOIN case_file c ON c.case_id = e.case_id
LEFT JOIN analysis_report r ON r.evidence_id = e.evidence_id
WHERE r.report_id IS NULL
ORDER BY e.evidence_no;

-- Sorgu 6: Analist başına tamamlanan rapor sayısı ve ortalama inceleme süresi
SELECT a.full_name,
       COUNT(*) AS tamamlanan_rapor,
       AVG(r.finished_at - r.started_at) AS ortalama_sure
FROM analysis_report r
JOIN analyst a ON a.analyst_id = r.analyst_id
WHERE r.finished_at IS NOT NULL
GROUP BY a.analyst_id, a.full_name
ORDER BY tamamlanan_rapor DESC, a.full_name;
