import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';
import 'BLOC/APIBloC.dart';
import 'POJO/chat_history_response_data.dart';
import 'Utility/SkeletonLoader.dart';
import 'Utility/constants.dart';
import 'chat_service.dart';

import 'package:cached_network_image/cached_network_image.dart';

class ChatScreen extends StatefulWidget {
  @override
  final String orderId;
  final String name;
  final String profileUrl;



  ChatScreen(this.orderId,this.name,this.profileUrl);

  @override
  State<StatefulWidget> createState() {
    return _ChatScreenState(this.orderId!,this.name,this.profileUrl);
  }

}


class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver{

  APIBloC? _bloc;
  bool _isLoading = false;
  String sender_id = "";
  String chat_id = "";
  String customer_id = "";
  String Name = "";
  String profile_url = "";
  String order_id = "";
  final ChatService chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  late List<ChatHistoryResponseData>? messageList = [];
  IO.Socket? socket;
  List<Map<String, String>> chatHistory = [];
  List<Map<String, dynamic>> messages = [];
  final ScrollController _scrollController = ScrollController();

  _ChatScreenState(String orderId, String name,String profileUrl);


  @override
  void initState() {
    super.initState();
    _isLoading = true;

    WidgetsBinding.instance.addObserver(this);


    String copyOrderId;
    copyOrderId = widget.orderId;
    Name = widget.name;
    profile_url = widget.profileUrl;

    order_id = copyOrderId;
    _isLoading = true;

    fetchChatHistory(context, order_id);


    initializeSocketConnection();


  }

  @override
  void dispose() {
    socket?.off('message');
    socket?.off('chat_history');
    socket?.off('join_success');
    socket?.off('join_error');
    socket?.disconnect();
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }


  @override
  void didChangeMetrics() {
    // Called when the keyboard is shown or hidden
    _scrollToEnd();
  }


  void initializeSocketConnection() {

  /*  socket = IO.io('http://trendtoday-env.eba-msabh2zc.us-east-2.elasticbeanstalk.com/',
        <String, dynamic>{
          'transports': ['websocket'],
        });*/


   /* socket = IO.io('https://staging.trendtoday.ca/', <String, dynamic>{

          'transports': ['websocket'],
          //'autoConnect': true,



        });*/

    socket = IO.io(EnvironmentConfig.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'forceNew': true,
    });

    socket!.connect();




    //socket!.connect();

    socket!.onConnect((_) {
      print('Socket connected');
      print('here in connect 3');
      startChat(context,order_id);


    });

    socket!.onConnectError((data) {
      print('Connect Error: $data');
      print('here in connect 4');

    });

    socket!.onDisconnect((_) {
      print('Socket disconnected');
      print('here in connect 5');

    });

   socket!.on('message', (data) {
      if (!mounted) return;
      print("socket message received: $data");
      Map<String, dynamic> parsedData = Map<String, dynamic>.from(data);

      if (parsedData.containsKey("sender")) {
        // Access the 'msg' and 'sender' fields
        final String msg = (parsedData['msg'] ?? parsedData['message'] ?? '') as String;
        final String sender = (parsedData['sender'] ?? '') as String;

        // Skip blank messages
        if (msg.trim().isEmpty) return;

        setState(() {
          messages.add(data);
          ChatHistoryResponseData x = ChatHistoryResponseData();
          x.message = msg;
          x.sender = sender;
          messageList!.add(x);
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToEnd();
        });
      }
    });

