var RoomConnection = function(url, outputID, inputID)
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

		var output = document.getElementById(outputID);

		if ("data" in parsed)
		{
			var msg = parsed["data"];
			output.innerHTML = msg;
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
	var url = getReceiver() + "/r1";
	var outputID = "message";
	var inputID = "input";

	var conn = new RoomConnection(url, outputID, inputID);
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

onReady();
