// =============================================================
// Starfall Chronicles — 探索手册配方
// 书 + 羽毛 = 可重复合成的 Patchouli 手册（遗失补办，不锁阶段）。
// 输出用 Item.of 对象（NBT 由 KubeJS 原生构造，不经 SNBT 字符串解析，
// 比数据包 `nbt` 字段更稳：前者在部分 1.20.1 Forge 构建会 SNBT 报错）。
// =============================================================

ServerEvents.recipes(event => {
  const { shapeless } = event;
  shapeless(
    Item.of('patchouli:guide_book', '{patchouli:book:"starciv_data:handbook"}'),
    ['minecraft:book', 'minecraft:feather']
  );
});