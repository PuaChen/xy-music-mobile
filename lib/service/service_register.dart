/*
 * @Description: 服务注册发现
 * @Author: chenzedeng
 * @Date: 2021-06-14 13:00:03
 * @LastEditTime: 2021-07-24 11:51:36
 */
import 'package:xy_music_mobile/config/service_manage.dart';
import 'package:xy_music_mobile/service/music/kg_music_service.dart';
import 'package:xy_music_mobile/service/music/kw_msuic_service.dart';
import 'package:xy_music_mobile/service/ranking/kg_ranking_service.dart';
import 'package:xy_music_mobile/service/ranking/wy_ranking_service.dart';
import 'package:xy_music_mobile/service/square/kg_square_service.dart';
import 'package:xy_music_mobile/service/square/wy_square_service.dart';
import 'package:xy_music_mobile/service/music/tx_music_service.dart';
import 'package:xy_music_mobile/service/music/wy_music_service.dart';

import 'music/mg_music_servce.dart';

///音乐服务
void _registerMusicService() {
  ///酷我音乐
  musicServiceProviderMange.register(KwMusicServiceImpl());

  ///注册酷狗服务
  musicServiceProviderMange.register(KGMusicServiceImpl());

  ///咪咕服务
  musicServiceProviderMange.register(MgMusicServiceImpl());

  ///QQ音乐服务
  musicServiceProviderMange.register(TxMusicServiceImpl());

  ///网易音乐
  musicServiceProviderMange.register(WyMusicServiceImpl());
}

///歌单服务
void _registerSquareService() {
  ///酷狗歌单服务注册
  squareServiceProviderMange.register(KgSquareServiceImpl());
  //网易歌单
  squareServiceProviderMange.register(WySquareServiceImpl());
}

///排行榜服务
void _registerRankingService() {
  ///酷狗排行榜服务注册
  songRankingServiceProviderMange.register(KgRankingListServiceImpl());
  //网易排行榜
  songRankingServiceProviderMange.register(WyRankingListServiceImpl());
}

///注册服务方法、调用交给Application类去管理
void register() {
  _registerMusicService();
  _registerSquareService();
  _registerRankingService();
}
