<!---
markmeta_author: titlwind
markmeta_date: 2023-09-16
markmeta_title: AI提示词 —— 代码生成（redis task queue）
markmeta_categories: ai
markmeta_tags: ai,prompt-engineering
-->
# AI提示词 —— 代码生成（redis task queue）


## 代码生成(询问AI)

我需要使用 redis zset 来模拟任务队列， zset 的key为任务 id，value 为任务待处理时间戳。请根据以下需求，生成使用 spring redistTemplate 操作 redis的 java 代码：
1. 生成添加任务 id 的方法，value 默认为当前时间戳加上60000毫秒；
2. 生成删除任务 id 的方法；
3. 生成获取任务 id 的方法。每次请求的时候获得 value 最小且 value 小于当前时间的第一个任务 id，并同时更新 value 值为当前时间戳加60000毫秒。以上获取任务 id 和更新动作需是原子操作，所以最好放在一个RedisScript中执行。 如果不存在这样的任务 id 则返回空。 


## 代码生成(AI回答)


你可以使用Spring的RedisTemplate来操作Redis，实现上述需求。以下是针对每个需求的Java代码：

生成添加任务 id 的方法，value 默认为当前时间戳加上 60000 毫秒：
```java
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;
import java.util.concurrent.TimeUnit;

@Service
public class TaskQueueService {
    private final RedisTemplate<String, String> redisTemplate;
    private static final String ZSET_KEY = "task_queue";

    public TaskQueueService(RedisTemplate<String, String> redisTemplate) {
        this.redisTemplate = redisTemplate;
    }

    public void addTask(String taskId) {
        long currentTimeMillis = System.currentTimeMillis();
        long delayedTimeMillis = currentTimeMillis + 60000; // 默认延迟 60000 毫秒
        redisTemplate.opsForZSet().add(ZSET_KEY, taskId, delayedTimeMillis);
    }
}

```

生成删除任务 id 的方法：

```java
public void removeTask(String taskId) {
    redisTemplate.opsForZSet().remove(ZSET_KEY, taskId);
}
```

生成获取任务 id 的方法，每次请求获得 value 最小且 value 小于当前时间的第一个任务 id，并同时更新 value 值为当前时间戳加 60000 毫秒。这需要使用 Lua 脚本来实现原子操作：

```java
public String getAndRenewTask() {
    String luaScript = "local task = redis.call('ZRANGEBYSCORE', KEYS[1], '-inf', ARGV[1], 'LIMIT', 0, 1)\n" +
            "if #task > 0 then\n" +
            "    local taskId = task[1]\n" +
            "    redis.call('ZREM', KEYS[1], taskId)\n" +
            "    local newTime = ARGV[1] + " + 60000 + "\n" +
            "    redis.call('ZADD', KEYS[1], newTime, taskId)\n" +
            "    return taskId\n" +
            "else\n" +
            "    return nil\n" +
            "end";
    
    List<String> keys = Collections.singletonList(ZSET_KEY);
    long currentTimeMillis = System.currentTimeMillis();
    Object taskId = redisTemplate.execute(new DefaultRedisScript<>(luaScript, String.class), keys, currentTimeMillis);
    
    return taskId != null ? taskId.toString() : null;
}
```

上述代码中，我们使用 Lua 脚本进行了原子操作，首先获取并移除符合条件的任务 id，然后重新添加一个新的带有更新后的时间戳的任务 id。这确保了获取和更新操作的原子性。



