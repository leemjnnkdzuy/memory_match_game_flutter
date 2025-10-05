import 'package:flutter/material.dart';

class SocialLinksWidget extends StatelessWidget {
  final String? githubUrl;
  final String? linkedinUrl;
  final String? websiteUrl;
  final String? youtubeUrl;
  final String? facebookUrl;
  final String? instagramUrl;
  final Function(String, String)? onLinkTap;

  const SocialLinksWidget({
    super.key,
    this.githubUrl,
    this.linkedinUrl,
    this.websiteUrl,
    this.youtubeUrl,
    this.facebookUrl,
    this.instagramUrl,
    this.onLinkTap,
  });

  bool get hasSocialLinks {
    return (githubUrl?.isNotEmpty == true) ||
        (linkedinUrl?.isNotEmpty == true) ||
        (websiteUrl?.isNotEmpty == true) ||
        (youtubeUrl?.isNotEmpty == true) ||
        (facebookUrl?.isNotEmpty == true) ||
        (instagramUrl?.isNotEmpty == true);
  }

  @override
  Widget build(BuildContext context) {
    if (!hasSocialLinks) {
      return SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(0),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            offset: const Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Liên kết mạng xã hội',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          SizedBox(height: 16),
          _buildSocialLinks(),
        ],
      ),
    );
  }

  Widget _buildSocialLinks() {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: [
        if (githubUrl?.isNotEmpty == true)
          _buildSocialLink(Icons.code, 'GitHub', githubUrl!),
        if (linkedinUrl?.isNotEmpty == true)
          _buildSocialLink(Icons.work, 'LinkedIn', linkedinUrl!),
        if (websiteUrl?.isNotEmpty == true)
          _buildSocialLink(Icons.web, 'Website', websiteUrl!),
        if (youtubeUrl?.isNotEmpty == true)
          _buildSocialLink(Icons.video_library, 'YouTube', youtubeUrl!),
        if (facebookUrl?.isNotEmpty == true)
          _buildSocialLink(Icons.facebook, 'Facebook', facebookUrl!),
        if (instagramUrl?.isNotEmpty == true)
          _buildSocialLink(Icons.camera_alt, 'Instagram', instagramUrl!),
      ],
    );
  }

  Widget _buildSocialLink(IconData icon, String label, String url) {
    return InkWell(
      onTap: () {
        onLinkTap?.call(label, url);
      },
      borderRadius: BorderRadius.circular(0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              offset: const Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.black, size: 16),
            SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
