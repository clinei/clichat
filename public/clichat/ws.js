var socket;
var visible = true;
$(document).ready(onReady);

function onReady()
{

	$("#input").bind("keypress", handleInput);
	connect();
}

function handleInput(event)
{
	if (event.keyCode == 13)
	{
		sendMessage("input");
	}
}

function connect()
{
	if (canConnect())
	{
		socket = new WebSocket("ws://" + getReceiver() + "/" + encodeURIComponent("r1"));
		socket.onopen = onOpen;
		socket.onmessage = onMessage;
		socket.onclose = onClose;
		socket.onerror = onError;
	}
	else if (socket.readyState == 3)
	{
		connectWithTimeout();
	}
	else
	{
		log("Already connected");
	}
}

function connectWithTimeout()
{
 	window.setTimeout(connect, 1000);
}

function disconnect()
{
	if (canSend)
	{
		socket.close();
		log("Disconnected");
	}
	else
	{
		log("Not connected");
	}
}

function canConnect()
{
	return socket == null || socket.readyState == 3;
}

function canSend()
{
	return socket != null && socket.readyState == 1;
}

function sendMessage(target)
{
	if (canSend)
	{
		var elem = $('#' + target);
		var text = elem.val();
		elem.val("");

		var msg = {data: text};
		var str = JSON.stringify(msg);

		log("Sending: " + str);
		socket.send(str);
	}
}

function onOpen()
{
	//log("Connected");
}

function onMessage(message)
{
	log("Received: " + message.data);
	var parsed = JSON.parse(message.data);
	if ("userCount" in parsed)
	{
		$("#userCount").html(parsed["userCount"]);
	}
	if ("data" in parsed)
	{
		var msg = parsed["data"];
		$("#message").html(msg);
		if (!visible)
		{
			// Notify user
			notifyNewMessage();
		}
	}
}

function onClose()
{
	//log("Connection closed");
	connectWithTimeout();
}

function onError()
{
	//log("Error occurred");
}

function log(text)
{
	console.log(text);
}

function getReceiver()
{
	return $('data#receiver').html();
}

function getRoot()
{
	return $('data#root').html();
}

function notifyNewMessage(max, n)
{
	max = max | 3;
	n = n | 0;
	if (n < max)
	{

	}
}

function onUnfocus()
{
	visible = false;
}
function onFocus()
{
	visible = true;
}

$(window).blur(onUnfocus);
$(window).focus(onFocus);