    socket!.on('chat_history', (history) {
      print("socket chat_history received: $history");
      if (!mounted) return;

      final List<dynamic> rawList = List<dynamic>.from(history);
      if (rawList.isEmpty) {
        // Server returned empty history — don't wipe existing HTTP-loaded messages
        print('chat_history: empty list from socket, keeping existing messageList');
        return;
      }

      final parsed = rawList
          .map((msg) {
            final message = (msg['msg'] ?? msg['message'] ?? '') as String;
            final sender = (msg['sender'] ?? '') as String;
            if (message.trim().isEmpty) return null; // skip blank entries
            final ChatHistoryResponseData item = ChatHistoryResponseData();
            item.message = message;
            item.sender = sender;
            return item;
          })
          .whereType<ChatHistoryResponseData>()
          .toList();

      if (parsed.isEmpty) {
        // All socket entries were blank — keep HTTP-loaded data
        print('chat_history: all socket entries were blank, keeping existing messageList');
        return;
      }

      setState(() {
        messageList = parsed;
        print("chat_history: updated messageList with ${parsed.length} messages");
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToEnd();
      });
    });
  }

  void joinSocketChat(String chatId,String senderId) {
    if (chatId.isEmpty || senderId.isEmpty) {
      print('joinSocketChat skipped: empty chatId or senderId');
      return;
    }

    print('here in connect join 1');
    print('here in connect join 1 '+senderId);


    socket!.emit('join', {
      'sender': 'Customer',
      'sender_id': senderId,
      'chat_id': chatId,
    });

    // Listen for a response from the server (e.g., 'join_success')
    socket!.on('join_success', (data) {
      print('Chat joined successfully');
      // Handle successful join (e.g., show a message, update UI, etc.)
    });

    // Optionally, listen for any failure response (e.g., 'join_error')
    socket!.on('join_error', (data) {
      print('Chat joined error');
      print('Failed to join chat: ${data.toString()}');
      // Handle join failure (e.g., show an error message, retry, etc.)
    });

  }


  Future<void> startChat(
      BuildContext context, String orderId) async {
    _bloc = APIBloC();

    try {
      // Perform the asynchronous work without calling setState
      var value = await _bloc?.startChat(orderId);

      if (value != null) {
        sender_id = value.customer_id ?? "";
        chat_id = value.chat_id ?? "";
        customer_id = value.customer_id ?? "";

        print("sender_id !!!"+sender_id);
        print("chat_id !!!"+chat_id);
        print("customer_id !!!"+customer_id);

        if (chat_id.isNotEmpty && sender_id.isNotEmpty) {
          joinSocketChat(chat_id,sender_id);
          socket?.emit('load_chat_history', {'chat_id': chat_id});
        } else {
          print('startChat: chat_id or sender_id is empty after parsing response');
        }
      } else {
        print('startChat: API returned null/empty response - backend may not have a chat for order $orderId');
      }

    } catch (e) {
      // Handle any errors that occur during the async operation
      print("Error in startChat: $e");
      setState(() {
        _isLoading = false; // Update the loading state even if an error occurs
      });
    }
  }


  Future<void> fetchChatHistory(BuildContext context, String orderId) async {
    _bloc = APIBloC();

    try {
      var value = await _bloc?.fetchHistoryChat(orderId);
      print("chat_id !!!" + (value.toString()));
      if (value != null && value.isNotEmpty) {
        print("chat_id !!!" + (value[0].message ?? ''));
      }

      setState(() {
        messageList = value;
        _isLoading = false;

      });

      // Ensure the scroll happens after the state is updated
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToEnd();
      });

    } catch (e) {
      print("Error fetching revenue details: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }





  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            // Orange gradient background with pattern
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFA773F7),
            Colors.black,
            Colors.black,
          ],
        ),
              ),
              child: Stack(
                children: [
                  // Stylish geometric pattern overlay
                  CustomPaint(
                    size: Size.infinite,
                    // painter: _ChatPatternPainter(),
                  ),
                  // Subtle gradient overlay for depth
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.transparent,
                          Colors.black.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Main content
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  _isLoading ? SkeletonLoader()
                      :
                  _buildChatBody(),
                  _buildSendMessageFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }









  Widget _buildChatBubble(String message, bool isSender) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Align(
        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: isSender
                ? LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFA773F7),
            Colors.black,
            Colors.black,
          ],
        )
                : null,
            color: isSender ? null : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: isSender ? Radius.circular(18) : Radius.circular(4),
              bottomRight: isSender ? Radius.circular(4) : Radius.circular(18),
            ),
            boxShadow: [
              BoxShadow(
                color: isSender
                    ? Color(0xFFF97316).withOpacity(0.3)
                    : Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Text(
            message,
            style: TextStyle(
              color: isSender ? Colors.white : Color(0xFF111827),
              fontSize: 14,
              fontFamily: "Poppins",
              fontWeight: FontWeight.w500,
              letterSpacing: -0.2,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 24, bottom: 16),
      child: Row(
        children: [
          // Back button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(20),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
          SizedBox(width: 14),
          // Profile image
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: profile_url != null && profile_url!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: profile_url!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.white.withOpacity(0.2),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.white.withOpacity(0.2),
                        child: Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.white.withOpacity(0.2),
                      child: Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
            ),
          ),
          SizedBox(width: 12),
          // Name and heading
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white,
                            Colors.white.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Chat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.9),
                        fontFamily: "Poppins",
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  Name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontFamily: "Poppins",
                    letterSpacing: -0.5,
                    height: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendMessageFooter(){

    return Container(
        color: Colors.black.withOpacity(0.4),
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(3.0),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            height: 50,
            padding: const EdgeInsets.all(0),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0,
                          horizontal: 10),
                      hintText: 'Message',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.5), // Set the color of the hint text here
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.2), // Border color
                          width: 1.0, // Border width
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      // Background color of the TextField
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.2),
                          // Border color when not focused
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(
                          color: Color(0xFFA773F7),
                          // Border color when the field is focused
                          width: 1.0,
                        ),
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.white, // Text color
                      fontSize: 14, // Font size
                    ),
                  ),

                ),
                SizedBox(width: 10),
                Container(
                  height: 50,
                  padding: EdgeInsets.symmetric(vertical: 2.0),
                  child: ElevatedButton(
                    onPressed: () {
                      final text = _messageController.text.trim();
                      if (text.isEmpty) return;

                      print("here in send");
                      String chatId = chat_id;
                      String sender = ConstantVariable.userName!;
                      String senderId = sender_id;
                      String message = text;

                      print("chatId " + chatId);
                      print("sender " + sender);
                      print("senderId " + senderId);
                      print("message " + message);

                      _messageController.clear();
                      sendMessage(chatId, sender, senderId, message);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      backgroundColor: Color(0xFFA773F7),
                    ),
                    child: Center( // Center the text within the button
                      child: Text(
                        'Send',
                        style: TextStyle(
                          color: Colors.white, // Text color
                          fontSize: 14, // Font size
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),),


              ],
            ),
          ),
        ));

  }

  void sendMessage(String chatId, String sender, String senderId, String message) {
    if (chatId.isEmpty || senderId.isEmpty) {
      print("Cannot sendMessage: empty chatId or senderId");
      return;
    }
    // Emit the 'send_message' event with necessary data
    print("Customer senderId " + senderId);

    socket?.emit('send_message', {
      'chat_id': chatId,
      'sender': 'Customer',
      'sender_id': senderId,
      'message': message,
    });

    // NOTE: Do NOT add the message locally here.
    // The server echoes it back via the 'message' event which adds it once.
    // Adding it here AND handling the echo would cause duplicates.
  }

  void loadChatHistory(String chatId) {
    socket?.emit('load_chat_history', {'chat_id': chatId});
  }




  Widget _buildChatBody(){

    return Expanded(
      child:/* Container(
        margin: const EdgeInsets.only(left: 0.0, right: 0.0, top: 10),
        child: ListView(
          padding: EdgeInsets.all(16.0),

          children: [
            // Sample chat bubbles
            _buildChatBubble(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque amet sed tempor etiam.',
                true),
            _buildChatBubble(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque amet sed tempor etiam.',
                false),
            _buildChatBubble('Lorem ipsum dolor sit amet.', true),
            _buildChatBubble(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque amet sed tempor etiam.',
                true),
            _buildChatBubble(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                false),
          ],
        ),
      ),*/


      (() {
        final filteredList = messageList?.where((msg) => msg.message != null && msg.message!.trim().isNotEmpty).toList() ?? [];
        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.only(top: 10, bottom: 10),
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            final message = filteredList[index].message;
            final isSender = filteredList[index].sender;

            if (isSender == "Customer") {
              return _buildChatBubble(message!, true);
            } else {
              return _buildChatBubble(message!, false);
            }
          },
        );
      })(),

    );

  }

 /* void _scrollToEnd() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }*/

  void _scrollToEnd() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}

// Custom painter for stylish geometric pattern on chat screen
class _ChatPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw diagonal lines pattern
    final spacing = 40.0;
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }

    // Draw circles pattern
    final circlePaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final circleSpacing = 80.0;
    for (double x = 0; x < size.width + circleSpacing; x += circleSpacing) {
      for (double y = 0; y < size.height + circleSpacing; y += circleSpacing) {
        canvas.drawCircle(
          Offset(x, y),
          20,
          circlePaint,
        );
      }
    }

    // Draw hexagon pattern
    final hexPaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final hexSpacing = 100.0;
    for (double x = 0; x < size.width + hexSpacing; x += hexSpacing) {
      for (double y = 0; y < size.height + hexSpacing; y += hexSpacing) {
        _drawHexagon(canvas, Offset(x, y), 30, hexPaint);
      }
    }
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 30) * math.pi / 180;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
