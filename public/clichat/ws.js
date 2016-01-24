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
		socket = new WebSocket("ws://" + getBackend());
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
		//var text = encodeURIComponent(elem.val());
		var text = elem.val();
		elem.val("");
		log("Sending: " + text);
		var msg = {"message": text};
		var data = JSON.stringify(msg);
		socket.send(data);
	}
}

function onOpen()
{
	//log("Connected");
}

function onMessage(message)
{
	log("Message: " + message.data);
	var parsed = JSON.parse(message.data);
	if ("userCount" in parsed)
	{
		$("#userCount").html(parsed["userCount"]);
	}
	if ("message" in parsed)
	{
		var msg = parsed["message"];
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

function getBackend()
{
	/*
	var href = window.location.href;
	href = "ws://" + href.substring(href.indexOf(":") + 3) + "ws";
	return href;
	*/
	return $('data#backend').html();
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
