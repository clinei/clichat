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

	ManualEvent userCountEvent;

	size_t userCount;

	import vibe.core.core : Timer;
	import clichat.backend.data : UserID;
	Timer[UserID] userCountTimers;

	import core.time : Duration;
	import core.time : minutes;
	import core.time : seconds;
	Duration userCountDur = 5.seconds;

	this(RedisDatabase database, string id)
	{
		this.id = id;

		this.database = database;

		import vibe.db.redis.types : getAsList;
		this.messages = database.getAsList!string("clichat_" ~ id);

		import vibe.core.sync : createManualEvent;
		this.messageEvent = createManualEvent();
		this.userCountEvent = createManualEvent();
	}

	import clichat.backend.data : Message;
	void addMessage(Message message)
	{
		import vibe.data.json : serializeToJsonString;
		messages.insertBack(message.serializeToJsonString());
		messageEvent.emit();

		if (auto tm = message.userID in userCountTimers)
		{
			tm.rearm(userCountDur);
		}
		else
		{
			userCount += 1;

			userCountEvent.emit();

			import vibe.core.core : setTimer;
			userCountTimers[message.userID] = setTimer(userCountDur,
			()
			{
				userCount -= 1;

				import std.algorithm : remove;
				userCountTimers.remove(message.userID);

				userCountEvent.emit();
			}
			);
		}
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

	void waitForUserCount()
	{
		userCountEvent.wait();
	}
}
