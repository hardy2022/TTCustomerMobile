import 'dart:async';

import '../POJO/profile_input_data.dart';

import '../POJO/login_response_data.dart';
import '../POJO/RegisterResponseData.dart';
import '../POJO/location_response_data.dart';
import '../POJO/professional_response_data.dart';
import '../POJO/rental_locations.dart';
import '../POJO/reset_password.dart';
import '../POJO/reviews_response_data.dart';
import '../POJO/services_response_data.dart';

import '../Networking/api_response.dart';
import '../POJO/AppointmnetSlotsResponseData.dart';
import '../POJO/appointment_input_data.dart';
import '../POJO/chat_history_response_data.dart';
import '../POJO/create_appointment_response.dart';
import '../POJO/customer_profile_response.dart';
import '../POJO/order_stages_data_response.dart';
import '../POJO/orders_response_data.dart';
import '../POJO/profile_data_response.dart';
import '../POJO/services_provided_by_vendor.dart';
import '../POJO/start_chat_response.dart';
import '../Repository/APIRepository.dart';

class APIBloC {
  late StreamController<ApiResponse<String>> _validateChannelController;
  late APIRepository _aPIRepository; // Declare as late
  StreamSink<ApiResponse<String>> get validateChannelSink =>
      _validateChannelController.sink;
  Stream<ApiResponse<String>> get validateChannelStream =>
      _validateChannelController.stream;

  APIBloC() {
    _validateChannelController = StreamController<ApiResponse<String>>();
    _aPIRepository = APIRepository();
  }

