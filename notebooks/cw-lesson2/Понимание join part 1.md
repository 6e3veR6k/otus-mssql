# Понимание джойнов сломано. Это точно не пересечение кругов, честно

<p>Так получилось, что я провожу довольно много собеседований на должность веб-программиста. Один из обязательных вопросов, который я задаю — это чем отличается INNER JOIN от LEFT JOIN.</p>
<p>Чаще всего ответ примерно такой: "inner join — это как бы пересечение множеств, т.е. остается только то, что есть в обеих таблицах, а left join — это когда левая таблица остается без изменений, а от правой добавляется пересечение множеств. Для всех остальных строк добавляется null". Еще, бывает, рисуют пересекающиеся круги. </p>
<p>Я так устал от этих ответов с пересечениями множеств и кругов, что даже перестал поправлять людей. </p>
<p>Дело в том, что этот ответ в общем случае неверен. Ну или, как минимум, не точен.</p><a name="habracut"></a>
<p>Давайте рассмотрим почему, и заодно затронем еще парочку тонкостей join-ов.</p>
<p>Во-первых, таблица — это вообще не множество. По математическому определению, во множестве все элементы уникальны, не повторяются, а в таблицах в общем случае это вообще-то не так. Вторая беда, что термин "пересечение" только путает.</p>
<p>(<strong>Update</strong>. В комментах идут жаркие споры о теории множеств и уникальности. Очень интересно, много нового узнал, спасибо)</p>
<h2 id="inner-join">INNER JOIN</h2>
<p>Давайте сразу пример. </p>
<p>Итак, создадим две одинаковых таблицы с одной колонкой id, в каждой из этих таблиц пусть будет по две строки со значением 1 и еще что-нибудь.</p>
<pre><code class="sql hljs"><span class="hljs-keyword"><span class="hljs-keyword">INSERT</span></span> <span class="hljs-keyword"><span class="hljs-keyword">INTO</span></span> table1
(<span class="hljs-keyword"><span class="hljs-keyword">id</span></span>)
<span class="hljs-keyword"><span class="hljs-keyword">VALUES</span></span>
(<span class="hljs-number"><span class="hljs-number">1</span></span>),
(<span class="hljs-number"><span class="hljs-number">1</span></span>)
(<span class="hljs-number"><span class="hljs-number">3</span></span>);

<span class="hljs-keyword"><span class="hljs-keyword">INSERT</span></span> <span class="hljs-keyword"><span class="hljs-keyword">INTO</span></span> table2
(<span class="hljs-keyword"><span class="hljs-keyword">id</span></span>)
<span class="hljs-keyword"><span class="hljs-keyword">VALUES</span></span>
(<span class="hljs-number"><span class="hljs-number">1</span></span>),
(<span class="hljs-number"><span class="hljs-number">1</span></span>),
(<span class="hljs-number"><span class="hljs-number">2</span></span>);</code></pre>
<p>Давайте, их, что ли, поджойним</p>
<pre><code class="plaintext hljs">SELECT *
FROM table1
   INNER JOIN table2
      ON table1.id = table2.id;</code></pre>
<p>Если бы это было "пересечение множеств", или хотя бы "пересечение таблиц", то мы бы увидели две строки с единицами. </p>
<p><img src="https://habrastorage.org/webt/2i/ly/no/2ilynombeb6-fchhmcx5_i_zjyw.png"></p>
<p>На практике ответ будет такой:</p>
<pre>| id  | id  |
| --- | --- |
| 1   | 1   |
| 1   | 1   |
| 1   | 1   |
| 1   | 1   |
</pre>
<p><img src="https://habrastorage.org/webt/ia/o1/0e/iao10em5gyhgwnxfdivsmyeep_a.png"></p>
<p>Но как??</p>
<p>Для начала рассмотрим, что такое CROSS JOIN. Вдруг кто-то не в курсе. </p>
<p>CROSS JOIN — это просто все возможные комбинации соединения строк двух таблиц. Например, есть две таблицы, в одной из них 3 строки, в другой — 2:</p>
<pre><code class="sql hljs"><span class="hljs-keyword"><span class="hljs-keyword">select</span></span> * <span class="hljs-keyword"><span class="hljs-keyword">from</span></span> t1;</code></pre>
<pre> id 
----
  1
  2
  3
</pre>
<pre><code class="sql hljs"><span class="hljs-keyword"><span class="hljs-keyword">select</span></span> * <span class="hljs-keyword"><span class="hljs-keyword">from</span></span> t2;</code></pre>
<pre> id 
----
  4
  5
