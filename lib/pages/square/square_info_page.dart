import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:xy_music_mobile/config/logger_config.dart';
import 'package:xy_music_mobile/config/service_manage.dart';
import 'package:xy_music_mobile/config/theme.dart';
import 'package:xy_music_mobile/model/music_entity.dart';
import 'package:xy_music_mobile/model/song_square_entity.dart';
import 'package:xy_music_mobile/service/player/audio_service_task.dart';
import 'package:xy_music_mobile/util/index.dart';
import 'package:xy_music_mobile/util/stream_util.dart';
import 'package:xy_music_mobile/view_widget/fade_head_sliver_delegate.dart';

/*
 * @Description: 歌单详情歌曲页面
 * @Author: cpyczd
 * @Date: 2021-06-18 4:05 下午
 * @LastEditTime: 2021-06-23 16:08:44
 */
class SquareInfoPage extends StatefulWidget {
  final SongSquareInfo info;

  SquareInfoPage({Key? key, required this.info}) : super(key: key);

  @override
  _SquareInfoPageState createState() => _SquareInfoPageState();
}

class _SquareInfoPageState extends State<SquareInfoPage> with MultDataLine {
  static const _KEY_MUSIC_LIST = "_KEY_MUSIC_LIST";
  List<MusicEntity> _musicList = [];
  int _pageSize = 9999;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadPage();
  }

  void _loadPage() {
    _pageIndex++;
    squareServiceProviderMange
        .getSupportProvider(widget.info.source)
        .first
        .getSongMusicList(widget.info, size: _pageSize, current: _pageIndex)
        .then((value) {
      if (value.isNotEmpty) {
        _musicList.addAll(value);
        getLine<List<MusicEntity>>(_KEY_MUSIC_LIST)
            .setData(_musicList, filterIdentical: false);
      }
    }).catchError((e) {
      log.e("没有数据或者异常信息:", e);
      ToastUtil.show(msg: e);
    });
  }

  @override
  void dispose() {
    disposeDataLine();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Color(AppTheme.getCurrentTheme().scaffoldBackgroundColor),
      body: Container(
        child: CustomScrollView(
          physics:
              BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [_topCovert(), _infoList()],
        ),
      ),
    );
  }

  Widget _topCovert() {
    Color textColor = Colors.white;
    var ordinaryStyle = TextStyle(fontSize: 14, color: Colors.white);
    return SliverPersistentHeader(
      pinned: true,
      delegate: SliverFadeDelegate(
          contentHeight: 150,
          barHeight: 50,
          spacing: 1,
          title: "歌单音乐",
          toTopReplaceTitle: widget.info.name,
          barColor: textColor,
          content: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            height: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CachedNetworkImage(
                        imageUrl: widget.info.img,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Positioned(
                        bottom: 5,
                        right: 5,
                        child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 4, vertical: 4),
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(.7),
                                borderRadius: BorderRadius.circular(20)),
                            child: RichText(
                                text: TextSpan(
                                    style: TextStyle(fontSize: 10),
                                    children: [
                                  WidgetSpan(
                                      child: Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: 10,
                                  )),
                                  TextSpan(text: " " + widget.info.playCount)
                                ]))))
                  ],
                ),
                SizedBox.fromSize(size: Size.fromWidth(15)),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.info.name,
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      "作者: ${widget.info.author}",
                      style: ordinaryStyle,
                    ),
                    widget.info.desc != null && widget.info.desc!.isNotEmpty
                        ? Expanded(
                            child: SingleChildScrollView(
                            child: Text(
                              widget.info.desc ?? "",
                              // overflow: TextOverflow.ellipsis,
                              style: ordinaryStyle,
                            ),
                          ))
                        : SizedBox.expand()
                  ],
                ))
              ],
            ),
          ),
          insertTopWidget: [
            SliverFadeDelegate.vague(widget.info.img, sigmaX: 60, sigmaY: 60)
          ],
          paddingTop: MediaQuery.of(context).padding.top),
    );
  }

  Widget _infoList() {
    return SliverStickyHeader(
      overlapsContent: false,
      header: Container(
        height: 60.0,
        color: Color(AppTheme.getCurrentTheme().scaffoldBackgroundColor),
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
                onPressed: _playAll,
                icon: Icon(Icons.play_arrow),
                label: Text("播放全部"))
          ],
        ),
      ),
      sliver: getLine<List<MusicEntity>>(_KEY_MUSIC_LIST,
          waitWidget: SliverToBoxAdapter(
            child: Container(
              height: MediaQuery.of(context).size.height / 2,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          )).addObserver((context, pack) => SliverList(
              delegate: SliverChildBuilderDelegate((content, index) {
            var music = pack.data![index];
            return ListTile(
              onTap: () => _handlePaly(music),
              dense: true,
              title: Text(music.songName),
              subtitle: Text(music.singer ?? ""),
              leading: Text(
                "${index + 1}",
                style: TextStyle(fontSize: 15, color: Colors.black),
              ),
              trailing:
                  IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
            );
          }, childCount: pack.data!.length))),
    );
  }

  ///播放音乐
  void _handlePaly(MusicEntity music) async {
    ToastUtil.show(msg: "开始播放${music.songName}");
    await PlayerTaskHelper.pushQueue(music);
    await PlayerTaskHelper.playByMd5(music.md5);
  }

  ///播放全部
  void _playAll() async {
    if (_musicList.isNotEmpty) {
      PlayerTaskHelper.appendList(_musicList).then((arr) {
        ToastUtil.show(msg: "已添加到试听列表开始播放");
        //播放第一个
        if (arr.isNotEmpty) {
          var first = arr.first;
          AudioService.playFromMediaId(first.uuid!);
        }
      });
    }
  }
}
