/* Меняет у всех функций схем 'smfd%' и 'module__%' владельца на smfd */
CREATE OR REPLACE FUNCTION public.dba__alter_funcs_owner_smfd() RETURNS INT
    LANGUAGE plpgsql AS
$$
DECLARE
    rec RECORD;
BEGIN
    FOR rec IN (
        SELECT 'alter function ' || nsp.nspname || '.' || p.proname || '(' ||
               pg_get_function_identity_arguments(p.oid) || ') owner to smfd;' AS sql_query
        FROM pg_namespace nsp
                 JOIN pg_proc p ON p.pronamespace = nsp.OID
        WHERE nsp.nspname LIKE 'smfd%'
           OR nsp.nspname LIKE 'module\_%' ESCAPE '\'
    )
        LOOP
            BEGIN
                EXECUTE rec.sql_query;
                RAISE NOTICE 'query: %', rec.sql_query;
            EXCEPTION
                WHEN insufficient_privilege
                    THEN NULL;
            END;
        END LOOP;
    RETURN 0;
END;
$$;

/* Меняет у всех таблиц и их сиквенсов схем 'smfd%' и 'module_%' владельца на smfd */
CREATE OR REPLACE FUNCTION public.dba__alter_tables_owner_smfd() RETURNS INT
    LANGUAGE plpgsql AS
$$
DECLARE
    rec RECORD;
BEGIN
    FOR rec IN (
        SELECT 'ALTER TABLE ' || t.schemaname || '.' || t.tablename || ' OWNER TO smfd;' sql_query,
               1                                                                         obj_type,
               t.schemaname                                                              obj_schema_name
        FROM pg_tables t
        WHERE t.schemaname LIKE 'module\_%' ESCAPE '\' OR t.schemaname LIKE 'smfd%'
        UNION
        SELECT 'ALTER SEQUENCE ' || s.sequence_schema || '.' || s.sequence_name || ' OWNER TO smfd;' sql_query,
               2                                                                                     obj_type,
               s.sequence_schema                                                                     obj_schema_name
        FROM information_schema.sequences s
        WHERE s.sequence_schema LIKE 'module\_%' ESCAPE '\' OR s.sequence_schema LIKE 'smfd%'
        ORDER BY obj_schema_name, obj_type
    )
        LOOP
            BEGIN
                EXECUTE rec.sql_query;
                RAISE NOTICE 'query: %', rec.sql_query;
            EXCEPTION
                WHEN insufficient_privilege
                    THEN NULL;
            END;
        END LOOP;
    RETURN 0;
END;
$$;

-- AFTER ALL ANOTHER SQLs:
select public.dba__alter_funcs_owner_smfd();
select public.dba__alter_tables_owner_smfd();
