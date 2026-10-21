-- Migration 094: Add the Content-Creation Tools category and matrix metadata.
--
-- Issue #626 supplies the category identity, scope, emoji, and benchmark labels.
-- The benchmark labels stay label-only until separately researched product rows
-- are accepted into the catalog.

START TRANSACTION;

INSERT INTO `categories`
  (`id`, `emoji`, `name_en`, `name_de`, `description_en`, `description_de`, `sort_order`)
VALUES
  (
    'content-creation-tools',
    '🎛️',
    'Content-Creation Tools',
    'Content-Creation-Tools',
    'Software and hardware designed to simplify and enhance the production of live streams, videos, and interactive content. Includes tools for audio mixing, scene switching, automation, overlays, and real-time engagement.',
    'Software und Hardware zur Vereinfachung und Verbesserung der Produktion von Livestreams, Videos und interaktiven Inhalten. Umfasst Werkzeuge für Audiomischung, Szenenwechsel, Automatisierung, Overlays und Echtzeit-Interaktion.',
    405
  )
ON DUPLICATE KEY UPDATE
  `emoji` = VALUES(`emoji`),
  `name_en` = VALUES(`name_en`),
  `name_de` = VALUES(`name_de`),
  `description_en` = VALUES(`description_en`),
  `description_de` = VALUES(`description_de`),
  `sort_order` = VALUES(`sort_order`);

INSERT IGNORE INTO `landing_group_categories` (`group_id`, `category_id`, `sort_order`)
SELECT
  lg.`id`,
  'content-creation-tools',
  COALESCE(MAX(lgc.`sort_order`), -1) + 1
FROM `landing_category_groups` lg
LEFT JOIN `landing_group_categories` lgc
  ON lgc.`group_id` = lg.`id`
WHERE lg.`slug` = 'ai-creative'
GROUP BY lg.`id`;

INSERT INTO `category_us_vendors` (`category_id`, `entry_id`, `raw_name`, `sort_order`)
VALUES
  ('content-creation-tools', NULL, 'Streamlabs', 0),
  ('content-creation-tools', NULL, 'Elgato', 1),
  ('content-creation-tools', NULL, 'Razer (StreamElements)', 2)
ON DUPLICATE KEY UPDATE
  `raw_name` = VALUES(`raw_name`);

INSERT IGNORE INTO `matrix_criterion_groups`
  (`category_id`, `group_key`, `label_en`, `label_de`, `description_en`, `description_de`, `sort_order`)
VALUES
  ('content-creation-tools', 'production_workflow', 'Production Workflow', 'Produktions-Workflow', 'Live production, recording, scene preparation, switching, and simultaneous output workflows.', 'Live-Produktion, Aufnahme, Szenenvorbereitung, Umschaltung und gleichzeitige Ausgabe-Workflows.', 100),
  ('content-creation-tools', 'sources_output', 'Sources & Output', 'Quellen & Ausgabe', 'Supported media sources, output protocols, streaming destinations, capture hardware, and output resolution.', 'Unterstützte Medienquellen, Ausgabeprotokolle, Streaming-Ziele, Aufnahme-Hardware und Ausgabeauflösung.', 200),
  ('content-creation-tools', 'audio_processing', 'Audio & Processing', 'Audio & Verarbeitung', 'Audio mixing, per-source controls, monitoring, processing, and isolated recording capabilities.', 'Audiomischung, quellenbezogene Steuerung, Monitoring, Verarbeitung und getrennte Aufnahmemöglichkeiten.', 300),
  ('content-creation-tools', 'overlays_engagement', 'Overlays & Engagement', 'Overlays & Interaktion', 'Overlay composition, alerts, chat, remote guests, and real-time audience interaction.', 'Overlay-Komposition, Benachrichtigungen, Chat, Remote-Gäste und Echtzeit-Interaktion mit dem Publikum.', 400),
  ('content-creation-tools', 'automation_integrations', 'Automation & Integrations', 'Automatisierung & Integrationen', 'Hotkeys, macros, hardware controls, plugins, scripting, and event-driven integrations.', 'Hotkeys, Makros, Hardware-Steuerung, Plugins, Skripting und ereignisgesteuerte Integrationen.', 500),
  ('content-creation-tools', 'platform_access', 'Platforms & Access', 'Plattformen & Zugriff', 'Supported platforms, offline operation, and portable project or profile data.', 'Unterstützte Plattformen, Offline-Betrieb und portable Projekt- oder Profildaten.', 600),
  ('content-creation-tools', 'privacy_openness', 'Privacy & Openness', 'Datenschutz & Offenheit', 'Account requirements, telemetry, processing location, source availability, and self-hosting.', 'Kontoanforderungen, Telemetrie, Verarbeitungsstandort, Quellcode-Verfügbarkeit und Self-Hosting.', 700),
  ('content-creation-tools', 'pricing_fit', 'Pricing & Fit', 'Preise & Eignung', 'Pricing structure, free access, and creator workflows the product is designed for.', 'Preisstruktur, kostenloser Zugang und Creator-Workflows, für die das Produkt ausgelegt ist.', 800);

