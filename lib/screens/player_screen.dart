import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_lyric/lyric_ui/ui_netease.dart';
import 'package:flutter_lyric/lyrics_model_builder.dart';
import 'package:flutter_lyric/lyrics_reader_model.dart';
import 'package:flutter_lyric/lyrics_reader_widget.dart';
import 'package:iconsax/iconsax.dart';
import 'package:musiz_player/api/image_resolution_modifier.dart';
import 'package:musiz_player/generated/l10n.dart';
import 'package:musiz_player/providers/media_manager.dart';
import 'package:musiz_player/ui/text_styles.dart';
import 'package:musiz_player/utils/enums.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class PlayerScreen extends StatefulWidget {
  final double? width;
  const PlayerScreen({super.key, this.width});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final PanelController controller = PanelController();
  FlipCardController flipCardController = FlipCardController();
  PanelController panelController = PanelController();
  final boundaryKey = GlobalKey();
  double progress = 0;
  Uri? arturi;
  Color? color;
  late List<Map<String, dynamic>> menuItems;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    menuItems = [
      {'index': 0, 'value': S.of(context).equalizer},
    ];
    MediaManager mediaManager = context.watch<MediaManager>();
    MediaItem? song = mediaManager.currentSong;
    if (arturi != song?.artUri) {
      arturi = song?.artUri;
      if (song?.extras?['palette'] == null && arturi != null) {
        PaletteGenerator.fromImageProvider(
          CachedNetworkImageProvider(arturi.toString()),
        ).then((value) {
          song?.extras?['palette'] = value;
          setState(() {});
        });
      }
    }
    PaletteGenerator? palette = song?.extras?['palette'];
    color =
        (context.isDarkMode
            ? palette?.darkVibrantColor?.color
            : palette?.lightVibrantColor?.color) ??
        Theme.of(context).colorScheme.primary;
    // ignore: deprecated_member_use

    return WillPopScope(
      onWillPop: () async {
        if (panelController.isPanelOpen) {
          panelController.close();
          return false;
        }
        return true;
      },
      child: Theme(
        data: Theme.of(
          context,
        ).copyWith(colorScheme: ColorScheme.fromSeed(seedColor: color!)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color!, color!.withAlpha(150), color!.withAlpha(20)],
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              leading:
                  Navigator.canPop(context)
                      ? IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(EvaIcons.chevronDownOutline),
                      )
                      : null,
              title: Text("Xoxo Play", style: textStyle(context, bold: false)),
              centerTitle: true,
              actions:
                  song != null
                      ? [
                        IconButton(
                          onPressed: () {
                            flipCardController.toggleCard();
                          },
                          icon: const Icon(Icons.lyrics_rounded),
                        ),
                        PopupMenuButton(
                          onSelected: menuSelected,
                          icon: const Icon(Icons.more_vert),
                          itemBuilder: (BuildContext context) {
                            return menuItems
                                .map(
                                  (item) => PopupMenuItem(
                                    value: item,
                                    child: Text(item['value']),
                                  ),
                                )
                                .toList();
                          },
                        ),
                      ]
                      : null,
            ),
            body: Padding(
              padding: const EdgeInsets.all(0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > constraints.maxHeight) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ArtWork(
                          controller: flipCardController,
                          width: min(
                            constraints.maxHeight / 0.9,
                            constraints.maxWidth / 1.8,
                          ),
                          song: song,
                        ),
                        NameAndControls(
                          song: song,
                          width: constraints.maxWidth / 2,
                          height: constraints.maxHeight,
                          panelController: panelController,
                        ),
                      ],
                    );
                  }
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ArtWork(
                        controller: flipCardController,
                        width: constraints.maxWidth,
                        song: song,
                      ),
                      NameAndControls(
                        song: song,
                        width: constraints.maxWidth,
                        height:
                            constraints.maxHeight -
                            (constraints.maxWidth * 0.88) -
                            16,
                        panelController: panelController,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  menuSelected(Map item) {
    switch (item['index']) {
      case 0:
        showModalBottomSheet(
          context: context,
          builder: (_) => const EqualizerScreen(),
        );
        break;
      default:
        Navigator.pop(context);
        break;
    }
  }
}

class Artwork extends StatefulWidget {
  final FlipCardController controller;
  final MediaItem? song;
  final double width;

  const Artwork({
    super.key,
    required this.controller,
    this.song,
    required this.width,
  });

  @override
  State<Artwork> createState() => _ArtworkState();
}

