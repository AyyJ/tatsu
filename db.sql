DROP TABLE roles cascade;
DROP TABLE users cascade;
DROP TABLE categories cascade;
DROP TABLE products cascade;
DROP TABLE purchases cascade;

CREATE TABLE roles (
  ID    SERIAL PRIMARY KEY,
  name  TEXT
);

INSERT INTO roles (name) VALUES ('Owner');
INSERT INTO roles (name) VALUES ('Customer');

CREATE TABLE users (
  ID      SERIAL PRIMARY KEY,
  name    TEXT NOT NULL UNIQUE CHECK (name <> ''),
  role    INTEGER REFERENCES roles (ID) NOT NULL,
  age     INTEGER NOT NULL,
  state   TEXT NOT NULL
);

CREATE TABLE categories (
  ID            SERIAL PRIMARY KEY ,
  name          TEXT NOT NULL UNIQUE CHECK (name <> ''),
  description   TEXT NOT NULL CHECK (description <> '')
);

CREATE TABLE products (
  ID        SERIAL PRIMARY KEY,
  name      TEXT,
  sku       INTEGER,
  category  INTEGER REFERENCES categories (ID) NOT NULL,
  price     INTEGER
);

CREATE TABLE purchases (
  ID        SERIAL PRIMARY KEY,
  uid       INTEGER REFERENCES users (ID) NOT NULL,
  pid       INTEGER REFERENCES products (ID) NOT NULL,
  quantity  INTEGER NOT NULL,
  price     INTEGER NOT NULL,
  timestamp timestamp default current_timestamp
);
