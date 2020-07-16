# compare-info-sites
Информация о настройках сайта выводится в виде:
<solr core> <db name> <cache default class> <memcached key prefix> <base url>


Скрипт выполняет получение информации о настройках сайта, путь до которого указывается в параметрах скрипта.
bash compare-info-sites.sh <path_ro_site>


Для сравнения информации о настройках двух сайтов необходимо в параметрах указать пути до двух сайтов
bash compare-info-sites.sh <path_ro_site1> <path_ro_site2>
