import 'dart:io';
import 'package:http/http.dart' as http;
import '../POJO/appointment_input_data.dart';
import '../POJO/profile_input_data.dart';
import '../POJO/rental_locations.dart';
import '../POJO/reset_password.dart';
import '../POJO/reviews_response_data.dart';
import '../POJO/services_response_data.dart';
import 'dart:convert';
import 'dart:async';
import '../POJO/AppointmnetSlotsResponseData.dart';
import '../POJO/login_response_data.dart';
import '../POJO/RegisterResponseData.dart';
import '../POJO/chat_history_response_data.dart';
import '../POJO/create_appointment_response.dart';
import '../POJO/customer_profile_response.dart';
import '../POJO/location_response_data.dart';
import '../POJO/order_stages_data_response.dart';
import '../POJO/orders_response_data.dart';
import '../POJO/professional_response_data.dart';
import '../POJO/profile_data_response.dart';
import '../POJO/services_provided_by_vendor.dart';
import '../POJO/start_chat_response.dart';
import '../Utility/constants.dart';
import 'api_exception.dart';

class ApiBaseHelper {

  final String _baseUrl = EnvironmentConfig.baseUrl;




  //final String _baseUrl = "http://dev.trendtoday.ca:5000/";



  //final String _baseUrl = "http://trendtoday-env.eba-msabh2zc.us-east-2.elasticbeanstalk.com/";



  Future<LoginResponseData?> login(String url, String ps) async {
    print('Api Get, url $url');
    try {
      final Uri uri = Uri.parse(_baseUrl + url); // parse string

      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          'Authorization': "${ps}",
          'Entity': "Customer"
        },
      );

