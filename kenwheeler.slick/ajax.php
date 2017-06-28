<?php
$datas = [];

if (isset($_GET['order_by'])) {
    $order_by = $_GET['order_by'];
} else {
    $order_by = 'asc';
}

$datas['Acrobat'] = 'http://www.avatarsdb.com/avatars/acrobat.gif';
$datas['Cat Rain'] = 'http://www.avatarsdb.com/avatars/cat_rain.gif';
$datas['Dota Windranger'] = 'http://www.avatarsdb.com/avatars/dota_windranger.jpg';
$datas['Fighting Funny'] = 'http://www.avatarsdb.com/avatars/fighting_funny.gif';
$datas['Fire 01'] = 'http://www.avatarsdb.com/avatars/fire_01.gif';
$datas['German Shepherd Puppy'] = 'http://www.avatarsdb.com/avatars/german_shepherd_puppy.jpg';
$datas['Girl With Cigarette'] = 'http://www.avatarsdb.com/avatars/girl_with_cigarette.jpg';
$datas['Hidden Cat'] = 'http://www.avatarsdb.com/avatars/hidden_cat.jpg';
$datas['Im Fabulous'] = 'http://www.avatarsdb.com/avatars/im_fabulous.jpg';
$datas['One Direction'] = 'http://www.avatarsdb.com/avatars/One_Direction.jpg';
$datas['Panda Kiss'] = 'http://www.avatarsdb.com/avatars/panda_kiss.gif';
$datas['PC User'] = 'http://www.avatarsdb.com/avatars/pc_user.gif';
$datas['Riri Queen'] = 'http://www.avatarsdb.com/avatars/riri_queen.gif';
$datas['Tennessee'] = 'http://www.avatarsdb.com/avatars/tennessee.jpg';
$datas['Tuxedo M'] = 'http://www.avatarsdb.com/avatars/Tuxedo_m.jpg';
$datas['Tuxedo Mask'] = 'http://www.avatarsdb.com/avatars/tuxedo_mask.jpg';
$datas['Ugly Face'] = 'http://www.avatarsdb.com/avatars/ugly_face.gif';
$datas['Waifu'] = 'http://www.avatarsdb.com/avatars/waifu.jpg';
$datas['Wolf In The Snow'] = 'http://www.avatarsdb.com/avatars/wolf_in_the_snow.jpg';
$datas['Xerxes Break Kevin'] = 'http://www.avatarsdb.com/avatars/xerxes_break_kevin.jpg';

switch ($order_by) {
    case 'desc':{krsort($datas);}
        break;

    case 'random':{
            $keys = array_keys($datas);
            shuffle($keys);
            $random = [];
            foreach ($keys as $key) {
                $random[$key] = $datas[$key];
            }
            $datas = $random;
        }break;

    case 'asc':
    default:
        {ksort($datas);}
        break;
}

header('Content-type: application/json; charset=utf-8');
echo json_encode([
    'datas' => $datas,
    'order_by' => $order_by,
]);
