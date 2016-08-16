String.prototype.replaceAll = function(search, replace) {
	return this.replace(new RegExp(search, 'g'), replace);
};

function encode(msg) {
	return msg.replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;");
}

function decode(msg) {
	return msg.replaceAll("&lt;", "<").replaceAll("&gt;", ">").replaceAll("&amp;", "&");
}

var RoomConnection = function(url, outputID, inputID, userCountID)
{
	var socket = new WebSocket("ws://" + url);

	function canSend()
	{
		return socket != null && socket.readyState == 1;
	}

	function onMessage(message)
	{
		log("Received " + url + ": " + message.data);
		var parsed = JSON.parse(message.data);

		if (outputID != null && "data" in parsed)
		{
			var output = document.getElementById(outputID);
			var msg = parsed["data"];
			msg = encode(msg);
			output.innerHTML = msg;
		}

		if (userCountID != null && "userCount" in parsed)
		{
			var userCount = document.getElementById(userCountID);
			userCount.innerHTML = parsed["userCount"];
		}
	}

	socket.addEventListener("message", onMessage);

	var input = document.getElementById(inputID);

	function keyDown(event)
	{
		if (event.keyCode == 13)
		{
			if (canSend())
			{
				var text = input.value;

				var msg = {data: text};
				var str = JSON.stringify(msg);

				log("Sending " + url + ": " + str);
				socket.send(str);

				input.value = "";
			}
		}
	};

	input.addEventListener("keydown", keyDown);
}


function onReady()
{
	var conns = [];
	for (var i = 1; i <= 2; i++)
	{
		conns.push(new RoomConnection(window.location.hostname + getServerURI() +"/r"+ i, "o"+ i, "i"+ i));
	}
}

function log(text)
{
	console.log(text);
}

function getReceiver()
{
	return document.getElementById("data_receiver").innerHTML;
}

function getRoot()
{
	return document.getElementById("data_root").innerHTML;
}

function getServerURI()
{
	return document.getElementById("data_serverURI").innerHTML;
}

onReady();
