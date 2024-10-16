using Microsoft.Extensions.Caching.Memory;
using System.Data;

namespace InfProject.Utils
{
    /// <summary>
    /// перечисление для режимов кеширования
    /// </summary>
    public enum PreCacheTableOptions : uint
    {
        NoCache = 0,    // no cache
        RAMOnly = 1,    // cache in RAM only (no disk)
        RAMandHDD = 2   // cache in RAM and on Disk
    }
    /*
    /// <summary>
    /// делегат для вызова метода, возвращающего табличку DataTable
    /// </summary>
    /// <param name="curRubricID">curRubricID</param>
    /// <param name="level">level</param>
    /// <returns>DataTable</returns>
    public delegate DataTable delegate_getTable4Rubrics(int curRubricID, int level);

    /// <summary>
    /// делегат для вызова метода, возвращающего табличку DataTable
    /// </summary>
    /// <returns>DataTable</returns>
    public delegate DataTable delegate_getTable();

    /// <summary>
    /// параметры, передаваемые в метод для генерации данных (метод отдельного потока или втроенный)
    /// </summary>
    public class PreCacheTable_Params
    {
        public string fileName = string.Empty;
        public string name = string.Empty;
        public delegate_getTable method = null;
        public HttpContext context = null;
        public string debug = string.Empty;
        public PreCacheTableOptions cacheMode = PreCacheTableOptions.RAMandHDD;
        public PreCacheTable_Params(string fileName, string name, delegate_getTable method, HttpContext context, PreCacheTableOptions cacheMode, string debug)
        {
            this.fileName = fileName;
            this.name = name;
            this.method = method;
            this.context = context;
            this.cacheMode = cacheMode;
            this.debug = debug;
        }
    }

    /// <summary>
    /// класс для кеширования результатов запросов на диск
    /// </summary>
    public class PreCacheTable
    {
        /// <summary>
        /// переменная, содержащая строку с именами (PreCacheTable_Params.name) выполянемых потоков
        /// </summary>
        public static string ActiveSessions = string.Empty;
        /// <summary>
        /// переменная для блокировки тяжелого потока (значение не играет роли)
        /// Используется только в lock(Lock4SingleThread)
        /// </summary>
        public static string Lock4SingleThread = string.Empty;

        /// <summary>
        /// удаление блокировки 
        /// </summary>
        /// <param name="name"></param>
        public static void RemoveLock(string name)
        {
            lock (ActiveSessions)
            {
                ActiveSessions = ActiveSessions.Replace("<!--#" + name + "#-->", string.Empty);
            }
        }

        /// <summary>
        /// проверка от одновременного запуска двух сессий с одним и тем же логином
        /// </summary>
        /// <returns>
        /// "" - успех (не обнаружено уже исполняющегося процесса) + добавляется запись блокировки для дочернего и главного магазина
        /// 1 - неудача: уже исполняется процесс от этого же имени
        /// </returns>
        public static string SetLock(string name)
        {
            if (string.IsNullOrEmpty(name))
                return "name==null";
            string RetVal = "default_error";   // неудача
            lock (ActiveSessions)
            {
                if (ActiveSessions.IndexOf("<!--#" + name + "#-->") == -1)
                {
                    RetVal = string.Empty;
                    ActiveSessions += "<!--#" + name + "#-->"; // добавляется запись блокировки
                }
                else
                    RetVal = "ERROR SetLock: Уже исполняется процесс от этого же имени [name=" + name + "]";
            }
            return RetVal;
        }



        public static void myCacheItemRemovedCallback(string key, Object value, CacheItemRemovedReason reason)
        {
            string st = string.Format("CacheItemRemovedCallback: \"{0}\" cache removed. Reason: {1}", key, reason.ToString());
            //Utils.LogDebug(st);
        }


        /// <summary>
        /// вспомогательная ф-ция для делегатов
        /// </summary>
        /// <param name="inDelegate"></param>
        /// <param name="a"></param>
        /// <param name="b"></param>
        /// <returns></returns>
        public static delegate_getTable convertDelagate(delegate_getTable4Rubrics inDelegate, int a, int b)
        {
            delegate_getTable Ret = delegate () { return inDelegate(a, b); };
            return Ret;
        }



        /// <summary>
        /// возвращает полное имя папки на диске для кеширования
        /// </summary>
        /// <returns>строка с путем к папке</returns>
        public static string GetCacheFolder()
        {
            HttpContext hc = HttpContext.Current;
            if (hc == null || hc.Server == null)
                return null;
            string folder = hc.Server.MapPath("/Cache");
            if (!Directory.Exists(folder))
            {
                Directory.CreateDirectory(folder);
            }
            return folder;
        }
        /// <summary>
        /// возвращает полное имя файла на диске с кешем по имени кеша
        /// </summary>
        /// <param name="cacheName">имя кеша</param>
        /// <returns>строка с полным путем к файлу</returns>
        public static string GetCacheFileName(string cacheName)
        {
            return Path.Combine(GetCacheFolder(), cacheName);
        }



        #region Поля
        /// <summary>
        /// имя кешированного фрагмента
        /// </summary>
        public string name = string.Empty;

        /// <summary>
        /// значение кеша
        /// </summary>
        public DataTable value = null;
        #endregion

        /// <summary>
        /// Конструктр по умолчанию
        /// </summary>
        public PreCacheTable() { }

        #region Реализация
        /// <summary>
        /// Запись таблички на диск 
        /// </summary>
        /// <param name="fileName">полный путь к файлу на диске</param>
        /// <param name="name">имя кеша</param>
        /// <param name="value">DataTable для кеширования</param>
        public static void SaveToDisk(string fileName, string name, DataTable value)
        {
            if (string.IsNullOrEmpty(fileName) || string.IsNullOrEmpty(name) || value == null)
                return;
            value.TableName = name;
            /// *** VIC - добавил lock - надо смотреть как будет работать под нагрузкой
            //lock (typeof(System.IO.File)) - лишнее, т.к. lock есть веше по иерархии
            value.WriteXml(fileName, XmlWriteMode.WriteSchema, false);
        }
        /// <summary>
        /// Запись таблички на диск 
        /// </summary>
        /// <param name="name">имя кеша</param>
        /// <param name="value">DataTable для кеширования</param>
        public static void SaveToDisk(string name, DataTable value)
        {
            SaveToDisk(GetCacheFileName(name), name, value);
        }

        /// <summary>
        /// читаем содержимое кеша с диска
        /// </summary>
        /// <param name="name">имя кеша</param>
        /// <returns>DataTable или null</returns>
        public static DataTable LoadFromDisk(string name)
        {
            string fn = GetCacheFileName(name);
            if (!File.Exists(fn))
                return null;
            DataTable value = new DataTable();
            try
            {
                value.ReadXml(fn);
            }
            catch (Exception ex)
            {
                string st = string.Format("PreCacheTable.LoadFromDisk({0}): {1}: {2}. Cache will be deleted...",
                    name, ex.GetType().ToString(), ex.Message);
                Utils.LogError(st);
                //Utils.LogDebug(st);
                value = null;
                try
                {
                    System.IO.File.Delete(fn);
                    st = string.Format("PreCacheTable.LoadFromDisk({0}): Cache was deleted...", name);
                    Utils.LogError(st);
                    //Utils.LogDebug(st);
                }
                catch (Exception ex2)
                {
                    st = string.Format("PreCacheTable.LoadFromDisk DeleteCache ERROR ({0}): {1}: {2}",
                        name, ex2.GetType().ToString(), ex2.Message);
                    Utils.LogError(st);
                    //Utils.LogDebug(st);
                }
            }
            return value;
        }

        /// <summary>
        /// главный метод потока
        /// запускается для заполнения кеша
        /// </summary>
        /// <param name="obj"></param>
        public static void Excute4Cache_Thread(object obj)
        {
            // отсечем всякую фигню
            if (obj == null)
                return;
            PreCacheTable_Params param = (PreCacheTable_Params)obj;
            if (string.IsNullOrEmpty(param.name) || param.method == null)
                return;
            string lockResult = string.Empty;
            try
            {
                lockResult = SetLock(param.name);
                if (!string.IsNullOrEmpty(lockResult))
                {
                    //Utils.LogDebug(string.Format("Excute4Cache_Thread({0}) lock error: {1}", param.name, lockResult));
                    return;
                }
                // тут все проверки пройдены и можно выполнять метод!
                lock (PreCacheTable.Lock4SingleThread)    // ЛОЧИМ статическую переменную !!! Это надо, чтобы несколько фоновых потоков не выполняли одновременно тяжелые запросы к SQL Server (а то порвут его в лоскуты)
                {
                    Execute4Cache(param);
                }
            }
            finally
            {
                if (string.IsNullOrEmpty(lockResult))
                {
                    RemoveLock(param.name);
                }
            }
        }

        /// <summary>
        /// выполняем запрос (вызывая метод param.method), пишем его на диск (из кеша сбросится автоматом)
        /// </summary>
        /// <param name="param">PreCacheTable_Params</param>
        /// <returns>DataTable</returns>
        public static DataTable Execute4Cache(PreCacheTable_Params param)
        {
            DataTable value = new DataTable();
            string fileName = param.fileName;
            string name = param.name;
            delegate_getTable method = param.method;
            PreCacheTableOptions cacheMode = param.cacheMode;
            string debug = param.debug == null ? string.Empty : param.debug;

            if (string.IsNullOrEmpty(name) || method == null)
                return value;
            // Cache _cache = HttpContext.Current.Cache; // в отдельном потоке так нельзя, т.к. будет null
            try
            {
                // в кеше(HDD) пусто => придется выполянть запрос
                //Utils.LogDebug(string.Format("Execute4Cache(ShopID={0}, NameCacheItem={1}, cacheMode={2}, debug={3}) - executing...", ShopsInfo.ShopID, name, cacheMode, debug));
                value = method();
                //Utils.LogDebug(string.Format("Execute4Cache(ShopID={0}, NameCacheItem={1}, cacheMode={2}, debug={3}) - executed ok", ShopsInfo.ShopID, name, cacheMode, debug));

                // теперь надо записать результат на диск
                if (cacheMode == PreCacheTableOptions.RAMandHDD)
                {
                    SaveToDisk(fileName, name, value);    // запишем на диск содержимое таблички
                    //Utils.LogDebug(string.Format("Execute4Cache(ShopID={0}, NameCacheItem={1}, cacheMode={2}, debug={3}) - written to disk ok", ShopsInfo.ShopID, name, cacheMode, debug));
                }

                // занесем в кеш (RAM)
                Cache _cache = param.context.Cache;
                _cache.Insert(name,
                    value,
                    new CacheDependency(
                        null,    // кеш не зависит от диска
                        ShopsInfo.CachDependencyKeysCatalog),
                    Cache.NoAbsoluteExpiration,
                    TimeSpan.FromDays(3),
                    CacheItemPriority.NotRemovable,
                    PreCacheTable.myCacheItemRemovedCallback);
                //Utils.LogDebug(string.Format("Execute4Cache(ShopID={0}, NameCacheItem={1}, cacheMode={2}, debug={3}) - written to RAM cache ok", ShopsInfo.ShopID, name, cacheMode, debug));

            }
            catch (Exception ex)
            {
                string st = string.Format("PreCacheTable.Execute4Cache (ShopID={0}, NameCacheItem={1}, cacheMode={2}, debug={3}): {4}: {5}",
                    name, method.ToString(), cacheMode, debug, ex.GetType().ToString(), ex.Message);
                Utils.LogError(st);
                //Utils.LogDebug(st);
            }
            return value;
        }


        /// <summary>
        /// получение данных из кеша(память, потом диск с актуализацией кеша), если есть
        /// в противном случае выполение запроса через делегат method и помещение результата в кеш
        /// </summary>
        /// <param name="name">имя записи в кеше. Это КЛЮЧ (требуется уникальность)</param>
        /// <param name="lockParamenter">параметр для блокировки при выполнении запроса и записи в кеш (если не надо - просто передать "new object()")</param>
        /// <param name="method">метод для выполнения запроса</param>
        /// <returns>DataTable с данными</returns>
        public static DataTable Get(string name, object lockParamenter, delegate_getTable method)
        {
            return Get(name, lockParamenter, method, PreCacheTableOptions.RAMandHDD);
        }


        /// <summary>
        /// получение данных из кеша(память, потом диск с актуализацией кеша), если есть
        /// в противном случае выполение запроса через делегат method и помещение результата в кеш
        /// </summary>
        /// <param name="name">имя записи в кеше. Это КЛЮЧ (требуется уникальность)</param>
        /// <param name="lockParamenter">параметр для блокировки при выполнении запроса и записи в кеш (если не надо - просто передать "new object()")</param>
        /// <param name="method">метод для выполнения запроса</param>
        /// <param name="CacheMode">использовать ли кеш и каким образом</param>
        /// <returns>DataTable с данными</returns>
        public static DataTable Get(string name, object lockParamenter, delegate_getTable method, PreCacheTableOptions cacheMode)
        {
            DataTable value = new DataTable();
            if (cacheMode == PreCacheTableOptions.NoCache)
            {
                if (method != null)
                {
                    value = method();
                }
                return value;
            }
            PreCacheTable_Params param = null;
            if (string.IsNullOrEmpty(name) || method == null)
                return value;

            string strMsg = string.Empty;
            Cache _cache = HttpContext.Current.Cache;

            /// читаем значение из кеша(RAM) - это было внесено в lock
            value = _cache[name] as DataTable;
            if (value != null)
            {
                // возвращаем из кеша(RAM) значение
                return value;
            }

            lock (lockParamenter)
            {
                /// читаем значение из кеша(RAM) 2 раз (если несколько потоков ждет одновременно, то первый выполянет запрос и пишет в кеш, а последующие должны только прочесть результат из кеша, а не читать еще раз результат с диска (или выполнять запрос))
                value = _cache[name] as DataTable;
                if (value != null)
                {
                    // возвращаем из кеша(RAM) значение
                    return value;
                }

                try
                {
                    // в кеше(RAM) пусто => проверим кеш на диске(HDD)
                    string fileName = GetCacheFileName(name);
                    if (cacheMode == PreCacheTableOptions.RAMandHDD)
                    {
                        value = LoadFromDisk(name);
                    }
                    if (value != null)
                    {
                        //Utils.LogDebug(string.Format("PreCacheTable.Get(ShopID={0}, NameCacheItem={1}) - taken from disk ok", ShopsInfo.ShopID, name));
                        // занесем в кеш
                        _cache.Insert(name,
                            value,
                            new CacheDependency(
                                null, // кеш не зависит от диска (изменено 22.11.11)   // new string[] { GetCacheFileName(name) },    // КЕШ ЗАВИСИТ ОТ ДИСКА
                                ShopsInfo.CachDependencyKeysCatalog),
                            Cache.NoAbsoluteExpiration,
                            TimeSpan.FromMinutes(10),
                            CacheItemPriority.NotRemovable,
                            PreCacheTable.myCacheItemRemovedCallback);
                        // тут надо запустить фоновый поток на вычисление кеша (уникальность по имени проверяется в ф-ции потока)

                        //Utils.LogDebug(string.Format("PreCacheTable.Get(ShopID={0}, NameCacheItem={1}) - starting background thread...", ShopsInfo.ShopID, name));
                        // подготовим поток для запуска
                        Thread newThread = new Thread(PreCacheTable.Excute4Cache_Thread);
                        // подготовим параметры для потока
                        param = new PreCacheTable_Params(fileName, name, method, HttpContext.Current, cacheMode, "backgroundThread");
                        // запустим поток
                        newThread.Start(param);
                        //Utils.LogDebug(string.Format("PreCacheTable.Get(ShopID={0}, NameCacheItem={1}) - returning value...", ShopsInfo.ShopID, name));
                        // возвращаем из кеша(HDD) значение
                        return value;
                    }
                    /// сюда попадаем, если кеша на диске нет => будем вычислять через вызов метода в текущем потоке (самые тормоза, но деваться некуда - это будет работать только 1 раз в жизни, когда кеша на диске нет)
                    param = new PreCacheTable_Params(fileName, name, method, HttpContext.Current, cacheMode, "currentThread");
                    value = Execute4Cache(param);
                }
                catch (Exception ex)
                {
                    string st = string.Format("PreCacheTable.Get HDD({0}, {1}): {2}: {3}",
                        name, method.ToString(), ex.GetType().ToString(), ex.Message);
                    Utils.LogError(st);
                    //Utils.LogDebug(st);
                }
            }//end lock
            return value;
        }
        #endregion
    }
    */
}
