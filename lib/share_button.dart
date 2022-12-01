library share_button;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

enum ShareType {auto, system, custom}

class ShareMedia {
  final String name;
  final IconData iconData;
  final String link;
  final Color color;

  const ShareMedia({
    required this.name,
    required this.iconData,
    required this.link,
    this.color = Colors.black87,
  });

  void share({
    String text = '',
    String url = '',
    void Function()? onShare,
  }) {
    this == ShareMedia.clipboard
        ? Clipboard.setData(ClipboardData(text: '$text\n$url'))
        : launchUrl(Uri.parse(link
        .replaceAll('%text%', text)
        .replaceAll('%url%', url)
    )
    );
    onShare?.call();
  }

  static const ShareMedia whatsapp = ShareMedia(
    name: 'whatsapp',
    iconData: FontAwesomeIcons.whatsapp,
    link: 'https://wa.me/?text=%text%%0A%url%',
    color: Colors.green,
  );

  static const ShareMedia twitter = ShareMedia(
    name: 'twitter',
    iconData: FontAwesomeIcons.twitter,
    link: 'https://twitter.com/intent/tweet?url=%url%&text=%text%',
    color: Colors.blue,
  );

  static const ShareMedia facebook = ShareMedia(
    name: 'facebook',
    iconData: FontAwesomeIcons.facebookF,
    link: 'https://www.facebook.com/sharer/sharer.php?u=%url%',
    color: Colors.indigo,
  );

  static const ShareMedia email = ShareMedia(
      name: 'email',
      iconData: Icons.mail_rounded,
      link: 'mailto:?to=&body=%text%%0A%url%',
      color: Colors.red
  );

  static const ShareMedia clipboard = ShareMedia(
      name: 'clipboard',
      iconData: Icons.copy_rounded,
      link: '',
      color: Colors.black87
  );

  static const List<ShareMedia> list = [
    ShareMedia.whatsapp,
    ShareMedia.twitter,
    ShareMedia.facebook,
    ShareMedia.email,
    ShareMedia.clipboard,
  ];
}


Future<void> share({
  required BuildContext context,
  required String text,
  required String url,
  ShareType type = ShareType.auto,
  String dialogTitle = 'Share',
  List<ShareMedia> shareMedias = ShareMedia.list,
  void Function(ShareMedia)? onShare,
}) async {
  if (type == ShareType.system ||
      type == ShareType.auto && [TargetPlatform.iOS, TargetPlatform.macOS].contains(defaultTargetPlatform)) {
    Share.share('$text\n$url');
  } else {
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(dialogTitle),
          content: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 256),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.black12)
            ),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(shareMedias.length*2 -1, (i) {
                  if (i % 2 == 0) {
                    final ShareMedia sm = shareMedias[i~/2];
                    return InkWell(
                      onTap: () => sm.share(
                          text: text,
                          url: url,
                          onShare: () {
                            Navigator.pop(context);
                            onShare?.call(sm);
                          }),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 24,
                          ),
                          Icon(sm.iconData, size: 20),
                          const SizedBox(
                            width: 16,
                            height: 48,
                          ),
                          Text('${sm.name[0].toUpperCase()}${sm.name.substring(1)}')
                        ],
                      ),
                    );
                  } else {
                    return const Divider(thickness: 1, height: 1,);
                  }
                }
                )
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600),),
            )
          ],
        )
    );
  }
}

class ShareButton extends StatelessWidget {
  final Icon icon;
  final Widget? child;
  final String text;
  final String url;
  final String tooltip;
  final ShareType shareType;
  final List<ShareMedia> shareMedias;
  final void Function(ShareMedia)? onShare;
  final void Function(List<ShareMedia>)? customShare;

  const ShareButton({
    this.icon = const Icon(Icons.share_rounded),
    this.child,
    this.text = '',
    this.url = '',
    this.tooltip = 'Share',
    this.shareType = ShareType.auto,
    this.shareMedias = ShareMedia.list,
    this.onShare,
    this.customShare,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.share_rounded),
      onPressed: customShare != null
          ? () => customShare!(shareMedias)
          : () => share(
          context: context,
          text: text,
          url: url,
          type: shareType,
          shareMedias: shareMedias,
          dialogTitle: tooltip,
          onShare: onShare
      ),
      tooltip: tooltip,
    );
  }
}
