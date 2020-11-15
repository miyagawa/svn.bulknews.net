CREATE TABLE url (id integer  NOT NULL PRIMARY KEY AUTOINCREMENT, url varchar(255) not null, alias varchar(16));
CREATE INDEX alias on url(alias);
