
//Initialize function
var init = function () {
	console.log("in init of main.js");
	msfHandle.initialize();
};
// window.onload can work without <body onload="">
window.onload = init;
