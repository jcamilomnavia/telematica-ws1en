//La URL de la base de datos debera obtener el contador y ademas sumarle uno a ese contador
//Observar el 'routes' del repo de la base de datos
const url='url.instancia.baseDatos'
var request = new XMLHttpRequest();
var counter=0;
request.responseType = "json"
request.open( "GET", url, true ); 
request.onreadystatechange = function() {
  if (request.readyState == 4) {
    const {response} = request
    counter=response.counter
    document.getElementById("counter").innerText=counter
  }
}
request.send( null );