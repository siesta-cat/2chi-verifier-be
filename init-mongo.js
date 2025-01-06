db = new Mongo().getDB("bot");

db.createCollection("authorizations");

db.authorizations.insert([
  {
    app: "tester",
    secret: "test",
  },
]);
