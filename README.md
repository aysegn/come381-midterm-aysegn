# COME 381 Vize Projesi

Senaryom, bir il emniyet müdürlüğü siber suçlar şubesinde vakaları, şüphelileri, ele geçirilen dijital kanıtları, adli bilişim analistlerini ve laboratuvar envanterini takip eden bir veritabanıdır. Şema 6 tablodan oluşuyor: `analyst`, `case_file`, `suspect`, `digital_evidence`, `lab_asset` ve `analysis_report`. Bir analist birçok kanıtı incelediği ve bir kanıtı birden fazla analist incelediği için M:N ilişkiyi `analysis_report` ara tablosuyla kurdum; rapor numarası, bulgular ve kullanılan araç ilişkinin kendi özniteliği olduğundan ara tabloyu ayrı bir rapor varlığı olarak tasarladım. Şüpheliyi sadelik için tek vakaya bağlı (1:N) tuttum, vaka tablosunun adı da SQL'de ayrılmış kelime olan `case` ile çakıştığı için `case_file` oldu.

ER diyagramı: [docs/er.md](docs/er.md) | Şema: [sql/schema.sql](sql/schema.sql)