class _ArtworkState extends State<Artwork> {
  bool fetchedLyrics = false;
  bool flipped = false;

  Map lyrMap = {};

  LyricsReaderModel? lyricsModel;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = widget.width * 0.85;

    if (widget.song != null && flipped && lyrMap['id'] != widget.song?.id) {
      fetchLyrics();
    }
    return SafeArea(
      child: SizedBox(
        height: width,
        width: width,
        child:
            widget.song == null
                ? Icon(Iconsax.music, size: width * 0.5)
                : FlipCard(
                  flipOnTouch: false,
                  controller: widget.controller,
                  onFlipDone: (value) {
                    flipped = value;
                    setState(() {});
                    if (value && lyrMap['id'] != widget.song?.id) {
                      fetchLyrics();
                    }
                  },
                  front: GestureDetector(
                    onHorizontalDragEnd: (DragEndDetails details) {
                      if ((details.primaryVelocity ?? 0) > 100) {
                        context.read<MediaManager>().previous();
                      }

                      if ((details.primaryVelocity ?? 0) < -100) {
                        context.read<MediaManager>().next();
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Hero(
                          tag: "playerPoster",
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child:
                                widget.song?.extras?['offline'] == true &&
                                        !widget.song!.artUri
                                            .toString()
                                            .startsWith('https')
                                    ? Image.file(
                                      File.fromUri(widget.song!.artUri!),
                                      width: width,
                                      fit: BoxFit.contain,
                                    )
                                    : CachedNetworkImage(
                                      imageUrl: getImageUrl(
                                        widget.song?.artUri.toString(),
                                      ),
                                      width: width,
                                      fit: BoxFit.contain,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  back: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      children: [
                        widget.song?.extras?['offline'] == true &&
                                !widget.song!.artUri.toString().startsWith(
                                  'https',
                                )
                            ? Image.file(
                              File.fromUri(widget.song!.artUri!),
                              width: width,
                              height: width,
                              fit: BoxFit.fill,
                            )
                            : CachedNetworkImage(
                              imageUrl: getImageUrl(
                                widget.song?.artUri.toString(),
                              ),
                              width: width,
                              height: width,
                              fit: BoxFit.fill,
                            ),
                        BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: ShaderMask(
                            shaderCallback:
                                (bounds) => const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black,
                                    Colors.black,
                                    Colors.black,
                                    Colors.transparent,
                                  ],
                                ).createShader(
                                  Rect.fromLTRB(
                                    0,
                                    0,
                                    bounds.width,
                                    bounds.height,
                                  ),
                                ),
                            blendMode: BlendMode.dstIn,
                            child: Container(
                              color: Colors.black.withOpacity(0.6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                              width: width,
                              height: width,
                              child:
                                  fetchedLyrics
                                      ? lyricsModel == null
                                          ? SingleChildScrollView(
                                            child: Text(
                                              '\n${lyrMap['lyrics']}\n',
                                              textAlign: TextAlign.center,
                                              style: subtitleTextStyle(
                                                context,
                                                bold: false,
                                              ).copyWith(color: Colors.white),
                                            ),
                                          )
                                          : StreamBuilder(
                                            stream: AudioService.position,
                                            builder: (context, snapshot) {
                                              return LyricsReader(
                                                position:
                                                    snapshot
                                                        .data
                                                        ?.inMilliseconds ??
                                                    0,
                                                model: lyricsModel,
                                                playing: true,
                                                lyricUi: UINetease(
                                                  highlight: false,
                                                  defaultSize: 19,
                                                ),
                                                size: Size(width, width),
                                              );
                                            },
                                          )
                                      : SizedBox(
                                        width: width,
                                        height: width,
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  fetchLyrics() {
    MediaItem song = widget.song!;
    setState(() {
      fetchedLyrics = false;
    });
    context
        .read<MediaManager>()
        .lyrics
        .getLyrics(
          id: song.id,
          title: song.title,
          artist: song.artist ?? "",
          saavnHas:
              song.extras?['offline'] == null
                  ? false
                  : bool.parse(song.extras?['offline'].toString() ?? 'false')
                  ? false
                  : bool.parse(song.extras?['has_lyrics'] ?? false),
        )
        .then((value) {
          lyrMap = value;
          lyricsModel =
              LyricsModelBuilder.create()
                  .bindLyricToMain(lyrMap['lyrics'])
                  .getModel();

          if (mounted) {
            setState(() {
              fetchedLyrics = true;
            });
          }
        });
  }
}
