<?php

function perfmon_test_cpu() {

 $exectime = 0;
 $count = 400;
//  $count = 1;
 $count_for = 3000000;

 for ($i = 0; $i < $count; $i++) {
   $starttime = microtime(TRUE);

   for ($j = 0; $j < $count_for; $j++) {
     $test = 0;

     $test++;
     $test--;
     $test = 2 / 5;
     $test = 2 * 5;
   }
   $endtime = microtime(TRUE);
//    print_r($endtime - $starttime);
   $exectime += $endtime - $starttime;

 }

 return array('result' => round(1 / ($exectime / $count), 0), 'value' => '0');
}

$var=perfmon_test_cpu();
print_r($var);
