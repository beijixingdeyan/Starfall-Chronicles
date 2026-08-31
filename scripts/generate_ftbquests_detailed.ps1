# Starfall Chronicles 详细任务书生成器（手工 + 自动混合）
# 输入基础：现有 112 任务的元数据
# 输出：增强版 FTB Quests snbt，包含详细坐标、背景、分支指引

$ErrorActionPreference = 'Stop'

# ---- 任务详细信息库（主线 11 个 + 星球各 12-14 个 = 112 总）----
# 这是一个"任务内容数据库"，定义每个任务的详细信息
$taskDetails = @{
  # 主线（11 个）
  'starciv_main_01' = @{
    title = '【开局】史书与手册 → 出发'
    subtitle = '收集初始物品'
    description = "你在一片麦田里醒来。头顶是四颗不同的星球。这不是巧合——一万年前，上一个文明把种子留在了这里。现在，轮到你沿着星门，把文明重新点亮。`n`n【关键说明】`nK = 任务书（树状图指引）| Q = 图鉴 | J = 配方 | E = 背包`n`n【下一步】找到独石碑（东北方向，约 26, ?, -126）"
    coords = @{ x = 26; y = 64; z = -126; tip = '出生点东北方向' }
    rewards = @('minecraft:written_book', 'starciv:guide_book')
  }
  'starciv_main_02' = @{
    title = '【农耕】独石碑 → 获得上古之种'
    subtitle = '触发文明回忆'
    description = "从出生点出发，朝东北方向走。你会看到一根闪烁着紫色光芒的巨大独石碑。`n`n靠近它（距离 26 格内），它会向你倾诉：这是文明的种子。它记得每一个时代。`n`n【奖励】自动获得 2 粒【上古之种】。"
    coords = @{ x = 26; y = 65; z = -126; tip = '紫色发光独石碑' }
    rewards = @('starciv:ancient_seed')
  }
  'starciv_main_03' = @{
    title = '【农耕】种植上古之种'
    subtitle = '等待收获'
    description = "找耕地，手持【上古之种】，右键耕地 → 放置【上古作物】。`n`n【生长时间】5-15 分钟（雨天快）。成熟后右键收获 → 掉落【上古之种】×1 + 【文明精粹】×1。`n`n【下一步】准备三种材料（金锭、绿宝石、石英），制造星门钥匙。"
    coords = @{ x = null; y = null; z = null; tip = '任意耕地' }
    rewards = @('starciv:civ_essence')
  }
  'starciv_main_04' = @{
    title = '【交易】合成星门钥匙'
    subtitle = '打开星门的钥匙'
    description = "在工作台合成【星门钥匙】。`n`n【配方】需要：金锭 ×3、绿宝石 ×1、石英 ×1、文明精粹 ×1`n`n【来源】金锭=烧金矿|绿宝石=采集或交易|石英=下界|精粹=上古作物收获"
    coords = @{ x = null; y = null; z = null; tip = '工作台' }
    rewards = @('starciv:stellar_key')
  }
  'starciv_main_05' = @{
    title = '【交通】跃迁铁锈星'
    subtitle = '第一次维度穿梭'
    description = "去绿谷星门（南方，黑曜石框架）。手持【星门钥匙】，右键紫色核心 → 传送到铁锈星。`n`n【铁锈星三线】炼钢 | 机械 | 管道（接下来的任务会逐个指引）"
    coords = @{ x = 0; y = 65; z = -100; tip = '绿谷星门（黑曜石框架）' }
    rewards = @()
  }
  # ... 继续 ⑥-⑪
}

Write-Host "✓ 任务详细信息库已加载 (示例: 5 个主线任务)"
Write-Host "📝 完整版需要扩展到 112 个任务"
Write-Host "💾 下一步：逐批生成 snbt 文件"
