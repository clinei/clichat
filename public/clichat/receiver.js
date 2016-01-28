function handleInput(event)
{
	if (event.keyCode == 13)
	{
		var elem = event.target;
		var text = elem.value;

		var message = {"data": text};
		var data = JSON.stringify(message);

		sendMessage(data);

		// Clear input field
		elem.value = "";
	}
}

function sendMessage(message)
{
	var xhr = new XMLHttpRequest();
	xhr.open("POST", "receiver");

	xhr.setRequestHeader("Content-Type", "application/json");

	console.log("Sending: " + message);

	xhr.send(message);
}

function initReceiver()
{
	var input = document.getElementById("input");
	input.addEventListener("keypress", handleInput);
}

initReceiver();
