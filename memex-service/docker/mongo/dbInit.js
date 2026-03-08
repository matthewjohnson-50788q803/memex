
use memex;
now = new ISODate();

const users = db.userDetails.find({}).toArray();

if (users.length === 0) {
    db.userDetails.insertOne({
        "_id" : "${DEFAULT_USER_USERNAME}",
        "password" : "${DEFAULT_USER_PW_ENCODED}",
        "authorities" : [],
        "createDateTime" : now,
        "updateDateTime" : now,
        "_class" : "com.matthewjohnson42.memexService.data.mongo.entity.UserDetailsMongo"
    });
}
