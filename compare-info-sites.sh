#!/bash/bin

get_solr_core()
{
        site_version=$(drush st 2>/dev/null | grep 'Drupal version' | awk -F':' '{print $2}' | sed s/' '//g)
        local _res=$?
        if [ $_res -ne 0 ] || [ "$site_version" == "" ];
        then
                echo "Error: not get version drupal"
                return $_res
        fi

        if [[ -n $(echo "$site_version" | sed -n '/^8./p') ]];
        then
                QUERY=`drush --extra="--skip-column-names" sql-query "select data from config where name='search_api.server.solr_index';" 2>/dev/null`
		INDEX=36
        else
                if [[ -n $(echo "$site_version" | sed -n '/^7./p') ]];
                then
			exist_table=$(drush --extra="--skip-column-names" sql-query "SHOW TABLES LIKE 'search_api_server';" 2>/dev/null)
        _res=$?
        if [ $_res -ne 0 ] || [ "$site_version" == "" ];
        then
                echo "Error: not get version drupal"
                return $_res
        fi
			if [ "$exist_table" == "" ];
			then
				echo "None"
				return 0
			else
	                        QUERY=`drush --extra="--skip-column-names" sql-query "select options from search_api_server where enabled=1" 2>/dev/null`				INDEX=11
			fi
                else
                        echo "Error: not detected version drupal"
                        return 1
                fi
        fi
        _res=$?
        if [ $_res -ne 0 ];
        then
                echo "Error: not execute query to db"
                return $_res
        else
                if [ "$QUERY" != "" ];
                then
                        IFS=';' read -ra ARRAY <<< $QUERY
                        IFS='"' read -ra CORE <<< ${ARRAY[$INDEX]}
                        echo "${CORE[1]}"
                else
                        echo "None"
                fi
        fi

}

get_db_name()
{
	DB=$(drush st 2>/dev/null | grep -E 'Database name|DB name' | awk -F':' '{print $2}' | sed s/' '//g )
        local _res=$?
        if [ $_res -ne 0 ];
        then	
                echo "Error: not get Database name"
		return $_res
        else
                if [ "$DB" != "" ];
                then
                        echo "${DB}"
                else
	                echo "Error: Database name is empty"
                        return 1
                fi
        fi

}


get_memcached_key()
{
	site_path=$(drush st 2>/dev/null | grep 'Site path' | awk -F':' '{print $2}' | sed s/' '//g )
        local _res=$?
        if [ $_res -ne 0 ];
        then
                echo "Error: not get Site path"
                return $_res
        fi

	cache_default_class=$(php -r 'include $argv[1]."/settings.php"; if (isset($conf["cache_default_class"])) {print_r($conf["cache_default_class"]);}' "$site_path" 2>/dev/null)
        local _res=$?
        if [ $_res -ne 0 ];
        then
                echo "Error: not get cache_default_class"
                return $_res
	fi
	if [ "$cache_default_class" != "" ];
	then
		if [ "$cache_default_class" == "MemcacheStorage" ];
		then
	        	memcache_key_prefix=$(php -r 'include $argv[1]."/settings.php"; if (isset($conf["memcache_storage_key_prefix"])) {print_r($conf["memcache_storage_key_prefix"]);}' "$site_path" 2>/dev/null)
		else
			if [ "$cache_default_class" == "MemCacheDrupal" ];
			then
			        memcache_key_prefix=$(php -r 'include $argv[1]."/settings.php"; if (isset($conf["memcache_key_prefix"])) {print_r($conf["memcache_key_prefix"]);}' "$site_path" 2>/dev/null)
			else
				echo "$cache_default_class None"
				return 0
			fi
		fi
	        local _res=$?
	        if [ $_res -ne 0 ];
	        then
	                echo "Error: not get memcache_storage_key_prefix/memcache_key_prefix"
	                return $_res
	        fi
	        if [ "$memcache_key_prefix" != "" ];
	        then
	                echo "$cache_default_class $memcache_key_prefix"
	        else
	                echo "Error: not set memcache_storage_key_prefix/memcache_key_prefix"
			return 1
	        fi
	else
	        echo "None"
	fi
}

get_base_url()
{
        site_version=$(drush st 2>/dev/null | grep 'Drupal version' | awk -F':' '{print $2}' | sed s/' '//g)
        local _res=$?
        if [ $_res -ne 0 ] || [ "$site_version" == "" ];
        then
                echo "Error: not get version drupal"
                return $_res
        fi

        if [[ -z $(echo "$site_version" | sed -n '/^7./p') ]];
        then
		echo "None"
		return 0
	fi

        site_path=$(drush st 2>/dev/null | grep 'Site path' | awk -F':' '{print $2}' | sed s/' '//g )
        local _res=$?
        if [ $_res -ne 0 ];
        then
                echo "Error: not get Site path"
                return $_res
        fi
	base_url=$(php -r 'include $argv[1]."/settings.php"; if (isset($base_url)) { print_r($base_url) ;}' "$site_path" 2>/dev/null)
        if [ $_res -ne 0 ];
        then
                echo "Error: not get base_url"
                return $_res
        fi
        if [ "$base_url" != "" ];
        then
		echo "$base_url"

        else
                echo "None"
        fi
}


if [ "$1" == "" ];
then
	echo "Для получения информации о сайте укажите путь до сайта в параметрах скрипта- bash script.sh path_to_site"
	echo "Для сравнения информации двух сайтов укажите пути до сайтов в параметрах скрипта - bash script.sh path_to_site1 path_to_site2"
	exit 1
fi

echo "Проверка сайта №1 $1 ..."
cd $1
pwd
        info_site1[0]=$(get_solr_core)
        if [ $? -ne 0 ];
        then
                echo "Error check solr"
		echo "${info_site1[0]}"
                exit 1
        fi

        info_site1[1]=$(get_db_name)
        if [ $? -ne 0 ];
        then
                echo "Error check DB"
		echo "${info_site1[1]}"
                exit 1
        fi


        info_site1[2]=$(get_memcached_key)
        if [ $? -ne 0 ];
        then
                echo "Error check memcached key"
		echo "${info_site1[2]}"
                exit 1
        fi

        info_site1[3]=$(get_base_url)
        if [ $? -ne 0 ];
        then
                echo "Error check base url"
		echo "${info_site1[3]}"
                exit 1
        fi

echo "Информация для сайта №1:"
echo ${info_site1[*]} # Все записи в массиве


if [ "$2" == "" ];
then
	exit 0
fi
echo ""
echo "Проверка сайта №2 $2 ..."
cd $2
pwd
        info_site2[0]=$(get_solr_core)
        if [ $? -ne 0 ];
        then
                echo "Error check solr"
		echo "${info_site2[0]}"
                exit 1
        fi

        info_site2[1]=$(get_db_name)
        if [ $? -ne 0 ];
        then
                echo "Error check DB"
		echo "${info_site2[1]}"
                exit 1
        fi


        info_site2[2]=$(get_memcached_key)
        if [ $? -ne 0 ];
        then
                echo "Error check memcached key"
		echo "${info_site2[2]}"
                exit 1
        fi

        info_site2[3]=$(get_base_url)
        if [ $? -ne 0 ];
        then
                echo "Error check base url"
		echo "${info_site2[3]}"
                exit 1
        fi


echo "Информация для сайта №2:"
echo ${info_site2[*]} # Все записи в массиве

echo ""
echo "Сравнение настроек сайтов"
for (( i=0; i <= 3; i++ ))
do
if [ "${info_site1[$i]}" == "${info_site2[$i]}" ];
then
	echo "!!! Значения совпадают на сайтах: $i '${info_site1[$i]}' '${info_site2[$i]}'"
else
	echo "Значения отличаются на сайтах: $i '${info_site1[$i]}' '${info_site2[$i]}'"
fi
done
