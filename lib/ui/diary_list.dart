import 'package:flutter/material.dart';
import 'package:random_note/main.dart';
import 'package:random_note/models/diary.dart';
import 'package:random_note/ui/diary_detail_page.dart';
import 'package:random_note/ui/diary_edit_page.dart';
import 'package:random_note/widgets/Loading.dart';
import 'package:unicons/unicons.dart';

void main() {
  runApp(const MaterialApp(
    home: DiaryList(),
  ));
}

class DiaryList extends StatefulWidget {
  const DiaryList({super.key});

  @override
  _DiaryListState createState() => _DiaryListState();
}

class _DiaryListState extends State<DiaryList> {
  @override
  void initState() {
    super.initState();
  }

  void toAddDiaryPage() {
    // 跳转到新增页面
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DiaryEditPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: SafeArea(
            child: Scaffold(
                backgroundColor: Colors.grey[200], // 设置背景为灰色
                appBar: AppBar(
                  toolbarHeight: 40,
                  backgroundColor: Colors.transparent,
                  elevation: 0, // 去掉阴影效果
                  title: const Text(
                    '二零二四年 三月',
                    style: TextStyle(fontSize: 14.0),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        toAddDiaryPage();
                      },
                    ),
                  ],
                ),
                body: StreamBuilder(
                  stream: diaryService.diaryStream,
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<List<Diary>> snapshot,
                  ) {
                    if (snapshot.hasError) {
                      return Center(
                          child: Text('Steam error: ${snapshot.error}'));
                    }
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        return const Center(
                            child: Icon(UniconsLine.data_sharing));
                      case ConnectionState.waiting:
                        return const Loading();
                      case ConnectionState.active:
                        return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              margin: const EdgeInsets.only(
                                  bottom: 8.0,
                                  left: 10.0,
                                  right: 10.0), // 设置底部间距
                              color: Colors.white, // 设置日记项的背景为白色
                              child:
                                  DiaryListItem(diary: snapshot.data![index]),
                            );
                          },
                        );
                      case ConnectionState.done:
                        return const Center(child: Text('Stream closed'));
                    }
                  },
                ))));
  }
}

class DiaryListItem extends StatelessWidget {
  final Diary diary;

  DiaryListItem({required this.diary});

  Future<bool> confirmDismiss(String text) async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
        key: Key(diary.id.toString()), // 唯一标识，通常是数据的唯一标识
        background: Container(
          color: Colors.red, // 滑动时显示的背景颜色
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: const Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
        confirmDismiss: (direction) => confirmDismiss(diary.id.toString()),
        onDismissed: (_) => {print(_)},
        movementDuration: const Duration(milliseconds: 400),
        child: Material(
            color: Colors.transparent,
            child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiaryDetailPage(diary: diary),
                    ),
                  );
                },
                child: Ink(
                    color: Colors.white,
                    child: Container(
                      padding:
                          EdgeInsets.only(top: 12.0, right: 20.0, bottom: 13.0),
                      child: Row(
                        children: [
                          // 左边布局
                          Container(
                            margin: EdgeInsets.only(right: 15.0),
                            decoration: BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        color: Colors.grey.shade200,
                                        width: 1))),
                            width: 55.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '${diary.date.day}'.padLeft(2, '0'),
                                  style: const TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '周${_getWeekday(diary.date.weekday)}',
                                  style: const TextStyle(fontSize: 10.0, height: 1.5),
                                ),
                                Text(
                                  '${'${diary.date.hour}'.padLeft(2, '0')}:${'${diary.date.minute}'.padLeft(2, '0')}',
                                  style: const TextStyle(fontSize: 8.0),
                                ),
                              ],
                            ),
                          ),
                          // 右边布局
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  // _truncateContent(diary.plainText),
                                  diary.plainText,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )))));
  }

  String _getWeekday(int weekday) {
    switch (weekday) {
      case 1:
        return '一';
      case 2:
        return '二';
      case 3:
        return '三';
      case 4:
        return '四';
      case 5:
        return '五';
      case 6:
        return '六';
      case 7:
        return '日';
      default:
        return '';
    }
  }
}
