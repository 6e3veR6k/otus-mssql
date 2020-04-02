---
title: База данных tempdb | Документация Майкрософт
description: В этой статье приводятся подробные сведения о настройке и использовании базы данных tempdb в SQL Server и базе данных SQL Azure.
ms.custom: P360
ms.date: 08/21/2019
ms.prod: sql
ms.prod_service: database-engine
ms.technology: ''
ms.topic: conceptual
helpviewer_keywords:
- temporary tables [SQL Server], tempdb database
- tempdb database [SQL Server], about tempdb
- temporary stored procedures [SQL Server]
- tempdb database [SQL Server]
ms.assetid: ce4053fb-e37a-4851-b711-8e504059a780
author: stevestein
ms.author: sstein
ms.reviewer: carlrab
monikerRange: =azuresqldb-current||>=sql-server-2016||=sqlallproducts-allversions||>=sql-server-linux-2017||=azuresqldb-mi-current
ms.openlocfilehash: 46807e551052ca6da38fde744d9a1e9dd7c794b0
ms.sourcegitcommit: 58158eda0aa0d7f87f9d958ae349a14c0ba8a209
ms.translationtype: HT
ms.contentlocale: ru-RU
ms.lasthandoff: 03/30/2020
ms.locfileid: "79288498"
---
# <a name="tempdb-database"></a>База данных tempdb

[!INCLUDE[appliesto-ss-asdb-xxxx-xxx-md](../../includes/appliesto-ss-asdb-xxxx-xxx-md.md)]

Системная база данных **TempDB** — это глобальный ресурс, доступный всем пользователям, подключенным к экземпляру [!INCLUDE[ssNoVersion](../../includes/ssnoversion-md.md)] или Базе данных SQL. База данных tempdb служит для хранения следующих объектов:  
  
