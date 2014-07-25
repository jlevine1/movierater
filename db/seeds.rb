user = User.create(username:"jlevine", password: "elladog", admin: true)
Profile.create(fav_movie: "Pulp Fiction", email: "joncars4@hotmail.com", user_id: user.id)