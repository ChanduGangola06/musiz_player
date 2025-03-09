import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

// ignore: non_constant_identifier_names
Padding Banners() {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: SizedBox(
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: CarouselSlider(
          items: [
            _buildImage(
              'https://firebasestorage.googleapis.com/v0/b/chatme-4ceae.appspot.com/o/afro-girl-enjoying-music-wearing-sunglasses-and-headphone-banner-vector.jpg?alt=media&token=94b7a0cc-04bb-42be-bdfa-c4c9035de2ca',
            ),
            _buildImage(
              'https://firebasestorage.googleapis.com/v0/b/chatme-4ceae.appspot.com/o/preview-page0.jpg?alt=media&token=a230c66e-a07e-4bbe-916a-45eba77ea8c7',
            ),
            _buildImage(
              'https://firebasestorage.googleapis.com/v0/b/chatme-4ceae.appspot.com/o/music-show-studio-live-premiere-youtube-template-banner_921690-29.avif?alt=media&token=0a3385c4-dacd-424e-9580-b11647022e6a',
            ),
          ],
          options: CarouselOptions(
            height: 150.0,
            aspectRatio: 16 / 9,
            viewportFraction: 1.0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            pauseAutoPlayOnTouch: true,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              // Handle page change if needed
            },
          ),
        ),
      ),
    ),
  );
}

Widget _buildImage(String imageUrl) {
  return Image.network(
    imageUrl,
    fit: BoxFit.cover,
    width: double.infinity,
    loadingBuilder: (
      BuildContext context,
      Widget child,
      ImageChunkEvent? loadingProgress,
    ) {
      if (loadingProgress == null) {
        return child;
      } else {
        return Center(
          child: CircularProgressIndicator(
            value:
                loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        (loadingProgress.expectedTotalBytes ?? 1)
                    : null,
          ),
        );
      }
    },
  );
}
