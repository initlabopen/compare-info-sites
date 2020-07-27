# compare-info-sites
## Скрипт для получения информации о настройках Drupal сайтов.

Информация о настройках сайта выводится в виде:
<solr core> <db name> <cache default class> <memcached key prefix> <base url>


Команда для запуска скрипта:

bash compare-info-sites.sh <path_ro_site>

Также скрипт позволяет сравнить настройки двух сайтов.

Для сравнения информации о настройках двух сайтов необходимо в параметрах указать пути до двух сайтов
bash compare-info-sites.sh <path_ro_site1> <path_ro_site2>
