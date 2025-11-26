import 'package:intl/intl.dart';

class DedetimeHelper {
  static String dateTimeConverter(String dateStr) {
    try {
      if (dateStr.isEmpty) return dateStr;
      
      // Parse the datetime string
      DateTime date = DateTime.parse(dateStr);
      
      // Check if the string indicates UTC timezone
      final upperDateStr = dateStr.toUpperCase();
      final isUtc = upperDateStr.endsWith('Z') || 
                    dateStr.contains('+00:00') || 
                    dateStr.endsWith('+00:00');
      
      // If the datetime is in UTC, convert to local time
      // DateTime.parse() with 'Z' creates a UTC DateTime, we need to convert to local
      if (isUtc) {
        // Already UTC, convert to local time
        date = date.toLocal();
      } else {
        // Check if there's timezone info in the string
        final hasTimezone = dateStr.contains('+') || 
                           (dateStr.contains('-') && dateStr.contains('T') && 
                            dateStr.split('T').length > 1 && 
                            dateStr.split('T')[1].contains('-'));
        
        // If no timezone info and it's an ISO format, assume UTC
        if (!hasTimezone && dateStr.contains('T')) {
          // Parse as UTC and convert to local
          if (!upperDateStr.endsWith('Z')) {
            date = DateTime.parse(dateStr + 'Z').toLocal();
          } else {
            date = date.toLocal();
          }
        }
        // If it has timezone info, DateTime.parse() handles it correctly
        // and we just need to ensure it's in local time
        else if (date.isUtc) {
          date = date.toLocal();
        }
      }
      
      // Format in local timezone
      return DateFormat("dd MMM,yy h:mm a").format(date);
    } catch (e) {
      // Fallback: try to parse as UTC and convert
      try {
        final cleanDateStr = dateStr.trim();
        final dateStrWithZ = cleanDateStr.toUpperCase().endsWith('Z') 
            ? cleanDateStr 
            : cleanDateStr + 'Z';
        DateTime date = DateTime.parse(dateStrWithZ);
        return DateFormat("dd MMM,yy h:mm a").format(date.toLocal());
      } catch (e2) {
        return dateStr; // final fallback
      }
    }
  }
}