      print("coded " + "${response.body}");
      return LoginResponseData.fromJson(jsonDecode(response.body));
    } on SocketException {
      print('No net');
      throw FetchDataException('No Internet connection');
    } on http.ClientException {
      print('here');
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch data');
    }
  }


  Future<LoginResponseData?> getToken(String url, String access_token, String refresh_token) async {
    print('Api Get, url $url');
    try {
      final Uri uri = Uri.parse(_baseUrl + url); // parse string

      final response = await http.put(
        uri,
        headers: {
          "Content-Type": "application/json",
        },
          body: jsonEncode(<String, String>{
            'access_token': access_token,
            'refresh_token': refresh_token
          })
      );

      print("coded " + "${response.body}");
      return LoginResponseData.fromJson(jsonDecode(response.body));
    } on SocketException {
      print('No net');
      throw FetchDataException('No Internet connection');
    } on http.ClientException {
      print('here');
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch data');
    }
  }



  Future<LoginResponseData?> updateFCMToken(String url) async {
    print('➡️ API CALL: PUT ${_baseUrl + url}');

    final Uri uri = Uri.parse(_baseUrl + url);
    final headers = {
      "Content-Type": "application/json",
      'Authorization': "Bearer ${ConstantVariable.authToken!}",

    };
    final body = jsonEncode(<String, String>{
      'device_token': ConstantVariable.FCMToken!,
    });

    print('🧾 Request Headers: $headers');
    print('📦 Request Body: $body');


    try {
      final response = await http.put(uri, headers: headers, body: body);

      print('✅ Status Code: ${response.statusCode}');
      print('📨 Response Body: ${response.body}');

      return LoginResponseData.fromJson(jsonDecode(response.body));
    } on SocketException {
      print('❌ No Internet connection');
      throw FetchDataException('No Internet connection');
    } on http.ClientException {
      print('❌ Client Exception');
    } catch (e) {
      print('❌ Unexpected Error: $e');
      throw Exception('Failed to fetch data');
    }
  }


  Future<RegisterResponseData?> register(
      String url,
      String entity_id,
      String first_name,
      String last_name,
      String username,
      String password,
      String mobile) async {
    print('Api Get, url $url');
    http.Response responseJson;
    String isValid = 'true';

    try {
      final Uri uri = Uri.parse(_baseUrl + url); // parse string

      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(<String, String>{
          'entity_id': entity_id,
          'first_name': first_name,
          'last_name': last_name,
          'username': username,
          'password': password,
          'mobile_no': mobile,

        }),
      );

      print("coded " + "${response.body}");

      return RegisterResponseData.fromJson(jsonDecode(response.body));
    } on SocketException {
      print('No net');
      throw FetchDataException('No Internet connection');
    } on http.ClientException {
      print('here');
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch data');
    }
  }

  Future<bool> verifyOTP(String url, String otp, String username) async {
    print('Api Get, url $url');
    http.Response responseJson;
    String isValid = 'true';

    try {
      final Uri uri = Uri.parse(_baseUrl + url); // parse string

      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'otp': otp,
        }),
      );

      print("Response code: ${response.statusCode}");
      print("Response body: ${response.body}");

      // Check if the status code is 202 ACCEPTED
      if (response.statusCode == 202) {
        return true;
      } else {
        return false;
      }
    } on SocketException {
      print('No net');
      throw FetchDataException('No Internet connection');
    } on http.ClientException {
      print('ClientException occurred');
      return false; // Return false if client error occurs
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch data');
    }
  }


  Future<bool> resendOtp(String url, String username) async {
    print('Api Get, url $url');
    http.Response responseJson;
    String isValid = 'true';

    try {
      final Uri uri = Uri.parse(_baseUrl + url); // parse string

      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(<String, String>{
          'username': username,
        }),
      );

      print("Response code: ${response.statusCode}");
      print("Response body: ${response.body}");

      // Check if the status code is 202 ACCEPTED
      if (response.statusCode == 202) {
        return true;
      } else {
        return false;
      }
    } on SocketException {
      print('No net');
      throw FetchDataException('No Internet connection');
    } on http.ClientException {
      print('ClientException occurred');
      return false; // Return false if client error occurs
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch data');
    }
  }




  Future<ResetPassword> getResetPasswordToken(String url, String email) async {
    print('Api Get, url $url');
    http.Response responseJson;
    String isValid = 'true';

    try {
      final Uri uri = Uri.parse(_baseUrl + url); // parse string

      print("uri "+uri.toString());
      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(<String, String>{
          'email': email,
        }),
      );


      print("Response code: ${response.statusCode}");
      print("Response body: ${response.body}");

      return ResetPassword.fromJson(jsonDecode(response.body));


    } on SocketException {
      print('No net');
      throw FetchDataException('No Internet connection');
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch data');
    }
  }



  Future<bool> updatePassword(String url, String token, String password) async {
    print('Api Get, url $url');
    http.Response responseJson;
    String isValid = 'true';

    try {
      final Uri uri = Uri.parse(_baseUrl + url); // parse string

      final response = await http.put(
        uri,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(<String, String>{
          'token': token,
          'new_password': password,

        }),
      );

      print("Response code: ${response.statusCode}");
      print("Response body: ${response.body}");

      // Check if the status code is 202 ACCEPTED
      if (response.statusCode == 204) {
        return true;
      } else {
        return false;
      }
    } on SocketException {
      print('No net');
      throw FetchDataException('No Internet connection');
    } on http.ClientException {
      print('ClientException occurred');
      return false; // Return false if client error occurs
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch data');
    }
  }


  Future<List<ServicesResponseData>?> getServiecs(
      String url) async {
    print('Api Get, url $url');
    try {
      final Uri uri = Uri.parse(_baseUrl + url) ;

      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          'Authorization': "Bearer ${ConstantVariable.authToken!}",
        },
      );

      print("coded " + "${response.body}");


      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((json) => ServicesResponseData.fromJson(json)).toList();



    } on SocketException {
      print('No net');
      throw FetchDataException('No Internet connection');
    } on http.ClientException {
      print('here');
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch data');
    }
  }



  Future<List<ServicesResponseData>?> getProfileData(
      String url) async {
    print('Api Get, url $url');
    try {
      final Uri uri = Uri.parse(_baseUrl + url) ;

      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          'Authorization': "Bearer ${ConstantVariable.authToken!}",
        },
      );

      print("coded " + "${response.body}");


      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((json) => ServicesResponseData.fromJson(json)).toList();



    } on SocketException {
      print('No net');
      throw FetchDataException('No Internet connection');
    } on http.ClientException {
      print('here');
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch data');
    }
  }


  Future<CustomerProfileResponse?> getCustomerProfileData(
      String url) async {
    print('Api Get, url $url');
    try {
      final Uri uri = Uri.parse(_baseUrl + url) ;

      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          'Authorization': "Bearer ${ConstantVariable.authToken!}",
        },
      );

      print("coded " + "${response.body}");


      /*List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((json) => CustomerProfileResponse.fromJson(json)).toList();*/
      return CustomerProfileResponse.fromJson(jsonDecode(response.body));



    } on SocketException {
      print('No net');
      throw FetchDataException('No Internet connection');
    } on http.ClientException {
      print('here');
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch data');
    }
  }

 Future<CustomerProfileResponse?> deleteAccount(
      String url) async {
    print('Api Get, url $url');
    print('Api Get, url "${ConstantVariable.authToken}');


    try {
      final Uri uri = Uri.parse(_baseUrl + url) ;

      final response = await http.delete(
        uri,
        headers: {
          "Content-Type": "application/json",
          'Authorization': "Bearer ${ConstantVariable.authToken!}",
        },
      );

      print("coded " + "${response.body}");


      /*List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((json) => CustomerProfileResponse.fromJson(json)).toList();*/
      return CustomerProfileResponse.fromJson(jsonDecode(response.body));



    } on SocketException {
      print('No net');
      throw FetchDataException('No Internet connection');
    } on http.ClientException {
      print('here');
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch data');
    }
  }
  Future<CustomerProfileResponse?> getMApKey(
      String url) async {
    print('Api Get, url $url');
    try {
      final Uri uri = Uri.parse(_baseUrl + url) ;

      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          'Authorization': "Bearer ${ConstantVariable.authToken!}",
        },
      );

      print("coded " + "${response.body}");


      /*List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((json) => CustomerProfileResponse.fromJson(json)).toList();*/
      return CustomerProfileResponse.fromJson(jsonDecode(response.body));



    } on SocketException {
      print('No net');
      throw FetchDataException('No Internet connection');
    } on http.ClientException {
      print('here');
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch data');
    }
  }




  Future<CustomerProfileResponse?> updateCustomerProfileData(
      String url,
      ProfileInputData profileInputData) async {
    print('Api Get, url $url');
    try {
      final Uri uri = Uri.parse(_baseUrl + url) ;

      final response = await http.put(
        uri,
        headers: {
          "Content-Type": "application/json",
          'Authorization': "Bearer ${ConstantVariable.authToken!}",
        },

        body: jsonEncode(profileInputData.toJson()),

      );

      print("coded " + "${response.body}");


      /*List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((json) => CustomerProfileResponse.fromJson(json)).toList();*/
      return CustomerProfileResponse.fromJson(jsonDecode(response.body));



    } on SocketException {
      print('No net');
      throw FetchDataException('No Internet connection');
    } on http.ClientException {
      print('here');
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch data');
    }
  }





  Future<List<LocationResponseData>?> getLocationBasedServiecs(String url) async {
    print('Api Get, url $url');
    try {
      final Uri uri = Uri.parse(_baseUrl + url); // parse string

      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          'Authorization': "Bearer ${ConstantVariable.authToken!}",
        },
      );

      print("coded " + "${response.body}");
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((json) => LocationResponseData.fromJson(json)).toList();



    } on SocketException {
      print('No net');
      throw FetchDataException('No Internet connection');
    } on http.ClientException {
      print('here');
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch data');
    }
  }

  Future<List<ProfessionalResponseData>?> getProfessionals(String url,String location, String price_range, String sid ) async {
    print('Api Get, url $url');

    try {
      final Uri uri;
      if( sid.isEmpty ){
        final queryParameters = {
          'location': location,
          'price_range': price_range,



        };
        uri = Uri.parse(_baseUrl + url).replace(queryParameters: queryParameters);

        print("uri "+uri.toString());

      }else{

        final queryParameters = {
          'location': location,
          'price_range': price_range,
          'sid': sid,


        };
        uri = Uri.parse(_baseUrl + url).replace(queryParameters: queryParameters);
      }

      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          /*'Authorization': "Bearer ${ConstantVariable.authToken!}",*/
        },
      );

      print("coded " + "${response.body}");
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((json) => ProfessionalResponseData.fromJson(json)).toList();


    } on SocketException {
      print('No net');
      throw FetchDataException('No Internet connection');
    } on http.ClientException {
      print('here');
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch data');
    }
  }


  Future<ProfileDataResponse?> getVendorProfile(String url,String vendorId) async {
    print('Api Get, url $url');
    http.Response responseJson;
    String isValid = 'true';

    try {

      final Uri uri = Uri.parse(_baseUrl + url+'/$vendorId');
      print("vendor profile "+uri.toString());// parse string
      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          'Authorization': "Bearer "+ConstantVariable.authToken!,
        },

      );

      print("coded " + "${response.body}");

      return ProfileDataResponse.fromJson(jsonDecode(response.body));

    } on SocketException {
      print('No net');
      throw FetchDataException('No Internet connection');
    }on http.ClientException{

      print('here');

    }catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch data');
    }
  }


  Future<List<ServicesProvidedByVendorResponseData>?> getServicesProvidedByVendor(String url,String vendorId) async {
    print('Api Get, url $url');
    http.Response responseJson;
    String isValid = 'true';

    try {

      final Uri uri = Uri.parse(_baseUrl + url+'/$vendorId'); // parse string
      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          /*'Authorization': "Bearer "+ConstantVariable.authToken!,*/
        },

      );

      print("coded " + "${response.body}");


      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((json) => ServicesProvidedByVendorResponseData.fromJson(json)).toList();



    } on SocketException {
      print('No net');
      throw FetchDataException('No Internet connection');
    }on http.ClientException{

      print('here');

    }catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch data');
    }
  }


  Future<RentalLocations?> getRentalLocations(String url, String vendorId) async {
    print('📡 API GET Request Started');
    http.Response responseJson;

    try {
      final Uri uri = Uri.parse("$_baseUrl$url/$vendorId"); // Full URL
      print("➡️ Request URL: $uri");

      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${ConstantVariable.authToken!}",
        },
      );

      print("✅ Response Code: ${response.statusCode}");
      print("📦 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return RentalLocations.fromJson(jsonDecode(response.body));
      } else {
        print("❌ Error Response: ${response.statusCode} | ${response.reasonPhrase}");
        throw Exception("Failed with status code ${response.statusCode}");
      }
    } on SocketException {
      print('❌ No Internet connection');
      throw FetchDataException('No Internet connection');
    } on http.ClientException catch (e) {
      print('❌ ClientException: $e');
      throw Exception('HTTP Client Exception: $e');
    } catch (e, stack) {
      print('❌ Unexpected Error: $e');
      print('🔍 StackTrace: $stack');
      throw Exception('Failed to fetch data');
    }
  }



