import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musiz_player/api/format.dart';
import 'package:musiz_player/utils/banners.dart';

import '../../api/api.dart' as Hive;
import '../../api/api.dart';
import '../../api/ytmusic.dart';
import '../../components/home_section.dart';
import '../../components/recently_played.dart';
import '../../components/recommendations.dart';
import '../../components/skeletons/home_page.dart';
import '../../ui/colors.dart';
import '../../utils/recomendations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen> {
  List songs = [];
  List recommendedSongs = [];
  double tileHeight = 0;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    // Do not call MediaQuery in initState
    // Instead, move it to _loadBannerAd method or build method
    fetchAllData();
  }

  @override
  void dispose() {
    super.dispose();
    GetIt.I<AudioPlayer>().dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipOval(
            child: Image.asset(
              'assets/images/xoxo_icon.png',
              height: 24,
              width: 24,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 24,
                  width: 24,
                  decoration: BoxDecoration(color: darkGreyColor.withAlpha(50)),
                );
              },
            ),
          ),
        ),
        title: Hero(
          tag: "SearchField",
          child: TextField(
            onTap: () => context.go('/search'),
            readOnly: true,
            decoration: InputDecoration(
              fillColor: darkGreyColor.withAlpha(50),
              filled: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 2,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(35),
                borderSide: BorderSide.none,
              ),
              hintText: 'Search Now...',
              prefixIcon: const Icon(Icons.search),
            ),
          ),
        ),
        centerTitle: true,
      ),
      body:
          loading
              ? const HomePageSkeleton()
              : RefreshIndicator(
                onRefresh: () => fetchAllData(),
                child: ListView(
                  children: [
                    Banners(),
                    const SizedBox(height: 8),
                    // Display the banner ad only if it's not null
                    // if (_bannerAd != null)
                    //   SizedBox(
                    //     height: _bannerAd!.size.height.toDouble(),
                    //     child: AdWidget(ad: _bannerAd!),
                    //   ),
                    const SizedBox(height: 8),
                    // Display the banner ad only if it's not null
                    // if (_bannerAd != null)
                    //   SizedBox(
                    //     height: _bannerAd!.size.height.toDouble(),
                    //     child: AdWidget(ad: _bannerAd!),
                    //   ), // This is line 135
                    if (recommendedSongs.isNotEmpty)
                      Recommendations(recommendedSongs: recommendedSongs),
                    const SizedBox(height: 12),
                    const RecentlyPlayed(),
                    const SizedBox(height: 20),
                    ...songs
                        .map((item) => HomeSection(sectionIitem: item))
                        .toList(),
                  ],
                ),
              ),
    );
  }

  fetchAllData() async {
    // setState(() {
    //   loading = true;
    //   recommendedSongs = [];
    //   songs = [];
    // });
    Box homeCache = Hive.box;
    recommendedSongs = await homeCache.get('recommended', defaultValue: []);
    songs = await homeCache.get('songs', defaultValue: []);
    setState(() {
      if (recommendedSongs.isEmpty && songs.isEmpty) {
        loading = true;
      }
    });
    recommendedSongs = await getRecomendations();
    songs = await fetchHomeData();

    await Hive.box.putAll({'recommended': recommendedSongs, 'songs': songs});
    setState(() {
      loading = false;
    });
  }

  @override
  bool get wantKeepAlive => true;
}

Future<List> fetchHomeData() async {
  String provider = Hive.box.get('homescreenProvider', defaultValue: 'saavn');

  List tiles = [];
  if (provider == 'youtube') {
    Map<String, dynamic> a = await YtMusicService().getMusicHome();
    tiles = a['body'];
    // pprint(a['body']);
  } else {
    Map<dynamic, dynamic> data = await SaavnAPI().fetchHomePageData();
    Map<dynamic, dynamic> formatedData = await FormatResponse.formatPromoLists(
      data,
    );
    Map modules = formatedData['modules'];
    modules.forEach((key, value) {
      tiles.add({'title': value['title'], 'items': formatedData[key]});
    });
  }

  return tiles;
}
