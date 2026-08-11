import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatService {
  late IO.Socket socket;

  // Method to initialize socket connection
  void initSocket() {
    // Replace with your server URL

   /* socket = IO.io('http://trendtoday-env.eba-msabh2zc.us-east-2.elasticbeanstalk.com', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });*/


    socket = IO.io('https://www.trendtoday.ca/',
        <String, dynamic>{
          'transports': ['websocket'],
          //'autoConnect': true,

        });

    // Connect to the socket server
    socket.connect();

    // Add event listeners here (optional)
    socket.onConnect((_) {
      print('Connected to socket server');
    });

    socket.onDisconnect((_) {
      print('Disconnected from socket server');
    });
  }

  // Method to emit a message to the server
  void sendMessage(String chatId, String sender, String senderId, String message) {

    print("here in send 2");
    socket.emit('send_message', {
      'chat_id': chatId,
      'sender': sender,
      'sender_id': senderId,
      'message': message,
    });
  }

  // Method to listen for incoming messages
  void onMessageReceived(Function(dynamic) callback) {
    socket.on('receive_message', (data) {
      callback(data);
    });
  }
}