</pre>
<p>Тогда CROSS JOIN будет порождать 6 строк.</p>
<pre><code class="sql hljs"><span class="hljs-keyword"><span class="hljs-keyword">select</span></span> * 
<span class="hljs-keyword"><span class="hljs-keyword">from</span></span> t1
   <span class="hljs-keyword"><span class="hljs-keyword">cross</span></span> <span class="hljs-keyword"><span class="hljs-keyword">join</span></span> t2; </code></pre>
<pre> id | id 
----+----
  1 |  4
  1 |  5
  2 |  4
  2 |  5
  3 |  4
  3 |  5
</pre>
<p>Так вот, вернемся к нашим баранам.
Конструкция </p>
<pre><code class="sql hljs">t1 INNER JOIN t2 ON condition</code></pre>
<p> — это, можно сказать, всего лишь синтаксический сахар к </p>
<pre><code class="sql hljs">t1 CROSS JOIN t2  WHERE condition</code></pre>
<p>Т.е. по сути <code>INNER JOIN</code> — это все комбинации соединений строк с неким фильтром <code>condition</code>. В общем-то, можно это представлять по разному, кому как удобнее, но точно не как пересечение каких-то там кругов.</p>
<p>Небольшой disclaimer: хотя inner join логически эквивалентен cross join с фильтром, это не значит, что база будет делать именно так, в тупую: генерить все комбинации и фильтровать. На самом деле там более интересные алгоритмы.</p>
<h2 id="left-join">LEFT JOIN</h2>
<p>Если вы считаете, что левая таблица всегда остается неизменной, а к ней присоединяется или значение из правой таблицы или null, то это в общем случае не так, а именно в случае когда есть повторы данных.</p>
<p>Опять же, создадим две таблицы:</p>
<pre><code class="sql hljs"><span class="hljs-keyword"><span class="hljs-keyword">insert</span></span> <span class="hljs-keyword"><span class="hljs-keyword">into</span></span> t1 
(<span class="hljs-keyword"><span class="hljs-keyword">id</span></span>)
<span class="hljs-keyword"><span class="hljs-keyword">values</span></span>
(<span class="hljs-number"><span class="hljs-number">1</span></span>),
(<span class="hljs-number"><span class="hljs-number">1</span></span>),
(<span class="hljs-number"><span class="hljs-number">3</span></span>);

<span class="hljs-keyword"><span class="hljs-keyword">insert</span></span> <span class="hljs-keyword"><span class="hljs-keyword">into</span></span> t2
(<span class="hljs-keyword"><span class="hljs-keyword">id</span></span>)
<span class="hljs-keyword"><span class="hljs-keyword">values</span></span>
(<span class="hljs-number"><span class="hljs-number">1</span></span>),
(<span class="hljs-number"><span class="hljs-number">1</span></span>),
(<span class="hljs-number"><span class="hljs-number">4</span></span>),
(<span class="hljs-number"><span class="hljs-number">5</span></span>);</code></pre>
<p>Теперь сделаем LEFT JOIN:</p>
<pre><code class="sql hljs"><span class="hljs-keyword"><span class="hljs-keyword">SELECT</span></span> * 
<span class="hljs-keyword"><span class="hljs-keyword">FROM</span></span> t1
   <span class="hljs-keyword"><span class="hljs-keyword">LEFT</span></span> <span class="hljs-keyword"><span class="hljs-keyword">JOIN</span></span> t2 
       <span class="hljs-keyword"><span class="hljs-keyword">ON</span></span> t1.id = t2.id;</code></pre>
<p>Результат будет содержать 5 строк, а не по количеству строк в левой таблице, как думают очень многие.</p>
<pre>| id  | id  |
| --- | --- |
| 1   | 1   |
| 1   | 1   |
| 1   | 1   |
| 1   | 1   |
| 3   |     |
</pre>
<p>Так что, LEFT JOIN — это тоже самое что и INNER JOIN (т.е. все комбинации соединений строк, отфильтрованных по какому-то условию), и плюс еще записи из левой таблицы, для которых в правой по этому фильтру ничего не совпало. </p>
<p>LEFT JOIN можно переформулировать так:</p>
<pre><code class="sql hljs"><span class="hljs-keyword"><span class="hljs-keyword">SELECT</span></span> * 
<span class="hljs-keyword"><span class="hljs-keyword">FROM</span></span> t1 
   <span class="hljs-keyword"><span class="hljs-keyword">CROSS</span></span> <span class="hljs-keyword"><span class="hljs-keyword">JOIN</span></span> t2
   <span class="hljs-keyword"><span class="hljs-keyword">WHERE</span></span> t1.id = t2.id

<span class="hljs-keyword"><span class="hljs-keyword">UNION</span></span> ALL

