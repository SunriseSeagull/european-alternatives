import { existsSync, readFileSync } from "node:fs";

import { describe, expect, it } from "vitest";

const categoryId = "content-creation-tools";
const migrationVersion = "094-content-creation-tools-category-matrix";
const migrationUrl = new URL(
  "../scripts/migrations/094-content-creation-tools-category-matrix.sql",
  import.meta.url,
);
const migrationExists = existsSync(migrationUrl);
const sql = migrationExists ? readFileSync(migrationUrl, "utf8") : "";
const normalizedSql = sql.replace(/--[^\n]*(?:\n|$)/g, " ").replace(/\s+/g, " ").trim();

const expectedGroups = [
  "production_workflow",
  "sources_output",
  "audio_processing",
  "overlays_engagement",
  "automation_integrations",
  "platform_access",
  "privacy_openness",
  "pricing_fit",
];

const expectedCriteria = [
  "product_form",
  "live_streaming",
  "local_recording",
  "scene_switching",
  "studio_preview",
  "multi_destination_streaming",
  "video_source_types",
  "output_protocols",
  "streaming_destinations",
  "virtual_camera",
  "capture_hardware_support",
  "max_output_resolution",
  "audio_mixing",
  "per_source_audio_controls",
  "audio_monitoring",
  "audio_processing_features",
  "isolated_audio_tracks",
  "overlay_composition",
  "custom_overlay_import",
  "stream_alerts",
  "chat_integration",
  "remote_guest_inputs",
  "audience_interaction",
  "hotkey_control",
  "macros_automation",
  "hardware_control",
  "plugin_ecosystem",
  "scripting_api",
  "webhook_events",
  "supported_platforms",
  "offline_core_workflow",
  "project_profile_export",
  "account_requirement",
  "telemetry_model",
  "data_processing_location",
  "source_model",
  "self_hostable",
  "pricing_model",
  "free_tier_available",
  "fit_profiles",
];

const optionBackedCriteria = [
  "product_form",
  "video_source_types",
  "output_protocols",
  "streaming_destinations",
  "max_output_resolution",
  "audio_processing_features",
  "audience_interaction",
  "supported_platforms",
  "account_requirement",
  "telemetry_model",
  "data_processing_location",
  "source_model",
  "pricing_model",
  "fit_profiles",
];

function expectLiteral(value: string): void {
  expect(sql).toContain(`'${value}'`);
}

function expectCriterionKey(key: string): void {
  const firstRow = sql.includes(`'${key}' AS \`criterion_key\``);
  const unionRow = sql.includes(`'${key}',`);

  expect(firstRow || unionRow, `Expected criterion ${key}`).toBe(true);
}

