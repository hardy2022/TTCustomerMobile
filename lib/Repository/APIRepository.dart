import 'dart:convert';

import '../POJO/profile_input_data.dart';

import '../Networking/api_base_helper.dart';
import '../POJO/location_response_data.dart';
import '../POJO/professional_response_data.dart';
import '../POJO/rental_locations.dart';
import '../POJO/reset_password.dart';
import '../POJO/reviews_response_data.dart';
import '../POJO/services_response_data.dart';
import '../POJO/AppointmnetSlotsResponseData.dart';
import '../POJO/login_response_data.dart';
import '../POJO/RegisterResponseData.dart';
import '../POJO/appointment_input_data.dart';
import '../POJO/chat_history_response_data.dart';
import '../POJO/create_appointment_response.dart';
import '../POJO/customer_profile_response.dart';
import '../POJO/order_stages_data_response.dart';
import '../POJO/orders_response_data.dart';
import '../POJO/profile_data_response.dart';
import '../POJO/services_provided_by_vendor.dart';
import '../POJO/start_chat_response.dart';

class APIRepository {
  ApiBaseHelper _helper = ApiBaseHelper();

  Future<LoginResponseData?> login(String? email, String? password) async {
    String ps = email.toString() + ":" + password.toString();
    print('ps !!!@@@@' + '$ps');

    String encodedText = base64Encode(utf8.encode(ps));
    print('encodedText !!!@@@@' + '$encodedText');

    final response = await _helper.login("api/tokens", "Basic " + encodedText);
    print('response !!!@@@@' + '$response');
    return response;
  }



  Future<LoginResponseData?> getToken(String access_token,String refresh_token) async {

    final response = await _helper.getToken("api/tokens", access_token,refresh_token);
    print('response !!!@@@@' + '$response');
    return response;
  }


  Future<LoginResponseData?> updateFCMToken() async {

    final response = await _helper.updateFCMToken("users/device-token");
    print('response !!!@@@@' + '$response');
    return response;
  }


  Future<RegisterResponseData?> register(
      String? entity_id,
      String? first_name,
      String? last_name,
      String? username,
      String? password,
      String? mobile) async {
    final response = await _helper.register("users", entity_id!, first_name!,
        last_name!, username!, password!, mobile!);
    print('response !!!@@@@' + '$response');
    return response;
  }

  Future<bool> verifyOTP(String? otp, String? username) async {
    final response = await _helper.verifyOTP("users/verify", otp!, username!);
    print('response !!!@@@@' + '$response');
    return response;
  }

  Future<bool> resendOtp(String? username) async {
    final response =
        await _helper.resendOtp("users/resend-verification", username!);
    print('response !!!@@@@' + '$response');
    return response;
  }

  Future<ResetPassword> getResetPasswordToken(String? email) async {
    final response =
        await _helper.getResetPasswordToken("api/tokens/reset", email!);
    print('response !!!@@@@' + '$response');
    return response;
  }

  Future<bool> updatePassword(String? token, String? newPassword) async {
    final response =
        await _helper.updatePassword("api/tokens/reset", token!, newPassword!);
    print('response !!!@@@@' + '$response');
    return response;
  }

  Future<List<ProfessionalResponseData>?> getProfessionals(
      String location, String price_range, String sid) async {
    final response = await _helper.getProfessionals(
        "vendors/list", location, price_range, sid);
    print('response !!!@@@@' + '$response');
    return response;
  }

  Future<List<ServicesResponseData>?> getServiecs() async {
    final response = await _helper.getServiecs("vendors/services");
    print('response !!!@@@@' + '$response');
    return response;
  }

  Future<List<LocationResponseData>?> getLocationBasedServiecs() async {
    final response =
        await _helper.getLocationBasedServiecs("vendors/locations");
    print('response !!!@@@@' + '$response');
    return response;
  }

  Future<ProfileDataResponse?> getVendorProfile(String vendorId) async {
    final response = await _helper.getVendorProfile("vendors", vendorId);
    print('response !!!@@@@' + '$response');
    return response;
  }

  Future<CustomerProfileResponse?> getCustomerProfileData() async {
    final response = await _helper.getCustomerProfileData("/customers/me");
    print('response !!!@@@@' + '$response');
    return response;
  }

  Future<CustomerProfileResponse?> deleteAccount() async {
    final response = await _helper.deleteAccount("/users/me");
    print('response !!!@@@@' + '$response');
    return response;
  }

  Future<CustomerProfileResponse?> updateCustomerProfileData(
      ProfileInputData profileInputData) async {
    final response = await _helper.updateCustomerProfileData(
        "/customers/me", profileInputData);
    print('response !!!@@@@' + '$response');
    return response;
  }

  Future<List<ReviewsResponseData>?> getVendorReviews(String vendorId) async {
    final response = await _helper.getVendorReviews("vendor", vendorId);
    print('response !!!@@@@' + '$response');
    return response;
  }

  Future<List<ServicesProvidedByVendorResponseData>?>
      getServicesProvidedByVendor(String vendorId) async {

    final response =
        await _helper.getServicesProvidedByVendor("vendors/services", vendorId);
    print('response !!!@@@@' + '$response');
    return response;
  }


  Future<RentalLocations?>
  getRentalLocations(String vendorId) async {

    final response =
    await _helper.getRentalLocations("vendors/service-locations", vendorId);
    print('response !!!@@@@' + '$response');
    return response;
  }



  Future<AvailableSlotResponseData?> getVendorWorkingHours(
      String vendorId, String appointment_date, String service_id) async {
    final response = await _helper.getVendorWorkingHours(
        "vendors/appointment-hours", vendorId, appointment_date, service_id);
    print('response !!!@@@@' + '$response');
    return response;
  }

  Future<CreateAppointmentResponse?> createAppointment(
      AppointmentInputData appointmentInputData) async {
    final response =
        await _helper.createAppointment("appointments", appointmentInputData);
    print('response !!!@@@@' + '$response');
    return response;
  }

  Future<List<OrdersResponseData>?> getOrder() async {
    final response = await _helper.getOrder("orders");
    print('response !!!@@@@' + '$response');
    return response;
  }

  Future<OrdersResponseData?> getOrderDetails(String? orderId) async {
    final response = await _helper.getOrderDetails("orders", orderId);
    print('response !!!@@@@' + '$response');
    return response;
  }

  Future<String?> getCheckoutLink(String? appointmentId) async {
    final response = await _helper.getCheckoutLink("checkout", appointmentId!);
    print('response !!!@@@@' + '$response');
    return response;
  }



  Future<OrderStagesDataResponse?> getAppointmentStages(String? id) async {
    final response = await _helper.getAppointmentStages("orders", id);
    print('response !!!@@@@' + '$response');
    return response;
  }

  Future<StartChatResponse?> startChat(String appointment_id) async {
    final response = await _helper.startChat(
      "chats",
      appointment_id,
    );
    print('response !!!@@@@' + '$response');
    return response;
  }

  Future<List<ChatHistoryResponseData>?> fetchHistoryChat(
      String appointment_id) async {
    final response = await _helper.fetchHistoryChat(
      "chats",
      appointment_id,
    );
    print('response !!!@@@@' + '$response');
    return response;
  }


}
