import 'package:chest_disease_app/core/utils/extenstions/responsive_design_extenstions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../utils/theme/colors/app_colors.dart';

class CustomProfileImage extends StatefulWidget {
  final bool isOnline;
  final double? size;
  final String? imageUrl;

  const CustomProfileImage(
      {super.key, this.isOnline = false, this.size, this.imageUrl});

  @override
  State<CustomProfileImage> createState() => _CustomProfileImageState();
}

class _CustomProfileImageState extends State<CustomProfileImage> {
  @override
  Widget build(BuildContext context) {
    return _buildImage();
  }

  Widget _buildImage() {
    final isSvg = (widget.imageUrl?.toLowerCase().endsWith('.svg')) ?? false;
    final size = widget.size ?? (isSvg ? 38 : 18.r);
    final finalImageUrl = "${widget.imageUrl}?t=${DateTime.now().millisecondsSinceEpoch}";

    if (isSvg) {
      return CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: size,
        child: SvgPicture.network(
          finalImageUrl,
          width: size * 2,
          height: size * 2,
        ),
      );
    } else {
      return CircleAvatar(
        radius: widget.size ?? 18.r,
        backgroundColor: Colors.transparent,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: finalImageUrl,
            placeholder: (context, url) => _buildePlaceHolder(),
            errorWidget: (context, url, error) => Image.asset(
              'assets/image/appointment_text.png',
              fit: BoxFit.cover,
            ),
            imageBuilder: (context, imageProvider) => Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                  // alignment: Alignment.center,
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildePlaceHolder() {
    return Container(
      width: widget.size ?? 24.w,
      height: widget.size ?? 24.w,
      decoration: const BoxDecoration(
        color: Color(0xFFEEEEEE),
      ),
      child: Center(
        child: SizedBox(
          width: 30.w,
          height: 30.w,
          child: CircularProgressIndicator(
            color: AppColors.buttonsAndNav,
            backgroundColor: AppColors.buttonsAndNav.withAlpha(55),
            strokeCap: StrokeCap.round,
          ),
        ),
      ),
    );
  }
}

