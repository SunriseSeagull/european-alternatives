import { readdirSync, readFileSync } from "node:fs";

import { describe, expect, it } from "vitest";

// Categories come from the database, but their names are rendered through
// `data:categories.<id>.name`. A category migration without the matching
// locale entries shows a raw i18n key on the landing and browse pages.

const migrationsDir = new URL("../scripts/migrations/", import.meta.url);

function readJson(relativePath: string): { categories: Record<string, { name?: string; description?: string }> } {
  return JSON.parse(readFileSync(new URL(relativePath, import.meta.url), "utf8"));
}

function categoryIdsFromMigrations(): string[] {
  const ids = new Set<string>();

  for (const file of readdirSync(migrationsDir).filter((name) => name.endsWith(".sql"))) {
    const sql = readFileSync(new URL(file, migrationsDir), "utf8");
    const pattern = /INSERT\s+(?:IGNORE\s+)?INTO\s+`categories`\s*\([^)]*\)\s*VALUES\s*\(\s*'([^']+)'/gi;

    for (const match of sql.matchAll(pattern)) {
      ids.add(match[1]);
    }
  }

  return [...ids].sort();
}

function categoryIdsFromType(): string[] {
  const types = readFileSync(new URL("../src/types/index.ts", import.meta.url), "utf8");
  const union = types.match(/export type CategoryId\s*=([^;]+);/);

  expect(union, "CategoryId union in src/types/index.ts").not.toBeNull();

  return [...union![1].matchAll(/"([^"]+)"/g)].map((match) => match[1]);
}

const locales = {
  en: readJson("../src/i18n/locales/en/data.json").categories,
  de: readJson("../src/i18n/locales/de/data.json").categories,
};

describe("category i18n coverage", () => {
  const migrationIds = categoryIdsFromMigrations();
  const typeIds = categoryIdsFromType();
  const allIds = [...new Set([...typeIds, ...migrationIds])];

  it("finds the categories added by migrations", () => {
    expect(migrationIds).toEqual(
      expect.arrayContaining(["content-creation-tools", "e-readers", "game-stores"]),
    );
  });

  it("lists every migration-added category in the CategoryId type", () => {
    expect(migrationIds.filter((id) => !typeIds.includes(id))).toEqual([]);
  });

  it.each(Object.entries(locales))(
    "has %s name and description for every known category",
    (_locale, categories) => {
      const missing = allIds.filter(
        (id) => !categories[id]?.name?.trim() || !categories[id]?.description?.trim(),
      );

      expect(missing).toEqual([]);
    },
  );
});
