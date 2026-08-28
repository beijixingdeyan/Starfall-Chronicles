// =============================================================
// Starfall Chronicles — 开局欢迎：第一次进入世界
// 通过 persistentData 保证只触发一次：赠送史书 + 文明指引。
// =============================================================

PlayerEvents.loggedIn(event => {
  var p = event.player;
  var uuid = String(p.uuid);
  var pd = p.persistentData;

  if (pd.sc_welcomed) return;
  pd.sc_welcomed = true;

  // 等待世界就绪后给予（登录瞬间某些系统未初始化）
  p.server.scheduleInTicks(20, () => {
    try {
      // 史书（written_book，title/author/pages 均为服务端 NBT）
      var book = Item.of('minecraft:written_book').withNBT({
        title: '文明编年史·序章',
        author: 'Starfall 档案馆',
        resolved: 1,
        pages: [
          '{"text":"§6《文明编年史》\\n§7——第一章·序\\n\\n你在一片麦田里醒来。\\n头顶有四颗星球：\\n绿谷、铁锈、硅火、苍穹。\\n\\n一万年前，上一个文明\\n把种子留在了这里。\\n现在，轮到你。","color":"white"}',
          '{"text":"§6绿谷星\\n§7农耕文明\\n\\n种下庄稼，酿造美酒，\\n养育村落。\\n\\n找到§b上古之种§7后，\\n沿着星门的方向前进。\\n\\n星门钥匙：\\n金·绿宝石·石英·§6文明精粹","color":"white"}',
          '{"text":"§6铁锈星\\n§7工业文明\\n\\n注意头顶的浓烟。\\n污染会反过来吞噬你。\\n\\n用§6上古之种§7酿造\\n§6生物燃料§7，\\n才能点燃下一座星门。","color":"white"}',
          '{"text":"§6硅火星\\n§7信息文明\\n\\n代码即力量。\\n写错代码，工厂会爆炸。\\n\\n用§6精密零件§7锻造\\n§6量子核心§7——\\n那是跃迁引擎的入场券。","color":"white"}',
          '{"text":"§6苍穹星\\n§7星际文明\\n\\n在这里，物理法则\\n可以被改写。\\n\\n终局之战，\\n和你文明的原点。\\n\\n——最原始的，\\n才是最先进的。","color":"white"}'
        ]
      });
      p.give(book);
      // 探索手册（Patchouli 任务书：四星球全流程引导）
      try {
        var handbook = Item.of('patchouli:guide_book', '{patchouli:book:"starciv:handbook"}');
        p.give(handbook);
      } catch (e2) {
        p.tell('§c[Starfall] 探索手册发放失败: ' + e2);
      }
      p.tell('§6【文明编年史】§f你获得了一本《文明编年史》与《探索手册》。');
      p.tell('§7按 §eE§7 打开手册，东方的天空下有一座独石碑在等你。');
    } catch (e) {
      p.tell('§c[Starfall] 史书发放失败: ' + e);
    }
  });
});