INSERT IGNORE INTO `matrix_criteria`
  (`category_id`, `group_id`, `criterion_key`, `label_en`, `label_de`, `value_type`, `semantics`, `filter_mode`, `sort_order`, `help_text_en`, `help_text_de`)
SELECT d.`category_id`, g.`id`, d.`criterion_key`, d.`label_en`, d.`label_de`, d.`value_type`, d.`semantics`, d.`filter_mode`, d.`sort_order`, d.`help_text_en`, d.`help_text_de`
FROM (
  SELECT 'content-creation-tools' AS `category_id`, 'production_workflow' AS `group_key`, 'product_form' AS `criterion_key`, 'Product form' AS `label_en`, 'Produktform' AS `label_de`, 'multi_enum' AS `value_type`, 'informational' AS `semantics`, 'multi_select' AS `filter_mode`, 1010 AS `sort_order`, 'The software, service, or hardware forms in which the product provides content-production capabilities.' AS `help_text_en`, 'Die Software-, Dienst- oder Hardwareformen, in denen das Produkt Funktionen zur Content-Produktion bereitstellt.' AS `help_text_de`
  UNION ALL SELECT 'content-creation-tools', 'production_workflow', 'live_streaming', 'Live streaming', 'Live-Streaming', 'boolean', 'informational', 'must_match', 1020, 'Whether the product can produce or control a live broadcast in real time.', 'Ob das Produkt eine Live-Übertragung in Echtzeit produzieren oder steuern kann.'
  UNION ALL SELECT 'content-creation-tools', 'production_workflow', 'local_recording', 'Local recording', 'Lokale Aufnahme', 'boolean', 'beneficial', 'must_match', 1030, 'Whether video or audio can be recorded to local storage without relying on a hosted recording service.', 'Ob Video oder Audio lokal aufgezeichnet werden kann, ohne auf einen gehosteten Aufnahmedienst angewiesen zu sein.'
  UNION ALL SELECT 'content-creation-tools', 'production_workflow', 'scene_switching', 'Scene switching', 'Szenenwechsel', 'boolean', 'beneficial', 'optional', 1040, 'Whether creators can prepare multiple scenes and switch between them during production.', 'Ob Creator mehrere Szenen vorbereiten und während der Produktion zwischen ihnen wechseln können.'
  UNION ALL SELECT 'content-creation-tools', 'production_workflow', 'studio_preview', 'Preview / program workflow', 'Vorschau-/Programm-Workflow', 'boolean', 'beneficial', 'optional', 1050, 'Whether a scene can be previewed separately before it is sent to the live program output.', 'Ob eine Szene vor der Ausgabe im Live-Programm separat als Vorschau geprüft werden kann.'
  UNION ALL SELECT 'content-creation-tools', 'production_workflow', 'multi_destination_streaming', 'Multi-destination streaming', 'Streaming an mehrere Ziele', 'boolean', 'beneficial', 'optional', 1060, 'Whether one production can be sent to multiple streaming destinations at the same time.', 'Ob eine Produktion gleichzeitig an mehrere Streaming-Ziele gesendet werden kann.'
  UNION ALL SELECT 'content-creation-tools', 'sources_output', 'video_source_types', 'Video source types', 'Videoquellen-Typen', 'multi_enum', 'informational', 'multi_select', 2010, 'The kinds of visual sources that can be combined in a production.', 'Die Arten visueller Quellen, die in einer Produktion kombiniert werden können.'
  UNION ALL SELECT 'content-creation-tools', 'sources_output', 'output_protocols', 'Output protocols', 'Ausgabeprotokolle', 'multi_enum', 'informational', 'multi_select', 2020, 'The live media transport protocols the product can output directly.', 'Die Live-Medientransportprotokolle, die das Produkt direkt ausgeben kann.'
  UNION ALL SELECT 'content-creation-tools', 'sources_output', 'streaming_destinations', 'Streaming destinations', 'Streaming-Ziele', 'multi_enum', 'informational', 'multi_select', 2030, 'The hosted platforms or custom endpoints supported as direct live-stream destinations.', 'Die gehosteten Plattformen oder benutzerdefinierten Endpunkte, die als direkte Live-Streaming-Ziele unterstützt werden.'
  UNION ALL SELECT 'content-creation-tools', 'sources_output', 'virtual_camera', 'Virtual camera output', 'Virtuelle Kameraausgabe', 'boolean', 'informational', 'optional', 2040, 'Whether the composed program output can be exposed to other applications as a virtual camera.', 'Ob die zusammengestellte Programmausgabe anderen Anwendungen als virtuelle Kamera bereitgestellt werden kann.'
  UNION ALL SELECT 'content-creation-tools', 'sources_output', 'capture_hardware_support', 'Capture hardware support', 'Unterstützung für Aufnahme-Hardware', 'boolean', 'informational', 'optional', 2050, 'Whether external video-capture devices can be used as production sources.', 'Ob externe Videoaufnahmegeräte als Produktionsquellen verwendet werden können.'
  UNION ALL SELECT 'content-creation-tools', 'sources_output', 'max_output_resolution', 'Maximum output resolution', 'Maximale Ausgabeauflösung', 'enum', 'informational', 'optional', 2060, 'The highest documented resolution available for live output or local recording.', 'Die höchste dokumentierte Auflösung für Live-Ausgabe oder lokale Aufnahme.'
  UNION ALL SELECT 'content-creation-tools', 'audio_processing', 'audio_mixing', 'Audio mixing', 'Audiomischung', 'boolean', 'beneficial', 'optional', 3010, 'Whether multiple audio inputs can be mixed with independent levels during production.', 'Ob mehrere Audioeingänge während der Produktion mit unabhängigen Pegeln gemischt werden können.'
  UNION ALL SELECT 'content-creation-tools', 'audio_processing', 'per_source_audio_controls', 'Per-source audio controls', 'Audio-Steuerung je Quelle', 'boolean', 'beneficial', 'optional', 3020, 'Whether each audio source has separate mute, volume, balance, or routing controls.', 'Ob jede Audioquelle eigene Stumm-, Lautstärke-, Balance- oder Routing-Steuerungen besitzt.'
  UNION ALL SELECT 'content-creation-tools', 'audio_processing', 'audio_monitoring', 'Audio monitoring', 'Audio-Monitoring', 'boolean', 'beneficial', 'optional', 3030, 'Whether creators can monitor selected audio sources or the final program mix.', 'Ob Creator ausgewählte Audioquellen oder den finalen Programm-Mix abhören können.'
  UNION ALL SELECT 'content-creation-tools', 'audio_processing', 'audio_processing_features', 'Audio processing features', 'Audio-Verarbeitungsfunktionen', 'multi_enum', 'beneficial', 'multi_select', 3040, 'Built-in or supported processing for shaping, cleaning, and controlling live audio.', 'Integrierte oder unterstützte Verarbeitung zur Klanggestaltung, Bereinigung und Steuerung von Live-Audio.'
  UNION ALL SELECT 'content-creation-tools', 'audio_processing', 'isolated_audio_tracks', 'Isolated audio tracks', 'Getrennte Audiospuren', 'boolean', 'beneficial', 'optional', 3050, 'Whether individual audio sources can be recorded to separate tracks for later editing.', 'Ob einzelne Audioquellen zur späteren Bearbeitung auf getrennten Spuren aufgezeichnet werden können.'
  UNION ALL SELECT 'content-creation-tools', 'overlays_engagement', 'overlay_composition', 'Overlay composition', 'Overlay-Komposition', 'boolean', 'beneficial', 'optional', 4010, 'Whether graphical overlays can be layered over the program output.', 'Ob grafische Overlays über die Programmausgabe gelegt werden können.'
  UNION ALL SELECT 'content-creation-tools', 'overlays_engagement', 'custom_overlay_import', 'Custom overlay import', 'Import eigener Overlays', 'boolean', 'beneficial', 'optional', 4020, 'Whether creators can import or build custom overlay layouts rather than using only bundled templates.', 'Ob Creator eigene Overlay-Layouts importieren oder erstellen können, statt nur mitgelieferte Vorlagen zu verwenden.'
  UNION ALL SELECT 'content-creation-tools', 'overlays_engagement', 'stream_alerts', 'Stream alerts', 'Stream-Benachrichtigungen', 'boolean', 'informational', 'optional', 4030, 'Whether real-time events such as follows, subscriptions, or donations can trigger on-screen alerts.', 'Ob Echtzeit-Ereignisse wie Follows, Abonnements oder Spenden Bildschirm-Benachrichtigungen auslösen können.'
  UNION ALL SELECT 'content-creation-tools', 'overlays_engagement', 'chat_integration', 'Chat integration', 'Chat-Integration', 'boolean', 'informational', 'optional', 4040, 'Whether live chat can be monitored, moderated, or displayed inside the production workflow.', 'Ob Live-Chat im Produktions-Workflow verfolgt, moderiert oder angezeigt werden kann.'
  UNION ALL SELECT 'content-creation-tools', 'overlays_engagement', 'remote_guest_inputs', 'Remote guest inputs', 'Remote-Gastbeiträge', 'boolean', 'informational', 'optional', 4050, 'Whether remote guests can join and provide live audio or video sources.', 'Ob Remote-Gäste beitreten und Live-Audio- oder Videoquellen bereitstellen können.'
  UNION ALL SELECT 'content-creation-tools', 'overlays_engagement', 'audience_interaction', 'Audience interaction', 'Publikumsinteraktion', 'multi_enum', 'informational', 'multi_select', 4060, 'The real-time audience engagement mechanisms integrated into the production workflow.', 'Die in den Produktions-Workflow integrierten Mechanismen zur Echtzeit-Interaktion mit dem Publikum.'
  UNION ALL SELECT 'content-creation-tools', 'automation_integrations', 'hotkey_control', 'Hotkey control', 'Hotkey-Steuerung', 'boolean', 'beneficial', 'optional', 5010, 'Whether production actions can be assigned to keyboard shortcuts.', 'Ob Produktionsaktionen Tastenkürzeln zugewiesen werden können.'
  UNION ALL SELECT 'content-creation-tools', 'automation_integrations', 'macros_automation', 'Macros / automation', 'Makros / Automatisierung', 'boolean', 'beneficial', 'optional', 5020, 'Whether multiple actions or conditional production steps can be automated as one workflow.', 'Ob mehrere Aktionen oder bedingte Produktionsschritte als ein Workflow automatisiert werden können.'
  UNION ALL SELECT 'content-creation-tools', 'automation_integrations', 'hardware_control', 'Hardware control surfaces', 'Hardware-Bedienoberflächen', 'boolean', 'beneficial', 'optional', 5030, 'Whether physical control surfaces can trigger scenes, sources, audio, or automation actions.', 'Ob physische Bedienoberflächen Szenen, Quellen, Audio- oder Automatisierungsaktionen auslösen können.'
  UNION ALL SELECT 'content-creation-tools', 'automation_integrations', 'plugin_ecosystem', 'Plugin / extension ecosystem', 'Plugin-/Erweiterungs-Ökosystem', 'boolean', 'beneficial', 'optional', 5040, 'Whether third-party plugins or extensions can add production features or integrations.', 'Ob Drittanbieter-Plugins oder Erweiterungen Produktionsfunktionen oder Integrationen hinzufügen können.'
  UNION ALL SELECT 'content-creation-tools', 'automation_integrations', 'scripting_api', 'Scripting / API access', 'Skripting / API-Zugang', 'boolean', 'beneficial', 'optional', 5050, 'Whether a documented scripting interface or API supports custom automation.', 'Ob eine dokumentierte Skript-Schnittstelle oder API benutzerdefinierte Automatisierung unterstützt.'
  UNION ALL SELECT 'content-creation-tools', 'automation_integrations', 'webhook_events', 'Webhook events', 'Webhook-Ereignisse', 'boolean', 'beneficial', 'optional', 5060, 'Whether external services can trigger or receive production events through webhooks.', 'Ob externe Dienste Produktionsereignisse über Webhooks auslösen oder empfangen können.'
  UNION ALL SELECT 'content-creation-tools', 'platform_access', 'supported_platforms', 'Supported platforms', 'Unterstützte Plattformen', 'multi_enum', 'informational', 'multi_select', 6010, 'The operating systems, web environments, mobile devices, or standalone hardware on which the product runs.', 'Die Betriebssysteme, Web-Umgebungen, Mobilgeräte oder eigenständige Hardware, auf denen das Produkt läuft.'
  UNION ALL SELECT 'content-creation-tools', 'platform_access', 'offline_core_workflow', 'Offline core workflow', 'Offline-Kernworkflow', 'boolean', 'beneficial', 'must_match', 6020, 'Whether core composition and recording functions remain usable without an internet connection.', 'Ob zentrale Kompositions- und Aufnahmefunktionen ohne Internetverbindung nutzbar bleiben.'
  UNION ALL SELECT 'content-creation-tools', 'platform_access', 'project_profile_export', 'Project / profile export', 'Projekt-/Profil-Export', 'boolean', 'beneficial', 'optional', 6030, 'Whether scenes, profiles, or project configuration can be exported in a reusable form.', 'Ob Szenen, Profile oder Projektkonfigurationen in wiederverwendbarer Form exportiert werden können.'
  UNION ALL SELECT 'content-creation-tools', 'privacy_openness', 'account_requirement', 'Account requirement', 'Kontoanforderung', 'enum', 'risk', 'must_match', 7010, 'When a vendor account is required for setup, local use, streaming, or cloud features.', 'Wann ein Anbieterkonto für Einrichtung, lokale Nutzung, Streaming oder Cloud-Funktionen erforderlich ist.'
  UNION ALL SELECT 'content-creation-tools', 'privacy_openness', 'telemetry_model', 'Telemetry model', 'Telemetrie-Modell', 'enum', 'risk', 'optional', 7020, 'How usage analytics or diagnostic telemetry is collected and controlled.', 'Wie Nutzungsanalysen oder Diagnose-Telemetrie erfasst und gesteuert werden.'
  UNION ALL SELECT 'content-creation-tools', 'privacy_openness', 'data_processing_location', 'Data processing location', 'Datenverarbeitungsstandort', 'enum', 'informational', 'optional', 7030, 'Where cloud-hosted production, account, or audience data is documented as being processed.', 'Wo cloudbasierte Produktions-, Konto- oder Publikumsdaten laut Dokumentation verarbeitet werden.'
  UNION ALL SELECT 'content-creation-tools', 'privacy_openness', 'source_model', 'Source model', 'Quellcode-Modell', 'enum', 'tradeoff', 'must_match', 7040, 'Whether the relevant software is open source, source available, mixed, or proprietary.', 'Ob die relevante Software Open Source, quelloffen einsehbar, gemischt oder proprietär ist.'
  UNION ALL SELECT 'content-creation-tools', 'privacy_openness', 'self_hostable', 'Self-hostable services', 'Selbst hostbare Dienste', 'boolean', 'beneficial', 'optional', 7050, 'Whether server-side overlay, automation, or collaboration services can be deployed on user-controlled infrastructure.', 'Ob serverseitige Overlay-, Automatisierungs- oder Zusammenarbeitsdienste auf nutzerkontrollierter Infrastruktur betrieben werden können.'
  UNION ALL SELECT 'content-creation-tools', 'pricing_fit', 'pricing_model', 'Pricing model', 'Preismodell', 'enum', 'informational', 'optional', 8010, 'The primary way the product is paid for, including software plans and hardware purchases.', 'Die primäre Zahlungsform des Produkts, einschließlich Softwaretarifen und Hardwarekäufen.'
  UNION ALL SELECT 'content-creation-tools', 'pricing_fit', 'free_tier_available', 'Free tier available', 'Kostenlose Stufe verfügbar', 'boolean', 'informational', 'must_match', 8020, 'Whether a useful version can be used without payment or a hardware purchase.', 'Ob eine brauchbare Version ohne Zahlung oder Hardwarekauf genutzt werden kann.'
  UNION ALL SELECT 'content-creation-tools', 'pricing_fit', 'fit_profiles', 'Fit profiles', 'Eignungsprofile', 'multi_enum', 'informational', 'multi_select', 8030, 'The creator and production workflows for which the product is designed.', 'Die Creator- und Produktions-Workflows, für die das Produkt ausgelegt ist.'
) AS d
JOIN `matrix_criterion_groups` g
  ON g.`category_id` = d.`category_id`
 AND g.`group_key` = d.`group_key`;