<span class="hljs-keyword"><span class="hljs-keyword">SELECT</span></span> t1.id, <span class="hljs-literal"><span class="hljs-literal">null</span></span>
   <span class="hljs-keyword"><span class="hljs-keyword">FROM</span></span> t1
   <span class="hljs-keyword"><span class="hljs-keyword">WHERE</span></span> <span class="hljs-keyword"><span class="hljs-keyword">NOT</span></span> <span class="hljs-keyword"><span class="hljs-keyword">EXISTS</span></span> (
        <span class="hljs-keyword"><span class="hljs-keyword">SELECT</span></span>
        <span class="hljs-keyword"><span class="hljs-keyword">FROM</span></span> t2
        <span class="hljs-keyword"><span class="hljs-keyword">WHERE</span></span> t2.id = t1.id
   )</code></pre>
<p>Сложноватое объяснение, но что поделать, зато оно правдивее, чем круги с пересечениями и т.д.</p>
<h2 id="uslovie-on">Условие ON</h2>
<p>Удивительно, но по моим ощущениям 99% разработчиков считают, что в условии ON должен быть id из одной таблицы и id из второй. На самом деле там любое булево выражение.</p>
<p>Например, есть таблица со статистикой юзеров users_stats, и таблица с ip адресами городов.
Тогда к статистике можно прибавить город</p>
<pre><code class="sql hljs"><span class="hljs-keyword"><span class="hljs-keyword">SELECT</span></span> s.id, c.city 
<span class="hljs-keyword"><span class="hljs-keyword">FROM</span></span> users_stats <span class="hljs-keyword"><span class="hljs-keyword">AS</span></span> s
    <span class="hljs-keyword"><span class="hljs-keyword">JOIN</span></span> cities_ip_ranges <span class="hljs-keyword"><span class="hljs-keyword">AS</span></span> c
        <span class="hljs-keyword"><span class="hljs-keyword">ON</span></span> c.ip_range &amp;&amp; s.ip</code></pre>
<p>где &amp;&amp; — оператор пересечения (см. расширение посгреса <a href="https://github.com/RhodiumToad/ip4r">ip4r</a>)</p>
<p>Если в условии ON поставить true, то это будет полный аналог CROSS JOIN</p>
<pre><code class="plaintext hljs">"table1 JOIN table2 ON true"  == "table1 CROSS JOIN table2"</code></pre>
<h2 id="proizvoditelnost">Производительность</h2>
<p>Есть люди, которые боятся join-ов как огня. Потому что "они тормозят". Знаю таких, где есть полный запрет join-ов по проекту. Т.е. люди скачивают две-три таблицы себе в код и джойнят вручную в каком-нибудь php.</p>
<p>Это, прямо скажем, странно.</p>
<p>Если джойнов немного, и правильно сделаны индексы, то всё будет работать быстро. Проблемы будут возникать скорее всего лишь тогда, когда у вас таблиц будет с десяток в одном запросе. Дело в том, что планировщику нужно определить, в какой последовательности осуществлять джойны, как выгоднее это сделать. </p>
<p>Сложность этой задачи <strong>O(n!)</strong>, где n — количество объединяемых таблиц. Поэтому для большого количества таблиц, потратив некоторое время на поиски оптимальной последовательности, планировщик прекращает эти поиски и делает такой план, какой успел придумать. В этом случае иногда бывает выгодно вынести часть запроса в <a href="https://habr.com/ru/post/440576/">подзапрос CTE</a>; например, если вы точно знаете, что, поджойнив две таблицы, мы получим очень мало записей, и остальные джойны будут стоить копейки.</p>
<p>Кстати, Еще маленький совет по производительности. Если нужно просто найти элементы в таблице, которых нет в другой таблице, то лучше использовать не 'LEFT JOIN… WHERE… IS NULL', а конструкцию EXISTS. Это и читабельнее, и быстрее.</p>
<h2 id="vyvody">Выводы</h2>
<p>Как мне кажется, не стоит использовать диаграммы Венна для объяснения джойнов. Также, похоже, нужно избегать термина "пересечение".</p>
<p>Как объяснить <strong>на картинке</strong> джойны корректно, я, честно говоря, не представляю. Если вы знаете — расскажите, плиз, и киньте в коменты. А мы обсудим это в одном из ближайших выпусков подкаста <a href="https://soundcloud.com/znprod">"Цинковый прод"</a>. Не забудьте подписаться.</p>
<p><strong>Update.</strong> Продолжение статьи здесь: <a href="https://habr.com/ru/post/450528/">https://habr.com/ru/post/450528/</a></p>