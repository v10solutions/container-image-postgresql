--
-- Container Image PostgreSQL
--

CREATE TABLE packages (
  id             int,
  client_id      int,
  creation_date  timestamp,
  PRIMARY KEY(id)
);