INSERT IGNORE INTO `matrix_criterion_options`
  (`criterion_id`, `option_key`, `label_en`, `label_de`, `display_tone`, `sort_order`)
SELECT mc.`id`, d.`option_key`, d.`label_en`, d.`label_de`, d.`display_tone`, d.`sort_order`
FROM (
  SELECT 'content-creation-tools' AS `category_id`, 'product_form' AS `criterion_key`, 'desktop_software' AS `option_key`, 'Desktop software' AS `label_en`, 'Desktop-Software' AS `label_de`, 'neutral' AS `display_tone`, 10 AS `sort_order`
  UNION ALL SELECT 'content-creation-tools', 'product_form', 'cloud_service', 'Cloud service', 'Cloud-Dienst', 'tradeoff', 20
  UNION ALL SELECT 'content-creation-tools', 'product_form', 'mobile_app', 'Mobile app', 'Mobile App', 'neutral', 30
  UNION ALL SELECT 'content-creation-tools', 'product_form', 'hardware_controller', 'Hardware controller', 'Hardware-Controller', 'neutral', 40
  UNION ALL SELECT 'content-creation-tools', 'product_form', 'capture_hardware', 'Capture hardware', 'Aufnahme-Hardware', 'neutral', 50
  UNION ALL SELECT 'content-creation-tools', 'product_form', 'audio_hardware', 'Audio hardware', 'Audio-Hardware', 'neutral', 60
  UNION ALL SELECT 'content-creation-tools', 'video_source_types', 'camera', 'Camera', 'Kamera', 'neutral', 10
  UNION ALL SELECT 'content-creation-tools', 'video_source_types', 'screen_capture', 'Screen capture', 'Bildschirmaufnahme', 'neutral', 20
  UNION ALL SELECT 'content-creation-tools', 'video_source_types', 'window_capture', 'Window capture', 'Fensteraufnahme', 'neutral', 30
  UNION ALL SELECT 'content-creation-tools', 'video_source_types', 'media_file', 'Media file', 'Mediendatei', 'neutral', 40
  UNION ALL SELECT 'content-creation-tools', 'video_source_types', 'browser_source', 'Browser source', 'Browser-Quelle', 'neutral', 50
  UNION ALL SELECT 'content-creation-tools', 'video_source_types', 'network_video', 'Network video', 'Netzwerkvideo', 'neutral', 60
  UNION ALL SELECT 'content-creation-tools', 'output_protocols', 'rtmp', 'RTMP', 'RTMP', 'neutral', 10
  UNION ALL SELECT 'content-creation-tools', 'output_protocols', 'rtmps', 'RTMPS', 'RTMPS', 'positive', 20
  UNION ALL SELECT 'content-creation-tools', 'output_protocols', 'srt', 'SRT', 'SRT', 'positive', 30
  UNION ALL SELECT 'content-creation-tools', 'output_protocols', 'rist', 'RIST', 'RIST', 'positive', 40
  UNION ALL SELECT 'content-creation-tools', 'output_protocols', 'webrtc', 'WebRTC', 'WebRTC', 'neutral', 50
  UNION ALL SELECT 'content-creation-tools', 'streaming_destinations', 'twitch', 'Twitch', 'Twitch', 'neutral', 10
  UNION ALL SELECT 'content-creation-tools', 'streaming_destinations', 'youtube_live', 'YouTube Live', 'YouTube Live', 'neutral', 20
  UNION ALL SELECT 'content-creation-tools', 'streaming_destinations', 'facebook_live', 'Facebook Live', 'Facebook Live', 'neutral', 30
  UNION ALL SELECT 'content-creation-tools', 'streaming_destinations', 'kick', 'Kick', 'Kick', 'neutral', 40
  UNION ALL SELECT 'content-creation-tools', 'streaming_destinations', 'custom_endpoint', 'Custom endpoint', 'Benutzerdefinierter Endpunkt', 'positive', 50
  UNION ALL SELECT 'content-creation-tools', 'max_output_resolution', 'hd', 'HD (720p)', 'HD (720p)', 'neutral', 10
  UNION ALL SELECT 'content-creation-tools', 'max_output_resolution', 'full_hd', 'Full HD (1080p)', 'Full HD (1080p)', 'neutral', 20
  UNION ALL SELECT 'content-creation-tools', 'max_output_resolution', 'qhd', 'QHD (1440p)', 'QHD (1440p)', 'neutral', 30
  UNION ALL SELECT 'content-creation-tools', 'max_output_resolution', 'uhd_4k', 'UHD 4K', 'UHD 4K', 'positive', 40
  UNION ALL SELECT 'content-creation-tools', 'max_output_resolution', 'above_4k', 'Above 4K', 'Über 4K', 'positive', 50
  UNION ALL SELECT 'content-creation-tools', 'audio_processing_features', 'equalizer', 'Equalizer', 'Equalizer', 'neutral', 10
  UNION ALL SELECT 'content-creation-tools', 'audio_processing_features', 'noise_suppression', 'Noise suppression', 'Rauschunterdrückung', 'positive', 20
  UNION ALL SELECT 'content-creation-tools', 'audio_processing_features', 'compressor', 'Compressor', 'Kompressor', 'neutral', 30
  UNION ALL SELECT 'content-creation-tools', 'audio_processing_features', 'limiter', 'Limiter', 'Limiter', 'neutral', 40
  UNION ALL SELECT 'content-creation-tools', 'audio_processing_features', 'noise_gate', 'Noise gate', 'Noise Gate', 'neutral', 50
  UNION ALL SELECT 'content-creation-tools', 'audio_processing_features', 'plugin_processing', 'Plugin processing', 'Plugin-Verarbeitung', 'positive', 60
  UNION ALL SELECT 'content-creation-tools', 'audience_interaction', 'polls', 'Polls', 'Umfragen', 'neutral', 10
  UNION ALL SELECT 'content-creation-tools', 'audience_interaction', 'chat_commands', 'Chat commands', 'Chat-Befehle', 'neutral', 20
  UNION ALL SELECT 'content-creation-tools', 'audience_interaction', 'donation_events', 'Donation events', 'Spendenereignisse', 'neutral', 30
  UNION ALL SELECT 'content-creation-tools', 'audience_interaction', 'viewer_games', 'Viewer games', 'Zuschauerspiele', 'neutral', 40
  UNION ALL SELECT 'content-creation-tools', 'supported_platforms', 'windows', 'Windows', 'Windows', 'neutral', 10
  UNION ALL SELECT 'content-creation-tools', 'supported_platforms', 'macos', 'macOS', 'macOS', 'neutral', 20
  UNION ALL SELECT 'content-creation-tools', 'supported_platforms', 'linux', 'Linux', 'Linux', 'positive', 30
  UNION ALL SELECT 'content-creation-tools', 'supported_platforms', 'web', 'Web', 'Web', 'neutral', 40
  UNION ALL SELECT 'content-creation-tools', 'supported_platforms', 'ios', 'iOS', 'iOS', 'neutral', 50
  UNION ALL SELECT 'content-creation-tools', 'supported_platforms', 'android', 'Android', 'Android', 'neutral', 60
  UNION ALL SELECT 'content-creation-tools', 'supported_platforms', 'standalone_hardware', 'Standalone hardware', 'Eigenständige Hardware', 'neutral', 70
  UNION ALL SELECT 'content-creation-tools', 'account_requirement', 'no_account', 'No account', 'Kein Konto', 'positive', 10
  UNION ALL SELECT 'content-creation-tools', 'account_requirement', 'optional_account', 'Optional account', 'Optionales Konto', 'neutral', 20
  UNION ALL SELECT 'content-creation-tools', 'account_requirement', 'required_for_cloud', 'Required for cloud features', 'Für Cloud-Funktionen erforderlich', 'tradeoff', 30
  UNION ALL SELECT 'content-creation-tools', 'account_requirement', 'required_for_core_use', 'Required for core use', 'Für Kernnutzung erforderlich', 'warning', 40
  UNION ALL SELECT 'content-creation-tools', 'telemetry_model', 'none', 'None', 'Keine', 'positive', 10
  UNION ALL SELECT 'content-creation-tools', 'telemetry_model', 'opt_in', 'Opt-in', 'Opt-in', 'neutral', 20
  UNION ALL SELECT 'content-creation-tools', 'telemetry_model', 'opt_out', 'Opt-out', 'Opt-out', 'warning', 30
  UNION ALL SELECT 'content-creation-tools', 'telemetry_model', 'mandatory', 'Mandatory', 'Verpflichtend', 'negative', 40
  UNION ALL SELECT 'content-creation-tools', 'telemetry_model', 'not_disclosed', 'Not disclosed', 'Nicht offengelegt', 'warning', 50
  UNION ALL SELECT 'content-creation-tools', 'data_processing_location', 'local_only', 'Local only', 'Nur lokal', 'positive', 10
  UNION ALL SELECT 'content-creation-tools', 'data_processing_location', 'eu_eea', 'EU / EEA', 'EU / EWR', 'positive', 20
  UNION ALL SELECT 'content-creation-tools', 'data_processing_location', 'europe_non_eu', 'European non-EU', 'Europäisch, nicht EU', 'neutral', 30
  UNION ALL SELECT 'content-creation-tools', 'data_processing_location', 'global', 'Global / multiple regions', 'Global / mehrere Regionen', 'tradeoff', 40
  UNION ALL SELECT 'content-creation-tools', 'data_processing_location', 'not_disclosed', 'Not disclosed', 'Nicht offengelegt', 'warning', 50
  UNION ALL SELECT 'content-creation-tools', 'source_model', 'open_source', 'Open source', 'Open Source', 'positive', 10
  UNION ALL SELECT 'content-creation-tools', 'source_model', 'source_available', 'Source available', 'Quelloffen einsehbar', 'tradeoff', 20
  UNION ALL SELECT 'content-creation-tools', 'source_model', 'mixed', 'Mixed open / proprietary', 'Gemischt offen / proprietär', 'tradeoff', 30
  UNION ALL SELECT 'content-creation-tools', 'source_model', 'proprietary', 'Proprietary', 'Proprietär', 'warning', 40
  UNION ALL SELECT 'content-creation-tools', 'pricing_model', 'free', 'Free', 'Kostenlos', 'positive', 10
  UNION ALL SELECT 'content-creation-tools', 'pricing_model', 'freemium', 'Freemium', 'Freemium', 'neutral', 20
  UNION ALL SELECT 'content-creation-tools', 'pricing_model', 'one_time_purchase', 'One-time purchase', 'Einmalkauf', 'neutral', 30
  UNION ALL SELECT 'content-creation-tools', 'pricing_model', 'subscription', 'Subscription', 'Abonnement', 'tradeoff', 40
  UNION ALL SELECT 'content-creation-tools', 'pricing_model', 'hardware_purchase', 'Hardware purchase', 'Hardwarekauf', 'neutral', 50
  UNION ALL SELECT 'content-creation-tools', 'pricing_model', 'mixed', 'Mixed', 'Gemischt', 'tradeoff', 60
  UNION ALL SELECT 'content-creation-tools', 'fit_profiles', 'solo_creators', 'Solo creators', 'Solo-Creator', 'neutral', 10
  UNION ALL SELECT 'content-creation-tools', 'fit_profiles', 'gaming_streams', 'Gaming streams', 'Gaming-Streams', 'neutral', 20
  UNION ALL SELECT 'content-creation-tools', 'fit_profiles', 'live_events', 'Live events', 'Live-Events', 'neutral', 30
  UNION ALL SELECT 'content-creation-tools', 'fit_profiles', 'podcasts', 'Podcasts', 'Podcasts', 'neutral', 40
  UNION ALL SELECT 'content-creation-tools', 'fit_profiles', 'video_production', 'Video production', 'Videoproduktion', 'neutral', 50
  UNION ALL SELECT 'content-creation-tools', 'fit_profiles', 'education_business', 'Education / business', 'Bildung / Unternehmen', 'neutral', 60
) AS d
JOIN `matrix_criteria` mc
  ON mc.`category_id` = d.`category_id`
 AND mc.`criterion_key` = d.`criterion_key`;

-- Populate placeholders only for catalog entries that are separately accepted
-- and explicitly assigned to this category. This migration does not create or
-- assert facts about any benchmark or proposed alternative.
INSERT IGNORE INTO `matrix_facts` (`entry_id`, `category_id`, `criterion_id`, `status`)
SELECT
  ce.`id`,
  mc.`category_id`,
  mc.`id`,
  'open'
FROM `catalog_entries` ce
JOIN `entry_categories` ec
  ON ec.`entry_id` = ce.`id`
 AND ec.`category_id` = 'content-creation-tools'
JOIN `matrix_criteria` mc
  ON mc.`category_id` = 'content-creation-tools'
WHERE ce.`status` IN ('alternative', 'us')
  AND ce.`is_active` = 1;

INSERT INTO `schema_migrations` (`version`)
VALUES ('094-content-creation-tools-category-matrix')
ON DUPLICATE KEY UPDATE `version` = VALUES(`version`);

COMMIT;
