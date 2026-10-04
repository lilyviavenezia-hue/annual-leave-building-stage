/// Client reserved for future HTTP communication with the Python backend.
class ApiClient {
  final String baseUrl;

  ApiClient({this.baseUrl = 'http://localhost:8000'});

  // Generic HTTP get/post methods will be added here 
  // when connecting to the live Python API.
}