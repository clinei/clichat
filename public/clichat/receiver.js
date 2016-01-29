function handleInput(event)
{
	if (event.keyCode == 13)
	{
		var elem = event.target;
		var text = elem.value;

		var message = {"type": "message", "data": text};
		var data = JSON.stringify(message);

		sendRequest(data);

		// Clear input field
		elem.value = "";
	}
}

// string req
function sendRequest(req)
{
	var xhr = new XMLHttpRequest();
	xhr.open("POST", "receiver");

	xhr.setRequestHeader("Content-Type", "application/json");

	function handleResponse()
	{
		if (this.responseText)
		{
			var res = JSON.parse(this.responseText);
			processResponse(res);
		}
	}

	xhr.addEventListener("load", handleResponse);

	xhr.send(req);

	console.log("request: " + req);
}

function initReceiver()
{
	var input = document.getElementById("input");
	input.addEventListener("keypress", handleInput);

	getLast();
}

function getLast()
{
	var message = {"type": "getLast"};
	var data = JSON.stringify(message);
	sendRequest(data);
}

initReceiver();
