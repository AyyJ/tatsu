CREATE TABLE users (
  ID      SERIAL PRIMARY KEY,
  name    TEXT,
  role    INTEGER REFERENCES roles (ID) NOT NULL,
  age     INTEGER,
  state   TEXT
)

CREATE TABLE products (
  ID        SERIAL PRIMARY KEY,
  name      TEXT,
  sku       INTEGER,
  category  INTEGER REFERENCES categories (ID) NOT NULL,
  price     INTEGER
)

CREATE TABLE roles (
  ID    SERIAL PRIMARY KEY,
  name  TEXT
)

CREATE TABLE categories (
  ID            SERIAL PRIMARY KEY,
  name          TEXT,
  description   TEXT
)

CREATE TABLE purchases (
  ID        SERIAL,
  user      INTEGER REFERENCES users (ID) NOT NULL,
  product   INTEGER REFERENCES products (ID) NOT NULL

)