  Future<RegisterResponseData?> register(
      String entity_id,
      String first_name,
      String last_name,
      String user_name,
      String password,
      String mobile) async {
    print('here####');
    validateChannelSink.add(ApiResponse.loading('Loading...'));

    try {
      RegisterResponseData? userdata1 = await _aPIRepository.register(
          entity_id, first_name, last_name, user_name, password, mobile);
      print("userdata1 " + userdata1.toString());
      validateChannelSink.add(ApiResponse.completed("true"));
      return userdata1;
    } catch (e) {
      validateChannelSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  Future<LoginResponseData?> updateFCMToken() async {
    print('here####');
    validateChannelSink.add(ApiResponse.loading('Loading...'));

    try {
      LoginResponseData? userdata1 =
      await _aPIRepository.updateFCMToken();
      print("userdata1 " + userdata1.toString());
      validateChannelSink.add(ApiResponse.completed("true"));
      return userdata1;
    } catch (e) {
      validateChannelSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }


  Future<bool> verifyOTP(String otp, String username) async {
    print('here####');
    validateChannelSink.add(ApiResponse.loading('Loading...'));

    try {
      bool userdata1 = await _aPIRepository.verifyOTP(otp, username);
      print("userdata1 " + userdata1.toString());
      validateChannelSink.add(ApiResponse.completed("true"));

      if (userdata1) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      validateChannelSink.add(ApiResponse.error(e.toString()));
      print(e);
      return false; // Return false in case of an error
    }
  }

  Future<bool> resendOtp(String username) async {
    print('here####');
    validateChannelSink.add(ApiResponse.loading('Loading...'));

    try {
      bool userdata1 = await _aPIRepository.resendOtp(username);
      print("userdata1 " + userdata1.toString());
      validateChannelSink.add(ApiResponse.completed("true"));

      if (userdata1) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      validateChannelSink.add(ApiResponse.error(e.toString()));
      print(e);
      return false; // Return false in case of an error
    }
  }

  Future<ResetPassword?> getResetPasswordToken(String email) async {
    print('here####');
    validateChannelSink.add(ApiResponse.loading('Loading...'));

    try {
      ResetPassword userdata1 =
          await _aPIRepository.getResetPasswordToken(email);
      print("userdata1 " + userdata1.toString());
      validateChannelSink.add(ApiResponse.completed("true"));
      return userdata1;
    } catch (e) {
      validateChannelSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  Future<bool> updatePassword(String token, String password) async {
    print('here####');
    validateChannelSink.add(ApiResponse.loading('Loading...'));

    try {
      bool userdata1 = await _aPIRepository.updatePassword(token, password);
      print("userdata1 " + userdata1.toString());
      validateChannelSink.add(ApiResponse.completed("true"));

      if (userdata1) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      validateChannelSink.add(ApiResponse.error(e.toString()));
      print(e);
      return false; // Return false in case of an error
    }
  }

  Future<LoginResponseData?> login(String user_name, String password) async {
    print('here####');
    validateChannelSink.add(ApiResponse.loading('Loading...'));

    try {
      LoginResponseData? userdata1 =
          await _aPIRepository.login(user_name, password);
      print("userdata1 " + userdata1.toString());
      validateChannelSink.add(ApiResponse.completed("true"));
      return userdata1;
    } catch (e) {
      validateChannelSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  Future<LoginResponseData?> getNewToken(String access_token,String refresh_token) async {
    print('here####');
    validateChannelSink.add(ApiResponse.loading('Loading...'));

    try {
      LoginResponseData? userdata1 =
      await _aPIRepository.getToken(access_token!, refresh_token!);
      print("userdata1 " + userdata1.toString());
      validateChannelSink.add(ApiResponse.completed("true"));
      return userdata1;
    } catch (e) {
      validateChannelSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }



  Future<List<ProfessionalResponseData>?> getProfessionals(
      String location, String price_range, String sid) async {
    print('here####');
    validateChannelSink.add(ApiResponse.loading('Loading...'));

    try {
      List<ProfessionalResponseData>? userdata1 =
          await _aPIRepository.getProfessionals(location, price_range, sid);
      print("userdata1 " + userdata1.toString());
      validateChannelSink.add(ApiResponse.completed("true"));
      return userdata1;
    } catch (e) {
      validateChannelSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  Future<List<ServicesResponseData>?> getServiecs() async {
    print('here####');
    validateChannelSink.add(ApiResponse.loading('Loading...'));

    try {
      List<ServicesResponseData>? userdata1 =
          await _aPIRepository.getServiecs();
      print("userdata1 " + userdata1.toString());
      validateChannelSink.add(ApiResponse.completed("true"));
      return userdata1;
    } catch (e) {
      validateChannelSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  Future<CustomerProfileResponse?> getCustomerProfileData() async {
    print('here####');
    validateChannelSink.add(ApiResponse.loading('Loading...'));

    try {
      CustomerProfileResponse? userdata1 =
          await _aPIRepository.getCustomerProfileData();
      print("userdata1 " + userdata1.toString());
      validateChannelSink.add(ApiResponse.completed("true"));
      return userdata1;
    } catch (e) {
      validateChannelSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  Future<CustomerProfileResponse?> deleteAccount() async {
    print('here####');
    validateChannelSink.add(ApiResponse.loading('Loading...'));

    try {
      CustomerProfileResponse? userdata1 = await _aPIRepository.deleteAccount();
      print("userdata1 " + userdata1.toString());
      validateChannelSink.add(ApiResponse.completed("true"));
      return userdata1;
    } catch (e) {
      validateChannelSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  Future<CustomerProfileResponse?> updateCustomerProfileData(
      ProfileInputData profileInputData) async {
    print('here####');
    validateChannelSink.add(ApiResponse.loading('Loading...'));

    try {
      CustomerProfileResponse? userdata1 =
          await _aPIRepository.updateCustomerProfileData(profileInputData);
      print("userdata1 " + userdata1.toString());
      validateChannelSink.add(ApiResponse.completed("true"));
      return userdata1;
    } catch (e) {
      validateChannelSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  Future<List<LocationResponseData>?> getLocationBasedServiecs() async {
    print('here####');
    validateChannelSink.add(ApiResponse.loading('Loading...'));

    try {
      List<LocationResponseData>? userdata1 =
          await _aPIRepository.getLocationBasedServiecs();
      print("userdata1 " + userdata1.toString());
      validateChannelSink.add(ApiResponse.completed("true"));
      return userdata1;
    } catch (e) {
      validateChannelSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  Future<List<ServicesResponseData>?> getServiecDetails(
      String location, String sid, String vendor) async {
    print('here####');
    validateChannelSink.add(ApiResponse.loading('Loading...'));

    try {
      List<ServicesResponseData>? userdata1 =
          await _aPIRepository.getServiecs();
      print("userdata1 " + userdata1.toString());
      validateChannelSink.add(ApiResponse.completed("true"));
      return userdata1;
    } catch (e) {
      validateChannelSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  Future<ProfileDataResponse?> getVendorProfileData(String vendorId) async {
    print('here####');
    validateChannelSink.add(ApiResponse.loading('Loading...'));

    try {
      ProfileDataResponse? userdata1 =
          await _aPIRepository.getVendorProfile(vendorId);
      print("userdata1 " + userdata1.toString());
      validateChannelSink.add(ApiResponse.completed("true"));
      return userdata1;
    } catch (e) {
      validateChannelSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  Future<List<ServicesProvidedByVendorResponseData>?>
      getServicesProvidedByVendor(String vendorId) async {
    print('here####');
    validateChannelSink.add(ApiResponse.loading('Loading...'));

    try {
      List<ServicesProvidedByVendorResponseData>? userdata1 =
          await _aPIRepository.getServicesProvidedByVendor(vendorId);
      print("userdata1 " + userdata1.toString());
      validateChannelSink.add(ApiResponse.completed("true"));
      return userdata1;
    } catch (e) {
      validateChannelSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }


  Future<RentalLocations?>
  getRentalLocations(String vendorId) async {
    print('here####');
    validateChannelSink.add(ApiResponse.loading('Loading...'));

    try {
      RentalLocations? userdata1 =
      await _aPIRepository.getRentalLocations(vendorId);
      print("userdata1 " + userdata1.toString());
      validateChannelSink.add(ApiResponse.completed("true"));
      return userdata1;
    } catch (e) {
      validateChannelSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }



  Future<List<ReviewsResponseData>?> getVendorReviews(String vendorId) async {
    print('here####');
    validateChannelSink.add(ApiResponse.loading('Loading...'));

    try {
      List<ReviewsResponseData>? userdata1 =
          await _aPIRepository.getVendorReviews(vendorId);
      print("userdata1 " + userdata1.toString());
      validateChannelSink.add(ApiResponse.completed("true"));
      return userdata1;
    } catch (e) {
      validateChannelSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  Future<AvailableSlotResponseData?> getVendorWorkingHours(
      String vendorId, String appointment_date, String service_id) async {
    print('here####');
    validateChannelSink.add(ApiResponse.loading('Loading...'));

    try {
      AvailableSlotResponseData? userdata1 = await _aPIRepository
          .getVendorWorkingHours(vendorId, appointment_date, service_id);
      print("userdata1 " + userdata1.toString());
      validateChannelSink.add(ApiResponse.completed("true"));
      return userdata1;
    } catch (e) {
      validateChannelSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  Future<CreateAppointmentResponse?> createAppointment(
      AppointmentInputData appointmentInputData) async {
    print('here####');
    validateChannelSink.add(ApiResponse.loading('Loading...'));

    try {
      CreateAppointmentResponse? userdata1 =
          await _aPIRepository.createAppointment(appointmentInputData);
      print("userdata1 " + userdata1.toString());
      validateChannelSink.add(ApiResponse.completed("true"));
      return userdata1;
    } catch (e) {
      validateChannelSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  Future<List<OrdersResponseData>?> getOrder() async {
    print('here####');
    validateChannelSink.add(ApiResponse.loading('Loading...'));

    try {
      List<OrdersResponseData>? userdata1 = await _aPIRepository.getOrder();
      print("userdata1 " + userdata1.toString());
      validateChannelSink.add(ApiResponse.completed("true"));
      return userdata1;
    } catch (e) {
      validateChannelSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  Future<OrderStagesDataResponse?> getAppointmentStages(String? id) async {
    print('here####');
    validateChannelSink.add(ApiResponse.loading('Loading...'));

    try {
      OrderStagesDataResponse? userdata1 =
          await _aPIRepository.getAppointmentStages(id);
      print("userdata1 " + userdata1.toString());
      validateChannelSink.add(ApiResponse.completed("true"));
      return userdata1;
    } catch (e) {
      validateChannelSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  Future<StartChatResponse?> startChat(String appointment_id) async {
    print('here####');
    validateChannelSink.add(ApiResponse.loading('Loading...'));

    try {
      StartChatResponse? userdata1 =
          await _aPIRepository.startChat(appointment_id);
      print("StartChatResponse " + userdata1.toString());
      validateChannelSink.add(ApiResponse.completed("true"));
      return userdata1;
    } catch (e) {
      validateChannelSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  Future<List<ChatHistoryResponseData>?> fetchHistoryChat(
      String appointment_id) async {
    print('here####');
    validateChannelSink.add(ApiResponse.loading('Loading...'));

    try {
      List<ChatHistoryResponseData>? userdata1 =
          await _aPIRepository.fetchHistoryChat(appointment_id);
      print("StartChatResponse " + userdata1.toString());
      validateChannelSink.add(ApiResponse.completed("true"));
      return userdata1;
    } catch (e) {
      validateChannelSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  Future<OrdersResponseData?> getOrderDetails(String orderId) async {
    print('here####');
    validateChannelSink.add(ApiResponse.loading('Loading...'));

    try {
      OrdersResponseData? userdata1 =
          await _aPIRepository.getOrderDetails(orderId);
      print("userdata1 " + userdata1.toString());
      validateChannelSink.add(ApiResponse.completed("true"));
      return userdata1;
    } catch (e) {
      validateChannelSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }


  Future<String?> getCheckoutLink(String appointmentId) async {
    print('here####');
    validateChannelSink.add(ApiResponse.loading('Loading...'));

    try {
      String? userdata1 =
      await _aPIRepository.getCheckoutLink(appointmentId);
      print("userdata1 " + userdata1.toString());
      validateChannelSink.add(ApiResponse.completed("true"));
      return userdata1;
    } catch (e) {
      validateChannelSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }



  dispose() {
    _validateChannelController.close();
  }
}
