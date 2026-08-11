import 'package:intl/intl.dart';


class DateConverter {

  // Define a static method to convert the date format
  static String convertDateFormat(String dateStr) {
    DateTime parsedDate = DateFormat('yyyy-MM-dd').parse(dateStr);
    return DateFormat('MMM dd').format(parsedDate);
  }


  static String convertDateFormat1(String dateStr) {
    DateTime parsedDate = DateFormat('yyyy-MM-dd').parse(dateStr);
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  }


  static String convertDateFormat2(String dateStr) {

    DateTime parsedDate = DateFormat('yyyy-mm-dd HH:mm:ss.SSS').parse(dateStr);
    return DateFormat('dd-mm-yyyy').format(parsedDate);
  }


  static String convertDateFormat3(String dateStr) {
    DateTime parsedDate = DateFormat('yyyy-MM-dd HH:mm:ss.SSSSSS').parse(dateStr); // Correct format for parsing
    return DateFormat('dd-MM-yyyy').format(parsedDate); // Correct format for output
  }


  static String convertTimeFormat111(String timeStr) {
    // Parse the input time string in the "hh:mm:ss" format
    DateTime parsedTime = DateFormat('HH:mm:ss').parse(timeStr);

    // Format the parsed time to the desired "hh:mm" format
    String formattedTime = DateFormat('HH:mm').format(parsedTime);

    return formattedTime;
  }


  static String convertTimeFormat(String timeStr) {
    if (timeStr.isEmpty) return ""; // 👈 avoid parsing empty strings

    try {
      // Accept both "HH:mm:ss" and "HH:mm:ss.SSSSSS"
      DateTime parsedTime;
      if (timeStr.contains(".")) {
        parsedTime = DateFormat("HH:mm:ss.SSSSSS").parse(timeStr);
      } else {
        parsedTime = DateFormat("HH:mm:ss").parse(timeStr);
      }

      return DateFormat("HH:mm").format(parsedTime);
    } catch (e) {
      print("⚠️ Failed to parse time: $timeStr, error: $e");
      return timeStr; // fallback to original
    }
  }


  /*static String convertTimeFormat(String timeStr) {
    if (timeStr.isEmpty) return "";

    try {
      // Dart can parse "2025-08-25 09:00:36.581004" and "11:00:00"
      DateTime parsed = DateTime.tryParse("1970-01-01 $timeStr") ??
          DateTime.parse(timeStr);
      return DateFormat("HH:mm").format(parsed);
    } catch (e) {
      print("⚠️ Failed to parse time: $timeStr, error: $e");
      return timeStr;
    }
  }*/



  static String convertTimeFormat1(String timeStr) {
    // Parse the input time string in the "hh:mm:ss" format
    DateTime parsedTime = DateFormat('HH:mm:ss').parse(timeStr);

    // Format the parsed time to the desired "hh:mm" format
    String formattedTime = DateFormat('HH:mm a').format(parsedTime);

    return formattedTime;
  }


/*
  static String formatDate(String dateStr) {
    // Parse the input date string
    DateTime parsedDate = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parseUTC(dateStr).toLocal();

    // Format the date to only show 'Mon, 30 Sep'
    String formattedDate = DateFormat("EEE, dd MMM").format(parsedDate);

    return formattedDate;
  }
*/

  static String formatDate(String dateStr) {
    try {
      // Check if the date string is null or empty
      if (dateStr == null || dateStr.isEmpty) {
        throw FormatException("Invalid date string");
      }

      // Parse the input date string with expected format
      DateTime parsedDate = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parseUTC(dateStr).toLocal();

      // Format the date to 'Mon, 30 Sep'
      String formattedDate = DateFormat("EEE, dd MMM").format(parsedDate);

      return formattedDate;

    } catch (e) {
      // Handle parsing errors or other issues
      print("Error parsing date: $e");
      return "Invalid Date";
    }
  }





}