import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GoogleImagesWidget extends StatefulWidget {
  final String searchQuery;
  final double height;
  final double width;

  const GoogleImagesWidget({
    super.key,
    required this.searchQuery,
    this.height = 300,
    this.width = double.infinity,
  });

  @override
  State<GoogleImagesWidget> createState() => _GoogleImagesWidgetState();
}

class _GoogleImagesWidgetState extends State<GoogleImagesWidget> {
  late WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(_getGoogleImagesUrl()));
  }

  String _getGoogleImagesUrl() {
    // สร้าง URL สำหรับ Google Images search
    final encodedQuery = Uri.encodeComponent(widget.searchQuery);
    return 'https://www.google.com/search?q=$encodedQuery&tbm=isch&tbs=isz:l';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('กำลังโหลดรูปภาพ...'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Widget สำหรับแสดงรูปภาพเดียว (แบบง่าย)
class SimpleGoogleImageWidget extends StatelessWidget {
  final String searchQuery;
  final double height;
  final double width;

  const SimpleGoogleImageWidget({
    super.key,
    required this.searchQuery,
    this.height = 200,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    final encodedQuery = Uri.encodeComponent(searchQuery);
    final imageUrl = 'https://source.unsplash.com/featured/?$encodedQuery';

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey.shade200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text('กำลังโหลดรูปภาพ...'),
                  ],
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade200,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('ไม่สามารถโหลดรูปภาพได้'),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
