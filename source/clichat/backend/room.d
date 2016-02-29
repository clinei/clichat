module clichat.backend.room;

final class Room
{
	string id;

	import vibe.db.redis.redis : RedisDatabase;
	RedisDatabase database;

	import vibe.db.redis.types : RedisList;
	RedisList!string messages;

	import vibe.core.sync : ManualEvent;
	ManualEvent messageEvent;

	this(RedisDatabase database, string id)
	{
		this.id = id;

		this.database = database;

		import vibe.db.redis.types : getAsList;
		this.messages = database.getAsList!string("clichat_" ~ id);

		import vibe.core.sync : createManualEvent;
		this.messageEvent = createManualEvent();
	}

	import clichat.backend.data : Message;
	void addMessage(Message message)
	{
		import vibe.data.json : serializeToJsonString;
		messages.insertBack(message.serializeToJsonString());
		messageEvent.emit();
	}
	void addMessage(string message, string userID)
	{
		import vibe.data.json : parseJsonString;
		auto json = parseJsonString(message);

		import clichat.backend.data : Message;
		Message msg;

		import std.conv : to;
		msg.data = json["data"].to!string;

		import std.datetime : Clock;
		msg.time = Clock.currTime.toUTC;
		msg.userID = userID;

		this.addMessage(msg);
	}

	void waitForMessage(size_t nextMessage)
	{
		while (messages.length <= nextMessage)
		{
			messageEvent.wait();
		}
	}
}
