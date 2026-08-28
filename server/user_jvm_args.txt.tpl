# Starfall Chronicles 服务端 JVM 参数（按需修改内存档位）
# 6G 档（推荐，8GB 内存机器，可同时跑客户端+服务端）
-Xmx6G -Xms2G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1MixedGCCountTarget=4 -XX:SurvivorRatio=32 -XX:+AlwaysPreTouch