- Временные **пользовательские объекты**, созданные явно, такие как глобальные или локальные временные таблицы и индексы, временные хранимые процедуры, табличные переменные, таблицы, возвращаемые функциями с табличными значениями, и курсоры.  
- **Внутренние объекты**, созданные ядром СУБД. К ним относятся следующие объекты.
  - Рабочие таблицы, хранящие промежуточные результаты буферов, курсоры, сортировки и временное хранилище больших объектов (LOB).
  - рабочие файлы для операций хэш-соединения или статистических хэш-выражений;
  - промежуточные результаты сортировки при таких операциях, как создание или перестроение индексов (если указан параметр SORT_IN_TEMPDB), либо определенных запросах GROUP BY, ORDER BY или UNION.

  > [!NOTE]
  > Каждый внутренний объект использует минимум девять страниц: страницу IAM и восьмистраничный экстент. Дополнительные сведения о страницах и экстентах см. в разделе [Страницы и экстенты](../../relational-databases/pages-and-extents-architecture-guide.md#pages-and-extents).
  > [!IMPORTANT]
  > Отдельные базы данных и эластичные пулы Базы данных SQL Azure поддерживают глобальные временные таблицы и глобальные временные хранимые процедуры, которые хранятся в TempDB и имеют область действия на уровне базы. Глобальные временные таблицы и глобальные временные хранимые процедуры являются общими для всех сеансов пользователей в рамках одной базы данных SQL Azure. Сеансы пользователей, связанные с другими базами данных SQL Azure, не имеют доступа к глобальным временным таблицам. Дополнительные сведения см. в разделе [Глобальные временные таблицы (база данных SQL Azure) в области базы данных](../../t-sql/statements/create-table-transact-sql.md#database-scoped-global-temporary-tables-azure-sql-database). [Управляемый экземпляр Базы данных SQL Azure](https://docs.microsoft.com/azure/sql-database/sql-database-managed-instance)) поддерживает те же временные объекты, что и SQL Server.
  > Для отдельных баз данных и эластичных пулов Базы данных SQL Azure применяются только базы master и TempDB. Дополнительные сведения см. в разделе [Что являет собою сервер Базы данных SQL Azure?](https://docs.microsoft.com/azure/sql-database/sql-database-servers-databases#what-is-an-azure-sql-database-server). Также см. раздел [База данных TempDB в отдельных базах и эластичных пулах Базы данных SQL Azure](#tempdb-database-in-sql-database). Для Управляемого экземпляра Базы данных Azure SQL применяются все системные базы данных.

- **Хранилища версий** — это коллекции страниц данных, содержащих строки данных, которые необходимы для поддержки возможностей, применяющих управление версиями строк. Существует два хранилища версий: общее хранилище версий и хранилище версий построения индексов в сети. Хранилища версий содержат следующее:
  - версии строк, сформированные транзакциями изменения данных в базе данных, в которой используются транзакции изоляции моментальных снимков с зафиксированным чтением и транзакции изоляции моментальных снимков;  
  - версии строк, создаваемые транзакциями изменения данных для таких функций, как операции с индексами в сети, функции режима MARS и триггеры AFTER.  
  
Операции в **TempDB** в минимальном объеме записываются в журнал, что позволяет откатывать транзакции. **TempDB** создается заново при каждом запуске [!INCLUDE[ssNoVersion](../../includes/ssnoversion-md.md)], чтобы система всегда запускалась с чистой копией базы. Временные таблицы и хранимые процедуры удаляются автоматически при отключении, и при выключении системы нет активных соединений. Поэтому сохранять что-либо в **TempDB** между сеансами [!INCLUDE[ssNoVersion](../../includes/ssnoversion-md.md)] не требуется. Операции резервного копирования и восстановления для **TempDB** недопустимы.  

## <a name="physical-properties-of-tempdb-in-sql-server"></a>Физические свойства TempDB в SQL Server

В следующей таблице приведены начальные значения конфигурации для файлов журналов и данных **TempDB** в SQL Server, основанные на значениях по умолчанию для шаблона базы данных. Размеры этих файлов могут немного изменяться в зависимости от выпуска [!INCLUDE[ssNoVersion](../../includes/ssnoversion-md.md)].  
  
|Файл|Логическое имя|Физическое имя|Начальный размер|Увеличение размера файлов|  
|----------|------------------|-------------------|------------------|-----------------|  
|Первичные данные|tempdev|tempdb.mdf|8 МБ|Автоматическое увеличение на 64 МБ до заполнения диска.|  
|Вторичные файлы данных*.|temp#|tempdb_mssql_ # .ndf|8 МБ|Автоматическое увеличение на 64 МБ до заполнения диска.|  
|Журнал|templog|templog.ldf|8 МБ|Автоматическое увеличение на 64 МБ до максимального размера в 2 ТБ.|  
  
\* Количество файлов зависит от числа (логических) процессоров на компьютере. Как правило, если число логических процессоров меньше или равно восьми, используйте равное ему число файлов данных. Если число логических процессоров больше восьми, используйте восемь файлов данных, а затем, если состязание сохраняется, увеличивайте число файлов данных на значение, кратное 4, пока состязание не уменьшится до приемлемого уровня, или внесите изменения в рабочую нагрузку или код.

> [!NOTE]
> Количество файлов данных по умолчанию основано на общих рекомендациях, приведенных в статье [KB 2154845](https://support.microsoft.com/kb/2154845/).  
  
### <a name="moving-the-tempdb-data-and-log-files-in-sql-server"></a>Перемещение файлов журналов и данных TempDB в SQL Server

Сведения о перемещении файлов журналов и данных **TempDB** см. в статье [Перемещение системных баз данных](../../relational-databases/databases/move-system-databases.md).  
  
### <a name="database-options-for-tempdb-in-sql-server"></a>Параметры базы данных TempDB в SQL Server

В следующей таблице приведены значения по умолчанию для всех параметров базы данных **TempDB** и указана возможность их изменения. Чтобы просмотреть текущие настройки этих параметров, используйте представление каталога [sys.databases](../../relational-databases/system-catalog-views/sys-databases-transact-sql.md) .  
  
|Параметр базы данных|Значение по умолчанию|Можно ли изменить|  
|---------------------|-------------------|---------------------|  
|ALLOW_SNAPSHOT_ISOLATION|OFF|Да|  
|ANSI_NULL_DEFAULT|OFF|Да|  
|ANSI_NULLS|OFF|Да|  
|ANSI_PADDING|OFF|Да|  
|ANSI_WARNINGS|OFF|Да|  
|ARITHABORT|OFF|Да|  
|AUTO_CLOSE|OFF|нет|  
|AUTO_CREATE_STATISTICS|ON|Да|  
|AUTO_SHRINK|OFF|нет|  
|AUTO_UPDATE_STATISTICS|ON|Да|  
|AUTO_UPDATE_STATISTICS_ASYNC|OFF|Да|  
|CHANGE_TRACKING|OFF|нет|  
|CONCAT_NULL_YIELDS_NULL|OFF|Да|  
|CURSOR_CLOSE_ON_COMMIT|OFF|Да|  
|CURSOR_DEFAULT|GLOBAL|Да|  
|Параметры доступности базы данных|ONLINE<br /><br /> MULTI_USER<br /><br /> READ_WRITE|нет<br /><br /> нет<br /><br /> нет|  
|DATE_CORRELATION_OPTIMIZATION|OFF|Да|  
|DB_CHAINING|ON|нет|  
|ENCRYPTION|OFF|нет|  
|MIXED_PAGE_ALLOCATION|OFF|нет|  
|NUMERIC_ROUNDABORT|OFF|Да|  
|PAGE_VERIFY|Значение CHECKSUM для новых установок [!INCLUDE[ssNoVersion](../../includes/ssnoversion-md.md)].<br /><br /> Значение NONE для обновлений [!INCLUDE[ssNoVersion](../../includes/ssnoversion-md.md)].|Да|  
|PARAMETERIZATION|ПРОСТОЙ|Да|  
|QUOTED_IDENTIFIER|OFF|Да|  
|READ_COMMITTED_SNAPSHOT|OFF|нет|  
|RECOVERY|ПРОСТОЙ|нет|  
|RECURSIVE_TRIGGERS|OFF|Да|  
|Параметры компонента Service Broker|ENABLE_BROKER|Да|  
|TRUSTWORTHY|OFF|нет|  
  
Описание этих баз данных см. в статье [Параметры ALTER DATABASE SET (Transact-SQL)](../../t-sql/statements/alter-database-transact-sql-set-options.md).  
  
## <a name="tempdb-database-in-sql-database"></a>База данных TempDB в Базе данных SQL

### <a name="tempdb-sizes-for-dtu-based-service-tiers"></a>Размеры TempDB для уровней служб на основе DTU

|SLO|Максимальный размер файлов данных TempDB (ГБ)|Число файлов данных TempDB|Максимальный размер данных TempDB (ГБ)|
|---|---:|---:|---:|
|Basic|13|1|13|
|S0|13|1|13|
|S1|13|1|13|
|S2|13|1|13|
|S3|32|1|32
|S4|32|2|64|
|S6|32|3|96|
|S7|32|6|192|
|S9|32|12|384|
|S12|32|12|384|
|P1|13|12|156|
|P2|13|12|156|
|P4|13|12|156|
|P6|13|12|156|
|P11|13|12|156|
|P15|13|12|156|
|Эластичные пулы уровня "Премиум" (все конфигурации DTU)|13|12|156|
|Эластичные пулы ценовой категории "Стандартный" (S0–S2)|13|12|156|
|Эластичные пулы ценовой категории "Стандартный" (S3 и выше) |32|12|384|
|Эластичные пулы уровня "Базовый" (все конфигурации DTU)|13|12|156|
||||

### <a name="tempdb-sizes-for-vcore-based-service-tiers"></a>Размеры TempDB для уровней служб на основе виртуальных ядер

См. [пределы для ресурсов на основе виртуальных ядер](https://docs.microsoft.com/azure/sql-database/sql-database-vcore-resource-limits)

## <a name="restrictions"></a>Ограничения

В базе данных **TempDB** невозможно выполнять следующие операции:  
  
- добавление файловых групп;
- резервное копирование и восстановление базы данных;
- Изменение параметров сортировки. (параметрами сортировки по умолчанию являются параметры сортировки сервера);
- Изменение владельца базы данных. (владельцем **TempDB** является **sa**);
- Создание моментального снимка базы данных
- удаление базы данных;
- удаление пользователя **guest** из базы данных;
- включение отслеживания измененных данных;
- участие в зеркальном отображении базы данных;
- удаление первичной файловой группы, первичного файла данных или файла журнала;
- переименование базы данных или первичной файловой группы;
- выполнение инструкции DBCC CHECKALLOC;
- выполнение инструкции DBCC CHECKCATALOG;
- перевод базы данных в режим "вне сети" (OFFLINE);
- перевод базы данных или первичной файловой группы в режим "только для чтения" (READ_ONLY).
  
## <a name="permissions"></a>Разрешения

Любой пользователь может создавать временные объекты в TempDB. Если не предоставлены какие-либо дополнительные разрешения, то пользователи могут производить доступ только к тем объектам, которыми они владеют. Существует возможность отменить разрешение на подключение к TempDB, чтобы пользователь не мог работать с этой базой, но делать это не рекомендуется, так как TempDB необходима для некоторых стандартных операций.  

## <a name="optimizing-tempdb-performance-in-sql-server"></a>Оптимизация производительности TempDB в SQL Server
Размер и физическое размещение базы данных TempDB может влиять на производительность системы. Например, если для TempDB установлен слишком малый размер, часть системной нагрузки по обработке может приходиться на автоматическое увеличение TempDB до размера, который необходим для поддержки рабочей нагрузки при каждом перезапуске экземпляра [!INCLUDE[ssNoVersion](../../includes/ssnoversion-md.md)].

Если возможно, используйте [мгновенную инициализацию файлов базы данных](../../relational-databases/databases/database-instant-file-initialization.md), чтобы улучшить производительность операций увеличения файлов данных.

Чтобы заранее выделить место для всех файлов TempDB, задайте достаточно большое значение размера файлов для типичных рабочих нагрузок в среде. Предварительное выделение позволяет избежать слишком частого расширения TempDB, способного повлиять на производительность. Для базы данных TempDB должно быть установлено автоувеличение, но все равно следует заранее увеличить место на диске для незапланированных исключений.

Файлы данных внутри каждой [файловой группы](../../relational-databases/databases/database-files-and-filegroups.md#filegroups) должны иметь одинаковый размер, поскольку [!INCLUDE[ssNoVersion](../../includes/ssnoversion-md.md)] использует алгоритм пропорционального заполнения, который повышает вероятность выделения памяти в файлах с большим объемом свободного пространства. Разделение TempDB на множество файлов данных равного размера обеспечивает эффективное выполнение использующих TempDB операций с высокой степенью параллелизма.

Установите достаточный шаг приращения для увеличения размера файлов базы данных TempDB. Если увеличение размера файлов будет слишком малым по сравнению с объемом записываемых в TempDB данных, база TempDB может постоянно требовать расширения, что скажется на производительности.

Чтобы проверить текущий размер и параметры увеличения TempDB, используйте следующий запрос:

```sql
 SELECT name AS FileName,
    size*1.0/128 AS FileSizeInMB,
    CASE max_size
        WHEN 0 THEN 'Autogrowth is off.'
        WHEN -1 THEN 'Autogrowth is on.'
        ELSE 'Log file grows to a maximum size of 2 TB.'
    END,
    growth AS 'GrowthValue',
    'GrowthIncrement' =
        CASE
            WHEN growth = 0 THEN 'Size is fixed.'
            WHEN growth > 0 AND is_percent_growth = 0
                THEN 'Growth value is in 8-KB pages.'
            ELSE 'Growth value is a percentage.'
        END
FROM tempdb.sys.database_files;
GO
```

Используйте базу данных TempDB с быстрой подсистемой ввода-вывода. Если имеется много непосредственно присоединенных дисков, то используйте чередование дисков. Отдельные файлы данных TempDB или их группы не обязательно должны располагаться на разных дисках или шпинделях, если только у вас не возникают какие-то узкие места в подсистеме ввода-вывода.

Размещайте TempDB на дисках, которые не используются пользовательскими базами данных.

## <a name="performance-improvements-in-tempdb-for-sql-server"></a>Улучшения производительности TempDB для SQL Server
Начиная с версии [!INCLUDE[ssSQL15](../../includes/sssql15-md.md)], производительность **TempDB** дополнительно оптимизирована следующим образом:  
  
- Временные таблицы и табличные переменные кэшируются. Кэширование позволяет операциям по удалению и созданию временных объектов выполняться очень быстро и снижает число состязаний из-за выделения страниц.  
- Усовершенствован протокол кратковременных блокировок выделения страниц для снижения количества используемых кратковременных блокировок UP (обновление).  
- Снижены затраты ресурсов на ведение журнала **TempDB** — уменьшено потребление пропускной способности подсистемы ввода-вывода файлом журнала **TempDB**.  
- Программа установки добавляет множество файлов данных TempDB при установке нового экземпляра. Эту задачу можно выполнить с помощью нового элемента управления для ввода в пользовательском интерфейсе в разделе **Настройка ядра СУБД** и с помощью параметра командной строки `/SQLTEMPDBFILECOUNT`. По умолчанию программа установки добавляет столько файлов данных TempDB, сколько имеется логических процессоров, но их может быть не больше восьми.  
- При наличии множества файлов данных **TempDB** автоматическое увеличение выполняется для всех файлов в одно время и в равном объеме согласно параметрам увеличения. [Флаг трассировки 1117](../../t-sql/database-console-commands/dbcc-traceon-trace-flags-transact-sql.md) больше не требуется.  
- Для всех операций распределения в **TempDB** используются единообразные экстенты. [Флаг трассировки 1118](../../t-sql/database-console-commands/dbcc-traceon-trace-flags-transact-sql.md) больше не требуется.  
- Для первичной файловой группы свойство AUTOGROW_ALL_FILES включено и не может быть изменено.

Дополнительные сведения об улучшениях производительности TempDB см. в следующей статье блога:

[TEMPDB — Files and Trace Flags and Updates, Oh My!](https://blogs.msdn.microsoft.com/sql_server_team/tempdb-files-and-trace-flags-and-updates-oh-my/) (TEMPDB — файлы, флаги трассировки и обновления)

## <a name="memory-optimized-tempdb-metadata"></a>Оптимизированные для памяти метаданные TempDB
Состязание метаданных TempDB всегда было узким местом для масштабируемости многих рабочих нагрузок, выполняющихся в [!INCLUDE[ssNoVersion](../../includes/ssnoversion-md.md)]. В [!INCLUDE[sql-server-2019](../../includes/sssqlv15-md.md)] появилась новая функция из семейства функций для [выполняющейся в памяти базы данных](../in-memory-database.md): оптимизированные для памяти метаданные TempDB. В сущности это позволяет устранить узкие места и обеспечить новый уровень масштабируемости для рабочих нагрузок, активно использующих TempDB. В [!INCLUDE[sql-server-2019](../../includes/sssqlv15-md.md)] системные таблицы, связанные с управлением метаданными временных таблиц, можно переместить в неустойчивые таблицы без кратковременной блокировки, оптимизированные для памяти.

Просмотрите это 7-минутное видео, чтобы получить общие сведения о том, как и когда следует использовать метаданные TempDB, оптимизированные для операций в памяти:

> [!VIDEO https://channel9.msdn.com/Shows/Data-Exposed/How-and-When-To-Memory-Optimized-TempDB-Metadata/player?WT.mc_id=dataexposed-c9-niner]


Чтобы согласиться на эту новую функцию, используйте следующий скрипт:

```sql
ALTER SERVER CONFIGURATION SET MEMORY_OPTIMIZED TEMPDB_METADATA = ON 
```

Чтобы это изменение конфигурации вступило в силу, нужно перезапустить службу.

У этой реализации имеются некоторые ограничения, которые нужно учитывать:

1. Включение и отключение функции не является динамическим. Из-за внутренних изменений, которые необходимо внести в структуру TempDB, для включения или отключения этой функции требуется перезапуск.

2. Отдельная транзакция не может обратиться к оптимизированным для памяти таблицам в более чем одной базе данных.  Это означает, что все транзакции, связанные с оптимизированной для памяти таблицей в пользовательской базе данных, не смогут обратиться к системным представлениям TempDB в той же транзакции.  Если вы попытаетесь обратиться к системным представлениям TempDB в той же транзакции, где участвует оптимизированная для памяти таблица в пользовательской базе данных, произойдет следующая ошибка:
    
    ```
    A user transaction that accesses memory optimized tables or natively compiled modules cannot access more than one user database or databases model and msdb, and it cannot write to master.
    ```
    
    Пример
    
    ```sql
    BEGIN TRAN
    SELECT *
    FROM tempdb.sys.tables  -----> Creates a user In-Memory OLTP Transaction on Tempdb
    INSERT INTO <user database>.<schema>.<mem-optimized table>
    VALUES (1)  ----> Attempts to create user In-Memory OLTP transaction but will fail
    COMMIT TRAN
    ```
    
3. Запросы к таблицам, оптимизированным для памяти, не поддерживают указания блокировки и изоляции, поэтому запросы к представлениям каталога оптимизированной для памяти TempDB не будут учитывать указания блокировки и изоляции. Как и в случае с другими системными представлениями каталога в [!INCLUDE[ssNoVersion](../../includes/ssnoversion-md.md)], все транзакции для системных представлений будут находиться в изоляции READ COMMITTED (или READ COMMITTED SNAPSHOT в данном случае).

4. При включении оптимизированных для памяти метаданных TempDB [индексы columnstore](../indexes/columnstore-indexes-overview.md) невозможно создавать во временных таблицах.

5. В связи с ограничением на индексы columnstore использование системной хранимой процедуры sp_estimate_data_compression_savings с параметром сжатия данных COLUMNSTORE или COLUMNSTORE_ARCHIVE не поддерживается, если включены оптимизированные для памяти метаданные TempDB.

> [!NOTE] 
> Эти ограничения действуют только при ссылке на системные представления TempDB, при необходимости вы сможете создать временную таблицу в той же транзакции, где обращаетесь к оптимизированной для памяти таблице в пользовательской базе данных.

Вы можете проверить, является ли TempDB оптимизированной для памяти, используя следующую команду T-SQL:
```
SELECT SERVERPROPERTY('IsTempdbMetadataMemoryOptimized')
```

Если не удается запустить сервер по какой-либо причине после включения оптимизированных для памяти метаданных TempDB, можно обойти эту функцию, запустив SQL Server в [минимальной конфигурации](../../database-engine/configure-windows/start-sql-server-with-minimal-configuration.md) с помощью параметра запуска **-f**. Это позволит отключить функцию, а затем перезапустить SQL Server в нормальном режиме.

## <a name="capacity-planning-for-tempdb-in-sql-server"></a>Планирование ресурсов для TempDB в SQL Server
Определение требуемого размера TempDB в рабочей среде [!INCLUDE[ssNoVersion](../../includes/ssnoversion-md.md)] зависит от многих факторов. Как описано выше в этой статье, эти факторы включают текущую рабочую нагрузку и используемые компоненты [!INCLUDE[ssNoVersion](../../includes/ssnoversion-md.md)]. Рекомендуется проанализировать текущую рабочую нагрузку, выполнив следующие задачи в среде тестирования SQL Server:

- Включите для TempDB автоувеличение.
- Запускайте отдельные запросы или файлы трассировки рабочей нагрузки и следите за использованием диска базой данных TempDB.
- Выполняйте операции обслуживания индексов, например перестроение индексов, и следите за использованием диска базой данных TempDB.
- Используйте значения используемого места на диске из предыдущих шагов для прогнозирования общей рабочей нагрузки, скорректируйте полученное значение с учетом предполагаемой параллельной обработки и задайте соответствующий размер TempDB.

## <a name="how-to-monitor-tempdb-use"></a>Мониторинг использования TempDB
Нехватка места на диске для TempDB может привести к существенным сбоям рабочей среды [!INCLUDE[ssNoVersion](../../includes/ssnoversion-md.md)] и помешать работающим приложениям завершить операции. Для отслеживания места на диске, используемого в файлах TempDB, можно применять динамическое административное представление [sys.dm_db_file_space_usage](../../relational-databases/system-dynamic-management-views/sys-dm-db-session-space-usage-transact-sql.md):

```sql
 -- Determining the Amount of Free Space in TempDB
SELECT SUM(unallocated_extent_page_count) AS [free pages],
  (SUM(unallocated_extent_page_count)*1.0/128) AS [free space in MB]
FROM sys.dm_db_file_space_usage;

-- Determining the Amount Space Used by the Version Store
SELECT SUM(version_store_reserved_page_count) AS [version store pages used],
  (SUM(version_store_reserved_page_count)*1.0/128) AS [version store space in MB]
FROM sys.dm_db_file_space_usage;

-- Determining the Amount of Space Used by Internal Objects
SELECT SUM(internal_object_reserved_page_count) AS [internal object pages used],
  (SUM(internal_object_reserved_page_count)*1.0/128) AS [internal object space in MB]
FROM sys.dm_db_file_space_usage;

-- Determining the Amount of Space Used by User Objects
SELECT SUM(user_object_reserved_page_count) AS [user object pages used],
  (SUM(user_object_reserved_page_count)*1.0/128) AS [user object space in MB]
FROM sys.dm_db_file_space_usage;
 ```

Кроме того, для мониторинга действий выделения и освобождения страниц в TempDB на уровне сеансов или задач можно использовать динамические административные представления [sys.dm_db_session_space_usage](../../relational-databases/system-dynamic-management-views/sys-dm-db-session-space-usage-transact-sql.md) и [sys.dm_db_task_space_usage](../../relational-databases/system-dynamic-management-views/sys-dm-db-task-space-usage-transact-sql.md). Эти представления позволяют выявлять большие запросы, временные таблицы или табличные переменные, которые используют много места на диске для TempDB. Кроме того, предусмотрено несколько счетчиков, которые можно использовать для мониторинга свободного места в базе данных TempDB, а также использующих ее ресурсов. Дополнительные сведения см. в следующем разделе.

```sql
-- Obtaining the space consumed by internal objects in all currently running tasks in each session
SELECT session_id,
  SUM(internal_objects_alloc_page_count) AS task_internal_objects_alloc_page_count,
  SUM(internal_objects_dealloc_page_count) AS task_internal_objects_dealloc_page_count
FROM sys.dm_db_task_space_usage
GROUP BY session_id;

-- Obtaining the space consumed by internal objects in the current session for both running and completed tasks
SELECT R2.session_id,
  R1.internal_objects_alloc_page_count
  + SUM(R2.internal_objects_alloc_page_count) AS session_internal_objects_alloc_page_count,
  R1.internal_objects_dealloc_page_count
  + SUM(R2.internal_objects_dealloc_page_count) AS session_internal_objects_dealloc_page_count
FROM sys.dm_db_session_space_usage AS R1
INNER JOIN sys.dm_db_task_space_usage AS R2 ON R1.session_id = R2.session_id
GROUP BY R2.session_id, R1.internal_objects_alloc_page_count,
  R1.internal_objects_dealloc_page_count;;
```

## <a name="related-content"></a>См. также
[Параметр SORT_IN_TEMPDB для индексов](../../relational-databases/indexes/sort-in-TempDB-option-for-indexes.md)    
[Системные базы данных](../../relational-databases/databases/system-databases.md)    
[sys.databases](../../relational-databases/system-catalog-views/sys-databases-transact-sql.md)    
[sys.master_files](../../relational-databases/system-catalog-views/sys-master-files-transact-sql.md)    
[Перемещение файлов базы данных](../../relational-databases/databases/move-database-files.md)    
  