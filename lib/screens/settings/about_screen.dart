import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:musiz_player/generated/l10n.dart';
import 'package:musiz_player/ui/colors.dart';
import 'package:musiz_player/ui/text_styles.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).about),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    ClipOval(
                      child: Image.asset(
                        'assets/images/xoxo_icon.png',
                        height: 100,
                        width: 100,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              color: darkGreyColor.withAlpha(50),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(EvaIcons.text),
                  title: Text(
                    S.of(context).name,
                    style: subtitleTextStyle(context),
                  ),
                  trailing: Text(
                    'Xoxo Play',
                    style: smallTextStyle(context),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.new_releases),
                  title: Text(
                    S.of(context).version,
                    style: subtitleTextStyle(context),
                  ),
                  trailing: Text(
                    "3.3.1",
                    style: smallTextStyle(context),
                  ),
                ),
                ListTile(
                  leading: const Icon(EvaIcons.person),
                  title: Text(
                    S.of(context).developer,
                    style: subtitleTextStyle(context),
                  ),
                  trailing: Wrap(
                    alignment: WrapAlignment.center,
                    runAlignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'YG Studio.',
                        style: smallTextStyle(context),
                      ),
                      const Icon(
                        EvaIcons.chevronRight,
                        size: 30,
                      )
                    ],
                  ),
                  onTap: () => launchUrl(
                      Uri.parse(
                          'https://codecanyon.net/user/yellowgems_studio'),
                      mode: LaunchMode.externalApplication),
                ),
                ListTile(
                  leading: const Icon(Iconsax.building),
                  title: Text(
                    S.of(context).organisation,
                    style: subtitleTextStyle(context),
                  ),
                  trailing: Wrap(
                    alignment: WrapAlignment.center,
                    runAlignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Envato Author',
                        style: smallTextStyle(context),
                      ),
                      const Icon(
                        EvaIcons.chevronRight,
                        size: 30,
                      )
                    ],
                  ),
                  onTap: () => launchUrl(
                      Uri.parse(
                          'https://codecanyon.net/user/yellowgems_studio/portfolio'),
                      mode: LaunchMode.externalApplication),
                ),
                ListTile(
                  leading: const Icon(Icons.bug_report),
                  title: Text(
                    S.of(context).bugReport,
                    style: subtitleTextStyle(context),
                  ),
                  trailing: const Icon(
                    EvaIcons.chevronRight,
                    size: 30,
                  ),
                  onTap: () => launchUrl(Uri.parse('YOUR_LINK_URL'),
                      mode: LaunchMode.externalApplication),
                ),
                ListTile(
                  leading: const Icon(Icons.request_page),
                  title: Text(
                    S.of(context).featureRequest,
                    style: subtitleTextStyle(context),
                  ),
                  trailing: const Icon(
                    EvaIcons.chevronRight,
                    size: 30,
                  ),
                  onTap: () => launchUrl(Uri.parse('YOUR_LINK_URL'),
                      mode: LaunchMode.externalApplication),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
