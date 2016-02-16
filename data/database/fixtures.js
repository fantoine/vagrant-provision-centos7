var database = 'vagrant';
var user     = 'vagrant';
var password = 'vagrant';

// Create database
db = connect(database);

// Create user
if (!db.getUser(user)) {
    db.createUser({
        user: user,
        pwd: password,
        roles: [
            { role: 'readWrite', db: database }
        ]
    });
}
