# Понимание джойнов сломано. Продолжение. Попытка альтернативной визуализации.

<blockquote>Многие из вас читали <a href="https://habr.com/ru/post/448072/">предыдущую статью</a> про то, как неправильная визуализация для объяснения работы JOIN-ов в некоторых случаях может запутать. Круги Венна не могут полноценно проиллюстрировать некоторые моменты, например, если значения в таблице повторяются.</blockquote><p>При подготовке к записи шестого выпуска <a href="https://soundcloud.com/znprod">подкаста "Цинковый прод"</a> (где мы договорились обсудить статью) кажется удалось нащупать один интересный вариант визуализации. Кроме того, в комментариях к изначальной статье тоже предлагали похожий вариант.</p>
<p>Все желающие приглашаются под кат</p><a name="habracut"></a>
<p>Итак, визуализация. Как мы выяснили в комментах к предыдущей статье, join — это скорее декартово произведение, чем пересечение. Если посмотреть, как иллюстрируют декартово произведение, то можно заметить, что зачастую это прямоугольная таблица, где по одной оси идет первое отношение, а по другой — второе. Таким образом элементы таблицы будут представлять собой все комбинации всего. </p>
<p>Сложно абстрактно это нарисовать, поэтому придется на примере. </p>
<p>Допустим, у нас есть две таблицы. В одной из них </p>
<pre><code class="plaintext hljs">id
--
1
1
6
5</code></pre>
<p>В другой:</p>
<pre><code class="plaintext hljs">id
--
1
1
2
3
5</code></pre>
<p>Сразу disclaimer: я назвал поле словом "id" просто для краткости. Многие в прошлой статье возмущались, как это так — id повторяются, безобразие. Не стоит сильно переживать, ну
представьте, например, что это таблица с ежедневной статистикой, где для каждого дня и каждого юзера есть данные по посещению какого-нибудь сайта. В общем, не суть.</p>
<p>Итак, мы хотим узнать, что же получится при различных джойнах таблиц. Начнем с CROSS JOIN:</p>
<h2 id="cross-join">CROSS JOIN</h2>
<pre><code class="sql hljs"><span class="hljs-keyword"><span class="hljs-keyword">SELECT</span></span> t1.id, t2.id
<span class="hljs-keyword"><span class="hljs-keyword">FROM</span></span> t1 
    <span class="hljs-keyword"><span class="hljs-keyword">CROSS</span></span> <span class="hljs-keyword"><span class="hljs-keyword">JOIN</span></span> t2</code></pre>
<p>CROSS JOIN — это все все возможные комбинации, которые можно получить из двух таблиц. </p>
<p>Визуализировать это можно так: по оси x — одна таблица, по оси y — другая, все клеточки внутри (выделены оранжевым) — это результат</p>
<p><img src="https://habrastorage.org/webt/cn/pm/1u/cnpm1u8xvea5yn9l2_zs0aslnhi.png"></p>
<h2 id="inner-join">INNER JOIN</h2>
<p>INNER JOIN (или просто JOIN) — это тот же самый CROSS JOIN, у которого оставлены только те элементы, которые удовлетворяют условию, записанному в конструкции "ON". Обратите внимание на ситуацию, когда записи дублируются — результатов с единичками будет четыре штуки.</p>
<pre><code class="sql hljs"><span class="hljs-keyword"><span class="hljs-keyword">SELECT</span></span> t1.id, t2.id
<span class="hljs-keyword"><span class="hljs-keyword">FROM</span></span> t1 
    <span class="hljs-keyword"><span class="hljs-keyword">INNER</span></span> <span class="hljs-keyword"><span class="hljs-keyword">JOIN</span></span> t2
        <span class="hljs-keyword"><span class="hljs-keyword">ON</span></span> t1.id = t2.id</code></pre>
<p><img src="https://habrastorage.org/webt/zy/tr/9a/zytr9aow8-2bopcicmymuhxdjj4.png"></p>
<h2 id="left-join">LEFT JOIN</h2>
<p>LEFT OUTER JOIN (или просто LEFT JOIN) — это тоже самое, что и INNER JOIN, но дополнительно мы добавляем null для строк из первой таблицы, для которой ничего не нашлось во второй</p>
<pre><code class="sql hljs"><span class="hljs-keyword"><span class="hljs-keyword">SELECT</span></span> t1.id, t2.id
<span class="hljs-keyword"><span class="hljs-keyword">FROM</span></span> t1
    <span class="hljs-keyword"><span class="hljs-keyword">LEFT</span></span> <span class="hljs-keyword"><span class="hljs-keyword">JOIN</span></span> t2
        <span class="hljs-keyword"><span class="hljs-keyword">ON</span></span> t1.id = t2.id</code></pre>
<p><img src="https://habrastorage.org/webt/d7/cb/7c/d7cb7cq3l98dtscuzpwoh-njiro.png"></p>
<h2 id="right-join">RIGHT JOIN</h2>
<p>RIGHT OUTER JOIN ( или RIGHT JOIN) — это тоже самое, что и LEFT JOIN, только наоборот. Т.е. это INNER JOIN + null для строк из второй таблицы, для которой ничего не нашлось в первой</p>
<pre><code class="sql hljs"><span class="hljs-keyword"><span class="hljs-keyword">SELECT</span></span> t1.id, t2.id
<span class="hljs-keyword"><span class="hljs-keyword">FROM</span></span> t1
    <span class="hljs-keyword"><span class="hljs-keyword">RIGHT</span></span> <span class="hljs-keyword"><span class="hljs-keyword">JOIN</span></span> t2
        <span class="hljs-keyword"><span class="hljs-keyword">ON</span></span> t1.id = t2.id</code></pre>
<p><img src="https://habrastorage.org/webt/dv/4f/mf/dv4fmfmfwy97ki2d9ui-wnabmwi.png"></p>
<p>→ Поиграть с запросами можно <a href="http://www.sqlfiddle.com/#!15/2a20cc/5">здесь</a></p>
<h2 id="vyvody">Выводы</h2>
<p>Вроде бы получилась простая визуализация. Хотя в ней есть ограничения: здесь показан случай, когда в ON записано равенство, а не что-то хитрое (любое булево выражение). Кроме того не рассмотрен случай, когда среди значений таблицы есть null. Т.е. это всё равно некоторое упрощение, но вроде бы получилось лучше и точнее, чем круги Венна.</p>
<p>Подписывайтесь на наш подкаст <a href="https://soundcloud.com/znprod">"Цинковый прод"</a>, там мы обсуждаем базы данных, разработку софта и прочие интересные штуки.</p>