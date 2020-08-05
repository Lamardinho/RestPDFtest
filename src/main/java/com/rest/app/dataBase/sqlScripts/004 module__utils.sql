/* Генерация псевдослучайного числа для соли пароля. */
CREATE OR REPLACE FUNCTION module__utils.generate_salt() RETURNS INTEGER
    LANGUAGE plpgsql
    STABLE AS
$$
DECLARE
    min_value CONSTANT INT := 1000000000;
    max_value CONSTANT INT := 1111111111;
BEGIN
    RETURN floor(random() * (max_value - min_value + 1)) + min_value;
END;
$$;

CREATE OR REPLACE FUNCTION module__utils.random_string(length INTEGER) RETURNS TEXT AS
$$
DECLARE
    chars  TEXT[]  := '{0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}';
    result TEXT    := '';
    i      INTEGER := 0;
BEGIN
    IF length < 0
    THEN
        RAISE EXCEPTION 'Given length cannot be less than 0';
    END IF;
    FOR i IN 1..length
        LOOP
            result := result || chars[1 + random() * (array_length(chars, 1) - 1)];
        END LOOP;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION module__utils.wipe_data() RETURNS VOID
    LANGUAGE plpgsql AS
$$
BEGIN
    TRUNCATE TABLE smfd_data.t_address CASCADE;
    TRUNCATE TABLE public.t_city CASCADE;
    TRUNCATE TABLE smfd_data.t_vendors CASCADE;
END;
$$;

-- region AGGREGATES
-- Create a function that always returns the first non-NULL item
CREATE OR REPLACE FUNCTION module__utils.first_agg(ANYELEMENT, ANYELEMENT)
    RETURNS ANYELEMENT
    LANGUAGE SQL
    IMMUTABLE STRICT AS
$$
SELECT $1;
$$;

-- And then wrap an aggregate around it
CREATE AGGREGATE module__utils.FIRST (
    SFUNC = module__utils.first_agg,
    BASETYPE = ANYELEMENT,
    STYPE = ANYELEMENT
    );

-- Create a function that always returns the last non-NULL item
CREATE OR REPLACE FUNCTION module__utils.last_agg(ANYELEMENT, ANYELEMENT)
    RETURNS ANYELEMENT
    LANGUAGE SQL
    IMMUTABLE STRICT AS
$$
SELECT $2;
$$;

-- And then wrap an aggregate around it
CREATE AGGREGATE module__utils.LAST (
    SFUNC = module__utils.last_agg,
    BASETYPE = ANYELEMENT,
    STYPE = ANYELEMENT
    );
-- endregion AGGREGATES