describe("content-creation tools category and matrix migration", () => {
  it("adds the issue-defined category to the creative landing group", () => {
    expect(migrationExists).toBe(true);
    expect(normalizedSql).toMatch(/INSERT\s+INTO\s+`categories`/i);
    expectLiteral(categoryId);
    expectLiteral("🎛️");
    expectLiteral("Content-Creation Tools");
    expect(sql).toContain(
      "Software and hardware designed to simplify and enhance the production of live streams, videos, and interactive content.",
    );
    expect(normalizedSql).toMatch(
      /INSERT\s+IGNORE\s+INTO\s+`landing_group_categories`/i,
    );
    expect(sql).toContain("lg.`slug` = 'ai-creative'");
  });

  it("keeps the submitted benchmarks as labels without inventing catalog products", () => {
    expect(normalizedSql).toMatch(/INSERT\s+INTO\s+`category_us_vendors`/i);

    for (const [name, order] of [
      ["Streamlabs", 0],
      ["Elgato", 1],
      ["Razer (StreamElements)", 2],
    ] as const) {
      expect(normalizedSql).toMatch(
        new RegExp(
          `'${name.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}'\\s*,\\s*${order}`,
          "i",
        ),
      );
    }

    expect(normalizedSql).toMatch(
      /\('content-creation-tools',\s*NULL,\s*'Streamlabs',\s*0\)/i,
    );
    expect(normalizedSql).not.toMatch(/INSERT\s+(?:IGNORE\s+)?INTO\s+`catalog_entries`/i);
    expect(normalizedSql).not.toMatch(/INSERT\s+(?:IGNORE\s+)?INTO\s+`entry_categories`/i);
    expect(normalizedSql).not.toMatch(/INSERT\s+(?:IGNORE\s+)?INTO\s+`entry_replacements`/i);
  });

  it("defines a category-specific matrix for production, engagement, and trust tradeoffs", () => {
    expect(normalizedSql).toMatch(/INSERT\s+IGNORE\s+INTO\s+`matrix_criterion_groups`/i);
    expect(normalizedSql).toMatch(/INSERT\s+IGNORE\s+INTO\s+`matrix_criteria`/i);
    expect(normalizedSql).toMatch(/JOIN\s+`matrix_criterion_groups`\s+g/i);
    expect(normalizedSql).toMatch(/g\.`category_id`\s*=\s*d\.`category_id`/i);
    expect(normalizedSql).toMatch(/g\.`group_key`\s*=\s*d\.`group_key`/i);

    for (const groupKey of expectedGroups) {
      expectLiteral(groupKey);
    }

    for (const criterionKey of expectedCriteria) {
      expectCriterionKey(criterionKey);
    }

    expect(new Set(expectedCriteria).size).toBe(40);
  });

  it("provides explicit options for every enum and multi-enum criterion", () => {
    expect(normalizedSql).toMatch(/INSERT\s+IGNORE\s+INTO\s+`matrix_criterion_options`/i);
    expect(normalizedSql).toMatch(/JOIN\s+`matrix_criteria`\s+mc/i);
    expect(normalizedSql).toMatch(/mc\.`category_id`\s*=\s*d\.`category_id`/i);
    expect(normalizedSql).toMatch(/mc\.`criterion_key`\s*=\s*d\.`criterion_key`/i);

    for (const criterionKey of optionBackedCriteria) {
      const occurrences = sql.split(`'${criterionKey}'`).length - 1;
      expect(
        occurrences,
        `Expected option rows for ${criterionKey}`,
      ).toBeGreaterThanOrEqual(2);
    }

    for (const optionKey of [
      "desktop_software",
      "capture_hardware",
      "browser_source",
      "rtmps",
      "custom_endpoint",
      "uhd_4k",
      "noise_suppression",
      "chat_commands",
      "standalone_hardware",
      "required_for_core_use",
      "local_only",
      "open_source",
      "hardware_purchase",
      "live_events",
    ]) {
      expectLiteral(optionKey);
    }

    expect(sql).not.toContain("'unknown'");
  });

  it("initializes only open placeholders for separately accepted category members", () => {
    expect(normalizedSql).toMatch(
      /INSERT\s+IGNORE\s+INTO\s+`matrix_facts`\s+\(`entry_id`,\s*`category_id`,\s*`criterion_id`,\s*`status`\)/i,
    );
    expect(normalizedSql).toMatch(
      /ec\.`category_id`\s*=\s*'content-creation-tools'/i,
    );
    expect(normalizedSql).toMatch(
      /ce\.`status`\s+IN\s+\('alternative',\s*'us'\)/i,
    );
    expect(normalizedSql).toMatch(/ce\.`is_active`\s*=\s*1/i);
    expect(normalizedSql).toMatch(/'open'/i);

    for (const unsupportedFact of [
      "trust_score",
      "reservations",
      "positive_signals",
      "scoring_metadata",
      "value_bool",
      "value_number",
      "value_text",
      "value_json",
      "public_source_url",
    ]) {
      expect(normalizedSql).not.toMatch(
        new RegExp(`\\b${unsupportedFact}\\b`, "i"),
      );
    }
  });

  it("is transactional and records an idempotent forward-only version", () => {
    expect(normalizedSql).toMatch(/^START\s+TRANSACTION\s*;/i);
    expect(normalizedSql).toMatch(/ON\s+DUPLICATE\s+KEY\s+UPDATE[\s\S]*`sort_order`\s*=\s*VALUES\(`sort_order`\)/i);
    expect(normalizedSql).toMatch(
      new RegExp(
        `INSERT\\s+INTO\\s+\`schema_migrations\`\\s+\\(\`version\`\\)\\s+VALUES\\s+\\('${migrationVersion}'\\)\\s+ON\\s+DUPLICATE\\s+KEY\\s+UPDATE`,
        "i",
      ),
    );
    expect(normalizedSql).toMatch(/COMMIT\s*;$/i);
  });
});

describe("content-creation tools frontend metadata", () => {
  const types = readFileSync(
    new URL("../src/types/index.ts", import.meta.url),
    "utf8",
  );
  const enData = JSON.parse(
    readFileSync(new URL("../src/i18n/locales/en/data.json", import.meta.url), "utf8"),
  );
  const deData = JSON.parse(
    readFileSync(new URL("../src/i18n/locales/de/data.json", import.meta.url), "utf8"),
  );
  const enLanding = JSON.parse(
    readFileSync(new URL("../src/i18n/locales/en/landing.json", import.meta.url), "utf8"),
  );
  const deLanding = JSON.parse(
    readFileSync(new URL("../src/i18n/locales/de/landing.json", import.meta.url), "utf8"),
  );
  const contributing = readFileSync(
    new URL("../CONTRIBUTING.md", import.meta.url),
    "utf8",
  );

  it("adds the category type and English and German localization", () => {
    expect(types).toContain('| "content-creation-tools"');
    expect(enData.categories[categoryId]).toEqual({
      name: "Content-Creation Tools",
      description: "Software and hardware for live streams, videos, and interactive content",
    });
    expect(deData.categories[categoryId]).toEqual({
      name: "Content-Creation-Tools",
      description: "Software und Hardware für Livestreams, Videos und interaktive Inhalte",
    });
  });

  it("describes the expanded creative group and contributor-facing category", () => {
    expect(enLanding.categoryGroups["ai-creative"].description).toContain(
      "content-production tools",
    );
    expect(deLanding.categoryGroups["ai-creative"].description).toContain(
      "Content-Produktion",
    );
    expect(contributing).toContain("`content-creation-tools`");
    expect(contributing).toContain("Streamlabs, Elgato, Razer (StreamElements)");
  });
});
