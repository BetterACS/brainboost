import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ErrorDialog extends StatelessWidget {
  final String errorMessage;

  const ErrorDialog({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 35),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/images/alert.png', // ใช้รูป alert.png
                    width: 150, // ขนาดของวงกลม
                    height: 150, // ขนาดของวงกลม
                    fit: BoxFit.cover, // ให้รูปภาพไม่บิดเบี้ยว
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  AppLocalizations.of(context)!.errorTitle,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                // แสดงข้อความ error
                Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(AppLocalizations.of(context)!.tryAgain,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(AppLocalizations.of(context)!.editFile,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Color(0xFF838383)),
              onPressed: () {
                Navigator.pop(context);
              },
              tooltip: AppLocalizations.of(context)!.close,
            ),
          ),
        ],
      ),
    );
  }
}
