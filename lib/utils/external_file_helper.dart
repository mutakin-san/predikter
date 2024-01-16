
import 'dart:io';

void deleteFileFromExternalStorage(String path) async {
  try {
    // Check if the file exists before attempting to delete
    if (await File(path).exists()) {
      // Delete the file
      await File(path).delete();
      

      print('File deleted successfully: $path');
    } else {
      print('File not found: $path');
    }
  } catch (e) {
    print('Error deleting file: $e');
  }
}
