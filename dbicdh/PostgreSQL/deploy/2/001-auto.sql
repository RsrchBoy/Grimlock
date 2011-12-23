-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Wed Dec 21 14:34:20 2011
-- 
;
--
-- Table: roles
--
CREATE TABLE "roles" (
  "roleid" serial NOT NULL,
  "name" character varying(50) NOT NULL,
  PRIMARY KEY ("roleid"),
  CONSTRAINT "roles_name" UNIQUE ("name")
);

;
--
-- Table: sessions
--
CREATE TABLE "sessions" (
  "sessoinid" character(72) NOT NULL,
  "session_data" text NOT NULL,
  "expires" integer NOT NULL,
  PRIMARY KEY ("sessoinid")
);

;
--
-- Table: users
--
CREATE TABLE "users" (
  "userid" serial NOT NULL,
  "name" character varying(200) NOT NULL,
  "password" character(59) NOT NULL,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp,
  PRIMARY KEY ("userid"),
  CONSTRAINT "users_name" UNIQUE ("name")
);

;
--
-- Table: entries
--
CREATE TABLE "entries" (
  "entryid" serial NOT NULL,
  "title" character varying(200) NOT NULL,
  "body" text NOT NULL,
  "author" integer NOT NULL,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp,
  PRIMARY KEY ("entryid")
);
CREATE INDEX "entries_idx_author" on "entries" ("author");

;
--
-- Table: user_roles
--
CREATE TABLE "user_roles" (
  "user" integer NOT NULL,
  "role" integer NOT NULL
);
CREATE INDEX "user_roles_idx_role" on "user_roles" ("role");
CREATE INDEX "user_roles_idx_user" on "user_roles" ("user");

;
--
-- Foreign Key Definitions
--

;
ALTER TABLE "entries" ADD FOREIGN KEY ("author")
  REFERENCES "users" ("userid") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "user_roles" ADD FOREIGN KEY ("role")
  REFERENCES "roles" ("roleid") ON DELETE RESTRICT ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "user_roles" ADD FOREIGN KEY ("user")
  REFERENCES "users" ("userid") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;
