# come381-midterm-aysegn


**Ayşegülsüm Gültekin | [202502009026] | Ödev 1 - Adli Bilişim Vaka Takip Sistemi**

Senaryom, bir il emniyet müdürlüğü siber suçlar şubesinde vakaları, şüphelileri, ele geçirilen dijital kanıtları, adli bilişim analistlerini ve laboratuvar envanterini takip eden bir veritabanıdır. Şema 6 tablodan oluşuyor: `analyst`, `case_file`, `suspect`, `digital_evidence`, `lab_asset` ve `analysis_report`. Bir analist birçok kanıtı incelediği ve bir kanıtı birden fazla analist incelediği için M:N ilişkiyi `analysis_report` ara tablosuyla kurdum; rapor numarası, bulgular ve kullanılan araç ilişkinin kendi özniteliği olduğundan ara tabloyu ayrı bir rapor varlığı olarak tasarladım. Şüpheliyi sadelik için tek vakaya bağlı (1:N) tuttum, ödevim tabloların yanı sıra kurgusal örnek veri ve 6 test sorgusu da içeriyor.