/*

  Future<RentalLocations?> getRentalLocations(String url,String vendorId) async {
    print('Api Get, url $url');
    http.Response responseJson;
    String isValid = 'true';

    try {

      final Uri uri = Uri.parse(_baseUrl + url+'/$vendorId'); // parse string
      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          'Authorization': "Bearer "+ConstantVariable.authToken!,
        },
      );

      print("coded " + "${response.body}");
      return RentalLocations.fromJson(jsonDecode(response.body));

    } on SocketException {
      print('No net');
      throw FetchDataException('No Internet connection');
    }on http.ClientException{

      print('here');

    }catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch data');
    }
  }
*/




  Future<List<ReviewsResponseData>?> getVendorReviews(String url,String vendorId) async {
    print('Api Get, url $url');
    http.Response responseJson;
    String isValid = 'true';

    try {
      final Uri uri = Uri.parse(_baseUrl + url+'/$vendorId'+"/reviews");
      print("uri  "+uri.toString());// parse string
      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          /*'Authorization': "Bearer "+ConstantVariable.authToken!,*/
        },

      );

      print("coded " + "${response.body}");


      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((json) => ReviewsResponseData.fromJson(json)).toList();



    } on SocketException {
      print('No net');
      throw FetchDataException('No Internet connection');
    }on http.ClientException{

      print('here');

    }catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch data');
    }
  }




  Future<AvailableSlotResponseData?> getVendorWorkingHours(String url,String vendorId,String appointment_date,String service_id) async {
    print('Api Get, url $url');
    http.Response responseJson;
    String isValid = 'true';


    try {

      final Uri uri = Uri.parse(_baseUrl + url+'/$vendorId'+'/$appointment_date'+'/$service_id');

      print("uri here in "+uri.toString());
      print("uri "+uri.toString());// parse string
      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
         /* 'Authorization': "Bearer "+ConstantVariable.authToken!,*/
        },

      );

      print("coded " + "${response.body}");

      return AvailableSlotResponseData.fromJson(jsonDecode(response.body));

    } on SocketException {
      print('No net');
      throw FetchDataException('No Internet connection');
    }on http.ClientException{

      print('here');

    }catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch data');
    }
  }


  Future<CreateAppointmentResponse?> createAppointment(String url,AppointmentInputData appointmentInputData) async {
    print('Api Get, url $url');
    http.Response responseJson;
    String isValid = 'true';

    try {

      print("ConstantVariable.authToken "+ConstantVariable.authToken!);
      /*final Uri uri = Uri.parse(_baseUrl + url); // parse string
      final response = await http.post(
        uri,
        final headers: {
          "Content-Type": "application/json",
           'Authorization': "Bearer "+ConstantVariable.authToken!,
        },
        body: jsonEncode(appointmentInputData.toJson()),);*/



    final Uri uri = Uri.parse(_baseUrl + url);
    final headers = {
    "Content-Type": "application/json",
    'Authorization': "Bearer "+ConstantVariable.authToken!,

    };
    final body = jsonEncode(appointmentInputData.toJson());
      print('🧾 Request Headers: $headers');
      print('📦 Request Body: $body');

      try {
        final response = await http.post(uri, headers: headers, body: body);

        print('✅ Status Code: ${response.statusCode}');
        print('📨 Response Body: ${response.body}');

        return CreateAppointmentResponse.fromJson(jsonDecode(response.body));
      } on SocketException {
        print('❌ No Internet connection');
        throw FetchDataException('No Internet connection');
      } on http.ClientException {
        print('❌ Client Exception');
      } catch (e) {
        print('❌ Unexpected Error: $e');
        throw Exception('Failed to fetch data');
      }

    /*
      print('✅ Status Code: ${response.statusCode}');
      print('📨 Response Body: ${response.body}');


      print("coded " + "${response.body}");

      return CreateAppointmentResponse.fromJson(jsonDecode(response.body));*/

    } on SocketException {
      print('No net');
      throw FetchDataException('No Internet connection');
    }on http.ClientException{

      print('here');

    }catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch data');
    }
  }



  Future<String?> getCheckoutLink(String url,String appointment_id) async {
    print('Api Get, url $url');
    http.Response responseJson;
    String isValid = 'true';

    try {

      print("ConstantVariable.authToken "+ConstantVariable.authToken!);

      final Uri uri = Uri.parse(_baseUrl + url);
      final headers = {
        "Content-Type": "application/json",
        'Authorization': "Bearer "+ConstantVariable.authToken!,

      };
      //final body = jsonEncode(appointmentInputData.toJson());

    final body = jsonEncode(<String, dynamic>{
        'appointment_id': int.tryParse(appointment_id) ?? appointment_id,
      });


      print('🧾 Request Headers: $headers');
      print('📦 Request Body: $body');

      try {
        final response = await http.post(uri, headers: headers, body: body);

        print('✅ Status Code: ${response.statusCode}');
        print('📨 Response Body: ${response.body}');
        final data = jsonDecode(response.body);
        final checkoutUrl = data['checkout_url'];


        return checkoutUrl;

      } on SocketException {
        print('❌ No Internet connection');
        throw FetchDataException('No Internet connection');
      } on http.ClientException {
        print('❌ Client Exception');
      } catch (e) {
        print('❌ Unexpected Error: $e');
        throw Exception('Failed to fetch data');
      }


    } on SocketException {
      print('No net');
      throw FetchDataException('No Internet connection');
    }on http.ClientException{

      print('here');

    }catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch data');
    }
  }



  Future<List<OrdersResponseData>?> getOrder(
      String url) async {
    print('Api Get, url $url');
    try {


      final queryParameters = {
        'period': "open",
      };

      final Uri uri = Uri.parse(_baseUrl + url).replace(queryParameters: queryParameters);



      //final Uri uri = Uri.parse(_baseUrl + url) ;

      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          'Authorization': "Bearer ${ConstantVariable.authToken!}",
        },

      );

      print("coded " + "${response.body}");


      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((json) => OrdersResponseData.fromJson(json)).toList();



    } on SocketException {
      print('No net');
      throw FetchDataException('No Internet connection');
    } on http.ClientException {
      print('here');
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch data');
    }
  }


  Future<OrdersResponseData?> getOrderDetails(String url,String? ordedrId) async {
    print('Api Get, url $url');
    try {

      final Uri uri = Uri.parse(_baseUrl + url+'/$ordedrId');
      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          'Authorization': "Bearer ${ConstantVariable.authToken!}",
        },
      );

      print("coded " + "${response.body}");
      return OrdersResponseData.fromJson(jsonDecode(response.body));
    } on SocketException {
      print('No net');
      throw FetchDataException('No Internet connection');
    } on http.ClientException {
      print('here');
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch data');
    }
  }



  Future<OrderStagesDataResponse?> getAppointmentStages(String url, String? id) async {
    print('Api Get, url $url');

    try {

      // Construct the URL with the path parameter
      final Uri uri = Uri.parse(_baseUrl + url+'/$id'+'/stages');
      print('Constructed URI: $uri');

      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          'Authorization': "Bearer " + ConstantVariable.authToken!,
        },
      );

      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        return OrderStagesDataResponse.fromJson(jsonDecode(response.body));
      } else {
        // Handle non-200 responses
        print('Failed to load data. Status code: ${response.statusCode}');
        return null;
      }

    } on SocketException {
      print('No internet connection');
      throw FetchDataException('No Internet connection');
    } on http.ClientException {
      print('Client Exception');
      throw FetchDataException('Client Exception occurred');
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch data');
    }
  }


  Future<StartChatResponse?> startChat(String url,
      String appointment_id,

      ) async {
    print('Api Get, url $url');

    try {

      final Uri uri = Uri.parse(_baseUrl + url+'/$appointment_id');
      print('startChat uri: $uri');
      final response = await http.post(
          uri,
          headers: {
            "Content-Type": "application/json",
            'Authorization': "Bearer "+ConstantVariable.authToken!,
          },

          body: jsonEncode(<String, String>{

          }));

      print("startChat response body: ${response.body}");

      final decoded = jsonDecode(response.body);
      // API may return an object or an array depending on whether chat exists
      if (decoded is Map<String, dynamic>) {
        return StartChatResponse.fromJson(decoded);
      } else {
        print('startChat: unexpected response format (not a map): $decoded');
        return null;
      }

    } on SocketException {
      print('No net');
      throw FetchDataException('No Internet connection');
    } on http.ClientException {
      print('here');
    } catch (e) {
      print('Error in startChat: $e');
    }
    return null;
  }


  Future<List<ChatHistoryResponseData>?> fetchHistoryChat(String url,
      String appointment_id,

      ) async {
    print('Api Get, url $url');
    http.Response responseJson;

    try {

      final Uri uri = Uri.parse(_baseUrl + url+'/$appointment_id'+'/history');
      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          'Authorization': "Bearer "+ConstantVariable.authToken!,
        },

      );
      print("coded 1122" + "${uri}");

      print("coded 1122" + "${response.body}");

      //return ChatHistoryResponseData.fromJson(jsonDecode(response.body));

      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((json) => ChatHistoryResponseData.fromJson(json)).toList();


    } on SocketException {
      print('No net');
      throw FetchDataException('No Internet connection');
    }on http.ClientException{

      print('here');

    }catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch data');
    }
  }



}
