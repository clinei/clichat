module clichat.backend.backend;

final class Backend
{
	import vibe.db.redis.redis : RedisDatabase;
	RedisDatabase database;

	import clichat.backend.room : Room;
	Room[string] rooms;

	this()
	{
		import vibe.db.redis.redis : connectRedis;
		database = connectRedis("127.0.0.1").getDatabase(0);
	}

	Room getRoom(string id)
	{
		if (auto roomPtr = id in rooms)
		{
			return *roomPtr;
		}

		return rooms[id] = new Room(database, id);
	}
}
