"""
Экспорт данных из Neon PostgreSQL в SQL файл
Не требует pg_dump - использует чистый Python
"""
import psycopg2
import json
from datetime import datetime, date
from decimal import Decimal
import uuid

DB_URL = "postgresql://neondb_owner:npg_mRMN7C3ohGHz@ep-restless-pond-af40wky4-pooler.c-2.us-west-2.aws.neon.tech/neondb?sslmode=require"

OUTPUT_FILE = "neon_export.sql"

def serialize_value(val):
    """Конвертирует Python значение в SQL литерал"""
    if val is None:
        return "NULL"
    elif isinstance(val, bool):
        return "TRUE" if val else "FALSE"
    elif isinstance(val, (int, float, Decimal)):
        return str(val)
    elif isinstance(val, (datetime, date)):
        return f"'{val.isoformat()}'"
    elif isinstance(val, uuid.UUID):
        return f"'{str(val)}'"
    elif isinstance(val, dict):
        return f"'{json.dumps(val, ensure_ascii=False).replace(chr(39), chr(39)+chr(39))}'"
    elif isinstance(val, list):
        return f"'{json.dumps(val, ensure_ascii=False).replace(chr(39), chr(39)+chr(39))}'"
    else:
        # Строка - экранируем кавычки
        escaped = str(val).replace("'", "''")
        return f"'{escaped}'"

def export_table(cur, table_name, f):
    """Экспортирует одну таблицу"""
    try:
        # Получаем данные
        cur.execute(f'SELECT * FROM "{table_name}"')
        rows = cur.fetchall()
        
        if not rows:
            print(f"  {table_name}: 0 rows (skipped)")
            return 0
        
        # Получаем имена колонок
        columns = [desc[0] for desc in cur.description]
        
        f.write(f"\n-- Table: {table_name}\n")
        f.write(f"-- Rows: {len(rows)}\n")
        
        for row in rows:
            values = [serialize_value(v) for v in row]
            cols_str = ", ".join([f'"{c}"' for c in columns])
            vals_str = ", ".join(values)
            f.write(f'INSERT INTO "{table_name}" ({cols_str}) VALUES ({vals_str}) ON CONFLICT DO NOTHING;\n')
        
        print(f"  {table_name}: {len(rows)} rows")
        return len(rows)
        
    except Exception as e:
        print(f"  {table_name}: ERROR - {e}")
        return 0

def main():
    print("=== Neon Database Export ===\n")
    
    # Важные таблицы для экспорта (в порядке зависимостей)
    tables_to_export = [
        "city",
        "tour",
        "poi", 
        "tour_items",
        "tour_media",
        "poi_media",
        "narrations",
        "users",
        "roles",
        "permissions",
        "role_permissions",
        "entitlements",
        "entitlement_grants",
        "purchases",
        "qr_mappings",
    ]
    
    print("Connecting to Neon...")
    conn = psycopg2.connect(DB_URL)
    cur = conn.cursor()
    print("Connected!\n")
    
    total_rows = 0
    
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        f.write("-- Neon Database Export\n")
        f.write(f"-- Generated: {datetime.now().isoformat()}\n")
        f.write("-- Source: Neon PostgreSQL\n\n")
        f.write("SET client_encoding = 'UTF8';\n")
        f.write("SET standard_conforming_strings = on;\n\n")
        
        print("Exporting tables:")
        for table in tables_to_export:
            rows = export_table(cur, table, f)
            total_rows += rows
    
    conn.close()
    
    print(f"\n=== Export Complete ===")
    print(f"Total rows: {total_rows}")
    print(f"Output file: {OUTPUT_FILE}")

if __name__ == "__main__":
    main()
