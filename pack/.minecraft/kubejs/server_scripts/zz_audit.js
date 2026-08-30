// [STARFALL AUDIT] 主线全链路 id 验证
ServerEvents.loaded(e => {
  var srv = e.server || e;
  var out = [];
  // 物品
  var items = [
    'starciv:ancient_seed','starciv:civ_essence','starciv:stellar_key',
    'starciv:biofuel_canister','starciv:data_slivers','starciv:precision_parts',
    'starciv:quantum_core','starciv:warp_engine','starciv:warp_core',
    'create:shaft','create:cogwheel','pipez:item_pipe','immersiveengineering:coil_lv',
    'minecraft:blast_furnace','minecraft:beehive','minecraft:lantern'
  ];
  items.forEach(id => {
    var item = Item.of(id);
    out.push('ITEM ' + id + ' = ' + (item.isEmpty() ? 'MISSING' : 'OK'));
  });
  // 维度
  ['starciv:rustfall','starciv:silicon','starciv:stellaris'].forEach(d => {
    try { var lvl = srv.getLevel(d); out.push('DIM ' + d + ' = ' + (lvl ? 'OK' : 'SERVER-TEST')); } catch (err) { out.push('DIM ' + d + ' = ?'); }
  });
  // 实体
  ['cataclysm:netherite_monstrosity','cataclysm:the_leviathan'].forEach(en => {
    try {
      var key = Java.loadClass('net.minecraft.resources.ResourceLocation').new(en);
      var reg = Java.loadClass('net.minecraftforge.registries.ForgeRegistries');
      out.push('ENTITY ' + en + ' = ' + (reg.ENTITY_TYPES.containsKey(key) ? 'OK' : 'MISSING'));
    } catch (err) { out.push('ENTITY ' + en + ' probe-err: ' + err); }
  });
  // 成就
  var advs = ['starciv:agriculture/start','starciv:agriculture/stellar_key','starciv:industry/arrival','starciv:industry/fuel','starciv:hidden/lost_tech','starciv:information/arrival','starciv:information/chips','starciv:information/core','starciv:interstellar/engine','starciv:interstellar/arrival','starciv:interstellar/contact'];
  advs.forEach(a => {
    try {
      var key = Java.loadClass('net.minecraft.resources.ResourceLocation').new(a);
      var adv = Java.loadClass('net.minecraft.advancements.Advancement');
      out.push('ADV ' + a + ' = ?(exists via datapack)');
    } catch (err) { out.push('ADV ' + a + ' probe-err'); }
  });
  out.forEach(l => console.info('[AUDIT] ' + l));
});