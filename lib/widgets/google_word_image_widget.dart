import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/word_item.dart';
import '../services/word_service.dart';

class GoogleWordImageWidget extends StatefulWidget {
  final WordItem wordItem;
  final double? width;
  final double? height;
  final bool showDescription;

  const GoogleWordImageWidget({
    super.key,
    required this.wordItem,
    this.width,
    this.height,
    this.showDescription = true,
  });

  @override
  State<GoogleWordImageWidget> createState() => _GoogleWordImageWidgetState();
}

class _GoogleWordImageWidgetState extends State<GoogleWordImageWidget> {
  String? _imageUrl;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final imageUrl = await WordService.getImageUrl(widget.wordItem.word);

      if (mounted) {
        setState(() {
          _imageUrl = imageUrl;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // รูปภาพ
            Expanded(child: _buildImageSection()),
            // คำอธิบาย (ถ้าแสดง)
            if (widget.showDescription && widget.wordItem.description != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.wordItem.word,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.wordItem.description!,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF7F8C8D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3498DB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.wordItem.category,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF3498DB),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    if (_isLoading) {
      return Container(
        color: const Color(0xFFF8F9FA),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
              ),
              SizedBox(height: 12),
              Text(
                'กำลังโหลดรูปภาพ...',
                style: TextStyle(color: Color(0xFF7F8C8D), fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    if (_hasError) {
      return Container(
        color: const Color(0xFFF8F9FA),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: const Color(0xFFE74C3C),
              ),
              const SizedBox(height: 12),
              Text(
                'ไม่สามารถโหลดรูปภาพได้',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: const Color(0xFF7F8C8D),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  _loadImage();
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('ลองใหม่'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3498DB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _buildSimpleImageSection();
  }

  Widget _buildSimpleImageSection() {
    if (_imageUrl == null) {
      return Container(
        color: const Color(0xFFF8F9FA),
        child: const Center(
          child: Icon(
            Icons.image_not_supported,
            size: 48,
            color: Color(0xFF7F8C8D),
          ),
        ),
      );
    }

    return Image.network(
      _imageUrl!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: const Color(0xFFF8F9FA),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF3498DB),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'กำลังโหลดรูปภาพ...',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xFFF8F9FA),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: const Color(0xFFE74C3C),
                ),
                const SizedBox(height: 12),
                Text(
                  'ไม่สามารถโหลดรูปภาพได้',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: const Color(0xFF7F8C8D),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      // Trigger rebuild to reload image
                    });
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('ลองใหม่'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3498DB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
